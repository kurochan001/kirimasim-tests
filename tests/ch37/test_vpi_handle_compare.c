/* VPI application of test_vpi_handle_compare (IEEE 1800-2023 37.2). */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

#define TOP "test_vpi_handle_compare"

static void compare(const char *what, vpiHandle a, vpiHandle b)
{
    if (a == NULL || b == NULL)
        vpi_printf("%s: a handle is NULL\n", what);
    else
        vpi_printf("%s: %d\n", what, (int)vpi_compare_objects(a, b));
}

static PLI_INT32 compare_calltf(PLI_BYTE8 *user_data)
{
    vpiHandle top = vpi_handle_by_name((PLI_BYTE8 *)TOP, NULL);
    vpiHandle r = vpi_handle_by_name((PLI_BYTE8 *)TOP ".r", NULL);
    vpiHandle s = vpi_handle_by_name((PLI_BYTE8 *)TOP ".s", NULL);
    vpiHandle r_in_top = top ? vpi_handle_by_name((PLI_BYTE8 *)"r", top) : NULL;
    vpiHandle r_scanned = NULL, h, it, bit;

    (void)user_data;
    it = top ? vpi_iterate(vpiReg, top) : NULL;
    while (it && (h = vpi_scan(it)) != NULL)
        if (strcmp(vpi_get_str(vpiName, h), "r") == 0)
            r_scanned = h;
    bit = r ? vpi_handle_by_index(r, 3) : NULL;

    compare("r by full name, r by name in the module", r, r_in_top);
    compare("r by full name, r by iteration", r, r_scanned);
    compare("r by full name, parent of r[3]", r, bit ? vpi_handle(vpiParent, bit) : NULL);
    compare("module by name, module of r", top, r ? vpi_handle(vpiModule, r) : NULL);
    compare("r, s", r, s);
    compare("r, r[3]", r, bit);
    return 0;
}

static void register_all(void)
{
    s_vpi_systf_data d;
    memset(&d, 0, sizeof d);
    d.type = vpiSysTask;
    d.tfname = (PLI_BYTE8 *)"$vt_compare";
    d.calltf = compare_calltf;
    vpi_register_systf(&d);
}

void (*vlog_startup_routines[])(void) = {register_all, 0};

#ifdef __cplusplus
}
#endif
