/* VPI application of test_vpi_assertion_objects (IEEE 1800-2023 37.49, 37.50). */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "vpi_user.h"
#include "sv_vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

#define TOP "test_vpi_assertion_objects"
#define COUNT 6

static const char *const names[COUNT] = {
    "a_expl", "a_inf", "c_prop", "c_seq", "m_inst", "r_prop",
};

static const char *name_of(vpiHandle h)
{
    return h != NULL && vpi_get_str(vpiName, h) != NULL ? vpi_get_str(vpiName, h) : "none";
}

static const char *kind(vpiHandle h)
{
    switch (vpi_get(vpiType, h)) {
    case vpiAssert: return "assert";
    case vpiAssume: return "assume";
    case vpiCover: return "cover";
    case vpiRestrict: return "restrict";
    default: return "other";
    }
}

/* Finds the six assertions in an iteration; returns how many were found. */
static int collect(vpiHandle ref, vpiHandle *found)
{
    vpiHandle it = vpi_iterate(vpiAssertion, ref), h;
    int i, n = 0;

    for (i = 0; i < COUNT; i++)
        found[i] = NULL;
    while (it != NULL && (h = vpi_scan(it)) != NULL)
        for (i = 0; i < COUNT; i++)
            if (found[i] == NULL && strcmp(name_of(h), names[i]) == 0) {
                found[i] = h;
                n++;
            }
    return n;
}

/* "posedge clk" for an edge operation, or the name of the expression. */
static void event_text(vpiHandle ev, char *buf, size_t size)
{
    vpiHandle it, operand = NULL;
    PLI_INT32 op;

    if (ev == NULL) {
        snprintf(buf, size, "none");
        return;
    }
    if (vpi_get(vpiType, ev) != vpiOperation) {
        snprintf(buf, size, "%s", name_of(ev));
        return;
    }
    op = vpi_get(vpiOpType, ev);
    it = vpi_iterate(vpiOperand, ev);
    if (it != NULL && (operand = vpi_scan(it)) != NULL)
        vpi_release_handle(it);
    snprintf(buf, size, "%s %s", op == vpiPosedgeOp ? "posedge" : op == vpiNegedgeOp ? "negedge"
             : "other", name_of(operand));
}

static const char *base_name(const char *path)
{
    const char *slash = path ? strrchr(path, '/') : NULL;
    return slash ? slash + 1 : path ? path : "none";
}

static void details(vpiHandle h, vpiHandle top)
{
    char name[64];
    char ev[48];
    vpiHandle inst, spec, by_name_h;
    int own_clock;

    snprintf(name, sizeof name, "%s", name_of(h));
    own_clock = strcmp(name, "a_expl") == 0 || strcmp(name, "c_prop") == 0
                || strcmp(name, "r_prop") == 0;

    event_text(vpi_handle(vpiClockingEvent, h), ev, sizeof ev);
    vpi_printf((PLI_BYTE8 *)"%s: %s", name, kind(h));
    if (own_clock)
        vpi_printf((PLI_BYTE8 *)", clock inferred %d", (int)vpi_get(vpiIsClockInferred, h));
    vpi_printf((PLI_BYTE8 *)", clocking event %s", ev);
    if (vpi_get(vpiType, h) == vpiCover)
        vpi_printf((PLI_BYTE8 *)", cover sequence %d", (int)vpi_get(vpiIsCoverSequence, h));
    if (strcmp(name, "a_expl") == 0)
        vpi_printf((PLI_BYTE8 *)", pass statement %d, fail statement %d",
                   vpi_handle(vpiStmt, h) != NULL, vpi_handle(vpiElseStmt, h) != NULL);
    if (strcmp(name, "r_prop") == 0)
        vpi_printf((PLI_BYTE8 *)", pass statement %d", vpi_handle(vpiStmt, h) != NULL);
    if (strcmp(name, "a_inf") == 0) {
        spec = vpi_handle(vpiProperty, h);
        vpi_printf((PLI_BYTE8 *)", property spec %d, disable condition %s",
                   spec != NULL && vpi_get(vpiType, spec) == vpiPropertySpec,
                   spec ? name_of(vpi_handle(vpiDisableCondition, spec)) : "none");
    }
    vpi_printf((PLI_BYTE8 *)"\n");
    if (strcmp(name, "a_expl") == 0) {
        char full[128], file[128];
        by_name_h = vpi_handle_by_name((PLI_BYTE8 *)TOP ".a_expl", NULL);
        inst = vpi_handle(vpiInstance, h);
        snprintf(full, sizeof full, "%s", vpi_get_str(vpiFullName, h));
        snprintf(file, sizeof file, "%s", vpi_get_str(vpiFile, h));
        vpi_printf((PLI_BYTE8 *)"a_expl: by name the same %d, full name %s, instance is the "
                   "module %d, file %s, lines %d to %d\n",
                   by_name_h != NULL && vpi_compare_objects(by_name_h, h) == 1,
                   full,
                   inst != NULL && top != NULL && vpi_compare_objects(inst, top) == 1,
                   base_name(file), (int)vpi_get(vpiStartLine, h),
                   (int)vpi_get(vpiEndLine, h));
    }
}

static void procedural(void)
{
    vpiHandle blk = vpi_handle_by_name((PLI_BYTE8 *)TOP ".blk", NULL);
    vpiHandle it = blk ? vpi_iterate(vpiConcurrentAssertion, blk) : NULL, h, found = NULL;
    char ev[48];

    while (it != NULL && (h = vpi_scan(it)) != NULL)
        if (strcmp(name_of(h), "a_proc") == 0)
            found = h;
    if (found == NULL) {
        vpi_printf((PLI_BYTE8 *)"a_proc not found in blk\n");
        return;
    }
    event_text(vpi_handle(vpiClockingEvent, found), ev, sizeof ev);
    vpi_printf((PLI_BYTE8 *)"a_proc in blk: %s, clock inferred %d, clocking event %s\n",
               kind(found), (int)vpi_get(vpiIsClockInferred, found), ev);
}

static PLI_INT32 assertions_calltf(PLI_BYTE8 *user_data)
{
    vpiHandle top = vpi_handle_by_name((PLI_BYTE8 *)TOP, NULL);
    vpiHandle in_module[COUNT], in_design[COUNT];
    int n, i;

    (void)user_data;
    n = top ? collect(top, in_module) : 0;
    vpi_printf((PLI_BYTE8 *)"assertions of the module found by iterating it: %d of %d\n", n,
               COUNT);
    vpi_printf((PLI_BYTE8 *)"assertions of the module found by iterating NULL: %d of %d\n",
               collect(NULL, in_design), COUNT);
    for (i = 0; i < COUNT; i++)
        if (in_module[i] != NULL)
            details(in_module[i], top);
    procedural();
    return 0;
}

static void register_all(void)
{
    s_vpi_systf_data d;
    memset(&d, 0, sizeof d);
    d.type = vpiSysTask;
    d.tfname = (PLI_BYTE8 *)"$vt_assertions";
    d.calltf = assertions_calltf;
    vpi_register_systf(&d);
}

void (*vlog_startup_routines[])(void) = {register_all, 0};

#ifdef __cplusplus
}
#endif
