// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
import "@share/_upgradeContracts.sol";
import { Client } from "@ccip-contracts/src/v0.8/ccip/libraries/Client.sol";
import { IRouterClient } from "@ccip-contracts/src/v0.8/ccip/interfaces/IRouterClient.sol";
contract CCIPReceiverUpgradeable is Initializable {
    IRouterClient internal router;
    function __CCIPReceiver_init(address _router) internal initializer {
        router = IRouterClient(_router);
    }
    function ccipReceive(Client.Any2EVMMessage calldata message) external {
        require(msg.sender == address(router), "NOT_ROUTER");
        _ccipReceive(message);
    }

    function _ccipReceive(Client.Any2EVMMessage memory message) public virtual {}
}
