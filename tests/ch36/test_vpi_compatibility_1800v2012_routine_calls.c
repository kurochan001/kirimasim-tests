/* VPI application of test_vpi_compatibility_1800v2012_routine_calls
   (IEEE 1800-2023 36.12.2.1, L.2, chapter 38). */
/* The one compatibility macro, defined as 1 before any VPI header. */
#define VPI_COMPATIBILITY_VERSION_1800v2012 1
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

#define TOP "test_vpi_compatibility_1800v2012_routine_calls"

#define VT_STR(x) #x
#define VT_XSTR(x) VT_STR(x)
#define SHOW(f) vpi_printf((PLI_BYTE8 *)"%s calls %s\n", #f, VT_XSTR(f))

static vpiHandle find(const char *name)
{
    char full[160];
    vpiHandle h;
    if (name[0] != '\0')
        snprintf(full, sizeof full, "%s.%s", TOP, name);
    else
        snprintf(full, sizeof full, "%s", TOP);
    h = vpi_handle_by_name((PLI_BYTE8 *)full, NULL);
    if (h == NULL)
        vpi_printf((PLI_BYTE8 *)"%s: not found\n", full);
    return h;
}

static int int_value(vpiHandle h)
{
    s_vpi_value v;
    if (h == NULL)
        return -1;
    v.format = vpiIntVal;
    vpi_get_value(h, &v);
    return (int)v.value.integer;
}

static vpiHandle first_port(const char *instance)
{
    vpiHandle inst = find(instance);
    vpiHandle it = inst != NULL ? vpi_iterate(vpiPort, inst) : NULL;
    vpiHandle port = it != NULL ? vpi_scan(it) : NULL;
    if (port != NULL)
        vpi_free_object(it);
    return port;
}

static void show_all(void)
{
    SHOW(vpi_compare_objects);
    SHOW(vpi_control);
    SHOW(vpi_get);
    SHOW(vpi_get_str);
    SHOW(vpi_get_value);
    SHOW(vpi_handle);
    SHOW(vpi_handle_by_index);
    SHOW(vpi_handle_by_multi_index);
    SHOW(vpi_handle_by_name);
    SHOW(vpi_handle_multi);
    SHOW(vpi_iterate);
    SHOW(vpi_put_value);
    SHOW(vpi_register_cb);
    SHOW(vpi_scan);
}

static PLI_INT32 later_cb(p_cb_data cb)
{
    s_vpi_time now;
    vpiHandle r = find("r");

    (void)cb;
    now.type = vpiSimTime;
    vpi_get_time(NULL, &now);
    vpi_printf((PLI_BYTE8 *)"callback at %d: r = %d, vpi_control(vpiFinish, 0)\n",
               (int)now.low, int_value(r));
    vpi_control(vpiFinish, 0);
    return 0;
}

static PLI_INT32 end_cb(p_cb_data cb)
{
    (void)cb;
    vpi_printf((PLI_BYTE8 *)"end of simulation callback\n");
    return 0;
}

static void register_callbacks(void)
{
    s_cb_data cb;
    s_vpi_time t;
    vpiHandle h1, h2;

    memset(&cb, 0, sizeof cb);
    memset(&t, 0, sizeof t);
    t.type = vpiSimTime;
    t.low = 2;
    cb.reason = cbAfterDelay;
    cb.cb_rtn = later_cb;
    cb.time = &t;
    h1 = vpi_register_cb(&cb);

    memset(&cb, 0, sizeof cb);
    cb.reason = cbEndOfSimulation;
    cb.cb_rtn = end_cb;
    h2 = vpi_register_cb(&cb);
    vpi_printf((PLI_BYTE8 *)"vpi_register_cb: cbAfterDelay %s, cbEndOfSimulation %s\n",
               h1 != NULL ? "registered" : "NULL", h2 != NULL ? "registered" : "NULL");
}

static PLI_INT32 calls_calltf(PLI_BYTE8 *user_data)
{
    vpiHandle top, r, r2, w, arr, bit, elem, mod, it, h, out, in, path;
    PLI_BYTE8 *s;
    PLI_INT32 index[2];
    s_vpi_value v;
    int n = 0;

    (void)user_data;
    show_all();
    top = find("");
    r = find("r");
    r2 = find("r");
    w = find("w");
    arr = find("arr");
    if (top == NULL || r == NULL || r2 == NULL || w == NULL || arr == NULL)
        return 0;

    s = vpi_get_str(vpiFullName, r);
    vpi_printf((PLI_BYTE8 *)"vpi_handle_by_name and vpi_get_str(vpiFullName): %s\n",
               s != NULL ? s : "(null)");
    vpi_printf((PLI_BYTE8 *)"vpi_get(vpiSize): %d\n", (int)vpi_get(vpiSize, r));
    vpi_printf((PLI_BYTE8 *)"vpi_get_value: %d\n", int_value(r));

    v.format = vpiIntVal;
    v.value.integer = 0x34;
    vpi_put_value(r, &v, NULL, vpiNoDelay);
    vpi_printf((PLI_BYTE8 *)"vpi_put_value of 52, then vpi_get_value: %d\n", int_value(r));

    bit = vpi_handle_by_index(r, 2);
    vpi_printf((PLI_BYTE8 *)"vpi_handle_by_index(r, 2): %d\n", int_value(bit));

    index[0] = 1;
    index[1] = 2;
    elem = vpi_handle_by_multi_index(arr, 2, index);
    vpi_printf((PLI_BYTE8 *)"vpi_handle_by_multi_index(arr, {1, 2}): %d\n", int_value(elem));

    mod = vpi_handle(vpiModule, r);
    s = mod != NULL ? vpi_get_str(vpiFullName, mod) : NULL;
    vpi_printf((PLI_BYTE8 *)"vpi_handle(vpiModule, r): %s\n", s != NULL ? s : "(none)");

    vpi_printf((PLI_BYTE8 *)"vpi_iterate(vpiNet) and vpi_scan:");
    it = vpi_iterate(vpiNet, top);
    while (it != NULL && (h = vpi_scan(it)) != NULL) {
        s = vpi_get_str(vpiName, h);
        vpi_printf((PLI_BYTE8 *)" %s", s != NULL ? s : "(null)");
        n++;
    }
    vpi_printf((PLI_BYTE8 *)" (%d)\n", n);

    vpi_printf((PLI_BYTE8 *)"vpi_compare_objects: r and r %d, r and w %d\n",
               (int)vpi_compare_objects(r, r2), (int)vpi_compare_objects(r, w));

    out = first_port("s");
    in = first_port("d");
    path = out != NULL && in != NULL ? vpi_handle_multi(vpiInterModPath, out, in) : NULL;
    vpi_printf((PLI_BYTE8 *)"vpi_handle_multi(vpiInterModPath): %s\n", path == NULL ? "NULL"
               : vpi_get(vpiType, path) == vpiInterModPath ? "vpiInterModPath" : "other type");

    register_callbacks();
    return 0;
}

static void register_all(void)
{
    s_vpi_systf_data d;
    memset(&d, 0, sizeof d);
    d.type = vpiSysTask;
    d.tfname = (PLI_BYTE8 *)"$vt_calls";
    d.calltf = calls_calltf;
    vpi_register_systf(&d);
}

void (*vlog_startup_routines[])(void) = {register_all, 0};

#ifdef __cplusplus
}
#endif
