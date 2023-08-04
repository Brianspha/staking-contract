// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../../src/vault/Vault.sol";
import "../../src/token/VaultToken.sol";

// @notice BaseVault Contract with common logic needed for basic setup for all tests
abstract contract DefaultVaultTest is Test {
    Vault public autoCompoundingDynamicVault;
    Vault public staticVault;
    VaultToken public vaultToken;
    VaultToken public rewardsToken;
    address public alice;
    address public spha;
    address public james;
    address public owner;
    uint40 public constant THREE_JULY_2023 = 1691040865;
    uint256 public immutable defaultTokenBalance = 1000 ether;
    uint256 public immutable defaultOwnerTokenBalance = 10000000000 ether;
    uint256 public immutable defaultStakingTokens = 100 ether;
    uint256 public immutable defaultVaultRewardTokens = 999999999999999 ether;

    /************************************************************************************************
                                            SET UP FUNCITON
    ************************************************************************************************/

    function setUp() public virtual {
        rewardsToken = new VaultToken();
        vaultToken = new VaultToken();
        owner = _createUser("owner");

        vm.startPrank(owner);
        // init token
        rewardsToken.initialize("VT", "Vault Token");
        vaultToken.initialize("VT", "Vault Token");

        // mint tokens to admin
        vaultToken.mint(owner, defaultOwnerTokenBalance);
        rewardsToken.mint(owner, defaultOwnerTokenBalance);
        vm.stopPrank();

        // create other users
        spha = _createUserWithTokenBalance("spha");
        james = _createUserWithTokenBalance("james");
        alice = _createUserWithTokenBalance("alice");

        // Label base test contracts
        vm.label(
            address(autoCompoundingDynamicVault),
            "Auto Compouding Dynamic Vault"
        );
        vm.label(address(staticVault), "Static Vault");
        vm.label(address(vaultToken), "Vault Token (yVT)");
        vm.label(address(rewardsToken), "Rewards for Token (yVT)");
        vm.label(spha, "Spha address");
        vm.label(alice, "Alice address");
        vm.label(james, "James address");
        vm.label(owner, "Owner address");
    }

    function test_Vault_Token_Config() public virtual {
        assertEq(vaultToken.totalSupply(), defaultOwnerTokenBalance);
        assertEq(vaultToken.name(), "Vault Token");
        assertEq(vaultToken.symbol(), "VT");
    }

    function test_yStatic_Vault_Config() public virtual {
        staticVault = _initVault(
            VaultConfig({
                token: vaultToken,
                rewardsToken: rewardsToken,
                name: "yStaticVault Token",
                symbol: "ySVT",
                vaultDynamic: false,
                compoundingEnabled: false,
                rewardRate: 40,
                maxStakeLength: 30
            })
        );

        assertEq(staticVault.name(), "yStaticVault Token");
        assertEq(staticVault.symbol(), "ySVT");
        assertEq(staticVault.decimals(), 18);
        assertEq(staticVault.isDynamic(), false);
        assertEq(staticVault.autocompoundEnabled(), false);
        assertEq(staticVault.isInitialized(), true);
    }

    function test_Compounding_DynamicVaultConfig() public virtual {
        autoCompoundingDynamicVault = _initVault(
            VaultConfig({
                token: vaultToken,
                rewardsToken: rewardsToken,
                name: "yCompoudingDynamicVault Token",
                symbol: "yACDVT",
                vaultDynamic: true,
                compoundingEnabled: true,
                rewardRate: 40,
                maxStakeLength: 30
            })
        );
        assertEq(
            autoCompoundingDynamicVault.name(),
            "yCompoudingDynamicVault Token"
        );
        assertEq(autoCompoundingDynamicVault.symbol(), "yACDVT");
        assertEq(autoCompoundingDynamicVault.decimals(), 18);
        assertEq(autoCompoundingDynamicVault.isDynamic(), true);
        assertEq(autoCompoundingDynamicVault.autocompoundEnabled(), true);
        assertEq(autoCompoundingDynamicVault.isInitialized(), true);
    }

    function test_Approve_Vaults() public virtual {
        staticVault = _initVault(
            VaultConfig({
                token: vaultToken,
                rewardsToken: rewardsToken,
                name: "yStaticVault Token",
                symbol: "ySVT",
                vaultDynamic: false,
                compoundingEnabled: false,
                rewardRate: 40,
                maxStakeLength: 30
            })
        );
        autoCompoundingDynamicVault = _initVault(
            VaultConfig({
                token: vaultToken,
                rewardsToken: rewardsToken,
                name: "yCompoudingDynamicVault Token",
                symbol: "yACDVT",
                vaultDynamic: true,
                compoundingEnabled: true,
                rewardRate: 40,
                maxStakeLength: 30
            })
        );
        vm.startPrank(owner);
        // aprove rewards for vaults
        vaultToken.approve(address(staticVault), vaultToken.balanceOf(owner));
        vaultToken.approve(
            address(autoCompoundingDynamicVault),
            vaultToken.balanceOf(owner)
        );
        rewardsToken.approve(
            address(autoCompoundingDynamicVault),
            vaultToken.balanceOf(owner)
        );
        rewardsToken.approve(address(staticVault), vaultToken.balanceOf(owner));

        // ensure tokens allowances equal owner balance
        assertEq(
            rewardsToken.allowance(owner, address(staticVault)),
            vaultToken.balanceOf(owner)
        );
        assertEq(
            rewardsToken.allowance(owner, address(autoCompoundingDynamicVault)),
            vaultToken.balanceOf(owner)
        );
        assertEq(
            vaultToken.allowance(owner, address(staticVault)),
            vaultToken.balanceOf(owner)
        );
        assertEq(
            vaultToken.allowance(owner, address(autoCompoundingDynamicVault)),
            vaultToken.balanceOf(owner)
        );
        vm.stopPrank();
    }

    function test_TokensMinted_ToOwner() public virtual {
        // ensure tokens were minted
        assertEq(rewardsToken.balanceOf(owner), defaultOwnerTokenBalance);
        assertEq(
            vaultToken.balanceOf(owner),
            defaultOwnerTokenBalance - defaultTokenBalance * 3
        );
    }

    function _createUserWithTokenBalance(
        string memory name
    ) internal returns (address payable) {
        vm.startPrank(owner);
        address payable user = payable(makeAddr(name));
        vm.deal({account: user, newBalance: 1000 ether});
        vaultToken.approve(user, defaultTokenBalance);
        assertEq(vaultToken.allowance(owner, user), defaultTokenBalance);
        vaultToken.transfer(user, defaultTokenBalance);
        assertEq(vaultToken.balanceOf(user), defaultTokenBalance);
        vm.stopPrank();
        return user;
    }

    function _createUser(
        string memory name
    ) internal returns (address payable) {
        address payable user = payable(makeAddr(name));
        vm.deal({account: user, newBalance: 1000 ether});
        return user;
    }

    function _initVault(VaultConfig memory config) internal returns (Vault) {
        vm.startPrank(owner);
        Vault tempVault = new Vault();
        // init vault
        tempVault.initialize(config);
        vm.stopPrank();
        return tempVault;
    }

    function _mintRewardsTokenToVault(Vault vault) internal {
        vm.startPrank(owner);

        // aprove rewards for vaults
        rewardsToken.mint(address(vault), defaultVaultRewardTokens);

        vm.stopPrank();
    }

    function _mintRewardsTokenToVault( Vault vault,uint256 amount) internal {
        vm.startPrank(owner);

        // aprove rewards for vaults
        rewardsToken.mint(address(vault), amount);

        vm.stopPrank();
    }
}
