// SPDX-License-Identifier: MIT License
pragma solidity >=0.8.0;

/// @title Vault errors
/// @author @brianspha
/// @notice File contains all errors used by the vault system
/// @dev WIP

/// @notice Error used whenever a zero address is detected
/// @dev error could be called if dynamic staking and auto compounding is disabled

error ZeroAddress();
/// @notice error called during construction of contract based on various factors
/// @dev error could be called if dynamic staking is enabled and auto compounding is disabled
/// @dev error could be called if dynamic staking is disabled and auto compounding is enabled
/// @dev theres no need for auto compounding since rewards are Fixed

error InvalidVaultConfig();

/// @notice Error used during deposit or whenever the max deposit allowed of the user
/// @notice has been reached
error MaxDepositReached();

/// @notice Error used when user attempt to witdraw rewards that are greater than balance
error InsufficientRewards();

/// @notice Error used when user attempt to witdraw an amount greater than their stake
error InsufficientBalance();

/// @notice Error used when user attempt to stake a 0 amount

error InvalidStakeAmount();
/// @notice Error used when an admin tries to update the rewards rate without
/// @notice having set the isDynamic property to true during init

error CannotUpdateRewardRate(string);

/// @notice Error used when contract is not initialised

error VaultNotInitialized();

/// @notice Error used when there are no rewards left in the contract for distribution

error NoRewardsAvailable();
