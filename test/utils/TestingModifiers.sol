// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

/**
 * @title TestingModifiers
 * @dev This contract provides various modifiers to be used in testing the different Vault configurations.
 * It includes modifiers to check configuration, dynamic status, auto-compound status,
 * reward rate, max stake length, contract initialization status, and paused status.
 * These modifiers are used for testing purposes and are abstract, meaning they should
 * be implemented in the derived contracts that use them.
 */
import "./TestingEvents.sol";
import "../../src/vault/Vault.sol";
import "forge-std/console.sol";

abstract contract TestingModifiers is TestingEvents {
    modifier whenInvalidConfiguration(string memory reason) {
        emit InvalidConfiguration(reason);
        _;
    }
    modifier whenDynamicIsDisabled() {
        _;
    }
    modifier whenDynamicIsEnabled() {
        _;
    }
    modifier whenAutoCompoundIsDisabled() {
        _;
    }
    modifier whenAutoCompoundIsEnabled() {
        _;
    }
    modifier whenRewardRateIsNotZero() {
        _;
    }
    modifier whenRewardRateIsZero() {
        _;
    }
    modifier whenMaxStakeLengthIsNotZero() {
        _;
    }

    modifier whenMaxStakeLengthIsZero() {
        _;
    }

    modifier whenContractInitialised() {
        _;
    }

    modifier whenContractNotInitialised() {
        _;
    }

    modifier whenNotPaused() {
        _;
    }
    modifier whenPaused() {
        _;
    }
    modifier whenNotInitialised() {
        _;
    }
    modifier whenInitialised() {
        _;
    }
}
