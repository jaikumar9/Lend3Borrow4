pragma solidity ^0.8.20;

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.0) (token/ERC20/IERC20.sol)

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract lendBorrow is Ownable {
    address public usdtAsset;
    uint256 public lendingRatePerDay = 3;
    uint256 public borrowingRatePerDay = 3;
    uint256 public ownerFee = 1;

    mapping(address => uint256) public lendingBalances;
    mapping(address => uint256) public borrowingBalances;
    mapping(address => bool) public whitelistedBorrowers;

    event Lending(address indexed lender, uint256 amount);
    event Borrowing(address indexed borrower, uint256 amount);
    event Repayment(address indexed borrower, uint256 amount);
    event Withdrawal(address indexed lender, uint256 amount);

    constructor(
        address _usdtAsset,
        address _initialOwner
    ) Ownable(_initialOwner) {
        usdtAsset = _usdtAsset;
    }

    function lendUsdt(uint256 _amount) public {
        require(_amount != 0, "Please send some value");
        require(
            IERC20(usdtAsset).balanceOf(msg.sender) >= _amount,
            "Not enough balance"
        );
        IERC20(usdtAsset).transferFrom(msg.sender, address(this), _amount);
        lendingBalances[msg.sender] += _amount;
        emit Lending(msg.sender, _amount);
    }

    function borrowUsdt(uint256 _amount) public {
        require(
            whitelistedBorrowers[msg.sender],
            "Borrower is not whitelisted"
        );
        require(
            IERC20(usdtAsset).balanceOf(address(this)) >= _amount,
            "Not enough balance"
        );
        IERC20(usdtAsset).transfer(msg.sender, _amount);
        borrowingBalances[msg.sender] += _amount;
        emit Borrowing(msg.sender, _amount);
    }

    function calculateLendingInterest(
        address _lender
    ) internal view returns (uint256) {
        uint256 lentAmount = lendingBalances[_lender];
        uint256 durationInSeconds = 1 days;
        uint256 interest = (lentAmount *
            lendingRatePerDay *
            durationInSeconds) / (100 * 1 days);
        return interest;
    }

    function withdrawLendingAmount() public {
        uint256 lentAmount = lendingBalances[msg.sender];
        require(lentAmount > 0, "No lending amount to withdraw");
        uint256 interest = calculateLendingInterest(msg.sender);
        uint256 totalAmount = lentAmount + interest;
        lendingBalances[msg.sender] = 0;
        require(
            IERC20(usdtAsset).balanceOf(address(this)) >= totalAmount,
            "Not enough balance in the contract"
        );
        IERC20(usdtAsset).transfer(msg.sender, totalAmount);

        emit Withdrawal(msg.sender, totalAmount);
    }

    function calculateBorrowingInterest(
        address _borrower
    ) internal view returns (uint256) {
        uint256 borrowAmount = borrowingBalances[_borrower];
        uint256 durationInSeconds = 1 days;
        uint256 interest = (borrowAmount *
            borrowingRatePerDay *
            durationInSeconds) / (100 * 1 days);
        return interest;
    }

    function calculateAdminFee(
        address _borrower
    ) internal view returns (uint256) {
        uint256 borrowAmount = borrowingBalances[_borrower];
        uint256 durationInSeconds = 1 days;
        uint256 adminFee = (borrowAmount * ownerFee * durationInSeconds) /
            (100 * 1 days);
        return adminFee;
    }

    function repayBorrowingAmount() public {
        uint256 borrowAmount = borrowingBalances[msg.sender];
        require(borrowAmount > 0, "No borrowing amount to repay");
        uint256 interest = calculateBorrowingInterest(msg.sender);
        uint256 adminFee = calculateAdminFee(msg.sender);
        uint256 totalAmount = borrowAmount + interest + adminFee;
        borrowingBalances[msg.sender] = 0;
        require(
            IERC20(usdtAsset).balanceOf(msg.sender) >= totalAmount,
            "Not enough balance to repay the borrowing"
        );
        IERC20(usdtAsset).transfer(address(this), (totalAmount - adminFee)); // Transfer 3% to the contract
        IERC20(usdtAsset).transfer(owner(), adminFee); // Transfer 1% to the owner's wallet
        emit Repayment(msg.sender, totalAmount);
    }

    function LiquidityAdd(uint256 _amount) public onlyOwner {
        require(
            IERC20(usdtAsset).balanceOf(msg.sender) >= _amount,
            "Not enough USDT balance"
        );

        uint256 allowance = IERC20(usdtAsset).allowance(
            msg.sender,
            address(this)
        );
        require(
            allowance >= _amount,
            "Insufficient allowance for USDT transfer"
        );
        bool success = IERC20(usdtAsset).transferFrom(
            msg.sender,
            payable(address(this)),
            _amount
        );
        require(success, "USDT transfer failed");
    }

    function Liquiditywithdraw(uint256 _amount) public onlyOwner {
        require(
            IERC20(usdtAsset).balanceOf(address(this)) >= _amount,
            "Not enough balance"
        );
        IERC20(usdtAsset).transfer(msg.sender, _amount);
    }

    // withdraw all USDT from the contract
    function withdrawAll() public onlyOwner {
        uint256 contractBalance = IERC20(usdtAsset).balanceOf(address(this));
        require(contractBalance > 0, "Contract balance is zero");
        IERC20(usdtAsset).transfer(msg.sender, contractBalance);
    }

    // add a borrower to the whitelist
    function AddwhitelistedBorowers(address _address) public onlyOwner {
        whitelistedBorrowers[_address] = true;
    }

    // remove a borrower from the whitelist
    function removeWhitelistBorrower(address _borrower) public onlyOwner {
        whitelistedBorrowers[_borrower] = false;
    }

    // check the contract balance
    function getContractBalance() public view returns (uint256) {
        return IERC20(usdtAsset).balanceOf(address(this));
    }
}
