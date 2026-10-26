/* VPI application of test_vpi_union_net_tagged (IEEE 1800-2023 37.26). */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "vpi_user.h"
#include "sv_vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

#define TOP "test_vpi_union_net_tagged"

static vpiHandle find(const char *name)
{
    char full[128];
    snprintf(full, sizeof full, "%s.%s", TOP, name);
    return vpi_handle_by_name((PLI_BYTE8 *)full, NULL);
}

static int by_name(const void *a, const void *b)
{
    return strcmp((const char *)a, (const char *)b);
}

static void report(const char *name)
{
    vpiHandle net = find(name);
    const char *type;
    char members[8][32];
    int n = 0, i;

    if (net == NULL) {
        vpi_printf((PLI_BYTE8 *)"%s: not found\n", name);
        return;
    }
    type = vpi_get_str(vpiType, net);
    vpi_printf((PLI_BYTE8 *)"%s: %s, tagged %d, packed %d\n", name,
               type != NULL ? type : "(no type)", (int)vpi_get(vpiTagged, net),
               (int)vpi_get(vpiPacked, net));
    {
        vpiHandle it = vpi_iterate(vpiMember, net), m;
        while (it != NULL && (m = vpi_scan(it)) != NULL) {
            const char *mn = vpi_get_str(vpiName, m);
            if (mn != NULL && n < 8)
                snprintf(members[n++], sizeof members[0], "%s", mn);
        }
    }
    qsort(members, (size_t)n, sizeof members[0], by_name);
    vpi_printf((PLI_BYTE8 *)"  members (%d):", n);
    for (i = 0; i < n; i++)
        vpi_printf((PLI_BYTE8 *)" %s", members[i]);
    vpi_printf((PLI_BYTE8 *)"\n");
}

static PLI_INT32 tagged_calltf(PLI_BYTE8 *user_data)
{
    (void)user_data;
    report("tn");
    report("pn");
    report("sn");
    return 0;
}

static void register_all(void)
{
    s_vpi_systf_data d;

    memset(&d, 0, sizeof d);
    d.type = vpiSysTask;
    d.tfname = (PLI_BYTE8 *)"$vt_tagged";
    d.calltf = tagged_calltf;
    vpi_register_systf(&d);
}

void (*vlog_startup_routines[])(void) = {register_all, 0};

#ifdef __cplusplus
}
#endif
