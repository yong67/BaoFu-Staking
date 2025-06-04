require("@nomicfoundation/hardhat-toolbox");
require("@nomicfoundation/hardhat-verify");
require("dotenv").config();

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity: {
    version: "0.8.20",
    settings: {
      optimizer: {
        enabled: true,
        runs: 200
      }
    }
  },
  networks: {
    hardhat: {
      forking: {
        url: process.env.RPC_URL,
      },
      hardfork: "cancun"
    },
    testnet: {
      url: process.env.RPC_URL,
      accounts: [process.env.PRIVATE_KEY],
      chainId: 97
    },
    bscTestnet: {
      url: process.env.RPC_URL,
      chainId: 97,
      accounts: [process.env.PRIVATE_KEY],
      gasPrice: 20000000000,
    }
  },
  etherscan: {
    apiKey: {
      bsc: process.env.BSC_SCAN_API_KEY,
      bscTestnet: process.env.BSC_SCAN_API_KEY
    },
    customChains: [
      {
        network: "bscTestnet",
        chainId: 97,
        urls: {
          apiURL: "https://api-testnet.bscscan.com/api",
          browserURL: "https://testnet.bscscan.com"
        }
      }
    ]
  },
  mocha: {
    timeout: 120000 // 120 seconds
  }
};
