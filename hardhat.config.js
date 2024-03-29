require("@nomicfoundation/hardhat-toolbox");
require("dotenv").config();
require('solidity-coverage');

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  defaultNetwork: "hardhat",
  networks: {
    hardhat: {
    },
    localhost: {
      url: "http://127.0.0.1:8545"
    },
    // matic: {
    //   url: "https://rpc-mumbai.maticvigil.com",
    //   accounts: [process.env.PRIVATE_KEY],
    //   gas: 2100000
    // },
    // mumbai: {
    //   url: process.env.STAGING_ALCHEMY_KEY,
    //   accounts: process.env.PRIVATE_KEY !== undefined ? [process.env.PRIVATE_KEY] : [],
    //   gas: 2100000,
    //   gasPrice: 8000000000
    // },

  },
  etherscan: {
    apiKey: process.env.POLYGONSCAN_API_KEY
  },
  solidity: {
    version: "0.8.13",
    // settings: {
    //   optimizer: {
    //     enabled: true,
    //     runs: 200
    //   }
    // }
  },
};
