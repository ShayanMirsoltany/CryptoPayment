// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;
import "@utils/Structs.sol";
interface IOrdersInWait {
    function setModifierOrderStatusRole(address contractModifier) external;
    function removeModifierOrderStatusRole(address contractModifier) external;
    function modifyOrderStatus(OrdersStruct memory order) external returns (bool result);
    function getOrderInfo(uint256 orderId) external view returns (bool result);
    function addToOrdersInWaiting(OrdersStruct memory order) external returns (bool result);
}
