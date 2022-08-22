const contractAddress = "0x5FbDB2315678afecb367f032d93F642f64180aa3";


const hre = require("hardhat");

async function main() {
    const ERC1155Contract = await hre.ethers.getContractFactory("ERC1155Contract");
    const contract = await ERC1155Contract.deploy();
    const [_, randomPerson] = await hre.ethers.getSigners();

    await contract.deployed();
    const options = {value: hre.ethers.utils.parseEther("1.0")}
    await contract.connect(randomPerson).startMintingToken(0, 10);
    console.log(await contract.connect(randomPerson).balanceOf(randomPerson.address, 0));
    // ERC1155Contract.connect(randomPerson).startMintingToken(0, 10, options);

}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.

function buyToken(contract, user, tokenId, amount) {
    return ;
}
function getBalance(contract, user, tokenId, amount, options){
    return
}

function buyToken1(contract, user, tokenId, amount, options) {
    return contract.startMintingToken(tokenId, amount, options);
}
function getBalance1(contract, user, tokenId, amount, options){
    return contract.balanceOf(user, tokenId);
}

main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});
