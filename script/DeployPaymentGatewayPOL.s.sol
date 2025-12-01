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

// contract token : 0xf10bDdeDaa761fa5c4c3b64eC832716Fcc157CE8
// proxy address : 0xD78280f74a1dd80f9e0faaFfd1119D9aBa18DEf4

// forge script script/DeployPaymentGatewayPOL.s.sol --rpc-url $env:RPC_POLYGON --private-key $env:PRIVATE_KEY --broadcast --verify
// forge verify-contract --chain polygon-amoy  --verifier etherscan --compiler-version 0.8.30 --watch --constructor-args $(cast abi-encode "constructor(address,bytes)" 0xf10bDdeDaa761fa5c4c3b64eC832716Fcc157CE8  0x8129fc1c)  0xD78280f74a1dd80f9e0faaFfd1119D9aBa18DEf4  lib/openzeppelin-contracts/contracts/proxy/ERC1967/ERC1967Proxy.sol:ERC1967Proxy

//Link Polygon // cast send 0x0Fd9e8d3aF1aaee056EB9e802c3A762a667b1904 "transfer(address,uint256)" 0xD78280f74a1dd80f9e0faaFfd1119D9aBa18DEf4 1000000000000000000 --rpc-url $env:RPC_POLYGON --private-key $env:PRIVATE_KEY
//cast send 0xa3258a331913B3097a13F913804CEca5242DC56E "func(address)" 0x38c30a38cbd6fd5333eb70eda32078e51e7e3009 --rpc-url $env:RPC_SEPOLIA --private-key $env:PRIVATE_KEY
//cast call 0xa3258a331913B3097a13F913804CEca5242DC56E "balanceOf(address)" 0x38c30a38cbd6fd5333eb70eda32078e51e7e3009 --rpc-url $env:RPC_SEPOLIA
