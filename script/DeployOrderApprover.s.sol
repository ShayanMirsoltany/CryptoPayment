// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;
import "forge-std/Script.sol";
import "@openzeppelin/proxy/ERC1967/ERC1967Proxy.sol";
import "@core/OrderApprover.sol";

contract DeployOrderApprover is Script {
    function run() public {
        vm.startBroadcast();
        address _router = 0x0BF3dE8c5D3e8A2B34D2BEeB17ABfCeBaf363A59;
        address _cltToken = 0x9C32fCB86BF0f4a1A8921a9Fe46de3198bb884B2;
        OrderApprover impl = new OrderApprover(_router, _cltToken);
        console.log("OrdersInWait address : ", address(impl));
        vm.stopBroadcast();
    }
}
