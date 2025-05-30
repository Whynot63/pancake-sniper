// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import {PancakeRouter} from "./interfaces/PancakeRouter.sol";

contract PancakeSniper {
    address immutable wBNB;
    PancakeRouter immutable router;

    constructor(address router_, address wBNB_) {
        router = PancakeRouter(router_);
        wBNB = wBNB_;
    }

    function buy(address token, uint256 amountOut) external payable {
        address[] memory path = new address[](2);
        path[0] = wBNB;
        path[1] = token;
        router.swapETHForExactTokens(
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

    receive() external payable {}
}
