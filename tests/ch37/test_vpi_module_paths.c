/* VPI application of test_vpi_module_paths (IEEE 1800-2023 37.39). */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

#define MAX_LINES 8

static char lines[MAX_LINES][128];
static int n_lines;

static int compare(const void *x, const void *y)
{
    return strcmp((const char *)x, (const char *)y);
}

/* The name of the terminal of the first path term of the given relation. */
static const char *term_name(vpiHandle path, PLI_INT32 relation)
{
    vpiHandle it = vpi_iterate(relation, path), term, expr;
    const char *name = "(none)";

    if (it == NULL)
        return name;
    term = vpi_scan(it);
    if (term != NULL) {
        expr = vpi_handle(vpiExpr, term);
        if (expr != NULL && vpi_get_str(vpiName, expr) != NULL)
            name = vpi_get_str(vpiName, expr);
        vpi_release_handle(it);
    }
    return name;
}

static const char *polarity(PLI_INT32 p)
{
    switch (p) {
    case vpiPositive: return "positive";
    case vpiNegative: return "negative";
    case vpiUnknown: return "unknown";
    default: return "other";
    }
}

static void report(vpiHandle path)
{
    char in[32], out[32], cond[32];
    vpiHandle c = vpi_handle(vpiCondition, path);
    s_vpi_time t[2];
    s_vpi_delay d;

    snprintf(in, sizeof in, "%s", term_name(path, vpiModPathIn));
    snprintf(out, sizeof out, "%s", term_name(path, vpiModPathOut));
    snprintf(cond, sizeof cond, "%s",
             c != NULL && vpi_get_str(vpiName, c) != NULL ? vpi_get_str(vpiName, c) : "none");
    memset(&d, 0, sizeof d);
    memset(t, 0, sizeof t);
    d.da = t;
    d.no_of_delays = 2;
    d.time_type = vpiScaledRealTime;
    vpi_get_delays(path, &d);
    if (n_lines < MAX_LINES)
        snprintf(lines[n_lines++], sizeof lines[0],
                 "%s -> %s: %s, polarity %s, ifnone %d, condition %s, delays %g %g", in, out,
                 vpi_get(vpiPathType, path) == vpiPathFull ? "full" :
                 vpi_get(vpiPathType, path) == vpiPathParallel ? "parallel" : "other",
                 polarity(vpi_get(vpiPolarity, path)), (int)vpi_get(vpiModPathHasIfNone, path),
                 cond, t[0].real, t[1].real);
}

static PLI_INT32 paths_calltf(PLI_BYTE8 *user_data)
{
    vpiHandle mod = vpi_handle_by_name((PLI_BYTE8 *)"test_vpi_module_paths.u", NULL);
    vpiHandle it = mod ? vpi_iterate(vpiModPath, mod) : NULL, path;
    int i;

    (void)user_data;
    if (it != NULL)
        while ((path = vpi_scan(it)) != NULL)
            report(path);
    qsort(lines, (size_t)n_lines, sizeof lines[0], compare);
    vpi_printf((PLI_BYTE8 *)"module paths: %d\n", n_lines);
    for (i = 0; i < n_lines; i++)
        vpi_printf((PLI_BYTE8 *)"  %s\n", lines[i]);
    return 0;
}

static void register_all(void)
{
    s_vpi_systf_data d;
    memset(&d, 0, sizeof d);
    d.type = vpiSysTask;
    d.tfname = (PLI_BYTE8 *)"$vt_paths";
    d.calltf = paths_calltf;
    vpi_register_systf(&d);
}

void (*vlog_startup_routines[])(void) = {register_all, 0};

#ifdef __cplusplus
}
#endif
