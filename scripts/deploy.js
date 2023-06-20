const { ethers } = require("hardhat");
const {
    deployProxyAndLogger,
    deployAndLogger,
    getCrossmintAddress,
    contractFactoriesLoader,
} = require("../utils/deploy.utils");
const { blockTimestamp } = require("../test/utils");
require("dotenv").config();
const env = process.env;
const fs = require("fs");

async function main() {
    //* Get network */
    const network = await ethers.provider.getNetwork();
    const networkName = network.chainId === 31337 ? "hardhat" : network.name;
    const blockTimeNow = await blockTimestamp();

    //* Loading accounts */
    const accounts = await ethers.getSigners();
    const addresses = accounts.map((item) => item.address);
    const deployer = addresses[0];

    //* Deploy param */
    const crossmintAddress = await getCrossmintAddress();

    //* Loading contract factory */
    const contractFactories = await contractFactoriesLoader();

    //* Deploy contracts */
    const underline = "=".repeat(93);
    console.log(underline);
    console.log("DEPLOYING CONTRACTS");
    console.log(underline);
    console.log("chainId   :>> ", network.chainId);
    console.log("chainName :>> ", networkName);
    console.log("deployer  :>> ", deployer);
    console.log(underline);

    const verifyArguments = {
        chainId: network.chainId,
        networkName,
        deployer,
    };

    //** NFTFactory */
    const monkey721Library = await deployAndLogger(contractFactories.Monkey721);
    verifyArguments.monkey721Library = monkey721Library.address;

    const monkey1155Library = await deployAndLogger(contractFactories.Monkey1155);
    verifyArguments.monkey1155Library = monkey1155Library.address;

    const nftFactory = await deployProxyAndLogger(contractFactories.NFTFactory, [
        monkey721Library.address,
        monkey1155Library.address,
        crossmintAddress,
    ]);
    verifyArguments.nftFactory = nftFactory.address;
    verifyArguments.nftFactoryVerify = nftFactory.addressVerify;

    //** NFT Public Mint */
    const monkey721PublicMint = await deployProxyAndLogger(contractFactories.Monkey721PublicMint, [
        env.MONKEY721_PUBLIC_MINT_CONTRACT_URI,
        env.MONKEY721_PUBLIC_MINT_NAME,
        env.MONKEY721_PUBLIC_MINT_SYMBOL,
        env.MONKEY721_PUBLIC_MINT_DEFAULT_RECEIVER_ROYALTY,
        env.MONKEY721_PUBLIC_MINT_DEFAULT_PERCENTAGE_ROYALTY,
    ]);
    verifyArguments.monkey721PublicMint = monkey721PublicMint.address;
    verifyArguments.monkey721PublicMintVerify = monkey721PublicMint.addressVerify;

    const monkey1155PublicMint = await deployProxyAndLogger(contractFactories.Monkey1155PublicMint, [
        env.MONKEY1155_PUBLIC_MINT_CONTRACT_URI,
        env.MONKEY1155_PUBLIC_MINT_NAME,
        env.MONKEY1155_PUBLIC_MINT_SYMBOL,
        env.MONKEY1155_PUBLIC_MINT_DEFAULT_RECEIVER_ROYALTY,
        env.MONKEY1155_PUBLIC_MINT_DEFAULT_PERCENTAGE_ROYALTY,
    ]);
    verifyArguments.monkey1155PublicMint = monkey1155PublicMint.address;
    verifyArguments.monkey1155PublicMintVerify = monkey1155PublicMint.addressVerify;

    console.log(underline);
    console.log("DONE");
    console.log(underline);

    const dir = `./deploy-history/${network.chainId}-${networkName}/`;
    const fileName = network.chainId === 31337 ? "hardhat" : blockTimeNow;
    if (!fs.existsSync(dir)) fs.mkdirSync(dir, { recursive: true });
    await fs.writeFileSync("contracts.json", JSON.stringify(verifyArguments));
    await fs.writeFileSync(`${dir}/${fileName}.json`, JSON.stringify(verifyArguments));
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });
