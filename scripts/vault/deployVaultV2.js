const { ethers, upgrades } = require("hardhat");
const constants = require("../utils/index");

const DEPLOYED_VAULT_TOKEN = "0x0372c5F3e23AD56AF9694462300c92632b6ee326";
const DEPLOYED_REWARDS_TOKEN = "0xe6eE5106E269D9a5d8d0E5EF4f78f39c3fcDA7f8";
const DEPLOYED_VAULT = "0xcE64490008587c092ACb0f804491d2b19B482A1D";

async function main() {
  try {
    const VaultV2 = await ethers.getContractFactory("VaultV2");
    console.log("Deploying VaultV2");
    const vaultV2 = await upgrades.upgradeProxy(DEPLOYED_VAULT, VaultV2);

    await vaultV2.waitForDeployment();

    console.log("Static vaultV2 deployed to:", await vaultV2.getAddress());
    console.log("Verifying that the contract was upgraded")
    const OldVaultContract = await ethers.getContractFactory("Vault");
    const oldVault = OldVaultContract.attach(DEPLOYED_VAULT);
    console.log(`Vault name was upgraded to ${await vaultV2.name()} from ${await oldVault.name()}`)

  } catch (error) {
    console.error(error);
  }
  async function mintTokens(token, tokens, receiver) {
    console.log(`Minting ${tokens} tokens to ${receiver}`);

    await token.mint(receiver, tokens);
    console.log(
      `Minted ${await token.balanceOf(receiver)} tokens to ${receiver}`
    );
  }
}

main();
