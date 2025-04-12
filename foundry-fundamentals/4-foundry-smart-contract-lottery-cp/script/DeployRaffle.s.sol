// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

// Libraries
import {Script} from "forge-std/Script.sol";

// Contracts
import {Raffle} from "../src/Raffle.sol";
import {CreateSubscription, FundSubscription, AddConsumer} from "./Interactions.s.sol";

// Helper
import {HelperConfig} from "./HelperConfig.s.sol";

contract DeployRaffle is Script {
    function deployContract() public returns (Raffle, HelperConfig) {
        HelperConfig helperConfig = new HelperConfig();
        // Local -> Deploy Mock and Get Config
        // Sepolia -> Get Config
        HelperConfig.NetworkConfig memory config = helperConfig.getConfig();

        if (config.subscriptionId == 0) {
            // Create Subscription
            CreateSubscription createSubscription = new CreateSubscription();
            (config.subscriptionId, config.vrfCoordinator) = createSubscription
                .createSubscription(config.vrfCoordinator, config.account);

            // Fund Subscription
            FundSubscription fundSubscription = new FundSubscription();
            fundSubscription.fundSubscription(
                config.vrfCoordinator,
                config.subscriptionId,
                config.link,
                config.account
            );
        }

        vm.startBroadcast(config.account);

        Raffle raffle = new Raffle(
            config.entranceFee,
            config.interval,
            config.vrfCoordinator,
            config.keyHash,
            config.subscriptionId,
            config.callbackGasLimit
        );

        vm.stopBroadcast();

        AddConsumer addConsumer = new AddConsumer();
        addConsumer.addConsumer(
            address(raffle),
            config.vrfCoordinator,
            config.subscriptionId,
            config.account
        );

        return (raffle, helperConfig);
    }

    function run() public {
        deployContract();
    }
}
