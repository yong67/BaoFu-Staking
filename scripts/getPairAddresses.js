const hre = require("hardhat");

// 从最新部署日志中获取的合约地址
const DEPLOYED_ADDRESSES = {
  mBNB: "0xd4E51ed3E307af6030Bd2422BB1d71725007AF4c",
  mUSDT: "0xa69A1d501b8cc0FF39cC80f3aEA1337359097fa7", 
  mBAOFU: "0x997199F5a245F914F3ad659fe4918BC567801F00",
  mREF: "0xae19a1E1a28212336f92afa689E9679fd0B7357e",
  Reservation: "0x8386eaA2e9B41b0a4AD1085Fd33E94ed15FF7175",
  PancakeRouter: "0xD99D1c33F9fC3444f8101754aBC46c52416550D1",
  PancakeFactory: "0x6725F303b657a9451d8BA641348b6761A6CC7a17"
};

async function main() {
  console.log("正在获取流动性池地址...\n");

  // 获取PancakeFactory合约实例
  const pancakeFactory = await hre.ethers.getContractAt(
    "IPancakeFactory",
    DEPLOYED_ADDRESSES.PancakeFactory
  );

  try {
    // 获取mBNB/mUSDT Pair地址
    const mBNBUSDTPair = await pancakeFactory.getPair(
      DEPLOYED_ADDRESSES.mBNB,
      DEPLOYED_ADDRESSES.mUSDT
    );

    // 获取mBAOFU/mUSDT Pair地址
    const mBAOFUUSDTPair = await pancakeFactory.getPair(
      DEPLOYED_ADDRESSES.mBAOFU,
      DEPLOYED_ADDRESSES.mUSDT
    );

    // 获取mBNB/mBAOFU Pair地址（如果存在）
    const mBNBBAOFUPair = await pancakeFactory.getPair(
      DEPLOYED_ADDRESSES.mBNB,
      DEPLOYED_ADDRESSES.mBAOFU
    );

    console.log("=== 流动性池地址查询结果 ===");
    console.log(`mBNB/mUSDT Pair: ${mBNBUSDTPair}`);
    console.log(`mBAOFU/mUSDT Pair: ${mBAOFUUSDTPair}`);
    console.log(`mBNB/mBAOFU Pair: ${mBNBBAOFUPair}`);
    
    console.log("\n=== 验证结果 ===");
    console.log(`mBNB/mUSDT Pair 是否存在: ${mBNBUSDTPair !== "0x0000000000000000000000000000000000000000"}`);
    console.log(`mBAOFU/mUSDT Pair 是否存在: ${mBAOFUUSDTPair !== "0x0000000000000000000000000000000000000000"}`);
    console.log(`mBNB/mBAOFU Pair 是否存在: ${mBNBBAOFUPair !== "0x0000000000000000000000000000000000000000"}`);

    // 如果需要，可以获取pair合约的更多信息
    if (mBNBUSDTPair !== "0x0000000000000000000000000000000000000000") {
      console.log("\n=== mBNB/mUSDT Pair 详细信息 ===");
      const pairContract = await hre.ethers.getContractAt("IPancakePair", mBNBUSDTPair);
      
      const reserves = await pairContract.getReserves();
      const token0 = await pairContract.token0();
      const token1 = await pairContract.token1();
      
      console.log(`Token0: ${token0}`);
      console.log(`Token1: ${token1}`);
      console.log(`Reserve0: ${hre.ethers.formatEther(reserves[0])}`);
      console.log(`Reserve1: ${hre.ethers.formatEther(reserves[1])}`);
      console.log(`最后更新时间: ${new Date(Number(reserves[2]) * 1000).toLocaleString()}`);
    }

    if (mBAOFUUSDTPair !== "0x0000000000000000000000000000000000000000") {
      console.log("\n=== mBAOFU/mUSDT Pair 详细信息 ===");
      const pairContract = await hre.ethers.getContractAt("IPancakePair", mBAOFUUSDTPair);
      
      const reserves = await pairContract.getReserves();
      const token0 = await pairContract.token0();
      const token1 = await pairContract.token1();
      
      console.log(`Token0: ${token0}`);
      console.log(`Token1: ${token1}`);
      console.log(`Reserve0: ${hre.ethers.formatEther(reserves[0])}`);
      console.log(`Reserve1: ${hre.ethers.formatEther(reserves[1])}`);
      console.log(`最后更新时间: ${new Date(Number(reserves[2]) * 1000).toLocaleString()}`);
    }

  } catch (error) {
    console.error("获取流动性池地址时发生错误:", error.message);
  }

  console.log("\n=== 所有已部署合约地址 ===");
  for (const [name, address] of Object.entries(DEPLOYED_ADDRESSES)) {
    console.log(`${name}: ${address}`);
  }
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  }); 