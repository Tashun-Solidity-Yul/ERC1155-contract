const {ethers} = require('hardhat');
const hre = require('hardhat');
const {expect} = require('chai');
describe('GameContractMint startMintingToken function tests', () => {
	const user1 = 1;
	const user2 = 2;
	const user3 = 3;

	let baseContract = null;
	let accounts = null;
	let provider = null;
	const INTERFACE_ID_ERC165 = 0x01ffc9a7;
	const INTERFACE_ID_ERC165_FALSE = 0x01ffc9a8;
	beforeEach(async () => {
		accounts = await ethers.getSigners();
		const baseContractFactory = await hre.ethers.getContractFactory('ERC1155BaseContract');
		baseContract = await baseContractFactory.connect(accounts[user1]).deploy();
		await baseContract.deployed();
		provider = await ethers.provider;

	});

	it('true supportsInterface', async () => {
		const bool = await baseContract.connect(accounts[user1]).supportsInterface(INTERFACE_ID_ERC165);
		expect(bool).to.be.equal(true);
	});

	it('false supportsInterface', async () => {
		const bool = await baseContract.connect(accounts[user1]).supportsInterface(INTERFACE_ID_ERC165_FALSE);
		expect(bool).to.be.equal(false);
	});
	it('Set invalid token, by overriding', async () => {
		await baseContract.connect(accounts[user1]).setNewToken(0,"Test");
		await expect(baseContract.connect(accounts[user1]).setNewToken(0,"Test1")).to.be.revertedWithCustomError(baseContract,'InvalidToken')
	});

});