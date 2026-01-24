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
<<<<<<< HEAD
// contract token : 0x961f6F2AaEED98744CFe1EC0e216278E47543750

//forge script script/DeployOrderApprover.s.sol --rpc-url $env:RPC_SEPOLIA --private-key $env:PRIVATE_KEY --broadcast --verify
//Link Sepolia // cast send 0x779877A7B0D9E8603169DdbD7836e478b4624789 "transfer(address,uint256)" 0x961f6F2AaEED98744CFe1EC0e216278E47543750  2000000000000000000 --rpc-url $env:RPC_SEPOLIA --private-key $env:PRIVATE_KEY
//cast send 0x961f6F2AaEED98744CFe1EC0e216278E47543750 "createOrder(uint256)" 909091 --rpc-url $env:RPC_SEPOLIA --private-key $env:PRIVATE_KEY
//cast call 0x961f6F2AaEED98744CFe1EC0e216278E47543750 "getOrderInfo(uint256)" 909091 --rpc-url $env:RPC_SEPOLIA
=======
// contract token : 0xCAc8534D5438f8C7FC3FA8827d61aa15E0223C11

//forge script script/DeployOrderApprover.s.sol --rpc-url $env:RPC_SEPOLIA --private-key $env:PRIVATE_KEY --broadcast --verify
//Link Sepolia // cast send 0x779877A7B0D9E8603169DdbD7836e478b4624789 "transfer(address,uint256)" 0xCAc8534D5438f8C7FC3FA8827d61aa15E0223C11  2000000000000000000 --rpc-url $env:RPC_SEPOLIA --private-key $env:PRIVATE_KEY
//cast send 0xCAc8534D5438f8C7FC3FA8827d61aa15E0223C11 "createOrder(uint256)" 551100 --rpc-url $env:RPC_SEPOLIA --private-key $env:PRIVATE_KEY
//cast call 0xCAc8534D5438f8C7FC3FA8827d61aa15E0223C11 "getOrderInfo(uint256)" 551100 --rpc-url $env:RPC_SEPOLIA
>>>>>>> df5db0f (cashback percent)
