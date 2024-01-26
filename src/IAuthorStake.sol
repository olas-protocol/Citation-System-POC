// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IAuthorStake {
    /// @notice Allows a user to stake Ether in the contract.
    function stakeEther() external payable;

    /// @notice Allows a user to withdraw their staked Ether from the contract.
    /// @param amount The amount of Ether to withdraw.
    function withdrawStake(uint256 amount) external;

    /// @notice Returns the amount of Ether staked by a specific user.
    /// @param staker The address of the user to check the staked balance for.
    /// @return The amount of Ether staked by the user.
    function getStakedBalance(address staker) external view returns (uint256);
}