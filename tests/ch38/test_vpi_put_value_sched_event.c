/* VPI application of test_vpi_put_value_sched_event (IEEE 1800-2023 38.34). */
#include <string.h>
#include "vpi_user.h"

/* The values that Annex K gives, for vpi_user.h files that leave them out. */
#ifndef vpiCancelEvent
#define vpiCancelEvent 7
#endif
#ifndef vpiScheduled
#define vpiScheduled 46
#endif
#ifndef vpiSchedEvent
#define vpiSchedEvent 53
#endif

#ifdef __cplusplus
extern "C" {
#endif

#define TOP "test_vpi_put_value_sched_event."

static vpiHandle event_of_c;

static vpiHandle object(const char *name)
{
    char full[96];
    strcpy(full, TOP);
    strcat(full, name);
    return vpi_handle_by_name((PLI_BYTE8 *)full, NULL);
}

static vpiHandle put(vpiHandle h, int value, PLI_UINT32 delay, PLI_INT32 flags)
{
    s_vpi_value v;
    s_vpi_time t;

    v.format = vpiIntVal;
    v.value.integer = value;
    t.type = vpiSimTime;
    t.high = 0;
    t.low = delay;
    t.real = 0.0;
    return vpi_put_value(h, &v, &t, flags);
}

static const char *is_event(vpiHandle h)
{
    return h != NULL && vpi_get(vpiType, h) == vpiSchedEvent ? "yes" : "no";
}

static PLI_INT32 at_17(p_cb_data cb)
{
    PLI_INT32 scheduled, error;

    (void)cb;
    if (event_of_c == NULL) {
        vpi_printf((PLI_BYTE8 *)"17: no event handle for c\n");
        return 0;
    }
    scheduled = vpi_get(vpiScheduled, event_of_c);
    vpi_put_value(event_of_c, NULL, NULL, vpiCancelEvent);
    error = vpi_chk_error(NULL);
    vpi_printf((PLI_BYTE8 *)"17: event of c at 15: vpiScheduled %d, cancel: error %s\n",
               (int)scheduled, error ? "yes" : "no");
    return 0;
}

static PLI_INT32 at_10(p_cb_data cb)
{
    vpiHandle a = object("a"), b = object("b"), c = object("c"), d = object("d"), e = object("e");
    vpiHandle h;
    s_vpi_value five;
    PLI_INT32 error;

    (void)cb;
    if (a == NULL || b == NULL || c == NULL || d == NULL || e == NULL) {
        vpi_printf((PLI_BYTE8 *)"objects not found\n");
        return 0;
    }
    h = put(a, 1, 10, vpiPureTransportDelay | vpiReturnEvent);
    vpi_printf((PLI_BYTE8 *)"10: a 1 at 20 with vpiReturnEvent: a vpiSchedEvent %s, "
               "vpiScheduled %d\n", is_event(h), h ? (int)vpi_get(vpiScheduled, h) : -1);
    vpi_printf((PLI_BYTE8 *)"10: a 2 at 30 without vpiReturnEvent: %s\n",
               put(a, 2, 20, vpiPureTransportDelay) == NULL ? "NULL" : "a handle");
    if (h != NULL) {
        vpi_put_value(h, NULL, NULL, vpiCancelEvent);
        error = vpi_chk_error(NULL);
        vpi_printf((PLI_BYTE8 *)"10: cancel of a 1 at 20 with NULL value_p and time_p: "
                   "error %s\n", error ? "yes" : "no");
    }
    five.format = vpiIntVal;
    five.value.integer = 5;
    vpi_printf((PLI_BYTE8 *)"10: b 5 with vpiNoDelay and vpiReturnEvent: %s\n",
               vpi_put_value(b, &five, NULL, vpiNoDelay | vpiReturnEvent) == NULL ? "NULL"
               : "a handle");
    event_of_c = put(c, 7, 5, vpiPureTransportDelay | vpiReturnEvent);
    h = put(d, 9, 10, vpiPureTransportDelay | vpiReturnEvent);
    if (h != NULL)
        vpi_release_handle(h);
    put(e, 1, 10, vpiPureTransportDelay);
    h = put(e, 2, 15, vpiInertialDelay | vpiReturnEvent);
    if (h != NULL)
        vpi_put_value(h, NULL, NULL, vpiCancelEvent);
    return 0;
}

static void after(PLI_UINT32 delay, PLI_INT32 (*rtn)(p_cb_data))
{
    static s_vpi_time times[2];
    static int used = 0;
    s_cb_data cb;

    times[used].type = vpiSimTime;
    times[used].high = 0;
    times[used].low = delay;
    memset(&cb, 0, sizeof cb);
    cb.reason = cbAfterDelay;
    cb.cb_rtn = rtn;
    cb.time = &times[used++];
    vpi_register_cb(&cb);
}

static PLI_INT32 on_start(p_cb_data data)
{
    (void)data;
    after(10, at_10);
    after(17, at_17);
    return 0;
}

static void register_all(void)
{
    s_cb_data d;
    memset(&d, 0, sizeof d);
    d.reason = cbStartOfSimulation;
    d.cb_rtn = on_start;
    vpi_register_cb(&d);
}

void (*vlog_startup_routines[])(void) = {register_all, 0};

#ifdef __cplusplus
}
#endif
