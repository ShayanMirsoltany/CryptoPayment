// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;
struct OrdersStruct {
    uint256 orderId;
    address userId;
    uint256 price;
    bool success;
    uint256 createdDateTime;
    uint256 modfiedDateTime;
}
