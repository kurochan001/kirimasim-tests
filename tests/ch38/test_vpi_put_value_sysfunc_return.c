/* VPI application of test_vpi_put_value_sysfunc_return (IEEE 1800-2023 38.34). */
#include <string.h>
#include "vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

static vpiHandle kept_call;

static PLI_INT32 value_calltf(PLI_BYTE8 *user_data)
{
    vpiHandle call = vpi_handle(vpiSysTfCall, NULL);
    vpiHandle it = vpi_iterate(vpiArgument, call);
    s_vpi_value v;

    (void)user_data;
    v.format = vpiIntVal;
    vpi_get_value(vpi_scan(it), &v);
    vpi_release_handle(it);
    vpi_put_value(call, &v, NULL, vpiNoDelay);
    return 0;
}

static PLI_INT32 put_outside(p_cb_data cb)
{
    s_vpi_value v;

    (void)cb;
    v.format = vpiIntVal;
    v.value.integer = 55;
    if (kept_call != NULL)
        vpi_put_value(kept_call, &v, NULL, vpiNoDelay);
    return 0;
}

static PLI_INT32 nothing_calltf(PLI_BYTE8 *user_data)
{
    static s_vpi_time two;
    s_cb_data cb;

    (void)user_data;
    if (kept_call != NULL)
        return 0;
    kept_call = vpi_handle(vpiSysTfCall, NULL);
    two.type = vpiSimTime;
    two.high = 0;
    two.low = 2;
    memset(&cb, 0, sizeof cb);
    cb.reason = cbAfterDelay;
    cb.cb_rtn = put_outside;
    cb.time = &two;
    vpi_register_cb(&cb);
    return 0;
}

static void add(const char *name, PLI_INT32 (*calltf)(PLI_BYTE8 *))
{
    s_vpi_systf_data d;
    memset(&d, 0, sizeof d);
    d.type = vpiSysFunc;
    d.sysfunctype = vpiIntFunc;
    d.tfname = (PLI_BYTE8 *)name;
    d.calltf = calltf;
    vpi_register_systf(&d);
}

static void register_all(void)
{
    add("$vt_value", value_calltf);
    add("$vt_nothing", nothing_calltf);
}

void (*vlog_startup_routines[])(void) = {register_all, 0};

#ifdef __cplusplus
}
#endif
