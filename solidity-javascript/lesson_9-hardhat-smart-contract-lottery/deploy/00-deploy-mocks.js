const { ethers } = require("hardhat");
const { developmentChains } = require("../helper-hardhat-config");

module.exports = async ({ getNamedAccounts, deployments }) => {
    // const { getNamedAccounts, deployment } = hre;
    const { deploy, log } = deployments;
    const { deployer } = await getNamedAccounts();

    const BASE_FEE = ethers.parseEther("0.25"); // Chainlink Fee.
    const GAS_PRICE_LINK = 1e9; // Link per gas Calculated value based on gas price of the chain. (Based on proce of gas)

    if (developmentChains.includes(network.name)) {
        log("[INFO] - Deployment 00 - Local network detected!");
        log("[INFO] - Deployment 00 - Mocks Deploying...");
        await deploy("VRFCoordinatorV2Mock", {
            from: deployer,
            log: true,
            args: [BASE_FEE, GAS_PRICE_LINK],
        });
        log("[INFO] - Deployment 00 - Mocks Deployed!");
        log("==================================================");
    }
};

module.exports.tags = ["all", "mocks"];
