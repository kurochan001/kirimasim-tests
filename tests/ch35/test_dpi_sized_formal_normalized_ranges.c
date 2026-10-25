/* C side of test_dpi_sized_formal_normalized_ranges (IEEE 1800-2023 H.11, H.7.6). */
#include <stdio.h>
#include "svdpi.h"

#ifdef __cplusplus
extern "C" {
#endif

void c_sized(const svBitVecVal *y, const svLogicVecVal *z, const int *u, int *ou)
{
    int k;

    /* bit [3:0][1:0] y [2:1]: one chunk per element, C index 0 first */
    printf("y in C order: %02x %02x\n", (unsigned)(y[0] & 0xffu), (unsigned)(y[1] & 0xffu));
    /* logic [0:5] z: normalized [5:0] */
    printf("z: aval %02x, C bit 5 %d, C bit 0 %d\n", (unsigned)(z->aval & 0x3fu),
           (int)svGetBitselLogic(z, 5), (int)svGetBitselLogic(z, 0));
    /* int u [1:3][2:0]: C int u[3][3] */
    printf("u in C order:");
    for (k = 0; k < 9; k++)
        printf(" %d", u[k]);
    printf("\n");
    /* int ou [3:1]: C int ou[3] */
    for (k = 0; k < 3; k++)
        ou[k] = (k + 1) * 100;
    fflush(stdout);
}

void c_open(const svOpenArrayHandle yo)
{
    svBitVecVal v1 = 0, v2 = 0;

    svGetBitArrElem1VecVal(&v2, yo, 2);
    svGetBitArrElem1VecVal(&v1, yo, 1);
    printf("open: dimension 1 %d:%d, dimension 0 %d:%d, index 2 %02x, index 1 %02x\n",
           svLeft(yo, 1), svRight(yo, 1), svLeft(yo, 0), svRight(yo, 0),
           (unsigned)(v2 & 0xffu), (unsigned)(v1 & 0xffu));
    fflush(stdout);
}

#ifdef __cplusplus
}
#endif
