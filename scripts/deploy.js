// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// You can also run a script with `npx hardhat run <script>`. If you do that, Hardhat
// will compile your contracts, add the Hardhat Runtime Environment's members to the
// global scope, and execute the script.
const hre = require('hardhat');
const {ethers} = require('hardhat');

async function main() {
	let accounts = null;
	const user1 = 1;
	const user2 = 2;
	const user3 = 3;
	accounts = await ethers.getSigners();
	const baseContractFactory = await hre.ethers.getContractFactory('ERC1155BaseContract');
	const baseContract = await baseContractFactory.connect(accounts[user1]).deploy();
	await baseContract.deployed();
	const gameContractFactory = await hre.ethers.getContractFactory('GameContract');
	const gameContract = await gameContractFactory.connect(accounts[user1]).deploy(baseContract.address);
	await gameContract.deployed();

	const adminRole = await baseContract.connect(accounts[user1]).ADMIN_ROLE();
	await baseContract.connect(accounts[user1]).grantRole(adminRole, gameContract.address);

	await gameContract.connect(accounts[user1]).setInitialTokenURI();
	const provider = await ethers.provider;

	await gameContract.connect(accounts[user2]).mintTokenAmountById(0, 100);
	await provider.send('evm_increaseTime', [60 + 1]);
	await gameContract.connect(accounts[user2]).mintTokenAmountById(1, 100);
	await provider.send('evm_increaseTime', [60 + 1]);
	await gameContract.connect(accounts[user2]).mintTokenAmountById(2, 100);

	const tnx = await baseContract.connect(accounts[user2]).safeBatchTransferFrom(accounts[user2].address, accounts[user1].address, [0, 1,2], [10, 10,12], 0x00);
	const receipt = await tnx.wait();
	console.log(receipt.events[0].topics);
	console.log(receipt.events[0].data.length);

	for (let i = 0; i < (receipt.events[0].data.length - 2) / 64; i++) {
		console.log(receipt.events[0].data.substring(2 + (i * 64), ((i + 1) * 64) + 2));
	}
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
	console.error(error);
	process.exitCode = 1;
});
