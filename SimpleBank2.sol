// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
//总言（不改）：这串代码具备存款，取款，紧急取款，行长，安保，白名单，行长发红包，熔断机制
contract SimpleBankWithEvent {
    address public owner; 
    mapping(address => uint256) public balances;
    // 这里的数组像是一个通讯录，按顺序记录所有人
    address[] public customerList; 

    // 这里的 mapping 像是一个开关，记录某人是否已经进过名单了
    mapping(address => bool) public hasRegistered;

    bool public isPaused = false;

    event Deposited(address indexed user, uint256 amount);
    event Withdrawn(address indexed user, uint256 amount);

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }

    function deposit() public payable {
        require(msg.value > 0, "No ETH sent");
        // 如果（！代表“不”） 已经在名单里了
        if (!hasRegistered[msg.sender]) {
            customerList.push(msg.sender);    // 把他推入数组
            hasRegistered[msg.sender] = true; // 拨动开关，下次他就进不来这个 if 了
        }
        balances[msg.sender] += msg.value;
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
    // 这是一个只读窗口，方便前端网页显示“当前已有多少位客户”
    function getCustomerCount() public view returns (uint256) {
        return customerList.length;
    }
    // 1. 总闸开关（防患于未然）
    function togglePause() public onlyOwner {
    isPaused = !isPaused;
    }
        // 给所有在名单里的人发红包
function airdropBonus() public onlyOwner {
    uint256 reward = 0.001 ether; // 设定红包金额
    
    // 检查金库里的钱够不够发给所有人
    require(address(this).balance >= customerList.length * reward, "Bank broke!");

    // 开始循环：i 从 0 增加到名单总人数
    for (uint256 i = 0; i < customerList.length; i++) {
        if (isPaused) {
                break; // 如果总闸关了，立刻停止后续所有人的发放
        }       
        address user = customerList[i]; // 获取当前排队的人的地址
        
        // 执行转账逻辑
        (bool success, ) = user.call{value: reward}("");
        // 注意：在大规模循环中，我们通常不建议在循环内用 require(success)
        // 因为如果其中一个人地址有问题导致转账失败，整个循环都会回滚！
        // 这里的处理体现了 Web3 全栈的安全思维。
    }
}
     }

