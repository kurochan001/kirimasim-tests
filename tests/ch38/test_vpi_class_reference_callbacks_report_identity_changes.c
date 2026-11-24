#include <stddef.h>
#include "vpi_user.h"
#include "sv_vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

enum { CAPACITY = 10 };

struct observation {
    unsigned tick;
    const char *identity;
    int opaque;
    int same_handle;
};

static vpiHandle watched;
static PLI_INT64 first_identity, second_identity;
static int change_count, pulse_count;
static struct observation changes[CAPACITY];

static PLI_INT64 identity(vpiHandle handle)
{
    return handle != NULL ? vpi_get64(vpiObjId, handle) : -1;
}

static const char *describe_identity(PLI_INT64 id)
{
    if (id == 0)
        return "null";
    if (id == first_identity)
        return "first";
    if (id == second_identity)
        return "second";
    return "new";
}

static PLI_INT32 record_class_change(p_cb_data data)
{
    if (change_count < CAPACITY) {
        struct observation *event = &changes[change_count];
        event->tick = data->time != NULL ? data->time->low : 0;
        event->identity = describe_identity(identity(data->obj));
        event->opaque = data->value == NULL;
        event->same_handle = data->obj != NULL && vpi_compare_objects(watched, data->obj);
    }
    ++change_count;
    return 0;
}

static PLI_INT32 count_pulse(p_cb_data data)
{
    (void)data;
    ++pulse_count;
    return 0;
}

static int watch(vpiHandle object, PLI_INT32 (*callback)(p_cb_data), p_vpi_value value)
{
    s_cb_data data = {0};
    s_vpi_time timestamp = {0};
    if (object == NULL)
        return 0;
    timestamp.type = vpiSimTime;
    data.reason = cbValueChange;
    data.cb_rtn = callback;
    data.obj = object;
    data.time = &timestamp;
    data.value = value;
    return vpi_register_cb(&data) != NULL;
}

static PLI_INT32 start(PLI_BYTE8 *unused)
{
    const char *top_name = "test_vpi_class_reference_callbacks_report_identity_changes";
    vpiHandle top = vpi_handle_by_name((PLI_BYTE8 *)top_name, NULL);
    s_vpi_value requested = {0};
    int class_registered, pulse_registered;
    (void)unused;
    if (top == NULL) {
        vpi_printf("top not found\n");
        return 0;
    }

    watched = vpi_handle_by_name("picked", top);
    first_identity = identity(vpi_handle_by_name("first_ref", top));
    second_identity = identity(vpi_handle_by_name("second_ref", top));
    requested.format = vpiObjTypeVal;
    class_registered = watch(watched, record_class_change, &requested);
    pulse_registered = watch(vpi_handle_by_name("pulse", top), count_pulse, NULL);
    vpi_printf("start class-kind=%d distinct-ids=%d registered=%d/%d\n",
               watched != NULL && vpi_get(vpiType, watched) == vpiClassVar,
               first_identity > 0 && second_identity > 0 && first_identity != second_identity,
               class_registered, pulse_registered);
    return 0;
}

static PLI_INT32 report(PLI_BYTE8 *unused)
{
    (void)unused;
    vpi_printf("changes=%d pulses=%d\n", change_count, pulse_count);
    for (int i = 0; i < change_count && i < CAPACITY; ++i) {
        struct observation *event = &changes[i];
        vpi_printf("t=%u identity=%s opaque=%d same-handle=%d\n",
                   event->tick, event->identity, event->opaque, event->same_handle);
    }
    return 0;
}

static void register_tasks(void)
{
    s_vpi_systf_data task = {0};
    task.type = vpiSysTask;
    task.tfname = (PLI_BYTE8 *)"$watch_class_reference";
    task.calltf = start;
    vpi_register_systf(&task);
    task.tfname = (PLI_BYTE8 *)"$report_class_reference";
    task.calltf = report;
    vpi_register_systf(&task);
}

void (*vlog_startup_routines[])(void) = {register_tasks, NULL};

#ifdef __cplusplus
}
#endif
