// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import {IBeacon} from "./interface/IBeacon.sol";

contract Beacon is IBeacon {
    address internal _impl;

    function update(address newImpl) external {
        _impl = newImpl;
    }

    function implementation() external view returns (address) {
        return _impl;
    }
}
