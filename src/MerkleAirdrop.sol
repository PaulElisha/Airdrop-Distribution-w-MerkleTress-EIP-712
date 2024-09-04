// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/utils/cryptography/MerkleProof.sol";

contract MerkleAirdrop {
    error MerkleAirdrop__InvalidProof();
    error MerkleAirdrop__AlreadyClaimed();

    event Claimed(address claimer, uint256 amount);

    address[] claimers;
    bytes32 private immutable i_merkletRoot;
    IERC20 private immutable i_token;
    mapping(address claimer => bool) private s_hasClaimed;

    constructor(bytes32 merkleRoot, IERC20 token) {
        i_merkletRoot = merkleRoot;
        i_token = token;
    }

    function claim(
        address claimer,
        uint256 amount,
        bytes32[] calldata merkleProof
    ) public {
        if (s_hasClaimed[claimer]) {
            revert MerkleAirdrop__AlreadyClaimed();
        }
        bytes32 leaf = keccak256(
            bytes.concat(keccak256(abi.encode(claimer, amount)))
        );
        if (!MerkleProof.verify(merkleProof, i_merkletRoot, leaf)) {
            revert MerkleAirdrop__InvalidProof();
        }
        s_hasClaimed[claimer] = true;
        emit Claimed(claimer, amount);
        SafeERC20.safeTransfer(i_token, claimer, amount);
    }

    function getMerkleRoot() public view returns (bytes32) {
        return i_merkletRoot;
    }

    function getToken() public view returns (IERC20) {
        return i_token;
    }
}
