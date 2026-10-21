/* VPI application of test_vpi_path_terms_tchk_args (IEEE 1800-2023 37.39, 37.40). */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "vpi_user.h"
#include "sv_vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

#define CELL "test_vpi_path_terms_tchk_args.u"
#define MAX_LINES 8

static char lines[MAX_LINES][200];
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
    return h != NULL && vpi_get_str(vpiName, h) != NULL ? vpi_get_str(vpiName, h) : "none";
}

static int int_value(vpiHandle h)
{
    s_vpi_value v;
    v.format = vpiIntVal;
    vpi_get_value(h, &v);
    return (int)v.value.integer;
}

static const char *edge_name(PLI_INT32 edge)
{
    switch (edge) {
    case vpiNoEdge: return "none";
    case vpiPosedge: return "posedge";
    case vpiNegedge: return "negedge";
    default: return "other";
    }
}

/* The names of the expressions of the path terms of one iteration. */
static void term_names(PLI_INT32 type, vpiHandle path, char *buf, size_t size)
{
    vpiHandle it = vpi_iterate(type, path), term;
    int n = 0;
    while (it != NULL && (term = vpi_scan(it)) != NULL) {
        append(buf, size, n++ ? " " : "");
        append(buf, size, name_of(vpi_handle(vpiExpr, term)));
    }
    if (n == 0)
        append(buf, size, "none");
}

static void report_path(vpiHandle path, vpiHandle cell)
{
    char in[32] = "", out[32] = "", data[32] = "";
    vpiHandle it = vpi_iterate(vpiModPathIn, path), term, first = NULL, inst;
    PLI_INT32 polarity;

    if (it != NULL && (first = vpi_scan(it)) != NULL)
        vpi_release_handle(it);
    term_names(vpiModPathIn, path, in, sizeof in);
    term_names(vpiModPathOut, path, out, sizeof out);
    term_names(vpiModDataPathIn, path, data, sizeof data);
    term = first;
    inst = vpi_handle(vpiInstance, path);
    polarity = vpi_get(vpiDataPolarity, path);
    if (n_lines < MAX_LINES)
        snprintf(lines[n_lines++], sizeof lines[0],
                 "%s -> %s: input edge %s, data path terms: %s%s, instance is u %d", in, out,
                 term ? edge_name(vpi_get(vpiEdge, term)) : "(no term)", data,
                 strcmp(data, "none") == 0 ? ""
                 : polarity == vpiPositive ? ", data polarity positive"
                 : polarity == vpiNegative ? ", data polarity negative" : ", data polarity other",
                 inst != NULL && vpi_compare_objects(inst, cell) == 1);
}

static const char *check_name(PLI_INT32 type)
{
    switch (type) {
    case vpiSetup: return "$setup";
    case vpiSetupHold: return "$setuphold";
    case vpiPeriod: return "$period";
    default: return "other";
    }
}

/* "posedge clk" or "d", with " if en" for a condition after &&&. */
static void describe_term(vpiHandle term, char *buf, size_t size)
{
    char part[48];
    vpiHandle cond;
    PLI_INT32 edge;

    if (term == NULL) {
        append(buf, size, "none");
        return;
    }
    edge = vpi_get(vpiEdge, term);
    cond = vpi_handle(vpiCondition, term);
    snprintf(part, sizeof part, "%s%s%s%s", edge == vpiNoEdge ? "" : edge_name(edge),
             edge == vpiNoEdge ? "" : " ", name_of(vpi_handle(vpiExpr, term)),
             cond != NULL ? " if " : "");
    append(buf, size, part);
    if (cond != NULL)
        append(buf, size, name_of(cond));
}

static int compare_int(const void *x, const void *y)
{
    int a = *(const int *)x, b = *(const int *)y;
    return a < b ? -1 : a > b;
}

/* The value of a single delay, or the values of a list operation, sorted. */
static void describe_delay(vpiHandle delay, char *buf, size_t size)
{
    char part[16];
    int values[4], n = 0, i;
    vpiHandle it, op;

    if (delay == NULL) {
        append(buf, size, "none");
    } else if (vpi_get(vpiType, delay) == vpiOperation && vpi_get(vpiOpType, delay) == vpiListOp) {
        it = vpi_iterate(vpiOperand, delay);
        while (it != NULL && (op = vpi_scan(it)) != NULL)
            if (n < 4)
                values[n++] = int_value(op);
        qsort(values, (size_t)n, sizeof values[0], compare_int);
        append(buf, size, "list, sorted:");
        for (i = 0; i < n; i++) {
            snprintf(part, sizeof part, " %d", values[i]);
            append(buf, size, part);
        }
    } else {
        snprintf(part, sizeof part, "%d", int_value(delay));
        append(buf, size, part);
    }
}

static void report_check(vpiHandle tchk)
{
    char buf[200], part[96];
    vpiHandle it = vpi_iterate(vpiExpr, tchk), arg;
    int terms = 0, constants = 0, variables = 0, others = 0;

    while (it != NULL && (arg = vpi_scan(it)) != NULL) {
        switch (vpi_get(vpiType, arg)) {
        case vpiTchkTerm: terms++; break;
        case vpiConstant: constants++; break;
        case vpiReg: variables++; break;
        default: others++;
        }
    }
    snprintf(buf, sizeof buf, "%s: reference ", check_name(vpi_get(vpiTchkType, tchk)));
    describe_term(vpi_handle(vpiTchkRefTerm, tchk), buf, sizeof buf);
    if (vpi_get(vpiTchkType, tchk) != vpiPeriod) {
        append(buf, sizeof buf, ", data ");
        describe_term(vpi_handle(vpiTchkDataTerm, tchk), buf, sizeof buf);
    }
    append(buf, sizeof buf, ", delay ");
    describe_delay(vpi_handle(vpiDelay, tchk), buf, sizeof buf);
    snprintf(part, sizeof part, ", arguments: tchk terms %d, constants %d, variables %d, others %d",
             terms, constants, variables, others);
    append(buf, sizeof buf, part);
    if (n_lines < MAX_LINES)
        snprintf(lines[n_lines++], sizeof lines[0], "%s", buf);
}

static void print_lines(const char *title)
{
    int i;
    qsort(lines, (size_t)n_lines, sizeof lines[0], compare);
    vpi_printf((PLI_BYTE8 *)"%s: %d\n", title, n_lines);
    for (i = 0; i < n_lines; i++)
        vpi_printf((PLI_BYTE8 *)"  %s\n", lines[i]);
    n_lines = 0;
}

static PLI_INT32 specify_calltf(PLI_BYTE8 *user_data)
{
    vpiHandle cell = vpi_handle_by_name((PLI_BYTE8 *)CELL, NULL), it, h;

    (void)user_data;
    if (cell == NULL) {
        vpi_printf((PLI_BYTE8 *)"%s not found\n", CELL);
        return 0;
    }
    it = vpi_iterate(vpiModPath, cell);
    while (it != NULL && (h = vpi_scan(it)) != NULL)
        report_path(h, cell);
    print_lines("module paths");
    it = vpi_iterate(vpiTchk, cell);
    while (it != NULL && (h = vpi_scan(it)) != NULL)
        report_check(h);
    print_lines("timing checks");
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
