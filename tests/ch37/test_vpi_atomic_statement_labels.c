/* VPI application of test_vpi_atomic_statement_labels (IEEE 1800-2023 37.60). */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "vpi_user.h"
#include "sv_vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

#define TOP "test_vpi_atomic_statement_labels"
#define MAX_LINES 32

static char lines[MAX_LINES][128];
static int line_count;

static int compare(const void *x, const void *y)
{
    return strcmp((const char *)x, (const char *)y);
}

static const char *label_of(vpiHandle h)
{
    const char *s = h != NULL ? vpi_get_str(vpiName, h) : NULL;
    return s != NULL ? s : "NULL";
}

static const char *kind_of(vpiHandle h)
{
    if (h == NULL)
        return "no statement";
    switch (vpi_get(vpiType, h)) {
    case vpiIfElse: return "if-else";
    case vpiWhile: return "while";
    case vpiRepeat: return "repeat";
    case vpiWait: return "wait";
    case vpiOrderedWait: return "ordered wait";
    case vpiWaitFork: return "wait fork";
    case vpiFor: return "for";
    case vpiDelayControl: return "delay control";
    case vpiEventStmt: return "event statement";
    case vpiDisable: return "disable";
    case vpiDisableFork: return "disable fork";
    case vpiForever: return "forever";
    case vpiDoWhile: return "do-while";
    case vpiExpectStmt: return "expect";
    case vpiForeachStmt: return "foreach";
    case vpiImmediateAssert: return "immediate assert";
    case vpiImmediateAssume: return "immediate assume";
    case vpiImmediateCover: return "immediate cover";
    case vpiReturnStmt: return "return";
    case vpiBreak: return "break";
    case vpiContinue: return "continue";
    case vpiNullStmt: return "null statement";
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

static void describe(vpiHandle s)
{
    char head[64], kind[24], label[24];
    vpiHandle sub;
    PLI_INT32 type;

    if (line_count == MAX_LINES)
        return;
    s = unwrap(s);
    snprintf(head, sizeof head, "%s: label %s", kind_of(s), label_of(s));
    type = vpi_get(vpiType, s);
    if (type == vpiWhile || type == vpiRepeat || type == vpiWait || type == vpiDelayControl) {
        sub = unwrap(vpi_handle(vpiStmt, s));
        snprintf(kind, sizeof kind, "%s", kind_of(sub));
        snprintf(label, sizeof label, "%s", label_of(sub));
        snprintf(lines[line_count++], sizeof lines[0], "%s; its statement: %s, label %s",
                 head, kind, label);
    } else {
        snprintf(lines[line_count++], sizeof lines[0], "%s", head);
    }
}

static PLI_INT32 start_of_simulation(p_cb_data data)
{
    vpiHandle task, body, it, s;
    int n = 0, i;

    (void)data;
    task = vpi_handle_by_name((PLI_BYTE8 *)TOP ".labeled", NULL);
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
