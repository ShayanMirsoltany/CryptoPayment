// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
import "@utils/Roles.sol";
import "@utils/Errors.sol";
import "@erc20/CLT_Token.sol";
import "@core/Gateways/PaymentGatewayPOL.sol";
import "@core/OrdersInWait.sol";

import { Test, console } from "forge-std/Test.sol";
import "@openzeppelin/proxy/ERC1967/ERC1967Proxy.sol";

contract RouterMock {
    uint256 public fee = 1 ether;
    bytes32 public lastMessageId;

    function getFee(uint64, Client.EVM2AnyMessage calldata) external view returns (uint256) {
        return fee;
    }

    function ccipSend(uint64, Client.EVM2AnyMessage calldata) external returns (bytes32) {
        lastMessageId = keccak256("mock-message");
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
    OrdersInWait ordersInWait;
    CLT_Token token;

    address user;

    function setUp() public {
        user = vm.addr(0x111);
        vm.deal(user, 10 ether);

        token = new CLT_Token();
        bytes memory data = abi.encodeCall(token.initialize, ("Chainlinker", "CLT", 100_000_000 ether));
        tokenProxy = address(new ERC1967Proxy(address(token), data));

        ordersInWait = new OrdersInWait(0x0BF3dE8c5D3e8A2B34D2BEeB17ABfCeBaf363A59, tokenProxy);
        router = new RouterMock();
        linkToken = new LinkTokenMock();

        PaymentGatewayPOL impl = new PaymentGatewayPOL();
        bytes memory data2 = abi.encodeCall(impl.initialize, (address(router), address(linkToken)));

        polGatewayProxy = PaymentGatewayPOL(payable(address(new ERC1967Proxy(address(impl), data2))));
        polGatewayProxy.modifyDestinationChainSelector(1234);
    }

    function testModifyContractReceiver() public {
        vm.startPrank(address(this));
        address receiverContract = address(ordersInWait);
        vm.assertEq(polGatewayProxy.getReceiverContract(), address(0));
        polGatewayProxy.modifyContractReceiver(receiverContract);
        vm.assertEq(polGatewayProxy.getReceiverContract(), receiverContract);
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
}
