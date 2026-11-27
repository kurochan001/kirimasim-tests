#include <stddef.h>
#include <stdio.h>
#include "vpi_user.h"

#ifndef cbNBASynch
#define cbNBASynch 30
#endif

static const PLI_INT32 reasons[] = {cbAtStartOfSimTime, cbNBASynch, cbAtEndOfSimTime, cbReadOnlySynch};
static const char *names[] = {"pre-active", "pre-nba", "pre-postponed", "postponed"};

static int read_variable(const char *name)
{
    char path[64];
    snprintf(path, sizeof path, "region_control_top.%s", name);
    vpiHandle handle = vpi_handle_by_name(path, NULL);
    if (!handle)
        return -1;
    s_vpi_value value = {.format = vpiIntVal};
    vpi_get_value(handle, &value);
    return value.value.integer;
}

static PLI_INT32 observe(p_cb_data data)
{
    int index = (int)(data->user_data - (PLI_BYTE8 *)reasons);
    if (index < 2) {
        vpi_printf("%s t=%u level=%d mirror=%d\n", names[index], (unsigned)data->time->low,
                   read_variable("level"), read_variable("mirror"));
    } else {
        vpi_printf("%s t=%u level=%d p=%d back=%d\n", names[index], (unsigned)data->time->low,
                   read_variable("level"), read_variable("p"), read_variable("back"));
    }
    return 0;
}

static PLI_INT32 register_callbacks(PLI_BYTE8 *unused)
{
    (void)unused;
    vpiHandle call = vpi_handle(vpiSysTfCall, NULL);
    vpiHandle args = call ? vpi_iterate(vpiArgument, call) : NULL;
    vpiHandle tick = args ? vpi_scan(args) : NULL;
    if (!tick)
        return 0;
    s_vpi_value slot = {.format = vpiIntVal};
    vpi_get_value(tick, &slot);
    vpi_release_handle(args);

    s_vpi_time at = {.type = vpiSimTime, .low = (PLI_UINT32)slot.value.integer};
    for (size_t i = 0; i < sizeof reasons / sizeof reasons[0]; ++i) {
        s_cb_data data = {.reason = reasons[i], .cb_rtn = observe, .time = &at, .user_data = (PLI_BYTE8 *)reasons + i};
        if (!vpi_register_cb(&data))
            vpi_printf("%s callback unavailable\n", names[i]);
    }
    return 0;
}

static void install(void)
{
    s_vpi_systf_data data = {.type = vpiSysTask, .tfname = "$observe_region_slot", .calltf = register_callbacks};
    vpi_register_systf(&data);
}

void (*vlog_startup_routines[])(void) = {install, NULL};
