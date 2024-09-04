// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.20;

import "../src/MerkleAirdrop.sol";
import "../src/BagelToken.sol";
import "forge-std/Script.sol";
import "@openzeppelin/token/ERC20/IERC20.sol";

contract DeployMerkleAirdrop is Script {
    bytes32 public constant ROOT =
        0x7cdb6c21ef22a6cb5726d348e677f3e10032127425d425c5028965a30a71556e;
    uint256 public AMOUNT_TO_CLAIM = 25 * 1e18;
    uint256 public AMOUNT_TO_MINT = AMOUNT_TO_CLAIM * 4;
    uint256 public AMOUNT_TO_SEND = AMOUNT_TO_MINT;

    function deployMerkleAirdrop() public returns (BagelToken, MerkleAirdrop) {
        vm.startBroadcast();
        BagelToken bagelToken = new BagelToken();
        MerkleAirdrop merkleAirdrop = new MerkleAirdrop(ROOT, bagelToken);
        bagelToken.mint(bagelToken.owner(), AMOUNT_TO_MINT);
        bagelToken.transfer(address(merkleAirdrop), AMOUNT_TO_SEND);
        vm.stopBroadcast();

        return (bagelToken, merkleAirdrop);
    }
}
