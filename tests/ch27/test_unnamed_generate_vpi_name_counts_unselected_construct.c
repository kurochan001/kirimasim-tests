#include <stddef.h>
#include <string.h>
#include "vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

static PLI_INT32 observe(p_cb_data data)
{
    vpiHandle absent = vpi_handle_by_name((PLI_BYTE8 *)"test_unnamed_generate_vpi_name_counts_unselected_construct.genblk1.marker", NULL);
    vpiHandle actual = vpi_handle_by_name((PLI_BYTE8 *)"test_unnamed_generate_vpi_name_counts_unselected_construct.genblk2.marker", NULL);
    s_vpi_value value = {0};
    (void)data;
    if (actual == NULL) {
        vpi_printf("genblk2 marker missing\n");
        return 0;
    }
    value.format = vpiIntVal;
    vpi_get_value(actual, &value);
    vpi_printf("genblk1=%d genblk2=%d value=%d\n", absent != NULL, actual != NULL,
               (int)value.value.integer);
    return 0;
}

static void register_observation(void)
{
    s_cb_data callback = {0};
    callback.reason = cbEndOfSimulation;
    callback.cb_rtn = observe;
    vpi_register_cb(&callback);
}

void (*vlog_startup_routines[])(void) = {register_observation, NULL};

#ifdef __cplusplus
}
#endif
