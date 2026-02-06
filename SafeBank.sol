// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract SafeBank {
    address public owner;
    bool public isBankOpen = true; 
    mapping(address => uint256) public balances;

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the Boss can do this!");
        _; 
    }

    function toggleBankStatus() public onlyOwner {
        isBankOpen = !isBankOpen; 
    }

    function deposit() public payable {
        require(isBankOpen == true, "Bank is closed!");
        balances[msg.sender] += msg.value;
    }

    function withdraw(uint256 amount) public {
        uint256 actualAmount = amount * 1 ether;
        require(isBankOpen == true, "Bank is closed!");
        require(balances[msg.sender] >= actualAmount, "Insufficient balance!");
        
        balances[msg.sender] -= actualAmount;
        payable(msg.sender).transfer(actualAmount);
    }

    function _secretInternalAction() internal pure returns (string memory) {
        return "You found the secret!";
    }
}
