#include <stddef.h>
#include <string.h>
#include "vpi_user.h"
#include "sv_vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

#define SINK "test_vpi_indexed_ports_and_input_delays.sink"

static vpiHandle named_port(vpiHandle instance, const char *name)
{
    vpiHandle ports = vpi_iterate(vpiPort, instance), port;
    while (ports != NULL && (port = vpi_scan(ports)) != NULL) {
        const char *found = vpi_get_str(vpiName, port);
        if (found != NULL && strcmp(name, found) == 0) {
            vpi_release_handle(ports);
            return port;
        }
    }
    return NULL;
}

static int has_parent(vpiHandle bit, vpiHandle port)
{
    if (bit == NULL || vpi_get(vpiType, bit) != vpiPortBit)
        return 0;
    vpiHandle parent = vpi_handle(vpiParent, bit);
    return parent != NULL && vpi_compare_objects(parent, port);
}

static void examine_indices(vpiHandle single, vpiHandle multi)
{
    if (single == NULL || multi == NULL) {
        vpi_printf("missing vector ports\n");
        return;
    }

    vpiHandle high = vpi_handle_by_index(single, 7);
    vpiHandle low = vpi_handle_by_index(single, 4);
    vpiHandle out_of_range = vpi_handle_by_index(single, 3);
    int distinct = high != NULL && low != NULL && !vpi_compare_objects(high, low);
    vpi_printf("single high=%d low=%d distinct=%d outside=%d\n",
               has_parent(high, single), has_parent(low, single), distinct, out_of_range == NULL);

    PLI_INT32 upper[2] = {2, 5}, lower[2] = {1, 4}, reversed[2] = {5, 2};
    high = vpi_handle_by_multi_index(multi, 2, upper);
    low = vpi_handle_by_multi_index(multi, 2, lower);
    vpiHandle wrong_order = vpi_handle_by_multi_index(multi, 2, reversed);
    distinct = high != NULL && low != NULL && !vpi_compare_objects(high, low);
    vpi_printf("multi high=%d low=%d distinct=%d reversed=%d\n",
               has_parent(high, multi), has_parent(low, multi), distinct, wrong_order == NULL);
}

static void report_delays(const char *label, vpiHandle port)
{
    s_vpi_time values[2] = {{vpiSimTime, 0, 99, 0.0}, {vpiSimTime, 0, 99, 0.0}};
    s_vpi_delay info = {values, 2, vpiSimTime, 0, 0, 0};
    vpi_get_delays(port, &info);
    vpi_printf("%s rise=%u fall=%u\n", label, (unsigned)values[0].low, (unsigned)values[1].low);
}

static PLI_INT32 configure(p_cb_data cb)
{
    (void)cb;
    vpiHandle sink = vpi_handle_by_name((PLI_BYTE8 *)SINK, NULL);
    if (sink == NULL) {
        vpi_printf("missing module instance\n");
        return 0;
    }
    vpiHandle input = named_port(sink, "direct");
    vpiHandle adjacent = named_port(sink, "adjacent");
    if (input == NULL || adjacent == NULL) {
        vpi_printf("missing scalar ports\n");
        return 0;
    }
    vpi_printf("ordinary input=%d peer=%d\n",
               vpi_get(vpiPortType, input) == vpiPort && vpi_get(vpiDirection, input) == vpiInput,
               vpi_get(vpiPortType, adjacent) == vpiPort && vpi_get(vpiDirection, adjacent) == vpiInput);
    report_delays("before", input);
    s_vpi_time values[2] = {{vpiSimTime, 0, 3, 0.0}, {vpiSimTime, 0, 5, 0.0}};
    s_vpi_delay info = {values, 2, vpiSimTime, 0, 0, 0};
    vpi_put_delays(input, &info);
    report_delays("after", named_port(sink, "direct"));
    report_delays("untouched", adjacent);

    examine_indices(named_port(sink, "single_index"), named_port(sink, "multi_index"));
    return 0;
}

static void install(void)
{
    s_cb_data cb = {0};
    cb.reason = cbEndOfCompile;
    cb.cb_rtn = configure;
    vpi_register_cb(&cb);
}

void (*vlog_startup_routines[])(void) = {install, NULL};

#ifdef __cplusplus
}
#endif
