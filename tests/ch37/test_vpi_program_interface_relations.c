/* VPI application of test_vpi_program_interface_relations (IEEE 1800-2023 37.10). */
#include <string.h>
#include "vpi_user.h"
#include "sv_vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

#define TOP "test_vpi_program_interface_relations"

static void show_instance(const char *label, vpiHandle object, vpiHandle top)
{
    vpiHandle instance = object ? vpi_handle(vpiInstance, object) : NULL;
    const char *type = object ? vpi_get_str(vpiType, object) : NULL;
    vpi_printf((PLI_BYTE8 *)"%s: type %s, instance is module %d\n", label,
               type ? type : "(none)",
               top && instance && vpi_compare_objects(instance, top));
}

static PLI_INT32 program_calltf(PLI_BYTE8 *user_data)
{
    vpiHandle top = vpi_handle_by_name((PLI_BYTE8 *)TOP, NULL);
    vpiHandle scalar = vpi_handle_by_name((PLI_BYTE8 *)(TOP ".b"), NULL);
    vpiHandle array = vpi_handle_by_name((PLI_BYTE8 *)(TOP ".ba"), NULL);

    (void)user_data;
    show_instance("b", scalar, top);
    show_instance("ba", array, top);
    show_instance("ba[0]", array ? vpi_handle_by_index(array, 0) : NULL, top);
    show_instance("ba[1]", array ? vpi_handle_by_index(array, 1) : NULL, top);
    return 0;
}

static void register_all(void)
{
    s_vpi_systf_data d;
    memset(&d, 0, sizeof d);
    d.type = vpiSysTask;
    d.tfname = (PLI_BYTE8 *)"$vt_program";
    d.calltf = program_calltf;
    vpi_register_systf(&d);
}

void (*vlog_startup_routines[])(void) = {register_all, 0};

#ifdef __cplusplus
}
#endif
