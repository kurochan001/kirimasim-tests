/* VPI application of test_vpi_get_value_array (IEEE 1800-2023 38.16). */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

static PLI_INT32 read_calltf(PLI_BYTE8 *user_data)
{
    vpiHandle mem = vpi_handle_by_name((PLI_BYTE8 *)"test_vpi_get_value_array.mem", NULL);
    vpiHandle ia = vpi_handle_by_name((PLI_BYTE8 *)"test_vpi_get_value_array.ia", NULL);
    PLI_INT32 ints[3], index[1];
    s_vpi_vecval vecs[2];
    s_vpi_arrayvalue v;
    int i;

    (void)user_data;
    if (mem == NULL || ia == NULL) {
        vpi_printf("arrays not found\n");
        return 0;
    }

    memset(&v, 0, sizeof v);
    v.format = vpiIntVal;
    v.flags = vpiUserAllocFlag;
    v.value.integers = ints;
    index[0] = 1;
    vpi_get_value_array(mem, &v, index, 3);
    if (v.value.integers == NULL) {
        vpi_printf("mem as integers: error\n");
    } else {
        vpi_printf("mem[1:3] as integers:");
        for (i = 0; i < 3; i++)
            vpi_printf(" %d", (int)v.value.integers[i]);
        vpi_printf("\n");
    }

    memset(&v, 0, sizeof v);
    v.format = vpiIntVal;
    index[0] = 3;
    vpi_get_value_array(ia, &v, index, 2);
    if (v.value.integers == NULL)
        vpi_printf("ia in VPI storage: error\n");
    else
        vpi_printf("ia[3:4] in VPI storage: %d %d\n", (int)v.value.integers[0],
                   (int)v.value.integers[1]);

    memset(&v, 0, sizeof v);
    v.format = vpiVectorVal;
    v.flags = vpiUserAllocFlag;
    v.value.vectors = vecs;
    index[0] = 0;
    vpi_get_value_array(mem, &v, index, 2);
    if (v.value.vectors == NULL)
        vpi_printf("mem as vectors: error\n");
    else
        vpi_printf("mem[0:1] as vectors: aval %x bval %x, aval %x bval %x\n",
                   (unsigned)vecs[0].aval, (unsigned)vecs[0].bval, (unsigned)vecs[1].aval,
                   (unsigned)vecs[1].bval);
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
