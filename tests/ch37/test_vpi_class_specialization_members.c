/* VPI application of test_vpi_class_specialization_members (IEEE 1800-2023 37.32). */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "vpi_user.h"
#include "sv_vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

#define TOP "test_vpi_class_specialization_members"
#define MAX 8
#define LEN 64

static vpiHandle spec;

static int by_text(const void *x, const void *y)
{
    return strcmp((const char *)x, (const char *)y);
}

static const char *name_of(vpiHandle h)
{
    PLI_BYTE8 *s = h != NULL ? vpi_get_str(vpiName, h) : NULL;
    return s != NULL ? s : "(none)";
}

static int int_value(vpiHandle h)
{
    s_vpi_value v;
    if (h == NULL)
        return -1;
    v.format = vpiIntVal;
    vpi_get_value(h, &v);
    return (int)v.value.integer;
}

static int leads_back(vpiHandle h)
{
    vpiHandle back = vpi_handle(vpiClassTypespec, h);
    return back != NULL && vpi_compare_objects(back, spec);
}

/* The names of an iteration, sorted unless in_order is set, with the number
 * of them that lead back to the specialization when back is set. */
static void names(PLI_INT32 type, const char *label, int in_order, int back)
{
    vpiHandle it = vpi_iterate(type, spec), h;
    char list[MAX][LEN];
    int n = 0, same = 0, i;

    while (it != NULL && (h = vpi_scan(it)) != NULL) {
        if (back && leads_back(h))
            same++;
        if (n < MAX)
            snprintf(list[n++], LEN, "%s", name_of(h));
    }
    if (!in_order)
        qsort(list, (size_t)n, LEN, by_text);
    vpi_printf((PLI_BYTE8 *)"%s:", label);
    for (i = 0; i < n; i++)
        vpi_printf((PLI_BYTE8 *)" %s", list[i]);
    if (back)
        vpi_printf((PLI_BYTE8 *)", leading back %d of %d", same, n);
    vpi_printf((PLI_BYTE8 *)"\n");
}

static void parameters(void)
{
    vpiHandle it = vpi_iterate(vpiParameter, spec), h;
    char list[MAX][LEN];
    int n = 0, i;

    while (it != NULL && (h = vpi_scan(it)) != NULL)
        if (n < MAX)
            snprintf(list[n++], LEN, "%s = %d (local %d, leading back %d)", name_of(h),
                     int_value(h), (int)vpi_get(vpiLocalParam, h), leads_back(h));
    qsort(list, (size_t)n, LEN, by_text);
    vpi_printf((PLI_BYTE8 *)"parameters:");
    for (i = 0; i < n; i++)
        vpi_printf((PLI_BYTE8 *)"%s %s", i ? "," : "", list[i]);
    vpi_printf((PLI_BYTE8 *)"\n");
}

static void param_assign_w(void)
{
    vpiHandle it = vpi_iterate(vpiParamAssign, spec), pa, found = NULL;

    while (it != NULL && (pa = vpi_scan(it)) != NULL)
        if (strcmp(name_of(vpi_handle(vpiLhs, pa)), "W") == 0)
            found = pa;
    if (found == NULL)
        vpi_printf((PLI_BYTE8 *)"param assign of W: none\n");
    else
        vpi_printf((PLI_BYTE8 *)"param assign of W: right-hand side value %d\n",
                   int_value(vpi_handle(vpiRhs, found)));
}

static void variables(void)
{
    vpiHandle it = vpi_iterate(vpiVariables, spec), h;
    int arrays = 0;

    names(vpiVariables, "variables", 0, 0);
    while (it != NULL && (h = vpi_scan(it)) != NULL)
        if (strcmp(name_of(h), "vifs") == 0 && vpi_get(vpiType, h) == vpiArrayVar)
            arrays++;
    vpi_printf((PLI_BYTE8 *)"vifs among the variables as one vpiArrayVar: %d\n", arrays);
}

static void virtual_interfaces(void)
{
    vpiHandle it = vpi_iterate(vpiVirtualInterfaceVar, spec), h;
    int n = 0, typed = 0, vif = 0;

    while (it != NULL && (h = vpi_scan(it)) != NULL) {
        n++;
        if (vpi_get(vpiType, h) == vpiVirtualInterfaceVar)
            typed++;
        if (strcmp(name_of(h), "vif") == 0)
            vif++;
    }
    vpi_printf((PLI_BYTE8 *)"virtual interface vars: %d, of type vpiVirtualInterfaceVar %d, "
                            "vif among them %d\n", n, typed, vif);
}

static PLI_INT32 spec_calltf(PLI_BYTE8 *user_data)
{
    vpiHandle b8 = vpi_handle_by_name((PLI_BYTE8 *)TOP ".b8", NULL);

    (void)user_data;
    spec = b8 != NULL ? vpi_handle(vpiClassTypespec, b8) : NULL;
    if (spec == NULL) {
        vpi_printf((PLI_BYTE8 *)"no class typespec\n");
        return 0;
    }
    vpi_printf((PLI_BYTE8 *)"class typespec of b8: definition %s\n",
               name_of(vpi_handle(vpiClassDefn, spec)));
    parameters();
    param_assign_w();
    variables();
    virtual_interfaces();
    names(vpiMethods, "methods", 0, 1);
    names(vpiConstraint, "constraints in order", 1, 1);
    names(vpiNamedEvent, "named events", 0, 1);
    names(vpiNamedEventArray, "named event arrays", 0, 1);
    return 0;
}

static void register_all(void)
{
    s_vpi_systf_data d;
    memset(&d, 0, sizeof d);
    d.type = vpiSysTask;
    d.tfname = (PLI_BYTE8 *)"$vt_spec";
    d.calltf = spec_calltf;
    vpi_register_systf(&d);
}

void (*vlog_startup_routines[])(void) = {register_all, 0};

#ifdef __cplusplus
}
#endif
