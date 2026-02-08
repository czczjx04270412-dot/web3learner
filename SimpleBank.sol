// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title SimpleBank
 * @dev 最终版：包含存取款、白名单、分红以及行长紧急提取功能。
 * 已根据最新标准将 .transfer 升级为 .call 方式。
 */
contract SimpleBank {
    // 账本：记录每个地址的余额
    mapping(address => uint256) private balances;

    // 银行行长：部署合约的人
    address public owner;

    // 白名单相关变量
    address[] public customerList; // 储户名单（用于遍历发钱）
    mapping(address => bool) public isWhiteListed; // 快速检查某人是否在名单内

    constructor() {
        owner = msg.sender;
    }

    // 存款功能：存钱的同时自动加入白名单
    function deposit() public payable {
        require(msg.value > 0, "Deposit amount must be greater than 0");
        
        // 如果这个地址是第一次存钱，就把他加进去
        if (!isWhiteListed[msg.sender]) {
            isWhiteListed[msg.sender] = true;
            customerList.push(msg.sender);
        }
        
        balances[msg.sender] += msg.value;
    }

    // 分红功能：只有行长可以执行，给名单里的每人发 0.01 ETH（账面数字）
    function airdropBonus() public {
        require(msg.sender == owner, "Only owner can airdrop");
        
        for (uint256 i = 0; i < customerList.length; i++) {
            address user = customerList[i];
            balances[user] += 0.01 ether; 
        }
    }

    // 行长紧急提取功能：将合约内所有余额转给行长
    function emergencyWithdraw() public {
        require(msg.sender == owner, "Only Boss can rescue funds!");
        uint256 entireBalance = address(this).balance;
        require(entireBalance > 0, "Bank is already empty");
        
        // 现代安全转账方式：使用 .call
        (bool success, ) = payable(owner).call{value: entireBalance}("");
        require(success, "Emergency transfer failed");
    }

    // 用户取款功能
    function withdraw(uint256 amount) public {
        require(balances[msg.sender] >= amount, "Insufficient balance");
        
        // 先扣钱，后转账（防重入攻击的好习惯）
        balances[msg.sender] -= amount;

        // 现代安全转账方式：使用 .call
        (bool success, ) = payable(msg.sender).call{value: amount}("");
        require(success, "Withdrawal failed");
    }

    // 查看余额
    function getBalance() public view returns (uint256) {
        return balances[msg.sender];
    }
}










