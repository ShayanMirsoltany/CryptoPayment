// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;
import "forge-std/Script.sol";
import "@openzeppelin/proxy/ERC1967/ERC1967Proxy.sol";
import "@core/Gateways/PaymentGatewayETH.sol";

contract DeployPaymentGatewayETH is Script {
    function run() public {
        vm.startBroadcast();
        PaymentGatewayETH impl = new PaymentGatewayETH();
        bytes memory data = abi.encodeCall(PaymentGatewayETH.initialize, ());
        address proxy = address(new ERC1967Proxy(address(impl), data));
        console.log("paymentGatewayETH proxy : ", proxy);
        vm.stopBroadcast();
    }
}

// contract DeployTokenV2 is Script {
//     function run() public {
//         vm.startBroadcast();
//         address proxyAddr = 0x31D653D6bdFCEF65420ebC5906e9BDA87968C07e;
//         CLT_Token2 v2 = new CLT_Token2();
//         CLT_Token(proxyAddr).upgradeTo(address(v2));
//         vm.stopBroadcast();
//     }
// }

// contract token : 0x86234BCC4F32249254c52aA9BdE453e34d5741b8
// proxy address : 0x31D653D6bdFCEF65420ebC5906e9BDA87968C07e
// forge script script/DeployPaymentGatewayETH.s.sol --rpc-url $env:RPC_SEPOLIA --private-key $env:PRIVATE_KEY --broadcast --verify
// forge verify-contract --chain sepolia  --verifier etherscan --compiler-version 0.8.30 --watch --constructor-args $(cast abi-encode "constructor(address,bytes)" 0x86234BCC4F32249254c52aA9BdE453e34d5741b8  0x8129fc1c)  0x937f04035A485f01a4D9aFE52A603bf6594D97d5  lib/openzeppelin-contracts/contracts/proxy/ERC1967/ERC1967Proxy.sol:ERC1967Proxy
//Link Sepolia // cast send 0x779877A7B0D9E8603169DdbD7836e478b4624789 "transfer(address,uint256)" 0x31D653D6bdFCEF65420ebC5906e9BDA87968C07e  2000000000000000000 --rpc-url $env:RPC_SEPOLIA --private-key $env:PRIVATE_KEY
//cast send 0x31D653D6bdFCEF65420ebC5906e9BDA87968C07e "modifyContractReceiver(address)" 0x0CE2A7df7FBcA936019D2f0583c246565B76eb19 --rpc-url $env:RPC_SEPOLIA --private-key $env:PRIVATE_KEY
//cast send 0x31D653D6bdFCEF65420ebC5906e9BDA87968C07e "addToPaymentQueue(uint256)" 666555 --value 1 --rpc-url $env:RPC_SEPOLIA --private-key $env:PRIVATE_KEY
