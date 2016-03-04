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

    public static void main(String[] args) {
        for (int i = 0; i < 56; i++) {
            int diff = (55 - i) - (56 - table_DES_PC1[i]);
            if (diff > 0)
                System.out.println("\troundKey |= ((key & ((1UL) << " + (55 - i) + ")) >> (" + diff + ")); \t\\");
            else 
                System.out.println("\troundKey |= ((key & ((1UL) << " + (55 - i) + ")) << (" + Math.abs(diff) + ")); \t\\");
        }
    }
}

