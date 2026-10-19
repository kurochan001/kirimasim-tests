/* VPI application of test_vpi_cont_assign_drivers (IEEE 1800-2023 37.46, 37.47). */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

#define TOP "test_vpi_cont_assign_drivers"
#define MAX_LINES 16

static char lines[MAX_LINES][128];
static int n_lines;

static int compare(const void *x, const void *y)
{
    return strcmp((const char *)x, (const char *)y);
}

static void print_sorted(const char *prefix)
{
    int i;
    qsort(lines, (size_t)n_lines, sizeof lines[0], compare);
    for (i = 0; i < n_lines; i++)
        vpi_printf("%s%s\n", prefix, lines[i]);
    n_lines = 0;
}

static const char *strength(PLI_INT32 s)
{
    switch (s) {
    case vpiSupplyDrive: return "supply";
    case vpiStrongDrive: return "strong";
    case vpiPullDrive: return "pull";
    case vpiWeakDrive: return "weak";
    case vpiHighZ: return "highz";
    default: return "other";
    }
}

static const char *kind(vpiHandle h)
{
    switch (vpi_get(vpiType, h)) {
    case vpiContAssign: return "cont assign";
    case vpiContAssignBit: return "cont assign bit";
    case vpiPrimTerm: return "prim term";
    case vpiPort: return "port";
    default: return "other";
    }
}

static int int_value(vpiHandle h)
{
    s_vpi_value v;
    v.format = vpiIntVal;
    vpi_get_value(h, &v);
    return (int)v.value.integer;
}

static void report_assign(vpiHandle ca)
{
    vpiHandle lhs = vpi_handle(vpiLhs, ca);
    char name[32], extra[64] = "";

    /* vpi_get_str can reuse its buffer, so the name is copied. */
    snprintf(name, sizeof name, "%s",
             lhs && vpi_get_str(vpiName, lhs) ? vpi_get_str(vpiName, lhs) : "(no lhs)");

    if (vpi_handle(vpiDelay, ca) != NULL) {
        s_vpi_time t[1];
        s_vpi_delay d;
        memset(&d, 0, sizeof d);
        t[0].type = vpiScaledRealTime;
        d.da = t;
        d.no_of_delays = 1;
        d.time_type = vpiScaledRealTime;
        vpi_get_delays(ca, &d);
        snprintf(extra, sizeof extra, ", delay %g", t[0].real);
    }
    if (vpi_get(vpiNetDeclAssign, ca) == 1)
        snprintf(extra + strlen(extra), sizeof extra - strlen(extra), ", net decl, %s0 %s1",
                 strength(vpi_get(vpiStrength0, ca)), strength(vpi_get(vpiStrength1, ca)));
    if (n_lines < MAX_LINES)
        snprintf(lines[n_lines++], sizeof lines[0], "%s = %d%s", name, int_value(ca), extra);
}

static void relation(const char *net, PLI_INT32 type, const char *label)
{
    char full[96];
    vpiHandle h, it, x;

    snprintf(full, sizeof full, "%s.%s", TOP, net);
    h = vpi_handle_by_name(full, NULL);
    it = h ? vpi_iterate(type, h) : NULL;
    if (it != NULL)
        while ((x = vpi_scan(it)) != NULL)
            if (n_lines < MAX_LINES)
                snprintf(lines[n_lines++], sizeof lines[0], "%s", kind(x));
    vpi_printf("%s of %s: %d\n", label, net, n_lines);
    print_sorted("  ");
}

static PLI_INT32 assigns_calltf(PLI_BYTE8 *user_data)
{
    vpiHandle top = vpi_handle_by_name(TOP, NULL), it, ca;

    (void)user_data;
    it = top ? vpi_iterate(vpiContAssign, top) : NULL;
    if (it != NULL)
        while ((ca = vpi_scan(it)) != NULL)
            report_assign(ca);
    vpi_printf("continuous assignments: %d\n", n_lines);
    print_sorted("  ");
    relation("m", vpiDriver, "drivers");
    relation("t", vpiDriver, "drivers");
    relation("n", vpiDriver, "drivers");
    relation("n", vpiLoad, "loads");
    return 0;
}

static void register_all(void)
{
    s_vpi_systf_data d;
    memset(&d, 0, sizeof d);
    d.type = vpiSysTask;
    d.tfname = (PLI_BYTE8 *)"$vt_assigns";
    d.calltf = assigns_calltf;
    vpi_register_systf(&d);
}

void (*vlog_startup_routines[])(void) = {register_all, 0};

#ifdef __cplusplus
}
#endif
