// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.20;

import "../src/MerkleAirdrop.sol";
import "../src/BagelToken.sol";
import "forge-std/Script.sol";
import "@openzeppelin/token/ERC20/IERC20.sol";
import "forge-std/console2.sol";
import "../script/DeployBagelToken.s.sol";

contract DeployMerkleAirdrop is Script {
    DeployBagelToken deployBagelToken;
    MerkleAirdrop merkleAirdrop;
    BagelToken bagelToken;

    bytes32 public constant ROOT =
        0x7cdb6c21ef22a6cb5726d348e677f3e10032127425d425c5028965a30a71556e;
    uint256 public AMOUNT_TO_CLAIM = 50 * 1e18;
    uint256 public AMOUNT_TO_MINT = AMOUNT_TO_CLAIM * 4;
    uint256 public AMOUNT_TO_SEND = 25 * 1e18;

    function deployMerkleAirdrop() public returns (MerkleAirdrop, BagelToken) {
        deployBagelToken = new DeployBagelToken();
        bagelToken = deployBagelToken.run();
        vm.startPrank(bagelToken.owner());
        merkleAirdrop = new MerkleAirdrop(ROOT, address(bagelToken));

        bagelToken.mint(bagelToken.owner(), AMOUNT_TO_MINT);
        bagelToken.transfer(address(merkleAirdrop), AMOUNT_TO_SEND);
        vm.stopPrank();

        return (merkleAirdrop, bagelToken);
    }

    function run() public returns (MerkleAirdrop, BagelToken) {
        return deployMerkleAirdrop();
    }
}
