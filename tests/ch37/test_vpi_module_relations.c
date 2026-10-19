/* VPI application of test_vpi_module_relations (IEEE 1800-2023 37.5, 37.76). */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "vpi_user.h"
#include "sv_vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

#define TOP "test_vpi_module_relations"

static char items[8][64];
static int n_items;

static int compare(const void *x, const void *y)
{
    return strcmp((const char *)x, (const char *)y);
}

static void print_items(const char *label)
{
    int i;
    qsort(items, (size_t)n_items, sizeof items[0], compare);
    vpi_printf((PLI_BYTE8 *)"%s:", label);
    for (i = 0; i < n_items; i++)
        vpi_printf((PLI_BYTE8 *)" %s", items[i]);
    vpi_printf((PLI_BYTE8 *)"\n");
    n_items = 0;
}

static const char *name_or_none(vpiHandle h)
{
    return h != NULL && vpi_get_str(vpiName, h) != NULL ? vpi_get_str(vpiName, h) : "(none)";
}

static vpiHandle find(const char *name)
{
    char full[64];
    snprintf(full, sizeof full, "%s%s%s", TOP, *name ? "." : "", name);
    return vpi_handle_by_name(full, NULL);
}

static PLI_INT32 module_calltf(PLI_BYTE8 *user_data)
{
    vpiHandle top = find(""), single = find("single"), elem = find("arr[1]"), it, h, idx;
    char a[32], b[32];
    s_vpi_value v;

    (void)user_data;
    it = vpi_iterate(vpiModule, NULL);
    if (it != NULL)
        while ((h = vpi_scan(it)) != NULL && n_items < 8)
            snprintf(items[n_items++], sizeof items[0], "%s", name_or_none(h));
    print_items("top modules");

    vpi_printf((PLI_BYTE8 *)"%s: top module %d, default decay time %d\n", TOP,
               (int)vpi_get(vpiTopModule, top), (int)vpi_get(vpiDefDecayTime, top));
    vpi_printf((PLI_BYTE8 *)"single: top module %d, index is NULL %d\n",
               (int)vpi_get(vpiTopModule, single), vpi_handle(vpiIndex, single) == NULL);
    idx = elem ? vpi_handle(vpiIndex, elem) : NULL;
    v.format = vpiIntVal;
    if (idx != NULL)
        vpi_get_value(idx, &v);
    vpi_printf((PLI_BYTE8 *)"arr[1]: index %d\n", idx ? (int)v.value.integer : -1);

    snprintf(a, sizeof a, "%s", name_or_none(vpi_handle(vpiGlobalClocking, top)));
    snprintf(b, sizeof b, "%s", name_or_none(vpi_handle(vpiDefaultClocking, top)));
    vpi_printf((PLI_BYTE8 *)"global clocking %s, default clocking %s, default disable iff %s\n",
               a, b, name_or_none(vpi_handle(vpiDefaultDisableIff, top)));

    it = vpi_iterate(vpiAliasStmt, top);
    if (it != NULL)
        while ((h = vpi_scan(it)) != NULL && n_items < 8) {
            snprintf(a, sizeof a, "%s", name_or_none(vpi_handle(vpiLhs, h)));
            snprintf(items[n_items++], sizeof items[0], "%s=%s", a,
                     name_or_none(vpi_handle(vpiRhs, h)));
        }
    print_items("alias statements");
    return 0;
}

static void register_all(void)
{
    s_vpi_systf_data d;
    memset(&d, 0, sizeof d);
    d.type = vpiSysTask;
    d.tfname = (PLI_BYTE8 *)"$vt_module";
    d.calltf = module_calltf;
    vpi_register_systf(&d);
}

void (*vlog_startup_routines[])(void) = {register_all, 0};

#ifdef __cplusplus
}
#endif
