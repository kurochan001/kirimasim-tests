/* VPI application of test_vpi_let_decl_body (IEEE 1800-2023 37.57). */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "vpi_user.h"
#include "sv_vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

#define TOP "test_vpi_let_decl_body"
#define MAX_LINES 4

static char lines[MAX_LINES][128];
static int line_count;

static int compare(const void *x, const void *y)
{
    return strcmp((const char *)x, (const char *)y);
}

static const char *str_or(PLI_INT32 prop, vpiHandle h, const char *fallback)
{
    const char *s = h != NULL ? vpi_get_str(prop, h) : NULL;
    return s != NULL ? s : fallback;
}

/* "x * k" for a binary operation, the name otherwise. */
static void expr_text(vpiHandle h, char *buf, size_t size)
{
    char left[32];
    vpiHandle it, l, r;
    PLI_INT32 op;

    if (vpi_get(vpiType, h) != vpiOperation) {
        snprintf(buf, size, "%s", str_or(vpiName, h, "unnamed expression"));
        return;
    }
    op = vpi_get(vpiOpType, h);
    it = vpi_iterate(vpiOperand, h);
    l = it != NULL ? vpi_scan(it) : NULL;
    r = l != NULL ? vpi_scan(it) : NULL;
    if (r != NULL && vpi_scan(it) != NULL)
        vpi_release_handle(it);
    snprintf(left, sizeof left, "%s", str_or(vpiName, l, "?"));
    snprintf(buf, size, "%s %s %s", left,
             op == vpiMultOp ? "*" : op == vpiLogAndOp ? "&&" : "?",
             str_or(vpiName, r, "?"));
}

static PLI_INT32 start_of_simulation(p_cb_data data)
{
    vpiHandle top, it, ca, rhs, decl, eit, e;
    char target[16], name[16], text[48], list[96];
    int n, i;

    (void)data;
    top = vpi_handle_by_name((PLI_BYTE8 *)TOP, NULL);
    it = top != NULL ? vpi_iterate(vpiContAssign, top) : NULL;
    while (it != NULL && (ca = vpi_scan(it)) != NULL) {
        if (line_count == MAX_LINES)
            continue;
        snprintf(target, sizeof target, "%s", str_or(vpiName, vpi_handle(vpiLhs, ca), "?"));
        rhs = vpi_handle(vpiRhs, ca);
        decl = rhs != NULL && vpi_get(vpiType, rhs) == vpiLetExpr
               ? vpi_handle(vpiLetDecl, rhs) : NULL;
        if (decl == NULL) {
            snprintf(lines[line_count++], sizeof lines[0], "%s: no let declaration", target);
            continue;
        }
        snprintf(name, sizeof name, "%s", str_or(vpiName, decl, "(no name)"));
        list[0] = '\0';
        n = 0;
        eit = vpi_iterate(vpiExpr, decl);
        while (eit != NULL && (e = vpi_scan(eit)) != NULL) {
            size_t len = strlen(list);
            expr_text(e, text, sizeof text);
            snprintf(list + len, sizeof list - len, "%s%s", n++ ? "; " : "", text);
        }
        snprintf(lines[line_count++], sizeof lines[0], "%s: let declaration %s, expressions: %s",
                 target, name, n ? list : "none");
    }
    qsort(lines, (size_t)line_count, sizeof lines[0], compare);
    for (i = 0; i < line_count; i++)
        vpi_printf((PLI_BYTE8 *)"%s\n", lines[i]);
    vpi_printf((PLI_BYTE8 *)"continuous assignments: %d\n", line_count);
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
