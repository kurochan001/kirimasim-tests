/* VPI application of test_pli_callbacks_are_evaluation_events (IEEE 1800-2023 4.3, 4.10, 38.36.2). */
#include <string.h>
#include "vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

#define TOP "test_pli_callbacks_are_evaluation_events"

static int value_of(const char *name)
{
    vpiHandle h = vpi_handle_by_name((PLI_BYTE8 *)name, NULL);
    s_vpi_value v;

    if (h == NULL)
        return -1;
    v.format = vpiIntVal;
    vpi_get_value(h, &v);
    return (int)v.value.integer;
}

static int now(void)
{
    s_vpi_time t;

    t.type = vpiSimTime;
    vpi_get_time(NULL, &t);
    return (int)t.low;
}

static PLI_INT32 on_after_delay(p_cb_data cb)
{
    vpiHandle w = vpi_handle_by_name((PLI_BYTE8 *)TOP ".w", NULL);
    s_vpi_value val;

    (void)cb;
    vpi_printf((PLI_BYTE8 *)"cbAfterDelay at %d: v=%d n=%d, writes w=7\n", now(),
               value_of(TOP ".v"), value_of(TOP ".n"));
    if (w == NULL)
        return 0;
    val.format = vpiIntVal;
    val.value.integer = 7;
    vpi_put_value(w, &val, NULL, vpiNoDelay);
    return 0;
}

/* Pre-NBA or Post-NBA: only v, which the Active region set, is printed. */
static PLI_INT32 on_read_write(p_cb_data cb)
{
    (void)cb;
    vpi_printf((PLI_BYTE8 *)"cbReadWriteSynch at %d: v=%d\n", now(), value_of(TOP ".v"));
    return 0;
}

static PLI_INT32 on_read_only(p_cb_data cb)
{
    (void)cb;
    vpi_printf((PLI_BYTE8 *)"cbReadOnlySynch at %d: v=%d n=%d w=%d\n", now(),
               value_of(TOP ".v"), value_of(TOP ".n"), value_of(TOP ".w"));
    return 0;
}

static void register_at_5(PLI_INT32 reason, PLI_INT32 (*routine)(p_cb_data))
{
    s_cb_data cb;
    s_vpi_time t;

    memset(&cb, 0, sizeof cb);
    memset(&t, 0, sizeof t);
    t.type = vpiSimTime;
    t.low = 5;
    cb.reason = reason;
    cb.cb_rtn = routine;
    cb.time = &t;
    if (vpi_register_cb(&cb) == NULL)
        vpi_printf((PLI_BYTE8 *)"callback %d could not be registered\n", (int)reason);
}

static PLI_INT32 register_calltf(PLI_BYTE8 *user_data)
{
    (void)user_data;
    register_at_5(cbAfterDelay, on_after_delay);
    register_at_5(cbReadWriteSynch, on_read_write);
    register_at_5(cbReadOnlySynch, on_read_only);
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
