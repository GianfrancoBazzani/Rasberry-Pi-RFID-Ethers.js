// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "./AccessControlToken.sol";

contract TokenVendor is Ownable {
    event TokensBought(
        address indexed buyer,
        uint256 amountOfETH,
        uint256 amountOfTokens
    );

    AccessControlToken token;
    ERC20 USDC;
    uint256 public price = 10000000000000000; //0.01 //USC/TOKEN

    constructor(address _tokenAddress, uint256 _initialPrice) {
        token = AccessControlToken(_tokenAddress);
        price = _initialPrice;
        USDC = ERC20(0x6c28AeF8977c9B773996d0e8376d2EE379446F2f);
    }

    function tokenACTAddress() public view returns (address) {
        return address(token);
    }

    function updatePrice(uint256 _price) public onlyOwner {
        price = _price;
    }

    function buyTokens(uint256 _amount) public payable {
        
        uint256 _usdcToPay = _amount*price;
        
        // Check vendor token balance
        require (token.balanceOf(address(this)) >= _amount, "Token vendor is empty");
        
        // Check USDC allowance
        require (USDC.allowance(msg.sender, address(this)) >= _usdcToPay , "Not enough USDC allowed to spend");
        
        // Transfer USDC from msg.sender to this.addess
        require (USDC.transferFrom(msg.sender, address(this), _usdcToPay), "Error while transfering USDC");

        //Transfer Tokens from Contract to user
        require(token.transfer(msg.sender, _amount), "Error while transfering Access Control Tokens");

        //Event emission
        emit TokensBought(msg.sender, _usdcToPay, _amount);
    }

    function withdraw() public onlyOwner {

        // Check usdc balance
        uint256 usdcBalance = USDC.balanceOf(address(this));
        require(usdcBalance > 0);

        // withdraw all usdc
        require (USDC.transfer(msg.sender, usdcBalance), "Error while transfering USDC");

    }
}