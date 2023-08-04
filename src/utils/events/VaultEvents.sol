// SPDX-License-Identifier: MIT License
pragma solidity >=0.8.0;

/**
 * @title VaultEvents
 * @dev Contract containing events related to the Vault contract.
 */
abstract contract VaultEvents {
    /**
     * @dev Emitted when a user deposits tokens into the Vault.
     * @param user The address of the user who deposited the tokens.
     * @param amount The amount of tokens deposited.
     */
    event DepositTokens(address indexed user, uint256 indexed amount);

    /**
     * @dev Emitted when a user withdraws tokens from the Vault.
     * @param user The address of the user who withdrew the tokens.
     * @param amount The amount of tokens withdrawn.
     */
    event WithdrewTokens(address indexed user, uint256 indexed amount);

    /**
     * @dev Emitted when a user redeems their rewards from the Vault.
     * @param user The address of the user who redeemed rewards.
     * @param amount The amount of rewards redeemed.
     * @param balance The updated balance of rewards after redemption.
     */
    event RedeemedRewards(
        address indexed user,
        uint256 indexed amount,
        uint256 indexed balance
    );

    /**
     * @dev Emitted when a user claims additional tokens as rewards from the Vault.
     * @param user The address of the user who claimed additional tokens.
     * @param amount The amount of tokens claimed.
     */
    event ClaimTokens(address indexed user, uint256 indexed amount);

    /**
     * @dev Emitted when the rewards for a user are updated.
     * @param user The address of the user whose rewards were updated.
     * @param amount The amount of additional rewards earned.
     * @param newBalance The new total balance of rewards after the update.
     * @param oldBalance The previous total balance of rewards.
     */
    event UpdatedRewards(
        address indexed user,
        uint256 indexed amount,
        uint256 indexed newBalance,
        uint256 oldBalance
    );
}
