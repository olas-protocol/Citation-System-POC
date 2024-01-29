// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import {Address} from "@openzeppelin/contracts/utils/Address.sol";

/// @title AuthorStakingContract
/// @notice A simple contract for staking Ether.
contract AuthorStakingContract is ReentrancyGuard {
    // Mapping to track staked Ether balances of each address.
    mapping(address => uint256) public stakes;
    // Event to log staking activity.

    event EtherStaked(address indexed from, uint256 amount);
    // Event to log withdrawal activity.
    event EtherWithdrawn(address indexed to, uint256 amount);

    // Modifier to check if the caller has enough staked balance.
    modifier hasSufficientStake(uint256 amount) {
        require(stakes[msg.sender] >= amount, "Insufficient staked amount to withdraw specified amount");
        _;
    }

    function stakeEther() public payable nonReentrant {
        require(msg.value > 0, "Must send Ether to stake");
        stakes[msg.sender] += msg.value;
        emit EtherStaked(msg.sender, msg.value);
    }

    // Allows users to withdraw their staked Ether.
    function withdrawStake(uint256 amount) external nonReentrant hasSufficientStake(amount) {
        require(amount > 0, "Withdrawal amount must be greater than 0");
        stakes[msg.sender] -= amount;
        Address.sendValue(payable(msg.sender), amount); // Safer Ether transfer
        emit EtherWithdrawn(msg.sender, amount);
    }

    // Function to check the staked balance of a caller.
    function getStakedBalance(address staker) external view returns (uint256) {
        return stakes[staker];
    }

    // Function to receive Ether. msg.data must be empty
    receive() external payable {
        stakeEther();
    }
}
