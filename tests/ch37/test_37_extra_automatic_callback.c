/* VPI application of test_37_extra_automatic_callback (IEEE 1800-2023 37.43). */
#include <stdio.h>
#include <string.h>
#include "sv_vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

#define TOP "test_37_extra_automatic_callback"
#define MAX 4

static int automatic_changes;
static int static_changes;
static int static_value;

/* The variables of a scope whose name is name, or NULL. */
static vpiHandle variable_of(vpiHandle scope, const char *name)
{
    vpiHandle variables = vpi_iterate(vpiVariables, scope);
    vpiHandle variable;

    while (variables != NULL && (variable = vpi_scan(variables)) != NULL)
        if (strcmp(vpi_get_str(vpiName, variable), name) == 0)
            return variable;
    return NULL;
}

static PLI_INT32 changed(p_cb_data cb)
{
    vpiHandle obj = cb->obj;

    if (strcmp(vpi_get_str(vpiName, obj), "auto_v") == 0)
        automatic_changes++;
    else {
        static_changes++;
        if (cb->value != NULL)
            static_value = (int)cb->value->value.integer;
    }
    return 0;
}

/* Register cbValueChange on obj, whose value is read as an int, and return
   the callback handle that vpi_register_cb returns. */
static vpiHandle watch(vpiHandle obj)
{
    static s_vpi_value values[MAX];
    static s_vpi_time times[MAX];
    static int used;
    s_cb_data cb;

    if (obj == NULL || used == MAX)
        return NULL;
    memset(&cb, 0, sizeof cb);
    cb.reason = cbValueChange;
    cb.cb_rtn = changed;
    cb.obj = obj;
    times[used].type = vpiSuppressTime;
    cb.time = &times[used];
    values[used].format = vpiIntVal;
    cb.value = &values[used];
    used++;
    return vpi_register_cb(&cb);
}

static int automatic_is_automatic;
static int automatic_null;
static int static_null;

static PLI_INT32 watch_calltf(PLI_BYTE8 *user_data)
{
    vpiHandle task, automatic_var, static_var;

    (void)user_data;
    task = vpi_handle_by_name((PLI_BYTE8 *)TOP ".bump", NULL);
    automatic_var = task != NULL ? variable_of(task, "auto_v") : NULL;
    static_var = vpi_handle_by_name((PLI_BYTE8 *)TOP ".stat", NULL);
    if (automatic_var != NULL)
        automatic_is_automatic = (int)vpi_get(vpiAutomatic, automatic_var);
    automatic_null = watch(automatic_var) == NULL;
    static_null = watch(static_var) == NULL;
    return 0;
}

static PLI_INT32 report_calltf(PLI_BYTE8 *user_data)
{
    (void)user_data;
    vpi_printf((PLI_BYTE8 *)"automatic variable is automatic: %d\n",
               automatic_is_automatic);
    vpi_printf((PLI_BYTE8 *)"callback handle on the automatic variable is NULL: %d\n",
               automatic_null);
    vpi_printf((PLI_BYTE8 *)"callback handle on the static variable is NULL: %d\n",
               static_null);
    vpi_printf((PLI_BYTE8 *)"callbacks for the automatic variable: %d\n",
               automatic_changes);
    vpi_printf((PLI_BYTE8 *)"callbacks for the static variable: %d, value %d\n",
               static_changes, static_value);
    return 0;
}

static void register_all(void)
{
    s_vpi_systf_data d;

    memset(&d, 0, sizeof d);
    d.type = vpiSysTask;
    d.calltf = watch_calltf;
    d.tfname = (PLI_BYTE8 *)"$vt_watch";
    vpi_register_systf(&d);

    memset(&d, 0, sizeof d);
    d.type = vpiSysTask;
    d.calltf = report_calltf;
    d.tfname = (PLI_BYTE8 *)"$vt_report";
    vpi_register_systf(&d);
}

void (*vlog_startup_routines[])(void) = {register_all, 0};

#ifdef __cplusplus
}
#endif
