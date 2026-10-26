/* VPI application of test_vpi_clocking_scope_group (IEEE 1800-2023 37.12). */
#include <stdio.h>
#include <string.h>
#include "vpi_user.h"
#include "sv_vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

#define TOP "test_vpi_clocking_scope_group"

static const char *sprop(PLI_INT32 property, vpiHandle h)
{
    PLI_BYTE8 *s = h != NULL ? vpi_get_str(property, h) : NULL;
    return s != NULL ? s : "(none)";
}

static PLI_INT32 clock_calltf(PLI_BYTE8 *user_data)
{
    vpiHandle top = vpi_handle_by_name((PLI_BYTE8 *)TOP, NULL);
    vpiHandle it = top != NULL ? vpi_iterate(vpiInternalScope, top) : NULL, h;

    (void)user_data;
    while (it != NULL && (h = vpi_scan(it)) != NULL)
        if (vpi_get(vpiType, h) == vpiClockingBlock
            && strcmp(sprop(vpiName, h), "cb") == 0) {
            vpiHandle mod = vpi_handle(vpiModule, h);
            vpi_printf((PLI_BYTE8 *)"clocking block %s: type %s, full name %s, "
                       "module is top %d\n", sprop(vpiName, h), sprop(vpiType, h),
                       sprop(vpiFullName, h),
                       mod != NULL && top != NULL && vpi_compare_objects(mod, top));
            return 0;
        }
    vpi_printf((PLI_BYTE8 *)"clocking block cb not found\n");
    return 0;
}

static void register_all(void)
{
    s_vpi_systf_data d;
    memset(&d, 0, sizeof d);
    d.type = vpiSysTask;
    d.tfname = (PLI_BYTE8 *)"$vt_clock";
    d.calltf = clock_calltf;
    vpi_register_systf(&d);
}

void (*vlog_startup_routines[])(void) = {register_all, 0};

#ifdef __cplusplus
}
#endif
