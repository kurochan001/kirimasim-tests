/* IEEE 1800-2023 37.58: traverse vpiUse on each declared ref object. */
#include <stddef.h>
#include <string.h>
#include "vpi_user.h"
#include "sv_vpi_user.h"

#define TOP "test_vpi_ref_port_simple_expression_use"

static int same(vpiHandle left, vpiHandle right)
{
    return left && right && vpi_compare_objects(left, right);
}

static int named(vpiHandle object, const char *wanted)
{
    const char *name = object ? vpi_get_str(vpiName, object) : NULL;
    return name && strcmp(name, wanted) == 0;
}

static void observe_use(const char *label, vpiHandle ref, vpiHandle actual,
                        vpiHandle own_assignment, vpiHandle other_assignment)
{
    vpiHandle bound = ref ? vpi_handle(vpiActual, ref) : NULL;
    vpiHandle iter = ref ? vpi_iterate(vpiUse, ref) : NULL;
    vpiHandle use;
    int own = 0, other = 0;

    while (iter && (use = vpi_scan(iter))) {
        own += same(use, own_assignment);
        other += same(use, other_assignment);
    }
    vpi_printf("%s: ref=%d actual=%d own_use=%d other_use=%d\n", label,
               ref && vpi_get(vpiType, ref) == vpiRefObj, same(bound, actual), own, other);
}

static PLI_INT32 observe(p_cb_data callback)
{
    vpiHandle child = vpi_handle_by_name((PLI_BYTE8 *)TOP ".u", NULL);
    vpiHandle first = vpi_handle_by_name((PLI_BYTE8 *)TOP ".first", NULL);
    vpiHandle second = vpi_handle_by_name((PLI_BYTE8 *)TOP ".second", NULL);
    vpiHandle iter = child ? vpi_iterate(vpiPort, child) : NULL;
    vpiHandle port, left_ref = NULL, right_ref = NULL;
    vpiHandle assignment, left_use = NULL, right_use = NULL;

    (void)callback;
    while (iter && (port = vpi_scan(iter))) {
        int index = vpi_get(vpiPortIndex, port);
        if (index == 0)
            left_ref = vpi_handle(vpiLowConn, port);
        if (index == 1)
            right_ref = vpi_handle(vpiLowConn, port);
    }

    iter = child ? vpi_iterate(vpiContAssign, child) : NULL;
    while (iter && (assignment = vpi_scan(iter))) {
        vpiHandle lhs = vpi_handle(vpiLhs, assignment);
        if (named(lhs, "left_output"))
            left_use = assignment;
        if (named(lhs, "right_output"))
            right_use = assignment;
    }

    vpi_printf("controls: distinct_actuals=%d distinct_assignments=%d\n",
               first && second && !same(first, second),
               left_use && right_use && !same(left_use, right_use));
    observe_use("left", left_ref, first, left_use, right_use);
    observe_use("right", right_ref, second, right_use, left_use);
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
