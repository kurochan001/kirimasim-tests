/* VPI application of test_vpi_clocking_edges_prefix (IEEE 1800-2023 37.48, 37.61). */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "vpi_user.h"
#include "sv_vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

#define TOP "test_vpi_clocking_edges_prefix"

static const char *name_of(vpiHandle h)
{
    return h != NULL && vpi_get_str(vpiName, h) != NULL ? vpi_get_str(vpiName, h) : "none";
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

static int int_value(vpiHandle h)
{
    s_vpi_value v;
    v.format = vpiIntVal;
    vpi_get_value(h, &v);
    return (int)v.value.integer;
}

static double delay_of(vpiHandle control)
{
    s_vpi_time t[1];
    s_vpi_delay d;
    memset(&d, 0, sizeof d);
    memset(t, 0, sizeof t);
    d.da = t;
    d.no_of_delays = 1;
    d.time_type = vpiScaledRealTime;
    vpi_get_delays(control, &d);
    return t[0].real;
}

static vpiHandle find(PLI_INT32 type, vpiHandle ref, const char *name)
{
    vpiHandle it = ref ? vpi_iterate(type, ref) : NULL, h, found = NULL;
    while (it != NULL && (h = vpi_scan(it)) != NULL)
        if (strcmp(name_of(h), name) == 0)
            found = h;
    if (found == NULL)
        vpi_printf((PLI_BYTE8 *)"%s not found\n", name);
    return found;
}

/* The clocking block that prefixes vif.cb.gnt in the task peek. */
static vpiHandle prefixed_block(void)
{
    vpiHandle peek = vpi_handle_by_name((PLI_BYTE8 *)TOP ".peek", NULL);
    vpiHandle stmt = peek ? vpi_handle(vpiStmt, peek) : NULL;
    vpiHandle rhs = stmt && vpi_get(vpiType, stmt) == vpiAssignment
                    ? vpi_handle(vpiRhs, stmt) : NULL;
    vpiHandle cb = rhs ? vpi_handle(vpiPrefix, rhs) : NULL;
    if (cb == NULL)
        vpi_printf((PLI_BYTE8 *)"the prefix of vif.cb.gnt was not found\n");
    return cb;
}

static void print_actual(vpiHandle cb)
{
    vpiHandle actual = cb ? vpi_handle(vpiActual, cb) : NULL;
    const char *full = actual ? vpi_get_str(vpiFullName, actual) : NULL;
    vpi_printf((PLI_BYTE8 *)"actual %s\n", actual == NULL ? "none" : full ? full : "(no name)");
}

static PLI_INT32 clocking_calltf(PLI_BYTE8 *user_data)
{
    vpiHandle top = vpi_handle_by_name((PLI_BYTE8 *)TOP, NULL);
    vpiHandle bus = vpi_handle_by_name((PLI_BYTE8 *)TOP ".bus", NULL);
    vpiHandle bus_cb = vpi_handle_by_name((PLI_BYTE8 *)TOP ".bus.cb", NULL);
    vpiHandle ck = find(vpiClockingBlock, top, "ck"), io, skew, inst, cb, vif;

    (void)user_data;
    if (ck != NULL) {
        inst = vpi_handle(vpiInstance, ck);
        vpi_printf((PLI_BYTE8 *)"ck: default input edge %s, default output edge %s, "
                   "instance is the module %d\n", edge_name(vpi_get(vpiInputEdge, ck)),
                   edge_name(vpi_get(vpiOutputEdge, ck)),
                   inst != NULL && top != NULL && vpi_compare_objects(inst, top) == 1);
        if ((io = find(vpiClockingIODecl, ck, "b")) != NULL)
            vpi_printf((PLI_BYTE8 *)"  b: output edge %s\n",
                       edge_name(vpi_get(vpiOutputEdge, io)));
        if ((io = find(vpiClockingIODecl, ck, "c")) != NULL) {
            skew = vpi_handle(vpiInputSkew, io);
            vpi_printf((PLI_BYTE8 *)"  c: input edge %s, input skew is a delay control %d",
                       edge_name(vpi_get(vpiInputEdge, io)),
                       skew != NULL && vpi_get(vpiType, skew) == vpiDelayControl);
            if (skew != NULL)
                vpi_printf((PLI_BYTE8 *)" of %g", delay_of(skew));
            vpi_printf((PLI_BYTE8 *)"\n");
        }
        if ((io = find(vpiClockingIODecl, ck, "e")) != NULL) {
            skew = vpi_handle(vpiOutputSkew, io);
            vpi_printf((PLI_BYTE8 *)"  e: output skew ");
            if (skew == NULL)
                vpi_printf((PLI_BYTE8 *)"none\n");
            else
                vpi_printf((PLI_BYTE8 *)"%d\n", int_value(skew));
        }
    }
    inst = bus_cb ? vpi_handle(vpiInstance, bus_cb) : NULL;
    vpi_printf((PLI_BYTE8 *)"bus.cb: instance is bus %d\n",
               inst != NULL && bus != NULL && vpi_compare_objects(inst, bus) == 1);
    if ((cb = prefixed_block()) != NULL) {
        vif = vpi_handle(vpiPrefix, cb);
        vpi_printf((PLI_BYTE8 *)"vif.cb.gnt: prefix is a clocking block %d, its prefix %s "
                   "(virtual interface var %d), ", vpi_get(vpiType, cb) == vpiClockingBlock,
                   name_of(vif),
                   vif != NULL && vpi_get(vpiType, vif) == vpiVirtualInterfaceVar);
        print_actual(cb);
    }
    return 0;
}

static PLI_INT32 actual_calltf(PLI_BYTE8 *user_data)
{
    vpiHandle cb = prefixed_block();

    (void)user_data;
    if (cb != NULL) {
        vpi_printf((PLI_BYTE8 *)"vif.cb.gnt after vif = bus: ");
        print_actual(cb);
    }
    return 0;
}

static void add(const char *name, PLI_INT32 (*calltf)(PLI_BYTE8 *))
{
    s_vpi_systf_data d;
    memset(&d, 0, sizeof d);
    d.type = vpiSysTask;
    d.tfname = (PLI_BYTE8 *)name;
    d.calltf = calltf;
    vpi_register_systf(&d);
}

static void register_all(void)
{
    add("$vt_clocking", clocking_calltf);
    add("$vt_actual", actual_calltf);
}

void (*vlog_startup_routines[])(void) = {register_all, 0};

#ifdef __cplusplus
}
#endif
