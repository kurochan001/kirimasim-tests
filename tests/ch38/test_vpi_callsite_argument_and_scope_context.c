/* H.9.1 B005 and 37.42: current call, actual arguments and surrounding scope. */
#include <stdio.h>
#include <string.h>
#include "vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

static void name_of(vpiHandle object, char *buffer, size_t size)
{
    const char *name = object != NULL ? vpi_get_str(vpiFullName, object) : NULL;
    snprintf(buffer, size, "%s", name != NULL ? name : "missing");
}

static int value_of(vpiHandle object)
{
    s_vpi_value value;
    if (object == NULL) return -999;
    value.format = vpiIntVal;
    vpi_get_value(object, &value);
    return (int)value.value.integer;
}

static PLI_INT32 probe_calltf(PLI_BYTE8 *user_data)
{
    vpiHandle call = vpi_handle(vpiSysTfCall, NULL);
    vpiHandle scope = call != NULL ? vpi_handle(vpiScope, call) : NULL;
    vpiHandle iterator = call != NULL ? vpi_iterate(vpiArgument, call) : NULL;
    vpiHandle arg = iterator != NULL ? vpi_scan(iterator) : NULL;
    vpiHandle local = scope != NULL
        ? vpi_handle_by_name((PLI_BYTE8 *)"local_value", scope) : NULL;
    char scope_name[160], arg_name[176], local_name[192];
    (void)user_data;
    name_of(scope, scope_name, sizeof scope_name);
    name_of(arg, arg_name, sizeof arg_name);
    name_of(local, local_name, sizeof local_name);
    vpi_printf((PLI_BYTE8 *)"scope=%s argument=%s value=%d surrounding=%s value=%d\n",
               scope_name, arg_name, value_of(arg), local_name, value_of(local));
    if (iterator != NULL) vpi_free_object(iterator);
    return 0;
}

static void register_probe(void)
{
    s_vpi_systf_data tf;
    memset(&tf, 0, sizeof tf);
    tf.type = vpiSysTask;
    tf.tfname = (PLI_BYTE8 *)"$vt_callsite_context";
    tf.calltf = probe_calltf;
    vpi_register_systf(&tf);
}

void (*vlog_startup_routines[])(void) = {register_probe, 0};

#ifdef __cplusplus
}
#endif
