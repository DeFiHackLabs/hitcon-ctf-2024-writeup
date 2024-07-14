// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

interface ISetup {
    function beacon() external returns (address);

    function channel() external returns (address);

    function protocol() external returns (address);

    function alice() external returns (address);

    function bob() external returns (address);

    function david() external returns (address);

    function commitPuzzle(int256) external;

    function isSolved() external view returns (bool);
}
