import { ethers } from "./ethers-5.6.esm.min.js";
import { ABI, CONTRACT_ADDRESS } from "./constants.js";

const connectButton = document.getElementById("connectButton");
const fundButton = document.getElementById("fundButton");
const balanceButton = document.getElementById("balanceButton");
const withdrawButton = document.getElementById("withdrawButton");

connectButton.addEventListener("click", connect);
fundButton.addEventListener("click", fund);
balanceButton.addEventListener("click", getBalance);
withdrawButton.addEventListener("click", withdraw);

async function connect() {
    if (typeof window.ethereum !== "undefined") {
        console.log("[INFO] - Connect() : Ethereum Supported!");
        await window.ethereum.request({ method: "eth_requestAccounts" });
        console.log("[INFO] - Connect() : Metamask Wallet Connected!");
        connectButton.innerHTML = "Connected!";
    } else {
        console.log("[INFO] - Connect() : Ethereum Not Supported!");
        connectButton.innerHTML = "Ethereum Not Supported!";
    }
}

async function fund() {
    const ethAmount = document.getElementById("ethAmount").value;
    console.log(`[INFO] - Fund() : Funding with ${ethAmount} ETH.`);

    if (typeof window.ethereum !== "undefined") {
        // 1. Provider / Connection to Blockchain
        const provider = new ethers.providers.Web3Provider(window.ethereum);

        // 2. Signer / Wallet
        const signer = provider.getSigner();

        // 3. ABI
        const contract = new ethers.Contract(CONTRACT_ADDRESS, ABI, signer);

        try {
            const transactionResponse = await contract.fund({ value: ethers.utils.parseEther(ethAmount) });
            // Wait - TX Mined
            await waitForConfirmation(transactionResponse, provider);
            document.getElementById("ethAmount").value = 0;
        } catch (error) {
            console.log(error);
        }
    } else {
        console.log("[INFO] - Connect() : Ethereum Not Supported!");
    }
}

async function getBalance() {
    if (typeof window.ethereum !== "undefined") {
        const provider = new ethers.providers.Web3Provider(window.ethereum);
        const balance = await provider.getBalance(CONTRACT_ADDRESS);
        console.log(`[INFO] - getBalance() : ${ethers.utils.formatEther(balance)}`);
        return balance;
    }

    return 0;
}

function waitForConfirmation(transactionResponse, provider) {
    console.log(`[INFO] - waitForConfirmation() : Mining ${transactionResponse.hash}...`);
    return new Promise((resolve, reject) => {
        provider.once(transactionResponse.hash, (transactionReceipt) => {
            console.log(
                `[INFO] - waitForConfirmation() : Completed with ${transactionReceipt.confirmations} confirm(s)`,
            );
            resolve();
        });
    });
}

async function withdraw() {
    const currentBalance = await getBalance();
    console.log(`[INFO] - withdraw() : Withdrawing ${ethers.utils.formatEther(currentBalance)} ETH`);

    const provider = new ethers.providers.Web3Provider(window.ethereum);
    const signer = provider.getSigner();
    const contract = new ethers.Contract(CONTRACT_ADDRESS, ABI, signer);

    try {
        const transactionResponse = await contract.withdraw();
        await waitForConfirmation(transactionResponse, provider);
    } catch (error) {
        console.log(error);
    }
}
