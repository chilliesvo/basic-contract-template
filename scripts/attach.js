const { ethers, upgrades } = require("hardhat");
require("dotenv").config();
const env = process.env;

async function main() {
    //* Loading accounts */
    const accounts = await ethers.getSigners();
    const callWallet = accounts[0].address;
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });
