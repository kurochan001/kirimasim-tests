/* VPI application of test_vpi_sys_func_call_value_info (IEEE 1800-2023 37.42). */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "vpi_user.h"
#include "sv_vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

static const char *func_type(PLI_INT32 t)
{
    switch (t) {
    case vpiIntFunc: return "vpiIntFunc";
    case vpiRealFunc: return "vpiRealFunc";
    case vpiTimeFunc: return "vpiTimeFunc";
    case vpiSizedFunc: return "vpiSizedFunc";
    case vpiSizedSignedFunc: return "vpiSizedSignedFunc";
    default: return "other";
    }
}

static int first_argument(vpiHandle call)
{
    vpiHandle it = vpi_iterate(vpiArgument, call), a;
    s_vpi_value v;

    a = it != NULL ? vpi_scan(it) : NULL;
    if (a == NULL)
        return -1;
    vpi_free_object(it);
    v.format = vpiIntVal;
    vpi_get_value(a, &v);
    return (int)v.value.integer;
}

/* The registration of a user-defined call, through vpiUserSystf. */
static void systf_info(vpiHandle call, char *out, size_t len)
{
    vpiHandle systf = vpi_handle(vpiUserSystf, call);
    s_vpi_systf_data d;

    if (systf == NULL) {
        snprintf(out, len, "no systf object");
        return;
    }
    memset(&d, 0, sizeof d);
    vpi_get_systf_info(systf, &d);
    snprintf(out, len, "systf info %s, %s, %s", d.tfname != NULL ? d.tfname : "(none)",
             d.type == vpiSysFunc ? "vpiSysFunc" : d.type == vpiSysTask ? "vpiSysTask" : "other",
             func_type(d.sysfunctype));
}

static PLI_INT32 val_calltf(PLI_BYTE8 *user_data)
{
    vpiHandle call = vpi_handle(vpiSysTfCall, NULL);
    char info[96], name[32];
    s_vpi_value v;
    int arg;

    (void)user_data;
    if (call == NULL) {
        vpi_printf((PLI_BYTE8 *)"$vt_val: no call\n");
        return 0;
    }
    arg = first_argument(call);
    snprintf(name, sizeof name, "%s", vpi_get_str(vpiName, call) != NULL
             ? vpi_get_str(vpiName, call) : "(none)");
    systf_info(call, info, sizeof info);
    vpi_printf((PLI_BYTE8 *)"invoking call: %s, system function call %d, argument %d, "
                            "user-defined %d, type %s, %s\n", name,
               vpi_get(vpiType, call) == vpiSysFuncCall, arg, (int)vpi_get(vpiUserDefn, call),
               func_type(vpi_get(vpiFuncType, call)), info);
    v.format = vpiIntVal;
    v.value.integer = 10 * arg;
    vpi_put_value(call, &v, NULL, vpiNoDelay);
    v.format = vpiIntVal;
    v.value.integer = -1;
    vpi_get_value(call, &v);
    vpi_printf((PLI_BYTE8 *)"value of the call after vpi_put_value: %d\n", (int)v.value.integer);
    return 0;
}

static PLI_INT32 val_sizetf(PLI_BYTE8 *user_data)
{
    (void)user_data;
    return 32;
}

static void describe(vpiHandle a, int position)
{
    char name[32] = "", info[96] = "";

    switch (vpi_get(vpiType, a)) {
    case vpiSysFuncCall:
        snprintf(name, sizeof name, "%s", vpi_get_str(vpiName, a) != NULL
                 ? vpi_get_str(vpiName, a) : "(none)");
        if (vpi_get(vpiUserDefn, a))
            systf_info(a, info, sizeof info);
        vpi_printf((PLI_BYTE8 *)"argument %d: system function call %s, user-defined %d, "
                                "type %s%s%s\n", position, name, (int)vpi_get(vpiUserDefn, a),
                   func_type(vpi_get(vpiFuncType, a)), info[0] ? ", " : "", info);
        break;
    case vpiOperation:
        vpi_printf((PLI_BYTE8 *)"argument %d: operation, null operation %d\n", position,
                   vpi_get(vpiOpType, a) == vpiNullOp);
        break;
    case vpiConstant:
        vpi_printf((PLI_BYTE8 *)"argument %d: constant, %s\n", position,
                   vpi_get(vpiConstType, a) == vpiNullConst ? "vpiNullConst"
                   : vpi_get(vpiConstType, a) == vpiStringConst ? "vpiStringConst"
                   : "other constant type");
        break;
    default:
        vpi_printf((PLI_BYTE8 *)"argument %d: other object\n", position);
        break;
    }
}

static PLI_INT32 args_calltf(PLI_BYTE8 *user_data)
{
    vpiHandle call = vpi_handle(vpiSysTfCall, NULL), it, a;
    int n = 0;

    (void)user_data;
    vpi_printf((PLI_BYTE8 *)"invoking call: %s, system task call %d\n",
               call != NULL && vpi_get_str(vpiName, call) != NULL ? vpi_get_str(vpiName, call)
               : "(none)", call != NULL && vpi_get(vpiType, call) == vpiSysTaskCall);
    it = call != NULL ? vpi_iterate(vpiArgument, call) : NULL;
    while (it != NULL && (a = vpi_scan(it)) != NULL)
        describe(a, ++n);
    return 0;
}

static void register_all(void)
{
    s_vpi_systf_data d;

    memset(&d, 0, sizeof d);
    d.type = vpiSysFunc;
    d.sysfunctype = vpiIntFunc;
    d.tfname = (PLI_BYTE8 *)"$vt_val";
    d.calltf = val_calltf;
    d.sizetf = val_sizetf;
    vpi_register_systf(&d);

    memset(&d, 0, sizeof d);
    d.type = vpiSysTask;
    d.tfname = (PLI_BYTE8 *)"$vt_args";
    d.calltf = args_calltf;
    vpi_register_systf(&d);
}

void (*vlog_startup_routines[])(void) = {register_all, 0};

#ifdef __cplusplus
}
#endif
