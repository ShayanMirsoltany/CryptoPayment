// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
import "@utils/Roles.sol";
import "@utils/Errors.sol";
import "@erc20/CLT_Token.sol";
import "@core/Gateways/PaymentGatewayETH.sol";
import "@core/OrderApprover.sol";
import "@utils/Structs.sol";

import { Test, console } from "forge-std/Test.sol";
import "@openzeppelin/proxy/ERC1967/ERC1967Proxy.sol";
contract PaymentGatewayETHTest is Test {
    address tokenProxy;
    address payable ethGatewayProxy;
    OrderApprover orderApprover;
    address _cltToken = 0x9C32fCB86BF0f4a1A8921a9Fe46de3198bb884B2;
    address user1;
    address user2;
    constructor() {
        user1 = vm.addr(0x100);
        user2 = vm.addr(0x200);
    }

    function setUp() public {
        vm.deal(user1, 10 ether);
        vm.deal(user2, 10 ether);
        orderApprover = new OrderApprover(0x0BF3dE8c5D3e8A2B34D2BEeB17ABfCeBaf363A59, _cltToken);
        CLT_Token token = new CLT_Token();
        bytes memory data = abi.encodeCall(token.initialize, ("Chainlinker", "CLT", 100_000_000 ether));
        tokenProxy = address(new ERC1967Proxy(address(token), data));

        PaymentGatewayETH ethGateway = new PaymentGatewayETH();
        bytes memory data2 = abi.encodeCall(ethGateway.initialize, ());
        ethGatewayProxy = payable(address(new ERC1967Proxy(address(ethGateway), data2)));
    }

    function test_modifyContractReceiver() public {
        vm.startPrank(address(this));
        address receiverContract = address(orderApprover);
        vm.assertEq(PaymentGatewayETH(ethGatewayProxy).getReceiverContract(), address(0));
        PaymentGatewayETH(ethGatewayProxy).modifyContractReceiver(receiverContract);
        vm.assertEq(PaymentGatewayETH(ethGatewayProxy).getReceiverContract(), receiverContract);
        vm.stopPrank();
    }

    function test_addToPaymentQueue_Invalid_Value() public {
        vm.startPrank(address(this));
        address receiverContract = address(orderApprover);
        PaymentGatewayETH(ethGatewayProxy).modifyContractReceiver(receiverContract);
        uint256 orderID = 123456;
        vm.expectRevert(Invalid_Value.selector);
        PaymentGatewayETH(ethGatewayProxy).addToPaymentQueue(orderID);
        vm.stopPrank();
    }

    function test_addToPaymentQueue_Invalid_ReceiverContract() public {
        vm.startPrank(address(this));
        uint256 orderID = 123456;
        vm.expectRevert(Invalid_ReceiverContract.selector);
        PaymentGatewayETH(ethGatewayProxy).addToPaymentQueue{ value: 1 wei }(orderID);
        vm.stopPrank();
    }

    function test_addToPaymentQueue_ReceiverCheckRole() public {
        vm.startPrank(address(this));
        address receiverContract = address(orderApprover);
        PaymentGatewayETH(ethGatewayProxy).modifyContractReceiver(receiverContract);

        uint256 orderID = 123456;
        vm.expectRevert();
        PaymentGatewayETH(ethGatewayProxy).addToPaymentQueue{ value: 1 wei }(orderID);
        vm.stopPrank();
    }

    function test_addToPaymentQueue_getBalance() public {
        vm.startPrank(address(this));
        address receiverContract = address(orderApprover);
        PaymentGatewayETH(ethGatewayProxy).modifyContractReceiver(receiverContract);
        orderApprover.setModifierOrderStatusRole(ethGatewayProxy);
        vm.assertEq(PaymentGatewayETH(ethGatewayProxy).getBalance(), 0);
        vm.stopPrank();

        vm.startPrank(user1);
        uint256 orderID = 123456;
        PaymentGatewayETH(ethGatewayProxy).addToPaymentQueue{ value: 1 wei }(orderID);
        vm.assertEq(PaymentGatewayETH(ethGatewayProxy).getUserBalance(), 1);
        vm.stopPrank();

        vm.startPrank(address(this));
        vm.assertEq(PaymentGatewayETH(ethGatewayProxy).getBalance(), 1);
        vm.stopPrank();

        vm.startPrank(user1);
        orderID = 123458;
        PaymentGatewayETH(ethGatewayProxy).addToPaymentQueue{ value: 1 wei }(orderID);
        vm.assertEq(PaymentGatewayETH(ethGatewayProxy).getUserBalance(), 2);
        vm.stopPrank();
    }

    function test_addToPaymentQueue_AddToPaymentQueue_Event() public {
        vm.startPrank(address(this));
        address receiverContract = address(orderApprover);
        PaymentGatewayETH(ethGatewayProxy).modifyContractReceiver(receiverContract);
        orderApprover.setModifierOrderStatusRole(ethGatewayProxy);
        uint256 orderID = 123456;
        uint256 dateTime = block.timestamp;
        vm.expectEmit(true, false, false, true);
        emit AddToPaymentQueue_Event(address(this), orderID, dateTime);
        PaymentGatewayETH(ethGatewayProxy).addToPaymentQueue{ value: 1 wei }(orderID);
        vm.stopPrank();
    }

    function test_addToPaymentQueue_CheckStatus() public {
        vm.startPrank(address(this));
        address receiverContract = address(orderApprover);
        PaymentGatewayETH(ethGatewayProxy).modifyContractReceiver(receiverContract);
        orderApprover.setModifierOrderStatusRole(ethGatewayProxy);

        uint256 orderId = 123456;
        PaymentGatewayETH(ethGatewayProxy).addToPaymentQueue{ value: 1 wei }(orderId);
        // vm.assertEq(orderApprover.getOrderInfo(orderId), OrderState.APPROVED);
        vm.stopPrank();
    }

    function test_withDrawBalance() public {
        vm.startPrank(address(this));
        address receiverContract = address(orderApprover);
        PaymentGatewayETH(ethGatewayProxy).modifyContractReceiver(receiverContract);
        orderApprover.setModifierOrderStatusRole(ethGatewayProxy);
        vm.stopPrank();
        uint256 currentBalance = address(this).balance;

        vm.startPrank(user1);
        uint256 orderId = 123456;
        PaymentGatewayETH(ethGatewayProxy).addToPaymentQueue{ value: 1 wei }(orderId);
        vm.stopPrank();

        vm.startPrank(address(this));
        vm.assertEq(PaymentGatewayETH(ethGatewayProxy).owner(), address(this));
        vm.assertEq(PaymentGatewayETH(ethGatewayProxy).getBalance(), 1);
        bool result = PaymentGatewayETH(ethGatewayProxy).withDrawBalance();
        vm.assertTrue(result);
        vm.assertEq(address(this).balance, currentBalance + 1);
        vm.stopPrank();
    }

    receive() external payable {}
}
