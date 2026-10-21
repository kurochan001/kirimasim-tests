/* VPI application of test_vpi_iterators_time_queue_events (IEEE 1800-2023 37.81, 37.84). */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "vpi_user.h"
#include "sv_vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

#define TOP "test_vpi_iterators_time_queue_events"
#define MAX 8

static const char *name_of(vpiHandle h)
{
    const char *s = h != NULL ? vpi_get_str(vpiName, h) : NULL;
    return s != NULL ? s : "none";
}

static int same(vpiHandle a, vpiHandle b)
{
    return a != NULL && b != NULL && vpi_compare_objects(a, b) ? 1 : 0;
}

static int by_text(const void *a, const void *b)
{
    return strcmp((const char *)a, (const char *)b);
}

/* Prints the iterator of the time queue and the times of its objects, in order. */
static void time_queue(void)
{
    vpiHandle it = vpi_iterate(vpiTimeQueue, NULL), tq;
    int first = 1;

    if (it == NULL) {
        vpi_printf((PLI_BYTE8 *)"time queue at 5 from read-only synch: NULL\n");
        return;
    }
    vpi_printf((PLI_BYTE8 *)"time queue iterator: type is time queue %d, use is NULL %d, "
               "protected %d\n", vpi_get(vpiIteratorType, it) == vpiTimeQueue,
               vpi_handle(vpiUse, it) == NULL, (int)vpi_get(vpiIsProtected, it));
    vpi_printf((PLI_BYTE8 *)"time queue at 5 from read-only synch:");
    while ((tq = vpi_scan(it)) != NULL) {
        s_vpi_time t;
        t.type = vpiSimTime;
        vpi_get_time(tq, &t);
        vpi_printf((PLI_BYTE8 *)" %u", (unsigned)t.low);
        if (first)
            vpi_printf((PLI_BYTE8 *)" (protected %d)", (int)vpi_get(vpiIsProtected, tq));
        first = 0;
    }
    vpi_printf((PLI_BYTE8 *)"\n");
}

static PLI_INT32 read_only(p_cb_data cb)
{
    (void)cb;
    time_queue();
    return 0;
}

static PLI_INT32 queue_calltf(PLI_BYTE8 *user_data)
{
    static s_vpi_time now;
    s_cb_data d;

    (void)user_data;
    memset(&d, 0, sizeof d);
    now.type = vpiSimTime;
    now.high = 0;
    now.low = 0;
    d.reason = cbReadOnlySynch;
    d.cb_rtn = read_only;
    d.time = &now;
    if (vpi_register_cb(&d) == NULL)
        vpi_printf((PLI_BYTE8 *)"read-only callback not placed\n");
    return 0;
}

static PLI_INT32 nothing(p_cb_data cb)
{
    (void)cb;
    return 0;
}

static void callbacks_of_x(void)
{
    static s_vpi_time suppress;
    static s_vpi_value no_value;
    vpiHandle x = vpi_handle_by_name((PLI_BYTE8 *)TOP ".x", NULL), cb, it;
    s_cb_data d;

    if (x == NULL) {
        vpi_printf((PLI_BYTE8 *)"x not found\n");
        return;
    }
    memset(&d, 0, sizeof d);
    suppress.type = vpiSuppressTime;
    no_value.format = vpiSuppressVal;
    d.reason = cbValueChange;
    d.cb_rtn = nothing;
    d.obj = x;
    d.time = &suppress;
    d.value = &no_value;
    cb = vpi_register_cb(&d);
    if (cb == NULL) {
        vpi_printf((PLI_BYTE8 *)"no callback on x\n");
        return;
    }
    vpi_printf((PLI_BYTE8 *)"callback on x: protected %d\n", (int)vpi_get(vpiIsProtected, cb));
    it = vpi_iterate(vpiCallback, x);
    if (it != NULL) {
        vpi_printf((PLI_BYTE8 *)"callback iterator: type is callback %d, use is x %d, "
                   "protected %d\n", vpi_get(vpiIteratorType, it) == vpiCallback,
                   same(vpi_handle(vpiUse, it), x), (int)vpi_get(vpiIsProtected, it));
        vpi_release_handle(it);
    } else {
        vpi_printf((PLI_BYTE8 *)"callback iterator: NULL\n");
    }
    vpi_remove_cb(cb);
}

static void scheduled_events(void)
{
    vpiHandle t = vpi_handle_by_name((PLI_BYTE8 *)TOP ".target", NULL), ev, ev2;
    s_vpi_value v;
    s_vpi_time delay;

    if (t == NULL) {
        vpi_printf((PLI_BYTE8 *)"target not found\n");
        return;
    }
    v.format = vpiIntVal;
    v.value.integer = 9;
    delay.type = vpiSimTime;
    delay.high = 0;
    delay.low = 10;
    ev = vpi_put_value(t, &v, &delay, vpiInertialDelay | vpiReturnEvent);
    if (ev == NULL) {
        vpi_printf((PLI_BYTE8 *)"no scheduled event returned\n");
    } else {
        vpi_printf((PLI_BYTE8 *)"scheduled event: type is sched event %d, scheduled %d, "
                   "protected %d\n", vpi_get(vpiType, ev) == vpiSchedEvent,
                   (int)vpi_get(vpiScheduled, ev), (int)vpi_get(vpiIsProtected, ev));
        vpi_put_value(ev, NULL, NULL, vpiCancelEvent);
    }
    v.value.integer = 4;
    delay.low = 3;
    ev2 = vpi_put_value(t, &v, &delay, vpiPureTransportDelay);
    vpi_printf((PLI_BYTE8 *)"without vpiReturnEvent: NULL %d\n", ev2 == NULL);
}

static void active_time_format(void)
{
    vpiHandle h1 = vpi_handle(vpiActiveTimeFormat, NULL);
    vpiHandle h2 = vpi_handle(vpiActiveTimeFormat, NULL);

    if (h1 == NULL) {
        vpi_printf((PLI_BYTE8 *)"active time format: NULL\n");
        return;
    }
    vpi_printf((PLI_BYTE8 *)"active time format: same object twice %d, no arguments %d\n",
               same(h1, h2), vpi_iterate(vpiArgument, h1) == NULL);
}

static void alias_statements(void)
{
    vpiHandle top = vpi_handle_by_name((PLI_BYTE8 *)TOP, NULL), it, h;
    char list[MAX][16];
    int n = 0, in_top = 0, prot = 0, i;

    it = top != NULL ? vpi_iterate(vpiAliasStmt, top) : NULL;
    while (it != NULL && (h = vpi_scan(it)) != NULL) {
        if (n < MAX) {
            snprintf(list[n], sizeof list[n], "%s=%s", name_of(vpi_handle(vpiLhs, h)),
                     name_of(vpi_handle(vpiRhs, h)));
            n++;
        }
        in_top += same(vpi_handle(vpiInstance, h), top);
        prot += (int)vpi_get(vpiIsProtected, h);
    }
    qsort(list, n, sizeof list[0], by_text);
    vpi_printf((PLI_BYTE8 *)"alias statements:");
    for (i = 0; i < n; i++)
        vpi_printf((PLI_BYTE8 *)" %s", list[i]);
    vpi_printf((PLI_BYTE8 *)"\nalias statements of the module instance: %d, protected %d\n",
               in_top, prot);
}

static PLI_INT32 objects_calltf(PLI_BYTE8 *user_data)
{
    vpiHandle call = vpi_handle(vpiSysTfCall, NULL);
    vpiHandle it = call != NULL ? vpi_iterate(vpiArgument, call) : NULL;

    (void)user_data;
    callbacks_of_x();
    if (it != NULL) {
        vpi_printf((PLI_BYTE8 *)"argument iterator: use is the call %d\n",
                   same(vpi_handle(vpiUse, it), call));
        vpi_release_handle(it);
    } else {
        vpi_printf((PLI_BYTE8 *)"no argument iterator\n");
    }
    scheduled_events();
    active_time_format();
    alias_statements();
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
    add("$vt_queue", queue_calltf);
    add("$vt_objects", objects_calltf);
}

void (*vlog_startup_routines[])(void) = {register_all, 0};

#ifdef __cplusplus
}
#endif
