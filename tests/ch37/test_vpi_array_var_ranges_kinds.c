/* VPI application of test_vpi_array_var_ranges_kinds (IEEE 1800-2023 37.17, 37.22, 37.25). */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "sv_vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

#define TOP "test_vpi_array_var_ranges_kinds"

static vpiHandle find(const char *name)
{
    char full[128];
    snprintf(full, sizeof full, "%s.%s", TOP, name);
    return vpi_handle_by_name((PLI_BYTE8 *)full, NULL);
}

static int int_value(vpiHandle h)
{
    s_vpi_value v;
    v.format = vpiIntVal;
    vpi_get_value(h, &v);
    return (int)v.value.integer;
}

static const char *array_type(vpiHandle h)
{
    switch (vpi_get(vpiArrayType, h)) {
    case vpiStaticArray: return "static";
    case vpiDynamicArray: return "dynamic";
    case vpiAssocArray: return "associative";
    case vpiQueueArray: return "queue";
    default: return "undefined";
    }
}

/* vpiLeftRange and vpiRightRange of h, each a value or NULL. */
static void bounds(vpiHandle h)
{
    vpiHandle l = vpi_handle(vpiLeftRange, h), r = vpi_handle(vpiRightRange, h);
    if (l != NULL)
        vpi_printf("left %d", int_value(l));
    else
        vpi_printf("left NULL");
    if (r != NULL)
        vpi_printf(", right %d", int_value(r));
    else
        vpi_printf(", right NULL");
}

static void ranges(vpiHandle h)
{
    vpiHandle it = vpi_iterate(vpiRange, h), r;
    int n = 0;
    vpi_printf("ranges:");
    while (it != NULL && (r = vpi_scan(it)) != NULL) {
        vpi_printf("%s [size %d, ", n++ ? "," : "", (int)vpi_get(vpiSize, r));
        bounds(r);
        vpi_printf("]");
    }
    if (n == 0)
        vpi_printf(" none");
    vpi_printf("\n");
}

static const char *kind(vpiHandle h)
{
    switch (vpi_get(vpiType, h)) {
    case vpiArrayVar: return "array var";
    case vpiLogicVar: return "logic var";
    case vpiBitVar: return "bit var";
    case vpiPackedArrayVar: return "packed array var";
    case vpiLogicTypespec: return "logic typespec";
    case vpiBitTypespec: return "bit typespec";
    case vpiArrayTypespec: return "array typespec";
    default: return "other type";
    }
}

enum { ARRAY = 1, TYPESPEC = 2, TYPESPEC_KIND = 4 };

static void describe(const char *name, int what)
{
    vpiHandle v = find(name), t;
    if (v == NULL) {
        vpi_printf("%s: not found\n", name);
        return;
    }
    vpi_printf("%s (%s): ", name, kind(v));
    if (what & ARRAY)
        vpi_printf("array type %s, ", array_type(v));
    bounds(v);
    vpi_printf(", ");
    ranges(v);
    if (what & TYPESPEC) {
        t = vpi_handle(vpiTypespec, v);
        if (t == NULL) {
            vpi_printf("  typespec NULL\n");
            return;
        }
        vpi_printf("  typespec (%s): ", kind(t));
        if (what & TYPESPEC_KIND)
            vpi_printf("array type %s, ", array_type(t));
        ranges(t);
    }
}

static PLI_INT32 ranges_calltf(PLI_BYTE8 *user_data)
{
    (void)user_data;
    describe("sa", ARRAY | TYPESPEC | TYPESPEC_KIND);
    describe("da", ARRAY | TYPESPEC | TYPESPEC_KIND);
    describe("de", ARRAY);
    describe("qa", ARRAY | TYPESPEC | TYPESPEC_KIND);
    describe("qe", ARRAY);
    describe("aa", ARRAY | TYPESPEC | TYPESPEC_KIND);
    describe("mx", TYPESPEC);
    describe("mq", 0);
    describe("ma", 0);
    describe("lu", ARRAY);
    describe("pv", TYPESPEC);
    describe("bv", TYPESPEC);
    describe("ps", 0);
    describe("pu", 0);
    describe("pe", 0);
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
