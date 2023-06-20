const { run } = require("hardhat");
const contracts = require("../contracts.json");

async function main() {
    const jobs = [
        run("verify:verify", {
            address: contracts.monkey721Library,
        }),
        run("verify:verify", {
            address: contracts.monkey1155Library,
        }),
        run("verify:verify", {
            address: contracts.nftFactoryVerify,
        }),
        run("verify:verify", {
            address: contracts.monkey721PublicMintVerify,
        }),
        run("verify:verify", {
            address: contracts.monkey1155PublicMintVerify,
        }),
    ];

    await Promise.all(jobs.map((job) => job.catch(console.log)));
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });
