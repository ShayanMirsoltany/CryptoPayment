// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;
import "@share/_upgradeContracts.sol";
import "@share/_ccip_Sender.sol";
import "@utils/Roles.sol";
import "@utils/Errors.sol";
import "@utils/Events/PaymentCLT_Events.sol";
import "@utils/Structs.sol";
import "@interfaces/IPaymentGateway.sol";
import "@interfaces/IOrderApprover.sol";
import "@erc20/CLT_Token.sol";

contract PaymentGatewayCLK is IPaymentCLTGateway, UUPSUpgradeable, OwnableUpgradeable, AccessControlUpgradeable {
    mapping(address userWalletId => uint256 amont) private _balances;
    mapping(address userId => uint256[] orderId) private _orders;
    mapping(uint256 orderId => bytes32 messageId) private _ordersMessage;

    IRouterClient private _router;
    address private _linkToken;
    address private _cltToken;
    address private _contractReceiver;
    uint64 private _destinationChainSelector;
    function initialize(address cltToken_) public initializer {
        __Ownable_init();
        __AccessControl_init();
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _cltToken = cltToken_;
    }

    function getReceiverContract() external view returns (address) {
        return _contractReceiver;
    }

    function modifyContractReceiver(address receiverContract) external onlyOwner {
        _contractReceiver = receiverContract;
    }

    function modifyDestinationChainSelector(uint64 destinationChainSelector_) external onlyOwner {
        _destinationChainSelector = destinationChainSelector_;
    }

    function payWithPermit(uint256 orderId, uint256 amount, uint256 deadline, uint8 v, bytes32 r, bytes32 s) external returns (bool result) {
        require(_contractReceiver != address(0), Invalid_ReceiverContract());
        require(amount == 100, Invalid_Value());
        require(CLT_Token(_cltToken).balanceOf(msg.sender) >= amount, Invalid_Balance());
        CLT_Token(_cltToken).permit(msg.sender, address(this), amount, deadline, v, r, s);

        require(CLT_Token(_cltToken).transferFrom(msg.sender, address(this), amount), "CLT transfer failed");

        _orders[msg.sender].push(orderId);
        OrdersStruct memory order = OrdersStruct(orderId, msg.sender, amount, OrderState.WAITING_API, block.timestamp, 0, true, false, 0);

        try IOrderApprover(_contractReceiver).modifyOrderStatus(order) returns (bool ok) {
            if (!ok) {
                IOrderApprover(_contractReceiver).addToOrdersInWaiting(order);
            }
        } catch {
            IOrderApprover(_contractReceiver).addToOrdersInWaiting(order);
        }
        emit AddToPaymentQueue_Event(msg.sender, orderId, block.timestamp);
        result = true;
    }

    function getUserBalance() public view returns (uint256 result) {
        return _balances[msg.sender];
    }

    function getBalance() public view onlyOwner returns (uint256 result) {
        return address(this).balance;
    }

    function withDrawBalance() external onlyOwner returns (bool result) {
        uint256 balance = CLT_Token(_cltToken).balanceOf(address(this));
        result = CLT_Token(_cltToken).transfer(owner(), balance);
    }

    receive() external payable {
        emit ETH_Events(msg.sender, msg.value);
    }

    fallback() external payable {}

    function _authorizeUpgrade(address newImplementation) internal override onlyOwner {}
}
