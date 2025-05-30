// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import {PancakeRouter} from "./interfaces/PancakeRouter.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract PancakeSniper {
    address immutable wNative;
    PancakeRouter immutable router;

    constructor(address router_, address wNative_) {
        router = PancakeRouter(router_);
        wNative = wNative_;
    }

    function buy(address token, uint256 amountOut) external payable {
        address[] memory path = new address[](2);
        path[0] = wNative;
        path[1] = token;
        router.swapETHForExactTokens{value: msg.value}(
            amountOut,
            path,
            msg.sender,
            block.timestamp
        );

        uint256 leftBnb = payable(address(this)).balance;
        if (leftBnb > 0) {
            (bool success, ) = payable(msg.sender).call{value: leftBnb}("");
            require(success);
        }
    }

    function buyAndLiquidity(
        address token,
        uint256 tokenBuyAmount,
        uint256 wNativeLiquidityAmount
    ) external payable {
        address[] memory path = new address[](2);
        path[0] = wNative;
        path[1] = token;
        uint[] memory amounts = router.swapETHForExactTokens{value: msg.value}(
            tokenBuyAmount,
            path,
            address(this),
            block.timestamp
        );

        IERC20(token).approve(address(router), amounts[1]);
        router.addLiquidityETH{value: wNativeLiquidityAmount}(
            token,
            tokenBuyAmount,
            0,
            0,
            msg.sender,
            block.timestamp
        );

        uint256 leftBnb = payable(address(this)).balance;
        if (leftBnb > 0) {
            (bool success, ) = payable(msg.sender).call{value: leftBnb}("");
            require(success);
        }

        uint256 leftToken = IERC20(token).balanceOf(address(this));
        if (leftToken > 0) {
            IERC20(token).transfer(msg.sender, leftToken);
        }
    }

    receive() external payable {}
}
