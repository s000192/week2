//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import { PoseidonT3 } from "./Poseidon.sol"; //an existing library to perform Poseidon hash on solidity
import "./verifier.sol"; //inherits with the MerkleTreeInclusionProof verifier contract

contract MerkleTree is Verifier {
    uint256[] public hashes; // the Merkle tree in flattened array form
    uint256 public index = 0; // the current index of the first unfilled leaf
    uint256 public root; // the current Merkle root

    constructor() {
        // [assignment] initialize a Merkle tree of 8 with blank leaves
        hashes = new uint256[](8);
        uint256 PoseidonHashOfTwoZeroes = PoseidonT3.poseidon([uint256(0), 0]);
        for (uint8 i = 0; i < 4; i++) {
            hashes.push(PoseidonHashOfTwoZeroes);
        }
        uint256 PoseidonHashOfTwoHashes = PoseidonT3.poseidon([
            PoseidonHashOfTwoZeroes,
            PoseidonHashOfTwoZeroes
        ]);
        for (uint8 i = 0; i < 2; i++) {
            hashes.push(PoseidonHashOfTwoHashes);
        }
        uint256 Root = PoseidonT3.poseidon([
            PoseidonHashOfTwoHashes,
            PoseidonHashOfTwoHashes
        ]);
        hashes.push(Root);
    }

    function insertLeaf(uint256 hashedLeaf) public returns (uint256) {
        // [assignment] insert a hashed leaf into the Merkle tree
        uint256 insertedIndex = index;
        hashes[index] = hashedLeaf;
        ++index;
        return insertedIndex;
    }

    function verify(
            uint[2] memory a,
            uint[2][2] memory b,
            uint[2] memory c,
            uint[1] memory input
        ) public view returns (bool) {

        // [assignment] verify an inclusion proof and check that the proof root matches current root
        return verifyProof(a,b,c,input);
    }
}
