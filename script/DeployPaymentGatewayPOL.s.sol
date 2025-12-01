// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;
import "forge-std/Script.sol";
import "@openzeppelin/proxy/ERC1967/ERC1967Proxy.sol";
import "@core/Gateways/PaymentGatewayPOL.sol";

contract DeployPaymentGatewayPOL is Script {
    function run() public {
        vm.startBroadcast();
        address _router = 0x9C32fCB86BF0f4a1A8921a9Fe46de3198bb884B2;
        address _linkToken = 0x0Fd9e8d3aF1aaee056EB9e802c3A762a667b1904;
        // uint256 _chainSelector = 16281711391670634445;
        PaymentGatewayPOL impl = new PaymentGatewayPOL();
        bytes memory data = abi.encodeCall(PaymentGatewayPOL.initialize, (_router, _linkToken));
        address proxy = address(new ERC1967Proxy(address(impl), data));
        console.log("PaymentGatewayPOL proxy : ", proxy);
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

// contract token : 0xdc838496e8139ACa84BA039CDb5C3230411C5dB7
// proxy address : 0x6411cB2c1fCAC3d1Dc44BC2b23A06Fe8b86e9ad4

// forge script script/Deploy_Token.s.sol --rpc-url $env:RPC_SEPOLIA --private-key $env:PRIVATE_KEY --broadcast --verify
//Link Polygon // cast send 0x0Fd9e8d3aF1aaee056EB9e802c3A762a667b1904 "transfer(address,uint256)" 0x6d20C71725068860fD0536E3e6101b6e4C4a5598 1000000000000000000 --rpc-url $env:RPC_POLYGON --private-key $env:PRIVATE_KEY
//Link Sepolia // cast send 0x779877A7B0D9E8603169DdbD7836e478b4624789 "transfer(address,uint256)" 0x9B2e17BFaa54E03a20e97b65E2f18810dc7E0826  2000000000000000000 --rpc-url $env:RPC_SEPOLIA --private-key $env:PRIVATE_KEY
//cast send 0xa3258a331913B3097a13F913804CEca5242DC56E "func(address)" 0x38c30a38cbd6fd5333eb70eda32078e51e7e3009 --rpc-url $env:RPC_SEPOLIA --private-key $env:PRIVATE_KEY
//cast call 0xa3258a331913B3097a13F913804CEca5242DC56E "balanceOf(address)" 0x38c30a38cbd6fd5333eb70eda32078e51e7e3009 --rpc-url $env:RPC_SEPOLIA
