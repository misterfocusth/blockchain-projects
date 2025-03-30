const ethers = require("ethers")
const fs = require("fs-extra")
require("dotenv").config()
const { Wallet } = require("ethers");

async function main() {
    const wallet = new ethers.Wallet(process.env.WALLET_PRIVATE_KEY)

    // const encryptedJsonKey = await wallet.encrypt(
    //     process.env.WALLET_PRIVATE_KEY,
    //     process.env.PRIVATE_KEY
    // )

    const encryptedJsonKey = wallet.encryptSync(process.env.PRIVATE_KEY_PASSWORD)

    // In later version (^6.2.3 as of this commit) of etherjs, PRIVATE_KEY is inferred from wallet, so there is no need to 
    // pass private key again. 
    //     const encryptedJsonKey = await wallet.encrypt(
    //         process.env.PRIVATE_KEY_PASSWORD,
    //  )
    console.log(encryptedJsonKey)
    fs.writeFileSync("./.encryptedKey.json", encryptedJsonKey)
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error)
        process.exit(1)
    })