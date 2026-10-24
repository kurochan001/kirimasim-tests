/* C side of test_dpi_packed_struct_union_formals (IEEE 1800-2023 35.5.6). */
#include <stdio.h>
#include <stdlib.h>
#include "svdpi.h"

#ifdef __cplusplus
extern "C" {
#endif

int dpi_low16_pair(const svBitVecVal *v)
{
    return (int)(v[0] & 0xffff);
}

int dpi_low16_union(const svBitVecVal *v)
{
    return (int)(v[0] & 0xffff);
}

int dpi_low16_2d(const svBitVecVal *v)
{
    return (int)(v[0] & 0xffff);
}

int dpi_low8_logic(const svLogicVecVal *v)
{
    return (int)(v[0].aval & 0xff);
}

void dpi_make_pair(svBitVecVal *v)
{
    v[0] = 0xabcd;
}

#ifdef __cplusplus
}
#endif
