# No-exit Room

## intro

The problem behind the challenge is a MPC protocol based on polynomial and lagrange interpolation. The challenge is an easy one so it was limited by only performing addition with given setup.

## mathematic about the protocol

### 1. prepare

Alice, Bob and David had their own private input. They designed a polynomial which encoded their private input in x = 0.

```
// Alice
private_input: 2

polynomial: A(x) = 2 - 3x + 1x^2

// Bob
private_input: 24

polynomial: B(x) = 24 - 14x + 2x^2

// David
private_input: 90

polynomial: C(x) = 90 - 11x + 3x^2
```

After that, the problem of calculating the sum will be transformed into `P(0)`:

```
polynomial: P(x) = A(x) + B(x) + C(x)
sum = P(0)
```

### 2. requesting for P(a), P(b) and P(c)

To get the quadratic polynomial P(x), we will need 3 point coordinates for interpolation.

As a result, Alice picked a value $\alpha$ and requested for B($\alpha$) and C($\alpha$) and get the result of P($\alpha$), so did Bob and Daivd.

Alice's part:

```solidity
// Alice picked 1 for the value
alice.selfRequest(1)
alice.request(address(bob), 1);
alice.request(address(david), 1);

// P(1) = A(1) + B(1) + C(1)
// A(1)
int256 a_of_1 = alice.historyRequests(1);
// B(1)
int256 b_of_1 = bob.historyRequests(1);
// C(1)
int256 c_of_1 = david.historyRequests(1);
```

Bob's part:

```solidity
// Bob picked 2 for the value
bob.selfRequest(2)
bob.request(address(alice), 2);
bob.request(address(david), 2);

// P(2) = A(2) + B(2) + C(2)
// A(2)
int256 a_of_2 = alice.historyRequests(2);
// B(2)
int256 b_of_2 = bob.historyRequests(2);
// C(2)
int256 c_of_2 = david.historyRequests(2);
```

David's part:

```solidity
// David picked 3 for the value
david.selfRequest(3)
david.request(address(alice), 3);
david.request(address(bob), 3);

// P(3) = A(3) + B(3) + C(3)
// A(3)
int256 a_of_2 = alice.historyRequests(3);
// B(3)
int256 b_of_2 = bob.historyRequests(3);
// C(3)
int256 c_of_2 = david.historyRequests(3);
```

### 3. perform interpolation for P(x)

Now, there are P(1), P(2) and P(3) for perform interpolation for P(x).

```solidity
int256 puzzle;
{
    int256[] memory xvs = new int256[](3);
    xvs[0] = 1;
    xvs[1] = 2;
    xvs[2] = 3;
    int256[] memory yvs = new int256[](3);
    yvs[0] = a_of_1 + b_of_1 + c_of_1; // P(1)
    yvs[1] = a_of_2 + b_of_2 + c_of_2; // P(2)
    yvs[2] = a_of_3 + b_of_3 + c_of_3; // P(3)

    // perform interpolation and evaluate with x=0
    puzzle = protocol.evaluateLagrange(xvs, yvs, 0);
    // puzzle is 116
}
```

## Solution

```solidity
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import "forge-std/Script.sol";

interface IChallenge {
    function alice() external returns (address);
    function bob() external returns (address);
    function david() external returns (address);
    function protocol() external returns (address);
    function commitPuzzle(int256) external;
    function isSolved() external view returns (bool);
}

interface IChannel {
    function open(address, address) external;

    function record(address a, address b, int256 x) external;
}

interface IProtocol {
    function evaluate(int256[] calldata, int256) external pure returns (int256);

    function evaluateLagrange(int256[] memory, int256[] memory, int256) external pure returns (int256);
}

interface IRoom {
    function hack(int256 x, bool) external;

    function request(address, int256) external;

    function onRequest(int256) external returns (int256);

    function solveRoomPuzzle(int256[] calldata) external;

    function selfRequest(int256) external returns (int256);

    function historyRequests(int256) external view returns (int256);
}

contract Solution {
    // change to challenge address
    IChallenge internal _challenge = IChallenge(0xf4688a416DE664777Cf746C92571c772852b27E3);

    function run() external {
        // load
        IRoom _alice = IRoom(_challenge.alice());
        IRoom _bob = IRoom(_challenge.bob());
        IRoom _david = IRoom(_challenge.david());
        IProtocol _protocol = IProtocol(_challenge.protocol());

        // alice
        _alice.selfRequest(1); // evaluate A(1)
        _alice.request(address(_bob), 1); // evaluate B(1)
        _alice.request(address(_david), 1); // evaluate C(1)

        // bob
        _bob.selfRequest(2); // evaluate A(2)
        _bob.request(address(_alice), 2); // evaluate B(2)
        _bob.request(address(_david), 2); // evaluate C(2)

        // david
        _david.selfRequest(3); // evaluate A(3)
        _david.request(address(_alice), 3); // evaluate B(3)
        _david.request(address(_bob), 3); // evaluate C(3)

        // load history data
        int256 a_of_1 = _alice.historyRequests(1);
        int256 b_of_1 = _bob.historyRequests(1);
        int256 c_of_1 = _david.historyRequests(1);

        int256 a_of_2 = _alice.historyRequests(2);
        int256 b_of_2 = _bob.historyRequests(2);
        int256 c_of_2 = _david.historyRequests(2);

        int256 a_of_3 = _alice.historyRequests(3);
        int256 b_of_3 = _bob.historyRequests(3);
        int256 c_of_3 = _david.historyRequests(3);

        int256 puzzle;
        {
            // avoid stack too deep
            int256[] memory xvs = new int256[](3);
            xvs[0] = 1;
            xvs[1] = 2;
            xvs[2] = 3;
            int256[] memory yvs = new int256[](3);
            yvs[0] = a_of_1 + b_of_1 + c_of_1; // P(1) = A(1) + B(1) + C(1)
            yvs[1] = a_of_2 + b_of_2 + c_of_2; // P(2) = A(2) + B(2) + C(2)
            yvs[2] = a_of_3 + b_of_3 + c_of_3; // P(3) = A(3) + B(3) + C(3)
            puzzle = _protocol.evaluateLagrange(xvs, yvs, 0); // evaluate P(0)
        }

        // solve puzzle
        int256[] memory roomx = new int256[](3);
        roomx[0] = 1;
        roomx[1] = 2;
        roomx[2] = 3;
        _alice.solveRoomPuzzle(roomx);
        _bob.solveRoomPuzzle(roomx);
        _david.solveRoomPuzzle(roomx);
        _challenge.commitPuzzle(puzzle);

        console.logBool(_challenge.isSolved());
    }
}
```
