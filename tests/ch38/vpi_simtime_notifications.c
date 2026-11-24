/* Compare both time words for relative timer and value-change notifications. */
#include <stddef.h>
#include "vpi_user.h"

#define LIMIT 3

struct observations {
    const char *name;
    unsigned count;
    s_vpi_time notified[LIMIT];
    s_vpi_time queried[LIMIT];
};

static struct observations timer_carry = {.name = "timer-carry"};
static struct observations timer_high = {.name = "timer-high"};
static struct observations timer_next = {.name = "timer-next-word"};
static struct observations early_change = {.name = "early-change"};
static struct observations late_change = {.name = "late-change"};
static struct observations direct_change = {.name = "direct-change"};

static s_vpi_time delay_carry = {.type = vpiSimTime, .high = 0, .low = 4294967291U};
static s_vpi_time delay_high = {.type = vpiSimTime, .high = 1, .low = 3};
static s_vpi_time delay_next = {.type = vpiSimTime, .high = 1, .low = 4294967291U};
static s_vpi_time callback_time = {.type = vpiSimTime};
static s_vpi_value no_value = {.format = vpiSuppressVal};

static PLI_INT32 capture(p_cb_data data)
{
    struct observations *events = (struct observations *)data->user_data;
    unsigned index = events->count++;
    if (index < LIMIT) {
        if (data->time)
            events->notified[index] = *data->time;
        events->queried[index].type = vpiSimTime;
        vpi_get_time(NULL, &events->queried[index]);
    }
    return 0;
}

static void register_event(struct observations *events, PLI_INT32 reason,
                           vpiHandle target, s_vpi_time *when)
{
    s_cb_data callback = {
        .reason = reason,
        .cb_rtn = capture,
        .obj = target,
        .time = when,
        .value = &no_value,
        .user_data = (PLI_BYTE8 *)events,
    };
    if ((reason == cbValueChange && !target) || !vpi_register_cb(&callback))
        vpi_printf("could not register %s\n", events->name);
}

static vpiHandle arguments(void)
{
    vpiHandle call = vpi_handle(vpiSysTfCall, NULL);
    return call ? vpi_iterate(vpiArgument, call) : NULL;
}

static PLI_INT32 setup_timers(PLI_BYTE8 *unused)
{
    (void)unused;
    vpiHandle args = arguments();
    vpiHandle direct = args ? vpi_scan(args) : NULL;
    if (direct)
        vpi_free_object(args);

    register_event(&timer_carry, cbAfterDelay, NULL, &delay_carry);
    register_event(&timer_high, cbAfterDelay, NULL, &delay_high);
    register_event(&timer_next, cbAfterDelay, NULL, &delay_next);
    register_event(&direct_change, cbValueChange, direct, &callback_time);
    return 0;
}

static void schedule_one(vpiHandle target, PLI_UINT32 high, PLI_UINT32 low)
{
    s_vpi_value value = {.format = vpiIntVal, .value.integer = 1};
    s_vpi_time when = {.type = vpiSimTime, .high = high, .low = low};
    if (target)
        vpi_put_value(target, &value, &when, vpiTransportDelay);
}

static PLI_INT32 setup_puts(PLI_BYTE8 *unused)
{
    (void)unused;
    vpiHandle args = arguments();
    vpiHandle early = args ? vpi_scan(args) : NULL;
    vpiHandle late = early ? vpi_scan(args) : NULL;
    if (late)
        vpi_free_object(args);

    register_event(&early_change, cbValueChange, early, &callback_time);
    register_event(&late_change, cbValueChange, late, &callback_time);
    schedule_one(early, 0, 8);
    schedule_one(late, 1, 0);
    return 0;
}

static void print_events(const struct observations *events)
{
    vpi_printf("%s", events->name);
    for (unsigned i = 0; i < events->count && i < LIMIT; ++i) {
        const s_vpi_time *data = &events->notified[i];
        const s_vpi_time *now = &events->queried[i];
        if (data->type == vpiSimTime)
            vpi_printf(" %u:%u", (unsigned)data->high, (unsigned)data->low);
        else
            vpi_printf(" missing-time");
        vpi_printf(" current=%u:%u", (unsigned)now->high, (unsigned)now->low);
    }
    if (events->count > LIMIT)
        vpi_printf(" additional=%u", events->count - LIMIT);
    vpi_printf("\n");
}

static PLI_INT32 report_timers(PLI_BYTE8 *unused)
{
    (void)unused;
    print_events(&timer_carry);
    print_events(&timer_high);
    print_events(&timer_next);
    print_events(&direct_change);
    return 0;
}

static PLI_INT32 report_puts(PLI_BYTE8 *unused)
{
    (void)unused;
    print_events(&early_change);
    print_events(&late_change);
    return 0;
}

static void register_tests(void)
{
    static const struct {
        const char *name;
        PLI_INT32 (*routine)(PLI_BYTE8 *);
    } tasks[] = {
        {"$vt_high_time_setup", setup_timers},
        {"$vt_high_time_report", report_timers},
        {"$vt_high_put_setup", setup_puts},
        {"$vt_high_put_report", report_puts},
    };
    for (size_t i = 0; i < sizeof tasks / sizeof tasks[0]; ++i) {
        s_vpi_systf_data task = {
            .type = vpiSysTask, .tfname = (PLI_BYTE8 *)tasks[i].name,
            .calltf = tasks[i].routine,
        };
        vpi_register_systf(&task);
    }
}

void (*vlog_startup_routines[])(void) = {register_tests, NULL};
