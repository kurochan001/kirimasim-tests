/* C side of test_dpi_one_function_two_imports (IEEE 1800-2023 35.2.1). */
#include <stdio.h>
#include <stdlib.h>
#include "svdpi.h"

#ifdef __cplusplus
extern "C" {
#endif

static int kept;

int c_offset(int a, int b)
{
    return a + b;
}

int c_keep(int v)
{
    kept = v;
    return 0;
}

int c_kept(void)
{
    return kept;
}

#ifdef __cplusplus
}
#endif
