/* C side of test_dpi_packed_canonical (IEEE 1800-2023 H.7.7, H.11.5). */
#include <stdio.h>
#include <stdlib.h>
#include "svdpi.h"

#ifdef __cplusplus
extern "C" {
#endif

int dpi_popcount40(const svBitVecVal *a)
{
    int n = 0;
    for (int i = 0; i < 40; i++)
        n += svGetBitselBit(a, i);
    return n;
}

void dpi_reverse40(const svBitVecVal *a, svBitVecVal *r)
{
    for (int i = 0; i < 40; i++)
        svPutBitselBit(r, 39 - i, svGetBitselBit(a, i));
}

int dpi_slice_35_28(const svBitVecVal *a)
{
    svBitVecVal w = 0;
    svGetPartselBit(&w, a, 28, 8);
    return (int)(w & 0xff);
}

int dpi_low_word(const svBitVecVal *a) { return (int)a[0]; }

#ifdef __cplusplus
}
#endif
