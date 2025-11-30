// SPDX-License-Identifier: MIT
pragma solidity 0.8.30;
import "@chainlink/src/v0.8/automation/interfaces/AutomationCompatibleInterface.sol";
contract KeeperManager is AutomationCompatibleInterface {
    event CheckEvent(address indexed user, uint256 timestamp);
    event RewardGranted(address indexed user, uint256 tokenId, uint256 timestamp);

    function doEvent() public {
        emit CheckEvent(msg.sender, block.timestamp);
    }

    function checkUpkeep(bytes calldata) external pure override returns (bool upkeepNeeded, bytes memory) {
        upkeepNeeded = false;
    }

    function performUpkeep(bytes calldata performData) external override {
        emit RewardGranted(msg.sender, 111111, block.timestamp);
    }
}
