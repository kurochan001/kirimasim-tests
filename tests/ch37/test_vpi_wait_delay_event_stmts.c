/* VPI application of test_vpi_wait_delay_event_stmts (IEEE 1800-2023 37.62, 37.67, 37.68). */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "vpi_user.h"
#include "sv_vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

#define TOP "test_vpi_wait_delay_event_stmts"
#define MAX_LINES 16
#define MAX_NAMES 8

static char lines[MAX_LINES][160];
static int line_count;

static int compare(const void *x, const void *y)
{
    return strcmp((const char *)x, (const char *)y);
}

static int int_value(vpiHandle h)
{
    s_vpi_value v;
    v.format = vpiIntVal;
    vpi_get_value(h, &v);
    return (int)v.value.integer;
}

/* NULL as none, a constant as its value, anything else by name. */
static void expr_text(vpiHandle h, char *buf, size_t size)
{
    const char *s;

    if (h == NULL) {
        snprintf(buf, size, "none");
    } else if (vpi_get(vpiType, h) == vpiConstant) {
        snprintf(buf, size, "%d", int_value(h));
    } else {
        s = vpi_get_str(vpiName, h);
        snprintf(buf, size, "%s", s != NULL ? s : "unnamed expression");
    }
}

/* An assignment as "v = N", NULL as none. */
static void stmt_text(vpiHandle s, char *buf, size_t size)
{
    char lhs[32], rhs[32];

    if (s == NULL) {
        snprintf(buf, size, "none");
    } else if (vpi_get(vpiType, s) == vpiAssignment) {
        expr_text(vpi_handle(vpiLhs, s), lhs, sizeof lhs);
        expr_text(vpi_handle(vpiRhs, s), rhs, sizeof rhs);
        snprintf(buf, size, "%s = %s", lhs, rhs);
    } else {
        snprintf(buf, size, "other statement");
    }
}

/* The names of the vpiCondition iteration, sorted and separated by spaces. */
static void condition_names(vpiHandle s, char *buf, size_t size)
{
    char names[MAX_NAMES][32];
    vpiHandle it = vpi_iterate(vpiCondition, s), h;
    int n = 0, i;

    buf[0] = '\0';
    while (it != NULL && (h = vpi_scan(it)) != NULL)
        if (n < MAX_NAMES)
            expr_text(h, names[n++], sizeof names[0]);
    qsort(names, (size_t)n, sizeof names[0], compare);
    for (i = 0; i < n; i++) {
        size_t len = strlen(buf);
        snprintf(buf + len, size - len, "%s%s", i ? " " : "", names[i]);
    }
    if (n == 0)
        snprintf(buf, size, "none");
}

static void describe(vpiHandle s)
{
    char a[64], b[64], c[64];
    char *line;
    size_t size = sizeof lines[0];
    vpiHandle dc;

    if (line_count == MAX_LINES)
        return;
    line = lines[line_count++];
    switch (vpi_get(vpiType, s)) {
    case vpiWait:
        expr_text(vpi_handle(vpiCondition, s), a, sizeof a);
        stmt_text(vpi_handle(vpiStmt, s), b, sizeof b);
        snprintf(line, size, "wait: condition %s, statement %s", a, b);
        break;
    case vpiOrderedWait:
        condition_names(s, a, sizeof a);
        stmt_text(vpi_handle(vpiStmt, s), b, sizeof b);
        stmt_text(vpi_handle(vpiElseStmt, s), c, sizeof c);
        snprintf(line, size, "ordered wait: conditions %s, statement %s, else %s", a, b, c);
        break;
    case vpiDelayControl:
        expr_text(vpi_handle(vpiDelay, s), a, sizeof a);
        stmt_text(vpi_handle(vpiStmt, s), b, sizeof b);
        snprintf(line, size, "delay control: delay %s, statement %s", a, b);
        break;
    case vpiAssignment:
        stmt_text(s, a, sizeof a);
        dc = vpi_handle(vpiDelayControl, s);
        if (dc == NULL) {
            snprintf(line, size, "assignment %s: no delay control", a);
            break;
        }
        expr_text(vpi_handle(vpiDelay, dc), b, sizeof b);
        stmt_text(vpi_handle(vpiStmt, dc), c, sizeof c);
        snprintf(line, size, "assignment %s: delay control with delay %s, statement %s",
                 a, b, c);
        break;
    case vpiEventStmt:
        expr_text(vpi_handle(vpiNamedEvent, s), a, sizeof a);
        snprintf(line, size, "event statement: named event %s, blocking %d", a,
                 (int)vpi_get(vpiBlocking, s));
        break;
    default:
        snprintf(line, size, "other statement");
        break;
    }
}

static PLI_INT32 start_of_simulation(p_cb_data data)
{
    vpiHandle task, body, it, s;
    int n = 0, i;

    (void)data;
    task = vpi_handle_by_name((PLI_BYTE8 *)TOP ".stmts", NULL);
    body = task != NULL ? vpi_handle(vpiStmt, task) : NULL;
    it = body != NULL ? vpi_iterate(vpiStmt, body) : NULL;
    while (it != NULL && (s = vpi_scan(it)) != NULL) {
        n++;
        describe(s);
    }
    qsort(lines, (size_t)line_count, sizeof lines[0], compare);
    for (i = 0; i < line_count; i++)
        vpi_printf((PLI_BYTE8 *)"%s\n", lines[i]);
    vpi_printf((PLI_BYTE8 *)"statements: %d\n", n);
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
