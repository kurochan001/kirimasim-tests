/* VPI application of test_vpi_systf_names (IEEE 1800-2023 36.3). */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

static const char *const names[] = {
    "$vt_Case",
    "$vt_case",
    "$vt_dollar$in$name",
    "$vt_digits_0123456789",
    "$vt_a_long_name_that_goes_on_well_past_the_usual_length_of_identifiers_x",
    "$vt_a_long_name_that_goes_on_well_past_the_usual_length_of_identifiers_y",
};

static PLI_INT32 say_name(PLI_BYTE8 *user_data)
{
    vpi_printf("%s ran\n", user_data);
    return 0;
}

static void register_all(void)
{
    int i;

    for (i = 0; i < (int)(sizeof names / sizeof names[0]); i++) {
        s_vpi_systf_data d;
        memset(&d, 0, sizeof d);
        d.type = vpiSysTask;
        d.tfname = (PLI_BYTE8 *)names[i];
        d.calltf = say_name;
        d.user_data = (PLI_BYTE8 *)names[i];
        vpi_register_systf(&d);
    }
}

void (*vlog_startup_routines[])(void) = {register_all, 0};

#ifdef __cplusplus
}
#endif
