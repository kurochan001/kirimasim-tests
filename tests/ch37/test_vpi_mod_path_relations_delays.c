/* VPI application of test_vpi_mod_path_relations_delays (IEEE 1800-2023 37.39). */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

#define TOP "test_vpi_mod_path_relations_delays"
#define MAX 8
#define LEN 128

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

static const char *term_name(vpiHandle term)
{
    vpiHandle e = vpi_handle(vpiExpr, term);
    PLI_BYTE8 *s = e != NULL ? vpi_get_str(vpiName, e) : NULL;
    return s != NULL ? s : "(none)";
}

static const char *direction(vpiHandle term)
{
    switch (vpi_get(vpiDirection, term)) {
    case vpiInput: return "input";
    case vpiOutput: return "output";
    case vpiInout: return "inout";
    default: return "other";
    }
}

/* The terms of one side of a path: name, direction, and whether vpiModPath
 * of the term is the path again. */
static void terms(vpiHandle path, PLI_INT32 rel, char *out, size_t len)
{
    char names[4][48];
    vpiHandle it = vpi_iterate(rel, path), term, back;
    int n = 0, i;

    while (it != NULL && (term = vpi_scan(it)) != NULL) {
        back = vpi_handle(vpiModPath, term);
        if (n < 4)
            snprintf(names[n++], sizeof names[0], "%s %s, path %d", term_name(term),
                     direction(term), back != NULL && vpi_compare_objects(back, path));
    }
    qsort(names, (size_t)n, sizeof names[0], by_text);
    out[0] = '\0';
    for (i = 0; i < n; i++)
        snprintf(out + strlen(out), len - strlen(out), "%s%s", i ? "; " : "", names[i]);
}

static void paths_of(const char *inst)
{
    char full[96], in[96], outs[96], mod[96], line[LEN];
    vpiHandle m, it, path, pm;

    snprintf(full, sizeof full, "%s.%s", TOP, inst);
    m = vpi_handle_by_name((PLI_BYTE8 *)full, NULL);
    it = m != NULL ? vpi_iterate(vpiModPath, m) : NULL;
    while (it != NULL && (path = vpi_scan(it)) != NULL) {
        terms(path, vpiModPathIn, in, sizeof in);
        terms(path, vpiModPathOut, outs, sizeof outs);
        pm = vpi_handle(vpiModule, path);
        snprintf(mod, sizeof mod, "%s", pm != NULL && vpi_get_str(vpiFullName, pm) != NULL
                 ? vpi_get_str(vpiFullName, pm) : "NULL");
        snprintf(line, sizeof line, "  in: %s | out: %s | module %s", in, outs, mod);
        add_line(line);
    }
    vpi_printf((PLI_BYTE8 *)"paths of %s: %d\n", inst, n_lines);
    flush_lines();
}

/* The path of u1 whose output term is z. */
static vpiHandle path_to_z(void)
{
    vpiHandle m = vpi_handle_by_name((PLI_BYTE8 *)TOP ".u1", NULL), it, path, out, found = NULL;
    vpiHandle oit;

    it = m != NULL ? vpi_iterate(vpiModPath, m) : NULL;
    while (it != NULL && (path = vpi_scan(it)) != NULL) {
        oit = vpi_iterate(vpiModPathOut, path);
        out = oit != NULL ? vpi_scan(oit) : NULL;
        if (out != NULL) {
            vpi_free_object(oit);
            if (strcmp(term_name(out), "z") == 0)
                found = path;
        }
    }
    return found;
}

static void delays(vpiHandle path, double *rise, double *fall)
{
    s_vpi_time t[2];
    s_vpi_delay d;
    memset(t, 0, sizeof t);
    memset(&d, 0, sizeof d);
    d.da = t;
    d.no_of_delays = 2;
    d.time_type = vpiScaledRealTime;
    vpi_get_delays(path, &d);
    *rise = t[0].real;
    *fall = t[1].real;
}

static PLI_INT32 paths_calltf(PLI_BYTE8 *user_data)
{
    vpiHandle p;
    s_vpi_time t[2];
    s_vpi_delay d;
    double r0, f0, r1, f1;

    (void)user_data;
    paths_of("u1");
    paths_of("u2");
    p = path_to_z();
    if (p == NULL) {
        vpi_printf((PLI_BYTE8 *)"path a => z not found\n");
        return 0;
    }
    delays(p, &r0, &f0);
    memset(t, 0, sizeof t);
    memset(&d, 0, sizeof d);
    t[0].type = t[1].type = vpiScaledRealTime;
    t[0].real = 6.0;
    t[1].real = 1.0;
    d.da = t;
    d.no_of_delays = 2;
    d.time_type = vpiScaledRealTime;
    vpi_put_delays(p, &d);
    delays(p, &r1, &f1);
    vpi_printf((PLI_BYTE8 *)"delays of a => z: %g %g, after vpi_put_delays: %g %g\n", r0, f0, r1,
               f1);
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
