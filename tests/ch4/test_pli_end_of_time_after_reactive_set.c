/* VPI application of test_pli_end_of_time_after_reactive_set
   (IEEE 1800-2023 4.10, 4.4.3.9, 4.4.3.10, 38.36.2). */
#include <stdio.h>
#include <string.h>
#include "vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

static vpiHandle var(const char *name)
{
    char full[96];

    snprintf(full, sizeof full, "test_pli_end_of_time_after_reactive_set.%s", name);
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

/* cbAtEndOfSimTime at 10: reads, then writes w = 4 with vpiNoDelay. */
static PLI_INT32 on_end(p_cb_data cb)
{
    vpiHandle w = var("w");
    s_vpi_value v;

    vpi_printf("cbAtEndOfSimTime at %d: b=%d p=%d q=%d, writes w=4\n", (int)cb->time->low,
               value_of("b"), value_of("p"), value_of("q"));
    if (w == NULL)
        return 0;
    v.format = vpiIntVal;
    v.value.integer = 4;
    vpi_put_value(w, &v, NULL, vpiNoDelay);
    return 0;
}

/* cbReadOnlySynch at 10: only reads. */
static PLI_INT32 on_read_only(p_cb_data cb)
{
    vpi_printf("cbReadOnlySynch at %d: w=%d c=%d r=%d\n", (int)cb->time->low, value_of("w"),
               value_of("c"), value_of("r"));
    return 0;
}

static void register_at_10(PLI_INT32 reason, PLI_INT32 (*rtn)(p_cb_data))
{
    s_cb_data cb;
    s_vpi_time t;

    memset(&cb, 0, sizeof cb);
    memset(&t, 0, sizeof t);
    t.type = vpiSimTime;
    t.low = 10;
    cb.reason = reason;
    cb.cb_rtn = rtn;
    cb.time = &t;
    if (vpi_register_cb(&cb) == NULL)
        vpi_printf("callback %d could not be registered\n", (int)reason);
}

static PLI_INT32 register_calltf(PLI_BYTE8 *user_data)
{
    (void)user_data;
    register_at_10(cbAtEndOfSimTime, on_end);
    register_at_10(cbReadOnlySynch, on_read_only);
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
