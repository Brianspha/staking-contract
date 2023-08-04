const { ethers, upgrades } = require("hardhat");

async function main() {
  try {
    const VaultToken = await ethers.getContractFactory("VaultToken");
    console.log("Deploying Vault Token");
    const vaultToken = await upgrades.deployProxy(
      VaultToken,
      ["VaultToken", "VT"],
      {
        initializer: "initialize",
      }
    );
    await vaultToken.waitForDeployment();

    console.log("Vault Token deployed to:", await vaultToken.getAddress());

    console.log("Minting  10000000000000 tokens to admin");
    const tokens = ethers.parseUnits("10000000000000", "ether");
    await vaultToken.mint("0x5aF828D07f4e403522F2E88eC544E1F7D559E29d", tokens);
    console.log(
      `Minted ${await vaultToken.balanceOf(
        "0x5aF828D07f4e403522F2E88eC544E1F7D559E29d"
      )} Vault tokens to admin`
    );
  } catch (error) {
    console.error(error.toString());
  }
}

main();
