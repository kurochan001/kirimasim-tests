#include <stddef.h>
#include "sv_vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

static char current_events[16];
static unsigned event_count;
static int registrations, end_count, after_end;

static PLI_INT32 record_system(p_cb_data cb)
{
    const char *kind = (const char *)cb->user_data;
    if (end_count != 0)
        after_end++;
    if (kind != NULL && event_count + 1 < sizeof current_events) {
        current_events[event_count++] = kind[0];
        if (kind[0] == 'E')
            end_count++;
    }
    return 0;
}

static void watch(PLI_INT32 reason, const char *label)
{
    s_cb_data cb = {0};
    cb.reason = reason;
    cb.cb_rtn = record_system;
    cb.user_data = (PLI_BYTE8 *)label;
    registrations += vpi_register_cb(&cb) != NULL;
}

static PLI_INT32 place_after_compile(p_cb_data cb)
{
    (void)cb;
    watch(cbAssertionSysInitialized, "I");
    watch(cbAssertionSysOn, "O");
    watch(cbAssertionSysEnd, "E");
    return 0;
}

static PLI_INT32 end_system(PLI_BYTE8 *user_data)
{
    (void)user_data;
    vpi_control(vpiAssertionSysEnd, (vpiHandle)NULL);
    vpi_control(vpiAssertionSysOn, (vpiHandle)NULL);
    return 0;
}

static PLI_INT32 report(PLI_BYTE8 *user_data)
{
    (void)user_data;
    vpi_printf("lifecycle registrations=%d events=%s\n", registrations, current_events);
    return 0;
}

static PLI_INT32 report_end(PLI_BYTE8 *user_data)
{
    (void)user_data;
    vpi_printf("end callbacks=%d later callbacks=%d\n", end_count, after_end);
    return 0;
}

static void add_task(const char *name, PLI_INT32 (*method)(PLI_BYTE8 *))
{
    s_vpi_systf_data def = {0};
    def.type = vpiSysTask;
    def.tfname = (PLI_BYTE8 *)name;
    def.calltf = method;
    vpi_register_systf(&def);
}

static void register_setup(void)
{
    s_cb_data cb = {0};
    cb.reason = cbEndOfCompile;
    cb.cb_rtn = place_after_compile;
    vpi_register_cb(&cb);
    add_task("$vt_report_lifecycle", report);
    add_task("$vt_end_system", end_system);
    add_task("$vt_report_end", report_end);
}

void (*vlog_startup_routines[])(void) = {register_setup, NULL};

#ifdef __cplusplus
}
#endif
