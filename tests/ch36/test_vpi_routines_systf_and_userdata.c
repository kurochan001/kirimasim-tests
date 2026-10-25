/* VPI application of test_vpi_routines_systf_and_userdata (IEEE 1800-2023 36.11). */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

static vpiHandle sum_systf, count_systf;
static PLI_BYTE8 sum_data[] = "sum data";
static PLI_BYTE8 count_data[] = "count data";

static PLI_INT32 no_check(PLI_BYTE8 *user_data)
{
    (void)user_data;
    return 0;
}

static PLI_INT32 sum_calltf(PLI_BYTE8 *user_data)
{
    vpiHandle call = vpi_handle(vpiSysTfCall, NULL);
    vpiHandle args = vpi_iterate(vpiArgument, call), arg;
    s_vpi_value v;
    PLI_INT32 total = 0;

    (void)user_data;
    while (args != NULL && (arg = vpi_scan(args)) != NULL) {
        v.format = vpiIntVal;
        vpi_get_value(arg, &v);
        total += v.value.integer;
    }
    v.format = vpiIntVal;
    v.value.integer = total;
    vpi_put_value(call, &v, NULL, vpiNoDelay);
    return 0;
}

static PLI_INT32 count_calltf(PLI_BYTE8 *user_data)
{
    vpiHandle call = vpi_handle(vpiSysTfCall, NULL);
    int *counter = (int *)vpi_get_userdata(call);

    (void)user_data;
    if (counter == NULL) {
        PLI_INT32 put;
        counter = (int *)calloc(1, sizeof *counter);
        put = vpi_put_userdata(call, counter);
        *counter += 1;
        vpi_printf("$vt_count: user data before NULL 1, vpi_put_userdata returned %d, "
                   "count %d\n", put, *counter);
    } else {
        *counter += 1;
        vpi_printf("$vt_count: user data before NULL 0, count %d\n", *counter);
    }
    return 0;
}

static PLI_INT32 info_calltf(PLI_BYTE8 *user_data)
{
    s_vpi_systf_data d;

    (void)user_data;
    memset(&d, 0, sizeof d);
    if (sum_systf != NULL)
        vpi_get_systf_info(sum_systf, &d);
    vpi_printf("$vt_sum: type vpiSysFunc %d, sysfunctype vpiIntFunc %d, tfname %s, calltf %d, "
               "compiletf %d, user data %s\n", d.type == vpiSysFunc,
               d.sysfunctype == vpiIntFunc, d.tfname ? (const char *)d.tfname : "(none)",
               d.calltf == sum_calltf, d.compiletf == no_check,
               d.user_data ? (const char *)d.user_data : "(none)");
    memset(&d, 0, sizeof d);
    if (count_systf != NULL)
        vpi_get_systf_info(count_systf, &d);
    vpi_printf("$vt_count: type vpiSysTask %d, tfname %s, calltf %d, compiletf %d, "
               "user data %s\n", d.type == vpiSysTask,
               d.tfname ? (const char *)d.tfname : "(none)", d.calltf == count_calltf,
               d.compiletf == no_check, d.user_data ? (const char *)d.user_data : "(none)");
    return 0;
}

static void register_all(void)
{
    s_vpi_systf_data tf;

    memset(&tf, 0, sizeof tf);
    tf.type = vpiSysFunc;
    tf.sysfunctype = vpiIntFunc;
    tf.tfname = (PLI_BYTE8 *)"$vt_sum";
    tf.calltf = sum_calltf;
    tf.compiletf = no_check;
    tf.user_data = sum_data;
    sum_systf = vpi_register_systf(&tf);

    memset(&tf, 0, sizeof tf);
    tf.type = vpiSysTask;
    tf.tfname = (PLI_BYTE8 *)"$vt_count";
    tf.calltf = count_calltf;
    tf.compiletf = no_check;
    tf.user_data = count_data;
    count_systf = vpi_register_systf(&tf);

    memset(&tf, 0, sizeof tf);
    tf.type = vpiSysTask;
    tf.tfname = (PLI_BYTE8 *)"$vt_info";
    tf.calltf = info_calltf;
    vpi_register_systf(&tf);
}

void (*vlog_startup_routines[])(void) = {register_all, 0};

#ifdef __cplusplus
}
#endif
