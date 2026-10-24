/* VPI application of test_vpi_interface_tf_decl_relations (IEEE 1800-2023 37.6, 37.8). */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "vpi_user.h"
#include "sv_vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

#define TOP "test_vpi_interface_tf_decl_relations"
#define MAX_ITEMS 8

static int compare(const void *x, const void *y)
{
    return strcmp((const char *)x, (const char *)y);
}

static vpiHandle find(const char *name)
{
    char full[128];
    snprintf(full, sizeof full, "%s.%s", TOP, name);
    return vpi_handle_by_name((PLI_BYTE8 *)full, NULL);
}

static const char *str_or(const char *s, const char *other)
{
    return s != NULL ? s : other;
}

static const char *access_name(PLI_INT32 a)
{
    switch (a) {
    case vpiForkJoinAcc: return "vpiForkJoinAcc";
    case vpiExternAcc: return "vpiExternAcc";
    default: return "other";
    }
}

/* Appends to `buf` the number of subroutines of `type` that `decl`
   iterates and their names, sorted; for two of them, also whether they are
   different objects. */
static void subroutines(vpiHandle decl, PLI_INT32 type, char *buf, size_t size)
{
    char found[MAX_ITEMS][32];
    vpiHandle it = vpi_iterate(type, decl), h, first = NULL, second = NULL;
    int n = 0, i;

    while (it != NULL && (h = vpi_scan(it)) != NULL) {
        if (n == MAX_ITEMS)
            continue;
        if (n == 0)
            first = h;
        else if (n == 1)
            second = h;
        snprintf(found[n++], sizeof found[0], "%s", str_or(vpi_get_str(vpiName, h), "?"));
    }
    qsort(found, (size_t)n, sizeof found[0], compare);
    snprintf(buf + strlen(buf), size - strlen(buf), "%d", n);
    for (i = 0; i < n; i++)
        snprintf(buf + strlen(buf), size - strlen(buf), "%s%s", i ? ", " : " (", found[i]);
    if (n > 0)
        snprintf(buf + strlen(buf), size - strlen(buf), ")");
    if (n == 2)
        snprintf(buf + strlen(buf), size - strlen(buf), ", different objects %d",
                 !vpi_compare_objects(first, second));
}

static void show(const char *label)
{
    char lines[MAX_ITEMS][192];
    vpiHandle intf = find(label), it, decl, back;
    int n = 0, i;

    it = intf != NULL ? vpi_iterate(vpiInterfaceTfDecl, intf) : NULL;
    while (it != NULL && (decl = vpi_scan(it)) != NULL) {
        if (n == MAX_ITEMS)
            continue;
        snprintf(lines[n], sizeof lines[n], "%s: functions ",
                 access_name(vpi_get(vpiAccessType, decl)));
        subroutines(decl, vpiFunction, lines[n], sizeof lines[n]);
        snprintf(lines[n] + strlen(lines[n]), sizeof lines[n] - strlen(lines[n]), "; tasks ");
        subroutines(decl, vpiTask, lines[n], sizeof lines[n]);
        back = vpi_handle(vpiInstance, decl);
        snprintf(lines[n] + strlen(lines[n]), sizeof lines[n] - strlen(lines[n]),
                 "; vpiInstance is %s %d", label,
                 back != NULL && vpi_compare_objects(back, intf));
        n++;
    }
    qsort(lines, (size_t)n, sizeof lines[0], compare);
    vpi_printf((PLI_BYTE8 *)"interface tf decls of %s: %d\n", label, n);
    for (i = 0; i < n; i++)
        vpi_printf((PLI_BYTE8 *)"  %s\n", lines[i]);
}

static PLI_INT32 start_of_simulation(p_cb_data cb)
{
    (void)cb;
    show("bus");
    show("q");
    return 0;
}

static void register_all(void)
{
    s_cb_data cb;
    memset(&cb, 0, sizeof cb);
    cb.reason = cbStartOfSimulation;
    cb.cb_rtn = start_of_simulation;
    vpi_register_cb(&cb);
}

void (*vlog_startup_routines[])(void) = {register_all, 0};

#ifdef __cplusplus
}
#endif
