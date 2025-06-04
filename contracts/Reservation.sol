// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import {IPancakeRouter02} from "@pancakeswap/v2-periphery/contracts/interfaces/IPancakeRouter02.sol";
import {IPancakeFactory} from "@pancakeswap/v2-core/contracts/interfaces/IPancakeFactory.sol";
import {IMockREF} from "./interfaces/IMockREF.sol";
import {AutomationCompatibleInterface} from "@chainlink/contracts/src/v0.8/interfaces/AutomationCompatibleInterface.sol";

/**
 * @title 预约合约 - 用于管理用户预约、锁仓和收益分配
 * @author 付朝阳 
 * @notice 这是一个智能合约，用于管理用户的预约、锁仓和收益分配机制
 * @dev 合约结构:
 * - 继承自 Ownable、ReentrancyGuard 和 AutomationCompatibleInterface
 * - 使用 PancakeSwap 进行代币交换
 * - 集成 Chainlink Automation 实现自动化操作
 * 
 * 主要状态变量:
 * - reservations: 存储用户预约数据的映射
 * - reservationQueue: 预约队列数组
 * - mBNB、mUSDT、mBAOFU: 代币合约接口
 * - mREF: 推荐系统代币合约
 * 
 * 核心功能:
 * 1. 预约机制:
 *    - 用户使用mBNB预约进场
 *    - 合约检查mBNB价值是否在100-300 USDT之间
 *    - 预约信息记录在reservations映射中
 * 
 * 2. 锁仓机制:
 *    - 预约后进入队列,强制锁仓24小时
 *    - 使用队列系统(reservationQueue)管理锁仓顺序
 * 
 * 3. 收益计算:
 *    - 24小时内达到100%收益率时强制平仓
 *    - 超过24小时按实时BAOFU币价计算
 *    - 多余利润通过销毁机制处理
 * 
 * 4. 推荐奖励系统:
 *    - 分级推荐制度,最多8代推荐奖励
 *    - 按照推荐人数确定等级:
 *      * 第一代(3人): 1.5%返佣
 *      * 第二代(6人): 1.0%返佣
 *      * 第三代(9人): 1.0%返佣
 *      * 第四代(12人): 0.5%返佣
 *      * 第五代(15人): 0.5%返佣
 *      * 第六到八代(20人): 0.3%返佣
 *    - 通过mREF代币记录推荐关系
 */

contract Reservation is Ownable, ReentrancyGuard, AutomationCompatibleInterface {
    // 代币合约接口
    IERC20 public mBNB;      // mBNB代币合约
    IERC20 public mUSDT;     // mUSDT代币合约
    IERC20 public mBAOFU;    // mBAOFU代币合约
    // MockREF Token的function一般IERC覆盖不到，用新的interface
    IMockREF public mREF;    // 推荐系统代币合约
    IPancakeRouter02 public pancakeRouter;    // PancakeSwap路由合约
    IPancakeFactory public pancakeFactory;    // PancakeSwap工厂合约
    
    // 预约数据结构
    struct ReservationData {
        uint256 amount;              // 预约金额
        uint256 timestamp;           // 预约时间戳
        bool isActive;               // 是否处于活跃状态
        uint256 baofuAmount;         // 获得的BAOFU数量
        uint256 originalMBNBValue;   // 存储原始mBNB的USDT价值
    }
    
    // 用户地址到预约数据的映射
    mapping(address => ReservationData) public reservations;
    
    // 合约授权状态
    bool public isAuthorized;
    
    // 预约队列相关变量
    address[] public reservationQueue;                    // 预约队列数组
    mapping(address => uint256) public queuePosition;     // 用户在队列中的位置
    uint256 public currentQueueIndex = 0;                 // 当前处理到的队列位置
    
    // 常量定义
    uint256 public constant MIN_RESERVATION = 100 * 1e18; // 最小预约金额：100 mUSDT
    uint256 public constant MAX_RESERVATION = 300 * 1e18; // 最大预约金额：300 mUSDT
    uint256 public constant LOCK_PERIOD = 24 hours;       // 锁仓期限：24小时
    uint256 public constant TARGET_RETURN = 100;          // 目标收益率：100%
    uint256 public constant REF_TOKEN_AMOUNT = 1e18;      // 建立推荐关系所需的REF代币数量：1 REF
    
    // 销毁地址 - 用于销毁多余的BAOFU代币
    address public constant BURN_ADDRESS = 0x000000000000000000000000000000000000dEaD;
    
    // 事件定义
    event ReservationCreated(address indexed user, uint256 amount, uint256 baofuAmount);    // 预约创建事件
    event ReservationClosed(address indexed user, uint256 returnAmount, uint256 profit);    // 预约关闭事件
    event ReferralRewardPaid(address indexed referrer, address indexed user, uint256 amount, uint256 level);  // 推荐奖励支付事件
    event ReservationAutoClosed(address indexed user, uint256 returnAmount, uint256 profit, bool isForced);   // 自动关闭预约事件
    
    /**
     * @dev 构造函数
     * @param _mBNB mBNB代币合约地址
     * @param _mUSDT mUSDT代币合约地址
     * @param _mBAOFU mBAOFU代币合约地址
     * @param _mREF 推荐系统代币合约地址
     * @param _pancakeRouter PancakeSwap路由合约地址
     */
    constructor(
        address _mBNB,
        address _mUSDT,
        address _mBAOFU,
        address _mREF,
        address _pancakeRouter
    ) {
        mBNB = IERC20(_mBNB);
        mUSDT = IERC20(_mUSDT);
        mBAOFU = IERC20(_mBAOFU);
        mREF = IMockREF(_mREF);
        pancakeRouter = IPancakeRouter02(_pancakeRouter);
        pancakeFactory = IPancakeFactory(pancakeRouter.factory());
    }
    
    /**
     * @dev 内部授权函数，用于初始化合约对MockREF的授权
     */
    function _mREFinitializeAuthorization() internal {
        mREF.addAuthorizedContract(address(this));
        isAuthorized = true;
    }
    
    /**
     * @dev 公共授权函数
     * @notice 允许合约所有者手动初始化授权
     */
    function initializeAuthorization() external onlyOwner {
        require(!isAuthorized, "mREF Already authorized");
        _mREFinitializeAuthorization();
    }

    /**
     * @dev 设置授权状态函数
     * @notice 允许合约所有者直接设置授权状态
     * @param status 授权状态
     */
    function setAuthorizationStatus(bool status) external onlyOwner {
        isAuthorized = status;
    }

    /**
     * @dev 预约函数
     * @param amount 预约金额（mBNB数量）
     * @param referrer 推荐人地址
     * @notice 需要用户先调用 mBNB.approve(reservationContract, amount) 授权合约使用mBNB
     * @notice 见scripts/userOperations.js
     */
    function createReservation(uint256 amount, address referrer) external nonReentrant {
        require(amount > 0, "Amount must be greater than 0");
        require(!reservations[msg.sender].isActive, "Active reservation exists");
        require(isAuthorized, "Contract not authorized to set referrals");
        
        // 使用PancakeSwap检查mBNB金额是否在限制范围内
        address[] memory path = new address[](2);
        path[0] = address(mBNB);
        path[1] = address(mUSDT);
        uint[] memory amounts = pancakeRouter.getAmountsOut(amount, path);
        require(amounts[1] >= MIN_RESERVATION && amounts[1] <= MAX_RESERVATION, "Amount out of range");
        
        // 从用户转入mBNB
        require(mBNB.transferFrom(msg.sender, address(this), amount), "mBNB transfer failed");
        
        // 通过PancakeSwap将mBNB兑换为BAOFU
        uint256 baofuAmount = _swapMBNBForBAOFU(amount);
        
        // 如果提供了推荐人且未建立推荐关系，则建立推荐关系
        if (referrer != address(0) && referrer != msg.sender && mREF.referrers(msg.sender) == address(0)) {
            // 原则上是推荐人给下级打推荐币(还要加入初始推荐人的mREF来源)，这要求推荐人的签名或approve
            // 在实际情况中，推荐机制应引入推荐人对打推荐币的签名
            // 这里为了方便，直接让合约给下级打推荐币
            require(mREF.transfer(msg.sender, REF_TOKEN_AMOUNT), "REF transfer failed");
            mREF.setReferralByContract(referrer, msg.sender);
        }
        
        // 创建预约记录
        reservations[msg.sender] = ReservationData({
            amount: amount,
            timestamp: block.timestamp,
            isActive: true,
            baofuAmount: baofuAmount,
            originalMBNBValue: amounts[1]
        });
        
        // 添加到预约队列
        reservationQueue.push(msg.sender);
        queuePosition[msg.sender] = reservationQueue.length - 1;
        
        emit ReservationCreated(msg.sender, amount, baofuAmount);
    }

    /* 支持 permit 的一步式预约函数，当然原生BNB不支持permmit
    function createReservationWithPermit(
        uint256 amount,
        address referrer,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external nonReentrant {
        require(amount > 0, "Amount must be greater than 0");
        require(!reservations[msg.sender].isActive, "Active reservation exists");
        require(isAuthorized, "Contract not authorized to set referrals");
        
        // 使用 permit 进行授权
        IERC20Permit(address(mBNB)).permit(msg.sender, address(this), amount, deadline, v, r, s);
        
        // 使用PancakeSwap检查mBNB金额是否在限制范围内
        address[] memory path = new address[](2);
        path[0] = address(mBNB);
        path[1] = address(mUSDT);
        uint[] memory amounts = pancakeRouter.getAmountsOut(amount, path);
        require(amounts[1] >= MIN_RESERVATION && amounts[1] <= MAX_RESERVATION, "Amount out of range");
        
        // 从用户转入mBNB
        require(mBNB.transferFrom(msg.sender, address(this), amount), "mBNB transfer failed");
        
        // 通过PancakeSwap将mBNB兑换为BAOFU
        uint256 baofuAmount = _swapMBNBForBAOFU(amount);
        
        // 如果提供了推荐人且未建立推荐关系，则建立推荐关系
        if (referrer != address(0) && referrer != msg.sender && mREF.referrers(msg.sender) == address(0)) {
            require(mREF.transfer(msg.sender, REF_TOKEN_AMOUNT), "REF transfer failed");
            mREF.setReferralByContract(referrer, msg.sender);
        }
        
        // 创建预约记录
        reservations[msg.sender] = ReservationData({
            amount: amount,
            timestamp: block.timestamp,
            isActive: true,
            baofuAmount: baofuAmount,
            originalMBNBValue: amounts[1]
        });
        
        // 添加到预约队列
        reservationQueue.push(msg.sender);
        queuePosition[msg.sender] = reservationQueue.length - 1;
        
        emit ReservationCreated(msg.sender, amount, baofuAmount);
    }
    */

    /**
     * @dev 接收ETH的回调函数
     */
    receive() external payable {
    }

    /**
     * @dev 将mBNB兑换为BAOFU的内部函数
     * @param mbnbAmount 要兑换的mBNB数量
     * @return 获得的BAOFU数量
     */
    function _swapMBNBForBAOFU(uint256 mbnbAmount) internal returns (uint256) {
        // 准备交换路径: mBNB -> mUSDT -> mBAOFU
        address[] memory path = new address[](3);
        path[0] = address(mBNB);
        path[1] = address(mUSDT);
        path[2] = address(mBAOFU);
        
        // 首先需要approve mBNB给PancakeSwap Router
        require(mBNB.approve(address(pancakeRouter), mbnbAmount), "mBNB approve failed");
        
        // 执行代币交换
        uint[] memory amounts = pancakeRouter.swapExactTokensForTokens(
            mbnbAmount,
            0, // 接受任意数量的BAOFU
            path,
            address(this),
            block.timestamp + 300 // 5分钟超时
        );
        
        return amounts[amounts.length - 1]; // 返回获得的BAOFU数量
    }
    
    /**
     * @dev 关闭预约
     * @notice 用户可以在锁仓期结束后关闭预约，提取对应的BAOFU代币
     */
    function closeReservation() external {
        require(reservations[msg.sender].isActive, "No active reservation");
        require(block.timestamp >= reservations[msg.sender].timestamp + LOCK_PERIOD, "Lock period not ended");
        
        ReservationData storage reservation = reservations[msg.sender];
        
        // 计算当前BAOFU的USDT价值
        uint256 currentBAOFUValueInUSDT = _getBAOFUValueInUSDT(reservation.baofuAmount);
        
        // 计算收益率
        uint256 returnPercentage = (currentBAOFUValueInUSDT * 100) / reservation.originalMBNBValue;
        
        // 计算利润金额（以USDT计算）
        uint256 profitInUSDT = currentBAOFUValueInUSDT > reservation.originalMBNBValue ? 
            currentBAOFUValueInUSDT - reservation.originalMBNBValue : 0;
        
        if (returnPercentage >= 200) {
            // 达到或超过100%收益：强制平仓逻辑
            // 1. 用户拿回原始投资金额等值的BAOFU
            uint256 originalInvestmentBAOFU = _calculateBAOFUAmountFromUSDT(reservation.originalMBNBValue);
            
            // 2. 利润部分的BAOFU用来支付推荐奖励
            uint256 profitBAOFU = _calculateBAOFUAmountFromUSDT(reservation.originalMBNBValue); // 100%利润对应的BAOFU
            
            // 3. 超过200%的部分销毁
            uint256 totalValidBAOFU = originalInvestmentBAOFU + profitBAOFU; // 最多200%对应的BAOFU
            if (reservation.baofuAmount > totalValidBAOFU) {
                uint256 excessBAOFU = reservation.baofuAmount - totalValidBAOFU;
                _burnExcessBAOFU(excessBAOFU);
            }
            
            // 返还用户原始投资金额对应的BAOFU
            require(mBAOFU.transfer(msg.sender, originalInvestmentBAOFU), "BAOFU transfer failed");
            
            profitInUSDT = reservation.originalMBNBValue; // 100%利润（以USDT计算）
            
            emit ReservationClosed(msg.sender, originalInvestmentBAOFU, profitInUSDT);
        } else {
            // 未达到100%收益：返还所有BAOFU
            require(mBAOFU.transfer(msg.sender, reservation.baofuAmount), "BAOFU transfer failed");
            
            emit ReservationClosed(msg.sender, reservation.baofuAmount, profitInUSDT);
        }
        
        // 在删除预约数据之前支付推荐奖励
        _payReferralRewards(msg.sender);
        
        // 清除预约
        delete reservations[msg.sender];
    }
    
    /**
     * @dev 根据USDT金额计算对应的BAOFU数量
     * @param usdtAmount USDT金额
     * @return 对应的BAOFU数量
     */
    function _calculateBAOFUAmountFromUSDT(uint256 usdtAmount) internal view returns (uint256) {
        address[] memory path = new address[](2);
        path[0] = address(mUSDT);
        path[1] = address(mBAOFU);
        
        uint[] memory amounts = pancakeRouter.getAmountsOut(usdtAmount, path);
        return amounts[1];
    }
    
    /**
     * @dev 支付推荐奖励的内部函数
     * @param user 用户地址
     */
    function _payReferralRewards(address user) internal {
        address currentReferrer = mREF.referrers(user);
        if (currentReferrer == address(0)) return; // 没有推荐人，直接返回

        // 获取当前BAOFU的USDT价值作为实际成交金额
        ReservationData storage reservation = reservations[user];
        uint256 actualTradeValue = _getBAOFUValueInUSDT(reservation.baofuAmount);
        
        // 计算利润金额（以USDT计算）
        uint256 profitInUSDT = actualTradeValue > reservation.originalMBNBValue ? 
            actualTradeValue - reservation.originalMBNBValue : 0;
        
        // 如果没有利润，就没有奖励可分配
        if (profitInUSDT == 0) return;

        // 计算总奖励比例
        uint256 totalRewardPercentage = 0;
        address tempReferrer = currentReferrer;
        uint256 tempLevel = 0;
        
        // 第一次遍历：计算总奖励比例
        while (tempReferrer != address(0) && tempLevel < 8) {
            uint256 referralCount = mREF.referralCount(tempReferrer);
            uint256 rewardPercentage = _getRewardPercentage(referralCount, tempLevel);
            totalRewardPercentage += rewardPercentage;
            
            tempReferrer = mREF.referrers(tempReferrer);
            tempLevel++;
        }
        
        // 如果没有推荐奖励比例，直接返回
        if (totalRewardPercentage == 0) return;
        
        // 第二次遍历：分配奖励
        uint256 level = 0;
        
        while (currentReferrer != address(0) && level < 8) {
            uint256 referralCount = mREF.referralCount(currentReferrer);
            uint256 rewardPercentage = _getRewardPercentage(referralCount, level);
            
            if (rewardPercentage > 0) {
                // 基于利润金额计算当前级别的奖励USDT金额
                uint256 levelRewardUSDT = (profitInUSDT * rewardPercentage) / 1000;
                
                if (levelRewardUSDT > 0) {
                    // 将奖励USDT金额转换成BAOFU数量
                    uint256 levelRewardBAOFU = _calculateBAOFUAmountFromUSDT(levelRewardUSDT);
                    
                    // 检查合约是否有足够的BAOFU
                    uint256 contractBAOFUBalance = mBAOFU.balanceOf(address(this));
                    if (levelRewardBAOFU > contractBAOFUBalance) {
                        levelRewardBAOFU = contractBAOFUBalance; // 如果不够，就用剩余的全部
                    }
                    
                    if (levelRewardBAOFU > 0) {
                        require(mBAOFU.transfer(currentReferrer, levelRewardBAOFU), "BAOFU reward transfer failed");
                        emit ReferralRewardPaid(currentReferrer, user, levelRewardBAOFU, level + 1);
                    }
                }
            }
            
            currentReferrer = mREF.referrers(currentReferrer);
            level++;
        }
    }
    
    /**
     * @dev 获取奖励比例的内部函数
     * @param referralCount 推荐人数
     * @param level 推荐层级
     * @return 奖励比例（千分比）
     */
    function _getRewardPercentage(uint256 referralCount, uint256 level) internal pure returns (uint256) {
        // 根据推荐人数确定能拿到的代数
        uint256 maxLevel = 0;
        if (referralCount >= 20) maxLevel = 8;      // 六到八代
        else if (referralCount >= 15) maxLevel = 5; // 第五代
        else if (referralCount >= 12) maxLevel = 4; // 第四代
        else if (referralCount >= 9) maxLevel = 3;  // 第三代
        else if (referralCount >= 6) maxLevel = 2;  // 第二代
        else if (referralCount >= 3) maxLevel = 1;  // 第一代
        
        // 如果当前级别超过推荐人数允许的最大级别，则无奖励
        if (level >= maxLevel) return 0;
        
        // 根据级别返回奖励比例
        if (level == 0) return 15;      // 1.5%
        else if (level == 1) return 10; // 1%
        else if (level == 2) return 10; // 1%
        else if (level == 3) return 5;  // 0.5%
        else if (level == 4) return 5;  // 0.5%
        else return 3;                  // 0.3% (六到八代)
    }
    
    /**
     * @dev 获取用户预约信息的函数
     * @param user 用户地址
     * @return amount 预约金额
     * @return timestamp 预约时间戳
     * @return isActive 是否处于活跃状态
     * @return baofuAmount 获得的BAOFU数量
     */
    function getReservationInfo(address user) external view returns (
        uint256 amount,
        uint256 timestamp,
        bool isActive,
        uint256 baofuAmount
    ) {
        ReservationData storage reservation = reservations[user];
        return (
            reservation.amount,
            reservation.timestamp,
            reservation.isActive,
            reservation.baofuAmount
        );
    }
    
    /**
     * @dev 获取用户推荐信息的函数
     * @param user 用户地址
     * @return referrer 推荐人地址
     * @return referralCount 推荐人数
     * @return maxLevel 最大推荐层级
     */
    function getReferralInfo(address user) external view returns (
        address referrer,
        uint256 referralCount,
        uint256 maxLevel
    ) {
        referrer = mREF.referrers(user);
        referralCount = mREF.referralCount(user);
        
        // 计算该用户能拿到的最大代数
        if (referralCount >= 20) maxLevel = 8;
        else if (referralCount >= 15) maxLevel = 5;
        else if (referralCount >= 12) maxLevel = 4;
        else if (referralCount >= 9) maxLevel = 3;
        else if (referralCount >= 6) maxLevel = 2;
        else if (referralCount >= 3) maxLevel = 1;
        else maxLevel = 0;
    }

    /**
     * @dev 授权合约可以调用 MockREF 的函数
     * @param contractAddress 要授权的合约地址
     */
    function authorizeContract(address contractAddress) external onlyOwner {
        mREF.addAuthorizedContract(contractAddress);
    }

    /**
     * @dev 取消合约对 MockREF 的授权
     * @param contractAddress 要取消授权的合约地址
     */
    function deauthorizeContract(address contractAddress) external onlyOwner {
        mREF.removeAuthorizedContract(contractAddress);
    }

    /**
     * @dev 获取预约队列长度的函数
     * @return 队列长度
     */
    function getQueueLength() external view returns (uint256) {
        return reservationQueue.length;
    }

    /**
     * @dev 获取用户在队列中的位置
     * @param user 用户地址
     * @return 用户在队列中的位置
     */
    function getQueuePosition(address user) external view returns (uint256) {
        require(reservations[user].isActive, "No active reservation");
        return queuePosition[user];
    }

    /**
     * @dev 获取当前队列处理位置的函数
     * @return 当前队列处理位置
     */
    function getCurrentQueueIndex() external view returns (uint256) {
        return currentQueueIndex;
    }

    /**
     * @dev 获取用户队列状态的函数
     * @param user 用户地址
     * @return position 用户在队列中的位置
     * @return ahead 用户前面还有多少人
     * @return canClose 是否可以关闭预约
     */
    function getQueueStatus(address user) external view returns (uint256 position, uint256 ahead, bool canClose) {
        require(reservations[user].isActive, "No active reservation");
        position = queuePosition[user];
        ahead = position > currentQueueIndex ? position - currentQueueIndex : 0;
        canClose = block.timestamp >= reservations[user].timestamp + LOCK_PERIOD;
        return (position, ahead, canClose);
    }

    /**
     * @dev Chainlink Automation checkUpkeep 函数
     * @notice 检查是否需要执行自动关闭预约的操作
     * @return needsExecution 是否需要执行
     * @return performData 执行所需的数据
     */
    function checkUpkeep(
        bytes calldata /* checkData */
    ) external view returns (bool needsExecution, bytes memory performData) {
        address[] memory usersToClose = new address[](reservationQueue.length);
        uint256 count = 0;
        
        for (uint256 i = currentQueueIndex; i < reservationQueue.length; i++) {
            address user = reservationQueue[i];
            ReservationData storage reservation = reservations[user];
            
            if (!reservation.isActive) continue;
            
            // 计算当前BAOFU的USDT价值
            uint256 currentBAOFUValue = _getBAOFUValueInUSDT(reservation.baofuAmount);
            bool isOver24Hours = block.timestamp >= reservation.timestamp + LOCK_PERIOD;
            bool is100PercentReturn = currentBAOFUValue >= reservation.originalMBNBValue * 2;
            
            // 严格检查条件：
            // 1. 24小时内达到100%收益强制平仓
            // 2. 超过24小时按实时价格计算
            if ((!isOver24Hours && is100PercentReturn) || isOver24Hours) {
                usersToClose[count] = user;
                count++;
            }
        }
        
        if (count > 0) {
            address[] memory finalUsersToClose = new address[](count);
            for (uint256 i = 0; i < count; i++) {
                finalUsersToClose[i] = usersToClose[i];
            }
            return (true, abi.encode(finalUsersToClose));
        }
        
        return (false, "");
    }

    /**
     * @dev Chainlink Automation performUpkeep 函数
     * @notice 执行自动关闭预约的操作
     * @param performData 执行所需的数据
     */
    function performUpkeep(bytes calldata performData) external {
        address[] memory usersToClose = abi.decode(performData, (address[]));
        
        for (uint256 i = 0; i < usersToClose.length; i++) {
            address user = usersToClose[i];
            ReservationData storage reservation = reservations[user];
            
            if (!reservation.isActive) continue;
            
            // 计算当前BAOFU的USDT价值
            uint256 currentBAOFUValue = _getBAOFUValueInUSDT(reservation.baofuAmount);
            bool isOver24Hours = block.timestamp >= reservation.timestamp + LOCK_PERIOD;
            bool is100PercentReturn = currentBAOFUValue >= reservation.originalMBNBValue * 2;
            
            // 检查是否满足自动关闭条件
            if ((!isOver24Hours && is100PercentReturn) || isOver24Hours) {
                // 计算收益率
                uint256 returnPercentage = (currentBAOFUValue * 100) / reservation.originalMBNBValue;
                
                uint256 returnAmount;
                uint256 profit;
                
                if (returnPercentage >= 200) {
                    // 达到或超过100%收益：强制平仓
                    // 1. 用户拿回原始投资金额等值的BAOFU
                    returnAmount = _calculateBAOFUAmountFromUSDT(reservation.originalMBNBValue);
                    
                    // 2. 利润部分的BAOFU用来支付推荐奖励
                    uint256 profitBAOFU = _calculateBAOFUAmountFromUSDT(reservation.originalMBNBValue); // 100%利润对应的BAOFU
                    
                    // 3. 超过200%的部分销毁
                    uint256 totalValidBAOFU = returnAmount + profitBAOFU; // 最多200%对应的BAOFU
                    if (reservation.baofuAmount > totalValidBAOFU) {
                        uint256 excessBAOFU = reservation.baofuAmount - totalValidBAOFU;
                        _burnExcessBAOFU(excessBAOFU);
                    }
                    
                    // 返还用户原始投资金额对应的BAOFU
                    require(mBAOFU.transfer(user, returnAmount), "BAOFU transfer failed");
                    
                    profit = reservation.originalMBNBValue; // 100%利润（以USDT计算）
                } else {
                    // 未达到100%收益：返还所有BAOFU
                    returnAmount = reservation.baofuAmount;
                    
                    // 返还用户所有BAOFU
                    require(mBAOFU.transfer(user, returnAmount), "BAOFU transfer failed");
                    
                    profit = currentBAOFUValue > reservation.originalMBNBValue ? 
                        currentBAOFUValue - reservation.originalMBNBValue : 0;
                }
                
                // 在删除预约数据之前支付推荐奖励
                _payReferralRewards(user);
                
                // 清除预约
                delete reservations[user];
                
                emit ReservationAutoClosed(user, returnAmount, profit, !isOver24Hours && is100PercentReturn);
            }
        }
    }

    /**
     * @dev 销毁多余的BAOFU
     * @param amount 要销毁的BAOFU数量
     */
    function _burnExcessBAOFU(uint256 amount) internal {
        // 将BAOFU转入死亡地址实现销毁（更安全的销毁方式）
        require(mBAOFU.transfer(BURN_ADDRESS, amount), "BAOFU burn failed");
    }

    /**
     * @dev 计算BAOFU的USDT价值
     * @param baofuAmount BAOFU数量
     * @return BAOFU的USDT价值
     */
    function _getBAOFUValueInUSDT(uint256 baofuAmount) internal view returns (uint256) {
        address[] memory path = new address[](2);
        path[0] = address(mBAOFU);
        path[1] = address(mUSDT);
        
        uint[] memory amounts = pancakeRouter.getAmountsOut(baofuAmount, path);
        return amounts[1];
    }
} 

