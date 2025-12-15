// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;
import "@share/_upgradeContracts.sol";
import "@share/_ccip_Sender.sol";
import "@utils/Roles.sol";
import "@utils/Errors.sol";
import "@utils/Events/PaymentCLT_Events.sol";
import "@utils/Structs.sol";
import "@interfaces/IPaymentGateway.sol";
import "@interfaces/IOrdersInWait.sol";
import "@erc20/CLT_Token.sol";

contract PaymentGatewayCLT is IPaymentCLTGateway, UUPSUpgradeable, OwnableUpgradeable, AccessControlUpgradeable {
    mapping(address userWalletId => uint256 amont) private _balances;
    mapping(address userId => uint256[] orderId) private _orders;
    mapping(uint256 orderId => bytes32 messageId) private _ordersMessage;
    IRouterClient private router;
    address private linkToken;
    address private cltToken;
    address private _contractReceiver;
    uint64 private _destinationChainSelector;
    function initialize(address _cltToken) public initializer {
        __Ownable_init();
        __AccessControl_init();
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        cltToken = _cltToken;
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
        require(_destinationChainSelector != 0, Invalid_DestinationChainSelector());
        CLT_Token(cltToken).permit(msg.sender, address(this), amount, deadline, v, r, s);

        require(CLT_Token(cltToken).transferFrom(msg.sender, address(this), amount), "CLT transfer failed");

        _orders[msg.sender].push(orderId);
        OrdersStruct memory order = OrdersStruct(orderId, msg.sender, amount, false, block.timestamp, 0);

        try IOrdersInWait(_contractReceiver).modifyOrderStatus(order) returns (bool ok) {
            if (!ok) {
                IOrdersInWait(_contractReceiver).addToOrdersInWaiting(order);
            }
        } catch {
            IOrdersInWait(_contractReceiver).addToOrdersInWaiting(order);
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
        uint256 balance = CLT_Token(cltToken).balanceOf(address(this));
        result = CLT_Token(cltToken).transfer(owner(), balance);
    }

    receive() external payable {
        emit ETH_Events(msg.sender, msg.value);
    }

    fallback() external payable {}

    function _authorizeUpgrade(address newImplementation) internal override onlyOwner {}
}

// import "forge-std/Test.sol";
// import {CLT_Token} from "../src/CLT_Token.sol";
// import {PaymentGatewayCLT} from "../src/PaymentGatewayCLT.sol";

// contract PaymentGatewayCLT_Test is Test {
//     CLT_Token clt;
//     PaymentGatewayCLT gateway;

//     address USER = address(0x1234);

//     function setUp() public {
//         // Deploy token
//         clt = new CLT_Token();
//         clt.initialize("CLT Token", "CLT", 1_000_000 ether);

//         // Deploy gateway
//         gateway = new PaymentGatewayCLT();
//         gateway.initialize(address(clt));

//         // Give USER some CLT
//         vm.prank(address(this));
//         clt.transfer(USER, 1000 ether);

//         // Receiver mock
//         gateway.modifyContractReceiver(address(0x9999));
//         gateway.modifyDestinationChainSelector(16015286601757825753); // Sepolia
//     }

//     function test_payWithPermit() public {
//         uint256 orderId = 1;
//         uint256 amount = 100 ether;

//         // ---- USER signs permit ----

//         uint256 deadline = block.timestamp + 1 hours;
//         uint256 nonce = clt.nonces(USER);

//         bytes32 digest = getPermitDigest(
//             USER,
//             address(gateway),
//             amount,
//             nonce,
//             deadline
//         );

//         (uint8 v, bytes32 r, bytes32 s) = vm.sign(1, digest);
//         // (۱ = privateKey برای USER)

//         // ---- Call payWithPermit ----
//         vm.prank(USER);
//         bool ok = gateway.payWithPermit(orderId, amount, deadline, v, r, s);
//         assertTrue(ok);

//         // ---- Check results ----
//         assertEq(clt.balanceOf(address(gateway)), amount, "Gateway did not receive CLT");
//         assertEq(clt.balanceOf(USER), 1000 ether - amount, "User CLT not deducted");
//     }

//     // -------------------------------------------------------------------------------------------------
//     // Helper: Create EIP-712 digest for CLT permit()
//     // -------------------------------------------------------------------------------------------------

//     function getPermitDigest(
//         address owner,
//         address spender,
//         uint256 value,
//         uint256 nonce,
//         uint256 deadline
//     ) internal view returns (bytes32) {
//         bytes32 PERMIT_TYPEHASH =
//             keccak256("Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)");

//         bytes32 structHash = keccak256(
//             abi.encode(
//                 PERMIT_TYPEHASH,
//                 owner,
//                 spender,
//                 value,
//                 nonce,
//                 deadline
//             )
//         );

//         return keccak256(
//             abi.encodePacked(
//                 "\x19\x01",
//                 clt.DOMAIN_SEPARATOR(),
//                 structHash
//             )
//         );
//     }
// }
