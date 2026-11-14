/* VPI application of test_vpi_put_delays_primitive_counts (IEEE 1800-2023 38.10, 38.32). */
#include <string.h>
#include "vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

#define TOP "test_vpi_put_delays_primitive_counts."

static void show(vpiHandle g, const char *name, const char *what, PLI_INT32 count)
{
    s_vpi_time da[3];
    s_vpi_delay d;
    int k;

    memset(&d, 0, sizeof d);
    memset(da, 0, sizeof da);
    d.da = da;
    d.no_of_delays = count;
    d.time_type = vpiScaledRealTime;
    vpi_get_delays(g, &d);
    vpi_printf((PLI_BYTE8 *)"8: %s %s delays", name, what);
    for (k = 0; k < count; k++)
        vpi_printf((PLI_BYTE8 *)" %.0f", da[k].real);
    vpi_printf((PLI_BYTE8 *)"\n");
}

static void put(vpiHandle g, PLI_INT32 count, const double *values)
{
    s_vpi_time da[3];
    s_vpi_delay d;
    int k;

    memset(&d, 0, sizeof d);
    memset(da, 0, sizeof da);
    for (k = 0; k < count; k++) {
        da[k].type = vpiScaledRealTime;
        da[k].real = values[k];
    }
    d.da = da;
    d.no_of_delays = count;
    d.time_type = vpiScaledRealTime;
    vpi_put_delays(g, &d);
}

static PLI_INT32 at_8(p_cb_data cb)
{
    static const double two[2] = {7.0, 9.0};
    static const double three[3] = {5.0, 8.0, 11.0};
    vpiHandle g2 = vpi_handle_by_name((PLI_BYTE8 *)TOP "g2", NULL);
    vpiHandle g3 = vpi_handle_by_name((PLI_BYTE8 *)TOP "g3", NULL);

    (void)cb;
    if (g2 == NULL || g3 == NULL) {
        vpi_printf((PLI_BYTE8 *)"gates not found\n");
        return 0;
    }
    show(g2, "g2", "old", 2);
    show(g3, "g3", "old", 3);
    put(g2, 2, two);
    put(g3, 3, three);
    show(g2, "g2", "new", 2);
    show(g3, "g3", "new", 3);
    return 0;
}

static PLI_INT32 on_start(p_cb_data data)
{
    static s_vpi_time eight;
    s_cb_data cb;

    (void)data;
    eight.type = vpiSimTime;
    eight.high = 0;
    eight.low = 8;
    memset(&cb, 0, sizeof cb);
    cb.reason = cbAfterDelay;
    cb.cb_rtn = at_8;
    cb.time = &eight;
    vpi_register_cb(&cb);
    return 0;
}

static void register_all(void)
{
    s_cb_data cb;

    memset(&cb, 0, sizeof cb);
    cb.reason = cbStartOfSimulation;
    cb.cb_rtn = on_start;
    vpi_register_cb(&cb);
}

void (*vlog_startup_routines[])(void) = {register_all, 0};

#ifdef __cplusplus
}
#endif
