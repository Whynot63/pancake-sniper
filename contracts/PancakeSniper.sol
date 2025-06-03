// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {PancakeLibrary} from "./PancakeLibrary.sol";
import {IWNative} from "./interfaces/IWNative.sol";
import {IPancakePair} from "./interfaces/IPancakePair.sol";

contract PancakeSniper {
    address immutable factory;
    address immutable wNative;

    constructor(address factory_, address wNative_) {
        factory = factory_;
        wNative = wNative_;
    }

    function buy(
        address token,
        uint256 amountOut
    ) external payable returns (uint256 amountIn) {
        address pair = PancakeLibrary.pairFor(factory, wNative, token);
        (uint256 rNative, uint256 rToken) = PancakeLibrary.getReserves(
            factory,
            wNative,
            token
        );
        amountIn = PancakeLibrary.getAmountIn(amountOut, rNative, rToken);
        IWNative(wNative).deposit{value: amountIn}();
        IWNative(wNative).transfer(pair, amountIn);

        (uint amount0Out, uint amount1Out) = wNative < token
            ? (uint(0), amountOut)
            : (amountOut, uint(0));
        IPancakePair(pair).swap(amount0Out, amount1Out, msg.sender, bytes(""));
        if (msg.value > amountIn) {
            payable(msg.sender).call{value: msg.value - amountIn}("");
        }
    }

    function buyAndLiquidity(
        address token,
        uint256 amountOut
    ) external payable returns (uint256 amountIn) {
        // preparations
        address pair = PancakeLibrary.pairFor(factory, wNative, token);
        IWNative(wNative).deposit{value: msg.value}();

        // swap
        (uint256 rNative, uint256 rToken) = PancakeLibrary.getReserves(
            factory,
            wNative,
            token
        );
        amountIn = PancakeLibrary.getAmountIn(amountOut, rNative, rToken);
        (uint amount0Out, uint amount1Out) = wNative < token
            ? (uint(0), amountOut)
            : (amountOut, uint(0));
        IWNative(wNative).transfer(pair, amountIn);
        IPancakePair(pair).swap(
            amount0Out,
            amount1Out,
            address(this),
            bytes("")
        );
        rNative += amountIn;
        rToken -= amountOut;

        // liquidity math
        uint256 liquidityTokenAmount = PancakeLibrary.quote(
            msg.value - amountIn,
            rNative,
            rToken
        );
        uint256 liquidityWnativeAmount = PancakeLibrary.quote(
            amountOut,
            rToken,
            rNative
        );
        if (liquidityTokenAmount <= amountOut) {
            IWNative(wNative).transfer(pair, msg.value - amountIn);
            IERC20(token).transfer(pair, liquidityTokenAmount);
            IERC20(token).transfer(
                msg.sender,
                amountOut - liquidityTokenAmount
            );
        } else {
            IERC20(token).transfer(pair, amountOut);
            IWNative(wNative).transfer(pair, liquidityWnativeAmount);
            IWNative(wNative).withdraw(msg.value - liquidityWnativeAmount);
            payable(msg.sender).call{value: msg.value - liquidityWnativeAmount}(
                ""
            );
        }

        IPancakePair(pair).mint(msg.sender);
    }
}
