// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

interface IChannel {
    function open(address, address) external;

    function record(address a, address b, int256 x) external;

    function isSenderLocked(address) external view returns (bool);

    function isChannelExist(address, address) external view returns (bool);
}
