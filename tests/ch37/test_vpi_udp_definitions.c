/* VPI application of test_vpi_udp_definitions (IEEE 1800-2023 37.36). */
#include <stdio.h>
#include <string.h>
#include "vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

#define TOP "test_vpi_udp_definitions"

static void describe(const char *inst)
{
    char full[64], name[32], sizes[64] = "";
    vpiHandle udp, defn, it, h;
    int n_io = 0, n_entries = 0;

    snprintf(full, sizeof full, "%s.%s", TOP, inst);
    udp = vpi_handle_by_name(full, NULL);
    defn = udp ? vpi_handle(vpiUdpDefn, udp) : NULL;
    if (defn == NULL) {
        vpi_printf((PLI_BYTE8 *)"%s: no UDP definition\n", inst);
        return;
    }
    snprintf(name, sizeof name, "%s", vpi_get_str(vpiDefName, defn));
    it = vpi_iterate(vpiIODecl, defn);
    if (it != NULL)
        while (vpi_scan(it) != NULL)
            n_io++;
    it = vpi_iterate(vpiTableEntry, defn);
    if (it != NULL)
        while ((h = vpi_scan(it)) != NULL) {
            n_entries++;
            snprintf(sizes + strlen(sizes), sizeof sizes - strlen(sizes), " %d",
                     (int)vpi_get(vpiSize, h));
        }
    vpi_printf((PLI_BYTE8 *)"%s: %s, %s, %d inputs, %d io declarations, initial %d\n", inst, name,
               vpi_get(vpiPrimType, defn) == vpiCombPrim ? "combinational" :
               vpi_get(vpiPrimType, defn) == vpiSeqPrim ? "sequential" : "other",
               (int)vpi_get(vpiSize, defn), n_io, vpi_handle(vpiInitial, defn) != NULL);
    vpi_printf((PLI_BYTE8 *)"%s: %d table entries, symbols per entry:%s\n", inst, n_entries, sizes);
}

static PLI_INT32 udps_calltf(PLI_BYTE8 *user_data)
{
    (void)user_data;
    describe("m");
    describe("l");
    return 0;
}

static void register_all(void)
{
    s_vpi_systf_data d;
    memset(&d, 0, sizeof d);
    d.type = vpiSysTask;
    d.tfname = (PLI_BYTE8 *)"$vt_udps";
    d.calltf = udps_calltf;
    vpi_register_systf(&d);
}

void (*vlog_startup_routines[])(void) = {register_all, 0};

#ifdef __cplusplus
}
#endif
