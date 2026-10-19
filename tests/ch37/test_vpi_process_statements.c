/* VPI application of test_vpi_process_statements (IEEE 1800-2023 37.63 to 37.68). */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "vpi_user.h"
#include "sv_vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

#define MAX_LINES 8

static char lines[MAX_LINES][160];
static int n_lines;

static int compare(const void *x, const void *y)
{
    return strcmp((const char *)x, (const char *)y);
}

static void append(char *buf, size_t size, const char *text)
{
    size_t len = strlen(buf);
    snprintf(buf + len, size - len, "%s", text);
}

static const char *name_of(vpiHandle h)
{
    return h != NULL && vpi_get_str(vpiName, h) != NULL ? vpi_get_str(vpiName, h) : "?";
}

/* The name of a simple expression, or the value of a constant. */
static void operand_text(vpiHandle h, char *buf, size_t size)
{
    s_vpi_value v;

    if (h != NULL && vpi_get(vpiType, h) == vpiConstant) {
        v.format = vpiIntVal;
        vpi_get_value(h, &v);
        snprintf(buf, size, "%d", (int)v.value.integer);
    } else {
        snprintf(buf, size, "%s", name_of(h));
    }
}

static double delay_of(vpiHandle control)
{
    s_vpi_time t[1];
    s_vpi_delay d;
    memset(&d, 0, sizeof d);
    memset(t, 0, sizeof t);
    d.da = t;
    d.no_of_delays = 1;
    d.time_type = vpiScaledRealTime;
    vpi_get_delays(control, &d);
    return t[0].real;
}

static void describe_stmt(vpiHandle s, char *buf, size_t size);

static void describe_assignment(vpiHandle a, char *buf, size_t size)
{
    char part[64], rhs[32];
    vpiHandle dc = vpi_handle(vpiDelayControl, a);
    PLI_INT32 op = vpi_get(vpiOpType, a);

    snprintf(part, sizeof part, "%s assignment %s ", vpi_get(vpiBlocking, a) == 1 ? "blocking" :
             "nonblocking", name_of(vpi_handle(vpiLhs, a)));
    append(buf, size, part);
    operand_text(vpi_handle(vpiRhs, a), rhs, sizeof rhs);
    snprintf(part, sizeof part, "%s %s", op == vpiAssignmentOp ? "=" : op == vpiAddOp ? "+=" : "?=",
             rhs);
    append(buf, size, part);
    if (dc != NULL) {
        snprintf(part, sizeof part, ", intra-assignment delay %g", delay_of(dc));
        append(buf, size, part);
    }
}

static void describe_stmt(vpiHandle s, char *buf, size_t size)
{
    char part[64];
    vpiHandle cond, operand_it, operand;

    if (s == NULL) {
        append(buf, size, "no statement");
        return;
    }
    switch (vpi_get(vpiType, s)) {
    case vpiEventControl:
        cond = vpi_handle(vpiCondition, s);
        operand_it = cond ? vpi_iterate(vpiOperand, cond) : NULL;
        operand = operand_it ? vpi_scan(operand_it) : NULL;
        snprintf(part, sizeof part, "event control %s%s, then ",
                 cond && vpi_get(vpiOpType, cond) == vpiPosedgeOp ? "posedge " : "",
                 name_of(operand ? operand : cond));
        if (operand_it != NULL && operand != NULL)
            vpi_release_handle(operand_it);
        append(buf, size, part);
        describe_stmt(vpi_handle(vpiStmt, s), buf, size);
        break;
    case vpiDelayControl:
        snprintf(part, sizeof part, "delay control %g, then ", delay_of(s));
        append(buf, size, part);
        describe_stmt(vpi_handle(vpiStmt, s), buf, size);
        break;
    case vpiAssignment:
        describe_assignment(s, buf, size);
        break;
    case vpiSysTaskCall:
        snprintf(part, sizeof part, "call of %s", name_of(s));
        append(buf, size, part);
        break;
    default:
        append(buf, size, "other statement");
    }
}

static const char *process_kind(vpiHandle p)
{
    switch (vpi_get(vpiType, p)) {
    case vpiInitial: return "initial";
    case vpiFinal: return "final";
    case vpiAlways:
        switch (vpi_get(vpiAlwaysType, p)) {
        case vpiAlways: return "always";
        case vpiAlwaysComb: return "always_comb";
        case vpiAlwaysFF: return "always_ff";
        case vpiAlwaysLatch: return "always_latch";
        default: return "always of other type";
        }
    default: return "other process";
    }
}

static PLI_INT32 processes_calltf(PLI_BYTE8 *user_data)
{
    vpiHandle mod = vpi_handle_by_name((PLI_BYTE8 *)"test_vpi_process_statements", NULL);
    vpiHandle it = mod ? vpi_iterate(vpiProcess, mod) : NULL, p;
    int i;

    (void)user_data;
    if (it != NULL)
        while ((p = vpi_scan(it)) != NULL && n_lines < MAX_LINES) {
            snprintf(lines[n_lines], sizeof lines[0], "%s: ", process_kind(p));
            describe_stmt(vpi_handle(vpiStmt, p), lines[n_lines], sizeof lines[0]);
            n_lines++;
        }
    qsort(lines, (size_t)n_lines, sizeof lines[0], compare);
    vpi_printf((PLI_BYTE8 *)"processes: %d\n", n_lines);
    for (i = 0; i < n_lines; i++)
        vpi_printf((PLI_BYTE8 *)"  %s\n", lines[i]);
    return 0;
}

static void register_all(void)
{
    s_vpi_systf_data d;
    memset(&d, 0, sizeof d);
    d.type = vpiSysTask;
    d.tfname = (PLI_BYTE8 *)"$vt_processes";
    d.calltf = processes_calltf;
    vpi_register_systf(&d);
}

void (*vlog_startup_routines[])(void) = {register_all, 0};

#ifdef __cplusplus
}
#endif
