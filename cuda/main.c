#include "des.h"
#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <inttypes.h>
#include <string.h>

#define MASK56(n) ((n) & 0x00FFFFFFFFFFFFFF)

int main(int argc, char **argv) {
    bool *original = (bool *) malloc(sizeof(bool) * 64);
    bool *key = (bool *)malloc(sizeof(bool) * 56);
    bool *afterDES = (bool *)malloc(sizeof(bool) * 64);

    uint64_t random_o = 0x19238563cafebeef;
    uint64_t random_k = MASK56(0xffff223112feabf);


    for (int i = 0; i < 64; i++) {
        original[63 - i] = random_o & (0x1 << i) ? 1 : 0;
    }

    for (int i = 0; i < 64; i++) {
        key[i] = random_k & (0x1 << i) ? 1 : 0;
    }

    printf("The original is  :\n");
    for (int i = 0; i < 64; i++) {
        printf("%d", original[i]);
    }
    printf("\n");

    printf("The key      is  %lx\n", random_k);
    for (int i = 0; i < 64; i++) {
        if (i < 8)
            printf("%d", 0);
        else 
            printf("%d", key[i - 8]);
    }
    printf("\n");


    EncryptDES(key, afterDES, original, 1);

    printf("The encrypt  is :\n");
    for (int i = 0; i < 64; i++) {
        printf("%d", afterDES[i]);
    }
    printf("\n");
    

    bool *decrypt_original = (bool *) malloc(sizeof(bool) * 64);
    memset(decrypt_original, 0, 64);

    DecryptDES(key, decrypt_original, afterDES, 0);

    printf("The decrypt  is :\n");
    for (int i = 0; i < 64; i++) {
        printf("%d", decrypt_original[i]);
    }
    printf("\n");

    return 0;
}
