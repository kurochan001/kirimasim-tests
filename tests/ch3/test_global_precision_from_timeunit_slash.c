/* VPI application of test_global_precision_from_timeunit_slash (IEEE 1800-2023 3.14.3, 37.10, 38.6):
   prints the time unit and precision of a NULL object, which are the
   simulation time unit, and those of the top module. */
#include <stdio.h>
#include <string.h>
#include "vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

static PLI_INT32 on_start(p_cb_data data)
{
    vpiHandle top = vpi_handle_by_name((PLI_BYTE8 *)"test_global_precision_from_timeunit_slash", NULL);

    (void)data;
    vpi_printf("NULL: vpiTimeUnit %d, vpiTimePrecision %d\n", (int)vpi_get(vpiTimeUnit, NULL),
               (int)vpi_get(vpiTimePrecision, NULL));
    if (top == NULL)
        vpi_printf("top module: not found\n");
    else
        vpi_printf("top module: vpiTimeUnit %d, vpiTimePrecision %d\n",
                   (int)vpi_get(vpiTimeUnit, top), (int)vpi_get(vpiTimePrecision, top));
    return 0;
}

static void register_all(void)
{
    s_cb_data d;

    memset(&d, 0, sizeof d);
    d.reason = cbStartOfSimulation;
    d.cb_rtn = on_start;
    vpi_register_cb(&d);
}

void (*vlog_startup_routines[])(void) = {register_all, 0};

#ifdef __cplusplus
}
#endif
