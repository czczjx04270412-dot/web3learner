// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title SimpleBank
 * @dev 这是一个基础的银行合约，实现了你之前跑通的存取款逻辑。
 */
contract SimpleBank {
    // 1. 理解 mapping: 多人储物柜账本
    mapping(address => uint256) private balances;

    // 2. 理解 address: 储户的地址（账号）
    address public owner;

    // 3. 理解 constructor: 开业剪彩（认主）
    constructor() {
        owner = msg.sender;
    }

    // 存款功能
    function deposit() public payable {
        // 4. 理解 require: 安保拦截（必须存入大于 0 的钱）
        require(msg.value > 0, "Deposit amount must be greater than 0");
        balances[msg.sender] += msg.value;
    }

    // 取款功能
    function withdraw(uint256 amount) public {
        require(balances[msg.sender] >= amount, "Insufficient balance");
        balances[msg.sender] -= amount;
        payable(msg.sender).transfer(amount);
    }

    // 查看余额
    function getBalance() public view returns (uint256) {
        return balances[msg.sender];
    }
}












