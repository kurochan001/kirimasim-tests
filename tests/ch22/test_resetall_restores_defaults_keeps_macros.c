/* VPI application of test_resetall_restores_defaults_keeps_macros
 * (IEEE 1800-2023 22.3, 22.10, 37.10): prints vpiCellInstance of the
 * instances of the modules defined before and after `resetall. */
#include <stdio.h>
#include <string.h>
#include "vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

static const char *const names[] = {"u_before", "h_before", "u_after", "h_after"};

static PLI_INT32 cells_calltf(PLI_BYTE8 *user_data)
{
    char path[128];
    int i;

    (void)user_data;
    for (i = 0; i < (int)(sizeof names / sizeof names[0]); i++) {
        vpiHandle h;
        snprintf(path, sizeof path, "test_resetall_restores_defaults_keeps_macros.%s",
                 names[i]);
        h = vpi_handle_by_name((PLI_BYTE8 *)path, NULL);
        if (h == NULL)
            vpi_printf("%s: not found\n", names[i]);
        else
            vpi_printf("%s: cell instance %d\n", names[i], (int)vpi_get(vpiCellInstance, h));
    }
    return 0;
}

static void register_all(void)
{
    s_vpi_systf_data d;
    memset(&d, 0, sizeof d);
    d.type = vpiSysTask;
    d.tfname = (PLI_BYTE8 *)"$vt_cells";
    d.calltf = cells_calltf;
    vpi_register_systf(&d);
}

void (*vlog_startup_routines[])(void) = {register_all, 0};

#ifdef __cplusplus
}
#endif
