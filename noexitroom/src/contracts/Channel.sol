// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import {IChannel} from "./interface/IChannel.sol";
import {IRoom} from "./interface/IRoom.sol";
import {Adminable} from "./utils/Adminable.sol";

contract Channel is IChannel, Adminable {
    // check channel exist
    mapping(address => mapping(address => bool)) internal _chan;

    // times
    mapping(address => uint256) internal _times;

    // check channel used
    mapping(address => mapping(address => bool)) internal _limit;

    constructor(address newAdmin) {
        _setAdmin(newAdmin);
    }

    function open(address a, address b) external {
        _onlyAdmin();
        _chan[a][b] = true;
        _chan[b][a] = true;
    }

    function record(address a, address b, int256 x) external {
        // check whether channel is exist
        require(_chan[a][b], "channel not exist");
        // check whether reach the limit
        require(_times[a] < 2, "reach the limit");
        // check whether channel is used
        require(!_limit[a][b], "channel is used");

        // effect
        IRoom(a).hack(x, (_times[a] == 2 ? true : false));
        _limit[a][b] = true;
        _times[a] += 1;
    }

    function isSenderLocked(address a) external view returns (bool) {
        return _times[a] == 2;
    }

    function isChannelExist(address a, address b) external view returns (bool) {
        return _chan[a][b];
    }
}
