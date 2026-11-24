#include <stdio.h>
#include "sv_vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

#define TOP "test_vpi_instance_binding_properties_follow_selected_rules"

static void read_string(vpiHandle instance, PLI_INT32 property, char *value, size_t length)
{
    const char *text = vpi_get_str(property, instance);
    snprintf(value, length, "%s", text != NULL ? text : "<null>");
}

static void report_binding(const char *name, const char *path)
{
    vpiHandle inst = vpi_handle_by_name((PLI_BYTE8 *)path, NULL);
    char library[48], cell[48], config[48];
    if (inst == NULL || vpi_get(vpiType, inst) != vpiModule) {
        vpi_printf("%s: module handle unavailable\n", name);
        return;
    }
    read_string(inst, vpiLibrary, library, sizeof library);
    read_string(inst, vpiCell, cell, sizeof cell);
    read_string(inst, vpiConfig, config, sizeof config);
    vpi_printf("%s: library=%s cell=%s config=%s\n", name, library, cell, config);
}

static PLI_INT32 calltf(PLI_BYTE8 *unused)
{
    (void)unused;
    report_binding("plain", TOP ".plain");
    report_binding("replaced", TOP ".replaced");
    report_binding("nested", TOP ".branch.nested");
    return 0;
}

static void register_task(void)
{
    s_vpi_systf_data task = {0};
    task.type = vpiSysTask;
    task.tfname = "$vt_report_binding_properties";
    task.calltf = calltf;
    vpi_register_systf(&task);
}

void (*vlog_startup_routines[])(void) = {register_task, NULL};

#ifdef __cplusplus
}
#endif
