/* C side of test_dpi_open_array_element_access (IEEE 1800-2023 H.12.3). */
#include <stdio.h>
#include "svdpi.h"

#ifdef __cplusplus
extern "C" {
#endif

void c_packed(const svOpenArrayHandle h, const svOpenArrayHandle q)
{
    int k;
    svBitVecVal v;
    svLogicVecVal w;

    for (k = svLow(h, 1); k <= svHigh(h, 1); k++) {
        v = 0;
        svGetBitArrElem1VecVal(&v, h, k);
        printf("c_packed: p[%d] = %03x\n", k, (unsigned)(v & 0xfffu));
        v = (v + 1) & 0xfffu;
        svPutBitArrElem1VecVal(h, &v, k);
    }
    for (k = 0; k <= 1; k++) {
        w.aval = 0;
        w.bval = 0;
        svGetLogicArrElem1VecVal(&w, q, k);
        printf("c_packed: q[%d] = aval %03x bval %03x\n", k, (unsigned)(w.aval & 0xfffu),
               (unsigned)(w.bval & 0xfffu));
        w.aval = (w.aval + 1) & 0xfffu;
        w.bval = 0;
        svPutLogicArrElem1VecVal(q, &w, k);
    }
    fflush(stdout);
}

void c_scalars(const svOpenArrayHandle s, const svOpenArrayHandle l)
{
    int k;

    printf("c_scalars: s");
    for (k = 0; k <= 3; k++)
        printf(" %d", (int)svGetBitArrElem1(s, k));
    printf(", l");
    for (k = 0; k <= 3; k++)
        printf(" %d", (int)svGetLogicArrElem1(l, k));
    printf("\n");
    for (k = 0; k <= 3; k++) {
        svPutBitArrElem1(s, svGetBitArrElem1(s, k) == sv_1 ? sv_0 : sv_1, k);
        svPutLogicArrElem1(l, svGetLogicArrElem1(l, k) == sv_1 ? sv_0 : sv_1, k);
    }
    fflush(stdout);
}

void c_others(const svOpenArrayHandle i, const svOpenArrayHandle g)
{
    int k;
    void *whole = svGetArrayPtr(i);
    int bytes = svSizeOfArray(i);

    for (k = 1; k <= 3; k++) {
        int *e = (int *)svGetArrElemPtr1(i, k);
        printf("c_others: i[%d] = %d\n", k, *e);
        *e *= 2;
    }
    for (k = 0; k <= 1; k++) {
        long long *e = (long long *)svGetArrElemPtr1(g, k);
        printf("c_others: g[%d] = %lld\n", k, *e);
        *e *= 2;
    }
    printf("c_others: whole-array pointer and size agree: %d\n",
           whole != NULL ? whole == svGetArrElemPtr1(i, 1) && bytes == 3 * (int)sizeof(int)
                         : bytes == 0);
    fflush(stdout);
}

#ifdef __cplusplus
}
#endif
