/* IEEE 1800-2023 38.36.3: query error information in cbError. */
#include <stddef.h>
#include "vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

enum { CAPACITY = 2 };

struct observation {
    unsigned tick;
    int reason, severity, state, message;
};

static struct observation events[CAPACITY];
static int calls;

static PLI_INT32 on_error(p_cb_data callback)
{
    s_vpi_error_info info = {0};
    s_vpi_time time = {0};
    int severity = vpi_chk_error(&info);

    if (calls < CAPACITY) {
        struct observation *event = &events[calls];
        /* Copy the checks before another VPI call can invalidate strings. */
        event->reason = callback->reason == cbError;
        event->severity = severity >= vpiError && info.level == severity;
        event->state = info.state == vpiRun;
        event->message = info.message != NULL && info.message[0] != '\0';
        time.type = vpiSimTime;
        vpi_get_time(NULL, &time);
        event->tick = time.low;
    }
    calls++;
    return 0;
}

static PLI_INT32 finish(p_cb_data callback)
{
    (void)callback;
    vpi_printf("error actions=%d\n", calls);
    for (int i = 0; i < calls && i < CAPACITY; i++) {
        const struct observation *event = &events[i];
        vpi_printf("t=%u reason=%d severity=%d runtime=%d message=%d\n",
                   event->tick, event->reason, event->severity, event->state, event->message);
    }
    return 0;
}

static void register_all(void)
{
    s_cb_data callback = {0};
    callback.reason = cbError;
    callback.cb_rtn = on_error;
    vpi_register_cb(&callback);
    callback.reason = cbEndOfSimulation;
    callback.cb_rtn = finish;
    vpi_register_cb(&callback);
}

void (*vlog_startup_routines[])(void) = {register_all, NULL};

#ifdef __cplusplus
}
#endif
