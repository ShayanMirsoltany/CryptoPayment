// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;
interface IPaymentGateway {
    function addToPaymentQueue(uint256 orderId) external payable returns (bool result);
    function withDrawBalance() external returns (bool result);
    function modifyContractReceiver(address receiverContract) external;
    function modifyDestinationChainSelector(uint64 destinationChainSelector_) external;
}

interface IPaymentCLTGateway {
    function payWithPermit(uint256 orderId, uint256 amount, uint256 deadline, uint8 v, bytes32 r, bytes32 s) external returns (bool);
    function withDrawBalance() external returns (bool result);
    function modifyContractReceiver(address receiverContract) external;
    function modifyDestinationChainSelector(uint64 destinationChainSelector_) external;
}
