// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

// Libraries
import {Script} from "forge-std/Script.sol";

// Contracts
import {VRFCoordinatorV2_5Mock} from "@chainlink/contracts/src/v0.8/vrf/mocks/VRFCoordinatorV2_5Mock.sol";

// Mock Link
import {LinkToken} from "test/mocks/LinkToken.sol";

abstract contract CodeConstants {
    // VRF MOCK CONFIG
    uint96 public MOCK_BASE_FEE = 0.25 ether; // 0.25 LINK
    uint96 public MOCK_GAS_PRICE_LINK = 1e9; // 1 Gwei
    int256 public MOCK_WEI_PER_UINT_LINK = 4e15; // LINK / ETH Price

    uint256 public constant ETH_SEPOLIA_CHAIN_ID = 11155111;
    uint256 public constant LOCAL_CHAIN_ID = 31337;

    constructor() {}
}

contract HelperConfig is CodeConstants, Script {
    error HelperConfig__InvalidChainId();

    struct NetworkConfig {
        uint256 entranceFee;
        uint256 interval;
        address vrfCoordinator;
        bytes32 keyHash;
        uint256 subscriptionId;
        uint32 callbackGasLimit;
        address link;
        address account;
    }

    NetworkConfig public localNetworkConfig;
    mapping(uint256 chainId => NetworkConfig) public networkConfigs;

    constructor() {
        networkConfigs[ETH_SEPOLIA_CHAIN_ID] = getSepoliaEthConfig();
    }

    function getConfigByChainId(
        uint256 chainId
    ) public returns (NetworkConfig memory) {
        if (networkConfigs[chainId].vrfCoordinator != address(0)) {
            return networkConfigs[chainId];
        } else if (chainId == LOCAL_CHAIN_ID) {
            return getOrCreateAnvilEthConfig();
        } else {
            revert HelperConfig__InvalidChainId();
        }
    }

    function getConfig() public returns (NetworkConfig memory) {
        return getConfigByChainId(block.chainid);
    }

    function getOrCreateAnvilEthConfig() public returns (NetworkConfig memory) {
        if (localNetworkConfig.vrfCoordinator != address(0)) {
            return localNetworkConfig;
        }

        // Deploy Mock and Return Config
        vm.startBroadcast();

        VRFCoordinatorV2_5Mock vrfCoordinatorMock = new VRFCoordinatorV2_5Mock(
            MOCK_BASE_FEE,
            MOCK_GAS_PRICE_LINK,
            MOCK_WEI_PER_UINT_LINK
        );

        LinkToken linkToken = new LinkToken();

        vm.stopBroadcast();

        localNetworkConfig = NetworkConfig({
            entranceFee: 0.01 ether, // 1e16
            interval: 30, // 30 seconds
            vrfCoordinator: address(vrfCoordinatorMock),
            keyHash: 0x6c3699283b146b5d9b146e10d1f5c2c8a4f7e0b3a4f7e0b3a4f7e0b3a4f7e0b3, // Mock Key Hash
            subscriptionId: 0, // Subscription ID
            callbackGasLimit: 100000, // 100k gas
            link: address(linkToken), // LINK Token
            account: 0x1804c8AB1F12E6bbf3894d4083f33e07309d1f38 // Default Foundry Sender
        });

        return localNetworkConfig;
    }

    function getSepoliaEthConfig() public pure returns (NetworkConfig memory) {
        return
            NetworkConfig({
                entranceFee: 0.01 ether, // 1e16
                interval: 30, // 30 seconds
                vrfCoordinator: 0x9DdfaCa8183c41ad55329BdeeD9F6A8d53168B1B, // Sepolia VRF Coordinator
                keyHash: 0x787d74caea10b2b357790d5b5247c2f63d1d91572a9846f780606e4d953677ae, // Sepolia Key Hash
                subscriptionId: 2566209793823083165104046240324820625567826459468828286387205626283729919581, // Subscription ID
                callbackGasLimit: 100000, // 100k gas
                link: 0x779877A7B0D9E8603169DdbD7836e478b4624789, // LINK Token
                account: 0xf466e7cE6B06f9b3071557A790Bd45F051C1C60A // Account
            });
    }
}
