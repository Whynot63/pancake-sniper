import { expect } from "chai";
import { ethers } from "hardhat";
import { reset, setBalance } from "@nomicfoundation/hardhat-toolbox/network-helpers";

const BSC_WNATIVE = "0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c"
const BSC_FACTORY = "0xcA143Ce32Fe78f1f7019d7d551a6402fC5350c73"

describe("PancakeSniper", function () {
    specify("buy", async function () {
        await reset("https://1rpc.io/bnb", 50599588)

        const token = await ethers.getContractAt("IERC20", "0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56")
        const buyAmount = ethers.parseUnits("1", 18)

        const sniper = await ethers.deployContract(
            "PancakeSniper",
            [BSC_FACTORY, BSC_WNATIVE]
        )
        const [executor] = await ethers.getSigners()
        await setBalance(executor.address, ethers.parseEther("100"))

        await expect(sniper.connect(executor).buy(
            token.target,
            buyAmount,
            { value: ethers.parseEther("50") }
        )).to.changeTokenBalance(
            token,
            executor.address,
            buyAmount,
        )
    })

    specify("buyAndLiquify", async function () {
        await reset("https://1rpc.io/bnb", 50599588)

        const token = await ethers.getContractAt("IERC20", "0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56")
        const buyAmount = ethers.parseUnits("660", 18)

        const sniper = await ethers.deployContract(
            "PancakeSniper",
            [BSC_FACTORY, BSC_WNATIVE]
        )
        const [executor] = await ethers.getSigners()
        await setBalance(executor.address, ethers.parseEther("100"))

        await expect(sniper.connect(executor).buy(
            token.target,
            buyAmount,
            { value: ethers.parseEther("2") }
        )).to.changeTokenBalance(
            token,
            executor.address,
            buyAmount,
        )
    })

});