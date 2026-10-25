/* C side of test_dpi_import_unnamed_formal_arguments
   (IEEE 1800-2023 35.5.4, A.10 footnote 28). */
#include <stdio.h>
#include <stdlib.h>
#include "svdpi.h"

#ifdef __cplusplus
extern "C" {
#endif

int dpi_n_mix(int a, char b, short c)
{
    return a * 10000 + b * 100 + c;
}

void dpi_n_split(int v, int *quot, int *rem)
{
    *quot = v / 10;
    *rem = v % 10;
}

void dpi_n_step(int *acc, int by)
{
    *acc += by;
}

int dpi_n_task(int in, int *out, int *io)
{
    *out = 3 * in;
    *io = 2 * *io;
    return 0;
}

#ifdef __cplusplus
}
#endif
