/* VPI application of test_vpi_callback_registration_errors (IEEE 1800-2023 38.36.1, 38.36.2). */
#include <string.h>
#include "vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

#define TOP "test_vpi_callback_registration_errors"

struct slot {
    int calls;
    int time;
};

static vpiHandle by_name(const char *name)
{
    return vpi_handle_by_name((PLI_BYTE8 *)name, NULL);
}

static PLI_INT32 count_cb(p_cb_data cb)
{
    struct slot *s = (struct slot *)cb->user_data;

    if (s != NULL) {
        s->calls++;
        s->time = cb->time ? (int)cb->time->low : -1;
    }
    return 0;
}

static vpiHandle register_cb(PLI_INT32 reason, vpiHandle obj, PLI_INT32 time_type,
                             PLI_INT32 when, struct slot *s,
                             PLI_INT32 (*fn)(p_cb_data))
{
    static s_vpi_time times[16];
    static int used;
    s_cb_data cb;

    memset(&cb, 0, sizeof cb);
    cb.reason = reason;
    cb.cb_rtn = fn;
    cb.obj = obj;
    if (time_type >= 0) {
        times[used].type = time_type;
        times[used].high = 0;
        times[used].low = (PLI_UINT32)when;
        cb.time = &times[used++];
    }
    cb.user_data = (PLI_BYTE8 *)s;
    return vpi_register_cb(&cb);
}

static int null_next_refused, supp_next_refused, after_null_refused;
static int bitsel_refused, start7_registered, zero_start_refused, zero_rw_refused;
static struct slot null_next, supp_next, after_null, next1, next2, bitsel, whole;
static struct slot tick1;
static struct slot start7, zero_start, rw5, ro5, zero_rw;
static int next1_time, next2_time, start7_time, rw5_time, ro5_time;
static int ro5_count, rw5_count;

static PLI_INT32 on_ro(p_cb_data cb)
{
    struct slot *s = (struct slot *)cb->user_data;

    if (s != NULL) {
        s->calls++;
        s->time = cb->time ? (int)cb->time->low : -1;
        ro5_time = s->time;
        ro5_count = s->calls;
    }
    zero_rw_refused = register_cb(cbReadWriteSynch, NULL, vpiSimTime, 0, &zero_rw,
                                  count_cb) == NULL;
    return 0;
}

static PLI_INT32 on_rw(p_cb_data cb)
{
    struct slot *s = (struct slot *)cb->user_data;

    if (s != NULL) {
        s->calls++;
        s->time = cb->time ? (int)cb->time->low : -1;
        rw5_time = s->time;
        rw5_count = s->calls;
    }
    zero_start_refused = register_cb(cbAtStartOfSimTime, NULL, vpiSimTime, 0,
                                     &zero_start, count_cb) == NULL;
    register_cb(cbReadOnlySynch, NULL, vpiSimTime, 0, &ro5, on_ro);
    return 0;
}

static PLI_INT32 on_next(p_cb_data cb)
{
    (void)cb;
    null_next_refused = register_cb(cbNextSimTime, NULL, -1, 0, &null_next,
                                    count_cb) == NULL;
    supp_next_refused = register_cb(cbNextSimTime, NULL, vpiSuppressTime, 0, &supp_next,
                                    count_cb) == NULL;
    after_null_refused = register_cb(cbAfterDelay, NULL, -1, 0, &after_null,
                                     count_cb) == NULL;
    register_cb(cbNextSimTime, NULL, vpiSimTime, 100, &next1, count_cb);
    register_cb(cbNextSimTime, NULL, vpiSimTime, 7, &next2, count_cb);
    return 0;
}

static PLI_INT32 on_start(p_cb_data cb)
{
    vpiHandle q = by_name(TOP ".q");
    vpiHandle bit = q ? vpi_handle_by_index(q, 1) : NULL;

    (void)cb;
    bitsel_refused = register_cb(cbForce, bit, vpiSimTime, 0, &bitsel, count_cb) == NULL;
    register_cb(cbForce, NULL, vpiSimTime, 0, &whole, count_cb);
    start7_registered = register_cb(cbAtStartOfSimTime, NULL, vpiSimTime, 7, &start7,
                                    count_cb) != NULL;
    register_cb(cbReadWriteSynch, NULL, vpiSimTime, 5, &rw5, on_rw);
    register_cb(cbAfterDelay, NULL, vpiSimTime, 1, &tick1, on_next);
    return 0;
}

static void say(const char *what, int ok)
{
    vpi_printf((PLI_BYTE8 *)"%s: %s\n", what, ok ? "yes" : "no");
}

static PLI_INT32 on_end(p_cb_data cb)
{
    (void)cb;
    next1_time = next1.calls == 1 ? next1.time : -1;
    next2_time = next2.calls == 1 ? next2.time : -1;
    start7_time = start7.calls == 1 ? start7.time : -1;
    say("cbNextSimTime with a NULL time was refused",
        null_next_refused && null_next.calls == 0);
    say("cbNextSimTime with suppressed time was refused",
        supp_next_refused && supp_next.calls == 0);
    say("cbAfterDelay with a NULL time was refused",
        after_null_refused && after_null.calls == 0);
    say("cbNextSimTime callbacks with different requested times ran at the next event queue",
        next1_time == 2 && next2_time == 2);
    say("cbForce on a variable bit-select was refused",
        bitsel_refused && bitsel.calls == 0);
    say("cbForce on the whole variable was delivered", whole.calls == 1);
    say("cbAtStartOfSimTime for a later time was registered and ran",
        start7_registered && start7_time == 7);
    say("a zero-delay cbAtStartOfSimTime after entering a time slice was refused",
        zero_start_refused && zero_start.calls == 0);
    say("a zero-delay cbReadOnlySynch at read-write time ran",
        rw5_count == 1 && rw5_time == 5 && ro5_count == 1 && ro5_time == 5);
    say("a zero-delay cbReadWriteSynch at read-only time was refused",
        zero_rw_refused && zero_rw.calls == 0);
    return 0;
}

static void register_all(void)
{
    s_cb_data cb;

    memset(&cb, 0, sizeof cb);
    cb.reason = cbStartOfSimulation;
    cb.cb_rtn = on_start;
    vpi_register_cb(&cb);
    memset(&cb, 0, sizeof cb);
    cb.reason = cbEndOfSimulation;
    cb.cb_rtn = on_end;
    vpi_register_cb(&cb);
}

void (*vlog_startup_routines[])(void) = {register_all, 0};

#ifdef __cplusplus
}
#endif
