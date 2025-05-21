// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";
import {TimeLockVault} from "../src/TimeLockVault.sol";

contract TimeLockVaultTest is Test {
    TimeLockVault public timeLockVault;

    address public user1 = makeAddr("user1");
    address public user2 = makeAddr("user2");

    function setUp() public {
        timeLockVault = new TimeLockVault();

        vm.deal(user1, 1 ether);
        vm.deal(user2, 1 ether);
    }

    function testDeposit() public {
        
        vm.prank(user1);
        timeLockVault.deposit{value: 0.5 ether}(1);
        assertEq(timeLockVault.getDeposit(user1), 0.5 ether);
        assertEq(address(timeLockVault).balance, 0.5 ether);
        assertEq(timeLockVault.getUnlockTime(user1), block.timestamp + 1);
        (uint256 amount, ) = timeLockVault.deposits(user1);
        assertEq(amount, 0.5 ether);
        ( ,uint256 unlockTimeInSeconds) = timeLockVault.deposits(user1);
        assertEq(unlockTimeInSeconds, block.timestamp + 1);
    }

    function testMultipleDeposits() public {
        vm.prank(user1);
        timeLockVault.deposit{value: 0.5 ether}(1);
        vm.prank(user1);
        vm.expectRevert("Already have locked ETH");
        timeLockVault.deposit{value: 0.5 ether}(1);
    }

    function testZeroValueDeposit() public {
        vm.prank(user1);
        vm.expectRevert("Value must be greater than 0");
        timeLockVault.deposit{value: 0 ether}(1);
    }

    function testZeroSecondsLockTime() public {
        vm.prank(user1);
        vm.expectRevert("Lock time must be greater than 0 seconds");
        timeLockVault.deposit{value: 0.5 ether}(0);
    }

    function testOneYearLockTime() public {
        vm.prank(user1);
        vm.expectRevert("Lock time must be less than or equal to 31536000 seconds (1 year)");
        timeLockVault.deposit{value: 0.5 ether}(31536001);
    }

    function testWithdrawal() public {
        vm.prank(user1);
        timeLockVault.deposit{value: 0.5 ether}(1);
        vm.warp(block.timestamp + 2);
        vm.prank(user1);
        timeLockVault.withdraw();
        assertEq(timeLockVault.getDeposit(user1), 0);
        assertEq(address(timeLockVault).balance, 0);
    }

    function testMultipleWithdrawals() public {
        vm.prank(user1);
        timeLockVault.deposit{value: 0.5 ether}(1);
        vm.warp(block.timestamp + 2);
        vm.prank(user1);
        timeLockVault.withdraw();
        assertEq(timeLockVault.getDeposit(user1), 0);
        assertEq(address(timeLockVault).balance, 0);
        vm.expectRevert("No funds deposited");
        vm.prank(user1);
        timeLockVault.withdraw();
    }

}

