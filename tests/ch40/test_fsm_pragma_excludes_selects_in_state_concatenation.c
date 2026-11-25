/* IEEE 1800-2023 40.4.2–40.4.3: inspect the registered FSM state views. */
#include <stddef.h>
#include <string.h>
#include "sv_vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

#define TOP "test_fsm_pragma_excludes_selects_in_state_concatenation"

static int matches_name(vpiHandle object, const char *expected)
{
    const char *name = object ? vpi_get_str(vpiName, object) : NULL;
    return name && strcmp(name, expected) == 0;
}

static int concat_members(vpiHandle expression)
{
    vpiHandle iter = expression ? vpi_iterate(vpiOperand, expression) : NULL;
    vpiHandle operand;
    int count = 0, matches = 0;

    while (iter && (operand = vpi_scan(iter))) {
        if (count == 0)
            matches += matches_name(operand, "hi");
        if (count == 1)
            matches += matches_name(operand, "lo");
        count++;
    }
    return count == 2 && matches == 2;
}

static PLI_INT32 observe(p_cb_data callback)
{
    vpiHandle top = vpi_handle_by_name((PLI_BYTE8 *)TOP, NULL);
    vpiHandle iter = top ? vpi_iterate(vpiFsm, top) : NULL;
    vpiHandle object, whole = NULL, standalone = NULL;
    int bit_concat = 0, part_concat = 0;

    (void)callback;
    while (iter && (object = vpi_scan(iter))) {
        if (matches_name(object, "whole_fsm"))
            whole = vpi_handle(vpiFsmStateExpression, object);
        if (matches_name(object, "standalone_part_fsm"))
            standalone = vpi_handle(vpiFsmStateExpression, object);
        bit_concat += matches_name(object, "bit_fsm");
        part_concat += matches_name(object, "part_fsm");
    }
    vpi_printf("whole: concat=%d members=%d\n",
               whole && vpi_get(vpiType, whole) == vpiOperation &&
                   vpi_get(vpiOpType, whole) == vpiConcatOp,
               concat_members(whole));
    vpi_printf("standalone: part_select=%d width=%d\n",
               standalone && vpi_get(vpiType, standalone) == vpiPartSelect,
               standalone ? vpi_get(vpiSize, standalone) : -1);
    vpi_printf("concatenations registered: bit_select=%d part_select=%d\n", bit_concat, part_concat);
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

#ifdef __cplusplus
}
#endif
