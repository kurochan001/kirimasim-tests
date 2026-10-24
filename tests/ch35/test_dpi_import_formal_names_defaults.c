/* C side of test_dpi_import_formal_names_defaults (IEEE 1800-2023 35.5.4). */
#include <stdio.h>
#include <stdlib.h>
#include "svdpi.h"

#ifdef __cplusplus
extern "C" {
#endif

int dpi_mix(int a, int b)
{
    return a * 100 + b;
}

#ifdef __cplusplus
}
#endif
