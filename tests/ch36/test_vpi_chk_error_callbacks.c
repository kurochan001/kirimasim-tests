/* VPI application of test_vpi_chk_error_callbacks (IEEE 1800-2023 36.10.1, 38.2, 38.36.2). */
#include <stdio.h>
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

static vpiHandle try_cb(PLI_INT32 reason, int with_time, PLI_INT32 (*rtn)(p_cb_data))
{
    s_cb_data cb;
    s_vpi_time t;

    memset(&cb, 0, sizeof cb);
    memset(&t, 0, sizeof t);
    t.type = vpiSimTime;
    cb.reason = reason;
    cb.cb_rtn = rtn;
    cb.time = with_time ? &t : NULL;
    return vpi_register_cb(&cb);
}

static const char *yes_no(int b) { return b ? "yes" : "no"; }

static void report(const char *what, vpiHandle h)
{
    PLI_INT32 first = vpi_chk_error(NULL);
    PLI_INT32 second = vpi_chk_error(NULL);
    vpi_printf("%s: %s, error: %s, again: %s\n", what, h ? "registered" : "not registered",
               yes_no(first != 0), yes_no(second != 0));
}

static PLI_INT32 on_read_only(p_cb_data cb)
{
    vpiHandle h;

    (void)cb;
    h = try_cb(cbReadWriteSynch, 1, ignore);
    report("in cbReadOnlySynch, cbReadWriteSynch with delay 0", h);
    return 0;
}

static PLI_INT32 try_calltf(PLI_BYTE8 *user_data)
{
    vpiHandle h;

    (void)user_data;
    h = try_cb(cbReadWriteSynch, 0, ignore);
    report("cbReadWriteSynch without a time", h);
    h = try_cb(cbAtStartOfSimTime, 1, ignore);
    report("cbAtStartOfSimTime with delay 0 at 5", h);
    h = try_cb(cbReadOnlySynch, 1, on_read_only);
    report("cbReadOnlySynch with delay 0", h);
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
