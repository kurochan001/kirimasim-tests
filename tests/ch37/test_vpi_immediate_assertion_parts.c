/* VPI application of test_vpi_immediate_assertion_parts (IEEE 1800-2023 37.55). */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "vpi_user.h"
#include "sv_vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

#define TOP "test_vpi_immediate_assertion_parts"
#define MAX_LINES 16

static char lines[MAX_LINES][160];
static int line_count;

static int compare(const void *x, const void *y)
{
    return strcmp((const char *)x, (const char *)y);
}

static const char *name_of(vpiHandle h)
{
    const char *s = h != NULL ? vpi_get_str(vpiName, h) : NULL;
    return s != NULL ? s : "none";
}

/* An assignment as "target = value", a task call as "call name", NULL as "none". */
static void stmt_text(vpiHandle s, char *buf, size_t size)
{
    char target[64];
    vpiHandle rhs;
    s_vpi_value v;

    if (s == NULL) {
        snprintf(buf, size, "none");
        return;
    }
    switch (vpi_get(vpiType, s)) {
    case vpiAssignment:
        snprintf(target, sizeof target, "%s", name_of(vpi_handle(vpiLhs, s)));
        rhs = vpi_handle(vpiRhs, s);
        if (rhs != NULL && vpi_get(vpiType, rhs) == vpiConstant) {
            v.format = vpiIntVal;
            vpi_get_value(rhs, &v);
            snprintf(buf, size, "%s = %d", target, (int)v.value.integer);
        } else {
            snprintf(buf, size, "%s = other", target);
        }
        break;
    case vpiTaskCall:
        /* 37.60: the call's name is its label, not the callee (37.42). */
        snprintf(buf, size, "call %s", name_of(vpi_handle(vpiTask, s)));
        break;
    default:
        snprintf(buf, size, "other statement");
        break;
    }
}

static void describe(vpiHandle s)
{
    char cond[64], pass[64], other[64];
    PLI_INT32 type = vpi_get(vpiType, s);
    const char *kind = type == vpiImmediateAssert ? "assert"
                     : type == vpiImmediateAssume ? "assume"
                     : type == vpiImmediateCover ? "cover" : NULL;
    int deferred, final;

    if (line_count == MAX_LINES)
        return;
    if (kind == NULL) {
        snprintf(lines[line_count++], sizeof lines[0], "other statement");
        return;
    }
    snprintf(cond, sizeof cond, "%s", name_of(vpi_handle(vpiExpr, s)));
    deferred = vpi_get(vpiIsDeferred, s) != 0;
    final = vpi_get(vpiIsFinal, s) != 0;
    stmt_text(vpi_handle(vpiStmt, s), pass, sizeof pass);
    if (type == vpiImmediateCover) {
        snprintf(lines[line_count++], sizeof lines[0], "%s: %s, deferred %d, final %d, pass %s",
                 cond, kind, deferred, final, pass);
    } else {
        stmt_text(vpi_handle(vpiElseStmt, s), other, sizeof other);
        snprintf(lines[line_count++], sizeof lines[0],
                 "%s: %s, deferred %d, final %d, pass %s, else %s",
                 cond, kind, deferred, final, pass, other);
    }
}

static PLI_INT32 start_of_simulation(p_cb_data data)
{
    vpiHandle task, body, it, s;
    int n = 0, i;

    (void)data;
    task = vpi_handle_by_name((PLI_BYTE8 *)TOP ".checks", NULL);
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
