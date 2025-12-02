// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;
interface IPaymentGateway {
    function addToPaymentQueue(uint256 orderId) external payable returns (bool result);
    function withDrawBalance() external returns (bool result);
    function modifyContractReceiver(address receiverContract) external;
    function modifyDestinationChainSelector(uint64 destinationChainSelector_) external;
}
