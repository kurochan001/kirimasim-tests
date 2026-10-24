/* VPI application of test_vpi_tchk_relations_path_delays (IEEE 1800-2023 37.40, 37.39). */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

#define TOP "test_vpi_tchk_relations_path_delays"
#define MAX 8
#define LEN 160

static char lines[MAX][LEN];
static int n_lines;

static int by_text(const void *x, const void *y)
{
    return strcmp((const char *)x, (const char *)y);
}

static void add_line(const char *s)
{
    if (n_lines < MAX)
        snprintf(lines[n_lines++], LEN, "%s", s);
}

static void flush_lines(void)
{
    int i;
    qsort(lines, (size_t)n_lines, LEN, by_text);
    for (i = 0; i < n_lines; i++)
        vpi_printf((PLI_BYTE8 *)"%s\n", lines[i]);
    n_lines = 0;
}

static int int_value(vpiHandle h)
{
    s_vpi_value v;
    v.format = vpiIntVal;
    vpi_get_value(h, &v);
    return (int)v.value.integer;
}

static const char *expr_name(vpiHandle term)
{
    vpiHandle e = term != NULL ? vpi_handle(vpiExpr, term) : NULL;
    PLI_BYTE8 *s = e != NULL ? vpi_get_str(vpiName, e) : NULL;
    return s != NULL ? s : "(none)";
}

static const char *tchk_name(vpiHandle tchk)
{
    switch (vpi_get(vpiTchkType, tchk)) {
    case vpiSetup: return "$setup";
    case vpiHold: return "$hold";
    case vpiWidth: return "$width";
    default: return "other";
    }
}

/* A term and whether vpiTchk of the term is the check again. */
static void term(vpiHandle tchk, PLI_INT32 rel, char *out, size_t len)
{
    vpiHandle t = vpi_handle(rel, tchk), back;
    if (t == NULL) {
        snprintf(out, len, "none");
        return;
    }
    back = vpi_handle(vpiTchk, t);
    snprintf(out, len, "%s, its check %d", expr_name(t),
             back != NULL && vpi_compare_objects(back, tchk));
}

static double limit(vpiHandle tchk)
{
    s_vpi_time t[1];
    s_vpi_delay d;
    memset(t, 0, sizeof t);
    memset(&d, 0, sizeof d);
    d.da = t;
    d.no_of_delays = 1;
    d.time_type = vpiScaledRealTime;
    vpi_get_delays(tchk, &d);
    return t[0].real;
}

static void set_limit(vpiHandle tchk, double value)
{
    s_vpi_time t[1];
    s_vpi_delay d;
    memset(t, 0, sizeof t);
    memset(&d, 0, sizeof d);
    t[0].type = vpiScaledRealTime;
    t[0].real = value;
    d.da = t;
    d.no_of_delays = 1;
    d.time_type = vpiScaledRealTime;
    vpi_put_delays(tchk, &d);
}

static void checks_of(const char *inst, double new_limit)
{
    char full[96], ref[64], data[64], mod[96], line[LEN];
    vpiHandle m, it, tchk, tm;
    double before;

    snprintf(full, sizeof full, "%s.%s", TOP, inst);
    m = vpi_handle_by_name((PLI_BYTE8 *)full, NULL);
    it = m != NULL ? vpi_iterate(vpiTchk, m) : NULL;
    while (it != NULL && (tchk = vpi_scan(it)) != NULL) {
        term(tchk, vpiTchkRefTerm, ref, sizeof ref);
        term(tchk, vpiTchkDataTerm, data, sizeof data);
        tm = vpi_handle(vpiModule, tchk);
        snprintf(mod, sizeof mod, "%s", tm != NULL && vpi_get_str(vpiFullName, tm) != NULL
                 ? vpi_get_str(vpiFullName, tm) : "NULL");
        before = limit(tchk);
        if (vpi_get(vpiTchkType, tchk) != vpiHold)
            set_limit(tchk, new_limit);
        snprintf(line, sizeof line, "  %s: module %s, reference %s, data %s, limit %g, now %g",
                 tchk_name(tchk), mod, ref, data, before, limit(tchk));
        add_line(line);
    }
    vpi_printf((PLI_BYTE8 *)"timing checks of %s: %d\n", inst, n_lines);
    flush_lines();
}

static void path_delays_of(const char *inst)
{
    char full[96], line[LEN];
    vpiHandle m, it, path, oit, out, e, opit, op;

    snprintf(full, sizeof full, "%s.%s", TOP, inst);
    m = vpi_handle_by_name((PLI_BYTE8 *)full, NULL);
    it = m != NULL ? vpi_iterate(vpiModPath, m) : NULL;
    while (it != NULL && (path = vpi_scan(it)) != NULL) {
        oit = vpi_iterate(vpiModPathOut, path);
        out = oit != NULL ? vpi_scan(oit) : NULL;
        if (out != NULL)
            vpi_free_object(oit);
        e = vpi_handle(vpiDelay, path);
        snprintf(line, sizeof line, "  path to %s: ", expr_name(out));
        if (e == NULL) {
            snprintf(line + strlen(line), sizeof line - strlen(line), "NULL");
        } else if (vpi_get(vpiType, e) != vpiOperation) {
            snprintf(line + strlen(line), sizeof line - strlen(line), "value %d", int_value(e));
        } else {
            int vals[8], n = 0, i, k;
            snprintf(line + strlen(line), sizeof line - strlen(line),
                     "list operation %d, operands sorted:", vpi_get(vpiOpType, e) == vpiListOp);
            opit = vpi_iterate(vpiOperand, e);
            while (opit != NULL && (op = vpi_scan(opit)) != NULL)
                if (n < 8)
                    vals[n++] = int_value(op);
            for (i = 1; i < n; i++)
                for (k = i; k > 0 && vals[k - 1] > vals[k]; k--) {
                    int t = vals[k];
                    vals[k] = vals[k - 1];
                    vals[k - 1] = t;
                }
            for (i = 0; i < n; i++)
                snprintf(line + strlen(line), sizeof line - strlen(line), " %d", vals[i]);
        }
        add_line(line);
    }
    vpi_printf((PLI_BYTE8 *)"delay expressions of the paths of %s: %d\n", inst, n_lines);
    flush_lines();
}

static PLI_INT32 specify_calltf(PLI_BYTE8 *user_data)
{
    (void)user_data;
    checks_of("u1", 7.0);
    checks_of("u2", 8.0);
    path_delays_of("u1");
    path_delays_of("u2");
    return 0;
}

static void register_all(void)
{
    s_vpi_systf_data d;
    memset(&d, 0, sizeof d);
    d.type = vpiSysTask;
    d.tfname = (PLI_BYTE8 *)"$vt_specify";
    d.calltf = specify_calltf;
    vpi_register_systf(&d);
}

void (*vlog_startup_routines[])(void) = {register_all, 0};

#ifdef __cplusplus
}
#endif
