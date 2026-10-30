/* VPI application of test_vpi_array_objects_and_array_member (IEEE 1800-2023 37.17, C.4.3). */
#include <stdio.h>
#include <string.h>
#include "sv_vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

#define TOP "test_vpi_array_objects_and_array_member"

static PLI_INT32 arrays_calltf(PLI_BYTE8 *user_data)
{
    vpiHandle top, mem, ia, element, it, h;
    PLI_BYTE8 *name;
    int found = 0, all_arrays = 1;

    (void)user_data;
    mem = vpi_handle_by_name((PLI_BYTE8 *)TOP ".mem", NULL);
    printf("mem is an array var %d and not a memory object %d\n",
           mem != NULL && vpi_get(vpiType, mem) == vpiArrayVar,
           mem != NULL && vpi_get(vpiType, mem) != vpiMemory);

    element = mem != NULL ? vpi_handle_by_index(mem, 2) : NULL;
    printf("mem[2] is a variable object %d and not a memory word %d\n",
           element != NULL && vpi_get(vpiType, element) == vpiReg,
           element != NULL && vpi_get(vpiType, element) != vpiMemoryWord);
    printf("vpiArrayMember is 1 for mem[2] and 0 for mem %d %d\n",
           element != NULL ? (int)vpi_get(vpiArrayMember, element) : -1,
           mem != NULL ? (int)vpi_get(vpiArrayMember, mem) : -1);

    ia = vpi_handle_by_name((PLI_BYTE8 *)TOP ".ia", NULL);
    element = ia != NULL ? vpi_handle_by_index(ia, 1) : NULL;
    printf("ia is an array var %d, ia[1] is an int var %d and a member %d\n",
           ia != NULL && vpi_get(vpiType, ia) == vpiArrayVar,
           element != NULL && vpi_get(vpiType, element) == vpiIntVar,
           element != NULL ? (int)vpi_get(vpiArrayMember, element) : -1);

    /* vpiMemory is a relationship of a module (37.20). */
    top = vpi_handle_by_name((PLI_BYTE8 *)TOP, NULL);
    it = top != NULL ? vpi_iterate(vpiMemory, top) : NULL;
    while (it != NULL && (h = vpi_scan(it)) != NULL) {
        name = vpi_get_str(vpiName, h);
        if (name != NULL && strcmp(name, "mem") == 0)
            found = 1;
        if (vpi_get(vpiType, h) != vpiArrayVar)
            all_arrays = 0;
    }
    printf("the vpiMemory relationship of the module gives mem %d"
           " and only array vars %d\n", found, all_arrays);
    fflush(stdout);
    return 0;
}

static void register_arrays(void)
{
    s_vpi_systf_data data;

    data.type = vpiSysTask;
    data.tfname = (PLI_BYTE8 *)"$vt_arrays";
    data.calltf = arrays_calltf;
    data.compiletf = NULL;
    data.sizetf = NULL;
    data.user_data = NULL;
    vpi_register_systf(&data);
}

void (*vlog_startup_routines[])(void) = { register_arrays, 0 };

#ifdef __cplusplus
}
#endif
