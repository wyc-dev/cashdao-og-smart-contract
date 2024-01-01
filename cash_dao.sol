// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;



import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";



// CashDAO合約，繼承自OpenZeppelin的ERC20和ReentrancyGuard
// CashDAO contract, inheriting from OpenZeppelin's ERC20 and ReentrancyGuard
contract CashDAO is ERC20, ReentrancyGuard {



    // 定義事件，用於記錄CASH代幣的購買和銷售
    // Events for logging the purchase and sale of CASH tokens
    event CASHBought(address indexed buyer, uint256 ethAmount, uint256 cashAmount);
    event CASHSold (address  indexed seller,uint256 cashAmount, uint256 ethAmount);



    // 建構函數，為Cash DAO團隊和合約內部池鑄造初始代幣
    // Constructor to mint initial tokens for the Cash DAO team and the contract's internal pool
    constructor() ERC20("Cash DAO", "CASH") {

        // CashDAO - Pre-angel Round Investor / BD Lead - "Brain"
        _mint(address(0xd8077BaE1D76ED883904563515bcda3fef985cEA), 5000 * 10 ** decimals());

        // CashDAO - Pre-angel Round Investor / Engineer / Design Lead - "Tonny"
        _mint(address(0x96a9f7faEC5C1bB9a85002fad26058F732D14eF4), 3000 * 10 ** decimals());

        // CashDAO - CEO / OG - "DL"
        _mint(address(0xfa1b70E944bDcD14f72aa7022229EEcd11E39684), 1500 * 10 ** decimals());

        // CashDAO - Marketing director - "Bobby Sosen"
        _mint(address(0xE9961E0f167d0679a00EC63EB8Ab5e2aFf4AfE2F), 1500 * 10 ** decimals());

        // CashDAO - Senior Dev.- "Mayank Sharma"
        _mint(address(0x486A6af541A4fB1e72e8bD62567557Ddcd957160), 1500 * 10 ** decimals());

        // CashDAO - Founder / CTO - "YC Wong"
        _mint(address(0xFc36Adb372556C16ea79CEaf9f59A83a47aDB687), 6000 * 10 ** decimals());

        // CashDAO - Team & Partners Foundation Reserve
        _mint(msg.sender, 281500 * 10 ** decimals()); // 30% of total supply for team and our partners 

        // CashDAO - Internal Swapping Pool Reserve
        _mint(address(this), 700000 * 10 ** decimals());
    }



    // 計算CASH在合約外的流通總量
    // Calculate the circulation of CASH outsdie the contract.
    uint256 circulatedAmount = 300000 * 10 ** decimals();



    // 計算使用ETH購買CASH的數量
    // Calculate the amount of CASH that can be bought with ETH
    function calculatePurchaseAmount(uint256 ethAmount) public view returns (uint256) {

        // 確保交易金額不超過 99 ETH (防止用戶購買總流通量的99%)
        // Ensure the transaction amount does not exceed 99 ETH
        require(ethAmount < 99, "Each transaction amount can not more than 99 ETH.");

        // 計算購買金額，包含1%的費用
        // Calculate purchase amount including a 1% fee
        return (ethAmount * balanceOf(address(this)) / (10 ** decimals())) * 99 / 100; // 1ETH for each % of the pool & 1% fee back to DeFi pool
    }



    // 計算出售CASH獲得的ETH數量
    // Calculate the amount of ETH obtained by selling CASH
    function calculateSellAmount(uint256 cashAmount) public view returns (uint256) {

        // 確保池中有CASH代幣
        // Ensure there is CASH in the pool
        require(balanceOf(address(this)) > 0, "No CASH in pool");

        // 計算賣出金額，包含1%的費用
        // Calculate sell amount including a 1% fee
        return (cashAmount * address(this).balance) / circulatedAmount * 99 / 100;
    }



    // 出售CASH以換取ETH
    // Sell CASH in exchange for ETH
    function sellCASH(uint256 cashAmount) public nonReentrant {

        // 確保賣家有足夠的CASH代幣
        // Ensure the seller has sufficient CASH balance
        require(balanceOf(msg.sender) >= cashAmount, "Insufficient CASH balance");
        uint256 ethAmount = calculateSellAmount(cashAmount);

        // 確保合約有足夠的ETH儲備
        // Ensure there is sufficient ETH in the reserve
        require(ethAmount <= address(this).balance, "Insufficient ETH in the reserve");

        // 轉移CASH代幣給合約
        // Transfer CASH tokens to the contract
        circulatedAmount -= cashAmount;
        _transfer(msg.sender, address(this), cashAmount);

        // 使用call方法傳送ETH給賣家，取代transfer方法
        // Use call method to send ETH to the seller, replacing transfer
        (bool sent, ) = payable(msg.sender).call{value: ethAmount}("");
        require(sent, "Failed to send ETH");

        // 觸發銷售事件
        // Trigger the sale event
        emit CASHSold(msg.sender, cashAmount, ethAmount);
    }



    // Fallback函數，處理接收ETH並購買CASH
    // Fallback function to handle receiving ETH and buying CASH
    fallback() external payable nonReentrant {
        uint256 amount = (msg.value * balanceOf(address(this)) / (10 ** decimals())) * 99 / 100;
        _transfer(address(this), msg.sender, amount);
        circulatedAmount += amount;
        emit CASHBought(msg.sender, msg.value,amount);
    }



    // Receive函數，同樣處理接收ETH並購買CASH
    // Receive function, similarly handling receiving ETH and buying CASH
    receive() external payable nonReentrant {
        uint256 amount = (msg.value * balanceOf(address(this)) / (10 ** decimals())) * 99 / 100;
        _transfer(address(this), msg.sender, amount);
        circulatedAmount += amount;
        emit CASHBought(msg.sender, msg.value,amount);
    }
}



// Copyright © 2023 Cash DAO. All rights reserved.