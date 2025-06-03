// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @notice 推荐币合约，用于记录推荐关系和推荐数量
 * 推荐制度发行推荐币，通过上级给下级打推荐币确定推荐层级关系：
 * 推荐3个人拿第一代，1.5%
 * 推荐6个人拿第二代，1%
 * 推荐9个人拿第三代，1%
 * 推荐12个人拿第四代，0.5%
 * 推荐15个人拿第五代，0.5%
 * 推荐20个人拿六到八代0.3%
 */

contract MockREF is ERC20, Ownable {
    mapping(address => address) public referrers;
    mapping(address => uint256) public referralCount;
    mapping(address => bool) public authorizedContracts;
    
    event ReferralSet(address indexed referrer, address indexed referee);
    event AuthorizedContractUpdated(address indexed contractAddress, bool status);
    
    constructor(
        string memory name,
        string memory symbol,
        uint256 initialSupply
    ) ERC20(name, symbol) {
        _mint(msg.sender, initialSupply);
    }

    function addAuthorizedContract(address contractAddress) external onlyOwner {
        authorizedContracts[contractAddress] = true;
        emit AuthorizedContractUpdated(contractAddress, true);
    }

    function removeAuthorizedContract(address contractAddress) external onlyOwner {
        authorizedContracts[contractAddress] = false;
        emit AuthorizedContractUpdated(contractAddress, false);
    }

    function setReferralByContract(address referrer, address referee) external {
        require(authorizedContracts[msg.sender], "Not authorized contract");
        require(referee != address(0), "Invalid referee address");
        require(referee != referrer, "Cannot refer yourself");
        require(referrers[referee] == address(0), "Already referred");
        
        referrers[referee] = referrer;
        referralCount[referrer]++;
        
        emit ReferralSet(referrer, referee);
    }

    function mint(address to, uint256 amount) public onlyOwner {
        _mint(to, amount);
    }
} 