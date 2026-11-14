/* VPI application of test_vpi_put_delays_tchk_limit_counts (IEEE 1800-2023 38.10, 38.32). */
#include <string.h>
#include "vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

#define COUNT 3

static const PLI_INT32 kinds[COUNT] = {vpiHold, vpiSetupHold, vpiRecrem};
static const char *const labels[COUNT] = {"$hold", "$setuphold", "$recrem"};
static const PLI_INT32 limits[COUNT] = {1, 2, 2};
static const double new_values[COUNT][2] = {{8.0, 0.0}, {9.0, 10.0}, {11.0, 12.0}};

static void read_limits(vpiHandle tchk, PLI_INT32 count)
{
    s_vpi_time da[2];
    s_vpi_delay d;
    int k;

    memset(&d, 0, sizeof d);
    memset(da, 0, sizeof da);
    d.da = da;
    d.no_of_delays = count;
    d.time_type = vpiScaledRealTime;
    vpi_get_delays(tchk, &d);
    for (k = 0; k < count; k++)
        vpi_printf((PLI_BYTE8 *)" %.0f", da[k].real);
}

static void put_limits(vpiHandle tchk, PLI_INT32 count, const double *values)
{
    s_vpi_time da[2];
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
    vpi_put_delays(tchk, &d);
}

static PLI_INT32 at_1(p_cb_data cb)
{
    vpiHandle cell = vpi_handle_by_name(
        (PLI_BYTE8 *)"test_vpi_put_delays_tchk_limit_counts.u1", NULL);
    vpiHandle found[COUNT] = {NULL, NULL, NULL};
    vpiHandle it = cell ? vpi_iterate(vpiTchk, cell) : NULL;
    vpiHandle tchk;
    int k;

    (void)cb;
    while (it != NULL && (tchk = vpi_scan(it)) != NULL)
        for (k = 0; k < COUNT; k++)
            if (vpi_get(vpiTchkType, tchk) == kinds[k])
                found[k] = tchk;
    for (k = 0; k < COUNT; k++) {
        if (found[k] == NULL) {
            vpi_printf((PLI_BYTE8 *)"%s not found\n", labels[k]);
            continue;
        }
        vpi_printf((PLI_BYTE8 *)"%s: old", labels[k]);
        read_limits(found[k], limits[k]);
        put_limits(found[k], limits[k], new_values[k]);
        vpi_printf((PLI_BYTE8 *)", new");
        read_limits(found[k], limits[k]);
        vpi_printf((PLI_BYTE8 *)"\n");
    }
    return 0;
}

static PLI_INT32 on_start(p_cb_data data)
{
    static s_vpi_time one;
    s_cb_data cb;

    (void)data;
    one.type = vpiSimTime;
    one.high = 0;
    one.low = 1;
    memset(&cb, 0, sizeof cb);
    cb.reason = cbAfterDelay;
    cb.cb_rtn = at_1;
    cb.time = &one;
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
