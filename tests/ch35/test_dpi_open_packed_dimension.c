/* C side of test_dpi_open_packed_dimension (IEEE 1800-2023 35.5.6.1). */
#include <stdio.h>
#include <stdlib.h>
#include "svdpi.h"

#ifdef __cplusplus
extern "C" {
#endif

void dpi_shape(const svOpenArrayHandle v, int *pl, int *pr, int *ps, int *ul, int *ur,
               int *first)
{
    svBitVecVal elem[2] = {0, 0};

    *pl = svLeft(v, 0);
    *pr = svRight(v, 0);
    *ps = svSize(v, 0);
    *ul = svLeft(v, 1);
    *ur = svRight(v, 1);
    svGetBitArrElem1VecVal(elem, v, svLeft(v, 1));
    /* Bits above the size of the packed part are not determined (H.7.7). */
    *first = (int)(*ps >= 32 ? elem[0] : elem[0] & ((1u << *ps) - 1u));
}

#ifdef __cplusplus
}
#endif
