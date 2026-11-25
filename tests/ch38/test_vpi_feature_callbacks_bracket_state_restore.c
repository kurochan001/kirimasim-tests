#include <stddef.h>
#include "checkpoint_fixtures/action_callback.h"

#ifdef __cplusplus
extern "C" {
#endif

struct feature_event {
    PLI_INT32 reason;
    const char *name;
};

static struct feature_event events[] = {
    {cbStartOfSave, "start save"},
    {cbEndOfSave, "end save"},
    {cbStartOfRestart, "start restart"},
    {cbEndOfRestart, "end restart"},
};

static PLI_INT32 report(p_cb_data data)
{
    const struct feature_event *event = (const struct feature_event *)data->user_data;
    if (event)
        vpi_printf("feature %s reason=%d\n", event->name, event->reason == data->reason);
    else
        vpi_printf("feature callback without registration data\n");
    return 0;
}

static void install(void)
{
    for (unsigned index = 0; index < sizeof events / sizeof *events; ++index) {
        if (!register_action(events[index].reason, report, &events[index]))
            vpi_printf("feature %s registration unavailable\n", events[index].name);
    }
}

void (*vlog_startup_routines[])(void) = {install, NULL};

#ifdef __cplusplus
}
#endif
