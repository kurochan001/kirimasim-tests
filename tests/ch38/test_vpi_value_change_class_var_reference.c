/* VPI application of test_vpi_value_change_class_var_reference (IEEE 1800-2023 38.36.1). */
#include <string.h>
#include "vpi_user.h"
#include "sv_vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

#define TOP "test_vpi_value_change_class_var_reference."

static vpiHandle h_var, a1_var, a2_var;
static s_vpi_time request_time;
static s_vpi_value request_value;

static PLI_INT32 on_change(p_cb_data cb)
{
    PLI_INT64 id = vpi_get64(vpiObjId, h_var);
    PLI_INT64 id1 = vpi_get64(vpiObjId, a1_var);
    PLI_INT64 id2 = vpi_get64(vpiObjId, a2_var);
    const char *what = id == 0 ? "nothing" : id == id1 ? "the object of a1"
                       : id == id2 ? "the object of a2" : "another object";

    vpi_printf((PLI_BYTE8 *)"%d: value %s, h refers to %s\n",
               cb->time != NULL ? (int)cb->time->low : -1,
               cb->value == NULL ? "NULL" : "not NULL", what);
    return 0;
}

static PLI_INT32 at_1(p_cb_data data)
{
    s_cb_data cb;

    (void)data;
    request_time.type = vpiSimTime;
    request_value.format = vpiObjTypeVal;
    memset(&cb, 0, sizeof cb);
    cb.reason = cbValueChange;
    cb.cb_rtn = on_change;
    cb.obj = h_var;
    cb.time = &request_time;
    cb.value = &request_value;
    if (vpi_register_cb(&cb) == NULL)
        vpi_printf((PLI_BYTE8 *)"not registered\n");
    return 0;
}

static PLI_INT32 on_start(p_cb_data data)
{
    static s_vpi_time one;
    s_cb_data cb;

    (void)data;
    h_var = vpi_handle_by_name((PLI_BYTE8 *)TOP "h", NULL);
    a1_var = vpi_handle_by_name((PLI_BYTE8 *)TOP "a1", NULL);
    a2_var = vpi_handle_by_name((PLI_BYTE8 *)TOP "a2", NULL);
    if (h_var == NULL || a1_var == NULL || a2_var == NULL) {
        vpi_printf((PLI_BYTE8 *)"class variables not found\n");
        return 0;
    }
    one.type = vpiSimTime;
    one.high = 0;
    one.low = 1;
    memset(&cb, 0, sizeof cb);
    cb.reason = cbAfterDelay;
    cb.cb_rtn = at_1;
    cb.time = &one;
    vpi_register_cb(&cb);
    return 0;
}

static void register_all(void)
{
    s_cb_data cb;

    memset(&cb, 0, sizeof cb);
    cb.reason = cbStartOfSimulation;
    cb.cb_rtn = on_start;
    vpi_register_cb(&cb);
}

void (*vlog_startup_routines[])(void) = {register_all, 0};

#ifdef __cplusplus
}
#endif
