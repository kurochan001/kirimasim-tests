/* VPI application of test_vpi_clocking_decl_relations (IEEE 1800-2023 37.48). */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "vpi_user.h"
#include "sv_vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

#define TOP "test_vpi_clocking_decl_relations"
#define MAX 8
#define LEN 64

static int by_text(const void *x, const void *y)
{
    return strcmp((const char *)x, (const char *)y);
}

static const char *name_of(vpiHandle h)
{
    PLI_BYTE8 *s = h != NULL ? vpi_get_str(vpiName, h) : NULL;
    return s != NULL ? s : "(none)";
}

/* Each object of an iteration over cb, with whether vpiClockingBlock of it
 * is cb again. */
static void members(vpiHandle cb, PLI_INT32 type, const char *label)
{
    vpiHandle it = vpi_iterate(type, cb), h, back;
    char list[MAX][LEN];
    int n = 0, i;

    while (it != NULL && (h = vpi_scan(it)) != NULL) {
        back = vpi_handle(vpiClockingBlock, h);
        if (n < MAX)
            snprintf(list[n++], LEN, "%s (its block %d)", name_of(h),
                     back != NULL && vpi_compare_objects(back, cb));
    }
    qsort(list, (size_t)n, LEN, by_text);
    vpi_printf((PLI_BYTE8 *)"  %s:", label);
    for (i = 0; i < n; i++)
        vpi_printf((PLI_BYTE8 *)"%s %s", i ? "," : "", list[i]);
    if (n == 0)
        vpi_printf((PLI_BYTE8 *)" none");
    vpi_printf((PLI_BYTE8 *)"\n");
}

static void block(const char *path)
{
    char full[96];
    vpiHandle cb;

    snprintf(full, sizeof full, "%s.%s", TOP, path);
    cb = vpi_handle_by_name((PLI_BYTE8 *)full, NULL);
    if (cb == NULL || vpi_get(vpiType, cb) != vpiClockingBlock) {
        vpi_printf((PLI_BYTE8 *)"%s: not a clocking block\n", path);
        return;
    }
    vpi_printf((PLI_BYTE8 *)"%s: full name %s\n", path,
               vpi_get_str(vpiFullName, cb) != NULL ? vpi_get_str(vpiFullName, cb) : "(none)");
    members(cb, vpiClockingIODecl, "clocking io decls");
    members(cb, vpiPropertyDecl, "property decls");
    members(cb, vpiSequenceDecl, "sequence decls");
}

static PLI_INT32 clocking_calltf(PLI_BYTE8 *user_data)
{
    (void)user_data;
    block("cb1");
    block("cb2");
    block("g.cb3");
    return 0;
}

static void register_all(void)
{
    s_vpi_systf_data d;
    memset(&d, 0, sizeof d);
    d.type = vpiSysTask;
    d.tfname = (PLI_BYTE8 *)"$vt_clocking";
    d.calltf = clocking_calltf;
    vpi_register_systf(&d);
}

void (*vlog_startup_routines[])(void) = {register_all, 0};

#ifdef __cplusplus
}
#endif
