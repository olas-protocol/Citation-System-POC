// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {Test, console2} from "forge-std/Test.sol";
import {AuthorStakingContract} from "../src/AuthorStake.sol";
import {Vm} from "forge-std/Vm.sol";

contract AuthorStakingContractTest is Test {
    Vm vm = Vm(HEVM_ADDRESS);
    AuthorStakingContract public stakingContract;

    function setUp() public {
        stakingContract = new AuthorStakingContract();
    }

    function testSuccessfulEtherStaking() public {
        address staker = address(1);
        uint256 stakeAmount = 1 ether;
    
        // Simulate sending Ether to the staking contract
        vm.deal(staker, stakeAmount);
        vm.prank(staker);
        stakingContract.stakeEther{value: stakeAmount}();
    
        // Verify the staked balance is updated
        uint256 stakedBalance = stakingContract.getStakedBalance(staker);
        assertEq(stakedBalance, stakeAmount, "Staked balance should match the sent amount");
    }

    function testSuccessfulEtherWithdrawal() public {
        address staker = address(2);
        uint256 stakeAmount = 1 ether;
        uint256 withdrawAmount = 0.5 ether;
    
        // Setup: Stake Ether
        vm.deal(staker, stakeAmount);
        vm.prank(staker);
        stakingContract.stakeEther{value: stakeAmount}();
    
        // Withdraw part of the staked Ether
        vm.prank(staker);
        stakingContract.withdrawStake(withdrawAmount);
    
        // Verify the remaining balance
        uint256 remainingBalance = stakingContract.getStakedBalance(staker);
        assertEq(remainingBalance, stakeAmount - withdrawAmount, "Remaining balance should match after withdrawal");
    }
    
    function testFailWithdrawalExceedsStakedAmount() public {
        address staker = address(3);
        uint256 stakeAmount = 0.5 ether;
        uint256 withdrawAmount = 1 ether; // Attempt to withdraw more than staked
    
        // Setup: Stake Ether
        vm.deal(staker, stakeAmount);
        vm.prank(staker);
        stakingContract.stakeEther{value: stakeAmount}();
    
        // Attempt to withdraw more than the staked amount should fail
        vm.prank(staker);
        vm.expectRevert("Insufficient staked amount to withdraw specified amount");
        stakingContract.withdrawStake(withdrawAmount);
    }

    function testMultipleStakers() public {
        address staker1 = address(6);
        address staker2 = address(7);
        uint256 stakeAmount1 = 1 ether;
        uint256 stakeAmount2 = 2 ether;
    
        // Staker 1 stakes
        vm.deal(staker1, stakeAmount1);
        vm.prank(staker1);
        stakingContract.stakeEther{value: stakeAmount1}();
    
        // Staker 2 stakes
        vm.deal(staker2, stakeAmount2);
        vm.prank(staker2);
        stakingContract.stakeEther{value: stakeAmount2}();
    
        // Verify each staker's balance independently
        uint256 stakedBalance1 = stakingContract.getStakedBalance(staker1);
        uint256 stakedBalance2 = stakingContract.getStakedBalance(staker2);
        assertEq(stakedBalance1, stakeAmount1, "Staker 1's staked balance should match");
        assertEq(stakedBalance2, stakeAmount2, "Staker 2's staked balance should match");
    }

    function testDirectEtherReceipt() public {
        address staker = address(5);
        uint256 stakeAmount = 1 ether;
    
        // Directly transfer Ether to the contract without calling `stakeEther`
        vm.deal(address(stakingContract), stakeAmount);
    
        // Attempt to record the direct transfer as a stake (if applicable)
        // Note: This requires the contract to have a receive() or fallback() function implemented
        (bool success,) = address(stakingContract).call{value: stakeAmount}("");
        assertTrue(success, "Direct transfer failed");
    
        // Verify the staked balance (if the contract treats direct transfers as stakes)
        // This step depends on whether your contract logic supports this behavior
        uint256 stakedBalance = stakingContract.getStakedBalance(staker);
        assertEq(stakedBalance, stakeAmount, "Staked balance should reflect the direct transfer");
    }
    
    function testFailStakingZeroEther() public {
        address staker = address(4);
        uint256 stakeAmount = 0;
    
        vm.deal(staker, 1 ether); // Ensure staker has some ether to cover gas costs
        vm.expectRevert("Must send Ether to stake");
        vm.prank(staker);
        stakingContract.stakeEther{value: stakeAmount}();
    }
}