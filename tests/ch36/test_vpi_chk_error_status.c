/* VPI application of test_vpi_chk_error_status (IEEE 1800-2023 36.10.1, 38.2). */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

static PLI_INT32 ignore(p_cb_data cb)
{
    (void)cb;
    return 0;
}

/* A cbAfterDelay callback whose time type is vpiSuppressTime (38.36.2). */
static void register_suppressed(void)
{
    s_cb_data cb;
    s_vpi_time t;

    memset(&cb, 0, sizeof cb);
    memset(&t, 0, sizeof t);
    t.type = vpiSuppressTime;
    t.low = 1;
    cb.reason = cbAfterDelay;
    cb.cb_rtn = ignore;
    cb.time = &t;
    vpi_register_cb(&cb);
}

static const char *yes_no(int b) { return b ? "yes" : "no"; }

static PLI_INT32 try_calltf(PLI_BYTE8 *user_data)
{
    vpiHandle call = vpi_handle(vpiSysTfCall, NULL);
    s_vpi_error_info info;
    s_vpi_time now;
    PLI_INT32 level, after_time, first, second, after_get;

    (void)user_data;
    memset(&info, 0, sizeof info);
    register_suppressed();
    level = vpi_chk_error(&info);
    now.type = vpiSimTime;
    vpi_get_time(NULL, &now);
    after_time = vpi_chk_error(NULL);

    register_suppressed();
    first = vpi_chk_error(NULL);
    second = vpi_chk_error(NULL);
    vpi_get(vpiType, call);
    after_get = vpi_chk_error(NULL);

    vpi_printf("vpiSuppressTime: error %s, a level of Table 38-1: %s, the same in the "
               "structure: %s\n", yes_no(level != 0),
               yes_no(level >= vpiNotice && level <= vpiInternal), yes_no(info.level == level));
    vpi_printf("after a vpi_get_time that succeeded: error %s\n", yes_no(after_time != 0));
    vpi_printf("again: error %s, still after vpi_chk_error: %s, after a vpi_get that "
               "succeeded: %s\n", yes_no(first != 0), yes_no(second != 0),
               yes_no(after_get != 0));
    return 0;
}

static void register_systf(void)
{
    s_vpi_systf_data tf;

    memset(&tf, 0, sizeof tf);
    tf.type = vpiSysTask;
    tf.tfname = (PLI_BYTE8 *)"$vt_try";
    tf.calltf = try_calltf;
    vpi_register_systf(&tf);
}

void (*vlog_startup_routines[])(void) = {register_systf, 0};

#ifdef __cplusplus
}
#endif
