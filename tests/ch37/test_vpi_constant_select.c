/* VPI application of test_vpi_constant_select (IEEE 1800-2023 37.19, 37.58). */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "vpi_user.h"
#include "sv_vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

#define TOP "test_vpi_constant_select"

static const char *name_of(vpiHandle h)
{
    const char *s = h != NULL ? vpi_get_str(vpiName, h) : NULL;
    return s != NULL ? s : "none";
}

static int int_value(vpiHandle h)
{
    s_vpi_value v;
    v.format = vpiIntVal;
    vpi_get_value(h, &v);
    return (int)v.value.integer;
}

static char lines[16][160];
static int n_lines;

static int by_text(const void *a, const void *b)
{
    return strcmp((const char *)a, (const char *)b);
}

static void flush_sorted(void)
{
    int k;
    qsort(lines, (size_t)n_lines, sizeof lines[0], by_text);
    for (k = 0; k < n_lines; k++)
        vpi_printf((PLI_BYTE8 *)"%s\n", lines[k]);
    n_lines = 0;
}

 static PLI_INT32 selects_calltf(PLI_BYTE8 *user_data)
 {
     vpiHandle top = vpi_handle_by_name((PLI_BYTE8 *)TOP, NULL);
     vpiHandle it = top ? vpi_iterate(vpiContAssign, top) : NULL, ca;

     (void)user_data;
     while (it != NULL && (ca = vpi_scan(it)) != NULL && n_lines < 16) {
         vpiHandle lhs = vpi_handle(vpiLhs, ca), rhs = vpi_handle(vpiRhs, ca);
         PLI_INT32 t = rhs ? vpi_get(vpiType, rhs) : 0;
         snprintf(lines[n_lines++], 160, "%s: %s, constant %d, value %d", name_of(lhs),
                  t == vpiVarSelect ? "var select" : t == vpiBitSelect ? "bit-select" : "other",
                  rhs ? (int)vpi_get(vpiConstantSelect, rhs) : -1, rhs ? int_value(rhs) : -1);
     }
     flush_sorted();
     return 0;
 }

static void add(const char *name, PLI_INT32 (*calltf)(PLI_BYTE8 *))
{
    s_vpi_systf_data d;
    memset(&d, 0, sizeof d);
    d.type = vpiSysTask;
    d.tfname = (PLI_BYTE8 *)name;
    d.calltf = calltf;
    vpi_register_systf(&d);
}

static void register_all(void)
{
    add("$vt_selects", selects_calltf);
}

void (*vlog_startup_routines[])(void) = {register_all, 0};

#ifdef __cplusplus
}
#endif
