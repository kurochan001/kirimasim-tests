/* VPI application of test_vpi_get_delays_tchk_limit_counts (IEEE 1800-2023
 * 38.10). */
#include <string.h>
#include "vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

#define CELL "test_vpi_get_delays_tchk_limit_counts.u1"
#define ROOM 8
#define FILL 0xA5

/* Reads count limits of a check and prints them and whether the elements
 * after them are intact. */
static void show(const char *label, vpiHandle tchk, int count)
{
    s_vpi_time da[ROOM];
    s_vpi_delay d;
    const unsigned char *bytes;
    int k, intact = 1;

    if (tchk == NULL) {
        vpi_printf((PLI_BYTE8 *)"%s: check not found\n", label);
        return;
    }
    memset(da, FILL, sizeof da);
    memset(&d, 0, sizeof d);
    d.da = da;
    d.no_of_delays = count;
    d.time_type = vpiScaledRealTime;
    d.mtm_flag = 0;
    d.append_flag = 0;
    d.pulsere_flag = 0;
    vpi_get_delays(tchk, &d);
    vpi_printf((PLI_BYTE8 *)"%s, no_of_delays %d:", label, count);
    for (k = 0; k < count; k++)
        vpi_printf((PLI_BYTE8 *)" %g", da[k].real);
    vpi_printf((PLI_BYTE8 *)"\n");
    bytes = (const unsigned char *)&da[count];
    for (k = 0; k < (int)((ROOM - count) * sizeof da[0]); k++)
        if (bytes[k] != FILL)
            intact = 0;
    vpi_printf((PLI_BYTE8 *)"%s, elements from da[%d] intact: %d\n", label, count, intact);
}

static PLI_INT32 limits_calltf(PLI_BYTE8 *user_data)
{
    vpiHandle cell = vpi_handle_by_name((PLI_BYTE8 *)CELL, NULL);
    vpiHandle it, h, setup = NULL, setuphold = NULL, recrem = NULL;

    (void)user_data;
    it = cell != NULL ? vpi_iterate(vpiTchk, cell) : NULL;
    while (it != NULL && (h = vpi_scan(it)) != NULL) {
        switch (vpi_get(vpiTchkType, h)) {
        case vpiSetup: setup = h; break;
        case vpiSetupHold: setuphold = h; break;
        case vpiRecrem: recrem = h; break;
        default: break;
        }
    }
    show("$setup", setup, 1);
    show("$setuphold", setuphold, 2);
    show("$recrem", recrem, 2);
    return 0;
}

static void register_all(void)
{
    s_vpi_systf_data d;

    memset(&d, 0, sizeof d);
    d.type = vpiSysTask;
    d.tfname = (PLI_BYTE8 *)"$vt_limits";
    d.calltf = limits_calltf;
    vpi_register_systf(&d);
}

void (*vlog_startup_routines[])(void) = {register_all, 0};

#ifdef __cplusplus
}
#endif
