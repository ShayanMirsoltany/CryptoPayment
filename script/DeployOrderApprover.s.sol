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
// contract token : 0xB38784480e506BDBF2155717b11F8d98E6571ffc

// forge script script/DeployOrderApprover.s.sol --rpc-url $env:RPC_SEPOLIA --private-key $env:PRIVATE_KEY --broadcast --verify
//Link Sepolia // cast send 0x779877A7B0D9E8603169DdbD7836e478b4624789 "transfer(address,uint256)" 0xB38784480e506BDBF2155717b11F8d98E6571ffc  2000000000000000000 --rpc-url $env:RPC_SEPOLIA --private-key $env:PRIVATE_KEY
//cast send 0xB38784480e506BDBF2155717b11F8d98E6571ffc "createOrder(uint256)" 123321 --rpc-url $env:RPC_SEPOLIA --private-key $env:PRIVATE_KEY
//cast call 0xB38784480e506BDBF2155717b11F8d98E6571ffc "getOrderInfo(uint256)" 123321 --rpc-url $env:RPC_SEPOLIA
