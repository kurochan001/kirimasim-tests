#include <stddef.h>
#include <string.h>
#include "vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

static s_vpi_time zero_ticks = {vpiSimTime, 0, 0, 0.0};
static s_vpi_time two_ticks = {vpiSimTime, 0, 2, 0.0};
static s_vpi_time three_ticks = {vpiSimTime, 0, 3, 0.0};
static s_vpi_time five_ticks = {vpiSimTime, 0, 5, 0.0};
static s_vpi_time six_ticks = {vpiSimTime, 0, 6, 0.0};
static s_vpi_time eight_ticks = {vpiSimTime, 0, 8, 0.0};
static s_vpi_time distant_ticks = {vpiSimTime, 1, 29, 0.0};
static s_vpi_time ignored_ticks = {vpiSimTime, 1, 41, 0.0};
static s_vpi_time suppressed = {vpiSuppressTime, 0, 1, 0.0};

static vpiHandle schedule(PLI_INT32 reason, p_vpi_time when,
                          PLI_INT32 (*callback)(p_cb_data), const char *label)
{
    s_cb_data data;
    memset(&data, 0, sizeof data);
    data.reason = reason;
    data.cb_rtn = callback;
    data.time = when;
    data.user_data = (PLI_BYTE8 *)label;
    return vpi_register_cb(&data);
}

static PLI_INT32 record_time(p_cb_data callback)
{
    s_vpi_time time_now = {vpiSimTime, 0, 0, 0.0};
    vpi_get_time(NULL, &time_now);
    vpi_printf("%s time=%u:%u\n", callback->user_data,
               (unsigned)time_now.high, (unsigned)time_now.low);
    return 0;
}

static void check_rejection(PLI_INT32 reason, p_vpi_time when, const char *label)
{
    vpiHandle handle = schedule(reason, when, record_time, label);
    int error_reported = vpi_chk_error(NULL) >= vpiError;
    vpi_printf("%s rejected=%d vpi-error=%d\n", label, handle == NULL, error_reported);
    if (handle)
        vpi_remove_cb(handle);
}

static PLI_INT32 into_slice(p_cb_data event)
{
    record_time(event);
    check_rejection(cbAtStartOfSimTime, &zero_ticks, "late start");
    return 0;
}

static PLI_INT32 at_start(p_cb_data event)
{
    record_time(event);
    vpi_printf("same region registered=%d\n",
               schedule(cbAtStartOfSimTime, &zero_ticks, record_time, "same region") != NULL);
    return 0;
}

static PLI_INT32 at_read_only(p_cb_data event)
{
    record_time(event);
    check_rejection(cbReadWriteSynch, &zero_ticks, "read-only write");
    return 0;
}

static PLI_INT32 on_startup(p_cb_data unused)
{
    s_vpi_vlog_info info;
    int i;
    (void)unused;
    if (!vpi_get_vlog_info(&info))
        return 0;
    for (i = 0; i < info.argc; ++i) {
        const char *arg = info.argv[i];
        if (strcmp(arg, "+time_structure") == 0) {
            check_rejection(cbAfterDelay, NULL, "null time");
            check_rejection(cbAfterDelay, &suppressed, "suppressed time");
            vpi_printf("valid registered=%d\n",
                       schedule(cbAfterDelay, &two_ticks, record_time, "valid") != NULL);
            break;
        }
        if (strcmp(arg, "+time_late_start") == 0) {
            vpi_printf("registered in-slice=%d\n",
                       schedule(cbReadWriteSynch, &three_ticks, into_slice, "read write") != NULL);
            vpi_printf("registered start=%d\n",
                       schedule(cbAtStartOfSimTime, &six_ticks, at_start, "start region") != NULL);
            break;
        }
        if (strcmp(arg, "+time_reentrant") == 0) {
            vpi_printf("registered start=%d\n",
                       schedule(cbAtStartOfSimTime, &six_ticks, at_start, "start region") != NULL);
            break;
        }
        if (strcmp(arg, "+time_read_only") == 0) {
            vpi_printf("registered read-only=%d\n",
                       schedule(cbReadOnlySynch, &five_ticks, at_read_only, "read only") != NULL);
            vpi_printf("registered later read-write=%d\n",
                       schedule(cbReadWriteSynch, &eight_ticks, record_time, "later read-write") != NULL);
            break;
        }
        if (strcmp(arg, "+time_high_word") == 0) {
            vpi_printf("registered distant=%d\n",
                       schedule(cbAfterDelay, &distant_ticks, record_time, "distant") != NULL);
            vpi_printf("registered next=%d\n",
                       schedule(cbNextSimTime, &ignored_ticks, record_time, "next") != NULL);
            break;
        }
    }
    return 0;
}

static void register_startup(void)
{
    schedule(cbStartOfSimulation, NULL, on_startup, NULL);
}

void (*vlog_startup_routines[])(void) = {register_startup, NULL};

#ifdef __cplusplus
}
#endif
