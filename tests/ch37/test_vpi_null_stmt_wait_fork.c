/* VPI application of test_vpi_null_stmt_wait_fork (IEEE 1800-2023 37.60, 37.67). */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "vpi_user.h"
#include "sv_vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

#define TOP "test_vpi_null_stmt_wait_fork"
#define MAX_LINES 16

static char lines[MAX_LINES][128];
static int line_count;

static int compare(const void *x, const void *y)
{
    return strcmp((const char *)x, (const char *)y);
}

static void add_line(const char *text)
{
    if (line_count < MAX_LINES)
        snprintf(lines[line_count++], sizeof lines[0], "%s", text);
}

static const char *kind_of(vpiHandle h)
{
    if (h == NULL)
        return "NULL";
    switch (vpi_get(vpiType, h)) {
    case vpiNullStmt: return "null statement";
    case vpiWaitFork: return "wait fork";
    case vpiWait: return "wait";
    case vpiIfElse: return "if-else";
    case vpiCase: return "case";
    case vpiDelayControl: return "delay control";
    case vpiAssignment: return "assignment";
    default: return "other";
    }
}

/* 9.3.5: a label can make a named block around the statement. If the
   implementation shows it as a named begin holding one statement, use
   that statement, which carries the label itself (37.60 detail 1). */
static vpiHandle unwrap(vpiHandle s)
{
    vpiHandle it, inner;

    if (s == NULL || vpi_get(vpiType, s) != vpiNamedBegin)
        return s;
    it = vpi_iterate(vpiStmt, s);
    inner = it != NULL ? vpi_scan(it) : NULL;
    if (inner == NULL)
        return s;
    if (vpi_scan(it) != NULL) {
        vpi_release_handle(it);
        return s;
    }
    return inner;
}

/* "kind, label L" of the statement s, or NULL when there is none. */
static void kind_label(char *out, size_t size, vpiHandle s)
{
    const char *label = s != NULL ? vpi_get_str(vpiName, s) : NULL;

    if (s == NULL)
        snprintf(out, size, "NULL");
    else
        snprintf(out, size, "%s, label %s", kind_of(s), label != NULL ? label : "NULL");
}

static void case_items(vpiHandle c)
{
    char text[128], stmt[48];
    vpiHandle items = vpi_iterate(vpiCaseItem, c), item, exprs, e;
    s_vpi_value v;

    while (items != NULL && (item = vpi_scan(items)) != NULL) {
        exprs = vpi_iterate(vpiExpr, item);
        e = exprs != NULL ? vpi_scan(exprs) : NULL;
        if (e != NULL)
            vpi_release_handle(exprs);
        kind_label(stmt, sizeof stmt, unwrap(vpi_handle(vpiStmt, item)));
        if (e == NULL) {
            snprintf(text, sizeof text, "case item default: %s", stmt);
        } else {
            v.format = vpiIntVal;
            vpi_get_value(e, &v);
            snprintf(text, sizeof text, "case item %d: %s", (int)v.value.integer, stmt);
        }
        add_line(text);
    }
}

static void describe(vpiHandle s)
{
    char text[128], head[48], sub[48], other[48];
    PLI_INT32 type;

    s = unwrap(s);
    kind_label(head, sizeof head, s);
    type = vpi_get(vpiType, s);
    if (type == vpiCase) {
        case_items(s);
        return;
    }
    if (type == vpiIfElse || type == vpiWait || type == vpiWaitFork || type == vpiDelayControl) {
        kind_label(sub, sizeof sub, unwrap(vpi_handle(vpiStmt, s)));
        if (type == vpiIfElse) {
            kind_label(other, sizeof other, unwrap(vpi_handle(vpiElseStmt, s)));
            snprintf(text, sizeof text, "%s; then %s; else %s", head, sub, other);
        } else {
            snprintf(text, sizeof text, "%s; its statement %s", head, sub);
        }
    } else {
        snprintf(text, sizeof text, "%s", head);
    }
    add_line(text);
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
