// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;
import "forge-std/Test.sol";
import "forge-std/console.sol";
import "../../../../base/DefaultVaultTest.t.sol";
import "../../../../../src/utils/errors/VaultErrors.sol";
import "../../../../utils/TestingModifiers.sol";

contract StaticVaultReverts is DefaultVaultTest, TestingModifiers {
    /************************************************************************************************
                                            SET UP FUNCITON
    ************************************************************************************************/

    function setUp() public virtual override {
        DefaultVaultTest.setUp();
    }

    function test_RevertWhen_CompoundingEnabled()
        external
        virtual
        whenDynamicIsEnabled
        whenAutoCompoundIsDisabled
    {
        vm.startPrank(owner);
        staticVault = new Vault();
        // init vault
        vm.expectRevert(InvalidVaultConfig.selector);
        staticVault.initialize(
            VaultConfig({
                token: vaultToken,
                rewardsToken: rewardsToken,
                name: "yStaticVault Token",
                symbol: "ySVT",
                vaultDynamic: true,
                compoundingEnabled: false,
                rewardRate: 40,
                maxStakeLength: 30
            })
        );
        vm.stopPrank();
    }

    function test_RevertWhen_Zero_RewardRate()
        external
        virtual
        whenRewardRateIsZero
    {
        vm.startPrank(owner);
        staticVault = new Vault();
        // init vault
        vm.expectRevert(InvalidVaultConfig.selector);
        staticVault.initialize(
            VaultConfig({
                token: vaultToken,
                rewardsToken: rewardsToken,
                name: "yStaticVault Token",
                symbol: "ySVT",
                vaultDynamic: true,
                compoundingEnabled: false,
                rewardRate: 0,
                maxStakeLength: 30
            })
        );
        vm.stopPrank();
    }

    function test_RevertWhen_Zero_MaxStakeLength()
        external
        virtual
        whenMaxStakeLengthIsZero
    {
        vm.startPrank(owner);
        staticVault = new Vault();

        // init vault
        vm.expectRevert(InvalidVaultConfig.selector);
        staticVault.initialize(
            VaultConfig({
                token: vaultToken,
                rewardsToken: rewardsToken,
                name: "yStaticVault Token",
                symbol: "ySVT",
                vaultDynamic: true,
                compoundingEnabled: false,
                rewardRate: 30,
                maxStakeLength: 0
            })
        );
        vm.stopPrank();
    }

    function test_RevertWhen_StaticVault_NotInitialised()
        external
        virtual
        whenContractNotInitialised
    {
        staticVault = new Vault();

        // set up expect
        vm.expectRevert(VaultNotInitialized.selector);
        staticVault.depositTokens(defaultStakingTokens, spha);
    }

    function test_RevertWhen_StaticVault_ChangingToDynamic()
        external
        virtual
        whenContractInitialised
    {
        staticVault = new Vault();
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
        // set up expect
        vm.startPrank(owner);
        vm.expectRevert(
            abi.encodeWithSelector(
                CannotUpdateRewardRate.selector,
                "Vault is not set to be dynamic"
            )
        );
        staticVault.updateRewardRate(1000);
        vm.stopPrank();
    }

    function test_RevertWhen_VaultPaused()
        external
        virtual
        whenDynamicIsEnabled
        whenPaused
        whenAutoCompoundIsDisabled
    {
        vm.startPrank(owner);
        staticVault = new Vault();
        // init vault
        staticVault.initialize(
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
        staticVault.pause();
        vm.stopPrank();

        _mintRewardsTokenToVault(staticVault);

        // ensure reward tokens were properly minted by owner
        assertEq(
            rewardsToken.balanceOf(address(staticVault)),
            defaultVaultRewardTokens
        );
        // stake defaultStakingTokens for spha
        vm.startPrank(spha);
        // approve vault for deposit
        vaultToken.approve(address(staticVault), defaultStakingTokens);

        // ensure vault was properly approved
        assertEq(
            vaultToken.allowance(spha, address(staticVault)),
            defaultStakingTokens
        );
        // set expect revert
        vm.expectRevert("Pausable: paused");

        // Here i would like to check for the emitted event but im yet to discover
        // a good way to do this
        staticVault.depositTokens(defaultStakingTokens, spha);

        vm.stopPrank();
    }

    function test_RevertWhen_NoRewards()
        external
        virtual
        whenNotPaused
        whenDynamicIsEnabled
        whenAutoCompoundIsDisabled
    {
        vm.startPrank(owner);
        staticVault = new Vault();
        // init vault
        staticVault.initialize(
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
        vm.stopPrank();

        // stake defaultStakingTokens for spha
        vm.startPrank(spha);
        // approve vault for deposit
        vaultToken.approve(address(staticVault), defaultStakingTokens);

        // ensure vault was properly approved
        assertEq(
            vaultToken.allowance(spha, address(staticVault)),
            defaultStakingTokens
        );
        // set expect revert

        vm.expectRevert(NoRewardsAvailable.selector);

        // Here i would like to check for the emitted event but im yet to discover
        // a good way to do this
        staticVault.depositTokens(defaultStakingTokens, spha);

        vm.stopPrank();
    }
}
