/* VPI application of test_vpi_size_change_callback_resizes (IEEE 1800-2023 38.36.1, 37.17). */
#include <string.h>
#include "vpi_user.h"
#include "sv_vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

#define TOP "test_vpi_size_change_callback_resizes."

static const char *const names[4] = {"da", "aa", "q", "s"};
static vpiHandle objects[4];
static s_vpi_time request_time;
static s_vpi_value request_value;

static PLI_INT32 on_size(p_cb_data cb)
{
    vpi_printf((PLI_BYTE8 *)"%d: %s",
               cb->time != NULL ? (int)cb->time->low : -1, cb->user_data);
    if (cb->value != NULL && cb->value->format == vpiIntVal)
        vpi_printf((PLI_BYTE8 *)", value %d", (int)cb->value->value.integer);
    else
        vpi_printf((PLI_BYTE8 *)", no integer value");
    vpi_printf((PLI_BYTE8 *)", vpiSize %d\n", (int)vpi_get(vpiSize, cb->obj));
    return 0;
}

static PLI_INT32 at_1(p_cb_data data)
{
    s_cb_data cb;
    int k;

    (void)data;
    request_time.type = vpiSimTime;
    request_value.format = vpiIntVal;
    for (k = 0; k < 4; k++) {
        memset(&cb, 0, sizeof cb);
        cb.reason = cbSizeChange;
        cb.cb_rtn = on_size;
        cb.obj = objects[k];
        cb.time = &request_time;
        cb.value = &request_value;
        cb.user_data = (PLI_BYTE8 *)names[k];
        if (vpi_register_cb(&cb) == NULL)
            vpi_printf((PLI_BYTE8 *)"%s: not registered\n", names[k]);
    }
    return 0;
}

static PLI_INT32 on_start(p_cb_data data)
{
    static s_vpi_time one;
    char full[96];
    s_cb_data cb;
    int k;

    (void)data;
    for (k = 0; k < 4; k++) {
        strcpy(full, TOP);
        strcat(full, names[k]);
        objects[k] = vpi_handle_by_name((PLI_BYTE8 *)full, NULL);
        if (objects[k] == NULL) {
            vpi_printf((PLI_BYTE8 *)"%s not found\n", names[k]);
            return 0;
        }
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
