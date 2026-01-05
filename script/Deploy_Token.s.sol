// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;
import "forge-std/Script.sol";
import "@openzeppelin/proxy/ERC1967/ERC1967Proxy.sol";
import "@core/ERC20/CLT_Token.sol";

contract DeployTokenV1 is Script {
    function run() public {
        vm.startBroadcast();
        CLT_Token impl = new CLT_Token();
        bytes memory data = abi.encodeCall(CLT_Token.initialize, ("Chainlinker", "AMINI", 200_000_000 ether));
        address proxy = address(new ERC1967Proxy(address(impl), data));
        console.log("Token proxy : ", proxy);
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

// contract token : 0x0d849283582499E5FeD9A3ee093e1Ce318D5c63b
// proxy address : 0xB3e71B5B930607e3E10c5c8A591bCC6D59b93CaF

// forge script script/Deploy_Token.s.sol --rpc-url $env:RPC_SEPOLIA --private-key $env:PRIVATE_KEY --broadcast --verify
//Link Polygon // cast send 0x0Fd9e8d3aF1aaee056EB9e802c3A762a667b1904 "transfer(address,uint256)" 0x6d20C71725068860fD0536E3e6101b6e4C4a5598 1000000000000000000 --rpc-url $env:RPC_POLYGON --private-key $env:PRIVATE_KEY
//Link Sepolia // cast send 0x779877A7B0D9E8603169DdbD7836e478b4624789 "transfer(address,uint256)" 0x9B2e17BFaa54E03a20e97b65E2f18810dc7E0826  2000000000000000000 --rpc-url $env:RPC_SEPOLIA --private-key $env:PRIVATE_KEY
//cast send 0xB3e71B5B930607e3E10c5c8A591bCC6D59b93CaF "mint(address,uint256)" 0x38c30a38cbd6fd5333eb70eda32078e51e7e3009 200000000000000000000000000 --rpc-url $env:RPC_SEPOLIA --private-key $env:PRIVATE_KEY
//cast call 0xB3e71B5B930607e3E10c5c8A591bCC6D59b93CaF "balanceOf(address)" 0x38c30a38cbd6fd5333eb70eda32078e51e7e3009 --rpc-url $env:RPC_SEPOLIA
