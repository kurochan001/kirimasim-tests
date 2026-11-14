/* VPI application of test_vpi_packed_array_typespec_ranges (IEEE 1800-2023 37.25). */
#include <stdio.h>
#include <string.h>
#include "vpi_user.h"
#include "sv_vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

#define TOP "test_vpi_packed_array_typespec_ranges"

/* Reads the bound expression rel (vpiLeftRange or vpiRightRange) of a range. */
static int bound(vpiHandle range, PLI_INT32 rel, int *out)
{
    vpiHandle e = vpi_handle(rel, range);
    s_vpi_value v;

    if (e == NULL)
        return 0;
    v.format = vpiIntVal;
    vpi_get_value(e, &v);
    *out = (int)v.value.integer;
    return 1;
}

static void show(const char *var)
{
    char full[128];
    vpiHandle h, ts, it, r;
    PLI_BYTE8 *name;
    int n = 0, left, right;

    snprintf(full, sizeof full, "%s.%s", TOP, var);
    h = vpi_handle_by_name((PLI_BYTE8 *)full, NULL);
    ts = h ? vpi_handle(vpiTypespec, h) : NULL;
    vpi_printf((PLI_BYTE8 *)"%s: ", var);
    if (ts == NULL) {
        vpi_printf((PLI_BYTE8 *)"no typespec\n");
        return;
    }
    if (vpi_get(vpiType, ts) != vpiPackedArrayTypespec) {
        vpi_printf((PLI_BYTE8 *)"not a packed array typespec\n");
        return;
    }
    name = vpi_get_str(vpiName, ts);
    vpi_printf((PLI_BYTE8 *)"packed array typespec %s, ranges", name ? name : "NULL");
    it = vpi_iterate(vpiRange, ts);
    while (it != NULL && (r = vpi_scan(it)) != NULL) {
        n++;
        if (vpi_get(vpiType, r) != vpiRange)
            vpi_printf((PLI_BYTE8 *)" (not a range)");
        else if (bound(r, vpiLeftRange, &left) && bound(r, vpiRightRange, &right))
            vpi_printf((PLI_BYTE8 *)" [%d:%d]", left, right);
        else
            vpi_printf((PLI_BYTE8 *)" (range without bounds)");
    }
    if (n == 0)
        vpi_printf((PLI_BYTE8 *)" none");
    vpi_printf((PLI_BYTE8 *)"\n");
}

static PLI_INT32 ranges_calltf(PLI_BYTE8 *user_data)
{
    (void)user_data;
    show("vrow");
    show("vcol");
    show("vanon");
    return 0;
}

static void register_all(void)
{
    s_vpi_systf_data d;

    memset(&d, 0, sizeof d);
    d.type = vpiSysTask;
    d.tfname = (PLI_BYTE8 *)"$vt_ranges";
    d.calltf = ranges_calltf;
    vpi_register_systf(&d);
}

void (*vlog_startup_routines[])(void) = {register_all, 0};

#ifdef __cplusplus
}
#endif
