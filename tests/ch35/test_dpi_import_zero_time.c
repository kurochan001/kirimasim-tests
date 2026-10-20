/* C side of test_dpi_import_zero_time (IEEE 1800-2023 35.5.1.1). */
#include <stdio.h>
#include <stdlib.h>
#include "svdpi.h"

#ifdef __cplusplus
extern "C" {
#endif

int c_sum(int n)
{
    int s = 0;
    for (int i = 1; i <= n; i++)
        s += i;
    return s;
}

int c_double(int v)
{
    return 2 * v;
}

#ifdef __cplusplus
}
#endif
