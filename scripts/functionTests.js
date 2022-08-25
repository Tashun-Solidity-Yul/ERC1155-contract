import { Observable } from 'rxjs';
const contractAddress = "0x9fE46736679d2D9a65F0992F2272dE9f3c7fa6e0";


const hre = require("hardhat");

async function main() {
    const contract = await hre.ethers.getContractAt("ERC1155Contract", contractAddress);
    const [_, randomPerson] = await hre.ethers.getSigners();

    await contract.deployed();
    const options = {value: hre.ethers.utils.parseEther("1.0")}
    await contract.connect(randomPerson).startMintingToken(0, 10);
    console.log(await contract.connect(randomPerson).balanceOf(randomPerson.address, 0));
    console.log(await contract.connect(randomPerson).getAllTokenBalances(randomPerson.address));
    // ERC1155Contract.connect(randomPerson).startMintingToken(0, 10, options);

}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.

function buyToken(contract, user, tokenId, amount) {
    return;
}

function getBalance(contract, user, tokenId, amount, options) {
    return
}

function buyToken1(contract, user, tokenId, amount, options) {
    return contract.startMintingToken(tokenId, amount, options);
}

function getBalance1(contract, user, tokenId, amount, options) {
    return contract.balanceOf(user, tokenId);
}

main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});
