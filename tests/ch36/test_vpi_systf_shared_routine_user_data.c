/* VPI application of test_vpi_systf_shared_routine_user_data (IEEE 1800-2023 36.8.4). */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

struct adder {
    int step;
    int compiled;
};

static struct adder plus_one = {1, 0}, plus_ten = {10, 0};

static PLI_INT32 add_compiletf(PLI_BYTE8 *user_data)
{
    ((struct adder *)user_data)->compiled++;
    return 0;
}

static PLI_INT32 add_calltf(PLI_BYTE8 *user_data)
{
    vpiHandle call = vpi_handle(vpiSysTfCall, NULL);
    vpiHandle it = vpi_iterate(vpiArgument, call);
    vpiHandle arg = it ? vpi_scan(it) : NULL;
    s_vpi_value v;

    if (arg == NULL)
        return 0;
    vpi_free_object(it);
    v.format = vpiIntVal;
    vpi_get_value(arg, &v);
    v.value.integer += ((struct adder *)user_data)->step;
    vpi_put_value(call, &v, NULL, vpiNoDelay);
    return 0;
}

static PLI_INT32 report_calltf(PLI_BYTE8 *user_data)
{
    (void)user_data;
    vpi_printf("compiletf calls: $vt_plus_one %d, $vt_plus_ten %d\n",
               plus_one.compiled, plus_ten.compiled);
    return 0;
}

static void add_function(const char *name, struct adder *data)
{
    s_vpi_systf_data d;
    memset(&d, 0, sizeof d);
    d.type = vpiSysFunc;
    d.sysfunctype = vpiIntFunc;
    d.tfname = (PLI_BYTE8 *)name;
    d.compiletf = add_compiletf;
    d.calltf = add_calltf;
    d.user_data = (PLI_BYTE8 *)data;
    vpi_register_systf(&d);
}

static void register_all(void)
{
    s_vpi_systf_data d;

    add_function("$vt_plus_one", &plus_one);
    add_function("$vt_plus_ten", &plus_ten);
    memset(&d, 0, sizeof d);
    d.type = vpiSysTask;
    d.tfname = (PLI_BYTE8 *)"$vt_report";
    d.calltf = report_calltf;
    vpi_register_systf(&d);
}

void (*vlog_startup_routines[])(void) = {register_all, 0};

#ifdef __cplusplus
}
#endif
