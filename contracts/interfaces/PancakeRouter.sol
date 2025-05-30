// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

interface PancakeRouter {
    function swapETHForExactTokens(
        uint amountOut,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable returns (uint[] memory amounts);
}
