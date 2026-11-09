/* VPI application of test_pli_time_slot_region_order
   (IEEE 1800-2023 4.4, 4.10, 38.36.2). */
#include <stdio.h>
#include <string.h>
#include "vpi_user.h"

/* The value that Annex K gives, for vpi_user.h files that leave it out. */
#ifndef cbNBASynch
#define cbNBASynch 30
#endif

#ifdef __cplusplus
extern "C" {
#endif

static const char *const names[] = {"cbAtStartOfSimTime", "cbNBASynch", "cbAtEndOfSimTime",
                                    "cbReadOnlySynch"};
static const PLI_INT32 reasons[] = {cbAtStartOfSimTime, cbNBASynch, cbAtEndOfSimTime,
                                    cbReadOnlySynch};

static int value_of(const char *name)
{
    char full[96];
    vpiHandle h;
    s_vpi_value v;

    snprintf(full, sizeof full, "test_pli_time_slot_region_order.%s", name);
    h = vpi_handle_by_name((PLI_BYTE8 *)full, NULL);
    if (h == NULL)
        return -1;
    v.format = vpiIntVal;
    vpi_get_value(h, &v);
    return (int)v.value.integer;
}

static PLI_INT32 on_time(p_cb_data cb)
{
    int k = (int)(cb->user_data - (PLI_BYTE8 *)names);

    if (k == 0 || k == 1)
        vpi_printf("%s at %d: v=%d\n", names[k], (int)cb->time->low, value_of("v"));
    else
        vpi_printf("%s at %d: v=%d p=%d back=%d\n", names[k], (int)cb->time->low,
                   value_of("v"), value_of("p"), value_of("back"));
    return 0;
}

static PLI_INT32 register_calltf(PLI_BYTE8 *user_data)
{
    int k;

    (void)user_data;
    for (k = 0; k < 4; k++) {
        s_cb_data cb;
        s_vpi_time t;
        memset(&cb, 0, sizeof cb);
        memset(&t, 0, sizeof t);
        t.type = vpiSimTime;
        t.low = 10;
        cb.reason = reasons[k];
        cb.cb_rtn = on_time;
        cb.time = &t;
        cb.user_data = (PLI_BYTE8 *)names + k;
        if (vpi_register_cb(&cb) == NULL)
            vpi_printf("%s could not be registered\n", names[k]);
    }
    return 0;
}

static void register_systf(void)
{
    s_vpi_systf_data tf;

    memset(&tf, 0, sizeof tf);
    tf.type = vpiSysTask;
    tf.tfname = (PLI_BYTE8 *)"$vt_register";
    tf.calltf = register_calltf;
    vpi_register_systf(&tf);
}

void (*vlog_startup_routines[])(void) = {register_systf, 0};

#ifdef __cplusplus
}
#endif
