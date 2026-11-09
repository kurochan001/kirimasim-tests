/* VPI application of test_pli_slot_entry_regions_run_once
   (IEEE 1800-2023 4.4.3.10, 4.10, 38.36.2). */
#include <stdio.h>
#include <string.h>
#include "vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

static vpiHandle var(const char *name)
{
    char full[96];

    snprintf(full, sizeof full, "test_pli_slot_entry_regions_run_once.%s", name);
    return vpi_handle_by_name((PLI_BYTE8 *)full, NULL);
}

static int value_of(const char *name)
{
    vpiHandle h = var(name);
    s_vpi_value v;

    if (h == NULL)
        return -1;
    v.format = vpiIntVal;
    vpi_get_value(h, &v);
    return (int)v.value.integer;
}

static void register_time_cb(PLI_INT32 reason, PLI_INT32 (*rtn)(p_cb_data), int at)
{
    s_cb_data cb;
    s_vpi_time t;

    memset(&cb, 0, sizeof cb);
    memset(&t, 0, sizeof t);
    t.type = vpiSimTime;
    t.low = (PLI_UINT32)at;
    cb.reason = reason;
    cb.cb_rtn = rtn;
    cb.time = &t;
    if (vpi_register_cb(&cb) == NULL)
        vpi_printf("callback %d could not be registered\n", (int)reason);
}

/* Pre-Active of 10: before any event of the slot. */
static PLI_INT32 on_start(p_cb_data cb)
{
    vpi_printf("cbAtStartOfSimTime at %d: v=%d w=%d\n", (int)cb->time->low,
               value_of("v"), value_of("w"));
    return 0;
}

/* Pre-Active of the next slot, registered from the Pre-Postponed region of 10. */
static PLI_INT32 on_next(p_cb_data cb)
{
    vpi_printf("cbNextSimTime at %d: v=%d w=%d\n", (int)cb->time->low,
               value_of("v"), value_of("w"));
    return 0;
}

/* Pre-Postponed of 10: writes w = 1, which makes the slot iterate again. */
static PLI_INT32 on_end(p_cb_data cb)
{
    vpiHandle w = var("w");
    s_vpi_value val;

    vpi_printf("cbAtEndOfSimTime at %d: v=%d clk=%d, writes w=1\n", (int)cb->time->low,
               value_of("v"), value_of("clk"));
    register_time_cb(cbNextSimTime, on_next, 0);
    if (w == NULL)
        return 0;
    val.format = vpiIntVal;
    val.value.integer = 1;
    vpi_put_value(w, &val, NULL, vpiNoDelay);
    return 0;
}

/* Postponed of 10: only reads. */
static PLI_INT32 on_read_only(p_cb_data cb)
{
    vpi_printf("cbReadOnlySynch at %d: v=%d w=%d clk=%d\n", (int)cb->time->low,
               value_of("v"), value_of("w"), value_of("clk"));
    return 0;
}

static PLI_INT32 register_calltf(PLI_BYTE8 *user_data)
{
    (void)user_data;
    register_time_cb(cbAtStartOfSimTime, on_start, 10);
    register_time_cb(cbAtEndOfSimTime, on_end, 10);
    register_time_cb(cbReadOnlySynch, on_read_only, 10);
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
