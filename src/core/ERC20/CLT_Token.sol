// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;
import "@utils/Roles.sol";
import "@share/_upgradeContracts.sol";
import "@openzeppelin-upgradeable/token/ERC20/ERC20Upgradeable.sol";
import "@openzeppelin-upgradeable/token/ERC20/extensions/ERC20CappedUpgradeable.sol";
import "@openzeppelin-upgradeable/token/ERC20/extensions/ERC20PausableUpgradeable.sol";
import "@openzeppelin-upgradeable/token/ERC20/extensions/ERC20BurnableUpgradeable.sol";
import "@openzeppelin-upgradeable/token/ERC20/extensions/ERC20PermitUpgradeable.sol";

contract CLT_Token is
    ERC20Upgradeable,
    ERC20CappedUpgradeable,
    ERC20PausableUpgradeable,
    ERC20BurnableUpgradeable,
    ERC20PermitUpgradeable,
    UUPSUpgradeable,
    OwnableUpgradeable,
    AccessControlUpgradeable
{
    function initialize(string calldata name_, string calldata symbol_, uint256 cap_) public initializer {
        __ERC20_init(name_, symbol_);
        __ERC20Capped_init(cap_);
        __ERC20Pausable_init();
        __ERC20Burnable_init();
        __ERC20Permit_init(name_);
        __Ownable_init();
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(Pauser_Role, msg.sender);
        _grantRole(Burner_Role, msg.sender);
        _grantRole(Minter_Role, msg.sender);
    }

    function burn(uint256 amount) public virtual override onlyRole(Burner_Role) {
        super.burn(amount);
    }

    function burnFrom(address account, uint256 amount) public override onlyRole(Burner_Role) {
        super.burnFrom(account, amount);
    }

    function paused() public view override returns (bool) {
        return super.paused();
    }

    function pause() public onlyRole(Pauser_Role) {
        _pause();
    }

    function unpause() public onlyRole(Pauser_Role) {
        _unpause();
    }

    function setRole(int8 role, address account) public onlyOwner {
        if (role == 1) _grantRole(Pauser_Role, account);
        else if (role == 2) _grantRole(Burner_Role, account);
        else if (role == 3) _grantRole(Minter_Role, account);
        else if (role == 4) _grantRole(CashBack_Role, account);
        else if (role == 5) _grantRole(ModifierOrderStatus_Role, account);
    }

    function mint(address account, uint256 amount) public onlyRole(Minter_Role) {
        super._mint(account, amount);
    }

    function _mint(address account, uint256 amount) internal override(ERC20Upgradeable, ERC20CappedUpgradeable) {
        super._mint(account, amount);
    }

    function _beforeTokenTransfer(address from, address to, uint256 amount) internal override(ERC20Upgradeable, ERC20PausableUpgradeable) {
        super._beforeTokenTransfer(from, to, amount);
    }

    function _authorizeUpgrade(address newImplementation) internal override onlyOwner {}
}
