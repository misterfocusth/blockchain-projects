// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

// Explainer: https://solidity-by-example.org/fallback/

//                  send Ether
//                       |
//            msg.data is empty?
//                 /           \
//             yes             no
//              |                |
//     receive() exists?     fallback()
//         /        \
//      yes          no
//       |            |
//   receive()     fallback()

contract FallbackExample {
    uint256 public result;

    // Special function without function keywords.
    // Trigger: ETH transfer to this contract.
    receive() external payable {
        result = 1;
    }

    // Special function without function keywords.
    // Trigger: When no function call, function not found on calldata.
    fallback() external payable {
        result = 2;
    }
}