/* VPI application of test_vpi_get_vlog_info (IEEE 1800-2023 38.17, 38.2, 38.38). */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

static const char *yes_no(int b)
{
    return b ? "yes" : "no";
}

static PLI_INT32 info_calltf(PLI_BYTE8 *user_data)
{
    s_vpi_vlog_info info;
    PLI_INT32 ok, first, second;
    vpiHandle top, it;

    (void)user_data;
    memset(&info, 0, sizeof info);
    ok = vpi_get_vlog_info(&info);
    first = vpi_chk_error(NULL);
    second = vpi_chk_error(NULL);
    vpi_printf("vpi_get_vlog_info returns %d\n", (int)ok);
    vpi_printf("argc at least 1: %s\n", yes_no(info.argc >= 1));
    vpi_printf("argv[0] given: %s\n", yes_no(info.argc >= 1 && info.argv && info.argv[0]));
    vpi_printf("product given: %s, version given: %s\n", yes_no(info.product != NULL),
               yes_no(info.version != NULL));
    vpi_printf("vpi_chk_error after it: %d, again: %d\n", (int)first, (int)second);

    top = vpi_handle_by_name((PLI_BYTE8 *)"test_vpi_get_vlog_info", NULL);
    it = top ? vpi_iterate(vpiReg, top) : NULL;
    if (it == NULL || vpi_scan(it) == NULL) {
        vpi_printf("no variables found\n");
        return 0;
    }
    vpi_printf("vpi_release_handle of the iterator returns %d\n", (int)vpi_release_handle(it));
    return 0;
}

static void register_all(void)
{
    s_vpi_systf_data d;
    memset(&d, 0, sizeof d);
    d.type = vpiSysTask;
    d.tfname = (PLI_BYTE8 *)"$vt_info";
    d.calltf = info_calltf;
    vpi_register_systf(&d);
}

void (*vlog_startup_routines[])(void) = {register_all, 0};

#ifdef __cplusplus
}
#endif
