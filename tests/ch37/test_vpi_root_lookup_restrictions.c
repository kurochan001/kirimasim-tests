/* VPI application of test_vpi_root_lookup_restrictions (IEEE 1800-2023 37.10). */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "vpi_user.h"
#include "sv_vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

#define TOP "test_vpi_root_lookup_restrictions"
#define MAX 8

static int by_text(const void *a, const void *b)
{
    return strcmp((const char *)a, (const char *)b);
}

static const char *inst_kind(vpiHandle h)
{
    switch (vpi_get(vpiType, h)) {
    case vpiModule: return "module";
    case vpiPackage: return "package";
    case vpiInterface: return "interface";
    case vpiProgram: return "program";
    default: return NULL;
    }
}

static PLI_INT32 lookup_calltf(PLI_BYTE8 *user_data)
{
    vpiHandle it, h;
    char names[MAX][96];
    int n = 0, i;

    (void)user_data;
    it = vpi_iterate(vpiInstance, NULL);
    while (it != NULL && (h = vpi_scan(it)) != NULL) {
        const char *kind = inst_kind(h);
        /* vpiUnit is a property of a package only (37.10); for another object
           vpi_get() can report an error and return vpiUndefined (38.6). */
        if (vpi_get(vpiType, h) == vpiPackage && vpi_get(vpiUnit, h) == 1)
            continue;
        if (kind != NULL && n < MAX)
            snprintf(names[n++], sizeof names[0], "%s %s", kind,
                     vpi_get_str(vpiName, h));
    }
    qsort(names, (size_t)n, sizeof names[0], by_text);
    vpi_printf((PLI_BYTE8 *)"top instances from NULL root: %d\n", n);
    for (i = 0; i < n; i++)
        vpi_printf((PLI_BYTE8 *)"  %s\n", names[i]);

    vpi_printf((PLI_BYTE8 *)"imported item by name NULL %d\n",
               vpi_handle_by_name((PLI_BYTE8 *)TOP ".pv", NULL) == NULL);
    vpi_printf((PLI_BYTE8 *)"compilation unit item by full name NULL %d\n",
               vpi_handle_by_name((PLI_BYTE8 *)"$unit::cu", NULL) == NULL);
    vpi_printf((PLI_BYTE8 *)"compilation unit item by simple name NULL %d\n",
               vpi_handle_by_name((PLI_BYTE8 *)"cu", NULL) == NULL);
    vpi_printf((PLI_BYTE8 *)"local item by name found %d\n",
               vpi_handle_by_name((PLI_BYTE8 *)TOP ".lvar", NULL) != NULL);
    return 0;
}

static void register_all(void)
{
    s_vpi_systf_data d;
    memset(&d, 0, sizeof d);
    d.type = vpiSysTask;
    d.tfname = (PLI_BYTE8 *)"$vt_lookup";
    d.calltf = lookup_calltf;
    vpi_register_systf(&d);
}

void (*vlog_startup_routines[])(void) = {register_all, 0};

#ifdef __cplusplus
}
#endif
