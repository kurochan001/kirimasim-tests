/* C side of test_dpi_open_array_layout_and_element_representation (IEEE 1800-2023 H.7.3, H.12.4). */
#include <stdio.h>
#include "svdpi.h"

#ifdef __cplusplus
extern "C" {
#endif

int c_layout(const svOpenArrayHandle a)
{
    int *p = (int *)svGetArrayPtr(a);
    int bytes = svSizeOfArray(a);
    int n = svSize(a, 1);
    int sum = 0;
    int first = 0, last = 0;
    int i;

    if (p != NULL) {
        for (i = 0; i < n; i++)
            sum += p[i];
    }
    first = *(int *)svGetArrElemPtr1(a, 0);
    last = *(int *)svGetArrElemPtr1(a, 3);
    printf("int ptr %d size %d sum %d ends %d %d\n",
           p != NULL, bytes, sum, first, last);
    return n;
}

int c_packed(const svOpenArrayHandle e)
{
    svLogicVecVal v[2];
    unsigned low[3];
    int bsum = 0;
    int i;

    for (i = 0; i < 3; i++) {
        v[0].aval = 0;
        v[0].bval = 0;
        v[1].aval = 0;
        v[1].bval = 0;
        svGetLogicArrElem1VecVal(v, e, i);
        low[i] = (unsigned)(v[0].aval & 0xFFu);
        bsum += (int)v[0].bval;
    }
    printf("logic packed size %d unpacked %d values %02x %02x %02x bval %d\n",
           svSize(e, 0), svSize(e, 1), low[0], low[1], low[2], bsum);
    return bsum;
}

#ifdef __cplusplus
}
#endif
