#include <stddef.h>
#include "vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

static PLI_INT32 unexpected_read_write(p_cb_data data)
{
    (void)data;
    vpi_printf("unexpected same-time read-write callback\n");
    return 0;
}

static PLI_INT32 read_only(p_cb_data data)
{
    static s_vpi_time zero = {vpiSimTime, 0, 0, 0.0};
    s_cb_data attempt = {0};
    (void)data;

    attempt.reason = cbReadWriteSynch;
    attempt.cb_rtn = unexpected_read_write;
    attempt.time = &zero;
    vpi_printf("read_only=1 rejected=%d\n", vpi_register_cb(&attempt) == NULL);
    return 0;
}

static PLI_INT32 schedule(p_cb_data data)
{
    static s_vpi_time at_two = {vpiSimTime, 0, 2, 0.0};
    s_cb_data callback = {0};
    (void)data;

    callback.reason = cbReadOnlySynch;
    callback.cb_rtn = read_only;
    callback.time = &at_two;
    vpi_register_cb(&callback);
    return 0;
}

static void register_check(void)
{
    s_cb_data callback = {0};
    callback.reason = cbStartOfSimulation;
    callback.cb_rtn = schedule;
    vpi_register_cb(&callback);
}

void (*vlog_startup_routines[])(void) = {register_check, NULL};

#ifdef __cplusplus
}
#endif
