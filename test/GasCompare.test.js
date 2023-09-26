const { ethers } = require("hardhat");
const { expect } = require("chai");
const { ZERO_ADDRESS } = require("@openzeppelin/test-helpers/src/constants");

describe("ERC721A", () => {
    before(async () => {
        //** Get Wallets */
        const accounts = await ethers.getSigners();
        [user1, user2] = accounts;

        //** Get contracts deployed  */
        const Test721A = await ethers.getContractFactory("Test721A");
        erc721a = await Test721A.deploy();

        const Test721 = await ethers.getContractFactory("Test721");
        erc721 = await Test721.deploy();

        const Test721AutoIncrementId = await ethers.getContractFactory("Test721AutoIncrementId");
        erc721AutoIncrementId = await Test721AutoIncrementId.deploy();

        const Test721Enumerable = await ethers.getContractFactory("Test721Enumerable");
        erc721Enumerable = await Test721Enumerable.deploy();

        tokenId = 0;
    });

    describe("Compare Gas Mint", () => {
        it("mint 721a", async () => {
            await Promise.all(Array(3).fill().map(async () => {
                let tx = await erc721a.connect(user1).mint(user1.address, 1);
                tx = await tx.wait();
                console.log('tx.gasUsed :>> ', tx.gasUsed.toString());
            }))
        });

        it("safeMint 721a", async () => {
            await Promise.all(Array(3).fill().map(async () => {
                let tx = await erc721a.connect(user1).safeMint(user1.address, 1);
                tx = await tx.wait();
                console.log('tx.gasUsed :>> ', tx.gasUsed.toString());
            }))
        });

        it("mint 721", async () => {
            await Promise.all(Array(3).fill().map(async () => {
                let tx = await erc721.connect(user1).mint(user1.address, ++tokenId);
                tx = await tx.wait();
                console.log('tx.gasUsed :>> ', tx.gasUsed.toString());
            }))
        });

        it("safeMint 721", async () => {
            await Promise.all(Array(3).fill().map(async () => {
                let tx = await erc721.connect(user1).safeMint(user1.address, ++tokenId);
                tx = await tx.wait();
                console.log('tx.gasUsed :>> ', tx.gasUsed.toString());
            }))
        });

        it("mint 721AutoIncrementId", async () => {
            await Promise.all(Array(3).fill().map(async () => {
                let tx = await erc721AutoIncrementId.connect(user1).mint(user1.address);
                tx = await tx.wait();
                console.log('tx.gasUsed :>> ', tx.gasUsed.toString());
            }))
        });

        it("safeMint 721AutoIncrementId", async () => {
            await Promise.all(Array(3).fill().map(async () => {
                let tx = await erc721AutoIncrementId.connect(user1).safeMint(user1.address);
                tx = await tx.wait();
                console.log('tx.gasUsed :>> ', tx.gasUsed.toString());
            }))
        });

        it("mint 721Enumerable", async () => {
            await Promise.all(Array(3).fill().map(async () => {
                let tx = await erc721Enumerable.connect(user1).mint(user1.address);
                tx = await tx.wait();
                console.log('tx.gasUsed :>> ', tx.gasUsed.toString());
            }))
        });

        it("safeMint 721Enumerable", async () => {
            await Promise.all(Array(3).fill().map(async () => {
                let tx = await erc721Enumerable.connect(user1).safeMint(user1.address);
                tx = await tx.wait();
                console.log('tx.gasUsed :>> ', tx.gasUsed.toString());
            }))
        });
    });
});
