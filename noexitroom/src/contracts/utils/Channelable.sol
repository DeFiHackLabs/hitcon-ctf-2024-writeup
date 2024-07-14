// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import {IChannel} from "../interface/IChannel.sol";
import {IRoom} from "../interface/IRoom.sol";

abstract contract ChannelAble {
    address internal _chan;

    function _setChannel(address newChan) internal {
        _chan = newChan;
    }

    function _onlyChannel() internal view {
        require(msg.sender == _chan, "only channel can call");
    }

    function _channelCheck(address a, address b, int256 x) internal {
        if (_chan == address(0)) {
            return;
        }
        // channel record
        IChannel(_chan).record(a, b, x);
    }
}
