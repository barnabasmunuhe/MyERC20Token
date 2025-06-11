// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Script} from "forge-std/Script.sol";
import {MyToken} from "src/MyToken.sol";

contract DeployMyToken is Script {
    uint256 public constant STARTING_SUPPLY = 120 ether;

    function run() public returns (MyToken) {
        vm.startBroadcast();
        MyToken MT = new MyToken(STARTING_SUPPLY);
        vm.stopBroadcast();
        return MT;
    }
}
