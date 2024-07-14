// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

interface IProtocol {
    function evaluate(int256[] calldata, int256) external pure returns (int256);

    function evaluateLagrange(int256[] memory, int256[] memory, int256) external pure returns (int256);
}
