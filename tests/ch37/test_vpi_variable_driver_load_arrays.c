/* VPI application of test_vpi_variable_driver_load_arrays (IEEE 1800-2023 37.21). */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "vpi_user.h"
#include "sv_vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

#define TOP "test_vpi_variable_driver_load_arrays"

static vpiHandle find(const char *name)
{
    char full[128];
    snprintf(full, sizeof full, "%s.%s", TOP, name);
    return vpi_handle_by_name((PLI_BYTE8 *)full, NULL);
}

static const char *name_of(vpiHandle h)
{
    const char *s = h != NULL ? vpi_get_str(vpiDecompile, h) : NULL;
    return s != NULL ? s : "NULL";
}

static int by_name(const void *a, const void *b)
{
    return strcmp((const char *)a, (const char *)b);
}

/* Prints the decompiled vpiLhs of each driver or the vpiRhs of each load. */
static void side(const char *label, const char *name, PLI_INT32 relation, PLI_INT32 which)
{
    vpiHandle obj = find(name);
    vpiHandle it = obj != NULL ? vpi_iterate(relation, obj) : NULL, h;
    char items[8][48];
    int n = 0, i;

    while (it != NULL && (h = vpi_scan(it)) != NULL) {
        vpiHandle side_h = vpi_handle(which, h);
        if (n < 8)
            snprintf(items[n++], sizeof items[0], "%s", name_of(side_h));
    }
    qsort(items, (size_t)n, sizeof items[0], by_name);
    vpi_printf((PLI_BYTE8 *)"%s of %s (%d):", label, name, n);
    for (i = 0; i < n; i++)
        vpi_printf((PLI_BYTE8 *)" %s", items[i]);
    vpi_printf((PLI_BYTE8 *)"\n");
}

static vpiHandle var_bit(vpiHandle var, int index)
{
    vpiHandle it = var != NULL ? vpi_iterate(vpiBit, var) : NULL, b;

    while (it != NULL && (b = vpi_scan(it)) != NULL)
        if ((int)vpi_get(vpiIndex, b) == index)
            return b;
    return NULL;
}

static void report_bit(const char *label, vpiHandle bit, PLI_INT32 relation)
{
    vpiHandle it = bit != NULL ? vpi_iterate(relation, bit) : NULL, h;
    int n = 0;

    while (it != NULL && (h = vpi_scan(it)) != NULL) {
        n++;
        vpi_printf((PLI_BYTE8 *)"%s: %s, offset %d\n", label, vpi_get_str(vpiType, h),
                   (int)vpi_get(vpiOffset, h));
    }
    if (n == 0)
        vpi_printf((PLI_BYTE8 *)"%s: none\n", label);
}

static PLI_INT32 vl_calltf(PLI_BYTE8 *user_data)
{
    vpiHandle vb = var_bit(find("v"), 2);

    (void)user_data;
    side("drivers", "av", vpiDriver, vpiLhs);
    side("loads", "av", vpiLoad, vpiRhs);
    side("drivers", "svw", vpiDriver, vpiLhs);
    side("drivers", "svm", vpiDriver, vpiLhs);
    side("drivers", "svb", vpiDriver, vpiLhs);
    report_bit("driver of v[2]", vb, vpiDriver);
    report_bit("load of v[2]", vb, vpiLoad);
    return 0;
}

static void register_all(void)
{
    s_vpi_systf_data d;

    memset(&d, 0, sizeof d);
    d.type = vpiSysTask;
    d.tfname = (PLI_BYTE8 *)"$vt_vl";
    d.calltf = vl_calltf;
    vpi_register_systf(&d);
}

void (*vlog_startup_routines[])(void) = {register_all, 0};

#ifdef __cplusplus
}
#endif
