#include <stdio.h>
#include "svdpi.h"

#ifdef __cplusplus
extern "C" {
#endif

void modern_transfer(const svBitVecVal *a, const svLogicVecVal *b,
                     svBitVecVal *x, svLogicVecVal *y)
{
    printf("modern low=%08x logic=%08x/%08x top=%u\n",
           (unsigned)a[0], (unsigned)b[0].aval, (unsigned)b[0].bval,
           (unsigned)(b[2].aval & 1u));
    for (int i = 0; i < 3; ++i) {
        x[i] = a[i];
        y[i] = b[i];
    }
    fflush(stdout);
}

void legacy_transfer(const svBitPackedArrRef a, const svLogicPackedArrRef b,
                     svBitPackedArrRef x, svLogicPackedArrRef y)
{
    enum { width = 65, chunks = SV_CANONICAL_SIZE(width) };
    svBitVec32 bits[chunks] = {0};
    svLogicVec32 state[chunks] = {{0, 0}};
    svGetBitVec32(bits, a, width);
    svGetLogicVec32(state, b, width);
    printf("legacy low=%08x logic=%08x/%08x top=%u\n",
           (unsigned)bits[0], (unsigned)state[0].c, (unsigned)state[0].d,
           (unsigned)(state[2].c & 1u));
    svPutBitVec32(x, bits, width);
    svPutLogicVec32(y, state, width);
    fflush(stdout);
}

#ifdef __cplusplus
}
#endif
