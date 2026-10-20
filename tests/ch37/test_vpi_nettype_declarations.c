/* VPI application of test_vpi_nettype_declarations (IEEE 1800-2023 37.23, 37.10). */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "vpi_user.h"
#include "sv_vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

#define TOP "test_vpi_nettype_declarations"

static const char *name_of(vpiHandle h)
{
    const char *s = h != NULL ? vpi_get_str(vpiName, h) : NULL;
    return s != NULL ? s : "none";
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

 static PLI_INT32 nettypes_calltf(PLI_BYTE8 *user_data)
 {
     vpiHandle top = vpi_handle_by_name((PLI_BYTE8 *)TOP, NULL);
     vpiHandle it = top ? vpi_iterate(vpiNettypeDecl, top) : NULL, nt;

     (void)user_data;
     while (it != NULL && (nt = vpi_scan(it)) != NULL && n_lines < 16)
         snprintf(lines[n_lines++], 160, "%s: resolved by %s, alias of %s", name_of(nt),
                  name_of(vpi_handle(vpiWith, nt)), name_of(vpi_handle(vpiNetTypedefAlias, nt)));
     if (n_lines == 0)
         vpi_printf((PLI_BYTE8 *)"no nettype declarations\n");
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
    add("$vt_nettypes", nettypes_calltf);
}

void (*vlog_startup_routines[])(void) = {register_all, 0};

#ifdef __cplusplus
}
#endif
