/* VPI application of test_vpi_stmt_callback_instance (IEEE 1800-2023 38.36.1.3). */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

static int blocks, delays, assignments, no_obj;
static char unit_data[] = "u1";

static PLI_INT32 on_stmt(p_cb_data data)
{
    PLI_INT32 t;

    if (data->obj == NULL) {
        no_obj++;
        return 0;
    }
    t = vpi_get(vpiType, data->obj);
    if (t == vpiBegin)
        blocks++;
    else if (t == vpiDelayControl)
        delays++;
    else if (t == vpiAssignment)
        assignments++;
    return 0;
}

static PLI_INT32 on_start(p_cb_data data)
{
    static s_vpi_time no_time;
    vpiHandle u1 = vpi_handle_by_name((PLI_BYTE8 *)"test_vpi_stmt_callback_instance.u1", NULL);
    s_cb_data d;

    (void)data;
    no_time.type = vpiSuppressTime;
    memset(&d, 0, sizeof d);
    d.reason = cbStmt;
    d.cb_rtn = on_stmt;
    d.obj = u1;
    d.time = &no_time;
    d.user_data = unit_data;
    vpi_printf("callback on u1: %s\n", u1 != NULL && vpi_register_cb(&d) != NULL
               ? "placed" : "not placed");
    return 0;
}

static PLI_INT32 on_end(p_cb_data data)
{
    (void)data;
    vpi_printf("u1 callbacks: begin %d, delay control %d, assignment %d, without obj %d\n",
               blocks, delays, assignments, no_obj);
    return 0;
}

static void register_all(void)
{
    s_cb_data d;
    memset(&d, 0, sizeof d);
    d.reason = cbStartOfSimulation;
    d.cb_rtn = on_start;
    vpi_register_cb(&d);
    d.reason = cbEndOfSimulation;
    d.cb_rtn = on_end;
    vpi_register_cb(&d);
}

void (*vlog_startup_routines[])(void) = {register_all, 0};

#ifdef __cplusplus
}
#endif
