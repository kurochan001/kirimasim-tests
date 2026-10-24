/* VPI application of test_vpi_prefix_kinds_actual (IEEE 1800-2023 37.61). */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "vpi_user.h"
#include "sv_vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

#define TOP "test_vpi_prefix_kinds_actual"
#define MAX_LINES 12

static char lines[MAX_LINES][160];
static int line_count;

static int compare(const void *x, const void *y)
{
    return strcmp((const char *)x, (const char *)y);
}

static const char *str_or(PLI_INT32 prop, vpiHandle h, const char *fallback)
{
    const char *s = h != NULL ? vpi_get_str(prop, h) : NULL;
    return s != NULL ? s : fallback;
}

static const char *kind_of(vpiHandle h)
{
    switch (vpi_get(vpiType, h)) {
    case vpiPartSelect: return "part-select";
    case vpiIndexedPartSelect: return "indexed part-select";
    case vpiNamedEvent: return "named event";
    case vpiTaskCall: return "task call";
    case vpiVirtualInterfaceVar: return "virtual interface var";
    case vpiClassVar: return "class var";
    case vpiClockingBlock: return "clocking block";
    default: return "other";
    }
}

static void add(const char *when, const char *what, vpiHandle obj)
{
    char prefix[64];
    vpiHandle p;

    if (line_count == MAX_LINES)
        return;
    if (obj == NULL) {
        snprintf(lines[line_count++], sizeof lines[0], "%s: %s not found", when, what);
        return;
    }
    p = vpi_handle(vpiPrefix, obj);
    if (p == NULL)
        snprintf(prefix, sizeof prefix, "NULL");
    else
        snprintf(prefix, sizeof prefix, "%s (%s)", str_or(vpiName, p, "(no name)"), kind_of(p));
    snprintf(lines[line_count++], sizeof lines[0], "%s: %s %s, prefix %s, has actual %d", when,
             what, kind_of(obj), prefix, (int)vpi_get(vpiHasActual, obj));
}

static PLI_INT32 report(p_cb_data data)
{
    const char *when = (const char *)data->user_data;
    vpiHandle task, body, it, s, obj, ts, f = NULL;
    char what[32];
    int i;

    line_count = 0;
    task = vpi_handle_by_name((PLI_BYTE8 *)TOP ".peek", NULL);
    body = task != NULL ? vpi_handle(vpiStmt, task) : NULL;
    it = body != NULL ? vpi_iterate(vpiStmt, body) : NULL;
    while (it != NULL && (s = vpi_scan(it)) != NULL) {
        switch (vpi_get(vpiType, s)) {
        case vpiAssignment:
            snprintf(what, sizeof what, "%s =", str_or(vpiName, vpi_handle(vpiLhs, s), "?"));
            add(when, what, vpi_handle(vpiRhs, s));
            break;
        case vpiEventStmt:
            add(when, "event trigger of", vpi_handle(vpiNamedEvent, s));
            break;
        case vpiTaskCall:
            add(when, "statement", s);
            break;
        default:
            add(when, "other statement", s);
            break;
        }
    }
    obj = vpi_handle_by_name((PLI_BYTE8 *)TOP ".obj", NULL);
    ts = obj != NULL ? vpi_handle(vpiTypespec, obj) : NULL;
    it = ts != NULL ? vpi_iterate(vpiVariables, ts) : NULL;
    while (it != NULL && (s = vpi_scan(it)) != NULL)
        if (strcmp(str_or(vpiName, s, ""), "f") == 0)
            f = s;
    if (line_count < MAX_LINES)
        snprintf(lines[line_count++], sizeof lines[0],
                 "%s: property f from the class typespec of obj, has actual %d", when,
                 f != NULL ? (int)vpi_get(vpiHasActual, f) : -1);
    qsort(lines, (size_t)line_count, sizeof lines[0], compare);
    for (i = 0; i < line_count; i++)
        vpi_printf((PLI_BYTE8 *)"%s\n", lines[i]);
    return 0;
}

static void at(PLI_INT32 reason, const char *label)
{
    static s_vpi_time times[2];
    static int n;
    s_cb_data d;

    memset(&d, 0, sizeof d);
    times[n].type = vpiSimTime;
    times[n].high = 0;
    times[n].low = 1;
    d.reason = reason;
    d.cb_rtn = report;
    d.time = &times[n++];
    d.user_data = (PLI_BYTE8 *)label;
    vpi_register_cb(&d);
}

static PLI_INT32 start_of_simulation(p_cb_data data)
{
    (void)data;
    at(cbAtStartOfSimTime, "start of 1");
    at(cbReadOnlySynch, "read-only synch of 1");
    return 0;
}

static void register_all(void)
{
    s_cb_data d;
    memset(&d, 0, sizeof d);
    d.reason = cbStartOfSimulation;
    d.cb_rtn = start_of_simulation;
    vpi_register_cb(&d);
}

void (*vlog_startup_routines[])(void) = {register_all, 0};

#ifdef __cplusplus
}
#endif
