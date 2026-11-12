/* VPI application of test_vpi_struct_and_tagged_patterns (IEEE 1800-2023 37.72). */
#include <stdarg.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "vpi_user.h"
#include "sv_vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

#define TOP "test_vpi_struct_and_tagged_patterns"
#define MAX_LINES 16
#define LINE_SIZE 160

static char lines[MAX_LINES][LINE_SIZE];
static int line_count;

static int compare(const void *x, const void *y)
{
    return strcmp((const char *)x, (const char *)y);
}

static void add_line(const char *fmt, ...)
{
    va_list ap;

    if (line_count == MAX_LINES)
        return;
    va_start(ap, fmt);
    vsnprintf(lines[line_count], sizeof lines[0], fmt, ap);
    va_end(ap);
    line_count++;
}

static const char *name_or(vpiHandle h, const char *fallback)
{
    const char *s = h != NULL ? vpi_get_str(vpiName, h) : NULL;

    return s != NULL ? s : fallback;
}

/* One pattern of a case item, with the relations that the diagram gives it.
   The diagram draws struct pattern to pattern and tagged pattern to pattern
   and typespec as single arrows and says no more, so the application prints
   only whether each relation gives an object. For the struct pattern it
   accepts the member pattern from vpi_handle or from an iteration. */
static void describe(const char *cond, vpiHandle p)
{
    vpiHandle it, m, ts, nested;

    switch (vpi_get(vpiType, p)) {
    case vpiStructPattern:
        m = vpi_handle(vpiPattern, p);
        it = m == NULL ? vpi_iterate(vpiPattern, p) : NULL;
        if (it != NULL) {
            m = vpi_scan(it);
            if (m != NULL)
                vpi_free_object(it);
        }
        add_line("case on %s: struct pattern, member pattern %d", cond, m != NULL);
        break;
    case vpiTaggedPattern:
        ts = vpi_handle(vpiTypespec, p);
        nested = vpi_handle(vpiPattern, p);
        add_line("case on %s: tagged pattern %s, member any pattern %s, typespec %d",
                 cond, name_or(p, "(no name)"),
                 nested != NULL ? name_or(nested, "(no name)") : "none",
                 ts != NULL);
        break;
    default:
        add_line("case on %s: another pattern", cond);
        break;
    }
}

static PLI_INT32 start_of_simulation(p_cb_data data)
{
    vpiHandle task, body, it, s, items, item, eit, p;
    char cond[64];
    int patterns = 0, i;

    (void)data;
    task = vpi_handle_by_name((PLI_BYTE8 *)TOP ".stmts", NULL);
    body = task != NULL ? vpi_handle(vpiStmt, task) : NULL;
    it = body != NULL ? vpi_iterate(vpiStmt, body) : NULL;
    while (it != NULL && (s = vpi_scan(it)) != NULL) {
        if (vpi_get(vpiType, s) != vpiCase)
            continue;
        snprintf(cond, sizeof cond, "%s", name_or(vpi_handle(vpiCondition, s), "?"));
        items = vpi_iterate(vpiCaseItem, s);
        while (items != NULL && (item = vpi_scan(items)) != NULL) {
            eit = vpi_iterate(vpiExpr, item);
            while (eit != NULL && (p = vpi_scan(eit)) != NULL) {
                describe(cond, p);
                patterns++;
            }
        }
    }
    qsort(lines, (size_t)line_count, sizeof lines[0], compare);
    for (i = 0; i < line_count; i++)
        vpi_printf((PLI_BYTE8 *)"%s\n", lines[i]);
    vpi_printf((PLI_BYTE8 *)"patterns: %d\n", patterns);
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
