/* VPI application of test_vpi_force_release_driver_kinds (IEEE 1800-2023 38.34). */
#include <string.h>
#include "vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

#define TOP "test_vpi_force_release_driver_kinds."
#define COUNT 6

static const char *const names[COUNT] = {"v", "cv", "pv", "n", "g", "mo"};
static const int forced[COUNT] = {30, 40, 50, 60, 1, 70};
static vpiHandle objects[COUNT];

static PLI_INT32 at_10(p_cb_data cb)
{
    s_vpi_value value;
    int k;

    (void)cb;
    for (k = 0; k < COUNT; k++) {
        value.format = vpiIntVal;
        value.value.integer = forced[k];
        vpi_put_value(objects[k], &value, NULL, vpiForceFlag);
    }
    return 0;
}

static PLI_INT32 at_14(p_cb_data cb)
{
    s_vpi_value value;
    int k;

    (void)cb;
    for (k = 0; k < COUNT; k++) {
        value.format = vpiIntVal;
        value.value.integer = 0;
        vpi_put_value(objects[k], &value, NULL, vpiReleaseFlag);
    }
    return 0;
}

static void after(PLI_UINT32 delay, PLI_INT32 (*rtn)(p_cb_data))
{
    static s_vpi_time times[2];
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
    char full[96];
    int k;

    (void)data;
    for (k = 0; k < COUNT; k++) {
        strcpy(full, TOP);
        strcat(full, names[k]);
        objects[k] = vpi_handle_by_name((PLI_BYTE8 *)full, NULL);
        if (objects[k] == NULL) {
            vpi_printf((PLI_BYTE8 *)"%s not found\n", names[k]);
            return 0;
        }
    }
    after(10, at_10);
    after(14, at_14);
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
