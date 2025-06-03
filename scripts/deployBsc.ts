import { ethers, network } from "hardhat";

const BSC_WNATIVE = "0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c"
const BSC_FACTORY = "0xcA143Ce32Fe78f1f7019d7d551a6402fC5350c73"


async function main() {
    if (network.config.chainId !== 56) {
        console.log("Only for BNB Smart Chain Mainnet (chain id = 56)")
        return;
    }

    const pancakeSniper = await ethers.deployContract(
        "PancakeSniper",
        [BSC_FACTORY, BSC_WNATIVE]
    );
    console.log(`PancakeSniper: ${await pancakeSniper.getAddress()}`)
}



main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});
