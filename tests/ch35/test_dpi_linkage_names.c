/* C side of test_dpi_linkage_names (IEEE 1800-2023 35.4). */
#include <stdio.h>
#include <stdlib.h>
#include "svdpi.h"

#ifdef __cplusplus
extern "C" {
#endif

int dpi_scale(int x, int k) { return x * k; }

/* "begin" is a keyword of SystemVerilog, not of C. */
int begin(int x) { return x + 100; }

#ifdef __cplusplus
}
#endif
