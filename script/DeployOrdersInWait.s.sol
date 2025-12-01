// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;
import "forge-std/Script.sol";
import "@openzeppelin/proxy/ERC1967/ERC1967Proxy.sol";
import "@core/OrdersInWait.sol";

contract DeployOrdersInWait is Script {
    function run() public {
        vm.startBroadcast();

        address _router = 0x0BF3dE8c5D3e8A2B34D2BEeB17ABfCeBaf363A59;
        // address _linkToken = 0x779877A7B0D9E8603169DdbD7836e478b4624789;
        // uint256 _chainSelector = 16015286601757825753;
        OrdersInWait impl = new OrdersInWait();
        bytes memory data = abi.encodeCall(OrdersInWait.initialize, (_router));
        address proxy = address(new ERC1967Proxy(address(impl), data));
        console.log("OrdersInWait proxy : ", proxy);
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

// contract token : 0x2caFf340e1e82c61481dFC2A9Fd689bDe9583a3d
// proxy address : 0x795117285A083Bcde1DF36233062B0f0c093BDa3

// forge script script/DeployOrdersInWait.s.sol --rpc-url $env:RPC_SEPOLIA --private-key $env:PRIVATE_KEY --broadcast --verify
// forge verify-contract --chain sepolia  --verifier etherscan --compiler-version 0.8.30 --watch --constructor-args $(cast abi-encode "constructor(address,bytes)" 0x57D457A897F622e68E84EE14ee9ce925dB84cc34  0x8129fc1c)  0x795117285A083Bcde1DF36233062B0f0c093BDa3  lib/openzeppelin-contracts/contracts/proxy/ERC1967/ERC1967Proxy.sol:ERC1967Proxy

//cast send 0x795117285A083Bcde1DF36233062B0f0c093BDa3 "func(address)" 0x38c30a38cbd6fd5333eb70eda32078e51e7e3009 --rpc-url $env:RPC_SEPOLIA --private-key $env:PRIVATE_KEY
//cast call 0x795117285A083Bcde1DF36233062B0f0c093BDa3 "getOrderInfo(uint256)" 555000 --rpc-url $env:RPC_SEPOLIA
