// SPDX-License-Identifier: MIT License
pragma solidity >=0.8.0;

import "../../lib/openzeppelin-contracts-upgradeable/contracts/token/ERC20/extensions/ERC4626Upgradeable.sol";
import "../../lib/openzeppelin-contracts-upgradeable/contracts/security/PausableUpgradeable.sol";
import "../../lib/openzeppelin-contracts-upgradeable/contracts/security/ReentrancyGuardUpgradeable.sol";
import "../../lib/openzeppelin-contracts-upgradeable/contracts/access/OwnableUpgradeable.sol";
import "../../lib/openzeppelin-contracts-upgradeable/contracts/token/ERC20/IERC20Upgradeable.sol";
import "../../lib/openzeppelin-contracts-upgradeable/contracts/proxy/utils/UUPSUpgradeable.sol";

import "../interfaces/IVault.sol";
import "../utils/events/VaultEvents.sol";

/// @title Vault
/// @author @brianspha
/// @notice Vault Contract that allows users to stake an arbitrary token
/// @dev WIP
contract Vault is
    IVault,
    ERC4626Upgradeable,
    PausableUpgradeable,
    OwnableUpgradeable,
    VaultEvents,
    ReentrancyGuardUpgradeable
{
    /**==============================================Modifiers==============================================**/

    modifier whenRewardsAvailable() {
        _checkVaultRewardsBalance();
        _;
    }
    modifier whenInitialised() {
        if (!isInitialized) revert VaultNotInitialized();
        _;
    }

    /**==============================================Vault Variables==============================================**/
    mapping(address => Staker) public stakers;
    bool public isDynamic;
    bool public autocompoundEnabled;
    bool public isInitialized;
    uint16 public rewardsDenominator;
    uint256 public rewardsRate;
    uint256 public maxStakingDuration;
    string public vaultName;
    string public vaultSymbol;
    IERC20Upgradeable public rewardsToken;

    constructor() payable {}

    /**==============================================External Functions==============================================**/

    /**==============================================Public Functions==============================================**/

    function initialize(
        VaultConfig memory config
    ) public virtual override initializer {
        if (
            (config.vaultDynamic && !config.compoundingEnabled) ||
            (!config.vaultDynamic && config.compoundingEnabled) ||
            ((config.maxStakeLength == 0 || config.rewardRate == 0))
        ) revert InvalidVaultConfig();
        isInitialized = true;
        rewardsToken = config.rewardsToken;
        isDynamic = config.vaultDynamic;
        autocompoundEnabled = config.compoundingEnabled;
        maxStakingDuration = config.maxStakeLength * 86400;
        rewardsRate = config.rewardRate;
        vaultName = config.name;
        vaultSymbol = config.symbol;
        rewardsDenominator = 1000;
        __Ownable_init();
        __Pausable_init();
        __ERC4626_init(config.token);
        __ReentrancyGuard_init();
    }

    function depositTokens(
        uint256 amount,
        address reciever
    )
        public
        virtual
        override
        whenInitialised
        whenNotPaused
        nonReentrant
        whenRewardsAvailable
        returns (uint256)
    {
        if (reciever == address(0)) revert ZeroAddress();
        if (amount <= 0) revert InvalidStakeAmount();
        if (amount > maxDeposit(_msgSender())) revert MaxDepositReached();

        stakers[reciever].startDate = block.timestamp;

        unchecked {
            stakers[reciever].amount += amount;
        }

        uint256 shares = previewDeposit(amount);
        _deposit(_msgSender(), reciever, amount, shares);
        _updateRewards(reciever);

        return shares;
    }

    function withdrawEverything()
        public
        virtual
        override
        whenRewardsAvailable
        nonReentrant
        returns (uint256)
    {
        if (balanceOf(_msgSender()) <= 0) revert InsufficientBalance();

        withdrawAllRewards();
        Staker storage staker = stakers[_msgSender()];
        staker.amount = 0;
        uint256 shares = balanceOf(_msgSender());
        uint256 assets = previewRedeem(shares);
        redeem(assets, _msgSender(), _msgSender());

        return shares;
    }

    function withdrawAllRewards()
        public
        virtual
        override
        whenRewardsAvailable
        whenInitialised
    {
        Staker storage staker = stakers[_msgSender()];
        uint256 rewards = staker.rewards;
        if (rewards <= 0) revert InsufficientRewards();

        _updateRewards(_msgSender());
        staker.startDate = block.timestamp;
        staker.rewards = 0;

        if (autocompoundEnabled) {
            _burn(_msgSender(), rewards);
        } else {
            rewardsToken.transfer(_msgSender(), rewards);
        }

        emit RedeemedRewards(_msgSender(), rewards, staker.rewards);
    }

    function updateRewardRate(
        uint256 rate
    ) public virtual override onlyOwner whenInitialised {
        if (!isDynamic)
            revert CannotUpdateRewardRate("Vault is not set to be dynamic");
        if (rate == 0) revert CannotUpdateRewardRate("Reward rate cannot be 0");
        rewardsRate = rate;
    }

    function withdrawRewards(
        uint256 amount
    ) external virtual override whenInitialised nonReentrant {
        Staker storage staker = stakers[_msgSender()];
        _updateRewards(_msgSender());

        if (staker.rewards < amount) revert InsufficientRewards();

        unchecked {
            staker.rewards -= amount;
        }

        if (autocompoundEnabled) {
            _burn(_msgSender(), amount);
        }

        rewardsToken.transfer(_msgSender(), amount);

        emit RedeemedRewards(_msgSender(), amount, staker.rewards);
    }

    function withdrawTokens(
        uint256 amount
    ) public virtual override whenInitialised nonReentrant {
        Staker storage staker = stakers[_msgSender()];
        if (staker.amount <= 0 || staker.amount < amount)
            revert InsufficientBalance();
        uint256 shares;
        unchecked {
            staker.amount -= amount;
            shares = balanceOf(_msgSender()) - amount;
        }

        uint256 assets = previewRedeem(shares);
        redeem(assets, _msgSender(), _msgSender());
    }

    function symbol()
        public
        view
        virtual
        override(ERC20Upgradeable, IERC20MetadataUpgradeable)
        returns (string memory)
    {
        return vaultSymbol;
    }

    function name()
        public
        view
        virtual
        override(ERC20Upgradeable, IERC20MetadataUpgradeable)
        returns (string memory)
    {
        return vaultName;
    }

    function unPause() public onlyOwner {
        _unpause();
    }

    function pause() public onlyOwner {
        _pause();
    }

    function getLatestRewards() public virtual override returns (uint256) {
        _updateRewards(_msgSender());

        return stakers[_msgSender()].rewards;
    }

    /**==============================================Internal Functions==============================================**/

    function _calculateRewards(uint256 amount) internal view returns (uint256) {
        return (amount * rewardsRate) / rewardsDenominator;
    }

    function _updateRewards(address user) internal returns (uint256) {
        uint256 rewards = _getRewards(user);
        Staker storage staker = stakers[user];
        uint256 oldRewardsBalance = staker.rewards;

        if (autocompoundEnabled) {
            unchecked {
                staker.amount += rewards;
            }

            uint256 shares = previewMint(rewards);
            _mint(_msgSender(), shares);
        }

        unchecked {
            staker.rewards += rewards;
        }

        emit UpdatedRewards(
            _msgSender(),
            rewards,
            staker.rewards,
            oldRewardsBalance
        );

        return rewards;
    }

    function _getRewards(
        address stakerAddress
    ) internal view returns (uint256) {
        Staker memory staker = stakers[stakerAddress];

        // No rewards if staker has not started staking or started in the future
        if (staker.startDate == 0 || block.timestamp < staker.startDate) {
            return 0;
        }

        uint256 rewards = _calculateRewards(staker.amount);

        // Calculate staking duration
        uint256 stakingDuration = block.timestamp - staker.startDate;

        // Cap the staking duration at maxStakingDuration
        stakingDuration = stakingDuration > maxStakingDuration
            ? maxStakingDuration
            : stakingDuration;

        // Calculate rewards based on the actual staking duration
        rewards = (rewards * stakingDuration) / maxStakingDuration;

        return rewards;
    }

    function _checkVaultRewardsBalance() internal view {
        uint256 rewardValultBalance = rewardsToken.balanceOf(address(this));

        if (rewardValultBalance <= 0) revert NoRewardsAvailable();
    }

    ///@dev required by the OZ UUPS module
    function _authorizeUpgrade(address) internal onlyOwner {}
    /**==============================================Private Functions==============================================**/
}
