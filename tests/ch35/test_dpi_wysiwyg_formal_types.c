/* C side of test_dpi_wysiwyg_formal_types (IEEE 1800-2023 35.6.1.1). */
#include <stdio.h>
#include <stdlib.h>
#include "svdpi.h"

#ifdef __cplusplus
extern "C" {
#endif

void c_ends(const int *a, int *c0, int *c3)
{
    *c0 = a[0];
    *c3 = a[3];
}

int c_low16(const svBitVecVal *v)
{
    return (int)(v[0] & 0xffffu);
}

void c_add(int *v, int add)
{
    *v += add;
}

/* The packed range as left*1000 + right*100, then the unpacked range as
   left*10 + right. */
int c_shape(const svOpenArrayHandle b)
{
    return svLeft(b, 0) * 1000 + svRight(b, 0) * 100 + svLeft(b, 1) * 10 + svRight(b, 1);
}

#ifdef __cplusplus
}
#endif
