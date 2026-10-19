/* VPI application of test_vpi_callback_objects (IEEE 1800-2023 37.80). */
#include <stdio.h>
#include <string.h>
#include "vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

#define TOP "test_vpi_callback_objects"

static vpiHandle cb_w, cb_r, cb_end;
static int w_changes, r_changes;

static PLI_INT32 on_w(p_cb_data data)
{
    (void)data;
    w_changes++;
    return 0;
}

static PLI_INT32 on_r(p_cb_data data)
{
    (void)data;
    r_changes++;
    return 0;
}

static PLI_INT32 on_end(p_cb_data data)
{
    (void)data;
    return 0;
}

static vpiHandle add_cb(PLI_INT32 reason, vpiHandle obj, PLI_INT32 (*rtn)(p_cb_data))
{
    s_cb_data cb;
    s_vpi_time t;
    s_vpi_value v;

    memset(&cb, 0, sizeof cb);
    t.type = vpiSuppressTime;
    v.format = vpiSuppressVal;
    cb.reason = reason;
    cb.cb_rtn = rtn;
    cb.obj = obj;
    cb.time = &t;
    cb.value = &v;
    return vpi_register_cb(&cb);
}

static PLI_INT32 register_calltf(PLI_BYTE8 *user_data)
{
    (void)user_data;
    cb_w = add_cb(cbValueChange, vpi_handle_by_name((PLI_BYTE8 *)TOP ".w", NULL), on_w);
    cb_r = add_cb(cbValueChange, vpi_handle_by_name((PLI_BYTE8 *)TOP ".r", NULL), on_r);
    cb_end = add_cb(cbEndOfSimulation, NULL, on_end);
    return 0;
}

/* Prints how many callbacks are on obj and whether they include cb. */
static void report(const char *label, vpiHandle obj, vpiHandle cb)
{
    vpiHandle it = vpi_iterate(vpiCallback, obj), h;
    int n = 0, found = 0;
    s_cb_data info;

    if (it != NULL)
        while ((h = vpi_scan(it)) != NULL) {
            n++;
            if (cb != NULL && vpi_compare_objects(h, cb))
                found = 1;
        }
    vpi_printf((PLI_BYTE8 *)"%s: %d callback(s), includes the registered one %d\n", label, n,
               found);
    if (obj != NULL && n > 0) {
        memset(&info, 0, sizeof info);
        vpi_get_cb_info(cb, &info);
        vpi_printf((PLI_BYTE8 *)"%s: reason value change %d, object is %s %d\n", label,
                   info.reason == cbValueChange, label,
                   info.obj != NULL && vpi_compare_objects(info.obj, obj));
    }
}

static PLI_INT32 callbacks_calltf(PLI_BYTE8 *user_data)
{
    vpiHandle w = vpi_handle_by_name((PLI_BYTE8 *)TOP ".w", NULL);
    vpiHandle r = vpi_handle_by_name((PLI_BYTE8 *)TOP ".r", NULL);
    vpiHandle it, h;
    int found = 0;

    (void)user_data;
    vpi_printf((PLI_BYTE8 *)"w changed %d time(s), r changed %d time(s)\n", w_changes, r_changes);
    report("w", w, cb_w);
    report("r", r, cb_r);
    it = vpi_iterate(vpiCallback, NULL);
    if (it != NULL)
        while ((h = vpi_scan(it)) != NULL)
            if (vpi_compare_objects(h, cb_end))
                found = 1;
    vpi_printf((PLI_BYTE8 *)"NULL: includes the end of simulation callback %d\n", found);
    vpi_printf((PLI_BYTE8 *)"remove the callback on r: %d\n", (int)vpi_remove_cb(cb_r));
    report("r", r, NULL);
    return 0;
}

static void register_task(const char *name, PLI_INT32 (*calltf)(PLI_BYTE8 *))
{
    s_vpi_systf_data d;
    memset(&d, 0, sizeof d);
    d.type = vpiSysTask;
    d.tfname = (PLI_BYTE8 *)name;
    d.calltf = calltf;
    vpi_register_systf(&d);
}

static void register_all(void)
{
    register_task("$vt_register", register_calltf);
    register_task("$vt_callbacks", callbacks_calltf);
}

void (*vlog_startup_routines[])(void) = {register_all, 0};

#ifdef __cplusplus
}
#endif
