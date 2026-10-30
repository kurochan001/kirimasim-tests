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

/* vpi_get_str() returns every string in one buffer (38.11), so each string
   that is printed with another one is copied first. */
static const char *copy_str(PLI_INT32 prop, vpiHandle h, char *buf, size_t n)
{
    const char *s = h != NULL ? vpi_get_str(prop, h) : NULL;

    snprintf(buf, n, "%s", s != NULL ? s : "NULL");
    return buf;
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

/* The net bit of wv with the given index, which vpiIndex of the bit gives
   as an expression (37.16). */
static vpiHandle net_bit(vpiHandle net, int index)
{
    vpiHandle it = net != NULL ? vpi_iterate(vpiBit, net) : NULL, b, ix;

    while (it != NULL && (b = vpi_scan(it)) != NULL) {
        ix = vpi_handle(vpiIndex, b);
        if (ix != NULL && int_of(ix) == index)
            return b;
    }
    return NULL;
}

static PLI_INT32 ca_calltf(PLI_BYTE8 *user_data)
{
    vpiHandle ca = assign_with_lhs("o");
    vpiHandle lhs, rhs, bit, wv = find("wv"), wbit;
    vpiHandle bit_it;
    char lhs_text[64], rhs_text[64], type_text[64];
    int loads = 0, same = 0;

    (void)user_data;
    if (ca == NULL) {
        vpi_printf((PLI_BYTE8 *)"assign o not found\n");
        return 0;
    }
    lhs = vpi_handle(vpiLhs, ca);
    rhs = vpi_handle(vpiRhs, ca);
    copy_str(vpiDecompile, lhs, lhs_text, sizeof lhs_text);
    copy_str(vpiDecompile, rhs, rhs_text, sizeof rhs_text);
    copy_str(vpiType, rhs, type_text, sizeof type_text);
    vpi_printf((PLI_BYTE8 *)"assign %s: rhs \"%s\", %s, bit-and %d, value %d\n",
               lhs_text, rhs_text, type_text,
               rhs != NULL && vpi_get(vpiOpType, rhs) == vpiBitAndOp ? 1 : 0,
               rhs != NULL ? int_of(rhs) : -1);

    bit_it = vpi_iterate(vpiBit, ca);
    bit = bit_it != NULL ? vpi_scan(bit_it) : NULL;
    vpi_printf((PLI_BYTE8 *)"bit of assign %s: %s, offset %d, size %d\n", lhs_text,
               copy_str(vpiType, bit, type_text, sizeof type_text),
               bit != NULL ? (int)vpi_get(vpiOffset, bit) : -1,
               bit != NULL ? (int)vpi_get(vpiSize, bit) : -1);

    wbit = net_bit(wv, 1);
    {
        vpiHandle it = wbit != NULL ? vpi_iterate(vpiLoad, wbit) : NULL, h;
        while (it != NULL && (h = vpi_scan(it)) != NULL) {
            loads++;
            if ((bit != NULL && vpi_compare_objects(h, bit)) || vpi_compare_objects(h, ca))
                same = 1;
        }
    }
    vpi_printf((PLI_BYTE8 *)"loads of wv[1]: %d, assign o or its bit is the load %d\n",
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
