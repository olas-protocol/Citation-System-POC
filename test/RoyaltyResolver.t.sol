// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {Test, console2} from "forge-std/Test.sol";
import {RoyaltyResolver} from "../src/RoyaltyResolver.sol";
import {IEAS, Attestation} from "eas-contracts/IEAS.sol";
import {ISchemaRegistry} from "eas-contracts/ISchemaRegistry.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import {IAuthorStake} from "../src/IAuthorStake.sol";

// Mock contracts for IEAS and IAuthorStake
contract MockEAS is IEAS {
    mapping(bytes32 => Attestation) public attestations;
    ISchemaRegistry public schemaRegistry;

    constructor(ISchemaRegistry _schemaRegistry) {
        schemaRegistry = _schemaRegistry;
    }

    function setAttestation(bytes32 _citationUID, Attestation memory _attestation) public {
        attestations[_citationUID] = _attestation;
    }

    function getAttestation(bytes32 _citationUID) external view override returns (Attestation memory) {
        return attestations[_citationUID];
    }

    // Mock any other functions from IEAS that your RoyaltyResolver interacts with
}

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
    MockEAS public eas;
    MockAuthorStakingContract public authorStake;

    function setUp() public {
        ISchemaRegistry dummySchemaRegistry = ISchemaRegistry(address(0));
        eas = new MockEAS(dummySchemaRegistry);
        authorStake = new MockAuthorStakingContract();
        royaltyResolver = new RoyaltyResolver(IEAS(address(eas)), address(authorStake));
    }

    // Test successful royalty distribution and staking
    function testSuccessfulRoyaltyDistributionAndStaking() public {
    // Assuming you have the EAS and schema registry set up
    // Register your schema and resolver in the schema registry if not already done

    // Prepare the attestation request data
    AttestationRequestData memory requestData = AttestationRequestData({
        recipient: address(this), // or another address for the recipient
        data: abi.encode(/* your attestation data here */),
        value: 0, // or any ether value if your schema requires payment
        expirationTime: block.timestamp + 1 days,
        revocable: true,
        refUID: 0x0 // Reference UID if applicable
    });

    AttestationRequest memory request = AttestationRequest({
        schema: /* schema UID you registered */,
        data: requestData
    });

    // Send the request and ETH to the EAS contract's attest function
    // This simulates the attestation process and should trigger your resolver
    bytes32 attestationUID = eas.attest{value: 1 ether}(request);

    // Assertions to verify the expected outcomes
    // For example, check the ether balance of the RoyaltyResolver,
    // verify that the correct events were emitted, etc.
        bytes32 citationUID = keccak256(abi.encodePacked("citation1"));
        Attestation memory attestation = Attestation({
            uid: citationUID,
            schema: keccak256(abi.encodePacked("schema1")),
            time: uint64(block.timestamp),
            expirationTime: uint64(block.timestamp + 365 days),
            revocationTime: 0,
            refUID: 0x0,
            recipient: address(this),
            attester: address(this),
            revocable: true,
            data: abi.encode(citationUID)
        });
        eas.setAttestation(citationUID, attestation);
    
        uint256 sentValue = 1 ether;
        address royaltyReceiver = address(0x123); // Example receiver address
    
        // Pre-fund the test contract with Ether to simulate sending Ether with the onAttest call
        vm.deal(address(this), sentValue);
        
        // Assume `testOnAttest` is a wrapper function to call `onAttest` for testing
        // Example of how to call a function with Ether in Foundry
        vm.prank(address(this)); // Simulate call from this contract
        royaltyResolver.call{value: sentValue}(abi.encodeWithSelector(RoyaltyResolver.onAttest.selector, attestation, sentValue));
    
        // Expected royalty calculation and staking
        uint256 expectedRoyalty = (sentValue * 10) / 100; // 10% royalty
        uint256 expectedStake = sentValue - expectedRoyalty;
    
        // Assert that the correct amount of Ether is staked
        uint256 stakedAmount = authorStake.getStakedBalance(address(royaltyResolver));
        assertEq(stakedAmount, expectedStake, "Staked amount does not match expected value");
    
        // Further assertions could check the royalty distribution to the intended recipients
    }

    function testFailOnZeroValue() public {
        bytes32 citationUID = keccak256(abi.encodePacked("citation1"));
        Attestation memory attestation = Attestation({
            uid: citationUID,
            schema: keccak256(abi.encodePacked("schema1")),
            time: uint64(block.timestamp),
            expirationTime: uint64(block.timestamp + 365 days),
            revocationTime: 0,
            refUID: 0x0,
            recipient: address(this),
            attester: address(this),
            revocable: true,
            data: abi.encode(citationUID)
        });
        eas.setAttestation(citationUID, attestation);
    
        // Assuming a test-specific callable function that wraps the call to `onAttest`
        vm.expectRevert(RoyaltyResolver.InsufficientEthValueSent.selector);
        vm.prank(address(this)); // Simulate call from this contract
        royaltyResolver.call(abi.encodeWithSelector(RoyaltyResolver.onAttest.selector, attestation, 0));
    }

    function testDirectPaymentReverted() public {
        vm.expectRevert(RoyaltyResolver.DirectPaymentsNotAllowed.selector);
        (bool success,) = address(royaltyResolver).call{value: 1 ether}("");
        assertFalse(success, "Direct payment did not revert as expected.");
    }
}
