/* VPI application of test_vpi_handle_by_multi_index (IEEE 1800-2023 38.20). */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

static void show(vpiHandle mem, int n, PLI_INT32 *indices, const char *what)
{
    vpiHandle h = vpi_handle_by_multi_index(mem, n, indices);
    s_vpi_value v;

    if (h == NULL) {
        vpi_printf("%s: NULL\n", what);
        return;
    }
    v.format = vpiBinStrVal;
    vpi_get_value(h, &v);
    vpi_printf("%s: %s\n", what, v.value.str);
}

static PLI_INT32 lookup_calltf(PLI_BYTE8 *user_data)
{
    vpiHandle mem = vpi_handle_by_name((PLI_BYTE8 *)"test_vpi_handle_by_multi_index.mem", NULL);
    PLI_INT32 a[2] = {2, 1}, b[3] = {2, 1, 3}, c[2] = {3, 2}, d[4] = {2, 1, 3, 0};

    (void)user_data;
    if (mem == NULL) {
        vpi_printf("mem not found\n");
        return 0;
    }
    show(mem, 2, a, "mem[2][1]");
    show(mem, 3, b, "mem[2][1][3]");
    show(mem, 2, c, "mem[3][2]");
    show(mem, 4, d, "mem[2][1][3][0]");
    return 0;
}

static void register_all(void)
{
    s_vpi_systf_data s;
    memset(&s, 0, sizeof s);
    s.type = vpiSysTask;
    s.tfname = (PLI_BYTE8 *)"$vt_lookup";
    s.calltf = lookup_calltf;
    vpi_register_systf(&s);
}

void (*vlog_startup_routines[])(void) = {register_all, 0};

#ifdef __cplusplus
}
#endif
