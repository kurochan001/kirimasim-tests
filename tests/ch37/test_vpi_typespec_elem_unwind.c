/* VPI application of test_vpi_typespec_elem_unwind (IEEE 1800-2023 37.25). */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "sv_vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

#define TOP "test_vpi_typespec_elem_unwind"

/* vpi_get_str reuses its buffer (38.11), so every string is copied; NULL is shown. */
static char *str(PLI_BYTE8 *s)
{
    const char *t = s ? s : "NULL";
    char *c = (char *)malloc(strlen(t) + 1);
    strcpy(c, t);
    return c;
}

static int int_value(vpiHandle h)
{
    s_vpi_value v;
    v.format = vpiIntVal;
    vpi_get_value(h, &v);
    return (int)v.value.integer;
}

static void bounds(vpiHandle h)
{
    vpiHandle l = vpi_handle(vpiLeftRange, h), r = vpi_handle(vpiRightRange, h);
    if (l != NULL)
        vpi_printf(", left %d", int_value(l));
    else
        vpi_printf(", left NULL");
    if (r != NULL)
        vpi_printf(", right %d", int_value(r));
    else
        vpi_printf(", right NULL");
}

/* Prints the ranges; returns their number. */
static int ranges(vpiHandle h)
{
    vpiHandle it = vpi_iterate(vpiRange, h), r, l, rr;
    int n = 0;
    vpi_printf(", ranges");
    while (it != NULL && (r = vpi_scan(it)) != NULL) {
        l = vpi_handle(vpiLeftRange, r);
        rr = vpi_handle(vpiRightRange, r);
        vpi_printf(" %d:%d", l ? int_value(l) : -1, rr ? int_value(rr) : -1);
        n++;
    }
    if (n == 0)
        vpi_printf(" none");
    return n;
}

static void level(vpiHandle t)
{
    PLI_INT32 type = vpi_get(vpiType, t);
    const char *kind;
    switch (type) {
    case vpiBitTypespec: kind = "bit typespec"; break;
    case vpiLogicTypespec: kind = "logic typespec"; break;
    case vpiPackedArrayTypespec: kind = "packed array typespec"; break;
    case vpiArrayTypespec: kind = "array typespec"; break;
    case vpiStructTypespec: kind = "struct typespec"; break;
    case vpiUnionTypespec: kind = "union typespec"; break;
    case vpiEnumTypespec: kind = "enum typespec"; break;
    default: kind = "other type"; break;
    }
    vpi_printf("%s (name %s", kind, str(vpi_get_str(vpiName, t)));
    if (type == vpiBitTypespec || type == vpiLogicTypespec) {
        if (ranges(t) > 0)
            bounds(t);
        vpi_printf(", vector %d", (int)vpi_get(vpiVector, t));
    } else if (type == vpiPackedArrayTypespec) {
        bounds(t);
        vpi_printf(", vector %d", (int)vpi_get(vpiVector, t));
    } else if (type == vpiArrayTypespec) {
        ranges(t);
        bounds(t);
    }
    vpi_printf(")");
}

static void unwind(const char *name)
{
    char full[128];
    vpiHandle v, t;
    int depth = 0;

    snprintf(full, sizeof full, "%s.%s", TOP, name);
    v = vpi_handle_by_name((PLI_BYTE8 *)full, NULL);
    t = v ? vpi_handle(vpiTypespec, v) : NULL;
    vpi_printf("%s:", name);
    while (t != NULL && depth++ < 6) {
        vpi_printf(" ");
        level(t);
        t = vpi_handle(vpiElemTypespec, t);
        vpi_printf(" ->");
    }
    vpi_printf(" NULL\n");
}

static PLI_INT32 unwind_calltf(PLI_BYTE8 *user_data)
{
    (void)user_data;
    unwind("vb");
    unwind("vl");
    unwind("vs");
    unwind("vpa");
    unwind("vpu");
    unwind("vpe");
    unwind("va");
    return 0;
}

static void register_all(void)
{
    s_vpi_systf_data d;
    memset(&d, 0, sizeof d);
    d.type = vpiSysTask;
    d.tfname = (PLI_BYTE8 *)"$vt_unwind";
    d.calltf = unwind_calltf;
    vpi_register_systf(&d);
}

void (*vlog_startup_routines[])(void) = {register_all, 0};

#ifdef __cplusplus
}
#endif
