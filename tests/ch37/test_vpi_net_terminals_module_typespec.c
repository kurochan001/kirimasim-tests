/* VPI application of test_vpi_net_terminals_module_typespec (IEEE 1800-2023 37.16). */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "sv_vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

#define TOP "test_vpi_net_terminals_module_typespec"
#define MAX 8
#define LEN 96

static int by_text(const void *a, const void *b)
{
    return strcmp((const char *)a, (const char *)b);
}

static const char *direction(vpiHandle h)
{
    switch (vpi_get(vpiDirection, h)) {
    case vpiInput: return "input";
    case vpiOutput: return "output";
    default: return "other direction";
    }
}

static void describe(vpiHandle h, char *out)
{
    vpiHandle x;
    switch (vpi_get(vpiType, h)) {
    case vpiPrimTerm:
        x = vpi_handle(vpiPrimitive, h);
        snprintf(out, LEN, "terminal %d of %s", (int)vpi_get(vpiTermIndex, h),
                 x ? vpi_get_str(vpiFullName, x) : "?");
        break;
    case vpiContAssign:
        x = vpi_handle(vpiLhs, h);
        snprintf(out, LEN, "assignment to %s", x ? vpi_get_str(vpiFullName, x) : "?");
        break;
    case vpiPathTerm:
        snprintf(out, LEN, "%s path term", direction(h));
        break;
    case vpiTchkTerm:
        snprintf(out, LEN, "tchk term, posedge %d", vpi_get(vpiEdge, h) == vpiPosedge);
        break;
    default: snprintf(out, LEN, "other object"); break;
    }
}

static void show_obj(const char *label, PLI_INT32 rel, const char *name, vpiHandle obj)
{
    char list[MAX][LEN];
    vpiHandle it, h;
    int n = 0, i;

    it = obj ? vpi_iterate(rel, obj) : NULL;
    while (it && (h = vpi_scan(it)) != NULL)
        if (n < MAX)
            describe(h, list[n++]);
    qsort(list, n, LEN, by_text);
    vpi_printf("%s of %s:", label, name);
    for (i = 0; i < n; i++)
        vpi_printf("%s %s", i ? "," : "", list[i]);
    if (n == 0)
        vpi_printf(" none");
    vpi_printf("\n");
}

static void show(const char *label, PLI_INT32 rel, const char *name)
{
    char full[96];
    snprintf(full, sizeof full, "%s.%s", TOP, name);
    show_obj(label, rel, name, vpi_handle_by_name(full, NULL));
}

static PLI_INT32 terms_calltf(PLI_BYTE8 *user_data)
{
    vpiHandle a = vpi_handle_by_name((PLI_BYTE8 *)TOP ".t.a", NULL), m, ts;
    vpiHandle lv2 = vpi_handle_by_name((PLI_BYTE8 *)TOP ".l.lv2", NULL);

    (void)user_data;
    show("prim terms", vpiPrimTerm, "tn");
    show("cont assigns", vpiContAssign, "tn");
    show("prim terms", vpiPrimTerm, "l.pin");
    show("cont assigns", vpiContAssign, "l.pin");
    show("prim terms", vpiPrimTerm, "l.lv2");
    show_obj("prim terms", vpiPrimTerm, "l.lv2[1]", lv2 ? vpi_handle_by_index(lv2, 1) : NULL);
    show("path terms", vpiPathTerm, "t.a");
    show("path terms", vpiPathTerm, "t.y");
    show("tchk terms", vpiTchkTerm, "t.d");
    show("tchk terms", vpiTchkTerm, "t.clk");
    if (a != NULL) {
        m = vpi_handle(vpiModule, a);
        ts = vpi_handle(vpiTypespec, a);
        vpi_printf("module of t.a: %s", m ? vpi_get_str(vpiFullName, m) : "NULL");
        vpi_printf(", typespec vpiLogicTypespec %d\n",
                   ts != NULL && vpi_get(vpiType, ts) == vpiLogicTypespec);
    }
    return 0;
}

static void register_all(void)
{
    s_vpi_systf_data d;
    memset(&d, 0, sizeof d);
    d.type = vpiSysTask;
    d.tfname = (PLI_BYTE8 *)"$vt_terms";
    d.calltf = terms_calltf;
    vpi_register_systf(&d);
}

void (*vlog_startup_routines[])(void) = {register_all, 0};

#ifdef __cplusplus
}
#endif
