/* VPI application of test_vpi_assertion_gclk_future_callback (IEEE 1800-2023 39.4.2.1, 39.4.2). */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "vpi_user.h"
#include "sv_vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

#define TOP "test_vpi_assertion_gclk_future_callback"

static int kills, ran_at = -1, event_at = -1;

static int ticks(p_vpi_time t)
{
    if (t == NULL)
        return -1;
    if (t->type == vpiScaledRealTime)
        return (int)(t->real + 0.5);
    return (int)t->low;
}

static PLI_INT32 on_kill(PLI_INT32 reason, p_vpi_time cb_time, vpiHandle assertion,
                         p_vpi_attempt_info info, PLI_BYTE8 *user_data)
{
    s_vpi_time t;

    (void)assertion;
    (void)info;
    (void)user_data;
    if (reason != cbAssertionKill)
        return 0;
    t.type = vpiSimTime;
    vpi_get_time(NULL, &t);
    kills++;
    ran_at = (int)t.low;
    event_at = ticks(cb_time);
    return 0;
}

static PLI_INT32 watch_calltf(PLI_BYTE8 *user_data)
{
    vpiHandle a1 = vpi_handle_by_name((PLI_BYTE8 *)TOP ".a1", NULL);

    (void)user_data;
    if (a1 == NULL || vpi_register_assertion_cb(a1, cbAssertionKill, on_kill, NULL) == NULL)
        vpi_printf((PLI_BYTE8 *)"callback not placed\n");
    return 0;
}

static PLI_INT32 report_calltf(PLI_BYTE8 *user_data)
{
    (void)user_data;
    vpi_printf((PLI_BYTE8 *)"kill callbacks: %d, ran at %d, cb_time %d\n", kills, ran_at, event_at);
    return 0;
}

static void add(const char *name, PLI_INT32 (*calltf)(PLI_BYTE8 *))
{
    s_vpi_systf_data d;
    memset(&d, 0, sizeof d);
    d.type = vpiSysTask;
    d.tfname = (PLI_BYTE8 *)name;
    d.calltf = calltf;
    vpi_register_systf(&d);
}

static void register_all(void)
{
    add("$vt_watch", watch_calltf);
    add("$vt_report", report_calltf);
}

void (*vlog_startup_routines[])(void) = {register_all, 0};

#ifdef __cplusplus
}
#endif
