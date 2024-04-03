// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {Lend3Borrow4} from "../src/Lend3Borrow4.sol";

contract Lend3Borrow4Test is Test {
    Lend3Borrow4 public lend3Borrow4;

    function setUp() public {
        Lend3Borrow4 = new Lend3Borrow4();
    
    }
}