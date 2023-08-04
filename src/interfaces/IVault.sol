// SPDX-License-Identifier: MIT License
pragma solidity >=0.8.0;

import "../utils/structs/VaultStructs.sol";
import "../utils/errors/VaultErrors.sol";
import "../../lib/openzeppelin-contracts-upgradeable/contracts/token/ERC20/IERC20Upgradeable.sol";

/// @title IVault
/// @author @brianspha
/// @notice Interface defining functions to be implemented by any child contract
/// @dev Work in progress (WIP)
interface IVault {
    /// @notice Function allows any staker to stake an arbitrary amount of tokens
    /// @dev The amount must be greater than zero
    /// @dev The function can only be called when the contract is active, i.e., not paused
    /// @dev Emits a depositTokens event
    /// @param amount Number of tokens represented as amount * vault token decimals
    /// @param receiver Receiver of the shares token
    function depositTokens(
        uint256 amount,
        address receiver
    ) external returns (uint256);

    /// @notice Function allows any staker to withdraw an arbitrary amount of staked tokens
    /// @dev The amount must be greater than zero, and the staker must have a balance greater than or equal to the stake
    /// @dev The function reverts if the staker has no balance or the stake amount is 0
    /// @dev Emits a withdrawTokens event
    /// @param amount Number of tokens represented as amount * vault token decimals
    function withdrawTokens(uint256 amount) external;

    /// @notice Function initializes the vault
    /// @dev This needs to be called before any interactions are allowed
    /// @dev Reverts if the vault is static and compounding is enabled; there's no need
    /// @dev for compounding to be enabled since the rewards are constant as this
    /// @dev will not yield any additional earnings
    /// @dev Reverts if the vault is not static and compounding is disabled
    /// @dev The rewards are dynamic and can change over time; it might be more
    /// @dev beneficial for users to continuously compound their earnings automatically
    /// @param config The configuration object for initializing the vault
    function initialize(VaultConfig memory config) external;

    /// @notice Function withdraws everything, including the principal and rewards
    /// @dev The function returns the total withdrawn amount
    function withdrawEverything() external returns (uint256);

    /// @notice Function withdraws all available rewards
    function withdrawAllRewards() external;

    /// @notice Function withdraws a specific amount of rewards
    /// @param amount The number of rewards to withdraw
    function withdrawRewards(uint256 amount) external;

    /// @notice Function updates the reward rate for the vault
    /// @param rate The new reward rate to be set
    function updateRewardRate(uint256 rate) external;

    /// @notice Function retrieves the latest rewards earned by the staker
    /// @return The latest rewards earned by the staker
    function getLatestRewards() external returns (uint256);
}
