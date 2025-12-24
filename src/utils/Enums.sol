// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;
enum OrderState {
    NONE,
    WAITING_API,
    API_REQUESTED,
    APPROVED,
    REJECTED
}
