/* C side of test_dpi_import_output_inout (IEEE 1800-2023 35.6.2, H.8.8). */
#include <stdio.h>
#include <stdlib.h>
#include "svdpi.h"

#ifdef __cplusplus
extern "C" {
#endif

void dpi_divmod(int a, int b, int *q, int *r)
{
    *q = a / b;
    *r = a % b;
}

void dpi_bump(int *x, int by) { *x += by; }

void dpi_fill12(svBitVecVal *v) { v[0] = 0xace; }

void dpi_swap_nibbles(svBitVecVal *v)
{
    unsigned b = v[0] & 0xff;
    v[0] = ((b << 4) | (b >> 4)) & 0xff;
}

void dpi_name(const char **s) { *s = "set by C"; }

#ifdef __cplusplus
}
#endif
