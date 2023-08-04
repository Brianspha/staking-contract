// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../../src/token/VaultToken.sol";

// @notice DefaultTokenTest Contract with common logic needed for basic setup for all tests

abstract contract DefaultTokenTest is Test {
    VaultToken public token;
    address public alice;
    address public spha;
    address public james;
    address public owner;
    address public bob;
    uint256 public immutable defaultOwnerTokenBalance = 99999999999999 ether;
    uint256 public immutable defaultTokenBalance = 1000 ether;
    uint256 public immutable defaultTransferAmount = 100 ether;

    /************************************************************************************************
                                            SET UP FUNCITON
    ************************************************************************************************/

    function setUp() public virtual {
        // create admin
        owner = _createUser("owner");

        // create new token instance
        token = new VaultToken();
        vm.startPrank(owner);

        // initialize token
        token.initialize("VT", "Vault Token");

        // mint tokens to admin
        token.mint(owner, defaultOwnerTokenBalance);

        // create other users
        spha = _createUserWithTokenBalance("spha");
        james = _createUserWithTokenBalance("james");
        alice = _createUserWithTokenBalance("alice");
        // create user without token balance
        bob = _createUser("bob");
        // label addresses
        vm.label(address(token), "Default Vault Token");
        vm.label(spha, "Spha address");
        vm.label(alice, "Alice address");
        vm.label(james, "James address");
        vm.label(owner, "Owner address");
        vm.label(bob, "Bob address");
    }

    function test_Token_Config() external {
        assertEq(token.totalSupply(), defaultOwnerTokenBalance);
        assertEq(token.name(), "Vault Token");
        assertEq(token.symbol(), "VT");
    }

    function _createUser(
        string memory name
    ) internal returns (address payable) {
        address payable user = payable(makeAddr(name));
        vm.deal({account: user, newBalance: 1000 ether});

        return user;
    }

    function _createUserWithTokenBalance(
        string memory name
    ) internal returns (address payable) {
        vm.startPrank(owner);
        address payable user = payable(makeAddr(name));
        vm.deal({account: user, newBalance: 1000 ether});
        token.approve(user, defaultTokenBalance);
        assertEq(token.allowance(owner, user), defaultTokenBalance);
        token.transfer(user, defaultTokenBalance);
        assertEq(token.balanceOf(user), defaultTokenBalance);
        vm.stopPrank();

        return user;
    }
}
