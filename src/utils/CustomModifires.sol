// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
import "@share/_anyAPIContracts.sol";
contract modifierUtilis is ChainlinkClient {
    // using Chainlink for Chainlink.Request;
    // mapping(bytes32 requestId => uint256 orderId) private _requests;
    // mapping(uint256 orderId => bool isValid) private _orders;
    // modifier checkOrderId(uint256 orderId) {
    //     Chainlink.Request memory req = _buildChainlinkRequest(jobId_bool, address(this), this.checkOrderResult.selector);
    //     req._add("get", string(abi.encodePacked("https://api.nafisexpress.dev/panel/checkOrderId?orderId=", orderId.toString())));
    //     req._add("path", "isValid");
    //     bytes32 requestId = _sendChainlinkRequest(req, fee);
    //     _requests[requestId] = orderId;
    //     _;
    // }
    // function checkOrderResult(bytes32 _requestId, bool isValid) public recordChainlinkFulfillment(_requestId) {
    //     uint256 orderId = _requests[_requestId];
    //     _orders[orderId] = isValid;
    //     delete _requests[_requestId];
    // }
}
