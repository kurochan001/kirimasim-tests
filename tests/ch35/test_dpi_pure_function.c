/* C side of test_dpi_pure_function (IEEE 1800-2023 35.5.2). */
#include <stdio.h>
#include <stdlib.h>
#include "svdpi.h"

#ifdef __cplusplus
extern "C" {
#endif

int dpi_gcd(int a, int b)
{
    while (b != 0) {
        int t = a % b;
        a = b;
        b = t;
    }
    return a;
}

#ifdef __cplusplus
}
#endif
