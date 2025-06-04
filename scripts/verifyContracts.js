const hre = require("hardhat");

// 已部署的合约地址
const DEPLOYED_ADDRESSES = {
  mBNB: "0xd4E51ed3E307af6030Bd2422BB1d71725007AF4c",
  mUSDT: "0xa69A1d501b8cc0FF39cC80f3aEA1337359097fa7", 
  mBAOFU: "0x997199F5a245F914F3ad659fe4918BC567801F00",
  mREF: "0xae19a1E1a28212336f92afa689E9679fd0B7357e",
  Reservation: "0x8386eaA2e9B41b0a4AD1085Fd33E94ed15FF7175"
};

async function verifyContract(contractAddress, contractName, constructorArguments = []) {
  console.log(`\n正在验证 ${contractName} 合约...`);
  console.log(`地址: ${contractAddress}`);
  
  try {
    await hre.run("verify:verify", {
      address: contractAddress,
      constructorArguments: constructorArguments,
      network: "testnet"
    });
    console.log(`✅ ${contractName} 验证成功!`);
  } catch (error) {
    if (error.message.toLowerCase().includes("already verified")) {
      console.log(`✅ ${contractName} 已经验证过了`);
    } else {
      console.error(`❌ ${contractName} 验证失败:`, error.message);
    }
  }
}

async function main() {
  console.log("=== 开始验证所有合约 ===\n");

  // 1. 验证 MockToken (mBNB)
  await verifyContract(
    DEPLOYED_ADDRESSES.mBNB,
    "MockToken (mBNB)",
    [
      "Mock BNB",           // name
      "mBNB",              // symbol
      hre.ethers.parseEther("100000")  // totalSupply
    ]
  );

  // 2. 验证 MockToken (mUSDT)
  await verifyContract(
    DEPLOYED_ADDRESSES.mUSDT,
    "MockToken (mUSDT)",
    [
      "Mock USDT",         // name
      "mUSDT",            // symbol
      hre.ethers.parseEther("100000000")  // totalSupply
    ]
  );

  // 3. 验证 MockBAOFU
  await verifyContract(
    DEPLOYED_ADDRESSES.mBAOFU,
    "MockBAOFU",
    [
      "Mock BAOFU",        // name
      "mBAOFU",           // symbol
      hre.ethers.parseEther("1000000")  // totalSupply
    ]
  );

  // 4. 验证 MockREF
  await verifyContract(
    DEPLOYED_ADDRESSES.mREF,
    "MockREF",
    [
      "Mock REF",          // name
      "mREF",             // symbol
      hre.ethers.parseEther("10000000000")  // totalSupply
    ]
  );

  // 5. 验证 Reservation 合约
  await verifyContract(
    DEPLOYED_ADDRESSES.Reservation,
    "Reservation",
    [
      DEPLOYED_ADDRESSES.mBNB,    // _mBNB
      DEPLOYED_ADDRESSES.mUSDT,   // _mUSDT
      DEPLOYED_ADDRESSES.mBAOFU,  // _mBAOFU
      DEPLOYED_ADDRESSES.mREF,    // _mREF
      "0xD99D1c33F9fC3444f8101754aBC46c52416550D1"  // _pancakeRouter
    ]
  );

  console.log("\n=== 验证完成 ===");
  console.log("\n验证后的合约可以在以下链接查看:");
  for (const [name, address] of Object.entries(DEPLOYED_ADDRESSES)) {
    console.log(`${name}: https://testnet.bscscan.com/address/${address}#code`);
  }
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  }); 