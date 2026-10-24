/* VPI application of test_vpi_expression_decompile_calls (IEEE 1800-2023 37.59). */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "vpi_user.h"
#include "sv_vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

#define TOP "test_vpi_expression_decompile_calls"
#define MAX_LINES 16

static char lines[MAX_LINES][128];
static int line_count;

static int compare(const void *x, const void *y)
{
    return strcmp((const char *)x, (const char *)y);
}

static const char *kind_of(vpiHandle h)
{
    if (h == NULL)
        return "none";
    switch (vpi_get(vpiType, h)) {
    case vpiFuncCall: return "function call";
    case vpiMethodFuncCall: return "method function call";
    case vpiLetExpr: return "let expression";
    case vpiOperation: return "operation";
    default: return "other expression";
    }
}

static void describe(vpiHandle s)
{
    char target[16];
    const char *t, *text;
    vpiHandle rhs;

    if (line_count == MAX_LINES)
        return;
    if (vpi_get(vpiType, s) != vpiAssignment) {
        snprintf(lines[line_count++], sizeof lines[0], "other statement");
        return;
    }
    t = vpi_get_str(vpiName, vpi_handle(vpiLhs, s));
    snprintf(target, sizeof target, "%s", t != NULL ? t : "?");
    rhs = vpi_handle(vpiRhs, s);
    if (target[0] == 'd') {
        text = rhs != NULL ? vpi_get_str(vpiDecompile, rhs) : NULL;
        snprintf(lines[line_count++], sizeof lines[0], "%s: \"%s\"", target,
                 text != NULL ? text : "(NULL)");
    } else {
        snprintf(lines[line_count++], sizeof lines[0], "%s: %s, size %d", target, kind_of(rhs),
                 rhs != NULL ? (int)vpi_get(vpiSize, rhs) : -1);
    }
}

static PLI_INT32 start_of_simulation(p_cb_data data)
{
    vpiHandle task, body, it, s;
    int n = 0, i;

    (void)data;
    task = vpi_handle_by_name((PLI_BYTE8 *)TOP ".exprs", NULL);
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
