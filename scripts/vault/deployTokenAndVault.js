const { ethers, upgrades } = require("hardhat");
const constants = require("../utils/index");
require("dotenv").config();
async function main() {
  try {
    const vaultToken = await deployToken(
      "VaultToken",
      "VT",
      constants.DEFAULT_VAULT_TOKEN_BALANCE,
      process.env.ADMIN
    );
    const rewardsToken = await deployToken(
      "yVaultToken",
      "yVT",
      constants.DEFAULT_VAULT_REWARDS_BALANCE,
      process.env.ADMIN
    );
    const Vault = await ethers.getContractFactory("Vault");
    console.log("Deploying Vault");
    const vault = await upgrades.deployProxy(
      Vault,
      [
        [
          await vaultToken.getAddress(),
          await rewardsToken.getAddress(),
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

    await mintTokens(
      rewardsToken,
      constants.DEFAULT_VAULT_REWARDS_BALANCE,
      await vault.getAddress()
    );
  } catch (error) {
    console.error(error);
  }

  async function deployToken(name, symbol, supply, receiver) {
    const VaultToken = await ethers.getContractFactory("VaultToken");

    console.log(`Deploying Token with name ${name} and symbol ${symbol}`);

    const vaultToken = await upgrades.deployProxy(VaultToken, [name, symbol], {
      initializer: "initialize",
    });

    await vaultToken.waitForDeployment();

    console.log("Token deployed to:", await vaultToken.getAddress());

    const tokens = ethers.parseUnits(supply.toString(), "ether");
    await mintTokens(vaultToken, tokens, receiver);

    return vaultToken;
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
