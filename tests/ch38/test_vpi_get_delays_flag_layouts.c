/* VPI application of test_vpi_get_delays_flag_layouts (IEEE 1800-2023
 * 38.10). */
#include <stdio.h>
#include <string.h>
#include "vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

#define TOP "test_vpi_get_delays_flag_layouts"
#define ROOM 24
#define FILL 0xA5

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

/* Reads two delays of the path of instance with the given flags, prints the
 * elements that Table 38-2 requires, and whether the later ones are intact. */
static void show(const char *instance, int mtm, int pulsere)
{
    s_vpi_time da[ROOM];
    s_vpi_delay d;
    vpiHandle path = path_of(instance);
    int per = mtm && pulsere ? 9 : (mtm || pulsere ? 3 : 1);
    int n = 2 * per, k, intact = 1;
    const unsigned char *bytes;

    if (path == NULL) {
        vpi_printf((PLI_BYTE8 *)"%s: path not found\n", instance);
        return;
    }
    memset(da, FILL, sizeof da);
    memset(&d, 0, sizeof d);
    d.da = da;
    d.no_of_delays = 2;
    d.time_type = vpiScaledRealTime;
    d.mtm_flag = mtm;
    d.append_flag = 0;
    d.pulsere_flag = pulsere;
    vpi_get_delays(path, &d);
    vpi_printf((PLI_BYTE8 *)"%s mtm_flag %d pulsere_flag %d, %d elements:", instance,
               mtm, pulsere, n);
    for (k = 0; k < n; k++)
        vpi_printf((PLI_BYTE8 *)" %g", da[k].real);
    vpi_printf((PLI_BYTE8 *)"\n");
    bytes = (const unsigned char *)&da[n];
    for (k = 0; k < (int)((ROOM - n) * sizeof da[0]); k++)
        if (bytes[k] != FILL)
            intact = 0;
    vpi_printf((PLI_BYTE8 *)"%s mtm_flag %d pulsere_flag %d, elements from da[%d] intact: %d\n",
               instance, mtm, pulsere, n, intact);
}

static PLI_INT32 layouts_calltf(PLI_BYTE8 *user_data)
{
    (void)user_data;
    show("u1", 0, 0);
    show("u1", 0, 1);
    show("u2", 1, 0);
    show("u2", 1, 1);
    return 0;
}

static void register_all(void)
{
    s_vpi_systf_data d;

    memset(&d, 0, sizeof d);
    d.type = vpiSysTask;
    d.tfname = (PLI_BYTE8 *)"$vt_layouts";
    d.calltf = layouts_calltf;
    vpi_register_systf(&d);
}

void (*vlog_startup_routines[])(void) = {register_all, 0};

#ifdef __cplusplus
}
#endif
