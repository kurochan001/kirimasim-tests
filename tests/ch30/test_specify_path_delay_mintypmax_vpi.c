/* VPI application of test_specify_path_delay_mintypmax_vpi (IEEE 1800-2023
 * 30.5.1 and 38.10). It reads the delays of the one module path of u1, u2
 * and u3 with mtm_flag set and prints the min, typ and max elements. */
#include <stdio.h>
#include <string.h>
#include "vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

#define TOP "test_specify_path_delay_mintypmax_vpi"

/* The first module path of the instance, or NULL. */
static vpiHandle path_of(const char *instance)
{
    char name[96];
    vpiHandle module, it;

    snprintf(name, sizeof name, "%s.%s", TOP, instance);
    module = vpi_handle_by_name((PLI_BYTE8 *)name, NULL);
    if (module == NULL)
        return NULL;
    it = vpi_iterate(vpiModPath, module);
    return it != NULL ? vpi_scan(it) : NULL;
}

/* Reads count delays of the path of instance with mtm_flag set into da,
 * which has room for 3 * count elements. Returns 0 when there is no path. */
static int read_mtm(const char *instance, int count, s_vpi_time *da)
{
    s_vpi_delay d;
    vpiHandle path = path_of(instance);

    if (path == NULL) {
        vpi_printf((PLI_BYTE8 *)"%s: path not found\n", instance);
        return 0;
    }
    memset(da, 0, 3 * count * sizeof da[0]);
    memset(&d, 0, sizeof d);
    d.da = da;
    d.no_of_delays = count;
    d.time_type = vpiScaledRealTime;
    d.mtm_flag = 1;
    d.append_flag = 0;
    d.pulsere_flag = 0;
    vpi_get_delays(path, &d);
    return 1;
}

static PLI_INT32 mtm_calltf(PLI_BYTE8 *user_data)
{
    s_vpi_time da[6];
    int k;

    (void)user_data;
    if (read_mtm("u1", 1, da))
        vpi_printf((PLI_BYTE8 *)"u1 min typ max: %g %g %g\n", da[0].real, da[1].real,
                   da[2].real);
    if (read_mtm("u2", 2, da)) {
        vpi_printf((PLI_BYTE8 *)"u2 rise min typ max, fall min typ max:");
        for (k = 0; k < 6; k++)
            vpi_printf((PLI_BYTE8 *)" %g", da[k].real);
        vpi_printf((PLI_BYTE8 *)"\n");
    }
    if (read_mtm("u3", 1, da))
        vpi_printf((PLI_BYTE8 *)"u3 typ: %g\n", da[1].real);
    return 0;
}

static void register_all(void)
{
    s_vpi_systf_data d;

    memset(&d, 0, sizeof d);
    d.type = vpiSysTask;
    d.tfname = (PLI_BYTE8 *)"$vt_mtm";
    d.calltf = mtm_calltf;
    vpi_register_systf(&d);
}

void (*vlog_startup_routines[])(void) = {register_all, 0};

#ifdef __cplusplus
}
#endif
