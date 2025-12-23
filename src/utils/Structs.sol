// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;
import "./Enums.sol";
struct OrdersStruct {
    uint256 orderId;
    address userId;
    uint256 price;
    OrderState state;
    uint256 createdDateTime;
    uint256 modfiedDateTime;
    bool nativeToken;
    bool isApproved;
    uint256 approvedDateTime;
}
