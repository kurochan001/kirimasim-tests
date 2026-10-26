/* VPI application of test_vpi_systf_phases_and_object_identity (IEEE 1800-2023 36.2, 36.6, 36.8, 36.10). */
#include <stdio.h>
#include <string.h>
#include "vpi_user.h"
#include "sv_vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

#define TOP "test_vpi_systf_phases_and_object_identity"

static int built, compile_before, compile_after, value_calls;

static vpiHandle by_name(const char *name)
{
    char full[160];
    snprintf(full, sizeof full, "%s.%s", TOP, name);
    return vpi_handle_by_name((PLI_BYTE8 *)full, NULL);
}

static PLI_INT32 value_compiletf(PLI_BYTE8 *user_data)
{
    (void)user_data;
    if (built)
        compile_after++;
    else
        compile_before++;
    return 0;
}

static PLI_INT32 value_calltf(PLI_BYTE8 *user_data)
{
    vpiHandle call = vpi_handle(vpiSysTfCall, NULL);
    s_vpi_value value;

    (void)user_data;
    value_calls++;
    vpi_printf((PLI_BYTE8 *)"value calltf\n");
    value.format = vpiIntVal;
    value.value.integer = 31;
    vpi_put_value(call, &value, NULL, vpiNoDelay);
    return 0;
}

static vpiHandle first_port(const char *instance)
{
    vpiHandle inst = by_name(instance);
    vpiHandle it = inst ? vpi_iterate(vpiPort, inst) : NULL;
    vpiHandle port = it ? vpi_scan(it) : NULL;

    if (it != NULL)
        vpi_free_object(it);
    return port;
}

static int integer_of(vpiHandle h)
{
    s_vpi_value value;

    value.format = vpiIntVal;
    vpi_get_value(h, &value);
    return (int)value.value.integer;
}

static PLI_INT32 report_calltf(PLI_BYTE8 *user_data)
{
    vpiHandle w1 = by_name("u1.w");
    vpiHandle w2 = by_name("u2.w");
    vpiHandle out = first_port("s");
    vpiHandle in = first_port("d");
    vpiHandle path = (out != NULL && in != NULL)
                     ? vpi_handle_multi(vpiInterModPath, out, in) : NULL;

    (void)user_data;
    vpi_printf((PLI_BYTE8 *)"value calltf count: %d\n", value_calls);
    vpi_printf((PLI_BYTE8 *)"compiletf before end of compile: %d, after: %d\n",
               compile_before, compile_after);
    vpi_printf((PLI_BYTE8 *)"u1.w and u2.w distinct: %d\n",
               w1 != NULL && w2 != NULL && !vpi_compare_objects(w1, w2));
    vpi_printf((PLI_BYTE8 *)"values read through VPI: %d %d\n",
               integer_of(w1), integer_of(w2));
    vpi_printf((PLI_BYTE8 *)"intermodule path is a simulation object: %d\n",
               path != NULL && vpi_get(vpiType, path) == vpiInterModPath);
    return 0;
}

static PLI_INT32 on_end_of_compile(p_cb_data cb)
{
    (void)cb;
    built = 1;
    return 0;
}

static void register_all(void)
{
    s_vpi_systf_data d;
    s_cb_data cb;

    memset(&d, 0, sizeof d);
    d.type = vpiSysFunc;
    d.sysfunctype = vpiIntFunc;
    d.tfname = (PLI_BYTE8 *)"$vt_value";
    d.calltf = value_calltf;
    d.compiletf = value_compiletf;
    vpi_register_systf(&d);

    memset(&d, 0, sizeof d);
    d.type = vpiSysTask;
    d.tfname = (PLI_BYTE8 *)"$vt_report";
    d.calltf = report_calltf;
    vpi_register_systf(&d);

    memset(&cb, 0, sizeof cb);
    cb.reason = cbEndOfCompile;
    cb.cb_rtn = on_end_of_compile;
    vpi_register_cb(&cb);
}

void (*vlog_startup_routines[])(void) = {register_all, 0};

#ifdef __cplusplus
}
#endif
