// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

// Import necessary libraries and contracts
import "../../../base/DefaultTokenTest.t.sol";
import "../../../../src/utils/errors/VaultErrors.sol";
import "../../../utils/TestingModifiers.sol";

contract VaultTokenRevertTest is DefaultTokenTest, TestingModifiers {
    function setUp() public virtual override {
        DefaultTokenTest.setUp();
    }

    function test_RevertWhenToken_NotInitialized() public whenNotInitialised {
        token = new VaultToken();
        vm.startPrank(spha);
        //set revert
        vm.expectRevert("ERC20: transfer amount exceeds balance");
        token.transfer(bob, defaultTransferAmount);
        vm.stopPrank();
    }

    function test_RevertWhenToken_Paused() public whenPaused {
        vm.startPrank(owner);
        token.pause();
        vm.stopPrank();
        vm.startPrank(spha);
        //set revert
        vm.expectRevert("Pausable: paused");
        token.transfer(bob, defaultTransferAmount);
        vm.stopPrank();
    }
}
