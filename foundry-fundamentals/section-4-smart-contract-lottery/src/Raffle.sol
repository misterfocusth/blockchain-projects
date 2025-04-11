// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

contract Raffle {
    uint256 private immutable i_entranceFee;

    constructor(uint256 entraceFee) {
        i_entranceFee = entraceFee;
    }

    function enterRaffle() public payable {}

    function pickWinner() public {}

    function getEntranceFee() public view returns (uint256) {
        return i_entranceFee;
    }
}
