#include <stddef.h>
#include "sv_vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

#define TOP "test_vpi_assertion_initialization_callback_guards_controls"

struct watched_assertion {
    const char *name;
    unsigned first_tick;
    unsigned second_tick;
};

static struct watched_assertion early = {TOP ".early_target", 0, 0};
static struct watched_assertion ready = {TOP ".ready_target", 0, 0};
static unsigned initialized, started, early_handle, watchers, unexpected;

static vpiHandle find_assertion(const struct watched_assertion *item)
{
    return vpi_handle_by_name((PLI_BYTE8 *)item->name, NULL);
}

static PLI_INT32 initialized_callback(p_cb_data callback)
{
    (void)callback;
    initialized++;
    vpiHandle target = find_assertion(&early);
    early_handle = target != NULL;

    /* The assertion system cannot take this action until the callback returns. */
    if (target != NULL)
        vpi_control(vpiAssertionDisable, target);
    return 0;
}

static PLI_INT32 simulation_start(p_cb_data callback)
{
    (void)callback;
    started++;
    return 0;
}

static PLI_INT32 record_start(PLI_INT32 reason, p_vpi_time time, vpiHandle assertion,
                             p_vpi_attempt_info info, PLI_BYTE8 *user_data)
{
    (void)assertion;
    (void)info;
    struct watched_assertion *item = (struct watched_assertion *)user_data;
    double tick = -1.0;
    if (time != NULL && time->type == vpiScaledRealTime)
        tick = time->real;
    if (time != NULL && time->type == vpiSimTime && time->high == 0)
        tick = time->low;
    if (reason == cbAssertionStart && tick == 5)
        item->first_tick++;
    else if (reason == cbAssertionStart && tick == 15)
        item->second_tick++;
    else
        unexpected++;
    return 0;
}

static unsigned watch_start(struct watched_assertion *item)
{
    vpiHandle assertion = find_assertion(item);
    return assertion != NULL &&
           vpi_register_assertion_cb(assertion, cbAssertionStart, record_start,
                                     (PLI_BYTE8 *)item) != NULL;
}

static PLI_INT32 watch_after_initialization(PLI_BYTE8 *unused)
{
    (void)unused;
    watchers = watch_start(&early) + watch_start(&ready);
    return 0;
}

static PLI_INT32 disable_after_initialization(PLI_BYTE8 *unused)
{
    (void)unused;
    vpiHandle target = find_assertion(&ready);
    if (target != NULL)
        vpi_control(vpiAssertionDisable, target);
    return 0;
}

static PLI_INT32 report(PLI_BYTE8 *unused)
{
    (void)unused;
    vpi_printf("initialization=%u simulation_start=%u early_handle=%u watchers=%u\n",
               initialized, started, early_handle, watchers);
    vpi_printf("starts first=%u%u second=%u%u unexpected=%u\n",
               early.first_tick, ready.first_tick, early.second_tick, ready.second_tick,
               unexpected);
    return 0;
}

static void watch(PLI_INT32 reason, PLI_INT32 (*callback)(p_cb_data))
{
    s_cb_data definition = {0};
    definition.reason = reason;
    definition.cb_rtn = callback;
    vpi_register_cb(&definition);
}

static PLI_INT32 after_compile(p_cb_data callback)
{
    (void)callback;
    watch(cbAssertionSysInitialized, initialized_callback);
    watch(cbStartOfSimulation, simulation_start);
    return 0;
}

static void add_task(const char *name, PLI_INT32 (*callback)(PLI_BYTE8 *))
{
    s_vpi_systf_data definition = {0};
    definition.type = vpiSysTask;
    definition.tfname = (PLI_BYTE8 *)name;
    definition.calltf = callback;
    vpi_register_systf(&definition);
}

static void setup(void)
{
    watch(cbEndOfCompile, after_compile);
    add_task("$vt_watch_ready_assertions", watch_after_initialization);
    add_task("$vt_disable_ready_assertion", disable_after_initialization);
    add_task("$vt_init_report", report);
}

void (*vlog_startup_routines[])(void) = {setup, NULL};

#ifdef __cplusplus
}
#endif
