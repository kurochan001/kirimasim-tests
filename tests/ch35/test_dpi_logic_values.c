/* C side of test_dpi_logic_values (IEEE 1800-2023 H.10.1). */
#include <stdio.h>
#include <stdlib.h>
#include "svdpi.h"

#ifdef __cplusplus
extern "C" {
#endif

int dpi_code(svLogic l) { return l; }

void dpi_make(svLogicVecVal *v)
{
    v[0].aval = 0x9; /* 1 0 z x */
    v[0].bval = 0x3;
}

void dpi_planes(const svLogicVecVal *v, int *a, int *b)
{
    *a = (int)(v[0].aval & 0xf);
    *b = (int)(v[0].bval & 0xf);
}

#ifdef __cplusplus
}
#endif
