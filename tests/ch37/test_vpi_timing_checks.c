/* VPI application of test_vpi_timing_checks (IEEE 1800-2023 37.40). */
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

static const char *check_name(PLI_INT32 type)
{
    switch (type) {
    case vpiSetup: return "$setup";
    case vpiHold: return "$hold";
    case vpiRecovery: return "$recovery";
    case vpiRemoval: return "$removal";
    case vpiSetupHold: return "$setuphold";
    default: return "other";
    }
}

static const char *expr_name(vpiHandle h)
{
    return h != NULL && vpi_get_str(vpiName, h) != NULL ? vpi_get_str(vpiName, h) : "(none)";
}

/* The edge and terminal of a tchk term, as in "posedge clk". */
static void describe_term(vpiHandle term, char *buf, size_t size)
{
    PLI_INT32 edge;

    if (term == NULL) {
        snprintf(buf, size, "none");
        return;
    }
    edge = vpi_get(vpiEdge, term);
    snprintf(buf, size, "%s%s", edge == vpiPosedge ? "posedge " : edge == vpiNegedge ? "negedge " :
             edge == vpiNoEdge ? "" : "other edge ", expr_name(vpi_handle(vpiExpr, term)));
}

static void report(vpiHandle tchk)
{
    char ref[48], data[48];
    s_vpi_time t[1];
    s_vpi_delay d;

    describe_term(vpi_handle(vpiTchkRefTerm, tchk), ref, sizeof ref);
    describe_term(vpi_handle(vpiTchkDataTerm, tchk), data, sizeof data);
    memset(&d, 0, sizeof d);
    memset(t, 0, sizeof t);
    d.da = t;
    d.no_of_delays = 1;
    d.time_type = vpiScaledRealTime;
    vpi_get_delays(tchk, &d);
    if (n_lines < MAX_LINES)
        snprintf(lines[n_lines++], sizeof lines[0],
                 "%s: reference %s, data %s, limit %g, notifier %s",
                 check_name(vpi_get(vpiTchkType, tchk)), ref, data, t[0].real,
                 expr_name(vpi_handle(vpiTchkNotifier, tchk)));
}

static PLI_INT32 checks_calltf(PLI_BYTE8 *user_data)
{
    vpiHandle mod = vpi_handle_by_name((PLI_BYTE8 *)"test_vpi_timing_checks.u", NULL);
    vpiHandle it = mod ? vpi_iterate(vpiTchk, mod) : NULL, tchk;
    int i;

    (void)user_data;
    if (it != NULL)
        while ((tchk = vpi_scan(it)) != NULL)
            report(tchk);
    qsort(lines, (size_t)n_lines, sizeof lines[0], compare);
    vpi_printf((PLI_BYTE8 *)"timing checks: %d\n", n_lines);
    for (i = 0; i < n_lines; i++)
        vpi_printf((PLI_BYTE8 *)"  %s\n", lines[i]);
    return 0;
}

static void register_all(void)
{
    s_vpi_systf_data d;
    memset(&d, 0, sizeof d);
    d.type = vpiSysTask;
    d.tfname = (PLI_BYTE8 *)"$vt_checks";
    d.calltf = checks_calltf;
    vpi_register_systf(&d);
}

void (*vlog_startup_routines[])(void) = {register_all, 0};

#ifdef __cplusplus
}
#endif
