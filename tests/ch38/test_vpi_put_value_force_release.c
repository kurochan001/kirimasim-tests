/* VPI application of test_vpi_put_value_force_release (IEEE 1800-2023 38.34). */
#include <string.h>
#include "vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

#define TOP "test_vpi_put_value_force_release."

static vpiHandle v_obj, n_obj;

static int read_int(vpiHandle h)
{
    s_vpi_value v;
    v.format = vpiIntVal;
    vpi_get_value(h, &v);
    return (int)v.value.integer;
}

static void put_int(vpiHandle h, int value, p_vpi_time t, PLI_INT32 flags)
{
    s_vpi_value v;
    v.format = vpiIntVal;
    v.value.integer = value;
    vpi_put_value(h, &v, t, flags);
}

static PLI_INT32 at_5(p_cb_data cb)
{
    s_vpi_time seven;

    (void)cb;
    put_int(v_obj, 20, NULL, vpiNoDelay);
    vpi_printf((PLI_BYTE8 *)"5: vpiNoDelay 20 with time_p NULL, v=%d\n", read_int(v_obj));
    seven.type = vpiSimTime;
    seven.high = 0;
    seven.low = 7;
    put_int(v_obj, 21, &seven, vpiNoDelay);
    vpi_printf((PLI_BYTE8 *)"5: vpiNoDelay 21 with a time_p of 7, v=%d\n", read_int(v_obj));
    return 0;
}

static PLI_INT32 at_15(p_cb_data cb)
{
    (void)cb;
    put_int(v_obj, 30, NULL, vpiForceFlag);
    put_int(n_obj, 40, NULL, vpiForceFlag);
    vpi_printf((PLI_BYTE8 *)"15: after vpiForceFlag v=%d n=%d\n", read_int(v_obj),
               read_int(n_obj));
    return 0;
}

static PLI_INT32 at_25(p_cb_data cb)
{
    s_vpi_value released_v, released_n;

    (void)cb;
    released_v.format = vpiIntVal;
    released_v.value.integer = -1;
    vpi_put_value(v_obj, &released_v, NULL, vpiReleaseFlag);
    released_n.format = vpiIntVal;
    released_n.value.integer = -1;
    vpi_put_value(n_obj, &released_n, NULL, vpiReleaseFlag);
    vpi_printf((PLI_BYTE8 *)"25: vpiReleaseFlag gives v %d and n %d in value_p\n",
               (int)released_v.value.integer, (int)released_n.value.integer);
    vpi_printf((PLI_BYTE8 *)"25: after vpiReleaseFlag v=%d n=%d\n", read_int(v_obj),
               read_int(n_obj));
    return 0;
}

static void after(PLI_UINT32 delay, PLI_INT32 (*rtn)(p_cb_data))
{
    static s_vpi_time times[3];
    static int used = 0;
    s_cb_data cb;

    times[used].type = vpiSimTime;
    times[used].high = 0;
    times[used].low = delay;
    memset(&cb, 0, sizeof cb);
    cb.reason = cbAfterDelay;
    cb.cb_rtn = rtn;
    cb.time = &times[used++];
    vpi_register_cb(&cb);
}

static PLI_INT32 on_start(p_cb_data data)
{
    (void)data;
    v_obj = vpi_handle_by_name((PLI_BYTE8 *)TOP "v", NULL);
    n_obj = vpi_handle_by_name((PLI_BYTE8 *)TOP "n", NULL);
    if (v_obj == NULL || n_obj == NULL) {
        vpi_printf((PLI_BYTE8 *)"objects not found\n");
        return 0;
    }
    after(5, at_5);
    after(15, at_15);
    after(25, at_25);
    return 0;
}

static void register_all(void)
{
    s_cb_data d;
    memset(&d, 0, sizeof d);
    d.reason = cbStartOfSimulation;
    d.cb_rtn = on_start;
    vpi_register_cb(&d);
}

void (*vlog_startup_routines[])(void) = {register_all, 0};

#ifdef __cplusplus
}
#endif
