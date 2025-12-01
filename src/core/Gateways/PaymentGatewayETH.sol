// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;
import "@share/_upgradeContracts.sol";
import "@share/_ccip_Sender.sol";
import "@core/OrdersInWait.sol";
import "@utils/Roles.sol";
import "@utils/Errors.sol";
import "@utils/Events/PaymentETH_Events.sol";
import "@utils/Structs.sol";
import "@interfaces/IOrdersInWait.sol";

contract PaymentGatewayETH is UUPSUpgradeable, OwnableUpgradeable, AccessControlUpgradeable {
    mapping(address userWalletId => uint256 amount) private _balances;
    mapping(address userId => uint256[] orderId) private _orders;
    mapping(uint256 orderId => bytes32 messageId) private _ordersMessage;
    function initialize() public initializer {
        __Ownable_init();
        __AccessControl_init();
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
    }

    function addToPaymentQueue(uint256 orderId, address contractReceiver) public payable returns (bool result) {
        require(msg.value == 1, Invalid_Value());
        _balances[msg.sender] += msg.value;
        _orders[msg.sender].push(orderId);
        emit AddToPaymentQueue_Event(msg.sender, orderId, block.timestamp);
        OrdersStruct memory order = OrdersStruct(orderId, msg.sender, msg.value, false, block.timestamp, 0);

        try IOrdersInWait(contractReceiver).modifyOrderStatus(order) returns (bool ok) {
            if (!ok) {
                IOrdersInWait(contractReceiver).addToOrdersInWaiting(order);
            }
        } catch {
            IOrdersInWait(contractReceiver).addToOrdersInWaiting(order);
        }
        emit SendMessage_Events(order.orderId);
        result = true;
    }

    function withDrawBalance() public returns (bool result) {
        (result, ) = payable(owner()).call{ value: address(this).balance }("");
    }

    receive() external payable {
        emit ETH_Events(msg.sender, msg.value);
    }

    fallback() external payable {}

    function _authorizeUpgrade(address newImplementation) internal override onlyOwner {}
}
