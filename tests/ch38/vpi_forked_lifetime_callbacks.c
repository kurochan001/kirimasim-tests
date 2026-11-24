/* Check end callbacks on two automatic frames and their separate forked threads. */
#include <string.h>
#include "vpi_user.h"
#include "sv_vpi_user.h"

struct lifetime {
    vpiHandle frame, thread;
    int frame_calls, object_calls, thread_calls, thread_object_calls;
    int frame_value, object_value, frame_time, thread_time;
    int matching_handles, ordered, object_time_null, thread_object_time_null;
    int object_only;
};

static struct lifetime lifetimes[2];
static s_vpi_time sim_time = {.type = vpiSimTime};

static int local_value(vpiHandle frame)
{
    vpiHandle iter = vpi_iterate(vpiAutomatics, frame);
    vpiHandle item;
    int result = -1;
    while (iter && (item = vpi_scan(iter))) {
        const char *name = vpi_get_str(vpiName, item);
        if (name && strcmp(name, "local_value") == 0) {
            s_vpi_value value = {.format = vpiIntVal};
            vpi_get_value(item, &value);
            result = (int)value.value.integer;
        }
    }
    return result;
}

static PLI_INT32 observe_end(p_cb_data data)
{
    struct lifetime *event = (struct lifetime *)data->user_data;
    const int is_thread = data->reason == cbEndOfThread ||
        (data->reason == cbEndOfObject && data->obj && vpi_get(vpiType, data->obj) == vpiThread);
    vpiHandle expected = is_thread ? event->thread : event->frame;
    event->matching_handles &= data->obj && vpi_compare_objects(data->obj, expected);
    switch (data->reason) {
    case cbEndOfFrame:
        ++event->frame_calls;
        event->frame_value = data->obj ? local_value(data->obj) : -1;
        event->frame_time = data->time ? (int)data->time->low : -1;
        break;
    case cbEndOfObject:
        if (is_thread) {
            ++event->thread_object_calls;
            event->thread_object_time_null = data->time == NULL;
            event->ordered = event->object_calls == 1;
        } else {
            ++event->object_calls;
            event->object_value = data->obj ? local_value(data->obj) : -1;
            event->object_time_null = data->time == NULL;
        }
        break;
    case cbEndOfThread:
        ++event->thread_calls;
        event->thread_time = data->time ? (int)data->time->low : -1;
        event->ordered = event->frame_calls == 1;
        break;
    }
    return 0;
}

static int subscribe(PLI_INT32 reason, vpiHandle object, struct lifetime *event)
{
    if (!object)
        return 0;
    s_cb_data callback = {
        .reason = reason,
        .cb_rtn = observe_end,
        .obj = object,
        .time = &sim_time,
        .user_data = (PLI_BYTE8 *)event,
    };
    return vpi_register_cb(&callback) != NULL;
}

static PLI_INT32 track_frame(PLI_BYTE8 *unused)
{
    (void)unused;
    s_vpi_value value = {.format = vpiIntVal};
    vpiHandle args = vpi_iterate(vpiArgument, vpi_handle(vpiSysTfCall, NULL));
    vpiHandle index_arg = args ? vpi_scan(args) : NULL;
    vpiHandle object_arg = index_arg ? vpi_scan(args) : NULL;
    if (!object_arg) {
        vpi_printf("missing lifetime arguments\n");
        return 0;
    }
    vpi_free_object(args);
    vpi_get_value(index_arg, &value);
    int index = (int)value.value.integer;
    if (index < 0 || index >= 2) {
        vpi_printf("unexpected lifetime index\n");
        return 0;
    }
    vpi_get_value(object_arg, &value);
    struct lifetime *event = &lifetimes[index];
    event->object_only = value.value.integer != 0;
    event->frame = vpi_handle(vpiFrame, NULL);
    event->thread = event->frame ? vpi_handle(vpiThread, event->frame) : NULL;
    event->matching_handles = 1;

    int registered;
    if (event->object_only) {
        registered = subscribe(cbEndOfObject, event->frame, event) &&
            subscribe(cbEndOfObject, event->thread, event);
    } else {
        registered = subscribe(cbEndOfFrame, event->frame, event) &&
            subscribe(cbEndOfThread, event->thread, event);
    }
    if (!registered)
        vpi_printf("could not register lifecycle callbacks for %d\n", index);
    return 0;
}

static PLI_INT32 report_frames(PLI_BYTE8 *unused)
{
    (void)unused;
    for (int i = 0; i < 2; ++i) {
        struct lifetime *event = &lifetimes[i];
        if (event->object_only) {
            vpi_printf("frame %d object-calls=%d/%d value=%d identity=%d "
                       "time-null=%d/%d frame-before-thread=%d\n",
                       i, event->object_calls, event->thread_object_calls,
                       event->object_value, event->matching_handles,
                       event->object_time_null, event->thread_object_time_null, event->ordered);
        } else {
            vpi_printf("frame %d calls=%d/%d value=%d times=%d/%d identity=%d frame-before-thread=%d\n",
                       i, event->frame_calls, event->thread_calls, event->frame_value,
                       event->frame_time, event->thread_time, event->matching_handles, event->ordered);
        }
    }
    return 0;
}

static void register_tests(void)
{
    s_vpi_systf_data track = {.type = vpiSysTask, .tfname = "$vt_track_frame", .calltf = track_frame};
    s_vpi_systf_data report = {.type = vpiSysTask, .tfname = "$vt_report_frames", .calltf = report_frames};
    vpi_register_systf(&track);
    vpi_register_systf(&report);
}

void (*vlog_startup_routines[])(void) = {register_tests, NULL};
