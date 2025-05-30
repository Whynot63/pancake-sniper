import { expect } from "chai";
import { ethers } from "hardhat";
import { reset, setBalance } from "@nomicfoundation/hardhat-toolbox/network-helpers";


describe("PancakeSniper", function () {
    specify("buy", async function () {
        await reset("https://1rpc.io/bnb", 50599588)

        const token = await ethers.getContractAt("IERC20", "0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56")
        const buyAmount = ethers.parseUnits("1", 18)

        const sniper = await ethers.deployContract(
            "PancakeSniper",
            ["0x10ED43C718714eb63d5aA57B78B54704E256024E", "0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c"]
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
});