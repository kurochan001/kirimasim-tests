/* VPI application of test_vpi_udp_table_primitive (IEEE 1800-2023 37.35, 37.36). */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "vpi_user.h"
#include "sv_vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

#define TOP "test_vpi_udp_table_primitive"
#define MAX 8

static int by_text(const void *a, const void *b)
{
    return strcmp((const char *)a, (const char *)b);
}

static const char *sprop(PLI_INT32 property, vpiHandle h)
{
    PLI_BYTE8 *s = h != NULL ? vpi_get_str(property, h) : NULL;
    return s != NULL ? s : "NULL";
}

static PLI_INT32 udp_calltf(PLI_BYTE8 *user_data)
{
    vpiHandle g = vpi_handle_by_name((PLI_BYTE8 *)TOP ".g", NULL);
    vpiHandle udp = g != NULL ? vpi_handle(vpiUdpDefn, g) : NULL;
    vpiHandle it, e, term;
    char entries[MAX][32];
    PLI_INT32 index[MAX];
    vpiHandle terms[MAX];
    int n = 0, nt = 0, i, j;
    s_vpi_value v;

    (void)user_data;
    vpi_printf((PLI_BYTE8 *)"udp defn: protected %d, combinational %d\n",
               (int)vpi_get(vpiProtected, udp),
               vpi_get(vpiPrimType, udp) == vpiCombPrim);
    it = udp != NULL ? vpi_iterate(vpiTableEntry, udp) : NULL;
    while (it != NULL && (e = vpi_scan(it)) != NULL && n < MAX) {
        v.format = vpiStringVal;
        v.value.str = (PLI_BYTE8 *)"?";
        vpi_get_value(e, &v);
        snprintf(entries[n++], sizeof entries[0], "%s", v.value.str);
    }
    qsort(entries, (size_t)n, sizeof entries[0], by_text);
    vpi_printf((PLI_BYTE8 *)"entries: %d\n", n);
    for (i = 0; i < n; i++)
        vpi_printf((PLI_BYTE8 *)"  %s\n", entries[i]);

    e = g != NULL ? vpi_handle(vpiDelay, g) : NULL;
    v.format = vpiIntVal;
    v.value.integer = -1;
    if (e != NULL)
        vpi_get_value(e, &v);
    vpi_printf((PLI_BYTE8 *)"prim: size %d, delay %d\n",
               (int)vpi_get(vpiSize, g), (int)v.value.integer);

    it = g != NULL ? vpi_iterate(vpiPrimTerm, g) : NULL;
    while (it != NULL && (term = vpi_scan(it)) != NULL && nt < MAX) {
        vpiHandle p = vpi_handle(vpiPrimitive, term);
        vpiHandle x = vpi_handle(vpiExpr, term);
        index[nt] = vpi_get(vpiTermIndex, term);
        terms[nt] = term;
        nt++;
        (void)p;
        (void)x;
    }
    for (i = 0; i < nt; i++)
        for (j = i + 1; j < nt; j++)
            if (index[i] > index[j]) {
                PLI_INT32 ti = index[i];
                vpiHandle th = terms[i];
                index[i] = index[j];
                terms[i] = terms[j];
                index[j] = ti;
                terms[j] = th;
            }
    for (i = 0; i < nt; i++) {
        vpiHandle p = vpi_handle(vpiPrimitive, terms[i]);
        vpiHandle x = vpi_handle(vpiExpr, terms[i]);
        vpi_printf((PLI_BYTE8 *)"term %d: expr %s, primitive same %d\n",
                   (int)index[i], sprop(vpiName, x),
                   p != NULL && g != NULL && vpi_compare_objects(p, g));
    }
    return 0;
}

static void register_all(void)
{
    s_vpi_systf_data d;
    memset(&d, 0, sizeof d);
    d.type = vpiSysTask;
    d.tfname = (PLI_BYTE8 *)"$vt_udp";
    d.calltf = udp_calltf;
    vpi_register_systf(&d);
}

void (*vlog_startup_routines[])(void) = {register_all, 0};

#ifdef __cplusplus
}
#endif
