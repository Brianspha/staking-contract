// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;
import "forge-std/Test.sol";
import "forge-std/console.sol";
import "../../../../base/DefaultVaultTest.t.sol";
import "../../../../../src/utils/errors/VaultErrors.sol";
import "../../../../utils/TestingModifiers.sol";

contract StaticVault is DefaultVaultTest, TestingModifiers {
    /************************************************************************************************
                                            SET UP FUNCITON
    ************************************************************************************************/

    function setUp() public virtual override {
        DefaultVaultTest.setUp();
    }

    function test_Deposit_TokensTo_StaticVault()
        external
        virtual
        whenDynamicIsDisabled
        whenAutoCompoundIsDisabled
        whenRewardRateIsNotZero
        whenMaxStakeLengthIsNotZero
        whenNotPaused
    {
        staticVault = new Vault();

        // init vault by vault owner
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
        // Here i would like to check for the emitted event but im yet to discover
        // a good way to do this
        staticVault.depositTokens(defaultStakingTokens, spha);

        // check sphas balance for ySVT to be equal to [defaultStakingTokens]
        assertEq(staticVault.balanceOf(spha), defaultStakingTokens);
    }

    function test_WithdrawRewards_StaticVault()
        external
        virtual
        whenDynamicIsDisabled
        whenAutoCompoundIsDisabled
        whenRewardRateIsNotZero
        whenMaxStakeLengthIsNotZero
        whenNotPaused
    {
        // reset vault state
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
        // Here i would like to check for the emitted event but im yet to discover
        // a good way to do this
        staticVault.depositTokens(defaultStakingTokens, spha);

        // check sphas balance for ySVT to be equal to [defaultStakingTokens]
        assertEq(staticVault.balanceOf(spha), defaultStakingTokens);

        // Fast foward time by 1 day
        vm.warp(block.timestamp + 1 days);
        uint256 rewards = staticVault.getLatestRewards();
        uint256 sphasRewardsBalanceBefore = rewardsToken.balanceOf(spha);
        // ensure that sphas balance was 0
        assertEq(sphasRewardsBalanceBefore, 0);

        // Now we withdraw the rewards
        staticVault.withdrawRewards(rewards);
        assertEq(rewardsToken.balanceOf(spha), rewards);
    }

    function test_WithdrawAllRewards_StaticVault()
        external
        virtual
        whenDynamicIsDisabled
        whenAutoCompoundIsDisabled
        whenRewardRateIsNotZero
        whenMaxStakeLengthIsNotZero
        whenNotPaused
    {
        // reset vault state
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
        // Here i would like to check for the emitted event but im yet to discover
        // a good way to do this
        staticVault.depositTokens(defaultStakingTokens, spha);

        // check sphas balance for ySVT to be equal to [defaultStakingTokens]
        assertEq(staticVault.balanceOf(spha), defaultStakingTokens);

        // Fast foward time by 30 day
        vm.warp(block.timestamp + 30 days);
        uint256 rewards = staticVault.getLatestRewards();
        uint256 sphasRewardsBalanceBefore = rewardsToken.balanceOf(spha);
        // ensure that sphas balance was 0
        assertEq(sphasRewardsBalanceBefore, 0);

        // Now we withdraw the rewards
        staticVault.withdrawAllRewards();
        // check to see if any reward remain
        assertEq(staticVault.getLatestRewards() / 10 ** 18, 0);
        // check to see if rewards were transfered
        assertEq(rewardsToken.balanceOf(spha), rewards);
    }

    function test_WithdrawEverything_StaticVault()
        external
        virtual
        whenDynamicIsDisabled
        whenAutoCompoundIsDisabled
        whenRewardRateIsNotZero
        whenMaxStakeLengthIsNotZero
        whenNotPaused
    {
        // reset vault state
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
        // Here i would like to check for the emitted event but im yet to discover
        // a good way to do this
        staticVault.depositTokens(defaultStakingTokens, spha);

        // check sphas balance for ySVT to be equal to [defaultStakingTokens]
        assertEq(staticVault.balanceOf(spha), defaultStakingTokens);

        // Fast foward time by 30 day
        vm.warp(block.timestamp + 30 days);
        uint256 rewards = staticVault.getLatestRewards();
        uint256 sphasRewardsBalanceBefore = rewardsToken.balanceOf(spha);
        // ensure that sphas balance was 0
        assertEq(sphasRewardsBalanceBefore, 0);

        // Now we withdraw the rewards
        staticVault.withdrawEverything();
        // check to see if any reward remain
        assertEq(staticVault.getLatestRewards() / 10 ** 18, 0);
        // check to see if rewards were transfered
        assertEq(rewardsToken.balanceOf(spha), rewards);
    }
      function test_WithdrawTokens_StaticVault()
        external
        virtual
        whenDynamicIsDisabled
        whenAutoCompoundIsDisabled
        whenRewardRateIsNotZero
        whenMaxStakeLengthIsNotZero
        whenNotPaused
    {
        // Reset vault state
        staticVault = _initVault(
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

        _mintRewardsTokenToVault(staticVault);

        // ensure reward tokens were properly minted by owner
        assertEq(
            rewardsToken.balanceOf(address(staticVault)),
            defaultVaultRewardTokens
        );
        // stake defaultStakingTokens for spha
        vm.startPrank(spha);

        // approve vault for deposit
        vaultToken.approve(
            address(staticVault),
            defaultStakingTokens
        );

        // ensure vault was properly approved
        assertEq(
            vaultToken.allowance(spha, address(staticVault)),
            defaultStakingTokens
        );

        // Here i would like to check for the emitted event but im yet to discover
        // a good way to do this
        staticVault.depositTokens(defaultStakingTokens, spha);

        uint256 halfTokens = defaultStakingTokens / 2;

        // Now we withdraw half the tokens we staked
        staticVault.withdrawTokens(halfTokens);
        uint256 balanceAfter = staticVault.balanceOf(spha);
        // Sphas balance should equal half the tokens
        assertEq(halfTokens, balanceAfter);
    }
}
