/* C side of test_dpi_import_function_zero_time_callers (IEEE 1800-2023 35.5.1.1). */
#include <stdio.h>
#include <stdlib.h>
#include "svdpi.h"

#ifdef __cplusplus
extern "C" {
#endif

int c_scale(int v)
{
    return 10 * v;
}

#ifdef __cplusplus
}
#endif
