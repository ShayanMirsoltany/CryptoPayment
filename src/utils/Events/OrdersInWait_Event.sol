// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;
event CashBackEvent(address indexed receiver, uint256 orderId, uint256 amount, uint256 cashBackAmount, uint256 datetime);
event OrderReceived_Event(bytes32 messageId, uint256 orderId, address indexed user);
event OrderReceivedETH_Event(uint256 orderId, address indexed user);
event ModifyOrderStatus_Event(uint256 orderId, uint256 modifiedDateTime);
