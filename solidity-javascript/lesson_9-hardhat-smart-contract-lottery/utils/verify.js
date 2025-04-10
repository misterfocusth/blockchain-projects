const { run } = require("hardhat");

const verify = async (contractAddress, args) => {
    console.log("[INFO] - Verification - Verifying Contract...");

    try {
        await run("verify:verify", {
            address: contractAddress,
            constructorArguments: args,
        });
    } catch (error) {
        if (error.message.toLowerCase().includes("already verified")) {
            console.log("[INFO] - Verification - Contract has been verified!");
        } else {
            console.log(error);
        }
    }
};

module.exports = { verify };
