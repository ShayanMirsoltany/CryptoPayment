// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
import "@utils/Roles.sol";
import "@utils/Errors.sol";
import "@erc20/CLT_Token.sol";
import "@core/Gateways/PaymentGatewayPOL.sol";
import "@core/OrderApprover.sol";

import { Test, console } from "forge-std/Test.sol";
import "@openzeppelin/proxy/ERC1967/ERC1967Proxy.sol";
import { Client } from "@ccip-contracts/src/v0.8/ccip/libraries/Client.sol";

contract RouterMock {
    uint256 public fee = 1 ether;
    bytes32 public lastMessageId;
    address payable private orderApprover;

    function getFee(uint64, Client.EVM2AnyMessage calldata message) external view returns (uint256) {
        return fee;
    }

    function setOrderApprover(address payable _orderApprover) public {
        orderApprover = _orderApprover;
    }

    function ccipSend(uint64, Client.EVM2AnyMessage calldata message) external returns (bytes32) {
        lastMessageId = keccak256("mock-message");
        (uint256 orderId, uint256 createdDateTime, address userId, uint256 price) = abi.decode(message.data, (uint256, uint256, address, uint256));
        OrdersStruct memory order = OrdersStruct(orderId, userId, price, OrderState.WAITING_API, createdDateTime, block.timestamp, false, false, 0);
        OrderApprover(orderApprover).addToOrdersInWaiting(order);
        return lastMessageId;
    }
}

contract LinkTokenMock {
    mapping(address => mapping(address => uint256)) public allowance;

    function approve(address spender, uint256 amount) external returns (bool) {
        allowance[msg.sender][spender] = amount;
        return true;
    }
}

contract PaymentGatewayPOLTest is Test {
    PaymentGatewayPOL polGatewayProxy;
    RouterMock router;
    LinkTokenMock linkToken;
    address tokenProxy;
    OrderApprover orderApprover;
    CLT_Token token;

    address user;
    function setUp() public {
        user = vm.addr(0x111);
        vm.deal(user, 10 ether);

        token = new CLT_Token();
        bytes memory data = abi.encodeCall(token.initialize, ("Chainlinker", "CLT", 100_000_000 ether));
        tokenProxy = address(new ERC1967Proxy(address(token), data));

        orderApprover = new OrderApprover(0x0BF3dE8c5D3e8A2B34D2BEeB17ABfCeBaf363A59, tokenProxy);
        router = new RouterMock();
        router.setOrderApprover(payable(address(orderApprover)));
        orderApprover.setModifierOrderStatusRole(address(router));
        linkToken = new LinkTokenMock();

        PaymentGatewayPOL impl = new PaymentGatewayPOL();
        bytes memory data2 = abi.encodeCall(impl.initialize, (address(router), address(linkToken)));

        polGatewayProxy = PaymentGatewayPOL(payable(address(new ERC1967Proxy(address(impl), data2))));
        polGatewayProxy.modifyDestinationChainSelector(1234);
    }
    function testModifyContractReceiver() public {
        vm.startPrank(address(this));
        address receiverContract = address(orderApprover);
        vm.assertEq(polGatewayProxy.getReceiverContract(), address(0));
        polGatewayProxy.modifyContractReceiver(receiverContract);
        vm.assertEq(polGatewayProxy.getReceiverContract(), receiverContract);
        vm.stopPrank();
    }

    function testValidateSender() public {
        vm.startPrank(address(this));
        address sender = vm.addr(0x555);
        vm.assertEq(orderApprover.checkValidSender(sender), false);
        orderApprover.modifyValidSender(sender, true);
        vm.assertEq(orderApprover.checkValidSender(sender), true);
        vm.stopPrank();
    }

    function testCltBalance() public view {
        vm.assertEq(address(user).balance, 10 ether);
    }

    function testAddToPaymentQueue_Invalid_ReceiverContract() public {
        vm.startPrank(user);
        uint256 orderID = 123456;
        vm.expectRevert(Invalid_ReceiverContract.selector);
        polGatewayProxy.addToPaymentQueue{ value: 1 }(orderID);
        vm.stopPrank();
    }

    function testAddToPaymentQueue_InvalidValue() public {
        vm.startPrank(user);
        uint256 orderID = 123456;
        vm.expectRevert(Invalid_Value.selector);
        polGatewayProxy.addToPaymentQueue(orderID);
        vm.stopPrank();
    }

    function testAddToPaymentQueue_CCIP_Send_Success() public {
        polGatewayProxy.modifyContractReceiver(address(orderApprover));
        uint256 orderId = 123456;

        vm.startPrank(address(this));
        vm.assertEq(orderApprover.getWatingOrdersCount(), 0);
        vm.stopPrank();

        vm.startPrank(user);

        vm.expectEmit(true, false, false, true);
        emit AddToPaymentQueue_Event(user, orderId, block.timestamp);

        vm.expectEmit(false, false, false, true);
        emit SendMessage_Events(orderId, keccak256("mock-message"));

        bool result = polGatewayProxy.addToPaymentQueue{ value: 1 }(orderId);
        vm.stopPrank();

        vm.startPrank(address(this));
        vm.assertEq(orderApprover.getWatingOrdersCount(), 1);
        vm.stopPrank();

        assertTrue(result);
        assertEq(router.lastMessageId(), keccak256("mock-message"));
    }

    function testAddToPaymentQueue_CheckStatus() public {
        polGatewayProxy.modifyContractReceiver(address(orderApprover));
        uint256 orderId = 123456;
        vm.startPrank(user);

        vm.expectEmit(true, false, false, true);
        emit AddToPaymentQueue_Event(user, orderId, block.timestamp);

        vm.expectEmit(false, false, false, true);
        emit SendMessage_Events(orderId, keccak256("mock-message"));

        polGatewayProxy.addToPaymentQueue{ value: 1 }(orderId);
        vm.stopPrank();

        orderApprover.modifyOrderStatus(OrdersStruct(orderId, user, 1, OrderState.WAITING_API, block.timestamp, 0, false, false, 0));
        vm.assertEq(uint256(orderApprover.getOrderInfo(orderId)), uint256(OrderState.WAITING_API));
    }
}
