// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;
interface IPaymentGateway {
    function getUserBalance() external view returns (uint256 result);
    function getBalance() external view returns (uint256 result);
    function addToPaymentQueue(uint256 orderId) external payable returns (bool result);
    function withDrawBalance() external returns (bool result);
    function modifyContractReceiver(address receiverContract) external;
    function modifyDestinationChainSelector(uint64 destinationChainSelector_) external;
}

interface IPaymentCLTGateway {
    function getBalance() external view returns (uint256 result);
    function payWithPermit(uint256 orderId, uint256 amount, uint256 deadline, uint8 v, bytes32 r, bytes32 s) external returns (bool);
    function withDrawBalance() external returns (bool result);
    function modifyContractReceiver(address receiverContract) external;
    function modifyDestinationChainSelector(uint64 destinationChainSelector_) external;
}
