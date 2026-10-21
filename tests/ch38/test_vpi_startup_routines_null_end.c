/* VPI application of test_vpi_startup_routines_null_end (IEEE 1800-2023 38.37.2). */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

static int first_calls, second_calls, third_calls;

static PLI_INT32 report(p_cb_data data)
{
    vpi_printf("%s: first routine %d call(s), second %d, after the NULL entry %d\n",
               data->reason == cbStartOfSimulation ? "start of simulation" : "end of simulation",
               first_calls, second_calls, third_calls);
    return 0;
}

static void on(PLI_INT32 reason)
{
    s_cb_data d;
    memset(&d, 0, sizeof d);
    d.reason = reason;
    d.cb_rtn = report;
    vpi_register_cb(&d);
}

static void first_routine(void)
{
    first_calls++;
    on(cbStartOfSimulation);
}

static void second_routine(void)
{
    second_calls++;
    on(cbEndOfSimulation);
}

static void third_routine(void)
{
    third_calls++;
    vpi_printf("the routine after the NULL entry is called\n");
}

void (*vlog_startup_routines[])(void) = {first_routine, second_routine, 0, third_routine, 0};

#ifdef __cplusplus
}
#endif
