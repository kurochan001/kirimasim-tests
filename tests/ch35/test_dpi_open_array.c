/* C side of test_dpi_open_array (IEEE 1800-2023 35.5.6.1, H.12). */
#include <stdio.h>
#include <stdlib.h>
#include "svdpi.h"

#ifdef __cplusplus
extern "C" {
#endif

int dpi_sum(const svOpenArrayHandle a)
{
    int s = 0;
    for (int i = svLow(a, 1); i <= svHigh(a, 1); i++)
        s += *(int *)svGetArrElemPtr1(a, i);
    return s;
}

void dpi_bounds(const svOpenArrayHandle a, int *left, int *right, int *size)
{
    *left = svLeft(a, 1);
    *right = svRight(a, 1);
    *size = svSize(a, 1);
}

void dpi_iota(const svOpenArrayHandle a, int start)
{
    int step = svLeft(a, 1) <= svRight(a, 1) ? 1 : -1;
    for (int i = svLeft(a, 1);; i += step) {
        *(int *)svGetArrElemPtr1(a, i) = start++;
        if (i == svRight(a, 1))
            break;
    }
}

#ifdef __cplusplus
}
#endif
