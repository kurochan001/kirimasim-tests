/* VPI application of test_vpi_packed_array_vars (IEEE 1800-2023 37.18). */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "vpi_user.h"
#include "sv_vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

static char items[4][96];
static int n_items;

static int compare(const void *x, const void *y)
{
    return strcmp((const char *)x, (const char *)y);
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

static PLI_INT32 packed_calltf(PLI_BYTE8 *user_data)
{
    vpiHandle pav = vpi_handle_by_name((PLI_BYTE8 *)"test_vpi_packed_array_vars.pav", NULL);
    vpiHandle it, e, idx_it, idx;
    char name[32];
    int i, index;

    (void)user_data;
    if (pav == NULL) {
        vpi_printf((PLI_BYTE8 *)"pav: not found\n");
        return 0;
    }
    vpi_printf((PLI_BYTE8 *)"pav: packed array var %d, packed %d, vector %d, size %d, value %x\n",
               vpi_get(vpiType, pav) == vpiPackedArrayVar, (int)vpi_get(vpiPacked, pav),
               (int)vpi_get(vpiVector, pav), (int)vpi_get(vpiSize, pav), int_value(pav));
    it = vpi_iterate(vpiElement, pav);
    if (it != NULL)
        while ((e = vpi_scan(it)) != NULL && n_items < 4) {
            snprintf(name, sizeof name, "%s",
                     vpi_get_str(vpiName, e) ? vpi_get_str(vpiName, e) : "(none)");
            idx_it = vpi_iterate(vpiIndex, e);
            idx = idx_it ? vpi_scan(idx_it) : NULL;
            index = int_value(idx);
            if (idx_it != NULL && idx != NULL)
                vpi_release_handle(idx_it);
            snprintf(items[n_items++], sizeof items[0],
                     "%s: struct var %d, member %d, parent is pav %d, index %d, value %x", name,
                     vpi_get(vpiType, e) == vpiStructVar, (int)vpi_get(vpiPackedArrayMember, e),
                     (int)vpi_compare_objects(vpi_handle(vpiParent, e), pav), index,
                     int_value(e));
        }
    qsort(items, (size_t)n_items, sizeof items[0], compare);
    for (i = 0; i < n_items; i++)
        vpi_printf((PLI_BYTE8 *)"%s\n", items[i]);
    return 0;
}

static void register_all(void)
{
    s_vpi_systf_data d;
    memset(&d, 0, sizeof d);
    d.type = vpiSysTask;
    d.tfname = (PLI_BYTE8 *)"$vt_packed";
    d.calltf = packed_calltf;
    vpi_register_systf(&d);
}

void (*vlog_startup_routines[])(void) = {register_all, 0};

#ifdef __cplusplus
}
#endif
