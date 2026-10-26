/* VPI application of test_vpi_get_value_preserve (IEEE 1800-2023 38.15). */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

#define TOP "test_vpi_get_value_preserve"

static vpiHandle by_name(const char *name)
{
    char full[96];
    snprintf(full, sizeof full, "%s.%s", TOP, name);
    return vpi_handle_by_name((PLI_BYTE8 *)full, NULL);
}

static PLI_INT32 read_calltf(PLI_BYTE8 *user_data)
{
    s_vpi_value value;
    s_vpi_vecval copied[2];
    char copied_string[8];
    vpiHandle w = by_name("w"), st = by_name("st"), r = by_name("r"), x = by_name("x");

    (void)user_data;
    if (w == NULL || st == NULL || r == NULL || x == NULL) {
        vpi_printf("object not found\n");
        return 0;
    }

    memset(&value, 0, sizeof value);
    value.format = vpiVectorVal;
    vpi_get_value(w, &value);
    copied[0] = value.value.vector[0];
    copied[1] = value.value.vector[1];

    memset(&value, 0, sizeof value);
    value.format = vpiStringVal;
    vpi_get_value(st, &value);
    memset(copied_string, 0, sizeof copied_string);
    memcpy(copied_string, value.value.str, 2);
    vpi_printf("copied vector %08x%08x, copied string %s\n", (unsigned)copied[1].aval,
               (unsigned)copied[0].aval, copied_string);

    memset(&value, 0, sizeof value);
    value.format = vpiRealVal;
    vpi_get_value(r, &value);
    memset(&value, 0, sizeof value);
    value.format = vpiHexStrVal;
    vpi_get_value(x, &value);
    memset(&value, 0, sizeof value);
    value.format = vpiVectorVal;
    vpi_get_value(w, &value);

    vpi_printf("after later calls vector %08x%08x, string %s\n", (unsigned)copied[1].aval,
               (unsigned)copied[0].aval, copied_string);
    return 0;
}

static void register_all(void)
{
    s_vpi_systf_data d;

    memset(&d, 0, sizeof d);
    d.type = vpiSysTask;
    d.tfname = (PLI_BYTE8 *)"$vt_read";
    d.calltf = read_calltf;
    vpi_register_systf(&d);
}

void (*vlog_startup_routines[])(void) = {register_all, 0};

#ifdef __cplusplus
}
#endif
