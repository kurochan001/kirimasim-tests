#include <stddef.h>
#include <string.h>
#include "vpi_user.h"
#include "sv_vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

static PLI_INT32 observe(p_cb_data data)
{
    vpiHandle top = vpi_handle_by_name((PLI_BYTE8 *)"test_vpi_nettype_declarations_belong_to_declaring_instance", NULL);
    /* The C header uses the declaration type for the nettype iterator. */
    vpiHandle iter = top != NULL ? vpi_iterate(vpiNettypeDecl, top) : NULL;
    vpiHandle type;
    int nibble = 0, octet = 0, hidden = 0, count = 0;
    (void)data;

    if (iter != NULL) {
        while ((type = vpi_scan(iter)) != NULL) {
            const char *name = vpi_get_str(vpiName, type);
            if (name != NULL) {
                nibble += strcmp(name, "nibble") == 0;
                octet += strcmp(name, "octet") == 0;
                hidden += strcmp(name, "hidden_type") == 0;
            }
            count++;
        }
    }
    vpi_printf("declared=%d nibble=%d octet=%d nested=%d\n", count, nibble, octet, hidden);
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
