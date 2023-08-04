# Staking Contract

This repo contains files used required for the creation of a tokenised vault **Please dont use these in any Production env as they are solely for learning purposes**

# Rationale

Im going to focus on the unit testing aspect of the project i had decided to introduce folders within the unit testing directory

1. Unit
2. Integration
3. Invariant
4. Fork

This was inspired by a talk i watched during ETHCC these folders allow for separation of strategies of how we can test the contracts developed and each test the contract in different ways.
Note: Since we developing a Tokenized vault which requires another contract i have put the tests under Unit
For setting up Testing i decided to use Inheritance reason being we want to setup base logic for all tests such that all other test can use the logic instead of duplicating by defining it in their own contracts.

Before creating a unit test we first defined a non-technical tree which follows the Branching Tree Technique (BTT) file that defines how we want to to the contract functions by defining possible execution paths you can find an example of such a tree file under the unit test folder

Before reading the unit tests one can easily get an idea of what we testing for within the contract

To ling the tree file to the actual unit test we used modifiers to translate the english to solidity.

## Project setup

To setup the project please ensure you have installed

1. Node Version Manager (https://github.com/nvm-sh/nvm)
2. node with npm (using NVM)
3. Foundry (https://book.getfoundry.sh/getting-started/installation)
4. Hardhat (https://hardhat.org/hardhat-runner/docs/getting-started#installation)

### Package installation

`yarn` or `npm i`

For the foundry contract theres no need to install again since the repo will included in the lib/ folder but if you wish to install other dependencies please see here:
https://book.getfoundry.sh/projects/dependencies

### Building

To build the contracts please run
`forge build`

### Testing

There are several folders within the testing folder we just focused on concreting testing other types of testing like fuzz and integration are not included

To test the contracts please run
`forge test`

### Deploying

For deployment we have employed the Universal Upgradeable Proxy Standard (UUPS) standard by hardhat and openzepplin (https://docs.openzeppelin.com/upgrades-plugins/1.x/api-hardhat-upgrades)

There are scripts that aid in the deployment of the Vault and Token one for local host running on port 8546 and one for deploy to mumbai testnet

All deployment scripts denoted with **::local** refer to local deployment
All deployment scripts denoted with **::polygon** refer to Polygon testnet deployment

### Deployed Contracts

1. Vault Token: https://mumbai.polygonscan.com/address/0x4b3486f7b072748185BDc9F512b9d9D9bdABc139
2. Rewards Token: https://mumbai.polygonscan.com/address/0x8bbb490a6fb95939c5348f0d97d993269f657cfc
3. Static Vault: https://mumbai.polygonscan.com/address/0x66a0a007c49428Bd0C217598fa60b508a3F10795
