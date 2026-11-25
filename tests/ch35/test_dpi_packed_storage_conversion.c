#include <stdio.h>
#include "svdpi.h"

#ifdef __cplusplus
extern "C" {
#endif

static void exchange_bit(const char *name, const svBitVecVal *src, svBitVecVal *dst)
{
    printf("%s words=%08x,%x\n", name, (unsigned)src[0], (unsigned)(src[1] & 3u));
    dst[0] = src[0] ^ 0x10u;
    dst[1] = src[1] & 3u;
    fflush(stdout);
}

static void exchange_logic(const char *name, const svLogicVecVal *src, svLogicVecVal *dst)
{
    printf("%s words=%08x/%08x,%x/%x\n", name, (unsigned)src[0].aval, (unsigned)src[0].bval,
           (unsigned)(src[1].aval & 3u), (unsigned)(src[1].bval & 3u));
    dst[0].aval = src[0].aval ^ 0x10u;
    dst[0].bval = src[0].bval;
    dst[1].aval = (src[1].aval ^ src[1].bval) & 3u;
    dst[1].bval = src[1].bval & 3u;
    fflush(stdout);
}

void transfer_bit_record(const svBitVecVal *src, svBitVecVal *dst)
{
    exchange_bit("bit record", src, dst);
}

void transfer_bit_grid(const svBitVecVal *src, svBitVecVal *dst)
{
    exchange_bit("bit grid", src, dst);
}

void transfer_logic_record(const svLogicVecVal *src, svLogicVecVal *dst)
{
    exchange_logic("logic record", src, dst);
}

void transfer_logic_grid(const svLogicVecVal *src, svLogicVecVal *dst)
{
    exchange_logic("logic grid", src, dst);
}

#ifdef __cplusplus
}
#endif
