/* VPI application of test_vpi_virtual_interface_expr (IEEE 1800-2023 37.29). */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "vpi_user.h"
#include "sv_vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

#define TOP "test_vpi_virtual_interface_expr"
#define MAX 8

static char lines[MAX][128];
static int line_count;

static const char *name_of(vpiHandle h)
{
    const char *s = h != NULL ? vpi_get_str(vpiName, h) : NULL;
    return s != NULL ? s : "NULL";
}

static int by_text(const void *a, const void *b)
{
    return strcmp((const char *)a, (const char *)b);
}

static void declarations(void)
{
    vpiHandle top = vpi_handle_by_name((PLI_BYTE8 *)TOP, NULL);
    vpiHandle it = top != NULL ? vpi_iterate(vpiVirtualInterfaceVar, top) : NULL, h;

    while (it != NULL && (h = vpi_scan(it)) != NULL) {
        char name[48];
        vpiHandle e;
        char what[96];

        /* vpi_get_str() returns every string in one buffer (38.11), so the
           name is copied before the name of the expression is asked for. */
        snprintf(name, sizeof name, "%s", name_of(h));
        if (strcmp(name, "v0") != 0 && strcmp(name, "v1") != 0)
            continue;
        e = vpi_handle(vpiExpr, h);
        if (e == NULL)
            snprintf(what, sizeof what, "NULL");
        else
            snprintf(what, sizeof what, "interface %s", name_of(e));
        if (line_count < MAX)
            snprintf(lines[line_count++], sizeof lines[0], "%s: expr %s", name, what);
    }
}

static void assignments(void)
{
    vpiHandle task = vpi_handle_by_name((PLI_BYTE8 *)TOP ".sets", NULL);
    vpiHandle body = task != NULL ? vpi_handle(vpiStmt, task) : NULL;
    vpiHandle it = body != NULL ? vpi_iterate(vpiStmt, body) : NULL, s;

    while (it != NULL && (s = vpi_scan(it)) != NULL) {
        vpiHandle rhs;
        char what[96];

        if (vpi_get(vpiType, s) != vpiAssignment)
            continue;
        rhs = vpi_handle(vpiRhs, s);
        if (rhs == NULL)
            snprintf(what, sizeof what, "NULL");
        else if (vpi_get(vpiType, rhs) == vpiConstant)
            snprintf(what, sizeof what, "constant null %d",
                     vpi_get(vpiConstType, rhs) == vpiNullConst ? 1 : 0);
        else if (vpi_get(vpiType, rhs) == vpiVirtualInterfaceVar)
            snprintf(what, sizeof what, "virtual interface var %s", name_of(rhs));
        else
            snprintf(what, sizeof what, "other %s", vpi_get_str(vpiType, rhs));
        if (line_count < MAX)
            snprintf(lines[line_count++], sizeof lines[0], "assign %s: rhs %s",
                     name_of(vpi_handle(vpiLhs, s)), what);
    }
}

static PLI_INT32 vif_calltf(PLI_BYTE8 *user_data)
{
    int i;

    (void)user_data;
    declarations();
    assignments();
    qsort(lines, (size_t)line_count, sizeof lines[0], by_text);
    for (i = 0; i < line_count; i++)
        vpi_printf((PLI_BYTE8 *)"%s\n", lines[i]);
    return 0;
}

static void register_all(void)
{
    s_vpi_systf_data d;

    memset(&d, 0, sizeof d);
    d.type = vpiSysTask;
    d.tfname = (PLI_BYTE8 *)"$vt_vif";
    d.calltf = vif_calltf;
    vpi_register_systf(&d);
}

void (*vlog_startup_routines[])(void) = {register_all, 0};

#ifdef __cplusplus
}
#endif
