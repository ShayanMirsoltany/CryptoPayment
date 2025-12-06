// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
import "@share/_upgradeContracts.sol";
import "@utils/Events/OrdersInWait_Event.sol";
import "@utils/Structs.sol";
import "@utils/Roles.sol";
import "@interfaces/IOrdersInWait.sol";
import "@openzeppelin/access/AccessControl.sol";
import "@openzeppelin/access/Ownable.sol";
import { CCIPReceiver } from "@ccip-contracts/src/v0.8/ccip/applications/CCIPReceiver.sol";
import { Client } from "@ccip-contracts/src/v0.8/ccip/libraries/Client.sol";
contract OrdersInWait is IOrdersInWait, CCIPReceiver, Ownable, AccessControl {
    constructor(address router) CCIPReceiver(router) {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(ModifierOrderStatus_Role, msg.sender);
    }
    mapping(uint256 orderId => OrdersStruct info) private _ordersInfo;
    event OrderReceived(uint256 orderID);

    function supportsInterface(bytes4 interfaceId) public view virtual override(CCIPReceiver, AccessControl) returns (bool) {
        return super.supportsInterface(interfaceId);
    }
    function setModifierOrderStatusRole(address contractModifier) public onlyOwner {
        _grantRole(ModifierOrderStatus_Role, contractModifier);
    }

    function removeModifierOrderStatusRole(address contractModifier) public onlyOwner {
        _revokeRole(ModifierOrderStatus_Role, contractModifier);
    }

    function _ccipReceive(Client.Any2EVMMessage memory message) internal override {
        emit OrderReceived(123456);
        (uint256 orderId) = abi.decode(message.data, (uint256));
        emit OrderReceived(orderId);

        // (uint256 orderId, uint256 createdDateTime, address userId, uint256 price) = abi.decode(message.data, (uint256, uint256, address, uint256));
        // _ordersInfo[orderId] = OrdersStruct(orderId, userId, price, true, createdDateTime, block.timestamp);
        // emit OrderReceived_Event(message.messageId, orderId, userId);
    }

    function addToOrdersInWaiting(OrdersStruct memory order) external override onlyRole(ModifierOrderStatus_Role) returns (bool result) {
        _ordersInfo[order.orderId] = order;
        emit OrderReceivedETH_Event(order.orderId, order.userId);
        return true;
    }

    function modifyOrderStatus(OrdersStruct memory order) public override onlyRole(ModifierOrderStatus_Role) returns (bool result) {
        order.success = true;
        order.modfiedDateTime = block.timestamp;
        _ordersInfo[order.orderId] = order;
        result = true;
        emit ModifyOrderStatus_Event(order.orderId, order.modfiedDateTime);
    }

    function getOrderInfo(uint256 orderId) public view override returns (bool result) {
        return _ordersInfo[orderId].success;
    }

    // function _authorizeUpgrade(address newImplementation) internal override onlyOwner {}
}
