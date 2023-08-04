const { ethers, upgrades } = require("hardhat");
const constants = require("../utils/index");

const DEPLOYED_VAULT_TOKEN = "0x0372c5F3e23AD56AF9694462300c92632b6ee326";
const DEPLOYED_REWARDS_TOKEN = "0xe6eE5106E269D9a5d8d0E5EF4f78f39c3fcDA7f8";
const DEPLOYED_VAULT = "0xcE64490008587c092ACb0f804491d2b19B482A1D";

async function main() {
  try {
    const Vault = await ethers.getContractFactory("Vault");
    console.log("Deploying Vault");
    const vault = await upgrades.deployProxy(
      Vault,
      [
        [
          DEPLOYED_VAULT_TOKEN,
          DEPLOYED_REWARDS_TOKEN,
          "yVaultToken",
          "yVT",
          false,
          false,
          100,
          30,
        ],
      ],
      {
        initializer: "initialize",
      }
    );
    await vault.waitForDeployment();

    console.log("Static vault deployed to:", await vault.getAddress());
    const RewardsTokenContract = await ethers.getContractFactory("VaultToken");
    const rewardsToken = RewardsTokenContract.attach(DEPLOYED_REWARDS_TOKEN);
    await mintTokens(
      rewardsToken,
      constants.DEFAULT_VAULT_REWARDS_BALANCE,
      await vault.getAddress()
    );
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
