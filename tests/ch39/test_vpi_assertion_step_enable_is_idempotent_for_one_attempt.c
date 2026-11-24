#include <stddef.h>
#include "sv_vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

#define TOP "test_vpi_assertion_step_enable_is_idempotent_for_one_attempt"

static vpiHandle assertion;
static unsigned registered, requests, at_tick[3], other_ticks, failed, other_attempts;
static unsigned peer_steps;
static s_vpi_time first_start = {vpiSimTime, 0, 15, 0.0};

static double tick_of(p_vpi_time time)
{
    if (time != NULL && time->type == vpiSimTime && time->high == 0)
        return time->low;
    if (time != NULL && time->type == vpiScaledRealTime)
        return time->real;
    return -1.0;
}

static PLI_INT32 record(PLI_INT32 reason, p_vpi_time time, vpiHandle target,
                        p_vpi_attempt_info info, PLI_BYTE8 *peer)
{
    (void)target;
    if (peer != NULL) {
        (*(unsigned *)peer)++;
        return 0;
    }
    if (info == NULL || tick_of(&info->attemptStartTime) != 15) {
        other_attempts++;
        return 0;
    }
    failed += reason != cbAssertionStepSuccess;
    const double tick = tick_of(time);
    for (unsigned i = 0; i < 3; ++i) {
        if (tick == 15 + i * 10) {
            at_tick[i]++;
            return 0;
        }
    }
    other_ticks++;
    return 0;
}

static void enable(void)
{
    if (assertion != NULL) {
        ++requests;
        vpi_control(vpiAssertionEnableStep, assertion, &first_start, vpiAssertionClockSteps);
    }
}

static PLI_INT32 arm(PLI_BYTE8 *unused)
{
    (void)unused;
    assertion = vpi_handle_by_name((PLI_BYTE8 *)TOP ".path", NULL);
    vpiHandle peer = vpi_handle_by_name((PLI_BYTE8 *)TOP ".peer", NULL);
    if (peer != NULL)
        registered += vpi_register_assertion_cb(peer, cbAssertionStepSuccess, record,
                                               (PLI_BYTE8 *)&peer_steps) != NULL;
    if (assertion != NULL) {
        registered +=
            vpi_register_assertion_cb(assertion, cbAssertionStepSuccess, record, NULL) != NULL;
        enable();
        enable();
    }
    return 0;
}

static PLI_INT32 repeat_arm(PLI_BYTE8 *unused)
{
    (void)unused;
    enable();
    return 0;
}

static PLI_INT32 report(PLI_BYTE8 *unused)
{
    (void)unused;
    vpi_printf("assertion callbacks=%u requests=%u\n", registered, requests);
    vpi_printf("first attempt steps=%u%u%u other ticks=%u failed=%u\n",
               at_tick[0], at_tick[1], at_tick[2], other_ticks, failed);
    vpi_printf("other attempts steps=%u other assertion steps=%u\n", other_attempts, peer_steps);
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
    add_task("$vt_arm_first", arm);
    add_task("$vt_repeat_arm", repeat_arm);
    add_task("$vt_report_steps", report);
}

void (*vlog_startup_routines[])(void) = {setup, NULL};

#ifdef __cplusplus
}
#endif
