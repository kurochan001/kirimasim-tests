/* C side of test_dpi_output_value_change_events (IEEE 1800-2023 35.6.2). */
#include <stdio.h>
#include <stdlib.h>
#include "svdpi.h"

#ifdef __cplusplus
extern "C" {
#endif

void c_byte(svBitVecVal *b)
{
    b[0] = 0x5a;
}

void c_set(int *v, int value)
{
    *v = value;
}

void c_keep(int *v)
{
    *v = *v;
}

void c_negate(int *v)
{
    *v = -*v;
}

#ifdef __cplusplus
}
#endif
