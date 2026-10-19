/* VPI application of test_vpi_clocking_blocks (IEEE 1800-2023 37.48). */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "vpi_user.h"
#include "sv_vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

#define MAX_ITEMS 8

static char items[MAX_ITEMS][80];
static int n_items;

static int compare(const void *x, const void *y)
{
    return strcmp((const char *)x, (const char *)y);
}

static const char *name_or_none(vpiHandle h)
{
    return h != NULL && vpi_get_str(vpiName, h) != NULL ? vpi_get_str(vpiName, h) : "(none)";
}

/* The delay of a delay control, or -1 for NULL. */
static double skew(vpiHandle control)
{
    s_vpi_time t[1];
    s_vpi_delay d;

    if (control == NULL)
        return -1;
    memset(&d, 0, sizeof d);
    memset(t, 0, sizeof t);
    d.da = t;
    d.no_of_delays = 1;
    d.time_type = vpiScaledRealTime;
    vpi_get_delays(control, &d);
    return t[0].real;
}

static const char *direction(PLI_INT32 dir)
{
    switch (dir) {
    case vpiInput: return "input";
    case vpiOutput: return "output";
    case vpiInout: return "inout";
    default: return "other";
    }
}

static void describe_block(vpiHandle cb)
{
    vpiHandle ev = vpi_handle(vpiClockingEvent, cb), cond, it, io, opnd_it, opnd;
    char block[32], clock[32];
    double c_skew = -1;
    int i;

    snprintf(block, sizeof block, "%s", name_or_none(cb));
    cond = ev ? vpi_handle(vpiCondition, ev) : NULL;
    opnd_it = cond ? vpi_iterate(vpiOperand, cond) : NULL;
    opnd = opnd_it ? vpi_scan(opnd_it) : NULL;
    snprintf(clock, sizeof clock, "%s%s",
             cond && vpi_get(vpiOpType, cond) == vpiPosedgeOp ? "posedge " : "",
             name_or_none(opnd ? opnd : cond));
    if (opnd_it != NULL && opnd != NULL)
        vpi_release_handle(opnd_it);
    vpi_printf((PLI_BYTE8 *)"%s: clocking event %s, default input skew %g, "
               "default output skew %g\n", block, clock, skew(vpi_handle(vpiInputSkew, cb)),
               skew(vpi_handle(vpiOutputSkew, cb)));
    it = vpi_iterate(vpiClockingIODecl, cb);
    if (it != NULL)
        while ((io = vpi_scan(it)) != NULL && n_items < MAX_ITEMS) {
            char name[32];
            snprintf(name, sizeof name, "%s", name_or_none(io));
            snprintf(items[n_items++], sizeof items[0], "%s: %s, refers to %s", name,
                     direction(vpi_get(vpiDirection, io)), name_or_none(vpi_handle(vpiExpr, io)));
            /* Only c has a skew of its own. */
            if (strcmp(name, "c") == 0)
                c_skew = skew(vpi_handle(vpiInputSkew, io));
        }
    qsort(items, (size_t)n_items, sizeof items[0], compare);
    for (i = 0; i < n_items; i++)
        vpi_printf((PLI_BYTE8 *)"  %s\n", items[i]);
    n_items = 0;
    vpi_printf((PLI_BYTE8 *)"input skew of c: %g\n", c_skew);
}

static PLI_INT32 clocking_calltf(PLI_BYTE8 *user_data)
{
    vpiHandle mod = vpi_handle_by_name((PLI_BYTE8 *)"test_vpi_clocking_blocks", NULL);
    vpiHandle it = mod ? vpi_iterate(vpiClockingBlock, mod) : NULL, cb;
    int n = 0;

    (void)user_data;
    if (it != NULL)
        while ((cb = vpi_scan(it)) != NULL) {
            describe_block(cb);
            n++;
        }
    vpi_printf((PLI_BYTE8 *)"clocking blocks: %d\n", n);
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
