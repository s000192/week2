pragma circom 2.0.0;

include "../node_modules/circomlib/circuits/poseidon.circom";

template Addition2(){
   signal input in1;
   signal input in2;
   signal output out;

   out <== in1 + in2;
}

template Multiplier2(){
   signal input in1;
   signal input in2;
   signal output out;

   out <== in1 * in2;
}

template GenerateUpperLeaves(n) {
    signal input leaves[2**n];
    signal output upperLeaves[2**(n - 1)];

    component poseidon[2**(n - 1)];

    for (var i = 0; i < 2 ** (n - 1); i++) {
        poseidon[2**(n - 1)] = Poseidon(2);

        poseidon[i].inputs[0] <== leaves[i * 2];
        poseidon[i].inputs[1] <== leaves[i * 2 + 1];

        upperLeaves[i] <== poseidon[i].out;
    }
}

template CheckRoot(n) { // compute the root of a MerkleTree of n Levels 
    signal input leaves[2**n];
    signal output root;

    component generateUpperLeaves[n];

    //[assignment] insert your code here to calculate the Merkle root from 2^n leaves
    for (var i = 0; i < n; i++) {
        generateUpperLeaves[i] = GenerateUpperLeaves(n - i);
        if (i == 0) {
            // TODO: may need to run a for loop here
            generateUpperLeaves[i].leaves <== leaves;
        } else {
            generateUpperLeaves[i].leaves <== generateUpperLeaves[i - 1].upperLeaves;
        }
    }

    root <== generateUpperLeaves[n][0];
}

template MerkleTreeInclusionProof(n) {
    signal input leaf;
    signal input path_elements[n];
    signal input path_index[n]; // path index are 0's and 1's indicating whether the current element is on the left or right
    signal output root; // note that this is an OUTPUT signal

    component poseidon[n];
    component left1[n];
    component left2[n];
    component right1[n];
    component right2[n];
    component left[n];
    component right[n];
    //[assignment] insert your code here to compute the root from a leaf and elements along the path
    for (var i = 0; i < n; i++) {
        poseidon[i] = Poseidon(2);

        var current;
        if (i == 0) {
            current = leaf;
        } else {
            current = poseidon[i - 1].out;
        }

        left1[i] = Multiplier2();
        left2[i] = Multiplier2();
        right1[i] = Multiplier2();
        right2[i] = Multiplier2();
        left[i] = Addition2();
        right[i] = Addition2();

        left1[i].in1 <== current;
        left1[i].in2 <== 1 - path_index[i];
        left2[i].in1 <== path_elements[i];
        left2[i].in2 <== path_index[i];
        left[i].in1 <== left1[i].out;
        left[i].in2 <== left2[i].out;

        right1[i].in1 <== current;
        right1[i].in2 <== path_index[i];
        right2[i].in1 <== path_elements[i];
        right2[i].in2 <== 1 - path_index[i];
        right[i].in1 <== left1[i].out;
        right[i].in2 <== left2[i].out;

        poseidon[i].inputs[0] <== left[i].out;
        poseidon[i].inputs[1] <== right[i].out;
    }

    root <== poseidon[n - 1].out;
}