//SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
import "@utils/Roles.sol";
import "@utils/Errors.sol";
import "@erc20/CLT_Token.sol";
import "@core/Gateways/PaymentGatewayCLT.sol";
import "@core/OrderApprover.sol";
import "@openzeppelin/utils/Strings.sol";
import { Test, console } from "forge-std/Test.sol";
import "@openzeppelin/proxy/ERC1967/ERC1967Proxy.sol";
contract PaymentGatewayCLTTest is Test {
    address tokenProxy;
    address payable cltGatewayProxy;
    OrderApprover orderApprover;
    address user1;
    uint256 user1PK;
    address user2;
    CLT_Token token;
    constructor() {
        user1PK = 0x100;
        user1 = vm.addr(user1PK);
        user2 = vm.addr(0x200);
    }

    function setUp() public {
        vm.deal(user1, 10 ether);
        vm.deal(user2, 10 ether);
        token = new CLT_Token();
        bytes memory data = abi.encodeCall(token.initialize, ("Chainlinker", "CLT", 100_000_000 ether));
        tokenProxy = address(new ERC1967Proxy(address(token), data));

        PaymentGatewayCLT cltgateway = new PaymentGatewayCLT();
        bytes memory data2 = abi.encodeCall(cltgateway.initialize, (tokenProxy));
        cltGatewayProxy = payable(address(new ERC1967Proxy(address(cltgateway), data2)));
        orderApprover = new OrderApprover(0x0BF3dE8c5D3e8A2B34D2BEeB17ABfCeBaf363A59, tokenProxy);
        CLT_Token(tokenProxy).grantRole(Minter_Role, address(orderApprover));
    }

    function testCltBalance() public {
        vm.startPrank(address(this));
        CLT_Token(tokenProxy).mint(user1, 10000);
        vm.stopPrank();

        vm.startPrank(user1);
        vm.assertEq(CLT_Token(tokenProxy).balanceOf(user1), 10000);
        vm.stopPrank();
    }

    function testModifyContractReceiver() public {
        vm.startPrank(address(this));
        address receiverContract = address(orderApprover);
        vm.assertEq(PaymentGatewayCLT(cltGatewayProxy).getReceiverContract(), address(0));
        PaymentGatewayCLT(cltGatewayProxy).modifyContractReceiver(receiverContract);
        vm.assertEq(PaymentGatewayCLT(cltGatewayProxy).getReceiverContract(), receiverContract);
        vm.stopPrank();
    }

    function testAddToPaymentQueue_Invalid_ReceiverContract() public {
        vm.startPrank(user1);
        uint256 orderID = 123456;
        vm.expectRevert(Invalid_ReceiverContract.selector);
        PaymentGatewayCLT(cltGatewayProxy).payWithPermit(orderID, 1, 1, 1, keccak256("test"), keccak256("test"));
        vm.stopPrank();
    }

    function testAddToPaymentQueueInvalidValue() public {
        vm.startPrank(address(this));
        address receiverContract = address(orderApprover);
        PaymentGatewayCLT(cltGatewayProxy).modifyContractReceiver(receiverContract);
        vm.stopPrank();

        vm.startPrank(user1);
        uint256 orderID = 123456;
        vm.expectRevert(Invalid_Value.selector);
        PaymentGatewayCLT(cltGatewayProxy).payWithPermit(orderID, 1, 1, 1, bytes32("test"), bytes32("test"));
        vm.stopPrank();
    }

    function testPayWithPermitCheckBalance() public {
        vm.startPrank(address(this));
        address receiverContract = address(orderApprover);
        PaymentGatewayCLT(cltGatewayProxy).modifyContractReceiver(receiverContract);
        orderApprover.setModifierOrderStatusRole(cltGatewayProxy);
        CLT_Token(tokenProxy).mint(user1, 10000);

        uint256 orderId = 123456;
        uint256 amount = 100 wei;
        uint256 deadline = block.timestamp + 1 hours;
        uint256 nonce = CLT_Token(tokenProxy).nonces(user1);

        bytes32 digest = getPermitDigest(user1, cltGatewayProxy, amount, nonce, deadline);
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(user1PK, digest);

        vm.stopPrank();
        vm.startPrank(user1);
        bool ok = PaymentGatewayCLT(cltGatewayProxy).payWithPermit(orderId, amount, deadline, v, r, s);
        vm.stopPrank();
        assertTrue(ok);

        uint256 cashBackAmount = (amount * 10) / 100;
        assertEq(CLT_Token(tokenProxy).balanceOf(cltGatewayProxy), amount, "Gateway did not receive CLT");
        assertEq(CLT_Token(tokenProxy).balanceOf(user1), 10000 - amount + cashBackAmount, "User CLT not deducted");
    }

    function testPayWithPermit_AddToPaymentQueue_Event() public {
        vm.startPrank(address(this));
        address receiverContract = address(orderApprover);
        PaymentGatewayCLT(cltGatewayProxy).modifyContractReceiver(receiverContract);
        orderApprover.setModifierOrderStatusRole(cltGatewayProxy);
        CLT_Token(tokenProxy).mint(user1, 10000);

        uint256 orderId = 123456;
        uint256 amount = 100 wei;
        uint256 deadline = block.timestamp + 1 hours;
        uint256 nonce = CLT_Token(tokenProxy).nonces(user1);
        bytes32 digest = getPermitDigest(user1, cltGatewayProxy, amount, nonce, deadline);
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(user1PK, digest);
        vm.stopPrank();

        vm.startPrank(user1);
        vm.expectEmit(true, false, false, true);
        emit AddToPaymentQueue_Event(user1, orderId, block.timestamp);
        PaymentGatewayCLT(cltGatewayProxy).payWithPermit(orderId, amount, deadline, v, r, s);
        vm.stopPrank();
    }

    function testPayWithPermit_ReceiverCheckRole() public {
        vm.startPrank(address(this));
        address receiverContract = address(orderApprover);
        PaymentGatewayCLT(cltGatewayProxy).modifyContractReceiver(receiverContract);
        CLT_Token(tokenProxy).mint(user1, 10000);

        uint256 orderId = 123456;
        uint256 amount = 100 wei;
        uint256 deadline = block.timestamp + 1 hours;
        uint256 nonce = CLT_Token(tokenProxy).nonces(user1);
        bytes32 digest = getPermitDigest(user1, cltGatewayProxy, amount, nonce, deadline);
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(user1PK, digest);

        vm.stopPrank();
        vm.startPrank(user1);
        vm.expectRevert();
        PaymentGatewayCLT(cltGatewayProxy).payWithPermit(orderId, amount, deadline, v, r, s);
        vm.stopPrank();
    }

    function testPayWithPermit_RevertInvalidBalance() public {
        vm.startPrank(address(this));
        address receiverContract = address(orderApprover);
        PaymentGatewayCLT(cltGatewayProxy).modifyContractReceiver(receiverContract);
        CLT_Token(tokenProxy).mint(user1, 10);

        uint256 orderId = 123456;
        uint256 amount = 100 wei;
        uint256 deadline = block.timestamp + 1 hours;
        uint256 nonce = CLT_Token(tokenProxy).nonces(user1);
        bytes32 digest = getPermitDigest(user1, cltGatewayProxy, amount, nonce, deadline);
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(user1PK, digest);

        vm.stopPrank();
        vm.startPrank(user1);
        vm.expectRevert(Invalid_Balance.selector);
        PaymentGatewayCLT(cltGatewayProxy).payWithPermit(orderId, amount, deadline, v, r, s);
        vm.stopPrank();
    }

    function testPayWithPermit_CheckStatus() public {
        vm.startPrank(address(this));
        address receiverContract = address(orderApprover);
        PaymentGatewayCLT(cltGatewayProxy).modifyContractReceiver(receiverContract);
        orderApprover.setModifierOrderStatusRole(cltGatewayProxy);
        CLT_Token(tokenProxy).mint(user1, 10000);

        uint256 orderId = 123456;
        uint256 amount = 100 wei;
        uint256 deadline = block.timestamp + 1 hours;
        uint256 nonce = CLT_Token(tokenProxy).nonces(user1);
        bytes32 digest = getPermitDigest(user1, cltGatewayProxy, amount, nonce, deadline);
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(user1PK, digest);
        vm.stopPrank();

        vm.startPrank(user1);
        PaymentGatewayCLT(cltGatewayProxy).payWithPermit(orderId, amount, deadline, v, r, s);
        vm.assertEq(uint256(orderApprover.getOrderInfo(orderId)), uint256(OrderState.WAITING_API));
        vm.stopPrank();
    }

    function testWithDrawBalance() public {
        vm.startPrank(address(this));
        address receiverContract = address(orderApprover);
        PaymentGatewayCLT(cltGatewayProxy).modifyContractReceiver(receiverContract);
        orderApprover.setModifierOrderStatusRole(cltGatewayProxy);
        CLT_Token(tokenProxy).mint(user1, 10000);

        uint256 orderId = 123456;
        uint256 amount = 100 wei;
        uint256 deadline = block.timestamp + 1 hours;
        uint256 nonce = CLT_Token(tokenProxy).nonces(user1);
        bytes32 digest = getPermitDigest(user1, cltGatewayProxy, amount, nonce, deadline);
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(user1PK, digest);
        vm.stopPrank();

        vm.startPrank(user1);
        PaymentGatewayCLT(cltGatewayProxy).payWithPermit(orderId, amount, deadline, v, r, s);
        vm.stopPrank();

        vm.startPrank(address(this));
        vm.assertEq(PaymentGatewayCLT(cltGatewayProxy).owner(), address(this));
        vm.assertEq(CLT_Token(tokenProxy).balanceOf(cltGatewayProxy), 100);
        bool result = PaymentGatewayCLT(cltGatewayProxy).withDrawBalance();
        vm.assertTrue(result);
        vm.assertEq(CLT_Token(tokenProxy).balanceOf(address(this)), 100);
        vm.stopPrank();
    }

    function testCashBack() public {
        vm.startPrank(address(this));
        address receiverContract = address(orderApprover);
        PaymentGatewayCLT(cltGatewayProxy).modifyContractReceiver(receiverContract);
        orderApprover.setModifierOrderStatusRole(cltGatewayProxy);
        CLT_Token(tokenProxy).mint(user1, 10000);

        uint256 orderId = 123456;
        uint256 amount = 100 wei;
        uint256 deadline = block.timestamp + 1 hours;
        uint256 nonce = CLT_Token(tokenProxy).nonces(user1);
        bytes32 digest = getPermitDigest(user1, cltGatewayProxy, amount, nonce, deadline);
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(user1PK, digest);
        vm.stopPrank();

        vm.startPrank(user1);
        uint256 cashBackAmount = (amount * 10) / 100;
        vm.expectEmit(true, false, false, true);
        emit CashBackEvent(user1, orderId, amount, cashBackAmount, block.timestamp);
        PaymentGatewayCLT(cltGatewayProxy).payWithPermit(orderId, amount, deadline, v, r, s);

        vm.assertEq(CLT_Token(tokenProxy).balanceOf(user1), 10000 - amount + cashBackAmount);
        vm.stopPrank();
    }

    function getPermitDigest(address owner, address spender, uint256 value, uint256 nonce, uint256 deadline) internal view returns (bytes32) {
        bytes32 PERMIT_TYPEHASH = keccak256("Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)");
        bytes32 structHash = keccak256(abi.encode(PERMIT_TYPEHASH, owner, spender, value, nonce, deadline));
        return keccak256(abi.encodePacked("\x19\x01", CLT_Token(tokenProxy).DOMAIN_SEPARATOR(), structHash));
    }

    function testAutomationTriggersApiRequest() public {
        uint256 orderId = 123;

        // فرض: سفارش قبلاً از CCIP یا Gateway آمده
        OrdersStruct memory order = OrdersStruct({
            orderId: orderId,
            userId: user1,
            price: 100,
            state: OrderState.WAITING_API,
            createdDateTime: block.timestamp,
            modfiedDateTime: 0,
            nativeToken: false,
            isApproved: false,
            approvedDateTime: 0
        });

        vm.startPrank(address(this));
        vm.assertEq(orderApprover.getWatingOrdersCount(), 0);
        orderApprover.addToOrdersInWaiting(order);
        vm.assertEq(orderApprover.getWatingOrdersCount(), 1);
        vm.stopPrank();

        // وقتی Automation اجرا می‌شود
        orderApprover.performUpkeep(abi.encode(orderId));

        // فقط state باید عوض شود
        assertEq(uint(orderApprover.getOrderInfo(orderId)), uint(OrderState.API_REQUESTED));
    }

    function testOracleFulfillmentApprove() public {
        uint256 orderId = 123;
        bytes32 fakeRequestId = keccak256("fake-request");

        orderApprover.approveOrder_Fake(fakeRequestId, orderId);
        orderApprover.fillOrderInfo_Fake(fakeRequestId, true);

        assertEq(uint(orderApprover.getOrderInfo(orderId)), uint(OrderState.APPROVED));
    }
}
