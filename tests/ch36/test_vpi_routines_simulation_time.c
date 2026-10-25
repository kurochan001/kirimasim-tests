/* VPI application of test_vpi_routines_simulation_time (IEEE 1800-2023 36.11, Table 36-8). */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

#define TOP "test_vpi_routines_simulation_time"

static double scaled(vpiHandle obj)
{
    s_vpi_time t;
    memset(&t, 0, sizeof t);
    t.type = vpiScaledRealTime;
    vpi_get_time(obj, &t);
    return t.real;
}

static PLI_INT32 at_ten(p_cb_data data)
{
    vpiHandle top = vpi_handle_by_name((PLI_BYTE8 *)TOP, NULL);
    vpiHandle sub = vpi_handle_by_name((PLI_BYTE8 *)TOP ".sub", NULL);
    vpiHandle it, tq;
    s_vpi_time t;

    (void)data;
    memset(&t, 0, sizeof t);
    t.type = vpiSimTime;
    vpi_get_time(NULL, &t);
    vpi_printf("at read-only synch of 10: vpiSimTime %u\n", (unsigned)t.low);
    vpi_printf("vpiScaledRealTime of the top module %.1f, of sub %.1f\n",
               top ? scaled(top) : -1.0, sub ? scaled(sub) : -1.0);
    vpi_printf("time queue:");
    it = vpi_iterate(vpiTimeQueue, NULL);
    if (it == NULL)
        vpi_printf(" NULL");
    while (it != NULL && (tq = vpi_scan(it)) != NULL) {
        memset(&t, 0, sizeof t);
        t.type = vpiSimTime;
        vpi_get_time(tq, &t);
        vpi_printf(" %u", (unsigned)t.low);
    }
    vpi_printf("\n");
    return 0;
}

static PLI_INT32 on_start(p_cb_data data)
{
    static s_vpi_time ten;
    s_cb_data d;

    (void)data;
    ten.type = vpiSimTime;
    ten.high = 0;
    ten.low = 10;
    memset(&d, 0, sizeof d);
    d.reason = cbReadOnlySynch;
    d.cb_rtn = at_ten;
    d.time = &ten;
    vpi_register_cb(&d);
    return 0;
}

static void register_start(void)
{
    s_cb_data d;
    memset(&d, 0, sizeof d);
    d.reason = cbStartOfSimulation;
    d.cb_rtn = on_start;
    vpi_register_cb(&d);
}

void (*vlog_startup_routines[])(void) = {register_start, 0};

#ifdef __cplusplus
}
#endif
