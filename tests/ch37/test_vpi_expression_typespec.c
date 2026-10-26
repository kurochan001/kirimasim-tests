/* VPI application of test_vpi_expression_typespec (IEEE 1800-2023 37.59). */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "vpi_user.h"
#include "sv_vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

#define TOP "test_vpi_expression_typespec"
#define MAX 8

static int by_text(const void *a, const void *b)
{
    return strcmp((const char *)a, (const char *)b);
}

static const char *sprop(PLI_INT32 property, vpiHandle h)
{
    PLI_BYTE8 *s = h != NULL ? vpi_get_str(property, h) : NULL;
    return s != NULL ? s : "NULL";
}

static void describe(vpiHandle s, char *out, size_t size)
{
    vpiHandle rhs = vpi_handle(vpiRhs, s);
    vpiHandle ts = rhs != NULL ? vpi_handle(vpiTypespec, rhs) : NULL;
    const char *kind;
    char spec[80];

    if (rhs == NULL) {
        snprintf(out, size, "%s: no right-hand side", sprop(vpiName, vpi_handle(vpiLhs, s)));
        return;
    }
    if (vpi_get(vpiType, rhs) == vpiOperation) {
        PLI_INT32 op = vpi_get(vpiOpType, rhs);
        if (op == vpiCastOp)
            kind = "cast operation";
        else if (op == vpiAssignmentPatternOp)
            kind = "assignment pattern operation";
        else if (op == vpiMultiAssignmentPatternOp)
            kind = "multiple assignment pattern operation";
        else
            kind = "other operation";
    } else {
        kind = "variable";
    }
    if (ts == NULL)
        snprintf(spec, sizeof spec, "NULL");
    else if (vpi_get(vpiType, ts) == vpiIntTypespec)
        snprintf(spec, sizeof spec, "int 1");
    else
        snprintf(spec, sizeof spec, "name %s", sprop(vpiName, ts));
    snprintf(out, size, "%s: %s, typespec %s", sprop(vpiName, vpi_handle(vpiLhs, s)),
             kind, spec);
}

static PLI_INT32 types_calltf(PLI_BYTE8 *user_data)
{
    vpiHandle task = vpi_handle_by_name((PLI_BYTE8 *)TOP ".exprs", NULL);
    vpiHandle body = task != NULL ? vpi_handle(vpiStmt, task) : NULL;
    vpiHandle it = body != NULL ? vpi_iterate(vpiStmt, body) : NULL, s;
    char lines[MAX][128];
    int n = 0, i;

    (void)user_data;
    while (it != NULL && (s = vpi_scan(it)) != NULL && n < MAX)
        if (vpi_get(vpiType, s) == vpiAssignment)
            describe(s, lines[n++], sizeof lines[0]);
    qsort(lines, (size_t)n, sizeof lines[0], by_text);
    for (i = 0; i < n; i++)
        vpi_printf((PLI_BYTE8 *)"%s\n", lines[i]);
    return 0;
}

static void register_all(void)
{
    s_vpi_systf_data d;
    memset(&d, 0, sizeof d);
    d.type = vpiSysTask;
    d.tfname = (PLI_BYTE8 *)"$vt_types";
    d.calltf = types_calltf;
    vpi_register_systf(&d);
}

void (*vlog_startup_routines[])(void) = {register_all, 0};

#ifdef __cplusplus
}
#endif
