/* VPI application of test_vpi_put_delays_layout_flags (38.32). */
#include <stdio.h>
#include <string.h>
#include "vpi_user.h"

/* SAME_TYPE(e, T) is 1 when the unevaluated expression e has exactly type T. */
#ifdef __cplusplus
template <typename A, typename B> struct vt_same { enum { value = 0 }; };
template <typename A> struct vt_same<A, A> { enum { value = 1 }; };
#define SAME_TYPE(e, T) ((int)vt_same<decltype(e), T>::value)
#else
#define SAME_TYPE(e, T) _Generic((e), T: 1, default: 0)
#endif

#ifdef __cplusplus
extern "C" {
#endif


static vpiHandle first_path(void)
{
    vpiHandle mod = vpi_handle_by_name(
        (PLI_BYTE8 *)"test_vpi_put_delays_layout_flags", NULL);
    vpiHandle it = vpi_iterate(vpiModPath, mod);

    return it != NULL ? vpi_scan(it) : NULL;
}

static void put(vpiHandle path, int count, int mtm, int pulsere,
                const double *values)
{
    s_vpi_time da[24];
    s_vpi_delay d;
    int k, n = count * (mtm && pulsere ? 9 : (mtm || pulsere ? 3 : 1));

    memset(&d, 0, sizeof d);
    memset(da, 0, sizeof da);
    for (k = 0; k < n; k++) {
        da[k].type = vpiScaledRealTime;
        da[k].real = values[k];
    }
    d.da = da;
    d.no_of_delays = count;
    d.time_type = vpiScaledRealTime;
    d.mtm_flag = mtm;
    d.pulsere_flag = pulsere;
    vpi_put_delays(path, &d);
}

static void show(const char *tag, vpiHandle path, int count, int mtm,
                 int pulsere)
{
    s_vpi_time da[24];
    s_vpi_delay d;
    int k, n = count * (mtm && pulsere ? 9 : (mtm || pulsere ? 3 : 1));

    memset(&d, 0, sizeof d);
    for (k = 0; k < 24; k++) {
        memset(&da[k], 0, sizeof da[k]);
        da[k].real = -1.0;
    }
    d.da = da;
    d.no_of_delays = count;
    d.time_type = vpiScaledRealTime;
    d.mtm_flag = mtm;
    d.pulsere_flag = pulsere;
    vpi_get_delays(path, &d);
    vpi_printf((PLI_BYTE8 *)"%s:", tag);
    for (k = 0; k < n; k++)
        vpi_printf((PLI_BYTE8 *)" %.0f", da[k].real);
    vpi_printf((PLI_BYTE8 *)"\n");
}

static PLI_INT32 put_calltf(PLI_BYTE8 *user_data)
{
    vpiHandle path = first_path();
    double both[18];
    int k;

    (void)user_data;
    if (path == NULL) {
        vpi_printf((PLI_BYTE8 *)"no module path\n");
        return 0;
    }
    vpi_printf((PLI_BYTE8 *)"vpi_put_delays is void (*)(vpiHandle, p_vpi_delay): %d\n",
               SAME_TYPE(&vpi_put_delays, void (*)(vpiHandle, p_vpi_delay)));

    {
        const double mtm[6] = {5, 6, 7, 8, 9, 10};
        put(path, 2, 1, 0, mtm);
        show("mtm", path, 2, 1, 0);
    }
    {
        const double pulse[6] = {5, 2, 3, 8, 2, 3};
        put(path, 2, 0, 1, pulse);
        show("pulse", path, 2, 0, 1);
    }
    for (k = 0; k < 18; k++)
        both[k] = k + 1;
    put(path, 2, 1, 1, both);
    show("both", path, 2, 1, 1);
    {
        const double delays[2] = {11, 13};
        const double limits[6] = {5, 2, 3, 8, 2, 3};
        put(path, 2, 0, 1, limits);
        put(path, 2, 0, 0, delays);
        show("delays only", path, 2, 0, 0);
        show("limits kept", path, 2, 0, 1);
    }
    return 0;
}

static void register_all(void)
{
    s_vpi_systf_data d;

    memset(&d, 0, sizeof d);
    d.type = vpiSysTask;
    d.tfname = (PLI_BYTE8 *)"$vt_put";
    d.calltf = put_calltf;
    vpi_register_systf(&d);
}

void (*vlog_startup_routines[])(void) = {register_all, 0};

#ifdef __cplusplus
}
#endif
