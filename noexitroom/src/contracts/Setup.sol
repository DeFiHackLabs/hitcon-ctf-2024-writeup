// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import {Beacon} from "./Beacon.sol";
import {Channel} from "./Channel.sol";
import {Protocol} from "./Protocol.sol";
import {Room} from "./Room.sol";

contract Setup {
    ////////////////////////////////////////////////////////////////////////////
    // variable
    ////////////////////////////////////////////////////////////////////////////

    bool internal puzzleSolved;
    bytes32 internal constant puzzleHash = hex"19a0b39aa25ac793b5f6e9a0534364cc0b3fd1ea9b651e79c7f50a59d48ef813";

    ////////////////////////////////////////////////////////////////////////////
    // contracts
    ////////////////////////////////////////////////////////////////////////////

    Beacon public beacon;
    Channel public channel;
    Protocol public protocol;
    Room public alice;
    Room public bob;
    Room public david;

    ////////////////////////////////////////////////////////////////////////////
    // constructor
    ////////////////////////////////////////////////////////////////////////////

    constructor() {
        // deployment
        beacon = new Beacon();
        protocol = new Protocol();
        channel = new Channel(address(this));
        alice = new Room(address(this), beacon);
        bob = new Room(address(this), beacon);
        david = new Room(address(this), beacon);

        // beacon update
        beacon.update(address(protocol));

        // set channel
        channel.open(address(alice), address(bob));
        channel.open(address(alice), address(david));
        channel.open(address(bob), address(david));
        alice.setChannel(address(channel));
        bob.setChannel(address(channel));
        david.setChannel(address(channel));

        // set neighbor
        address[] memory addrs = new address[](2);
        addrs[0] = address(bob);
        addrs[1] = address(david);
        alice.setNeighbor(addrs);
        // // bob
        addrs[0] = address(alice);
        addrs[1] = address(david);
        bob.setNeighbor(addrs);
        // // david
        addrs[0] = address(alice);
        addrs[1] = address(bob);
        david.setNeighbor(addrs);

        // set Protocol Arguments
        // // alice: B(x) = 2 - 3x + 1x^2
        int256[] memory poly = new int256[](3);
        poly[0] = 2;
        poly[1] = -3;
        poly[2] = 1;
        alice.setProtocolArgs(poly, 2);
        // // bob: B(x) = 24 - 14x + 2x^2
        poly[0] = 24;
        poly[1] = -14;
        poly[2] = 2;
        bob.setProtocolArgs(poly, 24);
        // // david: C(x) = 90 - 11x + 3x^2
        poly[0] = 90;
        poly[1] = -11;
        poly[2] = 3;
        david.setProtocolArgs(poly, 90);
    }

    ////////////////////////////////////////////////////////////////////////////
    // external function
    ////////////////////////////////////////////////////////////////////////////

    function commitPuzzle(int256 y) external {
        require(keccak256(abi.encode(y)) == puzzleHash, "Puzzle not Solve");
        puzzleSolved = true;
    }

    function isSolved() external view returns (bool) {
        return puzzleSolved && !alice.isHacked() && !bob.isHacked() && !david.isHacked() && alice.isSolved()
            && bob.isSolved() && david.isSolved();
    }
}
