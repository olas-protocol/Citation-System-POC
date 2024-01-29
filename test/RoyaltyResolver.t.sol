// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {Test, console2} from "forge-std/Test.sol";
import {RoyaltyResolver} from "../src/RoyaltyResolver.sol";
import {IEAS, Attestation, AttestationRequestData, AttestationRequest} from "eas-contracts/IEAS.sol";
import {ISchemaRegistry} from "eas-contracts/ISchemaRegistry.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import {IAuthorStake} from "../src/IAuthorStake.sol";

/// @title MockAuthorStakingContract
/// @dev Mock contract for testing interactions with IAuthorStake interface.
contract MockAuthorStakingContract is IAuthorStake, ReentrancyGuard {
    mapping(address => uint256) private _stakes;

    event EtherStaked(address indexed staker, uint256 amount);
    event EtherWithdrawn(address indexed staker, uint256 amount);

    /// @dev Allows a user to stake Ether in the contract.
    function stakeEther() external payable override nonReentrant {
        require(msg.value > 0, "Cannot stake 0 Ether");
        _stakes[msg.sender] += msg.value;
        emit EtherStaked(msg.sender, msg.value);
    }

    /// @dev Allows a user to withdraw their staked Ether from the contract.
    function withdrawStake(uint256 amount) external override nonReentrant {
        require(amount > 0, "Cannot withdraw 0 Ether");
        require(_stakes[msg.sender] >= amount, "Insufficient staked balance");

        _stakes[msg.sender] -= amount;
        payable(msg.sender).transfer(amount);
        emit EtherWithdrawn(msg.sender, amount);
    }

    /// @dev Returns the amount of Ether staked by a specific user.
    function getStakedBalance(address staker) external view override returns (uint256) {
        return _stakes[staker];
    }
}

contract RoyaltyResolverTest is Test {
    RoyaltyResolver public royaltyResolver;
    IEAS public eas;
    IAuthorStake public authorStake;

    function setUp() public {
        eas = IEAS(0xC2679fBD37d54388Ce493F1DB75320D236e1815e);
        authorStake = IAuthorStake(0x60ab70C38BA5788B6012F4225B75C8abA989d2E9);
        royaltyResolver = RoyaltyResolver(payable(0x43183CEec5eE67cEe5e32E2B9a8f7fA758aFe1A8));
    }

    // Test successful royalty distribution and staking
    function testSuccessfulRoyaltyDistributionAndStaking() public {
    // Setup: Assuming the schema is already registered and the resolver is set

    // The schema UID must match the one you registered with your resolver set
    bytes32 schemaUID = 0xdd1e02d1485d7fcbd2a9c027f8d3bbf8f0cb25ab8aaecf1d6af950e16c0717d8;
    uint256 sentValue = 1 ether;
    uint256 ROYALTY_PERCENTAGE = 10;

    // Encode the custom schema data
    bytes memory encodedData = "0x00000000000000000000000000000000000000000000000000000000000000a0566974616c696b4275746572696e0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000100a97a4ac8d31de963cd776730caa8bf2a66301525181b09a30d147b478a867f08000000000000000000000000000000000000000000000000000000000000014000000000000000000000000000000000000000000000000000000000000000026578616d706c65554944310000000000000000000000000000000000000000006578616d706c6555494432000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001757687920476d20697320746865206e65772048656c6c6f000000000000000000000000000000000000000000000000000000000000000000000000000000001b68747470733a2f2f6578616d706c652e636f6d2f636f6e74656e740000000000"; /* Use SchemaEncoder or similar logic to encode your data */
    
    // Simulate attestation: create an AttestationRequestData struct with the encoded data
    AttestationRequestData memory requestData = AttestationRequestData({
        recipient: address(this),
        expirationTime: uint64(block.timestamp + 365 days), // Expiration time, e.g., one year from now
        revocable: false, // Whether the attestation is revocable
        refUID: 0x0, // Reference UID if applicable, else 0
        data: encodedData, // The encoded custom data for the attestation
        value: sentValue // ETH value to send to the resolver, if applicable
    });

    // Wrap the requestData in an AttestationRequest struct, specifying the schema
    AttestationRequest memory request = AttestationRequest({
        schema: schemaUID, // The unique identifier of the schema
        data: requestData // The attestation request data
    });

    // Use vm.prank to set the sender of the next call
    vm.prank(address(this));
    // Before balance checks
    uint256 beforeStakeBalance = authorStake.getStakedBalance(address(this));

    // Send the request and ETH to the EAS contract's attest function
    // This simulates the attestation process and should trigger your RoyaltyResolver
    bytes32 attestationUID = eas.attest{value: 1 ether}(request);

    // Verify outcomes
    // This might involve checking balances, emitted events, etc.
 // Expected calculations
    uint256 expectedRoyalty = sentValue * ROYALTY_PERCENTAGE / 100;
    uint256 expectedStake = sentValue - expectedRoyalty;

    // After balance checks
    uint256 afterStakeBalance = authorStake.getStakedBalance(address(this));

    // Verify outcomes
    assertEq(afterStakeBalance - beforeStakeBalance, expectedStake, "Staked amount does not match expected value");
    
    // Example event assertion (pseudocode, replace with your actual event and parameters)

    assertEq(authorStake.getStakedBalance(address(this)), expectedStake);
    }

    // function testFailOnZeroValue() public {
    //     bytes32 citationUID = keccak256(abi.encodePacked("citation1"));
    //     Attestation memory attestation = Attestation({
    //         uid: citationUID,
    //         schema: keccak256(abi.encodePacked("schema1")),
    //         time: uint64(block.timestamp),
    //         expirationTime: uint64(block.timestamp + 365 days),
    //         revocationTime: 0,
    //         refUID: 0x0,
    //         recipient: address(this),
    //         attester: address(this),
    //         revocable: true,
    //         data: abi.encode(citationUID)
    //     });
    //     eas.Attest(citationUID, attestation);

    //     // Assuming a test-specific callable function that wraps the call to `onAttest`
    //     vm.expectRevert(RoyaltyResolver.InsufficientEthValueSent.selector);
    //     vm.prank(address(this)); // Simulate call from this contract
    //     royaltyResolver.call(abi.encodeWithSelector(RoyaltyResolver.onAttest.selector, attestation, 0));
    // }

    function testDirectPaymentReverted() public {
        vm.expectRevert(RoyaltyResolver.DirectPaymentsNotAllowed.selector);
        (bool success,) = address(royaltyResolver).call{value: 1 ether}("");
        assertFalse(success, "Direct payment did not revert as expected.");
    }
}
