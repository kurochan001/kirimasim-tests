/* VPI application of test_vpi_net_driver_objects (IEEE 1800-2023 37.16, 37.46). */
#include <stdio.h>
#include <string.h>
#include "vpi_user.h"
#include "sv_vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

#define TOP "test_vpi_net_driver_objects"
#define MAX 8

static const char *sprop(PLI_INT32 property, vpiHandle h)
{
    PLI_BYTE8 *s = h != NULL ? vpi_get_str(property, h) : NULL;
    return s != NULL ? s : "(none)";
}

static vpiHandle find(const char *name)
{
    char full[128];
    snprintf(full, sizeof full, "%s.%s", TOP, name);
    return vpi_handle_by_name((PLI_BYTE8 *)full, NULL);
}

static PLI_INT32 drv_calltf(PLI_BYTE8 *user_data)
{
    vpiHandle w = find("w"), it, d;
    int n = 0, i;
    char kinds[MAX][64];

    (void)user_data;
    it = w != NULL ? vpi_iterate(vpiDriver, w) : NULL;
    while (it != NULL && (d = vpi_scan(it)) != NULL && n < MAX)
        snprintf(kinds[n++], sizeof kinds[0], "%s", sprop(vpiType, d));
    vpi_printf((PLI_BYTE8 *)"drivers of w: %d", n);
    for (i = 0; i < n; i++)
        vpi_printf((PLI_BYTE8 *)" %s", kinds[i]);
    vpi_printf((PLI_BYTE8 *)"\n");

    {
        vpiHandle bit = w != NULL ? vpi_handle_by_index(w, 0) : NULL;
        int m = 0;
        char bits[MAX][64];

        it = bit != NULL ? vpi_iterate(vpiDriver, bit) : NULL;
        while (it != NULL && (d = vpi_scan(it)) != NULL && m < MAX)
            snprintf(bits[m++], sizeof bits[0], "%s offset %d", sprop(vpiType, d),
                     (int)vpi_get(vpiOffset, d));
        vpi_printf((PLI_BYTE8 *)"driver of w[0]: %d", m);
        for (i = 0; i < m; i++)
            vpi_printf((PLI_BYTE8 *)" %s", bits[i]);
        vpi_printf((PLI_BYTE8 *)"\n");
    }
    return 0;
}

static void register_all(void)
{
    s_vpi_systf_data d;
    memset(&d, 0, sizeof d);
    d.type = vpiSysTask;
    d.tfname = (PLI_BYTE8 *)"$vt_netdrv";
    d.calltf = drv_calltf;
    vpi_register_systf(&d);
}

void (*vlog_startup_routines[])(void) = {register_all, 0};

#ifdef __cplusplus
}
#endif
