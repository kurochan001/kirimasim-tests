/* VPI application of test_vpi_interconnect_array_ranges (IEEE 1800-2023 37.24). */
#include <stdio.h>
#include <string.h>
#include "vpi_user.h"
#include "sv_vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

#define TOP "test_vpi_interconnect_array_ranges"

static const char *sprop(PLI_INT32 property, vpiHandle h)
{
    PLI_BYTE8 *s = h != NULL ? vpi_get_str(property, h) : NULL;
    return s != NULL ? s : "(none)";
}

static int value(vpiHandle h)
{
    s_vpi_value v;

    if (h == NULL)
        return -1000;
    v.format = vpiIntVal;
    v.value.integer = -1000;
    vpi_get_value(h, &v);
    return (int)v.value.integer;
}

static void one(const char *name)
{
    char full[128];
    vpiHandle a;
    vpiHandle it, r;

    snprintf(full, sizeof full, "%s.%s", TOP, name);
    a = vpi_handle_by_name((PLI_BYTE8 *)full, NULL);
    if (a == NULL) {
        vpi_printf((PLI_BYTE8 *)"%s: not found\n", name);
        return;
    }
    vpi_printf((PLI_BYTE8 *)"%s: type %s, ranges", name, sprop(vpiType, a));
    it = vpi_iterate(vpiRange, a);
    if (it == NULL)
        vpi_printf((PLI_BYTE8 *)" none");
    else {
        while ((r = vpi_scan(it)) != NULL)
            vpi_printf((PLI_BYTE8 *)" %d:%d", value(vpi_handle(vpiLeftRange, r)),
                       value(vpi_handle(vpiRightRange, r)));
    }
    vpi_printf((PLI_BYTE8 *)"\n");
    vpi_printf((PLI_BYTE8 *)"%s: left %d, right %d\n", name,
               value(vpi_handle(vpiLeftRange, a)),
               value(vpi_handle(vpiRightRange, a)));
}

static PLI_INT32 range_calltf(PLI_BYTE8 *user_data)
{
    (void)user_data;
    one("ia");
    one("ib");
    return 0;
}

static void register_all(void)
{
    s_vpi_systf_data d;
    memset(&d, 0, sizeof d);
    d.type = vpiSysTask;
    d.tfname = (PLI_BYTE8 *)"$vt_icrange";
    d.calltf = range_calltf;
    vpi_register_systf(&d);
}

void (*vlog_startup_routines[])(void) = {register_all, 0};

#ifdef __cplusplus
}
#endif
