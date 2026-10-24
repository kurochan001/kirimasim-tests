/* VPI application of test_vpi_simple_expr_uses (IEEE 1800-2023 37.58). */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "vpi_user.h"
#include "sv_vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

#define TOP "test_vpi_simple_expr_uses"
#define MAX_USES 8

static int compare(const void *x, const void *y)
{
    return strcmp((const char *)x, (const char *)y);
}

static const char *str_or(PLI_INT32 prop, vpiHandle h, const char *fallback)
{
    const char *s = h != NULL ? vpi_get_str(prop, h) : NULL;
    return s != NULL ? s : fallback;
}

static void use_text(vpiHandle u, char *buf, size_t size)
{
    switch (vpi_get(vpiType, u)) {
    case vpiContAssign:
        snprintf(buf, size, "cont assign to %s", str_or(vpiName, vpi_handle(vpiLhs, u), "?"));
        break;
    case vpiPrimTerm:
        snprintf(buf, size, "prim term %d", (int)vpi_get(vpiTermIndex, u));
        break;
    default:
        snprintf(buf, size, "other use");
        break;
    }
}

static void uses(const char *label, vpiHandle obj)
{
    char list[MAX_USES][48];
    vpiHandle it, u;
    int n = 0, i;

    if (obj == NULL) {
        vpi_printf((PLI_BYTE8 *)"%s: not found\n", label);
        return;
    }
    it = vpi_iterate(vpiUse, obj);
    while (it != NULL && (u = vpi_scan(it)) != NULL)
        if (n < MAX_USES)
            use_text(u, list[n++], sizeof list[0]);
    qsort(list, (size_t)n, sizeof list[0], compare);
    vpi_printf((PLI_BYTE8 *)"uses of %s:", label);
    for (i = 0; i < n; i++)
        vpi_printf((PLI_BYTE8 *)"%s %s", i ? "," : "", list[i]);
    vpi_printf((PLI_BYTE8 *)"%s\n", n == 0 ? " none" : "");
}

static PLI_INT32 start_of_simulation(p_cb_data data)
{
    vpiHandle top, it, ca, bit = NULL;
    char label[96], name[32];

    (void)data;
    top = vpi_handle_by_name((PLI_BYTE8 *)TOP, NULL);
    uses("net v", vpi_handle_by_name((PLI_BYTE8 *)TOP ".v", NULL));
    uses("variable r", vpi_handle_by_name((PLI_BYTE8 *)TOP ".r", NULL));
    uses("parameter P", vpi_handle_by_name((PLI_BYTE8 *)TOP ".P", NULL));
    uses("specparam SP", vpi_handle_by_name((PLI_BYTE8 *)TOP ".SP", NULL));

    it = top != NULL ? vpi_iterate(vpiContAssign, top) : NULL;
    while (it != NULL && (ca = vpi_scan(it)) != NULL)
        if (strcmp(str_or(vpiName, vpi_handle(vpiLhs, ca), ""), "wb") == 0)
            bit = vpi_handle(vpiRhs, ca);
    if (bit == NULL || vpi_get(vpiType, bit) != vpiBitSelect) {
        vpi_printf((PLI_BYTE8 *)"no bit-select on the right-hand side of wb\n");
        return 0;
    }
    snprintf(name, sizeof name, "%s", str_or(vpiName, bit, "(no name)"));
    snprintf(label, sizeof label, "bit-select %s (full name %s)", name,
             str_or(vpiFullName, bit, "(no name)"));
    uses(label, bit);
    return 0;
}

static void register_all(void)
{
    s_cb_data d;
    memset(&d, 0, sizeof d);
    d.reason = cbStartOfSimulation;
    d.cb_rtn = start_of_simulation;
    vpi_register_cb(&d);
}

void (*vlog_startup_routines[])(void) = {register_all, 0};

#ifdef __cplusplus
}
#endif
