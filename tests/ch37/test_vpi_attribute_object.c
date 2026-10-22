/* VPI application of test_vpi_attribute_object (IEEE 1800-2023 37.83). */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "vpi_user.h"
#include "sv_vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

#define TOP "test_vpi_attribute_object"

static PLI_INT32 report_calltf(PLI_BYTE8 *user_data)
{
    vpiHandle inst = vpi_handle_by_name((PLI_BYTE8 *)TOP ".u", NULL);
    vpiHandle it, a;
    int n = 0;

    (void)user_data;
    if (inst == NULL) {
        vpi_printf("u not found\n");
        return 0;
    }
    it = vpi_iterate(vpiAttribute, inst);
    while (it != NULL && (a = vpi_scan(it)) != NULL) {
        s_vpi_value v;
        const char *name = vpi_get_str(vpiName, a);
        v.format = vpiStringVal;
        vpi_get_value(a, &v);
        vpi_printf("attribute %s=%s def=%d\n", name ? name : "(null)",
                   v.value.str ? v.value.str : "(null)",
                   (int)vpi_get(vpiDefAttribute, a));
        n++;
    }
    vpi_printf("attributes: %d\n", n);
    return 0;
}

static void register_all(void)
{
    s_vpi_systf_data d;

    memset(&d, 0, sizeof d);
    d.type = vpiSysTask;
    d.tfname = (PLI_BYTE8 *)"$vt_report";
    d.calltf = report_calltf;
    vpi_register_systf(&d);
}

void (*vlog_startup_routines[])(void) = {register_all, 0};

#ifdef __cplusplus
}
#endif
