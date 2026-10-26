/* VPI application of test_vpi_generate_nettype_typedef (IEEE 1800-2023 37.85). */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "vpi_user.h"
#include "sv_vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

#define TOP "test_vpi_generate_nettype_typedef"

static vpiHandle find(const char *name)
{
    char full[160];
    snprintf(full, sizeof full, "%s.%s", TOP, name);
    return vpi_handle_by_name((PLI_BYTE8 *)full, NULL);
}

static const char *name_of(vpiHandle h)
{
    const char *s = h != NULL ? vpi_get_str(vpiName, h) : NULL;
    return s != NULL ? s : "NULL";
}

static int by_name(const void *a, const void *b)
{
    return strcmp((const char *)a, (const char *)b);
}

static void typedefs(const char *label, vpiHandle scope)
{
    char names[8][48];
    int n = 0, i;
    vpiHandle it = scope != NULL ? vpi_iterate(vpiTypedef, scope) : NULL, h;

    while (it != NULL && (h = vpi_scan(it)) != NULL) {
        if (n < 8)
            snprintf(names[n++], sizeof names[0], "%s", name_of(h));
    }
    qsort(names, (size_t)n, sizeof names[0], by_name);
    vpi_printf((PLI_BYTE8 *)"typedefs of %s (%d):", label, n);
    for (i = 0; i < n; i++)
        vpi_printf((PLI_BYTE8 *)" %s", names[i]);
    vpi_printf((PLI_BYTE8 *)"\n");
}

static PLI_INT32 gen_calltf(PLI_BYTE8 *user_data)
{
    vpiHandle g = find("g");
    vpiHandle decl = find("g.gnt");
    vpiHandle scope = decl != NULL ? vpi_handle(vpiGenScope, decl) : NULL;
    vpiHandle ts = decl != NULL ? vpi_handle(vpiTypespec, decl) : NULL;

    (void)user_data;
    if (decl == NULL) {
        vpi_printf((PLI_BYTE8 *)"g.gnt: not found\n");
        return 0;
    }
    vpi_printf((PLI_BYTE8 *)"g.gnt: name %s, %s, typespec %s, gen scope g %d\n", name_of(decl),
               vpi_get_str(vpiType, decl), name_of(ts),
               g != NULL && scope != NULL && vpi_compare_objects(g, scope) ? 1 : 0);
    typedefs("g", g);
    typedefs("top", vpi_handle_by_name((PLI_BYTE8 *)TOP, NULL));
    return 0;
}

static void register_all(void)
{
    s_vpi_systf_data d;

    memset(&d, 0, sizeof d);
    d.type = vpiSysTask;
    d.tfname = (PLI_BYTE8 *)"$vt_gen";
    d.calltf = gen_calltf;
    vpi_register_systf(&d);
}

void (*vlog_startup_routines[])(void) = {register_all, 0};

#ifdef __cplusplus
}
#endif
