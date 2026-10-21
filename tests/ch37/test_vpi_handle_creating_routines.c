/* VPI programs of test_vpi_handle_creating_routines (IEEE 1800-2023 37.2.1). */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

#define TOP "test_vpi_handle_creating_routines"

static void same(const char *what, vpiHandle a, vpiHandle b)
{
    if (a == NULL || b == NULL)
        vpi_printf("%s: a handle is NULL\n", what);
    else
        vpi_printf("%s: %d\n", what, (int)vpi_compare_objects(a, b));
}

static vpiHandle first_port(vpiHandle inst)
{
    vpiHandle it = inst ? vpi_iterate(vpiPort, inst) : NULL;
    vpiHandle p = it ? vpi_scan(it) : NULL;
    if (p != NULL)
        vpi_release_handle(it);
    return p;
}

/* ---- VPI program A ---- */

static vpiHandle a_systf, a_count;

static PLI_INT32 a_never(p_cb_data cb)
{
    (void)cb;
    return 0;
}

static void a_intermod_path(vpiHandle s, vpiHandle t)
{
    vpiHandle out = first_port(s), in = first_port(t), path, it, p;
    int ports = 0, has_out = 0, has_in = 0;
    s_vpi_delay delay;
    s_vpi_time times[2];

    path = out && in ? vpi_handle_multi(vpiInterModPath, out, in) : NULL;
    if (path == NULL) {
        vpi_printf("vpi_handle_multi: NULL\n");
        return;
    }
    vpi_printf("vpi_handle_multi: type vpiInterModPath %d\n",
               vpi_get(vpiType, path) == vpiInterModPath);
    it = vpi_iterate(vpiPort, path);
    while (it && (p = vpi_scan(it)) != NULL) {
        ports++;
        has_out |= vpi_compare_objects(p, out);
        has_in |= vpi_compare_objects(p, in);
    }
    vpi_printf("ports of the path: %d, the output port of s %d, the input port of t %d\n",
               ports, has_out, has_in);
    memset(&delay, 0, sizeof delay);
    memset(times, 0, sizeof times);
    delay.da = times;
    delay.no_of_delays = 2;
    delay.time_type = vpiScaledRealTime;
    times[0].type = times[1].type = vpiScaledRealTime;
    times[0].real = 3.0;
    times[1].real = 5.0;
    vpi_put_delays(path, &delay);
    times[0].real = times[1].real = 0.0;
    vpi_get_delays(path, &delay);
    vpi_printf("delays of the path after vpi_put_delays: %g %g\n", times[0].real, times[1].real);
}

static PLI_INT32 a_calltf(PLI_BYTE8 *user_data)
{
    vpiHandle top = vpi_handle_by_name((PLI_BYTE8 *)TOP, NULL);
    vpiHandle mem = vpi_handle_by_name((PLI_BYTE8 *)TOP ".mem", NULL);
    vpiHandle s = vpi_handle_by_name((PLI_BYTE8 *)TOP ".s", NULL);
    vpiHandle t = vpi_handle_by_name((PLI_BYTE8 *)TOP ".t", NULL);
    vpiHandle w = vpi_handle_by_name((PLI_BYTE8 *)TOP ".w", NULL);
    vpiHandle it, h, s_scanned = NULL, cb, call;
    s_cb_data cbd;
    s_vpi_time cbt;
    s_vpi_value cbv;
    s_vpi_systf_data info;

    (void)user_data;
    a_count = vpi_handle_by_name((PLI_BYTE8 *)TOP ".count", NULL);

    same("mem[2] by index, by name", mem ? vpi_handle_by_index(mem, 2) : NULL,
         vpi_handle_by_name((PLI_BYTE8 *)TOP ".mem[2]", NULL));
    same("mem[1] by index, mem[2] by name", mem ? vpi_handle_by_index(mem, 1) : NULL,
         vpi_handle_by_name((PLI_BYTE8 *)TOP ".mem[2]", NULL));

    it = top ? vpi_iterate(vpiModule, top) : NULL;
    vpi_printf("vpi_iterate: type vpiIterator %d\n",
               it ? vpi_get(vpiType, it) == vpiIterator : -1);
    while (it && (h = vpi_scan(it)) != NULL)
        if (s && vpi_compare_objects(h, s))
            s_scanned = h;
    same("s by vpi_scan, by name", s_scanned, s);
    same("module of w by vpi_handle, module by name", w ? vpi_handle(vpiModule, w) : NULL, top);

    memset(&cbd, 0, sizeof cbd);
    cbt.type = vpiSuppressTime;
    cbv.format = vpiSuppressVal;
    cbd.reason = cbValueChange;
    cbd.cb_rtn = a_never;
    cbd.obj = mem ? vpi_handle_by_index(mem, 3) : NULL;
    cbd.time = &cbt;
    cbd.value = &cbv;
    cb = cbd.obj ? vpi_register_cb(&cbd) : NULL;
    if (cb == NULL) {
        vpi_printf("vpi_register_cb: NULL\n");
    } else {
        vpi_printf("vpi_register_cb: type vpiCallback %d\n", vpi_get(vpiType, cb) == vpiCallback);
        vpi_printf("vpi_remove_cb: %d\n", (int)vpi_remove_cb(cb));
    }

    memset(&info, 0, sizeof info);
    if (a_systf != NULL)
        vpi_get_systf_info(a_systf, &info);
    vpi_printf("vpi_register_systf: %s\n", info.tfname ? info.tfname : "(no name)");
    call = vpi_handle(vpiSysTfCall, NULL);
    h = call ? vpi_handle(vpiUserSystf, call) : NULL;
    memset(&info, 0, sizeof info);
    if (h != NULL)
        vpi_get_systf_info(h, &info);
    vpi_printf("systf of this call: %s\n", info.tfname ? info.tfname : "(no name)");

    a_intermod_path(s, t);
    return 0;
}

static PLI_INT32 a_release_calltf(PLI_BYTE8 *user_data)
{
    (void)user_data;
    if (a_count == NULL) {
        vpi_printf("program A: no handle to count\n");
        return 0;
    }
    vpi_printf("program A releases its handle to count: %d\n", (int)vpi_release_handle(a_count));
    a_count = NULL;
    return 0;
}

static vpiHandle register_task(const char *name, PLI_INT32 (*calltf)(PLI_BYTE8 *))
{
    s_vpi_systf_data d;
    memset(&d, 0, sizeof d);
    d.type = vpiSysTask;
    d.tfname = (PLI_BYTE8 *)name;
    d.calltf = calltf;
    return vpi_register_systf(&d);
}

static void program_a(void)
{
    a_systf = register_task("$vt_a", a_calltf);
    register_task("$vt_a_release", a_release_calltf);
}

/* ---- VPI program B ---- */

static vpiHandle b_count;

static PLI_INT32 b_get_calltf(PLI_BYTE8 *user_data)
{
    (void)user_data;
    b_count = vpi_handle_by_name((PLI_BYTE8 *)TOP ".count", NULL);
    return 0;
}

static PLI_INT32 b_read_calltf(PLI_BYTE8 *user_data)
{
    s_vpi_value v;

    (void)user_data;
    if (b_count == NULL) {
        vpi_printf("program B: no handle to count\n");
        return 0;
    }
    v.format = vpiIntVal;
    vpi_get_value(b_count, &v);
    vpi_printf("program B reads count through its handle: %d\n", (int)v.value.integer);
    same("program B's handle, a new handle to count", b_count,
         vpi_handle_by_name((PLI_BYTE8 *)TOP ".count", NULL));
    return 0;
}

static void program_b(void)
{
    register_task("$vt_b_get", b_get_calltf);
    register_task("$vt_b_read", b_read_calltf);
}

void (*vlog_startup_routines[])(void) = {program_a, program_b, 0};

#ifdef __cplusplus
}
#endif
