// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
import "@share/_upgradeContracts.sol";
import "@core/Gateways/CCIPReceiverUpgradeable.sol";
import "@utils/Events/OrdersInWait_Event.sol";
import "@utils/Structs.sol";

contract OrdersInWait is CCIPReceiverUpgradeable, UUPSUpgradeable, OwnableUpgradeable, AccessControlUpgradeable {
    function initialize(address route) public initializer {
        __Ownable_init();
        __AccessControl_init();
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        __CCIPReceiver_init(route);
    }

    uint256[] private orders;
    mapping(uint256 orderId => OrdersStruct info) private orderInfo;

    function _ccipReceive(Client.Any2EVMMessage memory message) internal override {
        OrdersStruct memory order = abi.decode(message.data, (OrdersStruct));
        orders.push(order.orderId);
        orderInfo[order.orderId] = order;
        emit OrderReceived_Event(message.messageId, order.orderId, order.userId);
    }

    function addToOrdersInWaiting(OrdersStruct memory order) external {
        orders.push(order.orderId);
        orderInfo[order.orderId] = order;
        emit OrderReceivedETH_Event(order.orderId, order.userId);
    }

    function getOrderInfo(uint256 orderId) public view returns (bool result) {
        return orderInfo[orderId].success;
    }

    function modifyOrderStatus(uint256 orderId) public returns (bool result) {
        OrdersStruct storage o = orderInfo[orderId];
        o.success = true;
        o.modfiedDateTime = block.timestamp;
        return true;
    }

    function _authorizeUpgrade(address newImplementation) internal override onlyOwner {}
}
