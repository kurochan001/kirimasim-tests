/* VPI application of test_vpi_sequence_decl_operands (IEEE 1800-2023 37.53, 37.54). */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "vpi_user.h"
#include "sv_vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

#define TOP "test_vpi_sequence_decl_operands"
#define MAX 8
#define LEN 64

static int by_text(const void *x, const void *y)
{
    return strcmp((const char *)x, (const char *)y);
}

static const char *name_of(vpiHandle h)
{
    PLI_BYTE8 *s = h != NULL ? vpi_get_str(vpiName, h) : NULL;
    return s != NULL ? s : "(none)";
}

static int int_value(vpiHandle h)
{
    s_vpi_value v;
    v.format = vpiIntVal;
    vpi_get_value(h, &v);
    return (int)v.value.integer;
}

static const char *op_name(PLI_INT32 op)
{
    switch (op) {
    case vpiCompAndOp: return "and";
    case vpiCompOrOp: return "or";
    case vpiUnaryCycleDelayOp: return "unary ##";
    case vpiCycleDelayOp: return "##";
    case vpiConsecutiveRepeatOp: return "[*]";
    case vpiGotoRepeatOp: return "[->]";
    case vpiRepeatOp: return "[=]";
    case vpiLogAndOp: return "&&";
    default: return "other operation";
    }
}

static void operand_text(vpiHandle h, char *out, size_t len)
{
    if (h == NULL)
        snprintf(out, len, "NULL");
    else if (vpi_get(vpiType, h) == vpiConstant)
        snprintf(out, len, "%d", int_value(h));
    else if (vpi_get(vpiType, h) == vpiOperation)
        snprintf(out, len, "(%s)", op_name(vpi_get(vpiOpType, h)));
    else if (vpi_get(vpiType, h) == vpiDistribution)
        snprintf(out, len, "(distribution of %s)", name_of(vpi_handle(vpiExpr, h)));
    else
        snprintf(out, len, "%s", name_of(h));
}

static vpiHandle decl_in(const char *scope, const char *name)
{
    vpiHandle s = vpi_handle_by_name((PLI_BYTE8 *)scope, NULL), it, h, found = NULL;
    it = s != NULL ? vpi_iterate(vpiSequenceDecl, s) : NULL;
    while (it != NULL && (h = vpi_scan(it)) != NULL)
        if (strcmp(name_of(h), name) == 0)
            found = h;
    return found;
}

static const char *direction(vpiHandle h)
{
    switch (vpi_get(vpiDirection, h)) {
    case vpiNoDirection: return "no direction";
    case vpiInput: return "input";
    case vpiOutput: return "output";
    case vpiInout: return "inout";
    default: return "other direction";
    }
}

static const char *typespec(vpiHandle formal)
{
    vpiHandle ts = vpi_handle(vpiTypespec, formal);
    if (ts == NULL)
        return "typespec NULL";
    switch (vpi_get(vpiType, ts)) {
    case vpiIntTypespec: return "int typespec";
    case vpiLogicTypespec: return "logic typespec";
    default: return "other typespec";
    }
}

static void formals(void)
{
    vpiHandle d = decl_in(TOP, "s_formals"), it, f;

    vpi_printf((PLI_BYTE8 *)"formals of s_formals:\n");
    it = d != NULL ? vpi_iterate(vpiSeqFormalDecl, d) : NULL;
    while (it != NULL && (f = vpi_scan(it)) != NULL)
        vpi_printf((PLI_BYTE8 *)"  %s: %s, %s\n", name_of(f), direction(f), typespec(f));
}

static void variables(void)
{
    vpiHandle d = decl_in(TOP, "s_vars"), it, h;
    char names[MAX][LEN];
    int n = 0, i;

    it = d != NULL ? vpi_iterate(vpiVariables, d) : NULL;
    while (it != NULL && (h = vpi_scan(it)) != NULL)
        if (n < MAX)
            snprintf(names[n++], LEN, "%s", name_of(h));
    qsort(names, (size_t)n, LEN, by_text);
    vpi_printf((PLI_BYTE8 *)"variables of s_vars:");
    for (i = 0; i < n; i++)
        vpi_printf((PLI_BYTE8 *)" %s", names[i]);
    vpi_printf((PLI_BYTE8 *)"\n");
}

static void full_name(const char *scope, const char *name)
{
    vpiHandle d = decl_in(scope, name);
    vpi_printf((PLI_BYTE8 *)"full name of %s: %s\n", name,
               d != NULL && vpi_get_str(vpiFullName, d) != NULL ? vpi_get_str(vpiFullName, d)
               : "(none)");
}

static void body(const char *name)
{
    vpiHandle d = decl_in(TOP, name), e, it, h;
    char text[LEN];

    e = d != NULL ? vpi_handle(vpiExpr, d) : NULL;
    if (e == NULL) {
        vpi_printf((PLI_BYTE8 *)"%s: no sequence expression\n", name);
        return;
    }
    if (vpi_get(vpiType, e) != vpiOperation) {
        operand_text(e, text, sizeof text);
        vpi_printf((PLI_BYTE8 *)"%s: expression %s\n", name, text);
        return;
    }
    vpi_printf((PLI_BYTE8 *)"%s: %s, operands:", name, op_name(vpi_get(vpiOpType, e)));
    it = vpi_iterate(vpiOperand, e);
    while (it != NULL && (h = vpi_scan(it)) != NULL) {
        operand_text(h, text, sizeof text);
        vpi_printf((PLI_BYTE8 *)" %s", text);
    }
    vpi_printf((PLI_BYTE8 *)"\n");
}

static void match_items(void)
{
    vpiHandle d = decl_in(TOP, "s_match"), e, it, first = NULL, mi, x;
    char items[MAX][LEN];
    int n = 0, i;

    e = d != NULL ? vpi_handle(vpiExpr, d) : NULL;
    it = e != NULL ? vpi_iterate(vpiOperand, e) : NULL;
    if (it != NULL && (first = vpi_scan(it)) != NULL)
        vpi_free_object(it);
    if (first == NULL) {
        vpi_printf((PLI_BYTE8 *)"s_match: no first operand\n");
        return;
    }
    it = vpi_iterate(vpiMatchItem, first);
    while (it != NULL && (mi = vpi_scan(it)) != NULL) {
        if (n == MAX)
            continue;
        switch (vpi_get(vpiType, mi)) {
        case vpiAssignment:
            x = vpi_handle(vpiLhs, mi);
            snprintf(items[n++], LEN, "assignment to %s", name_of(x));
            break;
        case vpiFuncCall:
            x = vpi_handle(vpiFunction, mi);
            snprintf(items[n++], LEN, "call of %s", name_of(x));
            break;
        default:
            snprintf(items[n++], LEN, "other object");
            break;
        }
    }
    qsort(items, (size_t)n, LEN, by_text);
    vpi_printf((PLI_BYTE8 *)"s_match: first operand %s, match items:", name_of(first));
    for (i = 0; i < n; i++)
        vpi_printf((PLI_BYTE8 *)"%s %s", i ? "," : "", items[i]);
    vpi_printf((PLI_BYTE8 *)"\n");
}

static PLI_INT32 seqs_calltf(PLI_BYTE8 *user_data)
{
    static const char *const names[] = {
        "s_and", "s_or", "s_udel", "s_udel2", "s_bdel", "s_bdel1", "s_rep", "s_rep2",
        "s_goto", "s_nc", "s_dist", "s_expr", "s_one", NULL};
    int i;

    (void)user_data;
    formals();
    variables();
    full_name(TOP, "s_vars");
    full_name(TOP ".g", "s_gen");
    for (i = 0; names[i] != NULL; i++)
        body(names[i]);
    match_items();
    return 0;
}

static void register_all(void)
{
    s_vpi_systf_data d;
    memset(&d, 0, sizeof d);
    d.type = vpiSysTask;
    d.tfname = (PLI_BYTE8 *)"$vt_seqs";
    d.calltf = seqs_calltf;
    vpi_register_systf(&d);
}

void (*vlog_startup_routines[])(void) = {register_all, 0};

#ifdef __cplusplus
}
#endif
