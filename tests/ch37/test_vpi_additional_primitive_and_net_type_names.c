#include <stddef.h>
#include <string.h>
#include "vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

static void report(vpiHandle object, PLI_INT32 property,
                   PLI_INT32 expected, const char *name)
{
    PLI_INT32 value = object != NULL ? vpi_get(property, object) : 0;
    const char *text = object != NULL ? vpi_get_str(property, object) : NULL;
    vpi_printf("%s number=%d name=%d\n", name, value == expected,
               text != NULL && strcmp(text, name) == 0);
}

static PLI_INT32 observe(p_cb_data data)
{
    vpiHandle top = vpi_handle_by_name((PLI_BYTE8 *)"test_vpi_additional_primitive_and_net_type_names", NULL);
    (void)data;
    if (top == NULL)
        return 0;
    report(vpi_handle_by_name((PLI_BYTE8 *)"active_buf", top),
           vpiPrimType, vpiBufPrim, "vpiBufPrim");
    report(vpi_handle_by_name((PLI_BYTE8 *)"inverter", top),
           vpiPrimType, vpiNotPrim, "vpiNotPrim");
    report(vpi_handle_by_name((PLI_BYTE8 *)"wire_result", top), vpiNetType, vpiWire, "vpiWire");
    report(vpi_handle_by_name((PLI_BYTE8 *)"wand_result", top), vpiNetType, vpiWand, "vpiWand");
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
