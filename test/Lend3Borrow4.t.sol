// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {lendBorrow} from "../src/lendBorrow.sol";
import {Vm} from "forge-std/Vm.sol";

contract lendBorrowTest is Test {
    lendBorrow public LendBorrow;

    function setUp() public {
        LendBorrow = new lendBorrow();
        address owner1 = vm.makeAddr("owner");
        address lender1 = vm.makeAddr("lender");
        address borrower1 = vm.makeAddr("borrower");
        address owner2 = vm.makeAddr("usdt");
    }
}
