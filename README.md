# BaoFu 智能合约项目

## Fork测试环境功能验证

项目在BSC测试网分叉环境中进行了全面的功能测试，按测试执行顺序包括:

### 1. 合约部署测试
- 代币合约部署(mBNB、mUSDT、mBAOFU、mREF)
- Reservation业务合约部署
- PancakeSwap Router和Factory接口验证

### 2. 流动性池设置测试
- mBNB/mUSDT交易对创建与验证
  - 初始价格设置为626 USDT/BNB
  - 流动性添加:15974.4 mBNB和1000万mUSDT
- mBAOFU/mUSDT交易对创建与验证
  - 初始价格设置为0.01 USDT/BAOFU
  - 流动性添加:50万mBAOFU和5000 mUSDT

### 3. mBNB价格波动测试
- 价格有效范围验证(500-800 USDT)
- 价格超出范围时的预约限制
- 价格恢复机制验证

### 4. mBAOFU价格波动测试
- 初始预约创建验证
- 价格上涨200%场景测试
- 白名单机制验证
- Chainlink Automation触发条件验证
- 手动平仓机制测试

### 5. 24小时自动平仓测试
- 初始预约状态验证
- 锁仓期检查(24小时)
- 自动平仓条件触发验证
- BAOFU代币余额结算验证




## Forking Test Environment
```bash
fu@Fu-work:~/HardhatProject/BaoFu$ npx hardhat test 


  BSC 测试网合约测试

=== 合约测试开始 ===
初始化测试环境...
主账户: 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266
测试账户列表:
- user1: 0x70997970C51812dc3A010C7d01b50e0d17dc79C8
- user2: 0x3C44CdDdB6a900fa2b585dd299e03d12FA4293BC
- user3: 0x90F79bf6EB2c4f870365E785982E1f101E93b906
- user4: 0x15d34AAf54267DB7D7c367839AAf71A00a2C6A65
- user5: 0x9965507D1a55bcC2695C58ba16FB37d819B0A4dc

=== 部署测试合约 ===

1. 部署代币合约
- mBNB 部署完成: 0x88909B84660f189846E2D3Bb7d8BE63243394678
- mUSDT 部署完成: 0x8cb14Db709c2554F4C2e826A7aBF976965434435
- mBAOFU 部署完成: 0x4235a0451D571b66f5c5A188111A2f845ca481F8
- mREF 部署完成: 0x6b72584Dc384B78f779c473091AB5089e5D30D68

2. 部署业务合约
- Reservation 合约部署完成: 0xC4aEaeBd6B15B404665d3865cc96F135C791f480

3. 获取 PancakeSwap 合约实例
- PancakeSwap Router: 0xD99D1c33F9fC3444f8101754aBC46c52416550D1
- PancakeSwap Factory: 0x6725F303b657a9451d8BA641348b6761A6CC7a17

=== 设置 PancakeSwap 交易对 ===

1. 创建 mBNB-mUSDT 交易对
- 交易对地址: 0x3BcA26D762082fbee724E6966Af9de9bCdb62e50

2. 创建 mBAOFU-mUSDT 交易对
- 交易对地址: 0x7b5935467FdBF40bD423bF248D6673eaa0E018C4

3. 设置 mBaoFu 的 PancakeSwap 交易对地址
- 设置完成: 0x7b5935467FdBF40bD423bF248D6673eaa0E018C4

=== 添加流动性 ===

1. 添加 mBNB-mUSDT 流动性
- mBNB 数量: 15974.4
- mUSDT 数量: 10000000.0
- 目标价格: 626 USDT/BNB
- 流动性添加完成

2. 添加 mBAOFU-mUSDT 流动性
- mBAOFU 数量: 500000.0
- mUSDT 数量: 5000.0
- 目标价格: 0.01 USDT/BAOFU
- 流动性添加完成

=== 设置合约关系 ===

1. 添加 PancakeSwap Router 到白名单
- Router 白名单状态: true

2. 添加 Reservation 合约到白名单
- Reservation 合约白名单状态: true

3. 设置 Reservation 合约在 mREF 中的授权
- Reservation 合约授权状态: true

4. 设置 Reservation 合约的授权状态
- Reservation 合约授权状态: true

5. 转移 mREF 代币到 Reservation 合约
- Reservation 合约 mREF 余额: 1000000.0 mREF

=== 测试环境准备完成 ===

    合约部署和配置测试

=== 验证合约部署状态 ===

1. 验证代币合约信息
- mBNB: Mock BNB (0x88909B84660f189846E2D3Bb7d8BE63243394678)
- mUSDT: Mock USDT (0x8cb14Db709c2554F4C2e826A7aBF976965434435)
- mBAOFU: Mock BAOFU (0x4235a0451D571b66f5c5A188111A2f845ca481F8)
- mREF: Mock REF (0x6b72584Dc384B78f779c473091AB5089e5D30D68)

2. 验证 PancakeSwap 交易对
- mBNB-mUSDT 交易对: 0x3BcA26D762082fbee724E6966Af9de9bCdb62e50
- mBAOFU-mUSDT 交易对: 0x7b5935467FdBF40bD423bF248D6673eaa0E018C4

3. 验证 mBaoFu 的 PancakeSwap 交易对地址
- 当前设置: 0x7b5935467FdBF40bD423bF248D6673eaa0E018C4
- 预期值: 0x7b5935467FdBF40bD423bF248D6673eaa0E018C4

合约部署和配置验证通过！
      ✔ 应该正确部署和配置所有合约
    流动性池测试

=== 验证流动性池状态 ===

1. 检查 mBNB-mUSDT 流动性池
- mBNB 储备量: 15974.4
- mUSDT 储备量: 10000000.0
- 当前价格: 626.0016025641025 USDT/BNB
- 目标价格: 626 USDT/BNB

2. 检查 mBAOFU-mUSDT 流动性池
- mBAOFU 储备量: 500000.0
- mUSDT 储备量: 5000.0
- 当前价格: 0.01 USDT/BAOFU
- 目标价格: 0.01 USDT/BAOFU

流动性池配置验证通过！
      ✔ 应该正确配置流动性池
    白名单功能测试

=== 测试白名单功能 ===

1. 验证已添加的白名单地址
- PancakeSwap Router (0xD99D1c33F9fC3444f8101754aBC46c52416550D1): true
- Reservation 合约 (0xC4aEaeBd6B15B404665d3865cc96F135C791f480): true

2. 验证未添加的地址
- 随机地址 (0x70997970C51812dc3A010C7d01b50e0d17dc79C8): false

3. 测试添加白名单
- 添加后状态 (0x70997970C51812dc3A010C7d01b50e0d17dc79C8): true

4. 测试移除白名单
- 移除后状态 (0x70997970C51812dc3A010C7d01b50e0d17dc79C8): false

白名单功能测试通过！
      ✔ 应该正确处理白名单状态 (929ms)
    预约排队功能测试

=== 测试预约排队功能 ===

1. 准备测试数据
- 转账金额: 0.32 mBNB (约 200.32 USDT)
- user1 余额: 0.32 mBNB
- user2 余额: 0.32 mBNB
- user3 余额: 0.32 mBNB

2. 用户授权
- 授权完成

3. 创建预约
- Reservation 合约 mBAOFU 余额: 0.0 mBAOFU
- user1 创建预约 (无推荐人)
- user2 创建预约 (推荐人: user1)
- user3 创建预约 (推荐人: user2)

4. 验证队列状态
- 队列长度: 3

5. 验证用户位置
- user1 位置: 0
- user2 位置: 1
- user3 位置: 2

6. 验证推荐关系
- user2 的推荐人: 0x70997970C51812dc3A010C7d01b50e0d17dc79C8
- user3 的推荐人: 0x3C44CdDdB6a900fa2b585dd299e03d12FA4293BC

预约排队功能测试通过！
      ✔ 应该正确处理预约排队 (38670ms)
    预约金额限制测试

=== 测试预约金额限制 ===

1. 测试金额过小
- 测试金额: 0.15 mBNB (约 93.90 USDT)
- 尝试创建预约...
- 预期失败: 金额过小

2. 测试金额过大
- 测试金额: 0.5 mBNB (约 313.00 USDT)
- 尝试创建预约...
- 预期失败: 金额过大

3. 测试有效金额
- 测试金额: 0.32 mBNB (约 200.32 USDT)
- 尝试创建预约...
- 预约创建成功

预约金额限制测试通过！
      ✔ 应该正确处理预约金额限制 (5287ms)
    锁仓和收益测试

=== 测试锁仓和收益功能 ===

1. 准备测试数据
- 测试用户地址: 0x1C110a0adeC4eAc9D4D8FB21efB429D73AFa6a25
- 转账金额: 0.32 mBNB (约 200.32 USDT)
- 测试用户 mBNB 余额: 0.32 mBNB

2. 用户授权
- 授权完成

3. 检查用户当前状态
- 用户是否有活跃预约: false

4. 创建预约
- 预约创建成功

5. 验证锁仓状态
- 预约金额: 0.32 mBNB
- 预约时间: 6/4/2025, 2:22:09 PM
- 预约状态: 活跃
- BAOFU 数量: 14338.031546473559975561 mBAOFU

6. 尝试提前关闭预约
- 尝试关闭预约...
- 预期失败: 锁仓期未结束

7. 等待锁仓期结束
- 当前时间: 6/4/2025, 2:23:34 PM
- 等待 24 小时...
- 新时间: 6/5/2025, 2:23:34 PM

8. 检查预约状态（锁仓期后）
- 预约状态: 活跃
- BAOFU 数量: 14338.031546473559975561 mBAOFU

9. 验证可以关闭预约
- 尝试关闭预约...
- Reservation 合约 mBAOFU 余额: 83149.396156433525881259 mBAOFU
- 用户关闭前 mBAOFU 余额: 0.0 mBAOFU
- 预约关闭成功

10. 验证最终状态
- 最终状态: 已关闭
- 最终 mBAOFU 余额: 14338.031546473559975561 mBAOFU
- 收到 mBAOFU 数量: 14338.031546473559975561 mBAOFU
- 最终验证：预约已关闭
- 清理：从白名单中移除测试用户

锁仓和收益测试通过！
      ✔ 应该正确处理锁仓和收益 (13338ms)
    推荐系统测试

=== 测试推荐系统 ===

1. 准备测试数据
- testUser1: 0x4e443f47BA592d0497A233F05de051C2647Ff16f
- testUser2: 0xB61f67695228Dd8D8e24c0a13195F62A9b8FF380
- testUser3: 0x2E6807838759d19b87adC26a2172eCF11bc69d1e
- testUser4: 0x6275fFa2e4B3D6372AD607490E1B8D415756C0Ed
- testUser5: 0x75c6b3FeA2C8288B2f29f2a1E71a18B4E6FA13f0

2. 准备 ETH 和代币

3. 创建推荐链
- 转账金额: 0.32 mBNB (约 200.32 USDT)
- testUser1 余额: 0.32 mBNB
- testUser2 余额: 0.32 mBNB
- testUser3 余额: 0.32 mBNB
- testUser4 余额: 0.32 mBNB
- testUser5 余额: 0.32 mBNB

4. 用户授权
- 授权完成

5. 检查初始推荐关系状态
- testUser1 推荐人: 0x0000000000000000000000000000000000000000
- testUser2 推荐人: 0x0000000000000000000000000000000000000000
- testUser3 推荐人: 0x0000000000000000000000000000000000000000
- testUser4 推荐人: 0x0000000000000000000000000000000000000000
- testUser5 推荐人: 0x0000000000000000000000000000000000000000

6. 创建推荐关系
- testUser1 创建预约 (无推荐人)
- testUser2 创建预约 (推荐人: testUser1)
- testUser3 创建预约 (推荐人: testUser1)
- testUser4 创建预约 (推荐人: testUser1)
- testUser5 创建预约 (推荐人: testUser2)

7. 验证推荐关系
- testUser2 的推荐人: 0x4e443f47BA592d0497A233F05de051C2647Ff16f
- testUser3 的推荐人: 0x4e443f47BA592d0497A233F05de051C2647Ff16f
- testUser4 的推荐人: 0x4e443f47BA592d0497A233F05de051C2647Ff16f
- testUser5 的推荐人: 0xB61f67695228Dd8D8e24c0a13195F62A9b8FF380

8. 验证推荐人数
- testUser1 的推荐人数: 3
- testUser2 的推荐人数: 1

推荐系统测试通过！
      ✔ 应该正确处理推荐关系 (51738ms)
    推荐返佣测试

=== 测试推荐返佣功能 ===

1. 准备推荐链
- 第一层推荐人: 0x736735d46d8414FE49Fa0aA6eaf66b69b1eC2b96
- 第二层推荐人: 0x5b0bB0CF525B7d69bC1CE8DBb70F77D5AD2C7Ec7
- 投资人: 0xe9360ED72a8884F4913cCa2Db9dBd674C8FC3bC0

2. 建立推荐关系
- referrer1 创建预约 (无推荐人)
- referrer2 创建预约 (推荐人: referrer1)
- investor 创建预约 (推荐人: referrer2)

3. 验证推荐关系
- referrer2 的推荐人: 0x736735d46d8414FE49Fa0aA6eaf66b69b1eC2b96
- investor 的推荐人: 0x5b0bB0CF525B7d69bC1CE8DBb70F77D5AD2C7Ec7
- referrer1 推荐人数: 1
- referrer2 推荐人数: 1

4. 记录关闭前的BAOFU余额
- referrer1 关闭前BAOFU余额: 0.0
- referrer2 关闭前BAOFU余额: 0.0

5. 等待锁仓期结束
- 锁仓期结束

6. 创造盈利空间：操纵mBAOFU价格上涨
- 添加投资人到mBAOFU白名单
  当前价格: 0.023075 USDT/BAOFU
- 价格操纵后: 0.073839 USDT/BAOFU
- 价格涨幅: 220.00%

7. 投资人关闭预约
- 投资人BAOFU数量: 8875.850795995325768287

8. 详细利润计算
- 当前BAOFU价值: 624.057977854508824407 USDT
- 原始投资价值: 199.811897980586771169 USDT
- 利润金额: 424.246079873922053238 USDT
- 收益率: 212%
- 是否有利润: true

9. 检查推荐奖励资格
- referrer2 推荐人数: 1 (需要>=3才能拿第一代1.5%)
- referrer1 推荐人数: 1 (需要>=3才能拿第二代1%)
- 根据ProjectDescription，两人都不满足推荐奖励条件

10. 验证推荐奖励结果
- 检测到 0 个推荐奖励支付事件
- 未检测到推荐奖励支付事件（符合预期，因为推荐人数不足）
- referrer1 关闭后BAOFU余额: 0.0
- referrer2 关闭后BAOFU余额: 0.0
- referrer1 获得奖励: 0.0 mBAOFU
- referrer2 获得奖励: 0.0 mBAOFU
- ✅ 验证通过：推荐人数不足，未获得奖励（符合ProjectDescription）

推荐返佣测试通过！
      ✔ 应该正确支付推荐奖励 (28957ms)

=== 测试多层级推荐奖励 ===

1. 准备有利润的测试场景
- user1 (推荐6人): 0xa063C8d8bfef32F96EaF1c1bd393e6e5aea74bf4
- user2 (推荐3人): 0x10Dc7e6959C0fA219D7d67D333431Cf5fFa783C1
- finalUser: 0xbF316217A220B251e7b9706BFE4681AC36569DA5

2. 建立推荐关系
- 创建基础预约
- user1的其他推荐人
- user2的其他推荐人
- 最终投资人

3. 验证推荐关系
- user1 推荐人数: 6 (应该=6，可拿第二代1%)
- user2 推荐人数: 3 (应该=3，可拿第一代1.5%)

4. 记录关闭前余额
- user1 关闭前BAOFU余额: 0.0
- user2 关闭前BAOFU余额: 0.0

5. 等待锁仓期结束

6. 创造盈利空间：操纵mBAOFU价格上涨
- 添加finalUser到mBAOFU白名单
  当前价格: 0.097102 USDT/BAOFU
- 价格操纵后: 0.261341 USDT/BAOFU
- 价格涨幅: 169.14%

7. finalUser 关闭预约

8. 详细利润计算
- 当前BAOFU价值: 531.122719259866170236 USDT
- 原始投资价值: 199.731970804368386904 USDT
- 利润金额: 331.390748455497783332 USDT
- 收益率: 165%
- 是否有利润: true

9. 检查推荐奖励资格
- user2 推荐人数: 3 (>=3，第一层，可以拿第一代1.5%) - 符合条件
- user1 推荐人数: 6 (>=6，第二层，可以拿第二代1%) - 符合条件
- 预期user2奖励: 4.970861226832466749 USDT (1.5%)
- 预期user1奖励: 3.313907484554977833 USDT (1%)

10. 验证推荐奖励结果
- 检测到 2 个推荐奖励支付事件
- 事件 1:
  推荐人: 0x10Dc7e6959C0fA219D7d67D333431Cf5fFa783C1
  奖励金额: 18.978448793626428525 mBAOFU
  推荐层级: 1
- 事件 2:
  推荐人: 0xa063C8d8bfef32F96EaF1c1bd393e6e5aea74bf4
  奖励金额: 12.653116475969868926 mBAOFU
  推荐层级: 2
- user1 获得奖励: 12.653116475969868926 mBAOFU
- user2 获得奖励: 18.978448793626428525 mBAOFU
- ✅ user2 获得第一代推荐奖励（>=3人推荐，第一层1.5%）
- ✅ user1 获得第二代推荐奖励（>=6人推荐，第二层1%）

多层级推荐奖励测试通过！
      ✔ 应该正确处理多层级推荐奖励 (76808ms)
    价格波动测试

=== 初始化价格波动测试环境 ===

1. 验证合约实例
- mBNB 地址: 0x88909B84660f189846E2D3Bb7d8BE63243394678
- mUSDT 地址: 0x8cb14Db709c2554F4C2e826A7aBF976965434435
- mBAOFU 地址: 0x4235a0451D571b66f5c5A188111A2f845ca481F8
- PancakeFactory 地址: 0x6725F303b657a9451d8BA641348b6761A6CC7a17

2. 获取交易对地址
- mBNB-mUSDT 交易对地址: 0x3BcA26D762082fbee724E6966Af9de9bCdb62e50
- mBAOFU-mUSDT 交易对地址: 0x7b5935467FdBF40bD423bF248D6673eaa0E018C4

3. 获取交易对合约实例

4. 验证合约实例
- mBNB-mUSDT 池子状态:
  mBNB 储备量: 15981.76
  mUSDT 储备量: 9995403.958306045197199432
- mBAOFU-mUSDT 池子状态:
  mBAOFU 储备量: 97941.325207210189650845
  mUSDT 储备量: 25596.041693954802800568

=== 测试 mBNB 价格波动 ===

1. 准备测试数据

2. 测试场景1：价格在范围内
- 预约创建成功

3. 测试场景2：价格过低
- 当前价格: 625.400712944450336177
- 目标价格: 90
- 需要添加的 mBNB 数量: 95075.74473705823143125
- 价格操纵完成，尝试创建预约...
- 预期失败：金额超出范围
      ✔ 应该正确处理 mBNB 价格波动 (16940ms)

=== 测试 mBAOFU 价格波动 ===

1. 准备测试数据

2. 检查当前价格状态
- 当前 mBNB 价格: 12.97 USDT/BNB
- 价格超出范围，恢复价格到有效范围...

3. 创建初始预约
- 初始预约创建成功
- 获得的 BAOFU 数量: 1036.456725802915925312

4. 测试场景1：价格达到 200%
- 当前池子状态:
  BAOFU 储备量: 96148.031626588736592349
  USDT 储备量: 26074.40425369861141328
- 添加测试用户到mBAOFU白名单...
- 测试用户白名单状态: true
- 通过买入大量BAOFU提高价格...
- 价格操纵后池子状态:
  BAOFU 储备量: 80703.387206615543078746
  USDT 储备量: 31074.40425369861141328
- 新的 BAOFU 价格: 0.385045 USDT/BAOFU
- 模拟 Chainlink Automation...
- 调试信息:
  预约BAOFU数量: 1036.456725802915925312
  原始mBNB数量: 0.32 mBNB
  当前BAOFU的USDT价值: 393.243666150719252652 USDT
  原始投资USDT价值（重新计算）: 278.617446780814571474 USDT
  收益率: 141%
  是否达到100%收益（200%总价值）: false
  条件: 393.243666150719252652 >= 557.234893561629142948
  时间差: 3604 秒 (1.00 小时)
  是否超过24小时: false
- Chainlink Automation 结果: false
- 最终预约状态: 活跃
- Chainlink Automation 未触发或失败
- 预约仍然活跃，尝试手动关闭
- 需要等待 82796 秒直到锁仓期结束
- 预约手动关闭成功
- 最终验证：预约已关闭
- 清理：从白名单中移除测试用户
      ✔ 应该正确处理 mBAOFU 价格波动 (8780ms)

=== 测试24小时自动平仓 ===

1. 准备测试数据

2. 检查当前价格状态
- 当前 mBNB 价格: 872.44 USDT/BNB
- 价格超出范围，恢复价格到有效范围...
- 价格恢复完成

3. 创建初始预约
- 初始预约创建成功
- 获得的 BAOFU 数量: 715.746275253622426594
- 原始投资价值: 0.32 mBNB
- 预约时间戳: 6/8/2025, 2:26:03 PM

4. 验证当前不满足自动平仓条件
- 当前是否需要执行自动平仓: false

5. 等待24小时锁仓期结束
- 等待时间: 24 小时
- 锁仓期结束

6. 验证现在满足自动平仓条件
- 现在是否需要执行自动平仓: true

7. 执行自动平仓
- Chainlink Automation 执行成功
- 预约已被自动关闭
- 用户最终 BAOFU 余额: 715.746275253622426594 mBAOFU

24小时自动平仓测试完成！
      ✔ 应该正确处理24小时自动平仓 (8423ms)


  12 passing (5m)
```

## 项目概述

BaoFu是一个基于BNB Chain测试网的智能合约项目，实现了代币预约、锁仓和收益分配机制。项目使用Hardhat开发框架，并在BSC测试网上部署。

## 合约架构

项目包含以下主要合约(地址已验证)：

1. **MockToken** - 模拟代币合约
   - mBNB: `0xd4E51ed3E307af6030Bd2422BB1d71725007AF4c`
   - mUSDT: `0xa69A1d501b8cc0FF39cC80f3aEA1337359097fa7`

2. **MockBAOFU** - BAOFU代币合约
   - 地址: `0x997199F5a245F914F3ad659fe4918BC567801F00`
   - 特点: 包含白名单机制

3. **MockREF** - 推荐系统代币合约
   - 地址: `0xae19a1E1a28212336f92afa689E9679fd0B7357e`
   - 功能: 管理推荐关系和奖励

4. **Reservation** - 核心预约合约
   - 地址: `0x8386eaA2e9B41b0a4AD1085Fd33E94ed15FF7175`
   - 主要功能:
     - 用户预约机制
     - 24小时锁仓
     - 收益计算和分配
     - 推荐奖励系统

## 流动性池

项目在PancakeSwap上创建了两个主要流动性池：

1. **mBNB/mUSDT Pair**
   - 地址: `0x4cadE510A57c86613a49ED2A58b9c4366523E7B0`
   - 储备量:
     - mUSDT: 10,000,000
     - mBNB: 15,974.44

2. **mBAOFU/mUSDT Pair**
   - 地址: `0xDBdD192b6282f210e7DB22677C3a54C813Fb9A71`
   - 储备量:
     - mBAOFU: 500,000
     - mUSDT: 5,000

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
