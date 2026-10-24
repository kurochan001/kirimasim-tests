/* VPI application of test_vpi_case_items_patterns (IEEE 1800-2023 37.72). */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "vpi_user.h"
#include "sv_vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

#define TOP "test_vpi_case_items_patterns"
#define MAX_LINES 16
#define MAX_EXPRS 8

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

static const char *name_or(vpiHandle h, const char *fallback)
{
    const char *s = h != NULL ? vpi_get_str(vpiName, h) : NULL;
    return s != NULL ? s : fallback;
}

/* A constant as its value, an any pattern as .name, a tagged pattern as
   "tagged name nested", anything else with a name by its name. */
static void pattern_text(vpiHandle p, char *buf, size_t size)
{
    char tag[32], nested[48];

    if (p == NULL) {
        snprintf(buf, size, "no pattern");
        return;
    }
    switch (vpi_get(vpiType, p)) {
    case vpiConstant:
        snprintf(buf, size, "%d", int_value(p));
        break;
    case vpiAnyPattern:
        snprintf(buf, size, ".%s", name_or(p, "(no name)"));
        break;
    case vpiTaggedPattern:
        snprintf(tag, sizeof tag, "%s", name_or(p, "(no name)"));
        pattern_text(vpi_handle(vpiPattern, p), nested, sizeof nested);
        snprintf(buf, size, "tagged %s %s", tag, nested);
        break;
    default:
        snprintf(buf, size, "other pattern %s", name_or(p, "(no name)"));
        break;
    }
}

static void stmt_text(vpiHandle s, char *buf, size_t size)
{
    char lhs[32];
    vpiHandle rhs;

    if (s == NULL || vpi_get(vpiType, s) != vpiAssignment) {
        snprintf(buf, size, s == NULL ? "none" : "other statement");
        return;
    }
    snprintf(lhs, sizeof lhs, "%s", name_or(vpi_handle(vpiLhs, s), "?"));
    rhs = vpi_handle(vpiRhs, s);
    if (rhs != NULL && vpi_get(vpiType, rhs) == vpiConstant)
        snprintf(buf, size, "%s = %d", lhs, int_value(rhs));
    else
        snprintf(buf, size, "%s = %s", lhs, name_or(rhs, "?"));
}

static void describe_item(const char *cond, vpiHandle item)
{
    char exprs[MAX_EXPRS][48], body[48], list[128];
    vpiHandle it, e;
    int n = 0, i;

    if (line_count == MAX_LINES)
        return;
    stmt_text(vpi_handle(vpiStmt, item), body, sizeof body);
    it = vpi_iterate(vpiExpr, item);
    if (it == NULL) {
        snprintf(list, sizeof list, "NULL");
    } else {
        while ((e = vpi_scan(it)) != NULL)
            if (n < MAX_EXPRS)
                pattern_text(e, exprs[n++], sizeof exprs[0]);
        qsort(exprs, (size_t)n, sizeof exprs[0], compare);
        list[0] = '\0';
        for (i = 0; i < n; i++) {
            size_t len = strlen(list);
            snprintf(list + len, sizeof list - len, "%s%s", i ? ", " : "", exprs[i]);
        }
    }
    snprintf(lines[line_count++], sizeof lines[0], "case on %s, item with %s: expressions %s",
             cond, body, list);
}

static PLI_INT32 start_of_simulation(p_cb_data data)
{
    vpiHandle task, body, it, s, items, item;
    char cond[32];
    int cases = 0, item_count = 0, i;

    (void)data;
    task = vpi_handle_by_name((PLI_BYTE8 *)TOP ".stmts", NULL);
    body = task != NULL ? vpi_handle(vpiStmt, task) : NULL;
    it = body != NULL ? vpi_iterate(vpiStmt, body) : NULL;
    while (it != NULL && (s = vpi_scan(it)) != NULL) {
        if (vpi_get(vpiType, s) != vpiCase)
            continue;
        cases++;
        snprintf(cond, sizeof cond, "%s", name_or(vpi_handle(vpiCondition, s), "?"));
        items = vpi_iterate(vpiCaseItem, s);
        while (items != NULL && (item = vpi_scan(items)) != NULL) {
            item_count++;
            describe_item(cond, item);
        }
    }
    qsort(lines, (size_t)line_count, sizeof lines[0], compare);
    for (i = 0; i < line_count; i++)
        vpi_printf((PLI_BYTE8 *)"%s\n", lines[i]);
    vpi_printf((PLI_BYTE8 *)"case statements: %d, case items: %d\n", cases, item_count);
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
