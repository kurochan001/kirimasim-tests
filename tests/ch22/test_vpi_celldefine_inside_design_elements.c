/* VPI application of test_vpi_celldefine_inside_design_elements
   (IEEE 1800-2023 22.10): prints vpiCellInstance (37.10) of the instances
   whose modules lie wholly inside or wholly outside the cell region. */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

static const char *const names[] = {
    "test_vpi_celldefine_inside_design_elements",
    "test_vpi_celldefine_inside_design_elements.c1",
    "test_vpi_celldefine_inside_design_elements.p1",
};

static PLI_INT32 cells_calltf(PLI_BYTE8 *user_data)
{
    int i;

    (void)user_data;
    for (i = 0; i < (int)(sizeof names / sizeof names[0]); i++) {
        vpiHandle h = vpi_handle_by_name((PLI_BYTE8 *)names[i], NULL);
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
