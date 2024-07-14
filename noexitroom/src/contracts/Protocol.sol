// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import {IProtocol} from "./interface/IProtocol.sol";

contract Protocol is IProtocol {
    function evaluate(int256[] memory polynomial, int256 x) external pure returns (int256 ret) {
        int256 power = 1;
        for (uint256 i; i < polynomial.length;) {
            ret += power * polynomial[i];
            power *= x;
            unchecked {
                i += 1;
            }
        }
    }

    function evaluateLagrange(int256[] memory xValues, int256[] memory yValues, int256 x)
        external
        pure
        returns (int256 ret)
    {
        for (uint256 i = 0; i < yValues.length;) {
            ret = ret + _calculateBasisPolynomial(i, x, xValues) * yValues[i];
            unchecked {
                i += 1;
            }
        }
    }

    function _calculateBasisPolynomial(uint256 index, int256 x, int256[] memory xValues)
        internal
        pure
        returns (int256)
    {
        int256 result = 1;
        uint256 j;
        // mult
        for (j = 0; j < xValues.length;) {
            if (j != index) {
                result = result * (x - xValues[j]);
            }
            unchecked {
                j += 1;
            }
        }
        // div
        for (j = 0; j < xValues.length;) {
            if (j != index) {
                result = result / (xValues[index] - xValues[j]);
            }
            unchecked {
                j += 1;
            }
        }

        return result;
    }
}
