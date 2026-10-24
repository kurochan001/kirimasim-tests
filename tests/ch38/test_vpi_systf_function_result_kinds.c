/* VPI application of test_vpi_systf_function_result_kinds (IEEE 1800-2023 38.37.1). */
#include <string.h>
#include "vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

enum { INT, REAL, TIME, SIZED40, SIGNED40, TASK, KINDS };

static const char *const kind_names[KINDS] = {"int", "real", "time", "sized 40", "sized signed 40",
                                              "task"};
static char tags[KINDS + 2];
static int sizetf_calls[KINDS];

static void put(s_vpi_value *v)
{
    vpi_put_value(vpi_handle(vpiSysTfCall, NULL), v, NULL, vpiNoDelay);
}

static PLI_INT32 count_sizetf(PLI_BYTE8 *user_data)
{
    int k = (int)(user_data - tags);
    if (k >= 0 && k < KINDS)
        sizetf_calls[k]++;
    return 40;
}

static PLI_INT32 int_calltf(PLI_BYTE8 *user_data)
{
    s_vpi_value v;
    (void)user_data;
    v.format = vpiIntVal;
    v.value.integer = -5;
    put(&v);
    return 0;
}

static PLI_INT32 real_calltf(PLI_BYTE8 *user_data)
{
    s_vpi_value v;
    (void)user_data;
    v.format = vpiRealVal;
    v.value.real = 2.5;
    put(&v);
    return 0;
}

static PLI_INT32 time_calltf(PLI_BYTE8 *user_data)
{
    s_vpi_value v;
    s_vpi_time t;
    (void)user_data;
    t.type = vpiSimTime;
    t.high = 256;
    t.low = 3;
    v.format = vpiTimeVal;
    v.value.time = &t;
    put(&v);
    return 0;
}

static PLI_INT32 bit39_calltf(PLI_BYTE8 *user_data)
{
    s_vpi_value v;
    s_vpi_vecval w[2];
    (void)user_data;
    w[0].aval = 0;
    w[0].bval = 0;
    w[1].aval = 0x80u;
    w[1].bval = 0;
    v.format = vpiVectorVal;
    v.value.vector = w;
    put(&v);
    return 0;
}

static PLI_INT32 bits63_31_calltf(PLI_BYTE8 *user_data)
{
    s_vpi_value v;
    s_vpi_vecval w[2];
    (void)user_data;
    w[0].aval = 0x80000000u;
    w[0].bval = 0;
    w[1].aval = 0x80000000u;
    w[1].bval = 0;
    v.format = vpiVectorVal;
    v.value.vector = w;
    put(&v);
    return 0;
}

static PLI_INT32 task_calltf(PLI_BYTE8 *user_data)
{
    (void)user_data;
    vpi_printf((PLI_BYTE8 *)"$vt_task ran as a task\n");
    return 0;
}

static PLI_INT32 report_calltf(PLI_BYTE8 *user_data)
{
    int k;
    (void)user_data;
    vpi_printf((PLI_BYTE8 *)"sizetf calls:");
    for (k = 0; k < KINDS; k++)
        vpi_printf((PLI_BYTE8 *)" %s %d%s", kind_names[k], sizetf_calls[k],
                   k + 1 < KINDS ? "," : "\n");
    return 0;
}

static void add(PLI_INT32 type, PLI_INT32 functype, const char *name,
                PLI_INT32 (*calltf)(PLI_BYTE8 *), int kind)
{
    s_vpi_systf_data d;
    memset(&d, 0, sizeof d);
    d.type = type;
    d.sysfunctype = functype;
    d.tfname = (PLI_BYTE8 *)name;
    d.calltf = calltf;
    if (kind >= 0) {
        d.sizetf = count_sizetf;
        d.user_data = &tags[kind];
    }
    vpi_register_systf(&d);
}

static void register_all(void)
{
    add(vpiSysFunc, vpiIntFunc, "$vt_int", int_calltf, INT);
    add(vpiSysFunc, vpiRealFunc, "$vt_real", real_calltf, REAL);
    add(vpiSysFunc, vpiTimeFunc, "$vt_time", time_calltf, TIME);
    add(vpiSysFunc, vpiSizedFunc, "$vt_sized40", bit39_calltf, SIZED40);
    add(vpiSysFunc, vpiSizedSignedFunc, "$vt_signed40", bit39_calltf, SIGNED40);
    add(vpiSysFunc, vpiSizedFunc, "$vt_sized32", bits63_31_calltf, -1);
    add(vpiSysFunc, vpiSizedSignedFunc, "$vt_signed32", bits63_31_calltf, -1);
    add(vpiSysTask, vpiRealFunc, "$vt_task", task_calltf, TASK);
    add(vpiSysTask, 0, "$vt_report", report_calltf, -1);
}

void (*vlog_startup_routines[])(void) = {register_all, 0};

#ifdef __cplusplus
}
#endif
