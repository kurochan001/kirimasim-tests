/* VPI application of test_vpi_net_variable_bit_select_drivers (IEEE 1800-2023 37.16). */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "sv_vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

#define TOP "test_vpi_net_variable_bit_select_drivers"
#define MAX 8
#define LEN 40

static int by_text(const void *a, const void *b)
{
    return strcmp((const char *)a, (const char *)b);
}

/* A continuous assignment is described by its source for a driver and by its
   target for a load; a bit of an assignment counts as the assignment. */
static void describe(vpiHandle h, int as_driver, char *out)
{
    vpiHandle side;
    if (vpi_get(vpiType, h) == vpiContAssignBit)
        h = vpi_handle(vpiParent, h);
    if (h == NULL || vpi_get(vpiType, h) != vpiContAssign) {
        snprintf(out, LEN, "other object");
        return;
    }
    side = vpi_handle(as_driver ? vpiRhs : vpiLhs, h);
    snprintf(out, LEN, "assignment %s %s", as_driver ? "from" : "to",
             side && vpi_get_str(vpiName, side) ? vpi_get_str(vpiName, side) : "?");
}

static void show(const char *label, PLI_INT32 rel, vpiHandle sel)
{
    vpiHandle it = vpi_iterate(rel, sel), h;
    char list[MAX][LEN], d[LEN];
    int n = 0, i;

    while (it && (h = vpi_scan(it)) != NULL) {
        describe(h, rel == vpiDriver, d);
        if (strcmp(d, "assignment to y") == 0)
            continue;
        for (i = 0; i < n && strcmp(list[i], d) != 0; i++)
            ;
        if (i == n && n < MAX)
            strcpy(list[n++], d);
    }
    qsort(list, n, LEN, by_text);
    vpi_printf("  %s:", label);
    for (i = 0; i < n; i++)
        vpi_printf("%s %s", i ? "," : "", list[i]);
    if (n == 0)
        vpi_printf(" none");
    vpi_printf("\n");
}

static PLI_INT32 select_calltf(PLI_BYTE8 *user_data)
{
    vpiHandle top = vpi_handle_by_name((PLI_BYTE8 *)TOP, NULL);
    vpiHandle iv = vpi_handle_by_name((PLI_BYTE8 *)TOP ".i", NULL);
    vpiHandle it = top ? vpi_iterate(vpiContAssign, top) : NULL, ca, lhs, sel = NULL;
    s_vpi_value v;

    (void)user_data;
    while (it && (ca = vpi_scan(it)) != NULL) {
        lhs = vpi_handle(vpiLhs, ca);
        if (lhs != NULL && vpi_get_str(vpiName, lhs) != NULL
            && strcmp(vpi_get_str(vpiName, lhs), "y") == 0) {
            sel = vpi_handle(vpiRhs, ca);
            vpi_free_object(it);
            break;
        }
    }
    v.format = vpiIntVal;
    vpi_get_value(iv, &v);
    vpi_printf("i = %d\n", (int)v.value.integer);
    if (sel == NULL) {
        vpi_printf("  w[i] not found\n");
        return 0;
    }
    show("drivers of w[i]", vpiDriver, sel);
    show("loads of w[i] other than the assignment to y", vpiLoad, sel);
    return 0;
}

static void register_all(void)
{
    s_vpi_systf_data d;
    memset(&d, 0, sizeof d);
    d.type = vpiSysTask;
    d.tfname = (PLI_BYTE8 *)"$vt_select";
    d.calltf = select_calltf;
    vpi_register_systf(&d);
}

void (*vlog_startup_routines[])(void) = {register_all, 0};

#ifdef __cplusplus
}
#endif
