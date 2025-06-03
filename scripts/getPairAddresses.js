const hre = require("hardhat");

// 从最新部署日志中获取的合约地址
const DEPLOYED_ADDRESSES = {
  mBNB: "0xf8E64A6Ae0c3cF9bFD46DB1c91aB819ee7a15765",
  mUSDT: "0x5bB5fA3bb0cC07cF275a91A4c3db9332DcEE6Fb5", 
  mBAOFU: "0xA94ac1b1609f16A83373d40F9cDb5ACfB4d39b01",
  mREF: "0xd8222d4623eE0591Df204cD8894d639C6c72f9b0",
  Reservation: "0xCc9D192b0258a8b4995fA27d8995ca7dE2b7e73F",
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