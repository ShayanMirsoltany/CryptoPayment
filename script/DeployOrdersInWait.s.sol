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
        OrdersInWait impl = new OrdersInWait(_router);
        // bytes memory data = abi.encodeCall(OrdersInWait.initialize, (_router));
        // address proxy = address(new ERC1967Proxy(address(impl), data));
        // console.log("OrdersInWait proxy : ", proxy);
        console.log("OrdersInWait address : ", address(impl));
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

// contract token : 0xF5b63923872ee10c8396fd48ed0ffC7b3Ca13EEC
// proxy address : 0xF5b63923872ee10c8396fd48ed0ffC7b3Ca13EEC

// forge script script/DeployOrdersInWait.s.sol --rpc-url $env:RPC_SEPOLIA --private-key $env:PRIVATE_KEY --broadcast --verify
// forge verify-contract --chain sepolia  --verifier etherscan --compiler-version 0.8.30 --watch --constructor-args $(cast abi-encode "constructor(address,bytes)" 0x2b95378231D4d00533A8200B62a2aF52B0ad08D0  0x8129fc1c)  0xBEA8A75F356efdcbF14C70c09c5FdFDE7b827715  lib/openzeppelin-contracts/contracts/proxy/ERC1967/ERC1967Proxy.sol:ERC1967Proxy

//cast send 0xF5b63923872ee10c8396fd48ed0ffC7b3Ca13EEC "setModifierOrderStatusRole(address)" 0x76C5Ce687595bF388cb9a7B34dd457585243bb39 --rpc-url $env:RPC_SEPOLIA --private-key $env:PRIVATE_KEY
//cast call 0xF5b63923872ee10c8396fd48ed0ffC7b3Ca13EEC "getOrderInfo(uint256)" 666555 --rpc-url $env:RPC_SEPOLIA
