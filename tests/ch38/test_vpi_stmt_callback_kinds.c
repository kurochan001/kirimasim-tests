/* VPI application of test_vpi_stmt_callback_kinds (IEEE 1800-2023 38.36.1.1, 38.36.1.2). */
#include <string.h>
#include "vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

#define TOP "test_vpi_stmt_callback_kinds"
#define SLOTS 24

/* The statements of the initial block, in order, with the probe each one prints. */
enum probe { NONE, CALLS, Q, W, R };
static const struct {
    PLI_INT32 type;
    const char *label;
    enum probe probe;
} expected[22] = {
    {vpiDelayControl, "vpiDelayControl", NONE}, {vpiAssignment, "vpiAssignment", NONE},
    {vpiBegin, "vpiBegin", NONE}, {vpiNamedBegin, "vpiNamedBegin nb", NONE},
    {vpiFork, "vpiFork", NONE}, {vpiNamedFork, "vpiNamedFork nf", NONE},
    {vpiIfElse, "vpiIfElse", CALLS}, {vpiCase, "vpiCase", NONE},
    {vpiAssignStmt, "vpiAssignStmt", Q}, {vpiDelayControl, "vpiDelayControl", NONE},
    {vpiDeassign, "vpiDeassign", Q}, {vpiForce, "vpiForce", W},
    {vpiDelayControl, "vpiDelayControl", NONE}, {vpiRelease, "vpiRelease", W},
    {vpiEventStmt, "vpiEventStmt", NONE}, {vpiTaskCall, "vpiTaskCall", R},
    {vpiWait, "vpiWait", R}, {vpiDisable, "vpiDisable", NONE},
    {vpiWhile, "vpiWhile", NONE}, {vpiRepeat, "vpiRepeat", NONE},
    {vpiNamedBegin, "vpiNamedBegin fl", NONE}, {vpiSysTaskCall, "vpiSysTaskCall", NONE}};

static struct slot {
    vpiHandle stmt;
    const char *label;
    enum probe probe;
    PLI_INT32 time_type;
    int seen[4];
    int count;
} slots[SLOTS];
static s_cb_data request;
static s_vpi_time request_times[3];
static s_vpi_value unused_value;
static int wrong_fields, placed;

static int value_of(const char *name)
{
    char full[96];
    vpiHandle h;
    s_vpi_value v;

    strcpy(full, TOP ".");
    strcat(full, name);
    h = vpi_handle_by_name((PLI_BYTE8 *)full, NULL);
    if (h == NULL)
        return -1;
    v.format = vpiIntVal;
    vpi_get_value(h, &v);
    return (int)v.value.integer;
}

static int now(void)
{
    s_vpi_time t;
    t.type = vpiSimTime;
    vpi_get_time(NULL, &t);
    return (int)t.low;
}

static int summarized(struct slot *s)
{
    return strcmp(s->label, "vpiWhile") == 0 || strcmp(s->label, "vpiRepeat") == 0
           || strcmp(s->label, "vpiForever") == 0;
}

static PLI_INT32 on_stmt(p_cb_data cb)
{
    struct slot *s = (struct slot *)cb->user_data;
    int time_ok;
    char when[40];

    if (s < slots || s >= slots + SLOTS) {
        wrong_fields++;
        return 0;
    }
    if (s->time_type == vpiSuppressTime) {
        time_ok = cb->time == NULL;
        strcpy(when, "time NULL");
    } else if (s->time_type == vpiScaledRealTime) {
        time_ok = cb->time != NULL && cb->time->type == vpiScaledRealTime
                  && cb->time->real == (double)now();
        strcpy(when, "vpiScaledRealTime");
    } else {
        time_ok = cb->time != NULL && cb->time->type == vpiSimTime
                  && (int)cb->time->low == now();
        strcpy(when, "vpiSimTime");
    }
    if (cb == &request || cb->reason != cbStmt || cb->cb_rtn != on_stmt || cb->value != NULL
        || cb->index != 0 || cb->obj == NULL || !vpi_compare_objects(cb->obj, s->stmt)
        || !time_ok)
        wrong_fields++;
    if (summarized(s)) {
        if (s->count < 4)
            s->seen[s->count] = strcmp(s->label, "vpiWhile") == 0 ? value_of("calls")
                                : value_of("step");
        s->count++;
        return 0;
    }
    vpi_printf((PLI_BYTE8 *)"%s: at %d, %s, step=%d", s->label, now(), when, value_of("step"));
    if (s->probe == CALLS)
        vpi_printf((PLI_BYTE8 *)", calls=%d", value_of("calls"));
    else if (s->probe == Q)
        vpi_printf((PLI_BYTE8 *)", q=%d", value_of("q"));
    else if (s->probe == W)
        vpi_printf((PLI_BYTE8 *)", w=%d", value_of("w"));
    else if (s->probe == R)
        vpi_printf((PLI_BYTE8 *)", r=%d", value_of("r"));
    vpi_printf((PLI_BYTE8 *)"\n");
    return 0;
}

static void place(vpiHandle stmt, const char *label, enum probe probe, PLI_INT32 time_type)
{
    struct slot *s = &slots[placed];
    s_vpi_time *t = &request_times[time_type == vpiSimTime ? 0
                                   : time_type == vpiScaledRealTime ? 1 : 2];

    s->stmt = stmt;
    s->label = label;
    s->probe = probe;
    s->time_type = time_type;
    t->type = time_type;
    memset(&request, 0, sizeof request);
    request.reason = cbStmt;
    request.cb_rtn = on_stmt;
    request.obj = stmt;
    request.time = t;
    request.value = &unused_value;
    request.index = 77;
    request.user_data = (PLI_BYTE8 *)s;
    if (vpi_register_cb(&request) != NULL)
        placed++;
}

static PLI_INT32 on_start(p_cb_data data)
{
    vpiHandle top = vpi_handle_by_name((PLI_BYTE8 *)TOP, NULL);
    vpiHandle procs = top ? vpi_iterate(vpiProcess, top) : NULL;
    vpiHandle proc, block = NULL, it, stmt, inner;
    int k = 0;

    (void)data;
    unused_value.format = 12345;
    while (procs != NULL && (proc = vpi_scan(procs)) != NULL)
        if (vpi_get(vpiType, proc) == vpiInitial)
            block = vpi_handle(vpiStmt, proc);
    if (block == NULL) {
        vpi_printf((PLI_BYTE8 *)"initial block not found\n");
        return 0;
    }
    place(block, "vpiBegin (initial block)", NONE, vpiSimTime);
    it = vpi_iterate(vpiStmt, block);
    while (it != NULL && (stmt = vpi_scan(it)) != NULL) {
        if (k >= 22 || vpi_get(vpiType, stmt) != expected[k].type) {
            vpi_printf((PLI_BYTE8 *)"statement %d: unexpected type\n", k + 1);
            k++;
            continue;
        }
        place(stmt, expected[k].label, expected[k].probe,
              k == 1 ? vpiScaledRealTime : k == 7 ? vpiSuppressTime : vpiSimTime);
        if (k == 20) {
            vpiHandle body = vpi_iterate(vpiStmt, stmt);
            inner = body ? vpi_scan(body) : NULL;
            if (inner != NULL && vpi_get(vpiType, inner) == vpiForever)
                place(inner, "vpiForever", NONE, vpiSimTime);
            else
                vpi_printf((PLI_BYTE8 *)"forever not found\n");
        }
        k++;
    }
    vpi_printf((PLI_BYTE8 *)"callbacks placed: %d\n", placed);
    return 0;
}

static struct slot *find(const char *label)
{
    int k;
    for (k = 0; k < placed; k++)
        if (strcmp(slots[k].label, label) == 0)
            return &slots[k];
    return NULL;
}

static PLI_INT32 on_end(p_cb_data data)
{
    struct slot *w = find("vpiWhile"), *r = find("vpiRepeat"), *f = find("vpiForever");

    (void)data;
    if (w != NULL)
        vpi_printf((PLI_BYTE8 *)"vpiWhile: 2 or 3 callbacks: %s, the first two saw calls=%d and "
                   "calls=%d\n", w->count == 2 || w->count == 3 ? "yes" : "no", w->seen[0],
                   w->seen[1]);
    if (r != NULL)
        vpi_printf((PLI_BYTE8 *)"vpiRepeat: 3 or 4 callbacks: %s, the first three saw step=%d %d "
                   "%d\n", r->count == 3 || r->count == 4 ? "yes" : "no", r->seen[0], r->seen[1],
                   r->seen[2]);
    if (f != NULL)
        vpi_printf((PLI_BYTE8 *)"vpiForever: %d callbacks, which saw step=%d %d %d\n", f->count,
                   f->seen[0], f->seen[1], f->seen[2]);
    vpi_printf((PLI_BYTE8 *)"fields as 38.36.1.1 gives them in every callback: %s\n",
               wrong_fields == 0 ? "yes" : "no");
    return 0;
}

static void register_all(void)
{
    s_cb_data d;
    memset(&d, 0, sizeof d);
    d.reason = cbStartOfSimulation;
    d.cb_rtn = on_start;
    vpi_register_cb(&d);
    d.reason = cbEndOfSimulation;
    d.cb_rtn = on_end;
    vpi_register_cb(&d);
}

void (*vlog_startup_routines[])(void) = {register_all, 0};

#ifdef __cplusplus
}
#endif
