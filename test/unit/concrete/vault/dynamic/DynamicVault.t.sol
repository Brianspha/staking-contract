// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

// Import necessary libraries and contracts
import "forge-std/Test.sol";
import "forge-std/console.sol";
import "../../../../base/DefaultVaultTest.t.sol";
import "../../../../../src/utils/errors/VaultErrors.sol";
import "../../../../utils/TestingModifiers.sol";

// DynamicVault contract inheriting from DefaultVaultTest and TestingModifiers
contract DynamicVault is DefaultVaultTest, TestingModifiers {
    /************************************************************************************************
                                            SET UP FUNCTION
    ************************************************************************************************/

    // setUp function to initialize the test environment
    function setUp() public virtual override {
        DefaultVaultTest.setUp();
        autoCompoundingDynamicVault = new Vault();
        // init vault by vault owner
        autoCompoundingDynamicVault = _initVault(
            VaultConfig({
                token: vaultToken,
                rewardsToken: rewardsToken,
                name: "yautoCompoundingDynamicVault Token",
                symbol: "ySVT",
                vaultDynamic: false,
                compoundingEnabled: false,
                rewardRate: 40,
                maxStakeLength: 30
            })
        );
    }

    /*********************************** TEST FUNCTIONS ***********************************/

    // Test deposit function for AutoCompoundingDynamicVault
    function test_Deposit_TokensTo_AutoCompoundingDynamicVault()
        external
        virtual
        whenDynamicIsDisabled
        whenAutoCompoundIsDisabled
        whenRewardRateIsNotZero
        whenMaxStakeLengthIsNotZero
        whenNotPaused
    {
        autoCompoundingDynamicVault = new Vault();

        // init vault by vault owner
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

        _mintRewardsTokenToVault(autoCompoundingDynamicVault);

        // ensure reward tokens were properly minted by owner
        assertEq(
            rewardsToken.balanceOf(address(autoCompoundingDynamicVault)),
            defaultVaultRewardTokens
        );
        // stake defaultStakingTokens for spha
        vm.startPrank(spha);

        // approve vault for deposit
        vaultToken.approve(
            address(autoCompoundingDynamicVault),
            defaultStakingTokens
        );

        // ensure vault was properly approved
        assertEq(
            vaultToken.allowance(spha, address(autoCompoundingDynamicVault)),
            defaultStakingTokens
        );
        // Here i would like to check for the emitted event but im yet to discover
        // a good way to do this
        autoCompoundingDynamicVault.depositTokens(defaultStakingTokens, spha);

        // check sphas balance for ySVT to be equal to [defaultStakingTokens]
        assertEq(
            autoCompoundingDynamicVault.balanceOf(spha),
            defaultStakingTokens
        );
    }

    // Test WithdrawRewards function for AutoCompoundingDynamicVault
    function test_WithdrawRewards_AutoCompoundingDynamicVault()
        external
        virtual
        whenDynamicIsDisabled
        whenAutoCompoundIsDisabled
        whenRewardRateIsNotZero
        whenMaxStakeLengthIsNotZero
        whenNotPaused
    {
        // Reset vault state
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

        _mintRewardsTokenToVault(autoCompoundingDynamicVault);

        // ensure reward tokens were properly minted by owner
        assertEq(
            rewardsToken.balanceOf(address(autoCompoundingDynamicVault)),
            defaultVaultRewardTokens
        );
        // stake defaultStakingTokens for spha
        vm.startPrank(spha);

        // approve vault for deposit
        vaultToken.approve(
            address(autoCompoundingDynamicVault),
            defaultStakingTokens
        );

        // ensure vault was properly approved
        assertEq(
            vaultToken.allowance(spha, address(autoCompoundingDynamicVault)),
            defaultStakingTokens
        );

        // Here i would like to check for the emitted event but im yet to discover
        // a good way to do this
        autoCompoundingDynamicVault.depositTokens(defaultStakingTokens, spha);

        // Fast forward time by 1 day
        vm.warp(block.timestamp + 1 days);
        uint256 rewards = autoCompoundingDynamicVault.getLatestRewards();
        uint256 sphasRewardsBalanceBefore = rewardsToken.balanceOf(spha);

        // ensure that sphas balance was 0
        assertEq(sphasRewardsBalanceBefore, 0);

        // Now we withdraw the rewards
        autoCompoundingDynamicVault.withdrawRewards(rewards);
        assertEq(rewardsToken.balanceOf(spha), rewards);
    }

    function test_WithdrawTokens_AutoCompoundingDynamicVault()
        external
        virtual
        whenDynamicIsDisabled
        whenAutoCompoundIsDisabled
        whenRewardRateIsNotZero
        whenMaxStakeLengthIsNotZero
        whenNotPaused
    {
        // Reset vault state
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

        _mintRewardsTokenToVault(autoCompoundingDynamicVault);

        // ensure reward tokens were properly minted by owner
        assertEq(
            rewardsToken.balanceOf(address(autoCompoundingDynamicVault)),
            defaultVaultRewardTokens
        );
        // stake defaultStakingTokens for spha
        vm.startPrank(spha);

        // approve vault for deposit
        vaultToken.approve(
            address(autoCompoundingDynamicVault),
            defaultStakingTokens
        );

        // ensure vault was properly approved
        assertEq(
            vaultToken.allowance(spha, address(autoCompoundingDynamicVault)),
            defaultStakingTokens
        );

        // Here i would like to check for the emitted event but im yet to discover
        // a good way to do this
        autoCompoundingDynamicVault.depositTokens(defaultStakingTokens, spha);

        uint256 halfTokens = defaultStakingTokens / 2;

        // Now we withdraw half the tokens we staked
        autoCompoundingDynamicVault.withdrawTokens(halfTokens);
        uint256 balanceAfter = autoCompoundingDynamicVault.balanceOf(spha);
        // Sphas balance should equal half the tokens
        assertEq(halfTokens, balanceAfter);
    }
}
