/* VPI application of test_vpi_assertion_callback_scope_removal (IEEE 1800-2023 39.4.2). */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "sv_vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

#define MAX 32

struct event {
    int when;
    char text[64];
};

static struct event events[MAX];
static int n_events;
static vpiHandle second_cb;

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
    struct event *e;

    (void)info;
    if (n_events == MAX)
        return 0;
    e = &events[n_events++];
    e->when = ticks(cb_time);
    snprintf(e->text, sizeof e->text, "%s %s, user data %s",
             vpi_get_str(vpiName, assertion),
             reason == cbAssertionSuccess ? "success" : reason == cbAssertionFailure
             ? "failure" : "other reason", user_data);
    return 0;
}

static vpiHandle find(const char *name)
{
    char full[128];
    vpiHandle h;
    snprintf(full, sizeof full, "test_vpi_assertion_callback_scope_removal.%s", name);
    h = vpi_handle_by_name((PLI_BYTE8 *)full, NULL);
    if (h == NULL)
        vpi_printf("%s not found\n", name);
    return h;
}

static PLI_INT32 watch_calltf(PLI_BYTE8 *user_data)
{
    vpiHandle a1 = find("a1"), a2 = find("a2");

    (void)user_data;
    if (a1 == NULL || a2 == NULL)
        return 0;
    if (vpi_register_assertion_cb(a1, cbAssertionSuccess, on_assertion,
                                  (PLI_BYTE8 *)"first") == NULL)
        vpi_printf("first callback not placed\n");
    second_cb = vpi_register_assertion_cb(a1, cbAssertionSuccess, on_assertion,
                                          (PLI_BYTE8 *)"second");
    if (second_cb == NULL)
        vpi_printf("second callback not placed\n");
    if (vpi_register_assertion_cb(a2, cbAssertionFailure, on_assertion,
                                  (PLI_BYTE8 *)"third") == NULL)
        vpi_printf("third callback not placed\n");
    return 0;
}

static PLI_INT32 drop_calltf(PLI_BYTE8 *user_data)
{
    (void)user_data;
    if (second_cb != NULL)
        vpi_printf("removing the second callback: %s\n",
                   vpi_remove_cb(second_cb) ? "done" : "failed");
    return 0;
}

static int by_time(const void *pa, const void *pb)
{
    const struct event *a = (const struct event *)pa, *b = (const struct event *)pb;
    if (a->when != b->when)
        return a->when - b->when;
    return strcmp(a->text, b->text);
}

static PLI_INT32 report_calltf(PLI_BYTE8 *user_data)
{
    int i;

    (void)user_data;
    qsort(events, n_events, sizeof events[0], by_time);
    for (i = 0; i < n_events; i++)
        vpi_printf("%d: %s\n", events[i].when, events[i].text);
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
    add_task("$vt_drop", drop_calltf);
    add_task("$vt_report", report_calltf);
}

void (*vlog_startup_routines[])(void) = {register_all, 0};

#ifdef __cplusplus
}
#endif
