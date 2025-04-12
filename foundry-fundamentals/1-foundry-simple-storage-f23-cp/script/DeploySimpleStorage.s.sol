// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

// Standard Libraries
import {Script} from "forge-std/Script.sol";

// Contracts
import {SimpleStorage} from "../src/SimpleStorage.sol";

contract DeploySimpleStorage is Script {
    function run() external returns (SimpleStorage) {
        vm.startBroadcast(); // Send TX to the network.
        // Deploy the SimpleStorage contract
        SimpleStorage simpleStorage = new SimpleStorage();
        vm.stopBroadcast(); // Stop sending TX to the network.
        return simpleStorage;
    }
}
