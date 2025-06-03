// test-env.js
require("dotenv").config();
console.log("RPC_URL:", process.env.BSC_TESTNET_URL);
console.log("PRIVATE_KEY:", process.env.PRIVATE_KEY ? "存在" : "不存在");