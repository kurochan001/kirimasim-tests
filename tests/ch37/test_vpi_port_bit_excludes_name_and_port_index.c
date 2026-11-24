#include <stddef.h>
#include <string.h>
#include "vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

static PLI_INT32 observe(p_cb_data data)
{
    vpiHandle child = vpi_handle_by_name((PLI_BYTE8 *)"test_vpi_port_bit_excludes_name_and_port_index.child", NULL);
    vpiHandle ports = child != NULL ? vpi_iterate(vpiPort, child) : NULL;
    vpiHandle vector_port = NULL, port, bits, bit;
    int names = 0, indices = 0, bit_count = 0, parents = 0;
    (void)data;

    while (ports != NULL && (port = vpi_scan(ports)) != NULL) {
        const char *name = vpi_get_str(vpiName, port);
        if (name != NULL && strcmp(name, "vector_input") == 0)
            vector_port = port;
    }
    if (vector_port == NULL) {
        vpi_printf("vector port not found\n");
        return 0;
    }

    vpi_printf("port index=%d\n", (int)vpi_get(vpiPortIndex, vector_port));
    bits = vpi_iterate(vpiBit, vector_port);
    while (bits != NULL && (bit = vpi_scan(bits)) != NULL) {
        vpiHandle parent = vpi_handle(vpiParent, bit);
        bit_count += vpi_get(vpiType, bit) == vpiPortBit;
        parents += parent != NULL && vpi_compare_objects(parent, vector_port) != 0;
        names += vpi_get_str(vpiName, bit) != NULL;
        indices += vpi_get(vpiPortIndex, bit) != vpiUndefined;
    }
    vpi_printf("port bits=%d parents=%d named=%d indexed=%d\n",
               bit_count, parents, names, indices);
    return 0;
}

static void register_observation(void)
{
    s_cb_data callback = {0};
    callback.reason = cbStartOfSimulation;
    callback.cb_rtn = observe;
    vpi_register_cb(&callback);
}

void (*vlog_startup_routines[])(void) = {register_observation, NULL};

#ifdef __cplusplus
}
#endif
