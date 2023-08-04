// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

/**
 * @title TestingEvents
 * @dev This contract provides event declarations to be used in the different Vault configurations.
 * It defines two events: `InvalidConfiguration` and `ValidConfiguration`.
 * These events can be emitted by the contracts that inherit from this contract to signal
 * changes in configuration status during testing.
 */
abstract contract TestingEvents {
    event InvalidConfiguration(string);
    event ValidConfiguration(string);
}
