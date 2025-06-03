const hre = require("hardhat");

// 部署合约
// 部署mBNB/mUSDT池
// 部署mBAOFU/mUSDT池
// 部署Reservation合约
// 由于部署在测试网，Chainlink相关部分已注释

async function main() {
  const [deployer] = await hre.ethers.getSigners();
  console.log("Deploying contracts with the account:", deployer.address);

  // Deploy MockToken for mBNB
  //超额10倍铸造，池子需要1e7/626=15974.44个mBNB,
  //后续填池为减小误差，应加上decimal先乘后除，即是1e7*e18/626个最小单位的mBNB
  const MockToken = await hre.ethers.getContractFactory("MockToken");
  const mBNB = await MockToken.deploy("Mock BNB", "mBNB", hre.ethers.parseEther("100000"));
  await mBNB.waitForDeployment();
  console.log("mBNB deployed to:", await mBNB.getAddress());

  // Deploy MockToken for mUSDT
  //超额10倍铸造，池子需求mBNB池的1e7+BAOFU池的5000=10005000个mUSDT
  const mUSDT = await MockToken.deploy("Mock USDT", "mUSDT", hre.ethers.parseEther("100000000"));
  await mUSDT.waitForDeployment();
  console.log("mUSDT deployed to:", await mUSDT.getAddress());

  // Deploy MockBAOFU
  //超额10倍铸造，池子需求1e5个mBAOFU
  const MockBAOFU = await hre.ethers.getContractFactory("MockBAOFU");
  const mBAOFU = await MockBAOFU.deploy("Mock BAOFU", "mBAOFU", hre.ethers.parseEther("1000000"));
  await mBAOFU.waitForDeployment();
  console.log("mBAOFU deployed to:", await mBAOFU.getAddress());

  // Deploy MockREF
  const MockREF = await hre.ethers.getContractFactory("MockREF");
  const mREF = await MockREF.deploy("Mock REF", "mREF", hre.ethers.parseEther("10000000000"));
  await mREF.waitForDeployment();
  console.log("mREF deployed to:", await mREF.getAddress());


  /**
   * 开始部署池子，先部署mBNB/mUSDT池，再部署mBAOFU/mUSDT池
   */
  // Get PancakeSwap Router and Factory
  const pancakeRouter = await hre.ethers.getContractAt(
    "IPancakeRouter02",
    "0xD99D1c33F9fC3444f8101754aBC46c52416550D1"
  );
  const pancakeFactory = await hre.ethers.getContractAt(
    "IPancakeFactory",
    await pancakeRouter.factory()
  );

  // Add liquidity for mBNB/mUSDT pair
  console.log("Adding liquidity for mBNB/mUSDT pair...");
  //先乘后除，避免精度丢失
  const mBNBAmount = hre.ethers.parseEther("10000000") / BigInt(626); // 1e7*1e18/626
  const mUSDTAmount = hre.ethers.parseEther("10000000");
  
  // Approve tokens
  await mBNB.approve(pancakeRouter.target, mBNBAmount);
  await mUSDT.approve(pancakeRouter.target, mUSDTAmount);
  
  // Add liquidity
  await pancakeRouter.addLiquidity(
    await mBNB.getAddress(),
    await mUSDT.getAddress(),
    mBNBAmount,
    mUSDTAmount,
    0, // Accept any amount of tokens
    0, // Accept any amount of tokens
    deployer.address,
    Math.floor(Date.now() / 1000) + 60 * 20 // 20 minutes deadline
  );
  console.log("mBNB/mUSDT liquidity added");

  // Add PancakeSwap Router to mBAOFU whitelist first
  console.log("Adding PancakeSwap Router to mBAOFU whitelist...");
  await mBAOFU.addToWhitelist(pancakeRouter.target);
  console.log("PancakeSwap Router added to whitelist");

  // Add liquidity for mBAOFU/mUSDT pair
  console.log("Adding liquidity for mBAOFU/mUSDT pair...");
  const mBAOFUAmount = hre.ethers.parseEther("500000"); // 5000/0.01
  const mUSDTAmount2 = hre.ethers.parseEther("5000");
  
  // Approve tokens
  await mBAOFU.approve(pancakeRouter.target, mBAOFUAmount);
  await mUSDT.approve(pancakeRouter.target, mUSDTAmount2);
  
  // Add liquidity
  await pancakeRouter.addLiquidity(
    await mBAOFU.getAddress(),
    await mUSDT.getAddress(),
    mBAOFUAmount,
    mUSDTAmount2,
    0, // Accept any amount of tokens
    0, // Accept any amount of tokens
    deployer.address,
    Math.floor(Date.now() / 1000) + 60 * 20 // 20 minutes deadline
  );
  console.log("mBAOFU/mUSDT liquidity added");

  // Get the mBAOFU/mUSDT pair address and set it in mBAOFU contract
  const mBAOFUPairAddress = await pancakeFactory.getPair(
    await mBAOFU.getAddress(),
    await mUSDT.getAddress()
  );
  console.log("mBAOFU/mUSDT pair address:", mBAOFUPairAddress);
  
  // 检查当前所有者
  const currentOwner = await mBAOFU.owner();
  console.log("Current mBAOFU owner:", currentOwner);
  
  // 如果当前所有者不是部署者，则转移所有权
  if (currentOwner.toLowerCase() !== deployer.address.toLowerCase()) {
    console.log("Transferring mBAOFU ownership to deployer...");
    await mBAOFU.transferOwnership(deployer.address);
    console.log("mBAOFU ownership transferred");
  }
  
  await mBAOFU.setPancakePairAddress(mBAOFUPairAddress);
  console.log("mBAOFU pair address set in contract");



  /**
   * 部署Reservation合约
   * Now deploy Reservation contract after liquidity pools are established
   */
  console.log("Deploying Reservation contract...");
  const Reservation = await hre.ethers.getContractFactory("Reservation");
  const reservation = await Reservation.deploy(
    await mBNB.getAddress(),
    await mUSDT.getAddress(),
    await mBAOFU.getAddress(),
    await mREF.getAddress(),
    "0xD99D1c33F9fC3444f8101754aBC46c52416550D1" // PancakeSwap Router
  );
  await reservation.waitForDeployment();
  console.log("Reservation deployed to:", await reservation.getAddress());

  // 检查 Reservation 合约的所有者
  const reservationOwner = await reservation.owner();
  console.log("Current Reservation owner:", reservationOwner);
  
  // 如果当前所有者不是部署者，则转移所有权
  if (reservationOwner.toLowerCase() !== deployer.address.toLowerCase()) {
    console.log("Transferring Reservation ownership to deployer...");
    await reservation.transferOwnership(deployer.address);
    console.log("Reservation ownership transferred");
  }

  // 检查 mREF 合约的所有者
  const mREFOwner = await mREF.owner();
  console.log("Current mREF owner:", mREFOwner);
  
  // 如果当前所有者不是部署者，则转移所有权
  if (mREFOwner.toLowerCase() !== deployer.address.toLowerCase()) {
    console.log("Transferring mREF ownership to deployer...");
    await mREF.transferOwnership(deployer.address);
    console.log("mREF ownership transferred");
  }

  // 直接从部署脚本中添加 Reservation 合约到 mREF 的授权列表
  console.log("Adding Reservation contract as authorized in MockREF...");
  await mREF.addAuthorizedContract(await reservation.getAddress());
  console.log("Reservation contract authorized in MockREF");

  // 设置 Reservation 合约的授权状态为 true（需要添加一个设置函数）
  console.log("Setting Reservation contract authorization status...");
  await reservation.setAuthorizationStatus(true);
  console.log("Reservation contract authorization status set");

  // Add Reservation contract to mBAOFU whitelist
  console.log("Adding Reservation contract to mBAOFU whitelist...");
  await mBAOFU.addToWhitelist(await reservation.getAddress());
  console.log("Reservation contract added to whitelist");

//   // Register with Chainlink Automation
//   console.log("Registering with Chainlink Automation...");
//   const automationRegistry = await hre.ethers.getContractAt(
//     "AutomationRegistryInterface",
//     "0x02777053d6764996e594c3E88AF1D58D5363a2e6" // BSC Mainnet Automation Registry
//   );

//   const checkData = "0x";
//   const gasLimit = 300000;
//   const triggerType = 0; // Time-based trigger
//   const triggerConfig = "0x"; // Empty config for time-based trigger

//   const tx = await automationRegistry.registerUpkeep(
//     await reservation.getAddress(),
//     gasLimit,
//     deployer.address,
//     checkData,
//     triggerType,
//     triggerConfig
//   );

//   await tx.wait();
//   console.log("Registered with Chainlink Automation");
//   //

  console.log("\n=== Deployment Summary ===");
  console.log("mBNB:", await mBNB.getAddress());
  console.log("mUSDT:", await mUSDT.getAddress());
  console.log("mBAOFU:", await mBAOFU.getAddress());
  console.log("mREF:", await mREF.getAddress());
  console.log("Reservation:", await reservation.getAddress());
  console.log("PancakeRouter:", pancakeRouter.target);
  console.log("PancakeFactory:", await pancakeRouter.factory());
  console.log("mBAOFU/mUSDT Pair:", mBAOFUPairAddress);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  }); 