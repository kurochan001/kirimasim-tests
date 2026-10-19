/* VPI application of test_vpi_compiletf_sizetf (IEEE 1800-2023 36.8). */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

enum { TASK, WIDE, INT, KINDS };

static char tags[KINDS];
static int compiletf_calls[KINDS], sizetf_calls[KINDS], calltf_calls[KINDS];
static int wrong_user_data, end_of_compile, start_of_simulation;
static int built_late, started_early;

static int kind_of(PLI_BYTE8 *user_data)
{
    int k;
    for (k = 0; k < KINDS; k++)
        if (user_data == &tags[k])
            return k;
    wrong_user_data++;
    return -1;
}

static PLI_INT32 compiletf(PLI_BYTE8 *user_data)
{
    int k = kind_of(user_data);
    if (k >= 0)
        compiletf_calls[k]++;
    if (end_of_compile)
        built_late++;
    return 0;
}

static PLI_INT32 sizetf(PLI_BYTE8 *user_data)
{
    int k = kind_of(user_data);
    if (k >= 0)
        sizetf_calls[k]++;
    if (end_of_compile)
        built_late++;
    return 40;
}

static PLI_INT32 calltf(PLI_BYTE8 *user_data)
{
    int k = kind_of(user_data);
    s_vpi_value v;
    s_vpi_vecval bits[2];

    if (k < 0)
        return 0;
    calltf_calls[k]++;
    if (!start_of_simulation)
        started_early++;
    if (k == WIDE) {
        bits[0].aval = 0xffffffff;
        bits[0].bval = 0;
        bits[1].aval = 0xff;
        bits[1].bval = 0;
        v.format = vpiVectorVal;
        v.value.vector = bits;
        vpi_put_value(vpi_handle(vpiSysTfCall, NULL), &v, NULL, vpiNoDelay);
    } else if (k == INT) {
        v.format = vpiIntVal;
        v.value.integer = 7;
        vpi_put_value(vpi_handle(vpiSysTfCall, NULL), &v, NULL, vpiNoDelay);
    }
    return 0;
}

static PLI_INT32 report_calltf(PLI_BYTE8 *user_data)
{
    (void)user_data;
    vpi_printf("compiletf: $vt_task %d, $vt_wide %d, $vt_int %d\n", compiletf_calls[TASK],
               compiletf_calls[WIDE], compiletf_calls[INT]);
    vpi_printf("sizetf: $vt_task %d, $vt_wide %d, $vt_int %d\n", sizetf_calls[TASK],
               sizetf_calls[WIDE], sizetf_calls[INT]);
    vpi_printf("calltf: $vt_task %d, $vt_wide %d, $vt_int %d\n", calltf_calls[TASK],
               calltf_calls[WIDE], calltf_calls[INT]);
    vpi_printf("compiletf or sizetf after the end of compilation: %d\n", built_late);
    vpi_printf("calltf before the start of simulation: %d\n", started_early);
    vpi_printf("end of compilation before start of simulation: %s\n",
               end_of_compile == 1 && start_of_simulation == 2 ? "yes" : "no");
    vpi_printf("wrong user_data: %d\n", wrong_user_data);
    return 0;
}

static PLI_INT32 on_action(p_cb_data cb)
{
    static int order;
    if (cb->reason == cbEndOfCompile)
        end_of_compile = ++order;
    else if (cb->reason == cbStartOfSimulation)
        start_of_simulation = ++order;
    return 0;
}

static void add(PLI_INT32 type, PLI_INT32 functype, const char *name, PLI_BYTE8 *user_data,
                PLI_INT32 (*call)(PLI_BYTE8 *), int with_compiletf)
{
    s_vpi_systf_data d;
    memset(&d, 0, sizeof d);
    d.type = type;
    d.sysfunctype = functype;
    d.tfname = (PLI_BYTE8 *)name;
    d.calltf = call;
    if (with_compiletf) {
        d.compiletf = compiletf;
        d.sizetf = sizetf;
    }
    d.user_data = user_data;
    vpi_register_systf(&d);
}

static void register_all(void)
{
    s_cb_data cb;

    add(vpiSysTask, 0, "$vt_task", &tags[TASK], calltf, 1);
    add(vpiSysFunc, vpiSizedFunc, "$vt_wide", &tags[WIDE], calltf, 1);
    add(vpiSysFunc, vpiIntFunc, "$vt_int", &tags[INT], calltf, 1);
    add(vpiSysTask, 0, "$vt_report", NULL, report_calltf, 0);
    memset(&cb, 0, sizeof cb);
    cb.reason = cbEndOfCompile;
    cb.cb_rtn = on_action;
    vpi_register_cb(&cb);
    cb.reason = cbStartOfSimulation;
    vpi_register_cb(&cb);
}

void (*vlog_startup_routines[])(void) = {register_all, 0};

#ifdef __cplusplus
}
#endif
