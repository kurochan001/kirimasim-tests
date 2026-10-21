/* VPI application of test_vpi_register_systf_methods (IEEE 1800-2023 38.37.3). */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

static int listed_compiled;
static PLI_INT32 separate_offset = 100, listed_offset = 200;
static char separate_text[] = "separate", listed_text[] = "listed";

static PLI_INT32 show_calltf(PLI_BYTE8 *user_data)
{
    vpi_printf("%s: user data \"%s\"\n",
               user_data == separate_text ? "$vt_separate_task" : "another task",
               user_data ? user_data : "");
    return 0;
}

static PLI_INT32 listed_compiletf(PLI_BYTE8 *user_data)
{
    if (user_data == listed_text)
        listed_compiled++;
    return 0;
}

static PLI_INT32 listed_calltf(PLI_BYTE8 *user_data)
{
    vpi_printf("$vt_listed_task: user data \"%s\", compiletf ran %d times before\n",
               user_data ? user_data : "", listed_compiled);
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
    vpi_release_handle(it);
    v.format = vpiIntVal;
    vpi_get_value(arg, &v);
    v.value.integer += *(PLI_INT32 *)user_data;
    vpi_put_value(call, &v, NULL, vpiNoDelay);
    return 0;
}

static void register_separately(void)
{
    static s_vpi_systf_data task_data, func_data;

    task_data.type = vpiSysTask;
    task_data.tfname = (PLI_BYTE8 *)"$vt_separate_task";
    task_data.calltf = show_calltf;
    task_data.user_data = separate_text;
    vpi_register_systf(&task_data);

    func_data.type = vpiSysFunc;
    func_data.sysfunctype = vpiIntFunc;
    func_data.tfname = (PLI_BYTE8 *)"$vt_separate_func";
    func_data.calltf = add_calltf;
    func_data.user_data = (PLI_BYTE8 *)&separate_offset;
    vpi_register_systf(&func_data);
}

static void register_from_array(void)
{
    static s_vpi_systf_data list[] = {
        {vpiSysTask, 0, (PLI_BYTE8 *)"$vt_listed_task", listed_calltf, listed_compiletf, 0,
         listed_text},
        {vpiSysFunc, vpiIntFunc, (PLI_BYTE8 *)"$vt_listed_func", add_calltf, 0, 0,
         (PLI_BYTE8 *)&listed_offset},
        {0, 0, 0, 0, 0, 0, 0}};
    p_vpi_systf_data p = list;

    while (p->type)
        vpi_register_systf(p++);
}

void (*vlog_startup_routines[])(void) = {register_separately, register_from_array, 0};

#ifdef __cplusplus
}
#endif
