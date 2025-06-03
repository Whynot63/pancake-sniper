import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";

const config: HardhatUserConfig = {
  solidity: "0.8.28",
  networks: {
    bsc: {
      url: "https://1rpc.io/bnb",
      chainId: 56,
      accounts: process.env.DEPLOYER ? [process.env.DEPLOYER] : []
    },
  }
};

export default config;
