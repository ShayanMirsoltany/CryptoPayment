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
// contract token : 0x184474E417289E63d6391Ca0c6CAAAe71DaB5782

// forge script script/DeployOrderApprover.s.sol --rpc-url $env:RPC_SEPOLIA --private-key $env:PRIVATE_KEY --broadcast --verify
//Link Sepolia // cast send 0x779877A7B0D9E8603169DdbD7836e478b4624789 "transfer(address,uint256)" 0x184474E417289E63d6391Ca0c6CAAAe71DaB5782  2000000000000000000 --rpc-url $env:RPC_SEPOLIA --private-key $env:PRIVATE_KEY
//cast send 0x184474E417289E63d6391Ca0c6CAAAe71DaB5782 "createOrder(uint256)" 123321 --rpc-url $env:RPC_SEPOLIA --private-key $env:PRIVATE_KEY
//cast call 0x184474E417289E63d6391Ca0c6CAAAe71DaB5782 "getOrderInfo(uint256)" 123321 --rpc-url $env:RPC_SEPOLIA
