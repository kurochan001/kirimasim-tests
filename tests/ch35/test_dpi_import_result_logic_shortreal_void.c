/* C side of test_dpi_import_result_logic_shortreal_void (IEEE 1800-2023 35.5.5). */
#include <stdio.h>
#include <stdlib.h>
#include "svdpi.h"

#ifdef __cplusplus
extern "C" {
#endif

static int kept;

svLogic dpi_logic_of(int code)
{
    switch (code) {
    case 0: return sv_0;
    case 1: return sv_1;
    case 2: return sv_z;
    default: return sv_x;
    }
}

float dpi_quarter(int n)
{
    return (float)n / 4.0f;
}

void dpi_store(int v)
{
    kept = v;
}

int dpi_load(void)
{
    return kept;
}

#ifdef __cplusplus
}
#endif
