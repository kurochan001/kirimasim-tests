/* VPI application of test_vpi_cont_assign_module_delays (IEEE 1800-2023 37.47). */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

#define TOP "test_vpi_cont_assign_module_delays"
#define MAX 8
#define LEN 128

static char lines[MAX][LEN];
static int n_lines;

static int by_text(const void *x, const void *y)
{
    return strcmp((const char *)x, (const char *)y);
}

static int int_value(vpiHandle h)
{
    s_vpi_value v;
    v.format = vpiIntVal;
    vpi_get_value(h, &v);
    return (int)v.value.integer;
}

/* The delay expression: "constant N" or "list a b". */
static void delay_expr(vpiHandle obj, char *out, size_t len)
{
    vpiHandle e = vpi_handle(vpiDelay, obj), it, op;
    int vals[4], n = 0, i, t;

    if (e == NULL) {
        snprintf(out, len, "NULL");
        return;
    }
    if (vpi_get(vpiType, e) != vpiOperation) {
        snprintf(out, len, "value %d", int_value(e));
        return;
    }
    it = vpi_iterate(vpiOperand, e);
    while (it != NULL && (op = vpi_scan(it)) != NULL)
        if (n < 4)
            vals[n++] = int_value(op);
    for (i = 1; i < n; i++)
        for (t = i; t > 0 && vals[t - 1] > vals[t]; t--) {
            int s = vals[t];
            vals[t] = vals[t - 1];
            vals[t - 1] = s;
        }
    snprintf(out, len, "list operation %d, operands", vpi_get(vpiOpType, e) == vpiListOp);
    for (i = 0; i < n; i++)
        snprintf(out + strlen(out), len - strlen(out), " %d", vals[i]);
}

static void delays(vpiHandle obj, int n, char *out, size_t len)
{
    s_vpi_time t[2];
    s_vpi_delay d;
    int i;

    memset(t, 0, sizeof t);
    memset(&d, 0, sizeof d);
    d.da = t;
    d.no_of_delays = n;
    d.time_type = vpiScaledRealTime;
    vpi_get_delays(obj, &d);
    out[0] = '\0';
    for (i = 0; i < n; i++)
        snprintf(out + strlen(out), len - strlen(out), "%s%g", i ? " " : "", t[i].real);
}

static void value_str(vpiHandle obj, char *out, size_t len)
{
    s_vpi_value v;
    v.format = vpiBinStrVal;
    vpi_get_value(obj, &v);
    snprintf(out, len, "%s", v.value.str != NULL ? v.value.str : "(none)");
}

static void report(vpiHandle ca, int n_delays)
{
    vpiHandle lhs = vpi_handle(vpiLhs, ca), m = vpi_handle(vpiModule, ca), it, bit;
    char name[32], mod[96], de[64], dl[32], val[16], line[LEN];
    int i;

    snprintf(name, sizeof name, "%s", lhs != NULL && vpi_get_str(vpiName, lhs) != NULL
             ? vpi_get_str(vpiName, lhs) : "(no lhs)");
    snprintf(mod, sizeof mod, "%s", m != NULL && vpi_get_str(vpiFullName, m) != NULL
             ? vpi_get_str(vpiFullName, m) : "NULL");
    delay_expr(ca, de, sizeof de);
    delays(ca, n_delays, dl, sizeof dl);
    value_str(ca, val, sizeof val);
    vpi_printf((PLI_BYTE8 *)"assignment to %s: module %s, delay expression %s, delays %s, "
                            "value %s\n", name, mod, de, dl, val);
    it = vpi_iterate(vpiBit, ca);
    while (it != NULL && (bit = vpi_scan(it)) != NULL) {
        delay_expr(bit, de, sizeof de);
        delays(bit, n_delays, dl, sizeof dl);
        value_str(bit, val, sizeof val);
        snprintf(line, sizeof line, "  bit offset %d: delay expression %s, delays %s, value %s",
                 (int)vpi_get(vpiOffset, bit), de, dl, val);
        if (n_lines < MAX)
            snprintf(lines[n_lines++], LEN, "%s", line);
    }
    qsort(lines, (size_t)n_lines, LEN, by_text);
    for (i = 0; i < n_lines; i++)
        vpi_printf((PLI_BYTE8 *)"%s\n", lines[i]);
    n_lines = 0;
}

/* The continuous assignment of a module instance whose LHS has this name. */
static vpiHandle assignment(const char *inst, const char *lhs_name)
{
    vpiHandle m = vpi_handle_by_name((PLI_BYTE8 *)inst, NULL), it, ca, lhs, found = NULL;

    it = m != NULL ? vpi_iterate(vpiContAssign, m) : NULL;
    while (it != NULL && (ca = vpi_scan(it)) != NULL) {
        lhs = vpi_handle(vpiLhs, ca);
        if (lhs != NULL && vpi_get_str(vpiName, lhs) != NULL &&
            strcmp(vpi_get_str(vpiName, lhs), lhs_name) == 0)
            found = ca;
    }
    return found;
}

static PLI_INT32 assigns_calltf(PLI_BYTE8 *user_data)
{
    vpiHandle w = assignment(TOP, "w"), o = assignment(TOP ".s", "o");

    (void)user_data;
    if (w == NULL || o == NULL) {
        vpi_printf((PLI_BYTE8 *)"an assignment was not found\n");
        return 0;
    }
    report(w, 1);
    report(o, 2);
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
