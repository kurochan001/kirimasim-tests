/* C side of test_dpi_open_array_actual_sizes (IEEE 1800-2023 35.5.6.1, H.12). */
#include "svdpi.h"

#ifdef __cplusplus
extern "C" {
#endif

int c_sum(const svOpenArrayHandle a)
{
    int sum = 0;
    int i;
    for (i = svLow(a, 1); i <= svHigh(a, 1); i++)
        sum += *(int *)svGetArrElemPtr1(a, i);
    return sum;
}

int c_sum2(const svOpenArrayHandle m)
{
    int sum = 0;
    int i, j;
    for (i = svLow(m, 1); i <= svHigh(m, 1); i++)
        for (j = svLow(m, 2); j <= svHigh(m, 2); j++)
            sum += *(int *)svGetArrElemPtr2(m, i, j);
    return sum;
}

void c_span(const svOpenArrayHandle a, int *left, int *right, int *size)
{
    *left = svLeft(a, 1);
    *right = svRight(a, 1);
    *size = svSize(a, 1);
}

#ifdef __cplusplus
}
#endif
