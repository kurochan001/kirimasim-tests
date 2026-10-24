/* C side of test_dpi_dynamic_array_actual (IEEE 1800-2023 35.6.1.1). */
#include <stdio.h>
#include <stdlib.h>
#include "svdpi.h"

#ifdef __cplusplus
extern "C" {
#endif

void dpi_open_info(const svOpenArrayHandle a, int *size, int *left, int *right, int *sum)
{
    int i, lo, hi, total = 0;

    *size = svSize(a, 1);
    *left = svLeft(a, 1);
    *right = svRight(a, 1);
    lo = svLow(a, 1);
    hi = svHigh(a, 1);
    for (i = lo; i <= hi; i++)
        total += *(int *)svGetArrElemPtr1(a, i);
    *sum = total;
}

void dpi_fixed_sum(const int *a, int *sum, int *c0)
{
    *sum = a[0] + a[1] + a[2];
    *c0 = a[0];
}

void dpi_fixed_fill(int *a)
{
    a[0] = 7;
    a[1] = 8;
    a[2] = 9;
}

#ifdef __cplusplus
}
#endif
