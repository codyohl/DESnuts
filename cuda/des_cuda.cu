/* This program is aimed to do the cuda implementation of DESnuts */

#include <cuda.h>
#include <stdlib.h>
#include <stdint.h>
#include <inttypes.h>
#include <stdio.h>
#include <inttypes.h>

/**********************************************************************/
/*                                                                    */
/*                            DES TABLES                              */
/*                                                                    */
/**********************************************************************/

#define MAX_THREADS_1D 32
#define MAX_BLOCKS_1D 256
#define CONSTANT_SIZE (sizeof(int) * 8 * 64)
__constant__ int S_TABLE[CONSTANT_SIZE];


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

/*
void print_bits_array(uint64_t n) {
    printf("%lX\n", n);
}

void print_bits(uint64_t n) {
    for (int i = 0 ; i < 64; i++) {
        if (i == 32)
            printf("\n");
        printf("%d", ((n) & 0x8000000000000000) >> 63);
        n <<= 1;
    }
    printf("\n");
    printf("\n");
}
*/
        
#define MASK56(n) ((n) & 0x00FFFFFFFFFFFFFF)
#define MASK48(n) ((n) & 0x0000FFFFFFFFFFFF)


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
    temp = 0UL;                    \
    temp |= ((in & ((1UL) << 63)) >> (39));  \
    temp |= ((in & ((1UL) << 62)) >> (6));  \
    temp |= ((in & ((1UL) << 61)) >> (45));     \
    temp |= ((in & ((1UL) << 60)) >> (12));     \
    temp |= ((in & ((1UL) << 59)) >> (51));     \
    temp |= ((in & ((1UL) << 58)) >> (18));     \
    temp |= ((in & ((1UL) << 57)) >> (57));     \
    temp |= ((in & ((1UL) << 56)) >> (24));     \
    temp |= ((in & ((1UL) << 55)) >> (30));     \
    temp |= ((in & ((1UL) << 54)) << (3));  \
    temp |= ((in & ((1UL) << 53)) >> (36));     \
    temp |= ((in & ((1UL) << 52)) >> (3));  \
    temp |= ((in & ((1UL) << 51)) >> (42));     \
    temp |= ((in & ((1UL) << 50)) >> (9));  \
    temp |= ((in & ((1UL) << 49)) >> (48));     \
    temp |= ((in & ((1UL) << 48)) >> (15));     \
    temp |= ((in & ((1UL) << 47)) >> (21));     \
    temp |= ((in & ((1UL) << 46)) << (12));     \
    temp |= ((in & ((1UL) << 45)) >> (27));     \
    temp |= ((in & ((1UL) << 44)) << (6));  \
    temp |= ((in & ((1UL) << 43)) >> (33));     \
    temp |= ((in & ((1UL) << 42)) << (0));  \
    temp |= ((in & ((1UL) << 41)) >> (39));     \
    temp |= ((in & ((1UL) << 40)) >> (6));  \
    temp |= ((in & ((1UL) << 39)) >> (12));     \
    temp |= ((in & ((1UL) << 38)) << (21));     \
    temp |= ((in & ((1UL) << 37)) >> (18));     \
    temp |= ((in & ((1UL) << 36)) << (15));     \
    temp |= ((in & ((1UL) << 35)) >> (24));     \
    temp |= ((in & ((1UL) << 34)) << (9));  \
    temp |= ((in & ((1UL) << 33)) >> (30));     \
    temp |= ((in & ((1UL) << 32)) << (3));  \
    temp |= ((in & ((1UL) << 31)) >> (3));  \
    temp |= ((in & ((1UL) << 30)) << (30));     \
    temp |= ((in & ((1UL) << 29)) >> (9));  \
    temp |= ((in & ((1UL) << 28)) << (24));     \
    temp |= ((in & ((1UL) << 27)) >> (15));     \
    temp |= ((in & ((1UL) << 26)) << (18));     \
    temp |= ((in & ((1UL) << 25)) >> (21));     \
    temp |= ((in & ((1UL) << 24)) << (12));     \
    temp |= ((in & ((1UL) << 23)) << (6));  \
    temp |= ((in & ((1UL) << 22)) << (39));     \
    temp |= ((in & ((1UL) << 21)) << (0));  \
    temp |= ((in & ((1UL) << 20)) << (33));     \
    temp |= ((in & ((1UL) << 19)) >> (6));  \
    temp |= ((in & ((1UL) << 18)) << (27));     \
    temp |= ((in & ((1UL) << 17)) >> (12));     \
    temp |= ((in & ((1UL) << 16)) << (21));     \
    temp |= ((in & ((1UL) << 15)) << (15));     \
    temp |= ((in & ((1UL) << 14)) << (48));     \
    temp |= ((in & ((1UL) << 13)) << (9));  \
    temp |= ((in & ((1UL) << 12)) << (42));     \
    temp |= ((in & ((1UL) << 11)) << (3));  \
    temp |= ((in & ((1UL) << 10)) << (36));     \
    temp |= ((in & ((1UL) << 9)) >> (3));   \
    temp |= ((in & ((1UL) << 8)) << (30));  \
    temp |= ((in & ((1UL) << 7)) << (24));  \
    temp |= ((in & ((1UL) << 6)) << (57));  \
    temp |= ((in & ((1UL) << 5)) << (18));  \
    temp |= ((in & ((1UL) << 4)) << (51));  \
    temp |= ((in & ((1UL) << 3)) << (12));  \
    temp |= ((in & ((1UL) << 2)) << (45));  \
    temp |= ((in & ((1UL) << 1)) << (6));   \
    temp |= ((in & ((1UL) << 0)) << (39));  \
    L = (temp >> 32) & 0xFFFFFFFF;            \
    R = (temp) & 0xFFFFFFFF;                  \


#define COMPUTE_FP(out, L, R)                   \
    temp = L;                                   \
    temp = (temp << 32) | R;                        \
    out |= ((temp & ((1UL) << 63)) >> (57));    \
    out |= ((temp & ((1UL) << 62)) >> (48));    \
    out |= ((temp & ((1UL) << 61)) >> (39));    \
    out |= ((temp & ((1UL) << 60)) >> (30));    \
    out |= ((temp & ((1UL) << 59)) >> (21));    \
    out |= ((temp & ((1UL) << 58)) >> (12));    \
    out |= ((temp & ((1UL) << 57)) >> (3));     \
    out |= ((temp & ((1UL) << 56)) << (6));     \
    out |= ((temp & ((1UL) << 55)) >> (51));    \
    out |= ((temp & ((1UL) << 54)) >> (42));    \
    out |= ((temp & ((1UL) << 53)) >> (33));    \
    out |= ((temp & ((1UL) << 52)) >> (24));    \
    out |= ((temp & ((1UL) << 51)) >> (15));    \
    out |= ((temp & ((1UL) << 50)) >> (6));     \
    out |= ((temp & ((1UL) << 49)) << (3));     \
    out |= ((temp & ((1UL) << 48)) << (12));    \
    out |= ((temp & ((1UL) << 47)) >> (45));    \
    out |= ((temp & ((1UL) << 46)) >> (36));    \
    out |= ((temp & ((1UL) << 45)) >> (27));    \
    out |= ((temp & ((1UL) << 44)) >> (18));    \
    out |= ((temp & ((1UL) << 43)) >> (9));     \
    out |= ((temp & ((1UL) << 42)) << (0));     \
    out |= ((temp & ((1UL) << 41)) << (9));     \
    out |= ((temp & ((1UL) << 40)) << (18));    \
    out |= ((temp & ((1UL) << 39)) >> (39));    \
    out |= ((temp & ((1UL) << 38)) >> (30));    \
    out |= ((temp & ((1UL) << 37)) >> (21));    \
    out |= ((temp & ((1UL) << 36)) >> (12));    \
    out |= ((temp & ((1UL) << 35)) >> (3));     \
    out |= ((temp & ((1UL) << 34)) << (6));     \
    out |= ((temp & ((1UL) << 33)) << (15));    \
    out |= ((temp & ((1UL) << 32)) << (24));    \
    out |= ((temp & ((1UL) << 31)) >> (24));    \
    out |= ((temp & ((1UL) << 30)) >> (15));    \
    out |= ((temp & ((1UL) << 29)) >> (6));     \
    out |= ((temp & ((1UL) << 28)) << (3));     \
    out |= ((temp & ((1UL) << 27)) << (12));    \
    out |= ((temp & ((1UL) << 26)) << (21));    \
    out |= ((temp & ((1UL) << 25)) << (30));    \
    out |= ((temp & ((1UL) << 24)) << (39));    \
    out |= ((temp & ((1UL) << 23)) >> (18));    \
    out |= ((temp & ((1UL) << 22)) >> (9));     \
    out |= ((temp & ((1UL) << 21)) << (0));     \
    out |= ((temp & ((1UL) << 20)) << (9));     \
    out |= ((temp & ((1UL) << 19)) << (18));    \
    out |= ((temp & ((1UL) << 18)) << (27));    \
    out |= ((temp & ((1UL) << 17)) << (36));    \
    out |= ((temp & ((1UL) << 16)) << (45));    \
    out |= ((temp & ((1UL) << 15)) >> (12));    \
    out |= ((temp & ((1UL) << 14)) >> (3));     \
    out |= ((temp & ((1UL) << 13)) << (6));     \
    out |= ((temp & ((1UL) << 12)) << (15));    \
    out |= ((temp & ((1UL) << 11)) << (24));    \
    out |= ((temp & ((1UL) << 10)) << (33));    \
    out |= ((temp & ((1UL) << 9)) << (42));     \
    out |= ((temp & ((1UL) << 8)) << (51));     \
    out |= ((temp & ((1UL) << 7)) >> (6));  \
    out |= ((temp & ((1UL) << 6)) << (3));  \
    out |= ((temp & ((1UL) << 5)) << (12));     \
    out |= ((temp & ((1UL) << 4)) << (21));     \
    out |= ((temp & ((1UL) << 3)) << (30));     \
    out |= ((temp & ((1UL) << 2)) << (39));     \
    out |= ((temp & ((1UL) << 1)) << (48));     \
    out |= ((temp & ((1UL) << 0)) << (57));     \

#define COMPUTE_P(out, in)  \
    out |= ((in & ((1UL) << 0)) << (11));   \
    out |= ((in & ((1UL) << 1)) << (16));   \
    out |= ((in & ((1UL) << 2)) << (3));    \
    out |= ((in & ((1UL) << 3)) << (24));   \
    out |= ((in & ((1UL) << 4)) << (21));   \
    out |= ((in & ((1UL) << 5)) << (5));    \
    out |= ((in & ((1UL) << 6)) << (14));   \
    out |= ((in & ((1UL) << 7)) >> (7));    \
    out |= ((in & ((1UL) << 8)) << (5));    \
    out |= ((in & ((1UL) << 9)) << (12));   \
    out |= ((in & ((1UL) << 10)) >> (7));   \
    out |= ((in & ((1UL) << 11)) << (17));  \
    out |= ((in & ((1UL) << 12)) << (17));  \
    out |= ((in & ((1UL) << 13)) >> (6));   \
    out |= ((in & ((1UL) << 14)) << (4));   \
    out |= ((in & ((1UL) << 15)) << (9));   \
    out |= ((in & ((1UL) << 16)) << (15));  \
    out |= ((in & ((1UL) << 17)) << (5));   \
    out |= ((in & ((1UL) << 18)) >> (6));   \
    out |= ((in & ((1UL) << 19)) >> (13));  \
    out |= ((in & ((1UL) << 20)) << (6));   \
    out |= ((in & ((1UL) << 21)) >> (19));  \
    out |= ((in & ((1UL) << 22)) >> (6));   \
    out |= ((in & ((1UL) << 23)) >> (15));  \
    out |= ((in & ((1UL) << 24)) >> (10));  \
    out |= ((in & ((1UL) << 25)) << (5));   \
    out |= ((in & ((1UL) << 26)) >> (22));  \
    out |= ((in & ((1UL) << 27)) >> (8));   \
    out |= ((in & ((1UL) << 28)) >> (27));  \
    out |= ((in & ((1UL) << 29)) >> (20));  \
    out |= ((in & ((1UL) << 30)) >> (15));  \
    out |= ((in & ((1UL) << 31)) >> (8));   \


#define COMPUTE_EXPANSION_E(expB, Rin)        \
    expB |= ((R & ((1UL) << 31)) >> (31));  \
    expB |= ((R & ((1UL) << 0)) << (1));    \
    expB |= ((R & ((1UL) << 1)) << (1));    \
    expB |= ((R & ((1UL) << 2)) << (1));    \
    expB |= ((R & ((1UL) << 3)) << (1));    \
    expB |= ((R & ((1UL) << 4)) << (1));    \
    expB |= ((R & ((1UL) << 3)) << (3));    \
    expB |= ((R & ((1UL) << 4)) << (3));    \
    expB |= ((R & ((1UL) << 5)) << (3));    \
    expB |= ((R & ((1UL) << 6)) << (3));    \
    expB |= ((R & ((1UL) << 7)) << (3));    \
    expB |= ((R & ((1UL) << 8)) << (3));    \
    expB |= ((R & ((1UL) << 7)) << (5));    \
    expB |= ((R & ((1UL) << 8)) << (5));    \
    expB |= ((R & ((1UL) << 9)) << (5));    \
    expB |= ((R & ((1UL) << 10)) << (5));   \
    expB |= ((R & ((1UL) << 11)) << (5));   \
    expB |= ((R & ((1UL) << 12)) << (5));   \
    expB |= ((R & ((1UL) << 11)) << (7));   \
    expB |= ((R & ((1UL) << 12)) << (7));   \
    expB |= ((R & ((1UL) << 13)) << (7));   \
    expB |= ((R & ((1UL) << 14)) << (7));   \
    expB |= ((R & ((1UL) << 15)) << (7));   \
    expB |= ((R & ((1UL) << 16)) << (7));   \
    expB |= ((R & ((1UL) << 15)) << (9));   \
    expB |= ((R & ((1UL) << 16)) << (9));   \
    expB |= ((R & ((1UL) << 17)) << (9));   \
    expB |= ((R & ((1UL) << 18)) << (9));   \
    expB |= ((R & ((1UL) << 19)) << (9));   \
    expB |= ((R & ((1UL) << 20)) << (9));   \
    expB |= ((R & ((1UL) << 19)) << (11));  \
    expB |= ((R & ((1UL) << 20)) << (11));  \
    expB |= ((R & ((1UL) << 21)) << (11));  \
    expB |= ((R & ((1UL) << 22)) << (11));  \
    expB |= ((R & ((1UL) << 23)) << (11));  \
    expB |= ((R & ((1UL) << 24)) << (11));  \
    expB |= ((R & ((1UL) << 23)) << (13));  \
    expB |= ((R & ((1UL) << 24)) << (13));  \
    expB |= ((R & ((1UL) << 25)) << (13));  \
    expB |= ((R & ((1UL) << 26)) << (13));  \
    expB |= ((R & ((1UL) << 27)) << (13));  \
    expB |= ((R & ((1UL) << 28)) << (13));  \
    expB |= ((R & ((1UL) << 27)) << (15));  \
    expB |= ((R & ((1UL) << 28)) << (15));  \
    expB |= ((R & ((1UL) << 29)) << (15));  \
    expB |= ((R & ((1UL) << 30)) << (15));  \
    expB |= ((R & ((1UL) << 31)) << (15));  \
    expB |= ((R & ((1UL) << 0)) << (47));   \


#define COMPUTE_PC2(subkey, roundKey)       \
    subkey |= ((roundKey & ((1UL) << 24)) >> (24));     \
    subkey |= ((roundKey & ((1UL) << 27)) >> (26));     \
    subkey |= ((roundKey & ((1UL) << 20)) >> (18));     \
    subkey |= ((roundKey & ((1UL) << 6)) >> (3));   \
    subkey |= ((roundKey & ((1UL) << 14)) >> (10));     \
    subkey |= ((roundKey & ((1UL) << 10)) >> (5));  \
    subkey |= ((roundKey & ((1UL) << 3)) << (3));   \
    subkey |= ((roundKey & ((1UL) << 22)) >> (15));     \
    subkey |= ((roundKey & ((1UL) << 0)) << (8));   \
    subkey |= ((roundKey & ((1UL) << 17)) >> (8));  \
    subkey |= ((roundKey & ((1UL) << 7)) << (3));   \
    subkey |= ((roundKey & ((1UL) << 12)) >> (1));  \
    subkey |= ((roundKey & ((1UL) << 8)) << (4));   \
    subkey |= ((roundKey & ((1UL) << 23)) >> (10));     \
    subkey |= ((roundKey & ((1UL) << 11)) << (3));  \
    subkey |= ((roundKey & ((1UL) << 5)) << (10));  \
    subkey |= ((roundKey & ((1UL) << 16)) >> (0));  \
    subkey |= ((roundKey & ((1UL) << 26)) >> (9));  \
    subkey |= ((roundKey & ((1UL) << 1)) << (17));  \
    subkey |= ((roundKey & ((1UL) << 9)) << (10));  \
    subkey |= ((roundKey & ((1UL) << 19)) << (1));  \
    subkey |= ((roundKey & ((1UL) << 25)) >> (4));  \
    subkey |= ((roundKey & ((1UL) << 4)) << (18));  \
    subkey |= ((roundKey & ((1UL) << 15)) << (8));  \
    subkey |= ((roundKey & ((1UL) << 54)) >> (30));     \
    subkey |= ((roundKey & ((1UL) << 43)) >> (18));     \
    subkey |= ((roundKey & ((1UL) << 36)) >> (10));     \
    subkey |= ((roundKey & ((1UL) << 29)) >> (2));  \
    subkey |= ((roundKey & ((1UL) << 49)) >> (21));     \
    subkey |= ((roundKey & ((1UL) << 40)) >> (11));     \
    subkey |= ((roundKey & ((1UL) << 48)) >> (18));     \
    subkey |= ((roundKey & ((1UL) << 30)) << (1));  \
    subkey |= ((roundKey & ((1UL) << 52)) >> (20));     \
    subkey |= ((roundKey & ((1UL) << 44)) >> (11));     \
    subkey |= ((roundKey & ((1UL) << 37)) >> (3));  \
    subkey |= ((roundKey & ((1UL) << 33)) << (2));  \
    subkey |= ((roundKey & ((1UL) << 46)) >> (10));     \
    subkey |= ((roundKey & ((1UL) << 35)) << (2));  \
    subkey |= ((roundKey & ((1UL) << 50)) >> (12));     \
    subkey |= ((roundKey & ((1UL) << 41)) >> (2));  \
    subkey |= ((roundKey & ((1UL) << 28)) << (12));     \
    subkey |= ((roundKey & ((1UL) << 53)) >> (12));     \
    subkey |= ((roundKey & ((1UL) << 51)) >> (9));  \
    subkey |= ((roundKey & ((1UL) << 55)) >> (12));     \
    subkey |= ((roundKey & ((1UL) << 32)) << (12));     \
    subkey |= ((roundKey & ((1UL) << 45)) >> (0));  \
    subkey |= ((roundKey & ((1UL) << 39)) << (7));  \
    subkey |= ((roundKey & ((1UL) << 42)) << (5));  \


#define COMPUTES_LOOKUP(k, sout, expandedBlock)     \
    sout |= S_TABLE[k * 64 + ((expandedBlock >> (6 * k)) & 0x3F)] << (4 * k);      \

/* This is the host code
#define COMPUTES_LOOKUP(k, sout, expandedBlock)     \
    sout |= table_DES_S[k][(expandedBlock >> (6 * k)) & 0x3F] << (4 * k);      \
*/

/*
uint32_t COMPUTE_F(uint32_t fout, uint32_t R, uint64_t roundKey) {
    uint64_t expandedBlock = 0UL, subkey = 0UL;
    uint32_t sout = 0;
    int i, k;

    COMPUTE_EXPANSION_E(expandedBlock, R)

    printf("expanded E is : \n");
    print_bits_array(expandedBlock);

    COMPUTE_PC2(subkey, roundKey)

    printf("subkey is :\n");
    print_bits_array(subkey);

    expandedBlock ^= subkey;
    // Mask expandedBlock
    expandedBlock = MASK48(expandedBlock);
    printf("Expanded E is :\n");
    print_bits_array(expandedBlock);

    for (k = 0; k < 8; k++) {
        COMPUTES_LOOKUP(k, sout, expandedBlock)

        printf("sout @ %d is :\n", k);
        print_bits_array(sout);
    }

    COMPUTE_P(fout, sout)

    printf("fout is :\n");
    print_bits_array(fout);
    printf("sout is :\n");
    print_bits_array(sout);

    return fout;
}
*/


#define ROTATE_ROUND_KEY_LEFT(roundK)         \
    uint64_t bit27 = ((roundK & ((1UL) << 27)) >> 27);\
    uint64_t bit55 = ((roundK & ((1UL) << 55)) >> 27);\
    roundK <<= 1;                             \
    temp = roundK & 0x00FFFFFFEFFFFFFE;            \
    roundK = temp | bit27 | bit55;           \




#define EXCHANGE_L_AND_R(L, R)                  \
    temp = L;                                   \
    L = R;                                      \
    R = temp;                                   \
    

__global__ void EncryptDES_device(uint64_t in, uint64_t expected, uint64_t* result, uint64_t bound) {

    int blockId = blockIdx.x + blockIdx.y * gridDim.x; 
    int threadId = blockId * (blockDim.x * blockDim.y) + (threadIdx.y * blockDim.x) + threadIdx.x;
    uint64_t key = threadId * bound;
    uint64_t counter = 0;
    
    while (counter != bound) {

        uint32_t R = 0, L = 0; 
        uint64_t roundKey = 0UL, out = 0UL, temp = 0UL;

        COMPUTE_ROUND_KEY(roundKey, key)

        COMPUTE_IP(L, R, in)

        for (int round = 0; round < 16; round++) {
            uint64_t expandedBlock = 0UL, subkey = 0UL;
            uint32_t sout = 0;
            uint32_t fout = 0;

            ROTATE_ROUND_KEY_LEFT(roundKey)

            if (round != 0 && round != 1 && round != 8 && round != 15) {
                ROTATE_ROUND_KEY_LEFT(roundKey)
            }


            COMPUTE_EXPANSION_E(expandedBlock, R)

            COMPUTE_PC2(subkey, roundKey)


            expandedBlock ^= subkey;
            expandedBlock = MASK48(expandedBlock);

            for (int i = 0; i < 8; i++) {
                COMPUTES_LOOKUP(i, sout, expandedBlock)
            }

            COMPUTE_P(fout, sout)

                L ^= fout;

            EXCHANGE_L_AND_R(L, R)

        }
        EXCHANGE_L_AND_R(L, R)

        COMPUTE_FP(out, L, R)

        if (out == expected) {
            *result = out;
             // asm("trap;");
        }
        counter++;
        key++;
    }
    __syncthreads();
}

/*
void EncryptDES_host(uint64_t key, uint64_t in, uint64_t expected) {
    uint32_t R = 0, L = 0; 
    uint64_t roundKey = 0UL, out = 0UL, temp = 0UL;
    
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

    for (int round = 0; round < 16; round++) {
        uint64_t expandedBlock = 0UL, subkey = 0UL;
        uint32_t sout = 0;
        uint32_t fout = 0;

        printf("------------------------- ROUND %d ----------------------\n", round);
    

        ROTATE_ROUND_KEY_LEFT(roundKey)
        
        printf("\t roundKey:\n");
        print_bits_array(roundKey);

        if (round != 0 && round != 1 && round != 8 && round != 15) {
            ROTATE_ROUND_KEY_LEFT(roundKey)
        }


        COMPUTE_EXPANSION_E(expandedBlock, R)

        printf("expanded E is : \n");
        print_bits_array(expandedBlock);

        COMPUTE_PC2(subkey, roundKey)

        printf("subkey is :\n");
        print_bits_array(subkey);

        expandedBlock ^= subkey;
        // Mask expandedBlock
        expandedBlock = MASK48(expandedBlock);
        printf("Expanded E is :\n");
        print_bits_array(expandedBlock);

        for (int i = 0; i < 8; i++) {
               Comment out for compilation of the device code

            COMPUTES_LOOKUP(i, sout, expandedBlock)
            printf("sout @ %d is :\n", i);
            print_bits_array(sout);
        }

        COMPUTE_P(fout, sout)

        printf("fout is :\n");
        print_bits_array(fout);
        printf("sout is :\n");
        print_bits_array(sout);

        printf("f is : \n");
        print_bits_array(fout);

        L ^= fout;

        printf("L^f is : \n");
        print_bits_array(L);
        
        EXCHANGE_L_AND_R(L, R)

        printf("------------------------- ROUND %d end ------------------\n", round);
         
    }
    EXCHANGE_L_AND_R(L, R)

    COMPUTE_FP(out, L, R)
    
    printf("FP out is \n");
    print_bits_array(out);

}
*/


int main(int argc, char **argv) {

    uint64_t random_o = 0xF77D7F53F77D7F53;
    // uint64_t random_k = 0x2FEABF912FEABF;
    uint64_t expected = 0xDF86B0B30BD2530A;

    cudaEvent_t start, stop;
    cudaEventCreate(&start);
    cudaEventCreate(&stop);
    float milliseconds = 0;

    uint64_t *result_host = (uint64_t *)calloc(1, sizeof(uint64_t));
    uint64_t *result_device;
    cudaMalloc(&result_device, sizeof(uint64_t));


    cudaMemcpy(result_device, result_host, sizeof(uint64_t),  cudaMemcpyHostToDevice);
    cudaMemcpyToSymbol(S_TABLE, table_DES_S, CONSTANT_SIZE);

    int threads = MAX_THREADS_1D / 2;
    int blocks = (MAX_BLOCKS_1D - 1);

    uint64_t overall_total = 0x0FFFFFFFFFFFFFFFULL;
    uint64_t target_total = 0xFFFFFFFFFFULL;

    dim3 dimGrid(blocks, blocks);
    dim3 dimBlock(threads, threads);

    cudaEventRecord(start, 0);
    cudaEventSynchronize(start);

    EncryptDES_device<<<dimGrid, dimBlock>>>(random_o, expected, result_device, (target_total / (blocks * blocks * threads * threads)));
    cudaDeviceSynchronize();

    cudaEventRecord(stop);
    cudaEventSynchronize(stop);
    cudaEventElapsedTime(&milliseconds, start, stop);

    printf("Cuda Execution Report: \n");
    printf("Targetting number of testing key - %" PRIu64 "\n", target_total);
    printf("Time spent %0.8f ms\n", milliseconds);
    printf("\n");
    printf("Estimated time to crack DES is %0.8f ms\n", (overall_total * 1.0 / target_total) * milliseconds);

    cudaMemcpy(result_host, result_device, sizeof(uint64_t), cudaMemcpyDeviceToHost);

    if (*result_host != 0x0)
        printf("Key found: %lX\n", *result_host);


    free(result_host);
    cudaFree(result_device);
    cudaEventDestroy(start);
    cudaEventDestroy(stop);

    return 0;
}

