#include <stdio.h>
#include <string.h>
#include "vpi_user.h"
#include "sv_vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

static PLI_INT32 probe(PLI_BYTE8 *which)
{
    char full[160], name[64];
    vpiHandle h, it, attribute, call;
    s_vpi_value value;
    int total, count = 0;
    snprintf(full, sizeof full, "test_system_function_names_cell_reset_and_attributes.%s", which);
    h = vpi_handle_by_name(full, NULL);
    total = h ? 100 * vpi_get(vpiCellInstance, h) : -1000;
    it = h ? vpi_iterate(vpiAttribute, h) : NULL;
    while (it && (attribute = vpi_scan(it)) != NULL) {
        const char *s = vpi_get_str(vpiName, attribute);
        snprintf(name, sizeof name, "%s", s ? s : "");
        if (strcmp(name, "weight") != 0) continue;
        if (vpi_get(vpiType, attribute) != vpiAttribute
            || vpi_get(vpiDefAttribute, attribute)) total = -1000;
        value.format = vpiIntVal; vpi_get_value(attribute, &value);
        total += value.value.integer; count++;
    }
    if (count != 1) total = -1000;
    call = vpi_handle(vpiSysTfCall, NULL);
    value.format = vpiIntVal; value.value.integer = total;
    vpi_put_value(call, &value, NULL, vpiNoDelay);
    return 0;
}

static void register_all(void)
{
    s_vpi_systf_data tf;
    memset(&tf, 0, sizeof tf);
    tf.type = vpiSysFunc; tf.sysfunctype = vpiIntFunc; tf.calltf = probe;
    tf.tfname = (PLI_BYTE8 *)"$Depth$probe_7"; tf.user_data = (PLI_BYTE8 *)"u";
    vpi_register_systf(&tf);
    tf.tfname = (PLI_BYTE8 *)"$depth$probe_7"; tf.user_data = (PLI_BYTE8 *)"v";
    vpi_register_systf(&tf);

}
void (*vlog_startup_routines[])(void) = {register_all, 0};
#ifdef __cplusplus
}
#endif
