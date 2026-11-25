/* IEEE 1800-2023 37.56: walk each clocked sequence to its body. */
#include <stddef.h>
#include <string.h>
#include "vpi_user.h"
#include "sv_vpi_user.h"

#define TOP "test_vpi_clocked_sequence_body"

static int named(vpiHandle object, const char *wanted)
{
    const char *name = object ? vpi_get_str(vpiName, object) : NULL;
    return name && strcmp(name, wanted) == 0;
}

static int operation(vpiHandle object, PLI_INT32 kind)
{
    return object && vpi_get(vpiType, object) == vpiOperation &&
           vpi_get(vpiOpType, object) == kind;
}

static int operands_match(vpiHandle op, const char *first, const char *second)
{
    vpiHandle iter = op ? vpi_iterate(vpiOperand, op) : NULL;
    vpiHandle operand;
    int count = 0, matches = 0;

    while (iter && (operand = vpi_scan(iter))) {
        if (count == 0)
            matches += named(operand, first);
        if (count == 1 && second)
            matches += named(operand, second);
        count++;
    }
    return count == (second ? 2 : 1) && matches == count;
}

static PLI_INT32 observe(p_cb_data callback)
{
    vpiHandle top = vpi_handle_by_name((PLI_BYTE8 *)TOP, NULL);
    vpiHandle iter = top ? vpi_iterate(vpiSequenceDecl, top) : NULL;
    vpiHandle declaration, sequence = NULL, segment;
    int segments = 0, clock_a = 0, clock_b = 0, body_a = 0, body_b = 0;

    (void)callback;
    while (iter && (declaration = vpi_scan(iter))) {
        if (named(declaration, "transfer"))
            sequence = vpi_handle(vpiExpr, declaration);
    }

    iter = sequence ? vpi_iterate(vpiClockedSeq, sequence) : NULL;
    while (iter && (segment = vpi_scan(iter))) {
        vpiHandle event = vpi_handle(vpiClockingEvent, segment);
        vpiHandle body = vpi_handle(vpiExpr, segment);
        segments++;
        if (vpi_get(vpiType, segment) != vpiClockedSeq)
            continue;
        if (operation(event, vpiPosedgeOp) && operands_match(event, "clk_a", NULL)) {
            clock_a++;
            body_a += operation(body, vpiLogAndOp) && operands_match(body, "data_a", "enable_a");
        }
        if (operation(event, vpiNegedgeOp) && operands_match(event, "clk_b", NULL)) {
            clock_b++;
            body_b += operation(body, vpiLogOrOp) && operands_match(body, "data_b", "enable_b");
        }
    }

    vpi_printf("multiclock=%d segments=%d\n",
               sequence && vpi_get(vpiType, sequence) == vpiMulticlockSequenceExpr, segments);
    vpi_printf("clock_a: edge=%d body=%d\n", clock_a, body_a);
    vpi_printf("clock_b: edge=%d body=%d\n", clock_b, body_b);
    return 0;
}

static void register_all(void)
{
    s_cb_data callback = {0};
    callback.reason = cbStartOfSimulation;
    callback.cb_rtn = observe;
    vpi_register_cb(&callback);
}

void (*vlog_startup_routines[])(void) = {register_all, NULL};
