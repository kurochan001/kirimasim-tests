/* Observe several independent VPI objects before and after their lifetime ends. */
#include <stddef.h>
#include "sv_vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

#if defined(vpiThread) && defined(vpiSchedEvent) && defined(vpiReturnEvent)
#define TOP "test_vpi_other_transient_objects"

static vpiHandle thread_handle;
static vpiHandle event_handle;
static vpiHandle target;
static int removed_calls, kept_calls, thread_ends;
static s_vpi_time timer = {vpiSimTime, 0, 3, 0.0};
static s_vpi_time suppress_time = {vpiSuppressTime, 0, 0, 0.0};
static s_vpi_value suppress_value;

static int read_value(vpiHandle object)
{
    if (!object)
        return -1;
    s_vpi_value value = {0};
    value.format = vpiIntVal;
    vpi_get_value(object, &value);
    return value.value.integer;
}

static int has_type(vpiHandle object, PLI_INT32 kind)
{
    return object && vpi_get(vpiType, object) == kind;
}

static PLI_INT32 count_timer(p_cb_data event)
{
    int *calls = (int *)event->user_data;
    ++*calls;
    return 0;
}

static PLI_INT32 end_thread(p_cb_data event)
{
    const int same = event->obj && thread_handle && vpi_compare_objects(event->obj, thread_handle);
    const int frame_present = event->obj && vpi_handle(vpiFrame, event->obj) != NULL;
    vpi_printf("thread ending type=%d identity=%d frame=%d\n",
               has_type(event->obj, vpiThread), same, frame_present);
    thread_handle = NULL;
    ++thread_ends;
    return 0;
}

static vpiHandle subscribe(PLI_INT32 reason, vpiHandle object, s_vpi_time *time,
                           PLI_INT32 (*invoke)(p_cb_data), int *calls)
{
    s_cb_data request = {0};
    request.reason = reason;
    request.obj = object;
    request.time = time;
    request.value = &suppress_value;
    request.cb_rtn = invoke;
    request.user_data = (PLI_BYTE8 *)calls;
    return vpi_register_cb(&request);
}

static int is_pending(void)
{
    return event_handle ? vpi_get(vpiScheduled, event_handle) : -1;
}

static void arm(vpiHandle thread)
{
    thread_handle = thread;
    target = vpi_handle_by_name((PLI_BYTE8 *)TOP ".target", NULL);
    s_vpi_value value = {0};
    value.format = vpiIntVal;
    value.value.integer = 91;
    event_handle = target ? vpi_put_value(target, &value, &timer, vpiPureTransportDelay | vpiReturnEvent) : NULL;
    vpi_printf("scheduled event type=%d pending=%d target=%d\n",
               has_type(event_handle, vpiSchedEvent), is_pending(), read_value(target));

    suppress_value.format = vpiSuppressVal;
    vpiHandle removed = subscribe(cbAfterDelay, NULL, &timer, count_timer, &removed_calls);
    vpiHandle kept = subscribe(cbAfterDelay, NULL, &timer, count_timer, &kept_calls);
    const int removed_typed = has_type(removed, vpiCallback);
    const int kept_typed = has_type(kept, vpiCallback);
    const int distinct = removed && kept && !vpi_compare_objects(removed, kept);
    const int cancelled = removed && vpi_remove_cb(removed);
    vpiHandle on_end = thread ? subscribe(cbEndOfThread, thread, &suppress_time, end_thread, NULL) : NULL;
    vpi_printf("callbacks type=%d/%d distinct=%d removed=%d end=%d\n",
               removed_typed, kept_typed, distinct, cancelled, has_type(on_end, vpiCallback));
}

static int source_values(vpiHandle frame, int *scoped)
{
    const vpiHandle origin = frame ? vpi_handle(vpiOrigin, frame) : NULL;
    const vpiHandle args = origin ? vpi_iterate(vpiArgument, origin) : NULL;
    const vpiHandle element = args ? vpi_scan(args) : NULL;
    if (!element)
        return -1;
    const vpiHandle local = vpi_scan(args);
    if (local) {
        *scoped = read_value(local);
        vpi_release_handle(args);
    }
    return read_value(element);
}

static PLI_INT32 sample(PLI_BYTE8 *unused)
{
    (void)unused;
    const vpiHandle call = vpi_handle(vpiSysTfCall, NULL);
    const vpiHandle args = call ? vpi_iterate(vpiArgument, call) : NULL;
    const int iterator = has_type(args, vpiIterator);
    const vpiHandle first = args ? vpi_scan(args) : NULL;
    const vpiHandle second = first ? vpi_scan(args) : NULL;
    if (!first || !second) {
        vpi_printf("missing transient probe arguments\n");
        return 0;
    }
    const int phase = read_value(first);
    const int actual = read_value(second);
    const int last = vpi_scan(args) == NULL;
    if (!last)
        vpi_release_handle(args);
    vpi_printf("iterator phase=%d typed=%d terminal=%d\n", phase, iterator, last);

    if (phase == 1 || phase == 2) {
        const vpiHandle frame = vpi_handle(vpiFrame, NULL);
        const vpiHandle thread = frame ? vpi_handle(vpiThread, frame) : NULL;
        int scoped = -1;
        const int outer = source_values(frame, &scoped);
        vpi_printf("references phase=%d frame=%d thread=%d holder=%d outer=%d scoped=%d\n",
                   phase, has_type(frame, vpiFrame), has_type(thread, vpiThread), actual, outer, scoped);
        if (phase == 1)
            arm(thread);
        else
            vpi_printf("before delivery pending=%d target=%d\n", is_pending(), read_value(target));
    } else if (phase == 3) {
        const int active_frame = thread_handle && vpi_handle(vpiFrame, thread_handle) != NULL;
        vpi_printf("after scope thread=%d frame=%d outer=%d\n",
                   has_type(thread_handle, vpiThread), active_frame, actual);
        vpi_printf("after delivery pending=%d target=%d removed=%d kept=%d\n",
                   is_pending(), read_value(target), removed_calls, kept_calls);
        const int released = event_handle && vpi_release_handle(event_handle);
        event_handle = NULL;
        vpi_printf("event handle released=%d\n", released);
    } else {
        vpi_printf("after join thread end=%d outer=%d target=%d\n",
                   thread_ends, actual, read_value(target));
    }
    return 0;
}
#else
static PLI_INT32 sample(PLI_BYTE8 *unused)
{
    (void)unused;
    vpi_printf("transient VPI declarations unavailable\n");
    return 0;
}
#endif

static void install(void)
{
    s_vpi_systf_data task = {0};
    task.type = vpiSysTask;
    task.tfname = (PLI_BYTE8 *)"$vt_transient_sample";
    task.calltf = sample;
    vpi_register_systf(&task);
}

void (*vlog_startup_routines[])(void) = {install, NULL};

#ifdef __cplusplus
}
#endif
