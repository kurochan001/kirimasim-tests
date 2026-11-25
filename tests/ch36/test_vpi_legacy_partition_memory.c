#define VPI_COMPATIBILITY_VERSION_1364v1995 1
#include "vpi_user.h"

static PLI_INT32 report_memory(p_cb_data callback)
{
    (void)callback;
    vpiHandle memory = vpi_handle_by_name(
        (PLI_BYTE8 *)"test_vpi_legacy_partition_memory.legacy.samples", 0);
    vpiHandle first = memory ? vpi_handle_by_index(memory, 0) : 0;
    vpiHandle second = memory ? vpi_handle_by_index(memory, 1) : 0;
    s_vpi_value left = {0}, right = {0};
    left.format = vpiIntVal;
    right.format = vpiIntVal;
    if (first)
        vpi_get_value(first, &left);
    if (second)
        vpi_get_value(second, &right);
    vpi_printf("legacy memory=%d words=%d,%d samples=%d,%d\n",
               memory && vpi_get(vpiType, memory) == vpiMemory,
               first && vpi_get(vpiType, first) == vpiMemoryWord,
               second && vpi_get(vpiType, second) == vpiMemoryWord,
               (int)left.value.integer, (int)right.value.integer);
    return 0;
}

static void register_test(void)
{
    s_cb_data end = {0};
    end.reason = cbEndOfSimulation;
    end.cb_rtn = report_memory;
    vpi_register_cb(&end);
}

void (*vlog_startup_routines[])(void) = {register_test, 0};
