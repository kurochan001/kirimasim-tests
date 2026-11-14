/* C side of test_dpi_vpi_systf_handle_in_import (IEEE 1800-2023 35.5.3,
   H.9.5, 38.2). */
#include <string.h>
#include "vpi_user.h"
#include "svdpi.h"

#ifdef __cplusplus
extern "C" {
#endif

static char first_module[128];

/* A context import: it may call VPI routines (35.5.3, H.9.5). Each check
   passes back 1 when vpi_chk_error reports an error for the call before it
   and 0 when it does not (38.2). */
void c_probe(int *modules, int *iterate_error, int *marker_value, int *marker_error,
             int *systf_error)
{
    vpiHandle it, m, var;
    s_vpi_value value;
    int n = 0;

    it = vpi_iterate(vpiModule, NULL);
    *iterate_error = vpi_chk_error(NULL) != 0;
    if (it != NULL) {
        while ((m = vpi_scan(it)) != NULL) {
            const char *name = vpi_get_str(vpiName, m);
            if (n == 0 && name != NULL)
                strncpy(first_module, name, sizeof first_module - 1);
            n++;
        }
    }
    *modules = n;

    *marker_value = -1;
    *marker_error = 1;
    var = vpi_handle_by_name((PLI_BYTE8 *)"test_dpi_vpi_systf_handle_in_import.marker", NULL);
    if (var != NULL) {
        value.format = vpiIntVal;
        vpi_get_value(var, &value);
        *marker_error = vpi_chk_error(NULL) != 0;
        *marker_value = value.value.integer;
    }

    /* An import is not a system task (H.9.5): this call is an error. */
    vpi_handle(vpiSysTfCall, NULL);
    *systf_error = vpi_chk_error(NULL) != 0;
}

const char *c_first_module(void)
{
    return first_module;
}

#ifdef __cplusplus
}
#endif
