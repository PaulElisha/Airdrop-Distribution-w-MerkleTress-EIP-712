// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/utils/cryptography/MerkleProof.sol";
import "@openzeppelin/utils/cryptography/EIP712.sol";
import "@openzeppelin/utils/cryptography/ECDSA.sol";

contract MerkleAirdrop is EIP712 {
    using ECDSA for bytes32;
    using SafeERC20 for IERC20;

    error MerkleAirdrop__InvalidProof();
    error MerkleAirdrop__AlreadyClaimed();
    error MerkleAirdrop__InvalidSignature();

    event Claimed(address claimer, uint256 amount);

    address[] claimers;
    bytes32 private immutable i_merkletRoot;
    IERC20 private immutable i_token;
    mapping(address claimer => bool) private s_hasClaimed;

    struct AirdropClaim {
        address account;
        uint256 amount;
    }

    bytes32 private constant MESSAGE_TYPEHASH =
        keccak256("AirdropClaim(address account, uint256 amount)");

    constructor(bytes32 merkleRoot, IERC20 token) EIP712("MerkleAirdrop", "1") {
        i_merkletRoot = merkleRoot;
        i_token = token;
    }

    function claim(
        address claimer,
        uint256 amount,
        bytes32[] calldata merkleProof,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) public {
        if (s_hasClaimed[claimer]) {
            revert MerkleAirdrop__AlreadyClaimed();
        }

        if (
            !_isValidSignature(
                claimer,
                getMessageHash(claimer, amount),
                v,
                r,
                s
            )
        ) {
            revert MerkleAirdrop__InvalidSignature();
        }

        bytes32 leaf = keccak256(
            bytes.concat(keccak256(abi.encode(claimer, amount))) // hash twice to avoid collision
        );
        if (!MerkleProof.verify(merkleProof, i_merkletRoot, leaf)) {
            revert MerkleAirdrop__InvalidProof();
        }
        s_hasClaimed[claimer] = true;
        emit Claimed(claimer, amount);
        i_token.safeTransfer(claimer, amount);
    }

    function getMessageHash(
        address account,
        uint256 amount
    )
        public
        view
        returns (
            /* AirdropClaim airdropClaim*/
            bytes32
        )
    {
        return
            _hashTypedDataV4(
                keccak256(
                    abi.encode(
                        MESSAGE_TYPEHASH,
                        AirdropClaim({account: account, amount: amount})
                    )
                )
            );

        // return
        //     _hashTypedDataV4(
        //         keccak256(
        //             abi.encode(
        //                 MESSAGE_TYPEHASH,
        //                 airdropClaim.account,
        //                 airdropClaim.amount
        //             )
        //         )
        //     );
    }

    function _isValidSignature(
        address claimedSigner,
        bytes32 digest,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) public pure returns (bool) {
        (address signer, , ) = digest.tryRecover(v, r, s);
        return signer == claimedSigner;
    }

    function getMerkleRoot() public view returns (bytes32) {
        return i_merkletRoot;
    }

    function getToken() public view returns (IERC20) {
        return i_token;
    }
}
