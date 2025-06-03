const hre = require("hardhat");

// 用户操作脚本：演示如何 approve 和创建预约
async function main() {
  // 从部署的合约地址获取合约实例 (需要先运行 deploy.js)
  // 这里需要替换为实际的部署地址
  const contractAddresses = {
    mBNB: "0x...", // 需要替换为实际地址
    mUSDT: "0x...", // 需要替换为实际地址 
    mBAOFU: "0x...", // 需要替换为实际地址
    mREF: "0x...", // 需要替换为实际地址
    reservation: "0x..." // 需要替换为实际地址
  };

  const [deployer, user1, user2, referrer] = await hre.ethers.getSigners();
  console.log("User address:", user1.address);
  console.log("Referrer address:", referrer.address);

  // 获取合约实例
  const mBNB = await hre.ethers.getContractAt("MockToken", contractAddresses.mBNB);
  const mUSDT = await hre.ethers.getContractAt("MockToken", contractAddresses.mUSDT);
  const mBAOFU = await hre.ethers.getContractAt("MockBAOFU", contractAddresses.mBAOFU);
  const mREF = await hre.ethers.getContractAt("MockREF", contractAddresses.mREF);
  const reservation = await hre.ethers.getContractAt("Reservation", contractAddresses.reservation);

  console.log("\n=== Step 1: 给用户转一些 mBNB 代币 ===");
  // 从部署者账户给用户转一些 mBNB
  const transferAmount = hre.ethers.parseEther("1"); // 1 mBNB
  await mBNB.connect(deployer).transfer(user1.address, transferAmount);
  console.log(`Transferred ${hre.ethers.formatEther(transferAmount)} mBNB to user`);

  // 检查用户余额
  const userBalance = await mBNB.balanceOf(user1.address);
  console.log(`User mBNB balance: ${hre.ethers.formatEther(userBalance)}`);

  console.log("\n=== Step 2: 用户 Approve mBNB 给 Reservation 合约 ===");
  // 用户需要预约的金额 (相当于 200 USDT 价值的 mBNB)
  const reservationAmount = hre.ethers.parseEther("200").mul(hre.ethers.parseEther("1")).div(626); // 200*1e18/626
  console.log(`Reservation amount: ${hre.ethers.formatEther(reservationAmount)} mBNB (≈ 200 USDT)`);

  // 检查用户是否有足够的余额
  if (userBalance < reservationAmount) {
    console.error("用户 mBNB 余额不足！");
    return;
  }

  // 用户 approve mBNB 给 Reservation 合约
  console.log("用户正在 approve mBNB...");
  const approveTx = await mBNB.connect(user1).approve(reservation.target, reservationAmount);
  await approveTx.wait();
  console.log("✅ mBNB approval 成功!");

  // 检查 allowance
  const allowance = await mBNB.allowance(user1.address, reservation.target);
  console.log(`Allowance: ${hre.ethers.formatEther(allowance)} mBNB`);

  console.log("\n=== Step 3: 用户创建预约 ===");
  try {
    const createTx = await reservation.connect(user1).createReservation(
      reservationAmount,
      referrer.address // 推荐人地址
    );
    await createTx.wait();
    console.log("✅ 预约创建成功!");

    // 查看预约信息
    const reservationInfo = await reservation.getReservationInfo(user1.address);
    console.log("\n预约信息:");
    console.log(`- 金额: ${hre.ethers.formatEther(reservationInfo.amount)} mBNB`);
    console.log(`- 时间戳: ${reservationInfo.timestamp}`);
    console.log(`- 是否激活: ${reservationInfo.isActive}`);
    console.log(`- BAOFU 数量: ${hre.ethers.formatEther(reservationInfo.baofuAmount)}`);

    // 查看推荐信息
    const referralInfo = await reservation.getReferralInfo(user1.address);
    console.log("\n推荐信息:");
    console.log(`- 推荐人: ${referralInfo.referrer}`);
    console.log(`- 推荐数量: ${referralInfo.referralCount}`);
    console.log(`- 最大级别: ${referralInfo.maxLevel}`);

  } catch (error) {
    console.error("创建预约失败:", error.message);
  }

  console.log("\n=== Step 4: 模拟时间过去 24 小时后关闭预约 ===");
  // 注意：在实际网络中需要等待 24 小时，这里只是演示
  console.log("⏰ 等待锁定期结束... (实际环境需要等待 24 小时)");
  
  // 在测试环境中，你可以使用 hardhat 的时间控制功能
  if (hre.network.name === "hardhat") {
    // 快进 24 小时
    await hre.network.provider.send("evm_increaseTime", [24 * 60 * 60]);
    await hre.network.provider.send("evm_mine");
    console.log("⏰ 时间已快进 24 小时");

    // 尝试关闭预约
    try {
      const closeTx = await reservation.connect(user1).closeReservation();
      await closeTx.wait();
      console.log("✅ 预约关闭成功!");

      // 检查用户的 BAOFU 余额
      const baofuBalance = await mBAOFU.balanceOf(user1.address);
      console.log(`用户获得的 BAOFU: ${hre.ethers.formatEther(baofuBalance)}`);

    } catch (error) {
      console.error("关闭预约失败:", error.message);
    }
  } else {
    console.log("在真实网络上，请等待 24 小时后再调用 closeReservation()");
  }
}

// 辅助函数：通过合约地址获取合约实例
async function getContractsFromAddresses() {
  console.log("请首先运行 deploy.js 获取合约地址，然后更新此脚本中的地址");
  console.log("或者使用 getDeployedContracts.js 脚本获取地址");
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  }); 