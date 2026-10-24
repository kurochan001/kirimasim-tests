/* C side of test_dpi_import_task_consumes_time (IEEE 1800-2023 35.2.1). */
#include <stdio.h>
#include <stdlib.h>
#include "svdpi.h"

#ifdef __cplusplus
extern "C" {
#endif

extern int sv_square(int v);
extern int sv_wait(int d);

int dpi_add(int a, int b)
{
    return a + b;
}

int dpi_square_via_sv(int v)
{
    return sv_square(v);
}

/* An imported task returns 0, or 1 when a disable is in effect (35.9). */
int dpi_wait_steps(int n, int *done)
{
    int i;

    for (i = 0; i < n; i++)
        if (sv_wait(4) != 0)
            return 1;
    *done = n;
    return 0;
}

#ifdef __cplusplus
}
#endif
