#include <stddef.h>
#include <string.h>
#include "vpi_user.h"
#include "sv_vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

static int read_marker(vpiHandle unit)
{
    vpiHandle variables = vpi_iterate(vpiVariables, unit), variable;
    if (variables == NULL)
        return -1;
    while ((variable = vpi_scan(variables)) != NULL) {
        const PLI_BYTE8 *name = vpi_get_str(vpiName, variable);
        if (name != NULL && strcmp((const char *)name, "unit_marker") == 0) {
            s_vpi_value value = {0};
            value.format = vpiIntVal;
            vpi_get_value(variable, &value);
            vpi_release_handle(variables);
            return value.value.integer;
        }
    }
    return -1;
}

static PLI_INT32 check_units(PLI_BYTE8 *unused)
{
    vpiHandle instances = vpi_iterate(vpiInstance, NULL), instance;
    int units = 0, first = 0, second = 0, other = 0;
    (void)unused;

    if (instances == NULL)
        return 0;
    while ((instance = vpi_scan(instances)) != NULL) {
        if (vpi_get(vpiType, instance) != vpiPackage || !vpi_get(vpiUnit, instance))
            continue;
        int value = read_marker(instance);
        units++;
        first += value == 23;
        second += value == 57;
        other += value != 23 && value != 57;
    }
    vpi_printf("matching units=%d first=%d second=%d other=%d\n",
               units, first, second, other);
    return 0;
}

static void register_task(void)
{
    s_vpi_systf_data task = {0};
    task.type = vpiSysTask;
    task.tfname = (PLI_BYTE8 *)"$vt_check_units";
    task.calltf = check_units;
    vpi_register_systf(&task);
}

void (*vlog_startup_routines[])(void) = {register_task, NULL};

#ifdef __cplusplus
}
#endif
