/* VPI application of test_vpi_case_loop_force_stmts (IEEE 1800-2023 37.72, 37.75, 37.79). */
#include <stdio.h>
#include <string.h>
#include "vpi_user.h"
#include "sv_vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

static const char *name_or_none(vpiHandle h)
{
    return h != NULL && vpi_get_str(vpiName, h) != NULL ? vpi_get_str(vpiName, h) : "(none)";
}

/* The name of a simple expression, the value of a constant, or "?". */
static void operand_text(vpiHandle h, char *buf, size_t size)
{
    s_vpi_value v;

    if (h != NULL && vpi_get(vpiType, h) == vpiConstant) {
        v.format = vpiIntVal;
        vpi_get_value(h, &v);
        snprintf(buf, size, "%d", (int)v.value.integer);
    } else {
        snprintf(buf, size, "%s", name_or_none(h));
    }
}

static int count(PLI_INT32 type, vpiHandle ref)
{
    vpiHandle it = vpi_iterate(type, ref);
    int n = 0;
    if (it != NULL)
        while (vpi_scan(it) != NULL)
            n++;
    return n;
}

static void describe_case(vpiHandle s)
{
    PLI_INT32 type = vpi_get(vpiCaseType, s), q = vpi_get(vpiQualifier, s);
    vpiHandle it = vpi_iterate(vpiCaseItem, s), item;

    vpi_printf((PLI_BYTE8 *)"case: type %s, qualifier %s, condition %s, expressions per item:",
               type == vpiCaseExact ? "case" : type == vpiCaseX ? "casex" :
               type == vpiCaseZ ? "casez" : "other",
               q == vpiUniqueQualifier ? "unique" : q == vpiPriorityQualifier ? "priority" :
               q == vpiNoQualifier ? "none" : "other",
               name_or_none(vpi_handle(vpiCondition, s)));
    if (it != NULL)
        while ((item = vpi_scan(it)) != NULL)
            vpi_printf((PLI_BYTE8 *)" %d", count(vpiExpr, item));
    vpi_printf((PLI_BYTE8 *)"\n");
}

static void describe_foreach(vpiHandle s)
{
    vpiHandle it = vpi_iterate(vpiLoopVars, s), v;

    vpi_printf((PLI_BYTE8 *)"foreach: array %s, loop variables:",
               name_or_none(vpi_handle(vpiVariables, s)));
    if (it != NULL)
        while ((v = vpi_scan(it)) != NULL)
            vpi_printf((PLI_BYTE8 *)" %s", vpi_get(vpiType, v) == vpiOperation &&
                       vpi_get(vpiOpType, v) == vpiNullOp ? "(skipped)" : name_or_none(v));
    vpi_printf((PLI_BYTE8 *)"\n");
}

static void describe_stmt(vpiHandle s)
{
    char lhs[32], rhs[32];

    operand_text(vpi_handle(vpiLhs, s), lhs, sizeof lhs);
    switch (vpi_get(vpiType, s)) {
    case vpiCase:
        describe_case(s);
        break;
    case vpiForeachStmt:
        describe_foreach(s);
        break;
    case vpiDoWhile:
        vpi_printf((PLI_BYTE8 *)"do-while: condition %s, statement %s\n",
                   vpi_handle(vpiCondition, s) ? "present" : "missing",
                   vpi_handle(vpiStmt, s) ? "present" : "missing");
        break;
    case vpiForce:
        operand_text(vpi_handle(vpiRhs, s), rhs, sizeof rhs);
        vpi_printf((PLI_BYTE8 *)"force %s = %s\n", lhs, rhs);
        break;
    case vpiRelease:
        vpi_printf((PLI_BYTE8 *)"release %s\n", lhs);
        break;
    case vpiAssignStmt:
        operand_text(vpi_handle(vpiRhs, s), rhs, sizeof rhs);
        vpi_printf((PLI_BYTE8 *)"assign %s = %s\n", lhs, rhs);
        break;
    case vpiDeassign:
        vpi_printf((PLI_BYTE8 *)"deassign %s\n", lhs);
        break;
    default:
        vpi_printf((PLI_BYTE8 *)"other statement (type %d)\n", (int)vpi_get(vpiType, s));
    }
}

static PLI_INT32 stmts_calltf(PLI_BYTE8 *user_data)
{
    vpiHandle blk = vpi_handle_by_name((PLI_BYTE8 *)"test_vpi_case_loop_force_stmts.stmts", NULL);
    vpiHandle it = blk ? vpi_iterate(vpiStmt, blk) : NULL, s;

    (void)user_data;
    if (it == NULL)
        vpi_printf((PLI_BYTE8 *)"no statements found\n");
    else
        while ((s = vpi_scan(it)) != NULL)
            describe_stmt(s);
    return 0;
}

static void register_all(void)
{
    s_vpi_systf_data d;
    memset(&d, 0, sizeof d);
    d.type = vpiSysTask;
    d.tfname = (PLI_BYTE8 *)"$vt_stmts";
    d.calltf = stmts_calltf;
    vpi_register_systf(&d);
}

void (*vlog_startup_routines[])(void) = {register_all, 0};

#ifdef __cplusplus
}
#endif
