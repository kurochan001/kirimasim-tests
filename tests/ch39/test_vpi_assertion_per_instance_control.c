/* VPI application of test_vpi_assertion_per_instance_control (IEEE 1800-2023 39.5.2). */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "sv_vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

#define TOP "test_vpi_assertion_per_instance_control"
#define MAX 16

struct event {
    int when;
    int rank;        /* 0 disable, 1 enable */
};

static struct event events[MAX];
static int n_events;
static int disable_callbacks_u2;

static int ticks(p_vpi_time t)
{
    if (t == NULL)
        return -1;
    if (t->type == vpiScaledRealTime)
        return (int)(t->real + 0.5);
    return (int)t->low;
}

static PLI_INT32 on_assertion(PLI_INT32 reason, p_vpi_time cb_time, vpiHandle assertion,
                              p_vpi_attempt_info info, PLI_BYTE8 *user_data)
{
    int is_u2 = user_data != NULL && strcmp(user_data, "u2") == 0;

    (void)assertion;
    (void)info;
    if (reason == cbAssertionDisable) {
        if (is_u2)
            disable_callbacks_u2++;
        else if (n_events < MAX) {
            events[n_events].when = ticks(cb_time);
            events[n_events].rank = 0;
            n_events++;
        }
    } else if (reason == cbAssertionEnable && !is_u2 && n_events < MAX) {
        events[n_events].when = ticks(cb_time);
        events[n_events].rank = 1;
        n_events++;
    }
    return 0;
}

static PLI_INT32 watch_calltf(PLI_BYTE8 *user_data)
{
    static PLI_BYTE8 tags[2][3] = {"u1", "u2"};
    vpiHandle h1 = vpi_handle_by_name((PLI_BYTE8 *)TOP ".u1.a1", NULL);
    vpiHandle h2 = vpi_handle_by_name((PLI_BYTE8 *)TOP ".u2.a1", NULL);

    (void)user_data;
    vpi_printf("u1 and u2 have different handles: %d\n",
               h1 != NULL && h2 != NULL && h1 != h2);
    if (h1 != NULL) {
        vpi_register_assertion_cb(h1, cbAssertionDisable, on_assertion, tags[0]);
        vpi_register_assertion_cb(h1, cbAssertionEnable, on_assertion, tags[0]);
        vpi_control(vpiAssertionDisable, h1);
    }
    if (h2 != NULL) {
        vpi_register_assertion_cb(h2, cbAssertionDisable, on_assertion, tags[1]);
        vpi_register_assertion_cb(h2, cbAssertionEnable, on_assertion, tags[1]);
    }
    return 0;
}

static PLI_INT32 enable_calltf(PLI_BYTE8 *user_data)
{
    vpiHandle h1 = vpi_handle_by_name((PLI_BYTE8 *)TOP ".u1.a1", NULL);

    (void)user_data;
    if (h1 != NULL)
        vpi_control(vpiAssertionEnable, h1);
    return 0;
}

static int by_time(const void *pa, const void *pb)
{
    const struct event *a = (const struct event *)pa, *b = (const struct event *)pb;
    if (a->when != b->when)
        return a->when - b->when;
    return a->rank - b->rank;
}

static PLI_INT32 report_calltf(PLI_BYTE8 *user_data)
{
    static const char *const names[] = {"disabled", "enabled"};
    int i;

    (void)user_data;
    qsort(events, n_events, sizeof events[0], by_time);
    for (i = 0; i < n_events; i++)
        vpi_printf("%d: u1 %s\n", events[i].when, names[events[i].rank]);
    vpi_printf("disable callbacks on u2: %d\n", disable_callbacks_u2);
    return 0;
}

static void add_task(const char *name, PLI_INT32 (*calltf)(PLI_BYTE8 *))
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
    add_task("$vt_watch", watch_calltf);
    add_task("$vt_enable", enable_calltf);
    add_task("$vt_report", report_calltf);
}

void (*vlog_startup_routines[])(void) = {register_all, 0};

#ifdef __cplusplus
}
#endif
