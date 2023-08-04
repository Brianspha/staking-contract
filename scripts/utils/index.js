const { ethers } = require("hardhat");

module.exports ={
    DEFAULT_VAULT_REWARDS_BALANCE:ethers.parseUnits("1000000000000", "ether"),
    DEFAULT_VAULT_TOKEN_BALANCE:ethers.parseUnits("1000000000000", "ether"),
    DEFAULT_ADMIN_TOKEN_BALANCE:ethers.parseUnits("1000000000000", "ether")

}