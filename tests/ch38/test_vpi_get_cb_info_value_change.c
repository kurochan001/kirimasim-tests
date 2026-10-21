/* VPI application of test_vpi_get_cb_info_value_change (IEEE 1800-2023 38.8). */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

static char r_data[] = "on r";
static char w_data[] = "on w";

static PLI_INT32 on_change(p_cb_data data)
{
    (void)data;
    return 0;
}

static vpiHandle place(vpiHandle obj, char *user_data)
{
    static s_vpi_time time_kind;
    static s_vpi_value value_kind;
    s_cb_data d;

    memset(&d, 0, sizeof d);
    time_kind.type = vpiSimTime;
    value_kind.format = vpiIntVal;
    d.reason = cbValueChange;
    d.cb_rtn = on_change;
    d.obj = obj;
    d.time = &time_kind;
    d.value = &value_kind;
    d.user_data = user_data;
    return vpi_register_cb(&d);
}

static void show(const char *label, vpiHandle cb, vpiHandle r, vpiHandle w)
{
    s_cb_data info;
    s_vpi_time info_time;
    s_vpi_value info_value;

    if (cb == NULL) {
        vpi_printf("%s: not registered\n", label);
        return;
    }
    memset(&info, 0, sizeof info);
    memset(&info_time, 0, sizeof info_time);
    memset(&info_value, 0, sizeof info_value);
    /* the tool may fill these or point the fields at its own storage */
    info.time = &info_time;
    info.value = &info_value;
    vpi_get_cb_info(cb, &info);
    vpi_printf("%s: reason %s, routine %s, object %s, user data \"%s\"\n", label,
               info.reason == cbValueChange ? "cbValueChange" : "other",
               info.cb_rtn == on_change ? "on_change" : "other",
               info.obj == NULL ? "NULL"
               : vpi_compare_objects(info.obj, r) ? "r"
               : vpi_compare_objects(info.obj, w) ? "w" : "other",
               info.user_data ? info.user_data : "");
}

static PLI_INT32 on_start(p_cb_data data)
{
    vpiHandle r = vpi_handle_by_name((PLI_BYTE8 *)"test_vpi_get_cb_info_value_change.r", NULL);
    vpiHandle w = vpi_handle_by_name((PLI_BYTE8 *)"test_vpi_get_cb_info_value_change.w", NULL);
    vpiHandle cb_r, cb_w;

    (void)data;
    if (r == NULL || w == NULL) {
        vpi_printf("objects not found\n");
        return 0;
    }
    cb_r = place(r, r_data);
    cb_w = place(w, w_data);
    show("callback on r", cb_r, r, w);
    show("callback on w", cb_w, r, w);
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
