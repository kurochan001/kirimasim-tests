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
#define MAX_MEMBERS 8
#define MEMBER_SIZE 32

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

static void append(char *buf, size_t size, const char *text)
{
    size_t len = strlen(buf);

    if (len + 1 < size)
        snprintf(buf + len, size - len, "%s", text);
}

static const char *name_or(vpiHandle h, const char *fallback)
{
    const char *s = h != NULL ? vpi_get_str(vpiName, h) : NULL;

    return s != NULL ? s : fallback;
}

static int int_value(vpiHandle h)
{
    s_vpi_value v;

    v.format = vpiIntVal;
    vpi_get_value(h, &v);
    return (int)v.value.integer;
}

/* One member pattern: its constant, .name for an any pattern, or the members
   of a nested struct pattern in braces. */
static void pattern_text(vpiHandle p, char *buf, size_t size, int depth)
{
    char part[MEMBER_SIZE];

    if (p == NULL) {
        snprintf(buf, size, "no pattern");
        return;
    }
    switch (vpi_get(vpiType, p)) {
    case vpiConstant:
        snprintf(buf, size, "%d", int_value(p));
        break;
    case vpiAnyPattern:
        snprintf(buf, size, ".%s", name_or(p, "(no name)"));
        break;
    case vpiTaggedPattern:
        snprintf(buf, size, "tagged %s", name_or(p, "(no name)"));
        break;
    case vpiStructPattern: {
        vpiHandle it = depth < 4 ? vpi_iterate(vpiPattern, p) : NULL, m;
        int first = 1;

        snprintf(buf, size, "{");
        while (it != NULL && (m = vpi_scan(it)) != NULL) {
            pattern_text(m, part, sizeof part, depth + 1);
            if (!first)
                append(buf, size, ", ");
            append(buf, size, part);
            first = 0;
        }
        append(buf, size, "}");
        break;
    }
    default:
        snprintf(buf, size, "other pattern");
        break;
    }
}

static const char *typespec_name(PLI_INT32 t)
{
    return t == vpiIntTypespec ? "vpiIntTypespec"
           : t == vpiByteTypespec ? "vpiByteTypespec"
           : t == vpiShortIntTypespec ? "vpiShortIntTypespec"
           : t == vpiLongIntTypespec ? "vpiLongIntTypespec"
           : t == vpiIntegerTypespec ? "vpiIntegerTypespec"
           : t == vpiUnionTypespec ? "vpiUnionTypespec"
           : "another typespec";
}

/* One pattern of a case item, with the relation that the diagram gives it. */
static void describe(const char *cond, vpiHandle p)
{
    char members[MAX_MEMBERS][MEMBER_SIZE], list[LINE_SIZE];
    vpiHandle it, m, ts, nested;
    int n = 0, i;

    switch (vpi_get(vpiType, p)) {
    case vpiStructPattern:
        it = vpi_iterate(vpiPattern, p);
        while (it != NULL && (m = vpi_scan(it)) != NULL)
            if (n < MAX_MEMBERS)
                pattern_text(m, members[n++], sizeof members[0], 0);
        qsort(members, (size_t)n, sizeof members[0], compare);
        list[0] = '\0';
        for (i = 0; i < n; i++) {
            if (i)
                append(list, sizeof list, ", ");
            append(list, sizeof list, members[i]);
        }
        add_line("case on %s: struct pattern with %d member patterns: %s",
                 cond, n, list);
        break;
    case vpiTaggedPattern:
        ts = vpi_handle(vpiTypespec, p);
        nested = vpi_handle(vpiPattern, p);
        add_line("case on %s: tagged pattern %s, member any pattern %s, typespec %s",
                 cond, name_or(p, "(no name)"),
                 nested != NULL ? name_or(nested, "(no name)") : "none",
                 ts != NULL ? typespec_name(vpi_get(vpiType, ts)) : "none");
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
