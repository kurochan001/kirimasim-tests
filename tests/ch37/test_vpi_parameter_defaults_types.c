/* VPI application of test_vpi_parameter_defaults_types (IEEE 1800-2023 37.28). */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "sv_vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

#define TOP "test_vpi_parameter_defaults_types"
#define MAX 8

struct item {
    char *name;
    vpiHandle h;
};

/* vpi_get_str reuses its buffer (38.11), so every string is copied; NULL is shown. */
static char *str(PLI_BYTE8 *s)
{
    const char *t = s ? s : "NULL";
    char *c = (char *)malloc(strlen(t) + 1);
    strcpy(c, t);
    return c;
}

static int by_name(const void *a, const void *b)
{
    return strcmp(((const struct item *)a)->name, ((const struct item *)b)->name);
}

static int int_value(vpiHandle h)
{
    s_vpi_value v;
    v.format = vpiIntVal;
    vpi_get_value(h, &v);
    return (int)v.value.integer;
}

static const char *kind(vpiHandle h)
{
    if (h == NULL)
        return "NULL";
    switch (vpi_get(vpiType, h)) {
    case vpiParameter: return "parameter";
    case vpiTypeParameter: return "type parameter";
    case vpiIntTypespec: return "int typespec";
    case vpiByteTypespec: return "byte typespec";
    case vpiBitTypespec: return "bit typespec";
    case vpiLogicTypespec: return "logic typespec";
    default: return "other type";
    }
}

static void bound(const char *label, vpiHandle h)
{
    if (h == NULL)
        vpi_printf(", %s NULL", label);
    else
        vpi_printf(", %s %d", label, int_value(h));
}

/* A typespec as its kind, name and, when it has them, bounds. */
static void typespec(const char *label, vpiHandle t)
{
    vpi_printf(", %s %s", label, kind(t));
    if (t == NULL)
        return;
    vpi_printf(" named %s", str(vpi_get_str(vpiName, t)));
    if (vpi_get(vpiType, t) == vpiBitTypespec || vpi_get(vpiType, t) == vpiLogicTypespec) {
        bound("left", vpi_handle(vpiLeftRange, t));
        bound("right", vpi_handle(vpiRightRange, t));
    }
}

static PLI_INT32 params_calltf(PLI_BYTE8 *user_data)
{
    vpiHandle u = vpi_handle_by_name((PLI_BYTE8 *)TOP ".u", NULL);
    vpiHandle it = u ? vpi_iterate(vpiParameter, u) : NULL, h, e;
    struct item list[MAX];
    int n = 0, i;

    (void)user_data;
    while (it != NULL && (h = vpi_scan(it)) != NULL) {
        if (n == MAX)
            continue;
        list[n].name = str(vpi_get_str(vpiName, h));
        list[n++].h = h;
    }
    qsort(list, n, sizeof list[0], by_name);
    vpi_printf("parameters of u (%d):", n);
    for (i = 0; i < n; i++)
        vpi_printf(" %s (%s)", list[i].name, kind(list[i].h));
    vpi_printf("\n");
    for (i = 0; i < n; i++) {
        h = list[i].h;
        vpi_printf("%s: full name %s", list[i].name, str(vpi_get_str(vpiFullName, h)));
        e = vpi_handle(vpiExpr, h);
        if (vpi_get(vpiType, h) == vpiTypeParameter) {
            typespec("typespec", vpi_handle(vpiTypespec, h));
            typespec("default", e);
        } else {
            vpi_printf(", value %d", int_value(h));
            if (strcmp(list[i].name, "U") != 0)
                vpi_printf(", typespec %s", kind(vpi_handle(vpiTypespec, h)));
            bound("left", vpi_handle(vpiLeftRange, h));
            bound("right", vpi_handle(vpiRightRange, h));
            if (strcmp(list[i].name, "U") != 0) {
                if (e == NULL)
                    vpi_printf(", default NULL");
                else
                    vpi_printf(", default %d", int_value(e));
            }
        }
        vpi_printf("\n");
    }
    return 0;
}

static void register_all(void)
{
    s_vpi_systf_data d;
    memset(&d, 0, sizeof d);
    d.type = vpiSysTask;
    d.tfname = (PLI_BYTE8 *)"$vt_params";
    d.calltf = params_calltf;
    vpi_register_systf(&d);
}

void (*vlog_startup_routines[])(void) = {register_all, 0};

#ifdef __cplusplus
}
#endif
