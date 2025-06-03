# BaoFu 智能合约项目

## 项目概述

BaoFu是一个基于BNB Chain测试网的智能合约项目，实现了代币预约、锁仓和收益分配机制。项目使用Hardhat开发框架，并在BSC测试网上部署。

## 合约架构

项目包含以下主要合约(地址已验证)：

1. **MockToken** - 模拟代币合约
   - mBNB: `0xf8E64A6Ae0c3cF9bFD46DB1c91aB819ee7a15765`
   - mUSDT: `0x5bB5fA3bb0cC07cF275a91A4c3db9332DcEE6Fb5`

2. **MockBAOFU** - BAOFU代币合约
   - 地址: `0xA94ac1b1609f16A83373d40F9cDb5ACfB4d39b01`
   - 特点: 包含白名单机制

3. **MockREF** - 推荐系统代币合约
   - 地址: `0xd8222d4623eE0591Df204cD8894d639C6c72f9b0`
   - 功能: 管理推荐关系和奖励

4. **Reservation** - 核心预约合约
   - 地址: `0xCc9D192b0258a8b4995fA27d8995ca7dE2b7e73F`
   - 主要功能:
     - 用户预约机制
     - 24小时锁仓
     - 收益计算和分配
     - 推荐奖励系统

## 流动性池

项目在PancakeSwap上创建了两个主要流动性池：

1. **mBNB/mUSDT Pair**
   - 地址: `0x94dd43b732Bf4908F5256de91508b17F953bb8E3`
   - 储备量:
     - mUSDT: 10,000,000
     - mBNB: 15,974.44

2. **mBAOFU/mUSDT Pair**
   - 地址: `0x714E66A0E29218E5D587dFF57ae40C710945bBf3`

## 部署信息

- **网络**: BSC Testnet
- **PancakeSwap Router**: `0xD99D1c33F9fC3444f8101754aBC46c52416550D1`
- **PancakeSwap Factory**: `0x6725F303b657a9451d8BA641348b6761A6CC7a17`

## 主要功能

1. **预约机制**
   - 用户使用mBNB进行预约
   - 预约金额限制: 100-300 USDT等值
   - 自动兑换为BAOFU代币

2. **锁仓机制**
   - 强制24小时锁仓期
   - 使用队列系统管理锁仓顺序

3. **收益计算**
   - 24小时内达到100%收益率时强制平仓
   - 超过24小时按实时BAOFU币价计算
   - 多余利润通过销毁机制处理

4. **推荐奖励系统**
   - 最多8代推荐奖励
   - 奖励比例:
     - 第一代(3人): 1.5%
     - 第二代(6人): 1.0%
     - 第三代(9人): 1.0%
     - 第四代(12人): 0.5%
     - 第五代(15人): 0.5%
     - 第六到八代(20人): 0.3%


## 当前限制和需要改进的地方

### ⚠️ 重要注意事项

#### 1. 用户操作前置要求
- **代币授权必需**: 用户在调用 `createReservation()` 前必须先调用 `mBNB.approve(reservationContract, amount)` 授权合约使用其mBNB代币
- **推荐人授权**: 建立推荐关系时，理论上应该由推荐人给下级打推荐币并提供签名授权，但当前实现中为方便测试，直接由合约给下级用户打推荐币

#### 2. Chainlink Automation 未配置
- **自动化功能未激活**: 虽然合约已实现 `checkUpkeep` 和 `performUpkeep` 函数，但尚未在 Chainlink Automation 官网注册和配置
- **手动平仓**: 目前24小时锁仓到期或达到100%收益时需要手动关闭预约，无法自动执行

#### 3. 安全性和测试状态
- **⚠️ 未经全面测试**: 合约尚未进行充分的单元测试和集成测试
- **⚠️ 未经安全审计**: 合约代码未经过专业安全审计，可能存在安全漏洞
- **⚠️ Gas 优化不足**: 合约代码未针对Gas消耗进行优化，可能导致交易成本较高

### 🔧 技术债务和改进建议

#### 1. 推荐系统改进
```solidity
// 当前实现 (在 createReservation 函数中)
// 原则上是推荐人给下级打推荐币(还要加入初始推荐人的mREF来源)，这要求推荐人的签名或approve
// 在实际情况中，推荐机制应引入推荐人对打推荐币的签名
// 这里为了方便，直接让合约给下级打推荐币
require(mREF.transfer(msg.sender, REF_TOKEN_AMOUNT), "REF transfer failed");
```

**建议改进**:
- 实现基于签名的推荐机制
- 推荐人需要提供签名授权给下级用户
- 使用 EIP-712 标准的类型化签名

#### 2. 白名单机制优化
```solidity
// 当前实现 (在 MockBAOFU.sol 中)
//白名单。若后续业务白名单较长，可以考虑用MerkleRoot来存储白名单,merkleproof加签名验证，减小gas消耗
mapping(address => bool) public whitelist;
```

**建议改进**:
- 对于大量地址的白名单，使用 Merkle Tree 存储
- 结合 Merkle Proof 和签名验证
- 显著降低 Gas 消耗

#### 3. Permit 支持
```solidity
/* 支持 permit 的一步式预约函数，当然原生BNB不支持permmit
function createReservationWithPermit(...) external nonReentrant {
    // 实现被注释掉了
}
*/
```

**建议改进**:
- 完善 `createReservationWithPermit` 函数实现
- 支持一步式授权和预约操作
- 提升用户体验

#### 4. 自动化配置
当前部署脚本中 Chainlink Automation 注册部分被注释:
```javascript
//   // Register with Chainlink Automation
//   console.log("Registering with Chainlink Automation...");
//   // ... 注册代码被注释
```

**需要完成**:
- 在 [Chainlink Automation](https://automation.chain.link/) 官网注册 Upkeep
- 配置触发条件和 Gas 限制
- 启用自动平仓功能

### 📋 待办清单

#### 高优先级
- [ ] **安全审计**: 进行专业的智能合约安全审计
- [ ] **全面测试**: 编写完整的单元测试和集成测试
- [ ] **Gas 优化**: 优化合约代码以降低 Gas 消耗
- [ ] **Chainlink 配置**: 完成 Chainlink Automation 的注册和配置

#### 中优先级
- [ ] **推荐签名机制**: 实现基于签名的推荐系统
- [ ] **Merkle 白名单**: 优化白名单存储机制
- [ ] **Permit 支持**: 完善一步式授权功能
- [ ] **错误处理**: 改善错误信息和异常处理

#### 低优先级
- [ ] **前端集成**: 开发用户友好的前端界面
- [ ] **事件监控**: 添加更详细的事件日志
- [ ] **文档完善**: 补充 API 文档和用户指南

### 🚨 风险提示

1. **智能合约风险**: 合约可能存在漏洞，请谨慎使用
2. **流动性风险**: PancakeSwap 流动性不足可能影响交易
3. **价格波动风险**: 代币价格剧烈波动可能导致损失
4. **测试环境**: 当前部署在测试网，仅供开发测试使用


## 开发环境设置

1. 安装依赖:
```bash
npm install
```

2. 配置环境变量:
创建 `.env` 文件并设置:
```
RPC_URL=https://data-seed-prebsc-1-s1.binance.org:8545/
PRIVATE_KEY=你的私钥
BSC_SCAN_API_KEY=你的bscAPI

```

3. 编译合约:
```bash
npx hardhat compile
```

4. 部署合约:
```bash
npx hardhat run scripts/deploy.js --network testnet
```

## 测试

运行测试:
```bash
npx hardhat test
```

## 工具脚本

1. 获取流动性池信息:
```bash
npx hardhat run scripts/getPairAddresses.js --network testnet
```

## 注意事项

1. 确保测试网账户有足够的BNB支付gas费
2. 部署前检查所有合约地址配置
3. 注意代币授权和流动性池设置


## 许可证

MIT License
