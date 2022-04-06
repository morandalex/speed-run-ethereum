// SPDX-License-Identifier: MIT

pragma solidity 0.8.4;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";


contract YourToken is ERC20 {
    constructor() ERC20("Gold", "GLD") {
        _mint(msg.sender, 1000 * 10 ** 18);
    }
}


contract Vendor is Ownable {
 

    YourToken public yourToken;
 
    uint256 public constant tokensPerEth = 100;

    event BuyTokens(address buyer, uint256 amountOfETH, uint256 amountOfTokens);
    event SellTokens(
        address seller,
        uint256 amountOfETH,
        uint256 amountOfTokens
    );

    constructor(address tokenAddress) public {
       yourToken =YourToken(tokenAddress);
    }

    function buyTokens() public payable {
        uint256 amountOfTokens = msg.value * tokensPerEth;
       yourToken.transfer(msg.sender, amountOfTokens);
        emit BuyTokens(msg.sender, msg.value, amountOfTokens);
    }

    function withdraw() public onlyOwner {
        uint256 amount = address(this).balance;
        (bool success, ) = owner().call{value: amount}("");
        require(success, "could not withdraw");
    }

    function sellTokens(uint256 tokenAmount) public {
        uint256 ethAmount = tokenAmount / tokensPerEth;
       yourToken.transferFrom(msg.sender, address(this), tokenAmount);
        (bool success, ) = msg.sender.call{value: ethAmount}("");
        require(success, "could not pay seller");
        emit SellTokens(msg.sender, ethAmount, tokenAmount);
    }
}
