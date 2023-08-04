// SPDX-License-Identifier: MIT License
pragma solidity >=0.8.0;

import "./Vault.sol";

/// @title VaultV2
/// @author @brianspha
/// @notice Vault Contract upgrade with a new fiesty name
/// @dev WIP
contract VaultV2 is Vault {
    function name() public view virtual override returns (string memory) {
        return "My Upgraded Vault name";
    }
}
