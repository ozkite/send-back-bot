// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/Address.sol";

contract EchoWallet {
    address public owner;

    constructor() {
        owner = msg.sender;
    }

    // ===== Native CELO Handling =====

    receive() external payable {
        if (msg.value > 0) {
            payable(msg.sender).transfer(msg.value);
        }
    }

    fallback() external payable {
        if (msg.value > 0) {
            payable(msg.sender).transfer(msg.value);
        }
    }

    // ===== ERC-20 Token Handling =====

    /**
     * @dev Function to receive tokens and send them back
     * Users must call this function instead of regular `transfer()`
     */
    function reflectToken(
        IERC20 token,
        uint256 amount
    ) external {
        require(
            token.transferFrom(msg.sender, address(this), amount),
            "Transfer failed"
        );

        // Send the tokens back
        require(
            token.transfer(msg.sender, amount),
            "Send back failed"
        );
    }

    // ===== Owner Functions =====

    /**
     * @dev Withdraw any tokens accidentally sent directly
     * @param tokenAddress The token to withdraw
     */
    function withdrawToken(address tokenAddress, uint256 amount) external {
        require(msg.sender == owner, "Only owner");
        IERC20(tokenAddress).transfer(owner, amount);
    }

    /**
     * @dev Withdraw CELO in case of accidental send
     */
    function withdrawCELO(uint256 amount) external {
        require(msg.sender == owner, "Only owner");
        payable(owner).transfer(amount);
    }
}
