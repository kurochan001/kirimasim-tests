/* VPI application of test_vpi_part_select_parts (IEEE 1800-2023 37.59). */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "vpi_user.h"
#include "sv_vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

#define TOP "test_vpi_part_select_parts"
#define MAX_LINES 8

static char lines[MAX_LINES][192];
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

/* NULL as none, a constant as its value, a var select as name[index],
   anything else by name. */
static void expr_text(vpiHandle h, char *buf, size_t size)
{
    char base[32], index[32];
    const char *s;

    if (h == NULL) {
        snprintf(buf, size, "none");
    } else if (vpi_get(vpiType, h) == vpiConstant) {
        snprintf(buf, size, "%d", int_value(h));
    } else if (vpi_get(vpiType, h) == vpiVarSelect) {
        expr_text(vpi_handle(vpiParent, h), base, sizeof base);
        expr_text(vpi_handle(vpiIndex, h), index, sizeof index);
        snprintf(buf, size, "%s[%s]", base, index);
    } else {
        s = vpi_get_str(vpiName, h);
        snprintf(buf, size, "%s", s != NULL ? s : "unnamed expression");
    }
}

static void describe(vpiHandle s)
{
    char target[16], a[32], b[32], parent[32], size_text[16];
    vpiHandle rhs;
    int constant;

    if (line_count == MAX_LINES || vpi_get(vpiType, s) != vpiAssignment) {
        if (line_count < MAX_LINES)
            snprintf(lines[line_count++], sizeof lines[0], "other statement");
        return;
    }
    expr_text(vpi_handle(vpiLhs, s), target, sizeof target);
    rhs = vpi_handle(vpiRhs, s);
    if (rhs == NULL) {
        snprintf(lines[line_count++], sizeof lines[0], "%s = none", target);
        return;
    }
    expr_text(vpi_handle(vpiParent, rhs), parent, sizeof parent);
    constant = vpi_get(vpiConstantSelect, rhs) != 0;
    /* The width of an unpacked slice is not printed. */
    if (strcmp(target, "p6") == 0)
        size_text[0] = '\0';
    else
        snprintf(size_text, sizeof size_text, ", size %d", (int)vpi_get(vpiSize, rhs));
    if (vpi_get(vpiType, rhs) == vpiPartSelect) {
        expr_text(vpi_handle(vpiLeftRange, rhs), a, sizeof a);
        expr_text(vpi_handle(vpiRightRange, rhs), b, sizeof b);
        snprintf(lines[line_count++], sizeof lines[0],
                 "%s = part-select, left %s, right %s, parent %s, constant %d%s",
                 target, a, b, parent, constant, size_text);
    } else if (vpi_get(vpiType, rhs) == vpiIndexedPartSelect) {
        PLI_INT32 dir = vpi_get(vpiIndexedPartSelectType, rhs);
        expr_text(vpi_handle(vpiBaseExpr, rhs), a, sizeof a);
        expr_text(vpi_handle(vpiWidthExpr, rhs), b, sizeof b);
        snprintf(lines[line_count++], sizeof lines[0],
                 "%s = indexed part-select %s, base %s, width %s, parent %s, constant %d%s",
                 target, dir == vpiPosIndexed ? "+:" : dir == vpiNegIndexed ? "-:" : "?",
                 a, b, parent, constant, size_text);
    } else {
        snprintf(lines[line_count++], sizeof lines[0], "%s = other expression", target);
    }
}

static PLI_INT32 start_of_simulation(p_cb_data data)
{
    vpiHandle task, body, it, s;
    int n = 0, i;

    (void)data;
    task = vpi_handle_by_name((PLI_BYTE8 *)TOP ".sels", NULL);
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
