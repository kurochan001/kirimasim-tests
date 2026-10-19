/* C side of test_dpi_export_task_time (IEEE 1800-2023 35.8). */
#include <stdio.h>
#include <stdlib.h>
#include "svdpi.h"

#ifdef __cplusplus
extern "C" {
#endif

extern int sv_step(int i, int d);

int dpi_run_steps(int n, int step)
{
    for (int i = 1; i <= n; i++)
        if (sv_step(i, step) != 0)
            return 1;
    return 0;
}

#ifdef __cplusplus
}
#endif
