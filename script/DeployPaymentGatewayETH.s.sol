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
//         address proxyAddr = 0x6411cB2c1fCAC3d1Dc44BC2b23A06Fe8b86e9ad4;
//         CLT_Token2 v2 = new CLT_Token2();
//         CLT_Token(proxyAddr).upgradeTo(address(v2));
//         vm.stopBroadcast();
//     }
// }

// contract token : 0x65a19a558823CC44e152Ea2b23B12C78B4706BA2
// proxy address : 0x937f04035A485f01a4D9aFE52A603bf6594D97d5
// forge script script/DeployPaymentGatewayETH.s.sol --rpc-url $env:RPC_SEPOLIA --private-key $env:PRIVATE_KEY --broadcast --verify
// forge verify-contract --chain sepolia  --verifier etherscan --compiler-version 0.8.30 --watch --constructor-args $(cast abi-encode "constructor(address,bytes)" 0x65a19a558823CC44e152Ea2b23B12C78B4706BA2  0x8129fc1c)  0x937f04035A485f01a4D9aFE52A603bf6594D97d5  lib/openzeppelin-contracts/contracts/proxy/ERC1967/ERC1967Proxy.sol:ERC1967Proxy
//Link Sepolia // cast send 0x779877A7B0D9E8603169DdbD7836e478b4624789 "transfer(address,uint256)" 0x937f04035A485f01a4D9aFE52A603bf6594D97d5  2000000000000000000 --rpc-url $env:RPC_SEPOLIA --private-key $env:PRIVATE_KEY
//cast send 0x937f04035A485f01a4D9aFE52A603bf6594D97d5 "addToPaymentQueue(uint256 , address)" 555000 0x795117285A083Bcde1DF36233062B0f0c093BDa3 --value 1 --rpc-url $env:RPC_SEPOLIA --private-key $env:PRIVATE_KEY
