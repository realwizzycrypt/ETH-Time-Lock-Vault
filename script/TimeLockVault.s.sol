// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Script, console} from "forge-std/Script.sol";
import {TimeLockVault} from "../src/TimeLockVault.sol";

contract DeployTimeLockVault is Script {
    TimeLockVault public timeLockVault;

    function setUp() public {}

    function run() public {
        vm.startBroadcast();

        timeLockVault = new TimeLockVault();

        vm.stopBroadcast();
    }
}
