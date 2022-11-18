// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./AccessControlToken.sol";

contract TokenVendor is Ownable {
    event TokensBought(
        address indexed buyer,
        uint256 amountOfETH,
        uint256 amountOfTokens
    );

    AccessControlToken public token;
    uint256 public constant tokensPerEth = 1500000;

    constructor(address tokenAddress) {
        token = AccessControlToken(tokenAddress);
    }

    function buyTokens() public payable {
        uint256 amount_ = msg.value * tokensPerEth;
        require(
            token.allowance(owner(), address(this)) >= amount_,
            "The vendor has not enought tokens"
        );
        bool sent = token.transferFrom(owner(), msg.sender, amount_);
        require(sent, "Failed to pay on exit");

        emit TokensBought(msg.sender, msg.value, amount_);
    }

    function withdraw() public onlyOwner {
        uint256 contractBalance = address(this).balance;
        (bool sent, ) = msg.sender.call{value: contractBalance}("");
        require(sent, "Failed to widraw funds");
    }
}