#include <stddef.h>
#include <string.h>
#include "vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

enum { TRACE_CAPACITY = 4, SAMPLED_TICKS = 3 };

struct trace {
    size_t count;
    PLI_INT32 values[TRACE_CAPACITY];
};

static struct trace traces[SAMPLED_TICKS];
static s_vpi_time event_time;
static s_vpi_value event_value;
static int timezero_case;
static int capture_failed;

static PLI_INT32 observe_resolution(p_cb_data event)
{
    if (event->time == NULL || event->time->type != vpiSimTime ||
        event->value == NULL || event->value->format != vpiIntVal) {
        capture_failed = 1;
        return 0;
    }
    if (event->time->high != 0 || event->time->low >= SAMPLED_TICKS)
        return 0;

    struct trace *trace = &traces[event->time->low];
    PLI_INT32 value = event->value->value.integer;
    if (trace->count != 0 && trace->values[trace->count - 1] == value)
        return 0;
    if (trace->count == TRACE_CAPACITY)
        capture_failed = 1;
    else
        trace->values[trace->count++] = value;
    return 0;
}

static size_t skip_value(const struct trace *trace, size_t start, PLI_INT32 value)
{
    return start < trace->count && trace->values[start] == value ? start + 1 : start;
}

static int reaches_final(const struct trace *trace, size_t start,
                         PLI_INT32 first_only, PLI_INT32 second_only, PLI_INT32 final)
{
    // A second evaluation can expose one intermediate sum. An evaluation
    // that returns the current value cannot be counted from net transitions.
    if (trace->count == start + 2 &&
        (trace->values[start] == first_only || trace->values[start] == second_only))
        ++start;
    return trace->count == start + 1 && trace->values[start] == final;
}

static int requested_trace(void)
{
    s_vpi_vlog_info info = {0};
    if (vpi_get_vlog_info(&info)) {
        for (int index = 0; index < info.argc; ++index)
            if (strcmp(info.argv[index], "+resolver_trace") == 0)
                return 1;
    }
    return 0;
}

static void print_trace(unsigned tick)
{
    const struct trace *trace = &traces[tick];
    vpi_printf("tick %u:", tick);
    for (size_t i = 0; i < trace->count; ++i)
        vpi_printf(" %d", (int)trace->values[i]);
    vpi_printf("\n");
}

static PLI_INT32 check_history(PLI_BYTE8 *unused)
{
    (void)unused;
    int valid;

    if (timezero_case) {
        // Initialization to 0 and an evaluation before either driver changes
        // can both precede the driver-dependent sums. Either may be absent
        // from observed transitions.
        size_t start = skip_value(&traces[0], 0, 0);
        start = skip_value(&traces[0], start, 100);
        valid = !capture_failed && reaches_final(&traces[0], start, 102, 103, 105);
        vpi_printf("time-zero history permitted=%d\n", valid);
        if (!valid || requested_trace())
            print_trace(0);
    } else {
        valid = !capture_failed && reaches_final(&traces[1], 0, 110, 113, 118);
        // The same observer must see the distinct resolved values across #0.
        int control = !capture_failed && traces[2].count == 2 &&
                      traces[2].values[0] == 124 && traces[2].values[1] == 130;
        vpi_printf("same-region history permitted=%d\n", valid);
        vpi_printf("separate-regions control=%d\n", control);
        if (!valid || !control || requested_trace()) {
            print_trace(1);
            print_trace(2);
        }
    }
    return 0;
}

static PLI_INT32 start_watch(p_cb_data unused)
{
    (void)unused;
    vpiHandle net = vpi_handle_by_name((PLI_BYTE8 *)"test_user_net_timezero_order.resolved", NULL);
    timezero_case = net != NULL;
    if (net == NULL)
        net = vpi_handle_by_name((PLI_BYTE8 *)"test_user_net_same_region_resolution.resolved", NULL);

    s_cb_data watcher = {0};
    event_time.type = vpiSimTime;
    event_value.format = vpiIntVal;
    watcher.reason = cbValueChange;
    watcher.cb_rtn = observe_resolution;
    watcher.obj = net;
    watcher.time = &event_time;
    watcher.value = &event_value;
    if (net == NULL || vpi_register_cb(&watcher) == NULL)
        capture_failed = 1;
    return 0;
}

static void register_history(void)
{
    s_cb_data end_compile = {0};
    end_compile.reason = cbEndOfCompile;
    end_compile.cb_rtn = start_watch;
    vpi_register_cb(&end_compile);

    s_vpi_systf_data task = {0};
    task.type = vpiSysTask;
    task.tfname = (PLI_BYTE8 *)"$vt_check_resolver_history";
    task.calltf = check_history;
    vpi_register_systf(&task);
}

void (*vlog_startup_routines[])(void) = {register_history, NULL};

#ifdef __cplusplus
}
#endif
