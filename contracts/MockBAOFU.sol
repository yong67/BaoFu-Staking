// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract MockBAOFU is ERC20, Ownable {
    //白名单。若后续业务白名单较长，可以考虑用MerkleRoot来存储白名单,merkleproof加签名验证，减小gas消耗
    mapping(address => bool) public whitelist;
    address public pancakePairAddress;
    
    event WhitelistUpdated(address indexed account, bool status);
    event PancakePairAddressUpdated(address indexed pairAddress);
    
    constructor(
        string memory name,
        string memory symbol,
        uint256 initialSupply
    ) ERC20(name, symbol) {
        _mint(msg.sender, initialSupply);
    }

    function addToWhitelist(address account) external onlyOwner {
        whitelist[account] = true;
        emit WhitelistUpdated(account, true);
    }

    function removeFromWhitelist(address account) external onlyOwner {
        whitelist[account] = false;
        emit WhitelistUpdated(account, false);
    }

    function setPancakePairAddress(address _pairAddress) external onlyOwner {
        pancakePairAddress = _pairAddress;
        emit PancakePairAddressUpdated(_pairAddress);
    }

    /**
     * @dev 重写_beforeTokenTransfer函数以实现白名单限制
     * 只有在以下情况下才允许转账:
     * - 接收方在白名单中，或
     * - 发送方是合约拥有者，或
     * - 接收方是合约拥有者，或
     * - 不是从PancakeSwap池子转出的交易
     */
    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual override {

        
        // 如果是从PancakeSwap池子转出的交易,则需要检查接收方是否在白名单中
        if(from == pancakePairAddress && pancakePairAddress != address(0)) {
            require(whitelist[to] || to == owner(), "Receiver not whitelisted for PancakeSwap purchase");
        }

        super._beforeTokenTransfer(from, to, amount);
    }

    function mint(address to, uint256 amount) public onlyOwner {
        _mint(to, amount);
    }
} 