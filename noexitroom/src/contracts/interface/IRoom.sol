// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

interface IRoom {
    function historyRequests(int256) external view returns (int256);

    function isHacked() external view returns (bool);

    function isSolved() external view returns (bool);

    function request(address, int256) external;

    function onRequest(int256) external returns (int256);

    function selfRequest(int256) external returns (int256);

    function solveRoomPuzzle(int256[] calldata) external;

    function hack(int256 x, bool) external;
}
