// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

/**
 * @title IMockREF Interface
 * @notice Interface for MockREF contract interactions
 * @dev 推荐币合约接口，用于推荐关系管理和奖励分发
 */
interface IMockREF is IERC20 {
    // 查询函数
    function referrers(address user) external view returns (address);
    function referralCount(address user) external view returns (uint256);
    function authorizedContracts(address contractAddress) external view returns (bool);
    
    // 推荐关系管理
    function setReferralByContract(address referrer, address referee) external;
    
    // 授权管理
    function addAuthorizedContract(address contractAddress) external;
    function removeAuthorizedContract(address contractAddress) external;
    
    // 铸造功能
    function mint(address to, uint256 amount) external;
    
    // 事件
    event ReferralSet(address indexed referrer, address indexed referee);
    event AuthorizedContractUpdated(address indexed contractAddress, bool status);
} 