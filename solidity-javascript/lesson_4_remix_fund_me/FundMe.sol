// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import "./PriceConverter.sol";

error NotOwner();

contract FundMe {
    using PriceConverter for uint256;

    uint256 public constant MINIMUM_USD = 10 * 1e18; // 1 * 10 ** 18

    address[] public funders;
    mapping(address => uint256) public addressToAmountFunded;

    address public immutable i_owner;

    constructor() {
        i_owner = msg.sender;
    }

    // Payable = Include native token in transaction. (msg.value) <- available global value.
    function fund() public payable {
        // require(msg.value > 1e18, "Minimum transfer amount did't met criteria!"); // 1e18 = 1 * 10 ** 18 = 1 ETH
        require(msg.value.getConversionRate() >= MINIMUM_USD, "Minimum transfer amount did't met criteria!");
        funders.push(msg.sender);
        addressToAmountFunded[msg.sender] = msg.value;
    }

    function withdraw() public onlyOwner {
        for (uint256 funderIndex = 0; funderIndex < funders.length; funderIndex++) {
            address funder = funders[funderIndex];
            addressToAmountFunded[funder] = 0;
        }
        // Reset.
        funders = new address[](0);

        // Send ETH to Owner.
        // 1. Transfer (Gas 2300, Failed revert transaction)
        // payable(msg.sender).transfer(address(this).balance);

        // 2. Send (Gas 2300, Return bool)
        // bool sendSuccess = payable(msg.sender).send(address(this).balance);
        // require(sendSuccess, "Error, Can't perform withdrawal operations!"); // If false, revert transaction.

        // 3. Call (Recommended)
        (bool callSuccess, bytes memory dataReturned) = payable(msg.sender).call{value: address(this).balance}("");
        require(callSuccess, "Error, Can't perform withdrawal operations!"); // If false, revert transaction.
    }

    modifier onlyOwner {
        // require(msg.sender == i_owner, "Permission Denied!, Only owner can perform this operation!");
        if (msg.sender != i_owner) { revert NotOwner(); }
        _;
    }

    // What happends if someone sends this contract ETH without func() ?
    // receive()
    // fallback()

    receive() external payable {
        fund();
    }

    fallback() external payable {
        fund();
    }
}