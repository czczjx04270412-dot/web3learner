// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title SimpleBank (Final Version)
 * @dev 功能：存取款 + 白名单 + 分红 + 紧急提取 + 熔断开关
 */
contract SimpleBank {
    mapping(address => uint256) private balances;
    address public owner;
    address[] public customerList; 
    mapping(address => bool) public isWhiteListed; 

    // --- 【核心新增】熔断机制开关 ---
    bool public isPaused; // 默认 false，表示银行正常营业

    constructor() {
        owner = msg.sender;
    }

    // 老板专属：一键开关（熔断）
    function togglePause() public {
        require(msg.sender == owner, "Only owner can toggle pause");
        isPaused = !isPaused; // 状态取反：开变关，关变开
    }

    // 存款：如果熔断开启，禁止存款
    function deposit() public payable {
        require(!isPaused, "Bank is paused for maintenance");
        require(msg.value > 0, "Deposit amount must be greater than 0");
        
        if (!isWhiteListed[msg.sender]) {
            isWhiteListed[msg.sender] = true;
            customerList.push(msg.sender);
        }
        balances[msg.sender] += msg.value;
    }

    // 分红：如果熔断开启，禁止发钱
    function airdropBonus() public {
        require(msg.sender == owner, "Only owner can airdrop");
        require(!isPaused, "Bank is paused");
        
        for (uint256 i = 0; i < customerList.length; i++) {
            address user = customerList[i];
            balances[user] += 0.01 ether; 
        }
    }

    // 取款：【最关键】熔断开启时，锁定资金，防止黑客继续提现
    function withdraw(uint256 amount) public {
        require(!isPaused, "Emergency: Bank is paused, withdrawals are locked!");
        require(balances[msg.sender] >= amount, "Insufficient balance");
        
        balances[msg.sender] -= amount;
        (bool success, ) = payable(msg.sender).call{value: amount}("");
        require(success, "Withdrawal failed");
    }

    // 紧急提取（即使熔断了，老板也能救出剩下的钱）
    function emergencyWithdraw() public {
        require(msg.sender == owner, "Only Boss can rescue funds!");
        uint256 entireBalance = address(this).balance;
        (bool success, ) = payable(owner).call{value: entireBalance}("");
        require(success, "Emergency transfer failed");
    }

    function getBalance() public view returns (uint256) {
        return balances[msg.sender];
    }
}









