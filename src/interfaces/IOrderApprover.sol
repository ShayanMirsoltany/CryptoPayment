// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;
interface IOrderApprover {
    function approveOrder(uint256 orderId) external returns (bool result);
}
