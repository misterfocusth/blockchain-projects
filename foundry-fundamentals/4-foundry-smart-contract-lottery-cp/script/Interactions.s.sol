// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

// Libraries
import {Script, console} from "forge-std/Script.sol";

// Contracts
import {HelperConfig} from "./HelperConfig.s.sol";
import {VRFCoordinatorV2_5Mock} from "@chainlink/contracts/src/v0.8/vrf/mocks/VRFCoordinatorV2_5Mock.sol";
import {CodeConstants} from "./HelperConfig.s.sol";
import {LinkToken} from "test/mocks/LinkToken.sol";
import {DevOpsTools} from "lib/foundry-devops/src/DevOpsTools.sol";

contract CreateSubscription is Script {
    function createSubscriptionUsingConfig() public returns (uint256, address) {
        HelperConfig helperConfig = new HelperConfig();
        address vrfCoordinator = helperConfig.getConfig().vrfCoordinator;
        address account = helperConfig.getConfig().account;
        (uint256 subId, ) = createSubscription(vrfCoordinator, account);
        return (subId, vrfCoordinator);
    }

    function createSubscription(
        address vrfCoordinator,
        address account
    ) public returns (uint256, address) {
        console.log("[INFO] - CreateSubscription - Creating Subscription...");
        vm.startBroadcast(account);
        uint256 subId = VRFCoordinatorV2_5Mock(vrfCoordinator)
            .createSubscription();
        vm.stopBroadcast();
        console.log("[INFO] - CreateSubscription - Subscription ID: ", subId);
        console.log("[INFO] - CreateSubscription - Subscription created.");
        return (subId, vrfCoordinator);
    }

    function run() public {
        createSubscriptionUsingConfig();
    }
}

contract FundSubscription is Script, CodeConstants {
    uint256 public constant FUND_AMOUNT = 1 ether;

    function fundSubscriptionUsingConfig() public {
        HelperConfig helperConfig = new HelperConfig();
        address vrfCoordinator = helperConfig.getConfig().vrfCoordinator;
        uint256 subscriptionId = helperConfig.getConfig().subscriptionId;
        address linkToken = helperConfig.getConfig().link;
        address account = helperConfig.getConfig().account;
        fundSubscription(vrfCoordinator, subscriptionId, linkToken, account);
    }

    function fundSubscription(
        address vrfCoordinator,
        uint256 subscriptionId,
        address linkToken,
        address account
    ) public {
        console.log("[INFO] - FundSubscription - Funding Subscription...");
        console.log(
            "[INFO] - FundSubscription - Subscription ID: ",
            subscriptionId
        );
        console.log(
            "[INFO] - FundSubscription - Using VRF Coordinator: ",
            vrfCoordinator
        );
        console.log(
            "[INFO] - FundSubscription - Using Link Token: ",
            linkToken
        );
        console.log("[INFO] - FundSubscription - On ChainId: ", block.chainid);

        if (block.chainid == LOCAL_CHAIN_ID) {
            vm.startBroadcast();

            VRFCoordinatorV2_5Mock(vrfCoordinator).fundSubscription(
                subscriptionId,
                FUND_AMOUNT * 1000
            );
            console.log(
                "[INFO] - FundSubscription - Funded Subscription with: ",
                FUND_AMOUNT
            );
            console.log("[INFO] - FundSubscription - Subscription Funded.");

            vm.stopBroadcast();
        } else {
            vm.startBroadcast(account);

            LinkToken(linkToken).transferAndCall(
                vrfCoordinator,
                FUND_AMOUNT,
                abi.encode(subscriptionId)
            );

            vm.stopBroadcast();
        }
    }

    function run() public {
        fundSubscriptionUsingConfig();
    }
}

contract AddConsumer is Script {
    function addConsumerUsingConfig(address mostRecentlyDeployed) public {
        HelperConfig helperConfig = new HelperConfig();
        uint256 subId = helperConfig.getConfig().subscriptionId;
        address vrfCoordinator = helperConfig.getConfig().vrfCoordinator;
        address account = helperConfig.getConfig().account;
        addConsumer(mostRecentlyDeployed, vrfCoordinator, subId, account);
    }

    function addConsumer(
        address contractToAddToVrf,
        address vrfCoordinator,
        uint256 subscriptionId,
        address account
    ) public {
        console.log(
            "[INFO] - AddConsumer - Adding Consumer to VRF Coordinator..."
        );
        console.log(
            "[INFO] - AddConsumer - Contract to add: ",
            contractToAddToVrf
        );
        console.log("[INFO] - AddConsumer - VRF Coordinator ", vrfCoordinator);
        console.log("[INFO] - AddConsumer - On ChainId: ", block.chainid);

        vm.startBroadcast(account);

        VRFCoordinatorV2_5Mock(vrfCoordinator).addConsumer(
            subscriptionId,
            contractToAddToVrf
        );

        vm.stopBroadcast();

        console.log(
            "[INFO] - AddConsumer - Added Consumer to VRF Coordinator."
        );
    }

    function run() external {
        address mostRecentlyDeployed = DevOpsTools.get_most_recent_deployment(
            "Raffle",
            block.chainid
        );
        addConsumerUsingConfig(mostRecentlyDeployed);
    }
}
