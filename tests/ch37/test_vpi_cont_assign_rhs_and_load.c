/* VPI application of test_vpi_cont_assign_rhs_and_load (IEEE 1800-2023 37.47, 37.46). */
#include <stdio.h>
#include <string.h>
#include "vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

#define TOP "test_vpi_cont_assign_rhs_and_load"

static vpiHandle find(const char *name)
{
    char full[128];
    snprintf(full, sizeof full, "%s.%s", TOP, name);
    return vpi_handle_by_name((PLI_BYTE8 *)full, NULL);
}

static const char *decompile(vpiHandle h)
{
    const char *s = h != NULL ? vpi_get_str(vpiDecompile, h) : NULL;
    return s != NULL ? s : "NULL";
}

static int int_of(vpiHandle h)
{
    s_vpi_value v;

    v.format = vpiIntVal;
    vpi_get_value(h, &v);
    return (int)v.value.integer;
}

/* The continuous assignment whose left-hand side decompiles to lhs_text. */
static vpiHandle assign_with_lhs(const char *lhs_text)
{
    vpiHandle top = vpi_handle_by_name((PLI_BYTE8 *)TOP, NULL);
    vpiHandle it = top != NULL ? vpi_iterate(vpiContAssign, top) : NULL, ca;

    while (it != NULL && (ca = vpi_scan(it)) != NULL) {
        if (strcmp(decompile(vpi_handle(vpiLhs, ca)), lhs_text) == 0)
            return ca;
    }
    return NULL;
}

/* The net bit of wv with the given index. */
static vpiHandle net_bit(vpiHandle net, int index)
{
    vpiHandle it = net != NULL ? vpi_iterate(vpiBit, net) : NULL, b;

    while (it != NULL && (b = vpi_scan(it)) != NULL)
        if ((int)vpi_get(vpiIndex, b) == index)
            return b;
    return NULL;
}

static PLI_INT32 ca_calltf(PLI_BYTE8 *user_data)
{
    vpiHandle ca = assign_with_lhs("o");
    vpiHandle lhs, rhs, bit, wv = find("wv"), wbit;
    vpiHandle bit_it;
    int loads = 0, same = 0;

    (void)user_data;
    if (ca == NULL) {
        vpi_printf((PLI_BYTE8 *)"assign o not found\n");
        return 0;
    }
    lhs = vpi_handle(vpiLhs, ca);
    rhs = vpi_handle(vpiRhs, ca);
    vpi_printf((PLI_BYTE8 *)"assign %s: rhs \"%s\", %s, bit-and %d, value %d\n",
               decompile(lhs), decompile(rhs),
               rhs != NULL ? vpi_get_str(vpiType, rhs) : "none",
               rhs != NULL && vpi_get(vpiOpType, rhs) == vpiBitAndOp ? 1 : 0,
               rhs != NULL ? int_of(rhs) : -1);

    bit_it = vpi_iterate(vpiBit, ca);
    bit = bit_it != NULL ? vpi_scan(bit_it) : NULL;
    vpi_printf((PLI_BYTE8 *)"bit of assign %s: %s, offset %d, size %d\n", decompile(lhs),
               bit != NULL ? vpi_get_str(vpiType, bit) : "none",
               bit != NULL ? (int)vpi_get(vpiOffset, bit) : -1,
               bit != NULL ? (int)vpi_get(vpiSize, bit) : -1);

    wbit = net_bit(wv, 1);
    {
        vpiHandle it = wbit != NULL ? vpi_iterate(vpiLoad, wbit) : NULL, h;
        while (it != NULL && (h = vpi_scan(it)) != NULL) {
            loads++;
            if (bit != NULL && vpi_compare_objects(h, bit))
                same = 1;
        }
    }
    vpi_printf((PLI_BYTE8 *)"loads of wv[1]: %d, the bit of assign o is the load %d\n",
               loads, same);
    return 0;
}

static void register_all(void)
{
    s_vpi_systf_data d;

    memset(&d, 0, sizeof d);
    d.type = vpiSysTask;
    d.tfname = (PLI_BYTE8 *)"$vt_ca";
    d.calltf = ca_calltf;
    vpi_register_systf(&d);
}

void (*vlog_startup_routines[])(void) = {register_all, 0};

#ifdef __cplusplus
}
#endif
