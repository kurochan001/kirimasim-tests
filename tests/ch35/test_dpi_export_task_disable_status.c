/* C side of test_dpi_export_task_disable_status (IEEE 1800-2023 35.9). */
#include <stdio.h>
#include <stdlib.h>
#include "svdpi.h"

#ifdef __cplusplus
extern "C" {
#endif

extern int sv_stop_worker(void);
extern int sv_self(void);

static int a_returned = -1, a_state = -1, b_returned = -1, b_state = -1;

int dpi_run_a(void)
{
    a_returned = sv_stop_worker();
    a_state = svIsDisabledState();
    /* A disabled imported task acknowledges the disable by returning 1. */
    return a_state ? 1 : 0;
}

int dpi_run_b(void)
{
    b_returned = sv_self();
    b_state = svIsDisabledState();
    return b_state ? 1 : 0;
}

void dpi_report(int *ar, int *as, int *br, int *bs)
{
    *ar = a_returned;
    *as = a_state;
    *br = b_returned;
    *bs = b_state;
}

#ifdef __cplusplus
}
#endif
