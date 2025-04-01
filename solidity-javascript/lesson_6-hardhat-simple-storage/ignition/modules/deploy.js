const { ethers, run, network } = require("hardhat");

async function main() {
  const SimpleStorageFactory = await ethers.getContractFactory("SimpleStorage");

  console.log("[INFO]", "[Network]", "Chain ID :", network.config.chainId);
  console.log("[INFO]", "[Contract]", ": Deploying a contract...")
  const simpleStorage = await SimpleStorageFactory.deploy();
  await simpleStorage.deploymentTransaction().wait(1)
  console.log("[INFO]", "[Contract]", ": Contract deployed at address =", await simpleStorage.getAddress());

  const HARDHAT_NETWORK_CHAINID = 31337;
  const ETHERSCAN_API_KEY = process.env.ETHERSCAN_API_KEY;

  if (network.config.chainId !== HARDHAT_NETWORK_CHAINID && ETHERSCAN_API_KEY) {
    await simpleStorage.deploymentTransaction().wait(6)
    await verify(await simpleStorage.getAddress(), [])
  }

  const currentValue = await simpleStorage.retrieve();
  console.log("[INFO]", "[SimpleStorage]", "Current Value :", currentValue.toString());

  const transactionResponse = await simpleStorage.store(65070219)
  await transactionResponse.wait(1);
  const updatedValue = await simpleStorage.retrieve();
  console.log("[INFO]", "[SimpleStorage]", "Updated Value :", updatedValue.toString());
}

async function verify(contractAddress, args) {
  console.log("[INFO]", "[Contract]", ": Verifying a contract...");
  try {
    await run("verify:verify", {
      address: contractAddress,
      constructorArguments: args
    })
  } catch (error) {
    if (error.message.toLowerCase().includes("already verified")) {
      console.log("[ERROR]", "[Contract]", ": Can't make a verification, this contract has benn verified!");
    }
    console.log("[ERROR]", "[Contract]", ":", error);
  }
  console.log("[INFO]", "[Contract]", ": Contract has been verified!");
}


main()
  .then(() => process.exit(0))
  .catch((err) => {
    console.error(err);
    process.exit(1);
  });
