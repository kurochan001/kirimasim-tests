/* VPI application of test_vpi_lifetime_properties (IEEE 1800-2023 37.3.7,
 * 37.2.2, 37.2.4). */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "sv_vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

#define TOP "test_vpi_lifetime_properties"

static vpiHandle kept_count;

static vpiHandle by_name(const char *name)
{
    char full[96];
    snprintf(full, sizeof full, "%s%s", TOP, name);
    return vpi_handle_by_name((PLI_BYTE8 *)full, NULL);
}

/* The variable called name among the vpiVariables of a task. */
static vpiHandle task_variable(vpiHandle task, const char *name)
{
    vpiHandle it = task ? vpi_iterate(vpiVariables, task) : NULL, h, found = NULL;
    while (it != NULL && (h = vpi_scan(it)) != NULL) {
        PLI_BYTE8 *s = vpi_get_str(vpiName, h);
        if (found == NULL && s != NULL && strcmp(s, name) == 0)
            found = h;
    }
    return found;
}

static void automatic_of(const char *label, vpiHandle h)
{
    if (h == NULL)
        vpi_printf((PLI_BYTE8 *)"%s: not found\n", label);
    else
        vpi_printf((PLI_BYTE8 *)"%s: automatic %d\n", label, (int)vpi_get(vpiAutomatic, h));
}

static int int_value(vpiHandle h)
{
    s_vpi_value v;
    v.format = vpiIntVal;
    vpi_get_value(h, &v);
    return (int)v.value.integer;
}

static PLI_INT32 lifetimes_calltf(PLI_BYTE8 *user_data)
{
    vpiHandle tk = by_name(".tk");

    (void)user_data;
    automatic_of("instance " TOP, by_name(""));
    automatic_of("instance am", by_name(".am"));
    automatic_of("task tk", tk);
    automatic_of("function f_default", by_name(".f_default"));
    automatic_of("task am.t_default", by_name(".am.t_default"));
    automatic_of("task am.t_static", by_name(".am.t_static"));
    automatic_of("variable am.mv", by_name(".am.mv"));
    automatic_of("variable calls", by_name(".calls"));
    automatic_of("variable tk.auto_v", task_variable(tk, "auto_v"));
    automatic_of("variable tk.count", task_variable(tk, "count"));
    return 0;
}

static PLI_INT32 count_changed(p_cb_data data)
{
    vpi_printf((PLI_BYTE8 *)"value change of count: %d\n",
               data->value ? (int)data->value->value.integer : -1);
    return 0;
}

static PLI_INT32 keep_calltf(PLI_BYTE8 *user_data)
{
    s_cb_data cb;
    s_vpi_time t;
    s_vpi_value v;
    vpiHandle registered;

    (void)user_data;
    kept_count = task_variable(by_name(".tk"), "count");
    if (kept_count == NULL) {
        vpi_printf((PLI_BYTE8 *)"in tk: count not found\n");
        return 0;
    }
    memset(&cb, 0, sizeof cb);
    t.type = vpiSuppressTime;
    v.format = vpiIntVal;
    cb.reason = cbValueChange;
    cb.cb_rtn = count_changed;
    cb.obj = kept_count;
    cb.time = &t;
    cb.value = &v;
    registered = vpi_register_cb(&cb);
    vpi_printf((PLI_BYTE8 *)"in tk: count = %d, callback registered %d\n", int_value(kept_count),
               registered != NULL);
    return 0;
}

static PLI_INT32 read_calltf(PLI_BYTE8 *user_data)
{
    (void)user_data;
    if (kept_count == NULL)
        vpi_printf((PLI_BYTE8 *)"no kept handle\n");
    else
        vpi_printf((PLI_BYTE8 *)"after the call: count = %d\n", int_value(kept_count));
    return 0;
}

static void register_task(const char *name, PLI_INT32 (*calltf)(PLI_BYTE8 *))
{
    s_vpi_systf_data d;
    memset(&d, 0, sizeof d);
    d.type = vpiSysTask;
    d.tfname = (PLI_BYTE8 *)name;
    d.calltf = calltf;
    vpi_register_systf(&d);
}

static void register_all(void)
{
    register_task("$vt_lifetimes", lifetimes_calltf);
    register_task("$vt_keep", keep_calltf);
    register_task("$vt_read", read_calltf);
}

void (*vlog_startup_routines[])(void) = {register_all, 0};

#ifdef __cplusplus
}
#endif
