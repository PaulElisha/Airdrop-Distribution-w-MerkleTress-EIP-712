// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../src/MerkleAirdrop.sol";
import "../src/BagelToken.sol";
import "foundry-devops/src/ZkSyncChainChecker.sol";
import "../script/DeployMerkleAirdrop.s.sol";

contract MerkleAirdropTest is ZkSyncChainChecker, Test {
    MerkleAirdrop public merkleAirdrop;
    BagelToken public bagelToken;
    bytes32 public constant ROOT =
        0x057d6d8597d3d22719e6cdb92ab6205bee3339e7df399b5622af37f5b76513b7;
    uint256 public AMOUNT_TO_CLAIM = 100 * 1e18;
    uint256 public AMOUNT_TO_MINT = AMOUNT_TO_CLAIM * 4;
    uint256 public AMOUNT_TO_SEND = AMOUNT_TO_MINT;
    bytes32 public PROOF_ONE =
        0x0fd7c981d39bece61f7499702bf59b3114a90e66b51ba2c53abdf7b62986c00a;
    bytes32 public PROOF_TWO =
        0xe5ebd1e1b5a5478a944ecab36a9a954ac3b6b8216875f6524caa7a1d87096576;
    bytes32[] public PROOF = [PROOF_ONE, PROOF_TWO];
    address private constant USER = 0x1bAB6c36d216F27730519DFa284A4587B26182CB;
    address FEE_PAYER;
    uint256 USER_PRIVATE_KEY = vm.envUint("PRIVATE_KEY");

    function setUp() public {
        bagelToken = BagelToken(0x16abE11dC7b33cE03D481c2A20661E70aE2d5c4f);
        merkleAirdrop = MerkleAirdrop(
            0x090F4dBbE93DE617529Bf189dB611b488bb18bab
        );
        vm.startPrank(bagelToken.owner());
        FEE_PAYER = makeAddr("FEE_PAYER");
        bagelToken.transfer(FEE_PAYER, 5e18);
        bagelToken.mint(address(merkleAirdrop), AMOUNT_TO_MINT);
        vm.stopPrank();
    }

    function testClaimersCanClaim() public {
        uint256 startingBalance = bagelToken.balanceOf(USER);
        console.log("Starting Balance:", startingBalance);
        bytes32 digest = merkleAirdrop.getMessageHash(USER, AMOUNT_TO_CLAIM);

        (uint8 v, bytes32 r, bytes32 s) = vm.sign(USER_PRIVATE_KEY, digest);

        vm.prank(FEE_PAYER);
        merkleAirdrop.claim(USER, AMOUNT_TO_CLAIM, PROOF, v, r, s);

        uint256 endingBalance = bagelToken.balanceOf(USER);
        console.log("Ending Balance:", endingBalance);

        assertEq(endingBalance - startingBalance, AMOUNT_TO_CLAIM);
    }
}
