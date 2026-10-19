/* C side of test_dpi_export_function (IEEE 1800-2023 35.7). */
#include <stdio.h>
#include <stdlib.h>
#include "svdpi.h"

#ifdef __cplusplus
extern "C" {
#endif

extern int sv_square(int x);

int dpi_sum_of_squares(int n)
{
    int s = 0;
    for (int i = 1; i <= n; i++)
        s += sv_square(i);
    return s;
}

#ifdef __cplusplus
}
#endif
