#include "svdpi.h"

#ifdef __cplusplus
extern "C" {
#endif

void transfer_legacy(const svBitPackedArrRef source, svBitPackedArrRef target)
{
    enum { width = 45 };
    svBitVec32 value[SV_CANONICAL_SIZE(width)] = {0};
    svGetBitVec32(value, source, width);
    value[0] ^= 0xffffffffu;
    svPutBitVec32(target, value, width);
}

void transfer_modern(const svBitVecVal *source, svBitVecVal *target)
{
    target[0] = source[0] ^ 0xff00u;
    target[1] = source[1] & 0x1fffu;
}

#ifdef __cplusplus
}
#endif
