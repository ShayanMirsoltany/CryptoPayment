// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;
import "@share/_upgradeContracts.sol";
import "@share/_ccip_Sender.sol";
import "@utils/Roles.sol";
import "@utils/Errors.sol";
import "@utils/Events/PaymentPOL_Events.sol";
import "@utils/Structs.sol";
import "@interfaces/IPaymentGateway.sol";
contract PaymentGatewayPOL is IPaymentGateway, UUPSUpgradeable, OwnableUpgradeable, AccessControlUpgradeable {
    mapping(address userWalletId => uint256 amont) private _balances;
    mapping(address userId => uint256 orderId) private _orders;
    mapping(uint256 orderId => bytes32 messageId) private _ordersMessage;
    IRouterClient private router;
    address private linkToken;
    address private _contractReceiver;
    uint64 private _destinationChainSelector;
    function initialize(address _router, address _linkToken) public initializer {
        __Ownable_init();
        __AccessControl_init();
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        router = IRouterClient(_router);
        linkToken = _linkToken;
    }

    function modifyContractReceiver(address receiverContract) public onlyOwner {
        _contractReceiver = receiverContract;
    }

    function modifyDestinationChainSelector(uint64 destinationChainSelector_) public onlyOwner {
        _destinationChainSelector = destinationChainSelector_;
    }

    function addToPaymentQueue(uint256 orderId) public payable returns (bool result) {
        require(msg.value == 1, Invalid_Value());
        require(_contractReceiver != address(0), Invalid_ReceiverContract());
        require(_destinationChainSelector != 0, Invalid_DestinationChainSelector());

        _balances[msg.sender] += msg.value;
        _orders[msg.sender] = orderId;
        emit AddToPaymentQueue_Event(msg.sender, orderId, block.timestamp);
        OrdersStruct memory order = OrdersStruct(orderId, msg.sender, msg.value, false, block.timestamp, 0);
        sendMessage(_destinationChainSelector, _contractReceiver, order);
        result = true;
    }

    function sendMessage(uint64 destinationChainSelector, address contractReceiver, OrdersStruct memory order) private returns (bytes32) {
        Client.EVM2AnyMessage memory message = Client.EVM2AnyMessage({
            receiver: abi.encode(contractReceiver),
            data: abi.encode(order),
            tokenAmounts: new Client.EVMTokenAmount[](0),
            //  tokenAmounts: new Client.EVMTokenAmountClient.EVMTokenAmount({ token: WETH_SEPOLIA, amount: 0.1 ether }),
            extraArgs: Client._argsToBytes(Client.EVMExtraArgsV1({ gasLimit: 50_000 })),
            feeToken: linkToken
        });
        uint256 fee = router.getFee(destinationChainSelector, message);
        require(fee > 0, Invalid_Fee());
        LinkTokenInterface(linkToken).approve(address(router), fee);
        bytes32 messageId = router.ccipSend(destinationChainSelector, message);
        _ordersMessage[order.orderId] = messageId;
        emit SendMessage_Events(order.orderId, messageId);
        return messageId;
    }

    function withDrawBalance() public onlyOwner returns (bool result) {
        (result, ) = payable(owner()).call{ value: address(this).balance }("");
    }

    receive() external payable {
        emit POL_Events(msg.sender, msg.value);
    }

    fallback() external payable {}

    function _authorizeUpgrade(address newImplementation) internal override onlyOwner {}
}
