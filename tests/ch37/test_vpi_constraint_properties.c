/* VPI application of test_vpi_constraint_properties (IEEE 1800-2023 37.34). */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "vpi_user.h"
#include "sv_vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

#define MAX 8

static const char *sprop(PLI_INT32 property, vpiHandle h)
{
    PLI_BYTE8 *s = h != NULL ? vpi_get_str(property, h) : NULL;
    return s != NULL ? s : "NULL";
}

static void constraints(vpiHandle cls)
{
    vpiHandle it = cls != NULL ? vpi_iterate(vpiConstraint, cls) : NULL, c;

    vpi_printf((PLI_BYTE8 *)"%s:\n", sprop(vpiName, cls));
    while (it != NULL && (c = vpi_scan(it)) != NULL)
        vpi_printf((PLI_BYTE8 *)"  %s: alloc other %d, automatic %d\n",
                   sprop(vpiName, c),
                   vpi_get(vpiAllocScheme, c) == vpiOtherScheme,
                   (int)vpi_get(vpiAutomatic, c));
}

static PLI_INT32 cons_calltf(PLI_BYTE8 *user_data)
{
    vpiHandle it, h;
    char names[MAX][48];
    vpiHandle classes[MAX];
    int n = 0, i, j;

    (void)user_data;
    it = vpi_iterate(vpiClassDefn, NULL);
    while (it != NULL && (h = vpi_scan(it)) != NULL && n < MAX) {
        snprintf(names[n], sizeof names[0], "%s", sprop(vpiName, h));
        classes[n++] = h;
    }
    for (i = 0; i < n; i++)
        for (j = i + 1; j < n; j++)
            if (strcmp(names[i], names[j]) > 0) {
                char t[48];
                vpiHandle th = classes[i];
                snprintf(t, sizeof t, "%s", names[i]);
                snprintf(names[i], sizeof names[i], "%s", names[j]);
                snprintf(names[j], sizeof names[j], "%s", t);
                classes[i] = classes[j];
                classes[j] = th;
            }
    vpi_printf((PLI_BYTE8 *)"classes:");
    if (n == 0)
        vpi_printf((PLI_BYTE8 *)" none");
    else {
        vpi_printf((PLI_BYTE8 *)" ");
        for (i = 0; i < n; i++)
            vpi_printf((PLI_BYTE8 *)"%s%s", i ? "," : "", names[i]);
    }
    vpi_printf((PLI_BYTE8 *)"\n");

    for (i = 0; i < n; i++)
        constraints(classes[i]);
    return 0;
}

static void register_all(void)
{
    s_vpi_systf_data d;
    memset(&d, 0, sizeof d);
    d.type = vpiSysTask;
    d.tfname = (PLI_BYTE8 *)"$vt_cons";
    d.calltf = cons_calltf;
    vpi_register_systf(&d);
}

void (*vlog_startup_routines[])(void) = {register_all, 0};

#ifdef __cplusplus
}
#endif
