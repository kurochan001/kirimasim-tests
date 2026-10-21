/* VPI application of test_vpi_systf_override_display (IEEE 1800-2023 36.3.2). */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

static PLI_INT32 show_calltf(PLI_BYTE8 *user_data)
{
    vpiHandle it = vpi_iterate(vpiArgument, vpi_handle(vpiSysTfCall, NULL));
    vpiHandle arg;
    char line[256];
    int count = 0;

    line[0] = '\0';
    while (it != NULL && (arg = vpi_scan(it)) != NULL) {
        char item[64];
        s_vpi_value v;
        if (vpi_get(vpiType, arg) == vpiConstant && vpi_get(vpiConstType, arg) == vpiStringConst) {
            v.format = vpiStringVal;
            vpi_get_value(arg, &v);
            snprintf(item, sizeof item, " \"%s\"", v.value.str);
        } else {
            v.format = vpiIntVal;
            vpi_get_value(arg, &v);
            snprintf(item, sizeof item, " %d", (int)v.value.integer);
        }
        strncat(line, item, sizeof line - strlen(line) - 1);
        count++;
    }
    vpi_printf("user %s, %d arguments:%s\n", user_data, count, line);
    return 0;
}

static void override(const char *name)
{
    s_vpi_systf_data d;

    memset(&d, 0, sizeof d);
    d.type = vpiSysTask;
    d.tfname = (PLI_BYTE8 *)name;
    d.calltf = show_calltf;
    d.user_data = (PLI_BYTE8 *)name;
    vpi_register_systf(&d);
}

static void register_all(void)
{
    override("$display");
    override("$write");
}

void (*vlog_startup_routines[])(void) = {register_all, 0};

#ifdef __cplusplus
}
#endif
