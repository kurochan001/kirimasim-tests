/* VPI application of test_vpi_process_kinds_relations (IEEE 1800-2023 37.63). */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "vpi_user.h"
#include "sv_vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

#define TOP "test_vpi_process_kinds_relations"
#define MAX_LINES 16

static char lines[MAX_LINES][192];
static int line_count;

static int compare(const void *x, const void *y)
{
    return strcmp((const char *)x, (const char *)y);
}

static void full_name(vpiHandle h, char *buf, size_t size)
{
    const char *s = h != NULL ? vpi_get_str(vpiFullName, h) : NULL;
    snprintf(buf, size, "%s", s != NULL ? s : "none");
}

static const char *kind_of(vpiHandle h)
{
    if (h == NULL)
        return "none";
    switch (vpi_get(vpiType, h)) {
    case vpiInitial: return "initial";
    case vpiFinal: return "final";
    case vpiAlways: return "always";
    case vpiAssignment: return "assignment";
    case vpiEventControl: return "event control";
    case vpiIf: return "if";
    case vpiNamedBegin: return "named begin";
    case vpiBegin: return "begin";
    default: return "other";
    }
}

static const char *always_type(vpiHandle p)
{
    if (vpi_get(vpiType, p) != vpiAlways)
        return "";
    switch (vpi_get(vpiAlwaysType, p)) {
    case vpiAlways: return " vpiAlways";
    case vpiAlwaysComb: return " vpiAlwaysComb";
    case vpiAlwaysFF: return " vpiAlwaysFF";
    case vpiAlwaysLatch: return " vpiAlwaysLatch";
    default: return " other always type";
    }
}

/* Whether stmt leads back to proc, and the full name of its scope. */
static void stmt_relations(vpiHandle stmt, vpiHandle proc, char *buf, size_t size)
{
    char scope[96];
    vpiHandle back = stmt != NULL ? vpi_handle(vpiProcess, stmt) : NULL;
    int same = back != NULL && vpi_compare_objects(back, proc);

    full_name(stmt != NULL ? vpi_handle(vpiScope, stmt) : NULL, scope, sizeof scope);
    snprintf(buf, size, "same process %d, scope %s", same, scope);
}

static void add_line(const char *head, vpiHandle stmt, vpiHandle proc)
{
    char rel[128];

    if (line_count == MAX_LINES)
        return;
    stmt_relations(stmt, proc, rel, sizeof rel);
    snprintf(lines[line_count++], sizeof lines[0], "%s: %s", head, rel);
}

/* The statements of a named begin, each with its relations. */
static void block_statements(vpiHandle block, vpiHandle proc)
{
    char head[96], name[48];
    vpiHandle it = block != NULL ? vpi_iterate(vpiStmt, block) : NULL, s;
    const char *n = block != NULL ? vpi_get_str(vpiName, block) : NULL;

    snprintf(name, sizeof name, "%s", n != NULL ? n : "?");
    while (it != NULL && (s = vpi_scan(it)) != NULL) {
        snprintf(head, sizeof head, "%s in %s", kind_of(s), name);
        add_line(head, s, proc);
    }
}

static void processes_of(vpiHandle mod)
{
    char head[160], module[96];
    vpiHandle it = mod != NULL ? vpi_iterate(vpiProcess, mod) : NULL, p, stmt;

    while (it != NULL && (p = vpi_scan(it)) != NULL) {
        stmt = vpi_handle(vpiStmt, p);
        full_name(vpi_handle(vpiModule, p), module, sizeof module);
        snprintf(head, sizeof head, "%s%s in %s: statement %s", kind_of(p), always_type(p),
                 module, kind_of(stmt));
        add_line(head, stmt, p);
        if (stmt != NULL && vpi_get(vpiType, stmt) == vpiNamedBegin)
            block_statements(stmt, p);
        if (vpi_get(vpiType, p) == vpiAlways && vpi_get(vpiAlwaysType, p) == vpiAlwaysLatch
            && stmt != NULL && vpi_get(vpiType, stmt) == vpiIf) {
            snprintf(head, sizeof head, "%s in the if of always_latch",
                     kind_of(vpi_handle(vpiStmt, stmt)));
            add_line(head, vpi_handle(vpiStmt, stmt), p);
        }
    }
}

static PLI_INT32 start_of_simulation(p_cb_data data)
{
    int i;

    (void)data;
    processes_of(vpi_handle_by_name((PLI_BYTE8 *)TOP, NULL));
    processes_of(vpi_handle_by_name((PLI_BYTE8 *)TOP ".u", NULL));
    qsort(lines, (size_t)line_count, sizeof lines[0], compare);
    for (i = 0; i < line_count; i++)
        vpi_printf((PLI_BYTE8 *)"%s\n", lines[i]);
    vpi_printf((PLI_BYTE8 *)"lines: %d\n", line_count);
    return 0;
}

static void register_all(void)
{
    s_cb_data d;
    memset(&d, 0, sizeof d);
    d.reason = cbStartOfSimulation;
    d.cb_rtn = start_of_simulation;
    vpi_register_cb(&d);
}

void (*vlog_startup_routines[])(void) = {register_all, 0};

#ifdef __cplusplus
}
#endif
