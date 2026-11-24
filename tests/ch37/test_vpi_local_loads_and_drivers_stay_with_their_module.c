#include <stddef.h>
#include "sv_vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

#define TOP "test_vpi_local_loads_and_drivers_stay_with_their_module"

static void summarize(const char *label, const char *kind, vpiHandle net,
                      PLI_INT32 relation)
{
    unsigned assignments = 0, ports = 0, terminals = 0, other = 0;
    if (net == NULL || vpi_get(vpiType, net) != vpiNet) {
        vpi_printf("%s %s: missing net\n", label, kind);
        return;
    }

    vpiHandle iterator = vpi_iterate(relation, net), item;
    while (iterator != NULL && (item = vpi_scan(iterator)) != NULL) {
        switch (vpi_get(vpiType, item)) {
        case vpiContAssign:
            assignments++;
            break;
        case vpiPort:
            ports++;
            break;
        case vpiPrimTerm:
            terminals++;
            break;
        default:
            other++;
            break;
        }
    }

    vpi_printf("%s %s assignments=%u ports=%u terminals=%u other=%u\n",
               label, kind, assignments, ports, terminals, other);
}

static void probe(const char *label, const char *name)
{
    vpiHandle net = vpi_handle_by_name((PLI_BYTE8 *)name, NULL);
    summarize(label, "drivers", net, vpiLocalDriver);
    summarize(label, "loads", net, vpiLocalLoad);
}

static PLI_INT32 examine(PLI_BYTE8 *unused)
{
    (void)unused;
    probe("parent", TOP ".joined");
    probe("child-input", TOP ".child.sample");
    probe("child-inout", TOP ".child.shared");
    probe("expression-input", TOP ".with_expr.sample");
    return 0;
}

static void setup(void)
{
    s_vpi_systf_data definition = {0};
    definition.type = vpiSysTask;
    definition.tfname = "$vt_local_net_relations";
    definition.calltf = examine;
    vpi_register_systf(&definition);
}

void (*vlog_startup_routines[])(void) = {setup, NULL};

#ifdef __cplusplus
}
#endif
