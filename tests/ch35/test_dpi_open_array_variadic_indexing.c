/* C side of test_dpi_open_array_variadic_indexing (IEEE 1800-2023 H.12.3). */
#include <stdio.h>
#include "svdpi.h"

#ifdef __cplusplus
extern "C" {
#endif

static int value(void *p) { return p != NULL ? *(int *)p : -1; }

void c_index(const svOpenArrayHandle m1, const svOpenArrayHandle m2, const svOpenArrayHandle m3,
             const svOpenArrayHandle m4, const svOpenArrayHandle b3, const svOpenArrayHandle b4)
{
    svBitVecVal a = 0, b = 0, w;

    printf("one index: m1[4] = %d, same as svGetArrElemPtr1: %d\n",
           value(svGetArrElemPtr(m1, 4)), svGetArrElemPtr(m1, 4) == svGetArrElemPtr1(m1, 4));
    printf("two indices: m2[1][2] = %d, same as svGetArrElemPtr2: %d\n",
           value(svGetArrElemPtr(m2, 1, 2)),
           svGetArrElemPtr(m2, 1, 2) == svGetArrElemPtr2(m2, 1, 2));
    printf("three indices: m3[2][1][3] = %d, same as svGetArrElemPtr3: %d\n",
           value(svGetArrElemPtr(m3, 2, 1, 3)),
           svGetArrElemPtr(m3, 2, 1, 3) == svGetArrElemPtr3(m3, 2, 1, 3));
    printf("four indices: m4[2][1][2][1] = %d, m4[1][0][3][2] = %d\n",
           value(svGetArrElemPtr(m4, 2, 1, 2, 1)), value(svGetArrElemPtr(m4, 1, 0, 3, 2)));

    svGetBitArrElemVecVal(&a, b3, 2, 1, 2);
    svGetBitArrElem3VecVal(&b, b3, 2, 1, 2);
    printf("b3[2][1][2]: variadic %02x, three-index %02x\n", (unsigned)(a & 0xffu),
           (unsigned)(b & 0xffu));
    w = 0xa5u;
    svPutBitArrElemVecVal(b3, &w, 1, 0, 3);
    w = 0x3cu;
    svPutBitArrElemVecVal(b4, &w, 2, 1, 2, 1);
    w = 0x81u;
    svPutBitArrElemVecVal(b4, &w, 1, 0, 3, 0);
    fflush(stdout);
}

#ifdef __cplusplus
}
#endif
