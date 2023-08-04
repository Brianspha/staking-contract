// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

// Import necessary libraries and contracts
import "../../../base/DefaultTokenTest.t.sol";
import "../../../../src/utils/errors/VaultErrors.sol";
import "../../../utils/TestingModifiers.sol";

contract VaultTokenTest is DefaultTokenTest, TestingModifiers {
    function setUp() public virtual override {
        DefaultTokenTest.setUp();
    }

    function test_TransferFrom_Spha_ToBob()
        public
        whenNotPaused
        whenInitialised
    {
        vm.startPrank(spha);
        token.transfer(bob, defaultTransferAmount);
        assertEq(token.balanceOf(bob), defaultTransferAmount);
        vm.stopPrank();
    }

    function test_TransferFrom_Bob_ToSpha()
        public
        whenNotPaused
        whenInitialised
    {
        //create bob with token balance
        bob = _createUserWithTokenBalance("bob");
        vm.startPrank(bob);
        uint256 sphasBalanceBefore = token.balanceOf(spha);
        token.transfer(spha, defaultTransferAmount);
        assertEq(
            token.balanceOf(spha),
            defaultTransferAmount + sphasBalanceBefore
        );
        vm.stopPrank();
    }
}
