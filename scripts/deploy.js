// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// You can also run a script with `npx hardhat run <script>`. If you do that, Hardhat
// will compile your contracts, add the Hardhat Runtime Environment's members to the
// global scope, and execute the script.
const hre = require('hardhat');

async function main() {
	// const baseContractFactory = await hre.ethers.getContractFactory('ERC1155BaseContract');
	// const baseContract = await baseContractFactory.deploy();
	//
	// await baseContract.deployed();
	const baseContract = await hre.ethers.getContractAt('ERC1155BaseContract', "0xb702A91f95C045e1850AAF4B4bd2a8F1B163b359");
	const gameContract = await hre.ethers.getContractAt('ERC1155BaseContract', "0x41d3cc91c36bb3a57387efc7a5a21c50952d9ffb");
	// console.log(baseContract.address);
	// const gameContractFactory = await hre.ethers.getContractFactory('GameContract');
	//
	// const gas =gameContractFactory.estimateGas.deploy(baseContract.address);
	// console.log(gas)
	// const gameContract = await gameContractFactory.deploy(baseContract.address, {gasLimit: 2100000});
	// await gameContract.deployed();
	const adminRole = await baseContract.ADMIN_ROLE();

	await baseContract.grantRole(adminRole, gameContract.address);
	await gameContract.setInitialTokenURI();
	//
	console.log(gameContract.address)

}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
	console.error(error);
	process.exitCode = 1;
});
