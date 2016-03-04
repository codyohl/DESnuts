public class PrintPerm {

    public static int[] table_DES_PC1 = {
        27, 19, 11, 31, 39, 47, 55,
        26, 18, 10, 30, 38, 46, 54,
        25, 17,  9, 29, 37, 45, 53,
        24, 16,  8, 28, 36, 44, 52,
        23, 15,  7,  3, 35, 43, 51,
        22, 14,  6,  2, 34, 42, 50,
        21, 13,  5,  1, 33, 41, 49,
        20, 12,  4,  0, 32, 40, 48
    };

    public static int[] table_DES_IP = {
        39,  7, 47, 15, 55, 23, 63, 31,
        38,  6, 46, 14, 54, 22, 62, 30,
        37,  5, 45, 13, 53, 21, 61, 29,
        36,  4, 44, 12, 52, 20, 60, 28,
        35,  3, 43, 11, 51, 19, 59, 27,
        34,  2, 42, 10, 50, 18, 58, 26,
        33,  1, 41,  9, 49, 17, 57, 25,
        32,  0, 40,  8, 48, 16, 56, 24
    };

    public static void main(String[] args) {
        for (int i = 0; i < 56; i++) {
            int diff = (i) - table_DES_PC1[i];
            if (diff > 0)
                System.out.println("\troundKey |= ((key & ((1UL) << " + (i) + ")) >> (" + diff + ")); \t\\");
            else 
                System.out.println("\troundKey |= ((key & ((1UL) << " + (i) + ")) << (" + Math.abs(diff) + ")); \t\\");
        }
        System.out.println();

        for (int i = 63; i >= 0; i--) {
            int diff = (i) - table_DES_IP[i];
            if (diff > 0)
                System.out.println("\toutput |= ((in & ((1UL) << " + (i) + ")) >> (" + diff + ")); \t\\");
            else 
                System.out.println("\toutput |= ((in & ((1UL) << " + (i) + ")) << (" + Math.abs(diff) + ")); \t\\");
        }
    }
}

