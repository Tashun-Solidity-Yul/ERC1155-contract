const {expect} = require('chai');
const {ethers} = require('hardhat');
const hre = require('hardhat');
const {BigNumber} = ethers;


describe('GameContractMint startMintingToken function tests', () => {
	const user1 = 1;
	const user2 = 2;
	const user3 = 3;

	let baseContract = null;
	let gameContract = null;
	let accounts = null;
	let provider = null;
	beforeEach(async () => {
		accounts = await ethers.getSigners();
		const baseContractFactory = await hre.ethers.getContractFactory('ERC1155BaseContract');
		baseContract = await baseContractFactory.connect(accounts[user1]).deploy();
		await baseContract.deployed();
		const gameContractFactory = await hre.ethers.getContractFactory('GameContract');
		gameContract = await gameContractFactory.connect(accounts[user1]).deploy(baseContract.address);
		await gameContract.deployed();

		const adminRole = await baseContract.connect(accounts[user1]).ADMIN_ROLE();
		await baseContract.connect(accounts[user1]).grantRole(adminRole, gameContract.address);

		await gameContract.connect(accounts[user1]).setInitialTokenURI();
		provider = await ethers.provider;

	});

	it('Mint Token Zero with no payment', async () => {
		await gameContract.connect(accounts[user2]).startMintingToken(0 , 100);
		expect(await gameContract.balanceOf(accounts[user2].address, 0)).to.be.equal(100);
	});

	it('Mint Token Zero with no payment 0 amount', async () => {
		await expect(gameContract.connect(accounts[user2]).startMintingToken(0 , 0)).to.be.revertedWithCustomError(gameContract,'TokenAmountCanNotBeZero');
	});

	it('Mint Token 9 with no payment 100 amount', async () => {
		await expect(gameContract.connect(accounts[user2]).startMintingToken(9 , 100)).to.be.revertedWithCustomError(gameContract,'TokenDoesNotExist');
	});



	it('Forge Token Three Full balances Forge', async () => {
		await gameContract.connect(accounts[user2]).startMintingToken(0 , 100);
		expect(await gameContract.balanceOf(accounts[user2].address, 0)).to.be.equal(100);

		await provider.send('evm_increaseTime', [60 +1]);

		await gameContract.connect(accounts[user2]).startMintingToken(1 , 100);
		expect(await gameContract.balanceOf(accounts[user2].address, 1)).to.be.equal(100);

		await provider.send('evm_increaseTime', [60 +1]);

		const payment = hre.ethers.utils.parseEther('1');

		await gameContract.connect(accounts[user2]).startMintingToken(3 , 100, {value: payment});
		expect(await gameContract.balanceOf(accounts[user2].address, 3)).to.be.equal(100);
		expect(await gameContract.balanceOf(accounts[user2].address, 0)).to.be.equal(0);
		expect(await gameContract.balanceOf(accounts[user2].address, 1)).to.be.equal(0);
	});

	it('Forge Token Three partial balances forge', async () => {
		await gameContract.connect(accounts[user2]).startMintingToken(0 , 100);
		expect(await gameContract.balanceOf(accounts[user2].address, 0)).to.be.equal(100);

		await provider.send('evm_increaseTime', [60 +1]);

		await gameContract.connect(accounts[user2]).startMintingToken(1 , 100);
		expect(await gameContract.balanceOf(accounts[user2].address, 1)).to.be.equal(100);

		await provider.send('evm_increaseTime', [60 +1]);

		const payment = hre.ethers.utils.parseEther('1');

		await gameContract.connect(accounts[user2]).startMintingToken(3 , 50, {value: payment});
		expect(await gameContract.balanceOf(accounts[user2].address, 3)).to.be.equal(50);
		expect(await gameContract.balanceOf(accounts[user2].address, 0)).to.be.equal(50);
		expect(await gameContract.balanceOf(accounts[user2].address, 1)).to.be.equal(50);
	});
	it('Forge Token six partial balances forge', async () => {
		await gameContract.connect(accounts[user2]).startMintingToken(0 , 100);
		expect(await gameContract.balanceOf(accounts[user2].address, 0)).to.be.equal(100);

		await provider.send('evm_increaseTime', [60 +1]);

		await gameContract.connect(accounts[user2]).startMintingToken(1 , 100);
		expect(await gameContract.balanceOf(accounts[user2].address, 1)).to.be.equal(100);

		await provider.send('evm_increaseTime', [60 +1]);

		await gameContract.connect(accounts[user2]).startMintingToken(2 , 100);
		expect(await gameContract.balanceOf(accounts[user2].address, 2)).to.be.equal(100);

		await provider.send('evm_increaseTime', [60 +1]);

		const payment = hre.ethers.utils.parseEther('1');

		await gameContract.connect(accounts[user2]).startMintingToken(6 , 50, {value: payment});
		expect(await gameContract.balanceOf(accounts[user2].address, 6)).to.be.equal(50);
		expect(await gameContract.balanceOf(accounts[user2].address, 0)).to.be.equal(50);
		expect(await gameContract.balanceOf(accounts[user2].address, 1)).to.be.equal(50);
		expect(await gameContract.balanceOf(accounts[user2].address, 2)).to.be.equal(50);
	});

	it('Forge Token Three with No Price reverting with InSufficientMatic', async () => {
		await gameContract.connect(accounts[user2]).startMintingToken(0 , 100);
		expect(await gameContract.balanceOf(accounts[user2].address, 0)).to.be.equal(100);

		await provider.send('evm_increaseTime', [60 +1]);

		await gameContract.connect(accounts[user2]).startMintingToken(1 , 100);
		expect(await gameContract.balanceOf(accounts[user2].address, 1)).to.be.equal(100);

		await provider.send('evm_increaseTime', [60 +1]);



		await expect(gameContract.connect(accounts[user2]).startMintingToken(3 , 100)).to.be.revertedWithCustomError(gameContract,'InSufficientMatic');
	});

	it('Forge Token Three with less matic reverting with InSufficientMatic', async () => {
		await gameContract.connect(accounts[user2]).startMintingToken(0 , 100);
		expect(await gameContract.balanceOf(accounts[user2].address, 0)).to.be.equal(100);

		await provider.send('evm_increaseTime', [60 +1]);

		await gameContract.connect(accounts[user2]).startMintingToken(1 , 100);
		expect(await gameContract.balanceOf(accounts[user2].address, 1)).to.be.equal(100);

		await provider.send('evm_increaseTime', [60 +1]);

		const payment = hre.ethers.utils.parseEther('0.000001');

		await expect(gameContract.connect(accounts[user2]).startMintingToken(3 , 100,{value: payment})).to.be.revertedWithCustomError(gameContract,'InSufficientMatic');
	});

	it('Forge Token Three with No Price', async () => {
		await gameContract.connect(accounts[user2]).startMintingToken(0 , 100);
		expect(await gameContract.balanceOf(accounts[user2].address, 0)).to.be.equal(100);


		await expect( gameContract.connect(accounts[user2]).startMintingToken(1 , 100)).to.be.revertedWithCustomError( gameContract,'MintingTooFast');

	});


	it('Forge Token Three with No Price No Token 0 Minting Token 3', async () => {
		await gameContract.connect(accounts[user2]).startMintingToken(0 , 100);

		await provider.send('evm_increaseTime', [60 +1]);

		await expect( gameContract.connect(accounts[user2]).startMintingToken(3 , 1000)).to.be.revertedWith( 'Missing a Token Zero');

	});
	it('Forge Token Three with No Price Not enough Token 1 Minting Token 3', async () => {
		await gameContract.connect(accounts[user2]).startMintingToken(0 , 1000);
		await provider.send('evm_increaseTime', [60 +1]);

		await gameContract.connect(accounts[user2]).startMintingToken(1 , 900);
		await provider.send('evm_increaseTime', [60 +1]);

		await expect( gameContract.connect(accounts[user2]).startMintingToken(3 , 1000)).to.be.revertedWith( 'Missing a Token One');

	});


	it('Forge Token Three with No Price No Token 1 Minting Token 4', async () => {
		await gameContract.connect(accounts[user2]).startMintingToken(1 , 100);

		await provider.send('evm_increaseTime', [60 +1]);

		await expect( gameContract.connect(accounts[user2]).startMintingToken(4 , 1000)).to.be.revertedWith( 'Missing a Token One');

	});
	it('Forge Token Three with No Price Not enough Token 2 Minting Token 4', async () => {
		await gameContract.connect(accounts[user2]).startMintingToken(1 , 1000);
		await provider.send('evm_increaseTime', [60 +1]);

		await gameContract.connect(accounts[user2]).startMintingToken(2 , 900);
		await provider.send('evm_increaseTime', [60 +1]);

		await expect( gameContract.connect(accounts[user2]).startMintingToken(4 , 1000)).to.be.revertedWith( 'Missing a Token Two');

	});

	it('Forge Token Three with No Price No Token 0 Minting Token 5', async () => {
		await gameContract.connect(accounts[user2]).startMintingToken(0 , 100);

		await provider.send('evm_increaseTime', [60 +1]);

		await expect( gameContract.connect(accounts[user2]).startMintingToken(5 , 1000)).to.be.revertedWith( 'Missing a Token Zero');

	});
	it('Forge Token Three with No Price Not enough Token 2 Minting Token 5', async () => {
		await gameContract.connect(accounts[user2]).startMintingToken(0 , 1000);
		await provider.send('evm_increaseTime', [60 +1]);

		await gameContract.connect(accounts[user2]).startMintingToken(2 , 900);
		await provider.send('evm_increaseTime', [60 +1]);

		await expect( gameContract.connect(accounts[user2]).startMintingToken(5 , 1000)).to.be.revertedWith( 'Missing a Token Two');

	});
	it('Forge Token Three with No Price No Token 0 Minting Token 6', async () => {
		await gameContract.connect(accounts[user2]).startMintingToken(0 , 100);

		await provider.send('evm_increaseTime', [60 +1]);

		await expect( gameContract.connect(accounts[user2]).startMintingToken(6 , 1000)).to.be.revertedWith( 'Missing a Token Zero');

	});
	it('Forge Token Three with No Price Not enough Token 1 Minting Token 6', async () => {
		await gameContract.connect(accounts[user2]).startMintingToken(0 , 1000);
		await provider.send('evm_increaseTime', [60 +1]);

		await gameContract.connect(accounts[user2]).startMintingToken(1 , 900);
		await provider.send('evm_increaseTime', [60 +1]);

		await expect( gameContract.connect(accounts[user2]).startMintingToken(6 , 1000)).to.be.revertedWith( 'Missing a Token One');

	});
	it('Forge Token Three with No Price Not enough Token 2 Minting Token 6', async () => {
		await gameContract.connect(accounts[user2]).startMintingToken(0 , 1000);
		await provider.send('evm_increaseTime', [60 +1]);

		await gameContract.connect(accounts[user2]).startMintingToken(1 , 1000);
		await provider.send('evm_increaseTime', [60 +1]);

		await gameContract.connect(accounts[user2]).startMintingToken(2 , 900);
		await provider.send('evm_increaseTime', [60 +1]);

		await expect( gameContract.connect(accounts[user2]).startMintingToken(6 , 1000)).to.be.revertedWith( 'Missing a Token Two');

	});
	it('Forge 6 and check on a different user', async () => {
		await gameContract.connect(accounts[user2]).startMintingToken(0 , 1000);
		await provider.send('evm_increaseTime', [60 +1]);

		await gameContract.connect(accounts[user2]).startMintingToken(1 , 1000);
		await provider.send('evm_increaseTime', [60 +1]);

		await gameContract.connect(accounts[user2]).startMintingToken(2 , 900);
		await provider.send('evm_increaseTime', [60 +1]);

		await expect( gameContract.connect(accounts[user2]).startMintingToken(6 , 1000)).to.be.revertedWith( 'Missing a Token Two');
		expect(await gameContract.balanceOf(accounts[user3].address, 6)).to.be.equal(0);

	});

	it('try Forge 6 with insufficient token', async () => {
		await gameContract.connect(accounts[user2]).startMintingToken(0 , 1000);
		await provider.send('evm_increaseTime', [60 +1]);

		await gameContract.connect(accounts[user2]).startMintingToken(1 , 1000);
		await provider.send('evm_increaseTime', [60 +1]);

		await gameContract.connect(accounts[user2]).startMintingToken(2 , 900);
		await provider.send('evm_increaseTime', [60 +1]);

		await expect( gameContract.connect(accounts[user2]).startMintingToken(6 , 1000)).to.be.revertedWith( 'Missing a Token Two');
		expect(await gameContract.balanceOf(accounts[user3].address, 6)).to.be.equal(0);

	});
});



describe('GameContractMint startBurningToken function tests', () => {
	const user1 = 1;
	const user2 = 2;

	let baseContract = null;
	let gameContract = null;
	let accounts = null;
	let provider = null;
	beforeEach(async () => {
		accounts = await ethers.getSigners();
		const baseContractFactory = await hre.ethers.getContractFactory('ERC1155BaseContract');
		baseContract = await baseContractFactory.connect(accounts[user1]).deploy();
		await baseContract.deployed();
		const gameContractFactory = await hre.ethers.getContractFactory('GameContract');
		gameContract = await gameContractFactory.connect(accounts[user1]).deploy(baseContract.address);
		await gameContract.deployed();

		const adminRole = await baseContract.connect(accounts[user1]).ADMIN_ROLE();
		await baseContract.connect(accounts[user1]).grantRole(adminRole, gameContract.address);

		await gameContract.connect(accounts[user1]).setInitialTokenURI();

		await gameContract.connect(accounts[user2]).startMintingToken(0 , 1000);
		provider = await ethers.provider;
		await provider.send('evm_increaseTime', [60 +1]);
		await gameContract.connect(accounts[user2]).startMintingToken(1 , 1000);
		await provider.send('evm_increaseTime', [60 +1]);
		await gameContract.connect(accounts[user2]).startMintingToken(2 , 1000);
		await provider.send('evm_increaseTime', [60 +1]);
		const payment = hre.ethers.utils.parseEther('1');
		await gameContract.connect(accounts[user2]).startMintingToken(3 , 100, {value: payment});
		await provider.send('evm_increaseTime', [60 +1]);
		await gameContract.connect(accounts[user2]).startMintingToken(4 , 100, {value: payment});
		await provider.send('evm_increaseTime', [60 +1]);
		await gameContract.connect(accounts[user2]).startMintingToken(5 , 100, {value: payment});
		await provider.send('evm_increaseTime', [60 +1]);
		await gameContract.connect(accounts[user2]).startMintingToken(6 , 100, {value: payment});
		await provider.send('evm_increaseTime', [60 +1]);


	});





	it('Forge Burning Token Zero', async () => {
		await expect(gameContract.connect(accounts[user2]).startBurningToken(0 , 10)).to.be.revertedWithCustomError(gameContract,'CanNotBurnThisToken');
	});
	it('Forge Burning Token One', async () => {
		await expect(gameContract.connect(accounts[user2]).startBurningToken(1 , 10)).to.be.revertedWithCustomError(gameContract,'CanNotBurnThisToken');
	});
	it('Forge Burning Token Two', async () => {
		await expect(gameContract.connect(accounts[user2]).startBurningToken(2 , 10)).to.be.revertedWithCustomError(gameContract,'CanNotBurnThisToken');
	});

	it('Forge Burning Token Three', async () => {
		await gameContract.connect(accounts[user2]).startBurningToken(3 , 50);
		expect(await gameContract.balanceOf(accounts[user2].address, 3)).to.be.equal(50);
	});
	it('Forge Burning Token Four', async () => {
		await gameContract.connect(accounts[user2]).startBurningToken(4 , 50);
		expect(await gameContract.balanceOf(accounts[user2].address, 4)).to.be.equal(50);
	});
	it('Forge Burning Token Five', async () => {
		await gameContract.connect(accounts[user2]).startBurningToken(5 , 50);
		expect(await gameContract.balanceOf(accounts[user2].address, 5)).to.be.equal(50);
	});
	it('Forge Burning Token Six', async () => {
		await gameContract.connect(accounts[user2]).startBurningToken(6 , 50);
		expect(await gameContract.balanceOf(accounts[user2].address, 6)).to.be.equal(50);
	});
	it('Forge Burning Token Six 1000 for revert', async () => {
		await gameContract.connect(accounts[user2]).startBurningToken(6 , 50);
		await expect( gameContract.connect(accounts[user2]).startBurningToken(6 , 1000)).to.be.revertedWithCustomError(gameContract,'InsufficientTokens');
	});

});


describe('GameContractMint startTransferringToken function tests', () => {
	const user1 = 1;
	const user2 = 2;

	let baseContract = null;
	let gameContract = null;
	let accounts = null;
	let provider = null;
	beforeEach(async () => {
		accounts = await ethers.getSigners();
		const baseContractFactory = await hre.ethers.getContractFactory('ERC1155BaseContract');
		baseContract = await baseContractFactory.connect(accounts[user1]).deploy();
		await baseContract.deployed();
		const gameContractFactory = await hre.ethers.getContractFactory('GameContract');
		gameContract = await gameContractFactory.connect(accounts[user1]).deploy(baseContract.address);
		await gameContract.deployed();

		const adminRole = await baseContract.connect(accounts[user1]).ADMIN_ROLE();
		await baseContract.connect(accounts[user1]).grantRole(adminRole, gameContract.address);

		await gameContract.connect(accounts[user1]).setInitialTokenURI();

		await gameContract.connect(accounts[user2]).startMintingToken(0 , 1000);
		provider = await ethers.provider;
		await provider.send('evm_increaseTime', [60 +1]);
		await gameContract.connect(accounts[user2]).startMintingToken(1 , 1000);
		await provider.send('evm_increaseTime', [60 +1]);
		await gameContract.connect(accounts[user2]).startMintingToken(2 , 1000);
		await provider.send('evm_increaseTime', [60 +1]);
		const payment = hre.ethers.utils.parseEther('1');
		await gameContract.connect(accounts[user2]).startMintingToken(3 , 100, {value: payment});
		await provider.send('evm_increaseTime', [60 +1]);
		await gameContract.connect(accounts[user2]).startMintingToken(4 , 100, {value: payment});
		await provider.send('evm_increaseTime', [60 +1]);
		await gameContract.connect(accounts[user2]).startMintingToken(5 , 100, {value: payment});
		await provider.send('evm_increaseTime', [60 +1]);
		await gameContract.connect(accounts[user2]).startMintingToken(6 , 100, {value: payment});
		await provider.send('evm_increaseTime', [60 +1]);


	});

	it('can not trade for same id', async () => {
		await expect(gameContract.connect(accounts[user2]).startTransferringToken(0 , 0, 10)).to.be.revertedWithCustomError(gameContract,'TokenCanNotBeTradedForEqualTokenId');
	});
	it('can not receive token 3', async () => {
		await expect(gameContract.connect(accounts[user2]).startTransferringToken(0 , 3, 10)).to.be.revertedWithCustomError(gameContract,'CanNotReceiveThisTokenByTrading');
	});
	it('can not receive token 4', async () => {
		await expect(gameContract.connect(accounts[user2]).startTransferringToken(0 , 4, 10)).to.be.revertedWithCustomError(gameContract,'CanNotReceiveThisTokenByTrading');
	});
	it('can not receive token 5', async () => {
		await expect(gameContract.connect(accounts[user2]).startTransferringToken(0 , 5, 10)).to.be.revertedWithCustomError(gameContract,'CanNotReceiveThisTokenByTrading');
	});
	it('can not receive token 6', async () => {
		await expect(gameContract.connect(accounts[user2]).startTransferringToken(0 , 6, 10)).to.be.revertedWithCustomError(gameContract,'CanNotReceiveThisTokenByTrading');
	});
	it('Transfer with insufficient tokens', async () => {
		await expect(gameContract.connect(accounts[user2]).startTransferringToken(1 , 0, 10000)).to.be.revertedWithCustomError(gameContract,'InsufficientTokensToTransfer');
	});
	it('Successful transfer from 6 to 0', async () => {
		const tokenZeroBalance =await gameContract.balanceOf(accounts[user2].address, 0);
		await gameContract.connect(accounts[user2]).startTransferringToken(6 , 0, 50);
		expect(await gameContract.balanceOf(accounts[user2].address, 6)).to.be.equal(50);
		expect(await gameContract.balanceOf(accounts[user2].address, 0)).to.be.equal(tokenZeroBalance.add(new BigNumber.from('50')));
	});
	it('Successful transfer from 5 to 0', async () => {
		const tokenZeroBalance =await gameContract.balanceOf(accounts[user2].address, 0);
		await gameContract.connect(accounts[user2]).startTransferringToken(5 , 0, 50);
		expect(await gameContract.balanceOf(accounts[user2].address, 5)).to.be.equal(50);
		expect(await gameContract.balanceOf(accounts[user2].address, 0)).to.be.equal(tokenZeroBalance.add(new BigNumber.from('50')));
	});
	it('Successful transfer from 4 to 1', async () => {
		const tokenZeroBalance =await gameContract.balanceOf(accounts[user2].address, 1);
		await gameContract.connect(accounts[user2]).startTransferringToken(4 , 1, 50);
		expect(await gameContract.balanceOf(accounts[user2].address, 4)).to.be.equal(50);
		expect(await gameContract.balanceOf(accounts[user2].address, 1)).to.be.equal(tokenZeroBalance.add(new BigNumber.from('50')));
	});
	it('Successful transfer from 3 to 2', async () => {
		const tokenZeroBalance =await gameContract.balanceOf(accounts[user2].address, 2);
		await gameContract.connect(accounts[user2]).startTransferringToken(3 , 2, 50);
		expect(await gameContract.balanceOf(accounts[user2].address, 3)).to.be.equal(50);
		expect(await gameContract.balanceOf(accounts[user2].address, 2)).to.be.equal(tokenZeroBalance.add(new BigNumber.from('50')));
	});
	it('Successful transfer from 2 to 1', async () => {
		const tokenZeroBalance =await gameContract.balanceOf(accounts[user2].address, 1);
		const tokenTwoBalance =await gameContract.balanceOf(accounts[user2].address, 2);
		await gameContract.connect(accounts[user2]).startTransferringToken(2 , 1, 50);
		expect(await gameContract.balanceOf(accounts[user2].address, 2)).to.be.equal(tokenTwoBalance.sub(new BigNumber.from('50')));
		expect(await gameContract.balanceOf(accounts[user2].address, 1)).to.be.equal(tokenZeroBalance.add(new BigNumber.from('50')));
	});


});
