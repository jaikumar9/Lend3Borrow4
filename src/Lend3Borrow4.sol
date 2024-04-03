// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract Lend3Borrow4 {
    address public owner;
    address public usdtAsset; // Asset for lending and borrowing
    uint8 public lendRate = 3; // Lending rate: 3%
    uint8 public borrowRate = 4; // Borrowing rate: 4%

    mapping(address => uint256) public lendersBalance;
    mapping(address => uint256) public borrowersBalance;
    mapping(address => bool) public whitelistedBorrowers;

    event Deposit(address indexed account, uint256 amount);
    event Withdraw(address indexed account, uint256 amount);
    event Borrow(address indexed borrower, uint256 amount);
    event Repay(address indexed borrower, uint256 amount);
    event AdminFee(address indexed owner, uint256 amount);
    event BorrowerWhitelisted(address indexed borrower);
    event BorrowerRemovedFromWhitelist(address indexed borrower);

    constructor(address _owner, address _usdtAsset) {
        owner = _owner;
        usdtAsset = _usdtAsset;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }

    modifier onlyWhitelisted() {
        require(whitelistedBorrowers[msg.sender], "Not whitelisted borrower");
        _;
    }

     // Function to calculate interest for lenders for one day
    function calculateLenderInterest(uint256 amount) internal view returns (uint256) {
        return (amount * lendRate) / 100 / 365;
    }

    // Function to calculate interest for borrowers for one day
    function calculateBorrowerInterest(uint256 amount) internal view returns (uint256) {
        return (amount * borrowRate) / 100 / 365;
    }

    function lend(uint256 amount) external {
        require(msg.sender != owner, "Owner cannot lend");
        require(amount > 0, "Invalid amount");

        // Calculate interest

         
       uint256 interest = calculateLenderInterest(amount)
        uint256 totalAmount = amount + interest;

        // Transfer USDT tokens from sender to contract
        // Assuming ERC20 transferFrom function is used
        // You need to implement this function or use existing ERC20 contract
        // This is just a placeholder
        // usdtAsset.transferFrom(msg.sender, address(this), totalAmount);

        // Update lender's balance
        lendersBalance[msg.sender] += totalAmount;

        emit Deposit(msg.sender, totalAmount);
    }

    function borrow(uint256 amount) external onlyWhitelisted {
        require(amount > 0, "Invalid amount");
        require(lendersBalance[owner] >= amount, "Insufficient liquidity");

        // Calculate interest
        uint256 interest = (amount * borrowRate) / 100;
        uint256 totalAmount = amount + interest;

        // Transfer borrowed tokens to borrower
        // Assuming ERC20 transfer function is used
        // You need to implement this function or use existing ERC20 contract
        // This is just a placeholder
        // usdtAsset.transfer(msg.sender, totalAmount);

        // Update borrower's balance
        borrowersBalance[msg.sender] += totalAmount;

        // Update lender's balance
        lendersBalance[owner] -= amount;

        emit Borrow(msg.sender, totalAmount);
    }

    function repay(uint256 amount) external {
        require(amount > 0, "Invalid amount");
        require(borrowersBalance[msg.sender] >= amount, "Insufficient balance");

        // Calculate admin fee
        uint256 adminFee = (amount * 1) / 100;

        // Transfer repaid tokens from borrower to contract
        // Assuming ERC20 transferFrom function is used
        // You need to implement this function or use existing ERC20 contract
        // This is just a placeholder
        // usdtAsset.transferFrom(msg.sender, address(this), amount);

        // Update borrower's balance
        borrowersBalance[msg.sender] -= amount;

        // Update lender's balance
        lendersBalance[owner] += amount - adminFee;

        // Transfer admin fee to owner
        // Assuming ERC20 transfer function is used
        // You need to implement this function or use existing ERC20 contract
        // This is just a placeholder
        // usdtAsset.transfer(owner, adminFee);

        emit Repay(msg.sender, amount);
        emit AdminFee(owner, adminFee);
    }

    function addLiquidity(uint256 amount) external onlyOwner {
        require(amount > 0, "Invalid amount");

        // Transfer USDT tokens from owner to contract
        // Assuming ERC20 transfer function is used
        // You need to implement this function or use existing ERC20 contract
        // This is just a placeholder
        // usdtAsset.transferFrom(owner, address(this), amount);

        // Update owner's balance
        lendersBalance[owner] += amount;

        emit Deposit(owner, amount);
    }

    function withdraw(uint256 amount) external onlyOwner {
        require(amount > 0, "Invalid amount");
        require(lendersBalance[owner] >= amount, "Insufficient balance");

        // Transfer tokens from contract to owner
        // Assuming ERC20 transfer function is used
        // You need to implement this function or use existing ERC20 contract
        // This is just a placeholder
        // usdtAsset.transfer(owner, amount);

        // Update owner's balance
        lendersBalance[owner] -= amount;

        emit Withdraw(owner, amount);
    }

    function whitelistBorrower(address borrower) external onlyOwner {
        require(!whitelistedBorrowers[borrower], "Borrower already whitelisted");
        whitelistedBorrowers[borrower] = true;
        emit BorrowerWhitelisted(borrower);
    }

    function removeFromWhitelist(address borrower) external onlyOwner {
        require(whitelistedBorrowers[borrower], "Borrower not whitelisted");
        whitelistedBorrowers[borrower] = false;
        emit BorrowerRemovedFromWhitelist(borrower);
    }
}
