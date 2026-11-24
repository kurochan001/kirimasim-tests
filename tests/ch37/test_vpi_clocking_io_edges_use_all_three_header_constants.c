#include <stddef.h>
#include <string.h>
#include "sv_vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

#define TOP "test_vpi_clocking_io_edges_use_all_three_header_constants"

struct edge_case {
    const char *name;
    PLI_INT32 property;
    PLI_INT32 edge;
};

static const struct edge_case cases[] = {
    {"in_delay", vpiInputEdge, vpiNoEdge},
    {"in_rise", vpiInputEdge, vpiPosedge},
    {"in_fall", vpiInputEdge, vpiNegedge},
    {"out_delay", vpiOutputEdge, vpiNoEdge},
    {"out_rise", vpiOutputEdge, vpiPosedge},
    {"out_fall", vpiOutputEdge, vpiNegedge},
};

static PLI_INT32 inspect(PLI_BYTE8 *unused)
{
    (void)unused;
    vpiHandle block = vpi_handle_by_name((PLI_BYTE8 *)TOP ".bus.sample", NULL);
    vpiHandle iterator = block != NULL ? vpi_iterate(vpiClockingIODecl, block) : NULL, item;
    unsigned matching[sizeof cases / sizeof *cases] = {0};

    while (iterator != NULL && (item = vpi_scan(iterator)) != NULL) {
        const char *name = vpi_get_str(vpiName, item);
        for (size_t i = 0; name != NULL && i < sizeof cases / sizeof *cases; ++i) {
            if (strcmp(name, cases[i].name) == 0) {
                matching[i] += vpi_get(cases[i].property, item) == cases[i].edge;
                break;
            }
        }
    }
    vpi_printf("input delay=%u rising=%u falling=%u\n", matching[0], matching[1], matching[2]);
    vpi_printf("output delay=%u rising=%u falling=%u\n", matching[3], matching[4], matching[5]);
    return 0;
}

static void setup(void)
{
    s_vpi_systf_data definition = {0};
    definition.type = vpiSysTask;
    definition.tfname = "$vt_edge_constant_matrix";
    definition.calltf = inspect;
    vpi_register_systf(&definition);
}

void (*vlog_startup_routines[])(void) = {setup, NULL};

#ifdef __cplusplus
}
#endif
