// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
import "@share/_upgradeContracts.sol";
import "@utils/Events/OrdersInWait_Event.sol";
import "@utils/Structs.sol";
import "@utils/Roles.sol";
import "@erc20/CLT_Token.sol";
import "@interfaces/IOrderApprover.sol";
import "@openzeppelin/access/AccessControl.sol";
import "@openzeppelin/access/Ownable.sol";
import { CCIPReceiver } from "@ccip-contracts/src/v0.8/ccip/applications/CCIPReceiver.sol";
import { Client } from "@ccip-contracts/src/v0.8/ccip/libraries/Client.sol";
import "@share/_anyAPIContracts.sol";
import "@openzeppelin/token/ERC20/IERC20.sol";
import "@openzeppelin/utils/Strings.sol";

contract OrderApprover is IOrderApprover, AccessControl, ChainlinkClient, ConfirmedOwner, CCIPReceiver {
    using Chainlink for Chainlink.Request;
    using Strings for *;
    uint256 private fee;
    bytes32 private jobId_uint256;
    bytes32 private jobId_int256;
    bytes32 public jobId_string;
    bytes32 public jobId_bytes;
    bytes32 public jobId_bool;
    uint256[] waitingOrderIds;
    address private _token;

    constructor(address router, address token) CCIPReceiver(router) ConfirmedOwner(msg.sender) {
        jobId_uint256 = "ca98366cc7314957b8c012c72f05aeeb";
        jobId_int256 = "fcf4140d696d44b687012232948bdd5d";
        jobId_string = "7d80a6386ef543a3abb52817f6707e3b";
        jobId_bytes = "7da2702f37fd48e5b1b9a5715e3509b6";
        jobId_bool = "c1c5e92880894eb6b27d3cae19670aa3";
        fee = (1 * LINK_DIVISIBILITY) / 10;
        _setChainlinkToken(0x779877A7B0D9E8603169DdbD7836e478b4624789);
        _setChainlinkOracle(0x6090149792dAAeE9D1D568c9f9a6F6B46AA29eFD);

        _token = token;
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(ModifierOrderStatus_Role, msg.sender);
    }

    mapping(uint256 orderId => OrdersStruct info) private _ordersInfo;

    event OrderReceived(uint256 orderID);

    mapping(bytes32 requestId => uint256 orderId) private _requests;

    function supportsInterface(bytes4 interfaceId) public view virtual override(AccessControl, CCIPReceiver) returns (bool) {
        return super.supportsInterface(interfaceId);
    }

    function setModifierOrderStatusRole(address contractModifier) public onlyOwner {
        _grantRole(ModifierOrderStatus_Role, contractModifier);
    }

    function removeModifierOrderStatusRole(address contractModifier) public onlyOwner {
        _revokeRole(ModifierOrderStatus_Role, contractModifier);
    }

    function _validateSender(Client.Any2EVMMessage memory message) internal pure {
        address amoy = 0x9C32fCB86BF0f4a1A8921a9Fe46de3198bb884B2;
        require(abi.decode(message.sender, (address)) == amoy, "INVALID_CCIP_SENDER");
    }

    function _ccipReceive(Client.Any2EVMMessage memory message) internal override {
        _validateSender(message); // ⬅️ واجب

        (uint256 orderId, uint256 createdDateTime, address userId, uint256 price, bool nativeToken) = abi.decode(
            message.data,
            (uint256, uint256, address, uint256, bool)
        );
        _ordersInfo[orderId] = OrdersStruct(orderId, userId, price, OrderState.WAITING_API, createdDateTime, block.timestamp, nativeToken, false, 0);
        waitingOrderIds.push(orderId);
        emit OrderReceived_Event(message.messageId, orderId, userId);
    }

    function getWatingOrdersCount() public view onlyOwner returns (uint256) {
        return waitingOrderIds.length;
    }

    function addToOrdersInWaiting(OrdersStruct memory order) external override onlyRole(ModifierOrderStatus_Role) returns (bool result) {
        order.state = OrderState.WAITING_API;
        _ordersInfo[order.orderId] = order;
        waitingOrderIds.push(order.orderId);
        emit OrderReceivedETH_Event(order.orderId, order.userId);
        return true;
    }

    function CalcCashBack(uint256 orderId, address receiver, uint256 amount) internal {
        uint256 cashBackAmount = (amount * 10) / 100;
        CLT_Token(_token).mint(receiver, cashBackAmount);
        emit CashBackEvent(receiver, orderId, amount, cashBackAmount, block.timestamp);
    }

    function modifyOrderStatus(OrdersStruct memory order) public override onlyRole(ModifierOrderStatus_Role) returns (bool result) {
        order.state = OrderState.WAITING_API;
        order.modfiedDateTime = block.timestamp;
        _ordersInfo[order.orderId] = order;
        waitingOrderIds.push(order.orderId);

        result = true;
        if (order.nativeToken && !CLT_Token(_token).paused()) {
            CalcCashBack(order.orderId, order.userId, order.price);
        }
    }

    function getOrderInfo(uint256 orderId) public view override returns (OrderState result) {
        result = _ordersInfo[orderId].state;
    }

    //#region automation

    function _findWaitingOrder() internal view returns (uint256) {
        for (uint256 i = 0; i < waitingOrderIds.length; i++) {
            uint256 orderId = waitingOrderIds[i];
            if (_ordersInfo[orderId].state == OrderState.WAITING_API) {
                return orderId;
            }
        }
        return 0;
    }

    function checkUpkeep(bytes calldata) external view returns (bool upkeepNeeded, bytes memory performData) {
        uint256 orderId = _findWaitingOrder();
        if (orderId != 0) {
            upkeepNeeded = true;
            performData = abi.encode(orderId);
        }
    }

    function performUpkeep(bytes calldata data) external {
        uint256 orderId = abi.decode(data, (uint256));
        require(_ordersInfo[orderId].state == OrderState.WAITING_API);

        _ordersInfo[orderId].state = OrderState.API_REQUESTED;
        approveOrder(orderId);
    }

    //#endregion

    //#region api

    function approveOrder(uint256 orderId) internal {
        Chainlink.Request memory req = _buildChainlinkRequest(jobId_bool, address(this), this.fillOrderInfo.selector);
        req._add("method", "POST");
        req._add("url", "https://api.example.com/order/status");
        req._add("body", string(abi.encodePacked('{"orderId":', orderId.toString(), "}")));
        req._add("path", "data,isApproved");
        bytes32 requestId = _sendChainlinkRequest(req, fee);
        _requests[requestId] = orderId;
    }

    function _handleOracleResult(uint256 orderId, bool isApproved) internal {
        OrdersStruct storage orderInfo = _ordersInfo[orderId];
        orderInfo.isApproved = isApproved;

        if (isApproved) {
            orderInfo.state = OrderState.APPROVED;
            orderInfo.approvedDateTime = block.timestamp;
            emit ModifyOrderStatus_Event(orderInfo.orderId, orderInfo.modfiedDateTime);

            if (orderInfo.nativeToken && !CLT_Token(_token).paused()) {
                CalcCashBack(orderInfo.orderId, orderInfo.userId, orderInfo.price);
            }
        } else {
            orderInfo.state = OrderState.WAITING_API;
        }
    }

    function fillOrderInfo(bytes32 _requestId, bool isApproved) public recordChainlinkFulfillment(_requestId) {
        uint256 orderId = _requests[_requestId];
        _handleOracleResult(orderId, isApproved);
        delete _requests[_requestId];
    }

    function withDrawToken(address _receiver, address customToken) public onlyOwner {
        if (customToken == address(0)) {
            (bool success, ) = payable(_receiver).call{ value: address(this).balance }("");
            require(success, "ETH transfer failed");
        } else {
            IERC20 lnk = IERC20(customToken);
            require(lnk.balanceOf(address(this)) > 0, "Invalid balance");
            require(lnk.transfer(_receiver, lnk.balanceOf(address(this))), "Transfer faild!");
        }
    }

    //#endregion

    receive() external payable {}

    fallback() external payable {}
}
