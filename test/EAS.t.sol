// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {Test, console2} from "forge-std/Test.sol";
import {EAS} from "../src/EAS.sol";
import {ISchemaRegistry} from "eas-contracts/ISchemaRegistry.sol";

contract EASTest is Test {
    EAS public eas;

    function setUp() public {
        eas = new EAS(ISchemaRegistry(0x0a7E2Ff54e76B8E6659aedc9103FB21c038050D0));
    }

    function testFunction() public {}
}
