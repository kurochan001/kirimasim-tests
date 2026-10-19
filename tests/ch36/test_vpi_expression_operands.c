/* VPI application of test_vpi_expression_operands (IEEE 1800-2023 36.10.3, 37.59). */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

struct op {
    PLI_INT32 type;
    const char *name;
};

static const struct op ops[] = {
    {vpiMinusOp, "minus"}, {vpiSubOp, "sub"}, {vpiAddOp, "add"}, {vpiMultOp, "mult"},
    {vpiConditionOp, "condition"}, {vpiConcatOp, "concat"}, {vpiMultiConcatOp, "replicate"},
};

static char out[512];

static void append(const char *s)
{
    strncat(out, s, sizeof out - strlen(out) - 1);
}

static void walk(vpiHandle h)
{
    char buf[64];
    int i, first = 1;
    vpiHandle it, operand;
    s_vpi_value v;

    switch (vpi_get(vpiType, h)) {
    case vpiOperation:
        for (i = 0; i < (int)(sizeof ops / sizeof ops[0]); i++)
            if (ops[i].type == vpi_get(vpiOpType, h))
                break;
        append(i < (int)(sizeof ops / sizeof ops[0]) ? ops[i].name : "other");
        append("(");
        it = vpi_iterate(vpiOperand, h);
        while (it && (operand = vpi_scan(it)) != NULL) {
            if (!first)
                append(", ");
            first = 0;
            walk(operand);
        }
        append(")");
        break;
    case vpiConstant:
        v.format = vpiIntVal;
        vpi_get_value(h, &v);
        snprintf(buf, sizeof buf, "%d", (int)v.value.integer);
        append(buf);
        break;
    default:
        append(vpi_get_str(vpiName, h) ? vpi_get_str(vpiName, h) : "?");
        break;
    }
}

static PLI_INT32 tree_calltf(PLI_BYTE8 *user_data)
{
    vpiHandle it = vpi_iterate(vpiArgument, vpi_handle(vpiSysTfCall, NULL));
    vpiHandle arg = it ? vpi_scan(it) : NULL;
    s_vpi_value v;

    (void)user_data;
    if (arg == NULL)
        return 0;
    vpi_free_object(it);
    out[0] = '\0';
    walk(arg);
    v.format = vpiIntVal;
    vpi_get_value(arg, &v);
    vpi_printf("%s = %d\n", out, (int)v.value.integer);
    return 0;
}

static void register_all(void)
{
    s_vpi_systf_data d;
    memset(&d, 0, sizeof d);
    d.type = vpiSysTask;
    d.tfname = (PLI_BYTE8 *)"$vt_tree";
    d.calltf = tree_calltf;
    vpi_register_systf(&d);
}

void (*vlog_startup_routines[])(void) = {register_all, 0};

#ifdef __cplusplus
}
#endif
