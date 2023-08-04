// SPDX-License-Identifier: MIT License
pragma solidity >=0.8.0;
import "../../lib/openzeppelin-contracts-upgradeable/contracts/security/PausableUpgradeable.sol";
import "../../lib/openzeppelin-contracts-upgradeable/contracts/access/OwnableUpgradeable.sol";
import "../../lib/openzeppelin-contracts-upgradeable/contracts/token/ERC20/ERC20Upgradeable.sol";

contract VaultToken is
    ERC20Upgradeable,
    PausableUpgradeable,
    OwnableUpgradeable
{
    function initialize(
        string memory symbol,
        string memory name
    ) public virtual initializer {
        __ERC20_init(name, symbol);
        __Ownable_init();
        __Pausable_init();
    }

    function burn(uint256 amount) public onlyOwner {
        _burn(address(0), amount);
    }

    function transfer(
        address to,
        uint256 amount
    ) public virtual override whenNotPaused returns (bool) {
        address owner = _msgSender();
        _transfer(owner, to, amount);
        return true;
    }

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public virtual override whenNotPaused returns (bool) {
        address spender = _msgSender();
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
        return true;
    }

    function increaseAllowance(
        address spender,
        uint256 addedValue
    ) public virtual override whenNotPaused returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, allowance(owner, spender) + addedValue);
        return true;
    }

    function approve(
        address spender,
        uint256 amount
    ) public virtual override whenNotPaused returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, amount);
        return true;
    }

    function pause() public onlyOwner {
        _pause();
    }

    function unPause() public onlyOwner {
        _unpause();
    }

    function mint(
        address to,
        uint256 amount
    ) public virtual whenNotPaused onlyOwner {
        _mint(to, amount);
    }
}
