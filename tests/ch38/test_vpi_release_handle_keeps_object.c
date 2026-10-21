/* VPI application of test_vpi_release_handle_keeps_object (IEEE 1800-2023 38.38). */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

static PLI_INT32 on_change(p_cb_data data)
{
    vpi_printf("r changed to %d at %d\n", data->value ? (int)data->value->value.integer : -1,
               data->time ? (int)data->time->low : -1);
    return 0;
}

static vpiHandle find_r(void)
{
    return vpi_handle_by_name((PLI_BYTE8 *)"test_vpi_release_handle_keeps_object.r", NULL);
}

static PLI_INT32 on_start(p_cb_data data)
{
    static s_vpi_time time_kind;
    static s_vpi_value value_kind;
    vpiHandle r = find_r(), cb;
    s_cb_data d;
    s_vpi_value v;

    (void)data;
    if (r == NULL) {
        vpi_printf("r not found\n");
        return 0;
    }
    time_kind.type = vpiSimTime;
    value_kind.format = vpiIntVal;
    memset(&d, 0, sizeof d);
    d.reason = cbValueChange;
    d.cb_rtn = on_change;
    d.obj = r;
    d.time = &time_kind;
    d.value = &value_kind;
    cb = vpi_register_cb(&d);
    if (cb == NULL) {
        vpi_printf("callback not placed\n");
        return 0;
    }
    vpi_printf("vpi_release_handle of the callback handle: %d\n", (int)vpi_release_handle(cb));
    vpi_printf("vpi_release_handle of the handle to r: %d\n", (int)vpi_release_handle(r));
    r = find_r();
    if (r == NULL) {
        vpi_printf("r not found again\n");
        return 0;
    }
    v.format = vpiIntVal;
    vpi_get_value(r, &v);
    vpi_printf("r found again: vpiSize %d, value %d\n", (int)vpi_get(vpiSize, r),
               (int)v.value.integer);
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
