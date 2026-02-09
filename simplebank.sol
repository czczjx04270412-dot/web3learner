// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
//总言（不断添加）：这串代码具备存款，取款，紧急提取功能
contract SimpleBankWithEvent {
    address public owner; 
    mapping(address => uint256) public balances;
    address[] public customerList;
    mapping(address => bool) public hasRegistered;
    uint256 public whitelistThreshold = 1 ether;

    event Deposited(address indexed user, uint256 amount);

    event Withdrawn(address indexed user, uint256 amount);

    event CustomerRegistered(address indexed user);

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }

    function deposit() public payable {
        require(msg.value > 0, "No ETH sent");
        balances[msg.sender] += msg.value;
        if (
        balances[msg.sender] >= whitelistThreshold &&
        !hasRegistered[msg.sender]
    ) {
        hasRegistered[msg.sender] = true;
        customerList.push(msg.sender);
        emit CustomerRegistered(msg.sender);
    }
        emit Deposited(msg.sender, msg.value);
    }

    function withdraw(uint256 amount) public {
        require(balances[msg.sender] >= amount, "Not enough balance");
        balances[msg.sender] -= amount;
        (bool success, ) = msg.sender.call{value: amount}("");
        require(success, "Transfer failed");
        emit Withdrawn(msg.sender, amount);
    }

   function emergencyWithdraw() public onlyOwner {
    (bool success, ) = owner.call{value: address(this).balance}("");
    require(success, "Transfer failed");
}

    function getContractBalance() public view returns (uint256) {
        return address(this).balance;
    }
    function addToWhitelist(address user) public onlyOwner {
    if (!hasRegistered[user]) {
        customerList.push(user);
        hasRegistered[user] = true;
        emit CustomerRegistered(user);
      }
    }
}