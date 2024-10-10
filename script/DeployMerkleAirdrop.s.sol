// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.20;

import "../src/MerkleAirdrop.sol";
import "../src/BagelToken.sol";
import "forge-std/Script.sol";
import "@openzeppelin/token/ERC20/IERC20.sol";
import "forge-std/console2.sol";

contract DeployMerkleAirdrop is Script {
    MerkleAirdrop merkleAirdrop;
    BagelToken bagelToken;

    bytes32 public constant ROOT =
        0x057d6d8597d3d22719e6cdb92ab6205bee3339e7df399b5622af37f5b76513b7;
    uint256 public AMOUNT_TO_CLAIM = 25 * 1e18;
    uint256 public AMOUNT_TO_MINT = AMOUNT_TO_CLAIM * 4;
    uint256 public AMOUNT_TO_SEND = AMOUNT_TO_MINT;

    function InteractMerkleAirdrop() public {
        vm.startPrank(bagelToken.owner());
        // deployBagelToken = new DeployBagelToken();
        // bagelToken = deployBagelToken.run();
        // MerkleAirdrop merkleAirdrop = new MerkleAirdrop(
        //     ROOT,
        //     address(bagelToken)
        // );

        bagelToken = BagelToken(0x16abE11dC7b33cE03D481c2A20661E70aE2d5c4f);
        merkleAirdrop = MerkleAirdrop(
            0x090F4dBbE93DE617529Bf189dB611b488bb18bab
        );
        bagelToken.mint(address(merkleAirdrop), AMOUNT_TO_MINT);
        // bagelToken.transfer(address(merkleAirdrop), AMOUNT_TO_SEND);
        vm.stopPrank();
    }

    function run() public {
        return InteractMerkleAirdrop();
    }
}
