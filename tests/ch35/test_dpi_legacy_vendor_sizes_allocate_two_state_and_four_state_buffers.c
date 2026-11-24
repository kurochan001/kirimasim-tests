#include <stdio.h>
#include <stdlib.h>
#include "svdpi.h"

#ifdef __cplusplus
extern "C" {
#endif

static int copy_at_width(int width)
{
    int bit_size = svSizeOfBitPackedArr(width);
    int logic_size = svSizeOfLogicPackedArr(width);
    if (bit_size <= 0 || logic_size <= 0)
        return 0;

    svBitPackedArrRef bit_storage = calloc(1, (size_t)bit_size);
    svLogicPackedArrRef logic_storage = calloc(1, (size_t)logic_size);
    int ok = 0;
    if (bit_storage != NULL && logic_storage != NULL) {
        svBitVec32 bits[3] = {0}, read_bits[3] = {0};
        svLogicVec32 state[3] = {{0, 0}}, read_state[3] = {{0, 0}};
        int word = (width - 1) / 32;
        unsigned top_bit = 1u << ((width - 1) % 32);
        bits[word] = top_bit;
        state[word].d = top_bit;
        svPutBitVec32(bit_storage, bits, width);
        svPutLogicVec32(logic_storage, state, width);
        svGetBitVec32(read_bits, bit_storage, width);
        svGetLogicVec32(read_state, logic_storage, width);
        ok = (read_bits[word] & top_bit) == top_bit &&
             (read_state[word].c & top_bit) == 0 &&
             (read_state[word].d & top_bit) == top_bit;
    }
    free(bit_storage);
    free(logic_storage);
    return ok;
}

int check_legacy_sizes(void)
{
    int ok = copy_at_width(1) && copy_at_width(33) && copy_at_width(65);
    printf("allocation and copy at all three widths=%d\n", ok);
    fflush(stdout);
    return ok;
}

#ifdef __cplusplus
}
#endif
