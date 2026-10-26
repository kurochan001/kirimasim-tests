/* VPI application of test_vpi_variable_array_index_access (IEEE 1800-2023 37.17). */
#include <stdio.h>
#include <string.h>
#include "vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

#define TOP "test_vpi_variable_array_index_access"

static vpiHandle find(const char *name)
{
    char full[128];
    snprintf(full, sizeof full, "%s.%s", TOP, name);
    return vpi_handle_by_name((PLI_BYTE8 *)full, NULL);
}

static int int_value(vpiHandle h)
{
    s_vpi_value v;

    if (h == NULL)
        return -1000;
    v.format = vpiIntVal;
    v.value.integer = -1000;
    vpi_get_value(h, &v);
    return (int)v.value.integer;
}

static PLI_INT32 idx_calltf(PLI_BYTE8 *user_data)
{
    vpiHandle m = find("m"), pk = find("pk"), e;
    PLI_INT32 idx[2];
    s_vpi_value v;
    s_vpi_time t;

    (void)user_data;
    idx[0] = 1;
    idx[1] = 2;
    e = m != NULL ? vpi_handle_by_multi_index(m, 2, idx) : NULL;
    vpi_printf((PLI_BYTE8 *)"m[1][2] = %d\n", int_value(e));

    idx[0] = 1;
    idx[1] = 1;
    e = m != NULL ? vpi_handle_by_multi_index(m, 2, idx) : NULL;
    vpi_printf((PLI_BYTE8 *)"m[1][1] = %d\n", int_value(e));

    idx[0] = 0;
    idx[1] = 0;
    e = m != NULL ? vpi_handle_by_multi_index(m, 2, idx) : NULL;
    vpi_printf((PLI_BYTE8 *)"m[0][0] = %d\n", int_value(e));

    idx[0] = 0;
    idx[1] = 2;
    e = m != NULL ? vpi_handle_by_multi_index(m, 2, idx) : NULL;
    v.format = vpiIntVal;
    v.value.integer = 77;
    memset(&t, 0, sizeof t);
    vpi_put_value(e, &v, &t, vpiNoDelay);
    vpi_printf((PLI_BYTE8 *)"m[0][2] changed to %d\n", int_value(e));

    e = pk != NULL ? vpi_handle_by_index(pk, 2) : NULL;
    {
        int bit = int_value(e);
        const char *bits = "(none)";

        if (pk != NULL) {
            v.format = vpiBinStrVal;
            v.value.str = NULL;
            vpi_get_value(pk, &v);
            bits = v.value.str != NULL ? v.value.str : "(none)";
        }
        vpi_printf((PLI_BYTE8 *)"pk = %s, bit 2 = %d\n", bits, bit);
    }
    v.format = vpiIntVal;
    v.value.integer = 1;
    vpi_put_value(e, &v, &t, vpiNoDelay);
    v.format = vpiBinStrVal;
    v.value.str = NULL;
    if (pk != NULL)
        vpi_get_value(pk, &v);
    vpi_printf((PLI_BYTE8 *)"pk after put = %s\n",
               pk != NULL && v.value.str != NULL ? v.value.str : "(none)");
    return 0;
}

static void register_all(void)
{
    s_vpi_systf_data d;
    memset(&d, 0, sizeof d);
    d.type = vpiSysTask;
    d.tfname = (PLI_BYTE8 *)"$vt_idx";
    d.calltf = idx_calltf;
    vpi_register_systf(&d);
}

void (*vlog_startup_routines[])(void) = {register_all, 0};

#ifdef __cplusplus
}
#endif
