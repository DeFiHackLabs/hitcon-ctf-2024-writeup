// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import {IBeacon} from "./interface/IBeacon.sol";
import {IRoom} from "./interface/IRoom.sol";
import {IProtocol} from "./interface/IProtocol.sol";
import {Adminable} from "./utils/Adminable.sol";
import {ChannelAble} from "./utils/Channelable.sol";

contract Room is IRoom, Adminable, ChannelAble {
    ////////////////////////////////////////////////////////////////////////////
    // constant & immutable
    ////////////////////////////////////////////////////////////////////////////

    IBeacon internal immutable beacon;

    ////////////////////////////////////////////////////////////////////////////
    // state variables
    ////////////////////////////////////////////////////////////////////////////

    address[] internal neighbors;

    int256[] internal polynomial;

    int256 internal privateInput;

    uint256 internal selfLimit;

    uint256 internal historyRequestsLen;

    // store request from other Room
    // map(x => y)
    mapping(int256 => int256) public historyRequests;

    // store request result from other Room
    // map(x => map(y) => bool)
    mapping(int256 => mapping(int256 => bool)) internal isHistoryRequestExist;

    // Room is hacked due private input revealed
    bool public isHacked;

    // Room puzzle is solved
    bool public isSolved;

    ////////////////////////////////////////////////////////////////////////////
    // constructor
    ////////////////////////////////////////////////////////////////////////////

    constructor(address newAdmin, IBeacon newBeacon) {
        _setAdmin(newAdmin);
        beacon = newBeacon;
        isHacked = false;
    }

    ////////////////////////////////////////////////////////////////////////////
    // player
    ////////////////////////////////////////////////////////////////////////////

    function request(address to, int256 x) external {
        // check neighbors
        require(_isNeighbor(to), "Not a Neighbor");

        // check channel
        _channelCheck(address(this), to, x);

        // effect
        IRoom(to).onRequest(x);
    }

    function onRequest(int256 x) external returns (int256 y) {
        // check neighbors
        require(_isNeighbor(msg.sender), "Not a Neighbor");
        y = _onRequest(x);
    }

    function selfRequest(int256 x) external returns (int256 y) {
        // check not neighbors
        require(!_isNeighbor(msg.sender), "Be a Neighbor");
        require(selfLimit < 1, "match the limit");
        unchecked {
            selfLimit += 1;
        }
        y = _onRequest(x);
    }

    function _onRequest(int256 x) internal returns (int256 y) {
        y = IProtocol(beacon.implementation()).evaluate(polynomial, x);

        require(!isHistoryRequestExist[x][y], "had requested");

        historyRequests[x] = y;
        historyRequestsLen += 1;
        isHistoryRequestExist[x][y] = true;
    }

    function solveRoomPuzzle(int256[] calldata xvs) external {
        int256[] memory yvs = new int256[](xvs.length);
        require(historyRequestsLen >= 3, "lack of request");
        for (uint256 i = 0; i < xvs.length;) {
            yvs[i] = historyRequests[xvs[i]];
            unchecked {
                i += 1;
            }
        }

        IProtocol _protocol = IProtocol(beacon.implementation());
        int256 left = _protocol.evaluateLagrange(xvs, yvs, 100);
        int256 right = _protocol.evaluate(polynomial, 100);

        if (left == right) {
            isSolved = true;
        }
    }

    ////////////////////////////////////////////////////////////////////////////
    // admin
    ////////////////////////////////////////////////////////////////////////////

    function setChannel(address newChannel) external {
        _onlyAdmin();
        _setChannel(newChannel);
    }

    function setNeighbor(address[] calldata addrs) external {
        _onlyAdmin();
        for (uint256 i = 0; i < addrs.length;) {
            neighbors.push(addrs[i]);
            unchecked {
                i += 1;
            }
        }
    }

    function setProtocolArgs(int256[] calldata poly, int256 newPrivateInput) external {
        _onlyAdmin();
        privateInput = newPrivateInput;
        for (uint256 i = 0; i < poly.length;) {
            polynomial.push(poly[i]);
            unchecked {
                i += 1;
            }
        }
    }

    ////////////////////////////////////////////////////////////////////////////
    // channel
    ////////////////////////////////////////////////////////////////////////////

    function hack(int256 x, bool force) external {
        _onlyChannel();
        if (force || x == privateInput) {
            isHacked = true;
        }
    }

    ////////////////////////////////////////////////////////////////////////////
    // view functions
    ////////////////////////////////////////////////////////////////////////////

    function getNeighbors() external view returns (address[] memory ret) {
        ret = neighbors;
    }

    function getPolynomial() external view returns (int256[] memory ret) {
        ret = polynomial;
    }

    function getPrivateInput() external view returns (int256) {
        return privateInput;
    }

    function getAdmin() external view returns (address) {
        return admin;
    }

    function getChannel() external view returns (address) {
        return _chan;
    }

    function getBeacon() external view returns (address) {
        return address(beacon);
    }

    ////////////////////////////////////////////////////////////////////////////
    // helper functions
    ////////////////////////////////////////////////////////////////////////////

    function _isNeighbor(address to) internal view returns (bool isMatch) {
        for (uint256 i = 0; i < neighbors.length;) {
            if (neighbors[i] == to) {
                isMatch = true;
                break;
            }
            unchecked {
                i += 1;
            }
        }
    }
}
