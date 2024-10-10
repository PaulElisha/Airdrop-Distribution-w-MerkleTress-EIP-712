// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.20;

import "../src/BagelToken.sol";
import "forge-std/Script.sol";
import "@openzeppelin/token/ERC20/IERC20.sol";

contract DeployBagelToken is Script {
    function deployBagelToken() public returns (BagelToken) {
        vm.startBroadcast();
        BagelToken bagelToken = new BagelToken();
        vm.stopBroadcast();

        return (bagelToken);
    }

    function run() public returns (BagelToken) {
        return deployBagelToken();
    }
}
