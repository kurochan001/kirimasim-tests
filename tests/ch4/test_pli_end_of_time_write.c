/* VPI application of test_pli_end_of_time_write (IEEE 1800-2023 4.4.3.9, 38.36.2). */
#include <stdio.h>
#include <string.h>
#include "vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

static vpiHandle var(const char *name)
{
    return vpi_handle_by_name((PLI_BYTE8 *)name, NULL);
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

static int now(void)
{
    s_vpi_time t;
    t.type = vpiSimTime;
    vpi_get_time(NULL, &t);
    return (int)t.low;
}

static PLI_INT32 on_end(p_cb_data cb)
{
    vpiHandle w = var("test_pli_end_of_time_write.w");
    s_vpi_value val;

    (void)cb;
    vpi_printf("cbAtEndOfSimTime at %d: b=%d, writes w=3\n", now(),
               value_of("test_pli_end_of_time_write.b"));
    if (w == NULL)
        return 0;
    val.format = vpiIntVal;
    val.value.integer = 3;
    vpi_put_value(w, &val, NULL, vpiNoDelay);
    return 0;
}

static PLI_INT32 on_read_only(p_cb_data cb)
{
    (void)cb;
    vpi_printf("cbReadOnlySynch at %d: w=%d c=%d\n", now(),
               value_of("test_pli_end_of_time_write.w"), value_of("test_pli_end_of_time_write.c"));
    return 0;
}

static void place(PLI_INT32 reason, PLI_INT32 (*routine)(p_cb_data), const char *name)
{
    s_cb_data cb;
    s_vpi_time t;

    memset(&cb, 0, sizeof cb);
    memset(&t, 0, sizeof t);
    t.type = vpiSimTime;
    t.low = 10;
    cb.reason = reason;
    cb.cb_rtn = routine;
    cb.time = &t;
    if (vpi_register_cb(&cb) == NULL)
        vpi_printf("%s could not be registered\n", name);
}

static PLI_INT32 register_calltf(PLI_BYTE8 *user_data)
{
    (void)user_data;
    place(cbAtEndOfSimTime, on_end, "cbAtEndOfSimTime");
    place(cbReadOnlySynch, on_read_only, "cbReadOnlySynch");
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
