#include <stddef.h>
#include "vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

#define TOP "test_vpi_scalar_callbacks_keep_high_and_low_strength_states"
#define MAX_EVENTS 8

struct scalar_event {
    PLI_UINT32 tick;
    char value;
};

struct scalar_watch {
    const char *name;
    vpiHandle object;
    s_vpi_time requested_time;
    s_vpi_value requested_value;
    struct scalar_event events[MAX_EVENTS];
    int count;
};

static struct scalar_watch watches[] = {
    {.name = TOP ".high_ambiguous"},
    {.name = TOP ".low_ambiguous"},
    {.name = TOP ".ordinary"},
};

static char scalar_symbol(PLI_INT32 value)
{
    switch (value) {
    case vpi0: return '0';
    case vpi1: return '1';
    case vpiX: return 'X';
    case vpiZ: return 'Z';
    case vpiH: return 'H';
    case vpiL: return 'L';
    default: return '?';
    }
}

static PLI_INT32 on_value_change(p_cb_data data)
{
    struct scalar_watch *watch = (struct scalar_watch *)data->user_data;
    int index = watch->count++;
    if (index < MAX_EVENTS) {
        struct scalar_event *event = &watch->events[index];
        event->tick = data->time != NULL && data->time->type == vpiSimTime && data->time->high == 0
                      ? data->time->low : 0;
        event->value = data->value != NULL && data->value->format == vpiScalarVal
                       ? scalar_symbol(data->value->value.scalar) : '?';
    }
    return 0;
}

static PLI_INT32 start_watch(PLI_BYTE8 *unused)
{
    (void)unused;
    for (size_t i = 0; i < sizeof watches / sizeof watches[0]; ++i) {
        struct scalar_watch *watch = &watches[i];
        s_cb_data callback = {0};
        watch->object = vpi_handle_by_name((PLI_BYTE8 *)watch->name, NULL);
        watch->requested_time.type = vpiSimTime;
        watch->requested_value.format = vpiScalarVal;
        callback.reason = cbValueChange;
        callback.cb_rtn = on_value_change;
        callback.obj = watch->object;
        callback.time = &watch->requested_time;
        callback.value = &watch->requested_value;
        callback.user_data = (PLI_BYTE8 *)watch;
        if (watch->object == NULL || vpi_register_cb(&callback) == NULL)
            vpi_printf("watch %zu unavailable\n", i);
    }
    return 0;
}

static PLI_INT32 snapshot(PLI_BYTE8 *unused)
{
    (void)unused;
    vpi_printf("read:");
    for (size_t i = 0; i < sizeof watches / sizeof watches[0]; ++i) {
        s_vpi_value value = {0};
        value.format = vpiScalarVal;
        value.value.scalar = -1;
        if (watches[i].object != NULL) vpi_get_value(watches[i].object, &value);
        vpi_printf(" %c", value.format == vpiScalarVal ? scalar_symbol(value.value.scalar) : '?');
    }
    vpi_printf("\n");
    return 0;
}

static PLI_INT32 report(PLI_BYTE8 *unused)
{
    (void)unused;
    for (size_t i = 0; i < sizeof watches / sizeof watches[0]; ++i) {
        const struct scalar_watch *watch = &watches[i];
        vpi_printf("watch %zu (%d):", i, watch->count);
        for (int j = 0; j < watch->count && j < MAX_EVENTS; ++j)
            vpi_printf(" %u=%c", (unsigned)watch->events[j].tick, watch->events[j].value);
        vpi_printf("\n");
    }
    return 0;
}

static void register_task(const char *name, PLI_INT32 (*call)(PLI_BYTE8 *))
{
    s_vpi_systf_data task = {0};
    task.type = vpiSysTask;
    task.tfname = (PLI_BYTE8 *)name;
    task.calltf = call;
    vpi_register_systf(&task);
}

static void register_all(void)
{
    register_task("$vt_start_scalar_watch", start_watch);
    register_task("$vt_scalar_snapshot", snapshot);
    register_task("$vt_report_scalar_watch", report);
}

void (*vlog_startup_routines[])(void) = {register_all, NULL};

#ifdef __cplusplus
}
#endif
