/* This program is aimed to do the cuda implementation of DESnuts */

#include <cuda.h>
#include <stdlib.h>
#include <stdint.h>
#include <inttypes.h>
#include <stdio.h>

/**********************************************************************/
/*                                                                    */
/*                            DES TABLES                              */
/*                                                                    */
/**********************************************************************/

/* The number of bytes need for storing all the DES TABLES are:
 * 64 * 4 + 64 * 4 + 56 * 4 + 48 * 4 + 48 * 4 + 32 * 4 + 8 * 64 * 4 
 * = 3296 bytes
 */

/*
 *  IP: Output bit table_DES_IP[i] equals input bit i.
 */
static int table_DES_IP[64] = {
    39,  7, 47, 15, 55, 23, 63, 31,
    38,  6, 46, 14, 54, 22, 62, 30,
    37,  5, 45, 13, 53, 21, 61, 29,
    36,  4, 44, 12, 52, 20, 60, 28,
    35,  3, 43, 11, 51, 19, 59, 27,
    34,  2, 42, 10, 50, 18, 58, 26,
    33,  1, 41,  9, 49, 17, 57, 25,
    32,  0, 40,  8, 48, 16, 56, 24
};


/*
 *  FP: Output bit table_DES_FP[i] equals input bit i.
 */
static int table_DES_FP[64] = {
    57, 49, 41, 33, 25, 17,  9,  1,
    59, 51, 43, 35, 27, 19, 11,  3,
    61, 53, 45, 37, 29, 21, 13,  5,
    63, 55, 47, 39, 31, 23, 15,  7,
    56, 48, 40, 32, 24, 16,  8,  0,
    58, 50, 42, 34, 26, 18, 10,  2,
    60, 52, 44, 36, 28, 20, 12,  4,
    62, 54, 46, 38, 30, 22, 14,  6
};


/*
 *  PC1: Permutation choice 1, used to pre-process the key
 */
static int table_DES_PC1[56] = {
    27, 19, 11, 31, 39, 47, 55,
    26, 18, 10, 30, 38, 46, 54,
    25, 17,  9, 29, 37, 45, 53,
    24, 16,  8, 28, 36, 44, 52,
    23, 15,  7,  3, 35, 43, 51,
    22, 14,  6,  2, 34, 42, 50,
    21, 13,  5,  1, 33, 41, 49,
    20, 12,  4,  0, 32, 40, 48
};


/*
 *  PC2: Map 56-bit round key to a 48-bit subkey
 */
static int table_DES_PC2[48] = {
    24, 27, 20,  6, 14, 10,  3, 22,
    0, 17,  7, 12,  8, 23, 11,  5,
    16, 26,  1,  9, 19, 25,  4, 15,
    54, 43, 36, 29, 49, 40, 48, 30,
    52, 44, 37, 33, 46, 35, 50, 41,
    28, 53, 51, 55, 32, 45, 39, 42
};


/*
 *  E: Expand 32-bit R to 48 bits.
 */
static int table_DES_E[48] = {
    31,  0,  1,  2,  3,  4,  3,  4,
    5,  6,  7,  8,  7,  8,  9, 10,
    11, 12, 11, 12, 13, 14, 15, 16,
    15, 16, 17, 18, 19, 20, 19, 20,
    21, 22, 23, 24, 23, 24, 25, 26,
    27, 28, 27, 28, 29, 30, 31,  0
};


/*
 *  P: Permutation of S table outputs
 */
static int table_DES_P[32] = {
    11, 17,  5, 27, 25, 10, 20,  0,
    13, 21,  3, 28, 29,  7, 18, 24,
    31, 22, 12,  6, 26,  2, 16,  8,
    14, 30,  4, 19,  1,  9, 15, 23
};


/*
 *  S Tables: Introduce nonlinearity and avalanche
 */
static int table_DES_S[8][64] = {
    /* table S[0] */
    {   13,  1,  2, 15,  8, 13,  4,  8,  6, 10, 15,  3, 11,  7,  1,  4,
        10, 12,  9,  5,  3,  6, 14, 11,  5,  0,  0, 14, 12,  9,  7,  2,
        7,  2, 11,  1,  4, 14,  1,  7,  9,  4, 12, 10, 14,  8,  2, 13,
        0, 15,  6, 12, 10,  9, 13,  0, 15,  3,  3,  5,  5,  6,  8, 11  },
    /* table S[1] */
    {    4, 13, 11,  0,  2, 11, 14,  7, 15,  4,  0,  9,  8,  1, 13, 10,
        3, 14, 12,  3,  9,  5,  7, 12,  5,  2, 10, 15,  6,  8,  1,  6,
        1,  6,  4, 11, 11, 13, 13,  8, 12,  1,  3,  4,  7, 10, 14,  7,
        10,  9, 15,  5,  6,  0,  8, 15,  0, 14,  5,  2,  9,  3,  2, 12  },
    /* table S[2] */
    {   12, 10,  1, 15, 10,  4, 15,  2,  9,  7,  2, 12,  6,  9,  8,  5,
        0,  6, 13,  1,  3, 13,  4, 14, 14,  0,  7, 11,  5,  3, 11,  8,
        9,  4, 14,  3, 15,  2,  5, 12,  2,  9,  8,  5, 12, 15,  3, 10,
        7, 11,  0, 14,  4,  1, 10,  7,  1,  6, 13,  0, 11,  8,  6, 13  },
    /* table S[3] */
    {    2, 14, 12, 11,  4,  2,  1, 12,  7,  4, 10,  7, 11, 13,  6,  1,
        8,  5,  5,  0,  3, 15, 15, 10, 13,  3,  0,  9, 14,  8,  9,  6,
        4, 11,  2,  8,  1, 12, 11,  7, 10,  1, 13, 14,  7,  2,  8, 13,
        15,  6,  9, 15, 12,  0,  5,  9,  6, 10,  3,  4,  0,  5, 14,  3  },
    /* table S[4] */
    {    7, 13, 13,  8, 14, 11,  3,  5,  0,  6,  6, 15,  9,  0, 10,  3,
        1,  4,  2,  7,  8,  2,  5, 12, 11,  1, 12, 10,  4, 14, 15,  9,
        10,  3,  6, 15,  9,  0,  0,  6, 12, 10, 11,  1,  7, 13, 13,  8,
        15,  9,  1,  4,  3,  5, 14, 11,  5, 12,  2,  7,  8,  2,  4, 14  },
    /* table S[5] */
    {   10, 13,  0,  7,  9,  0, 14,  9,  6,  3,  3,  4, 15,  6,  5, 10,
        1,  2, 13,  8, 12,  5,  7, 14, 11, 12,  4, 11,  2, 15,  8,  1,
        13,  1,  6, 10,  4, 13,  9,  0,  8,  6, 15,  9,  3,  8,  0,  7,
        11,  4,  1, 15,  2, 14, 12,  3,  5, 11, 10,  5, 14,  2,  7, 12  },
    /* table S[6] */
    {   15,  3,  1, 13,  8,  4, 14,  7,  6, 15, 11,  2,  3,  8,  4, 14,
        9, 12,  7,  0,  2,  1, 13, 10, 12,  6,  0,  9,  5, 11, 10,  5,
        0, 13, 14,  8,  7, 10, 11,  1, 10,  3,  4, 15, 13,  4,  1,  2,
        5, 11,  8,  6, 12,  7,  6, 12,  9,  0,  3,  5,  2, 14, 15,  9  },
    /* table S[7] */
    {   14,  0,  4, 15, 13,  7,  1,  4,  2, 14, 15,  2, 11, 13,  8,  1,
        3, 10, 10,  6,  6, 12, 12, 11,  5,  9,  9,  5,  0,  3,  7,  8,
        4, 15,  1, 12, 14,  8,  8,  2, 13,  4,  6,  9,  2,  1, 11,  7,
        15,  5, 12, 11,  9,  3,  7, 14,  3, 10, 10,  0,  5,  6,  0, 13  }
};

#define MASK56(n) ((n) & 0x00FFFFFFFFFFFFFF)

void print_bits_array(uint64_t n) {
    printf("%lX\n", n);
}

#define COMPUTE_ROUND_KEY(roundKey, key)        \
    roundKey |= ((key & ((1UL) << 0)) << (27));     \
    roundKey |= ((key & ((1UL) << 1)) << (18));     \
    roundKey |= ((key & ((1UL) << 2)) << (9));  \
    roundKey |= ((key & ((1UL) << 3)) << (28));     \
    roundKey |= ((key & ((1UL) << 4)) << (35));     \
    roundKey |= ((key & ((1UL) << 5)) << (42));     \
    roundKey |= ((key & ((1UL) << 6)) << (49));     \
    roundKey |= ((key & ((1UL) << 7)) << (19));     \
    roundKey |= ((key & ((1UL) << 8)) << (10));     \
    roundKey |= ((key & ((1UL) << 9)) << (1));  \
    roundKey |= ((key & ((1UL) << 10)) << (20));    \
    roundKey |= ((key & ((1UL) << 11)) << (27));    \
    roundKey |= ((key & ((1UL) << 12)) << (34));    \
    roundKey |= ((key & ((1UL) << 13)) << (41));    \
    roundKey |= ((key & ((1UL) << 14)) << (11));    \
    roundKey |= ((key & ((1UL) << 15)) << (2));     \
    roundKey |= ((key & ((1UL) << 16)) >> (7));     \
    roundKey |= ((key & ((1UL) << 17)) << (12));    \
    roundKey |= ((key & ((1UL) << 18)) << (19));    \
    roundKey |= ((key & ((1UL) << 19)) << (26));    \
    roundKey |= ((key & ((1UL) << 20)) << (33));    \
    roundKey |= ((key & ((1UL) << 21)) << (3));     \
    roundKey |= ((key & ((1UL) << 22)) >> (6));     \
    roundKey |= ((key & ((1UL) << 23)) >> (15));    \
    roundKey |= ((key & ((1UL) << 24)) << (4));     \
    roundKey |= ((key & ((1UL) << 25)) << (11));    \
    roundKey |= ((key & ((1UL) << 26)) << (18));    \
    roundKey |= ((key & ((1UL) << 27)) << (25));    \
    roundKey |= ((key & ((1UL) << 28)) >> (5));     \
    roundKey |= ((key & ((1UL) << 29)) >> (14));    \
    roundKey |= ((key & ((1UL) << 30)) >> (23));    \
    roundKey |= ((key & ((1UL) << 31)) >> (28));    \
    roundKey |= ((key & ((1UL) << 32)) << (3));     \
    roundKey |= ((key & ((1UL) << 33)) << (10));    \
    roundKey |= ((key & ((1UL) << 34)) << (17));    \
    roundKey |= ((key & ((1UL) << 35)) >> (13));    \
    roundKey |= ((key & ((1UL) << 36)) >> (22));    \
    roundKey |= ((key & ((1UL) << 37)) >> (31));    \
    roundKey |= ((key & ((1UL) << 38)) >> (36));    \
    roundKey |= ((key & ((1UL) << 39)) >> (5));     \
    roundKey |= ((key & ((1UL) << 40)) << (2));     \
    roundKey |= ((key & ((1UL) << 41)) << (9));     \
    roundKey |= ((key & ((1UL) << 42)) >> (21));    \
    roundKey |= ((key & ((1UL) << 43)) >> (30));    \
    roundKey |= ((key & ((1UL) << 44)) >> (39));    \
    roundKey |= ((key & ((1UL) << 45)) >> (44));    \
    roundKey |= ((key & ((1UL) << 46)) >> (13));    \
    roundKey |= ((key & ((1UL) << 47)) >> (6));     \
    roundKey |= ((key & ((1UL) << 48)) << (1));     \
    roundKey |= ((key & ((1UL) << 49)) >> (29));    \
    roundKey |= ((key & ((1UL) << 50)) >> (38));    \
    roundKey |= ((key & ((1UL) << 51)) >> (47));    \
    roundKey |= ((key & ((1UL) << 52)) >> (52));    \
    roundKey |= ((key & ((1UL) << 53)) >> (21));    \
    roundKey |= ((key & ((1UL) << 54)) >> (14));    \
    roundKey |= ((key & ((1UL) << 55)) >> (7));     \


#define COMPUTE_IP(L, R, in)            \
    uint64_t output = 0UL;                    \
    output |= ((in & ((1UL) << 63)) >> (39));   \
    output |= ((in & ((1UL) << 62)) >> (6));    \
    output |= ((in & ((1UL) << 61)) >> (45));   \
    output |= ((in & ((1UL) << 60)) >> (12));   \
    output |= ((in & ((1UL) << 59)) >> (51));   \
    output |= ((in & ((1UL) << 58)) >> (18));   \
    output |= ((in & ((1UL) << 57)) >> (57));   \
    output |= ((in & ((1UL) << 56)) >> (24));   \
    output |= ((in & ((1UL) << 55)) >> (30));   \
    output |= ((in & ((1UL) << 54)) << (3));    \
    output |= ((in & ((1UL) << 53)) >> (36));   \
    output |= ((in & ((1UL) << 52)) >> (3));    \
    output |= ((in & ((1UL) << 51)) >> (42));   \
    output |= ((in & ((1UL) << 50)) >> (9));    \
    output |= ((in & ((1UL) << 49)) >> (48));   \
    output |= ((in & ((1UL) << 48)) >> (15));   \
    output |= ((in & ((1UL) << 47)) >> (21));   \
    output |= ((in & ((1UL) << 46)) << (12));   \
    output |= ((in & ((1UL) << 45)) >> (27));   \
    output |= ((in & ((1UL) << 44)) << (6));    \
    output |= ((in & ((1UL) << 43)) >> (33));   \
    output |= ((in & ((1UL) << 42)) << (0));    \
    output |= ((in & ((1UL) << 41)) >> (39));   \
    output |= ((in & ((1UL) << 40)) >> (6));    \
    output |= ((in & ((1UL) << 39)) >> (12));   \
    output |= ((in & ((1UL) << 38)) << (21));   \
    output |= ((in & ((1UL) << 37)) >> (18));   \
    output |= ((in & ((1UL) << 36)) << (15));   \
    output |= ((in & ((1UL) << 35)) >> (24));   \
    output |= ((in & ((1UL) << 34)) << (9));    \
    output |= ((in & ((1UL) << 33)) >> (30));   \
    output |= ((in & ((1UL) << 32)) << (3));    \
    output |= ((in & ((1UL) << 31)) >> (3));    \
    output |= ((in & ((1UL) << 30)) << (30));   \
    output |= ((in & ((1UL) << 29)) >> (9));    \
    output |= ((in & ((1UL) << 28)) << (24));   \
    output |= ((in & ((1UL) << 27)) >> (15));   \
    output |= ((in & ((1UL) << 26)) << (18));   \
    output |= ((in & ((1UL) << 25)) >> (21));   \
    output |= ((in & ((1UL) << 24)) << (12));   \
    output |= ((in & ((1UL) << 23)) << (6));    \
    output |= ((in & ((1UL) << 22)) << (39));   \
    output |= ((in & ((1UL) << 21)) << (0));    \
    output |= ((in & ((1UL) << 20)) << (33));   \
    output |= ((in & ((1UL) << 19)) >> (6));    \
    output |= ((in & ((1UL) << 18)) << (27));   \
    output |= ((in & ((1UL) << 17)) >> (12));   \
    output |= ((in & ((1UL) << 16)) << (21));   \
    output |= ((in & ((1UL) << 15)) << (15));   \
    output |= ((in & ((1UL) << 14)) << (48));   \
    output |= ((in & ((1UL) << 13)) << (9));    \
    output |= ((in & ((1UL) << 12)) << (42));   \
    output |= ((in & ((1UL) << 11)) << (3));    \
    output |= ((in & ((1UL) << 10)) << (36));   \
    output |= ((in & ((1UL) << 9)) >> (3));     \
    output |= ((in & ((1UL) << 8)) << (30));    \
    output |= ((in & ((1UL) << 7)) << (24));    \
    output |= ((in & ((1UL) << 6)) << (57));    \
    output |= ((in & ((1UL) << 5)) << (18));    \
    output |= ((in & ((1UL) << 4)) << (51));    \
    output |= ((in & ((1UL) << 3)) << (12));    \
    output |= ((in & ((1UL) << 2)) << (45));    \
    output |= ((in & ((1UL) << 1)) << (6));     \
    output |= ((in & ((1UL) << 0)) << (39));    \
                                                \
    L = (output >> 32) & 0xFFFFFFFF;            \
    R = (output) & 0xFFFFFFFF;                  \


    

__global__ void EncryptDES(uint64_t key, uint64_t in, uint64_t expected) {
    int i, round;
    uint32_t R, L, fout; 
    uint64_t roundKey, out;

    /*
       COMPUTE_ROUND_KEY(roundKey, key)


       COMPUTE_IP(L, R, in)
     */

    /*
       for (round = 0; round < 16; round++) {
       RotateRoundKeyLeft(roundKey);
       if (round != 0 && round != 1 && round != 8 && round != 15)
       RotateRoundKeyLeft(roundKey);

       ComputeF(fout, R, roundKey);

       L ^= fout;

       Exchange_L_and_R(L, R);
       }
       Exchange_L_and_R(L, R);

       ComputeFP(out, L, R);

     */

    /*
       Logic need to be added in order to handle 
       the out == expected situation.
     */

}

void EncryptDES_host(uint64_t key, uint64_t in, uint64_t expected) {
    int i = 0, round = 0;
    uint32_t R = 0, L = 0, fout = 0; 
    uint64_t roundKey = 0UL, out;
    
    printf("sizeof(unsigned long long) is %d\n", sizeof(unsigned long long));

    COMPUTE_ROUND_KEY(roundKey, key)
    
    printf("roundKey is: \n");
    print_bits_array(roundKey);


    COMPUTE_IP(L, R, in)
    
    printf("after IP is: \n");
    printf("\t L:\n");
    print_bits_array(L);
    printf("\t R:\n");
    print_bits_array(R);
}


int main(int argc, char **argv) {

    uint64_t random_o = 0xF77D7F53F77D7F53;
    uint64_t random_k = 0x2FEABF912FEABF;

    printf("original is : \n");
    print_bits_array(random_o);
    printf("key is :\n");
    print_bits_array(random_k);
    EncryptDES_host(random_k, random_o, 0);


    return 0;
}

