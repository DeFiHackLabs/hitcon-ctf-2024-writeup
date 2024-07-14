// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

abstract contract Adminable {
    address internal admin;

    function _onlyAdmin() internal view {
        require(msg.sender == admin);
    }

    function _setAdmin(address newAdmin) internal {
        admin = newAdmin;
    }
}
