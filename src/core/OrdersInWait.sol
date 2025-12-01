// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
import "@share/_upgradeContracts.sol";
import "@core/Gateways/CCIPReceiverUpgradeable.sol";
import "@utils/Events/OrdersInWait_Event.sol";
import "@utils/Structs.sol";
import "@interfaces/IOrdersInWait.sol";

contract OrdersInWait is IOrdersInWait, CCIPReceiverUpgradeable, UUPSUpgradeable, OwnableUpgradeable, AccessControlUpgradeable {
    function initialize(address route) public initializer {
        __Ownable_init();
        __AccessControl_init();
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        __CCIPReceiver_init(route);
    }

    mapping(uint256 orderId => OrdersStruct info) private _ordersInfo;

    function _ccipReceive(Client.Any2EVMMessage memory message) internal override {
        OrdersStruct memory order = abi.decode(message.data, (OrdersStruct));
        _ordersInfo[order.orderId] = order;
        emit OrderReceived_Event(message.messageId, order.orderId, order.userId);
    }

    function addToOrdersInWaiting(OrdersStruct memory order) external override returns (bool result) {
        _ordersInfo[order.orderId] = order;
        emit OrderReceivedETH_Event(order.orderId, order.userId);
        return true;
    }

    function getOrderInfo(uint256 orderId) public view override returns (bool result) {
        return _ordersInfo[orderId].success;
    }

    function modifyOrderStatus(OrdersStruct memory order) public override returns (bool result) {
        order.success = true;
        order.modfiedDateTime = block.timestamp;
        _ordersInfo[order.orderId] = order;
        result = true;
        emit ModifyOrderStatus_Event(order.orderId, order.modfiedDateTime);
    }

    function _authorizeUpgrade(address newImplementation) internal override onlyOwner {}
}
