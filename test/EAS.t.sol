// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console2} from "forge-std/Test.sol";
import {EAS} from "../src/EAS.sol";

contract EASTest is Test {
    EAS public eas;

    function setUp() public {
        eas = new EAS();
    }

    function testFunction() public {
    }
}
