/* VPI application of test_vpi_udp_entry_vector_storage (IEEE 1800-2023
 * 38.15). */
#include <stdio.h>
#include <string.h>
#include "vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

#define TOP "test_vpi_udp_entry_vector_storage"

/* Prints the symbols of the only table entry of the definition of an
 * instance; count is the number of symbols that the entry has in the
 * source. */
static void entry(const char *instance, int count)
{
    char name[96];
    vpiHandle udp, defn, it, h;
    s_vpi_value v;
    int k;

    snprintf(name, sizeof name, "%s.%s", TOP, instance);
    udp = vpi_handle_by_name((PLI_BYTE8 *)name, NULL);
    defn = udp != NULL ? vpi_handle(vpiUdpDefn, udp) : NULL;
    it = defn != NULL ? vpi_iterate(vpiTableEntry, defn) : NULL;
    h = it != NULL ? vpi_scan(it) : NULL;
    if (h == NULL) {
        vpi_printf((PLI_BYTE8 *)"%s: no table entry\n", instance);
        return;
    }
    memset(&v, 0, sizeof v);
    v.format = vpiVectorVal;
    vpi_get_value(h, &v);
    if (v.value.vector == NULL) {
        vpi_printf((PLI_BYTE8 *)"%s: no vector\n", instance);
        return;
    }
    vpi_printf((PLI_BYTE8 *)"%s, %d symbols:", instance, count);
    for (k = 0; k < count; k++) {
        p_vpi_vecval w = &v.value.vector[k / 4];
        PLI_UINT32 word = (PLI_UINT32)(k % 4 < 2 ? w->aval : w->bval);
        unsigned half = (unsigned)(k % 2 == 0 ? (word >> 16) & 0xffffu : word & 0xffffu);
        vpi_printf((PLI_BYTE8 *)" [%d]%04x", k / 4, half);
    }
    vpi_printf((PLI_BYTE8 *)"\n");
}

static PLI_INT32 entries_calltf(PLI_BYTE8 *user_data)
{
    (void)user_data;
    entry("u1", 5);
    entry("u2", 9);
    return 0;
}

static void register_all(void)
{
    s_vpi_systf_data d;

    memset(&d, 0, sizeof d);
    d.type = vpiSysTask;
    d.tfname = (PLI_BYTE8 *)"$vt_entries";
    d.calltf = entries_calltf;
    vpi_register_systf(&d);
}

void (*vlog_startup_routines[])(void) = {register_all, 0};

#ifdef __cplusplus
}
#endif
