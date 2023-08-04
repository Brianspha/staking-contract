// SPDX-License-Identifier: MIT License
import "../../../lib/openzeppelin-contracts-upgradeable/contracts/token/ERC20/IERC20Upgradeable.sol";

pragma solidity >=0.8.0;

struct Staker {
    uint256 amount;
    uint256 rewards;
    uint256 startDate;
}
/// @param token The token used for staking in the vault
/// @param rewardsToken_ The token used for paying rewards
/// @param vaultDynamic Indicates if the vault is dynamic or not
/// @param compoundingEnabled Indicates if compouding is enabled
/// @param rewardRate The rate at which the staker will earn their rewards e.g 40=4% i.e. 40/1000
/// @param _symbol The symbol of the vault
/// @param _name The name of the vault
/// @param maxStakeLength Indicates the length with which the rewards are redemable in the instance where
/// Staking is static e.g. 7= 7 days

struct VaultConfig {
    IERC20Upgradeable token;
    IERC20Upgradeable rewardsToken;
    string name;
    string symbol;
    bool vaultDynamic;
    bool compoundingEnabled;
    uint256 rewardRate;
    uint256 maxStakeLength;
}
