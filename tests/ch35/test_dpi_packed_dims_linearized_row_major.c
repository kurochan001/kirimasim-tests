/* C side of test_dpi_packed_dims_linearized_row_major (IEEE 1800-2023 H.7.5). */
#include <stdio.h>
#include "svdpi.h"

#ifdef __cplusplus
extern "C" {
#endif

void c_sized(const svBitVecVal *p, const svBitVecVal *q, const svLogicVecVal *r, svBitVecVal *po)
{
    printf("p %06x\n", (unsigned)(p[0] & 0xffffffu));
    printf("q %06x\n", (unsigned)(q[0] & 0xffffffu));
    printf("r aval %02x bval %02x\n", (unsigned)(r->aval & 0x3fu), (unsigned)(r->bval & 0x3fu));
    po[0] = (1u << 22) | (1u << 9) | (1u << 5);
    fflush(stdout);
}

void c_unpacked(const int *c3)
{
    int k;

    printf("c3 in C order:");
    for (k = 0; k < 12; k++)
        printf(" %d", c3[k]);
    printf("\nc3 as int[2][3][2]: [1][2][0] %d [0][1][1] %d\n",
           ((const int (*)[3][2])c3)[1][2][0], ((const int (*)[3][2])c3)[0][1][1]);
    fflush(stdout);
}

#ifdef __cplusplus
}
#endif
