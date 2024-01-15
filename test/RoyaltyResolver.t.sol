// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console2} from "forge-std/Test.sol";
import {RoyaltyResolver} from "../src/RoyaltyResolver.sol";

contract RoyaltyResolverTest is Test {
    RoyaltyResolver public royaltyResolver;

    function setUp() public {
        royaltyResolver = new RoyaltyResolver();
    }

    function testFunction() public {
        
    }
}
