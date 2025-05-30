// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import {PancakeRouter} from "./interfaces/PancakeRouter.sol";

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
        router.swapETHForExactTokens{value: tokenBuyAmount}(
            tokenBuyAmount,
            path,
            address(this),
            block.timestamp
        );

        router.addLiquidityETH{value: wNativeLiquidityAmount}(
            token,
            tokenBuyAmount,
            0,
            0,
            msg.sender,
            block.timestamp
        );
    }

    receive() external payable {}
}
