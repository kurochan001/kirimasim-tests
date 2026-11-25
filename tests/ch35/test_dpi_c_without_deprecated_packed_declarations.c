#include <stdio.h>
#include "svdpi.h"

#ifdef DPI_REQUIRE_OBSOLETE_GET
static void (*volatile legacy_get_bits)(svBitVec32 *, const svBitPackedArrRef, int) = svGetBitVec32;
#endif

#ifdef __cplusplus
extern "C" {
#endif

void modern_values(const svBitVecVal *data, svBitVecVal *result)
{
#ifdef DPI_REQUIRE_OBSOLETE_GET
    /* Keep the old function as a link dependency without calling it on a modern object. */
    if (!legacy_get_bits) {
        puts("legacy function unavailable");
        return;
    }
#endif
    result[0] = data[0] ^ 0xa5u;
    result[1] = data[1] ^ 0xffffffffu;
    result[2] = data[2] ^ 1u;
    printf("C observed high=%u low=%08x\n", (unsigned)data[2], (unsigned)data[0]);
    fflush(stdout);
}

#ifdef __cplusplus
}
#endif
