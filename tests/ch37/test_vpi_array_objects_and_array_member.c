/* VPI application of test_vpi_array_objects_and_array_member (IEEE 1800-2023 37.17, C.4.3). */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "sv_vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

#define TOP "test_vpi_array_objects_and_array_member"

static char *copy_of(PLI_BYTE8 *s)
{
    char *c = (char *)malloc(s != NULL ? strlen(s) + 1 : 7);

    strcpy(c, s != NULL ? s : "(null)");
    return c;
}

static int by_name(const void *a, const void *b)
{
    return strcmp(*(char *const *)a, *(char *const *)b);
}

static PLI_INT32 arrays_calltf(PLI_BYTE8 *user_data)
{
    vpiHandle mem, ia, element, it, h;
    char *names[4];
    int count = 0, k;

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
    printf("ia is an array var %d, ia[1] is an integer var %d and a member %d\n",
           ia != NULL && vpi_get(vpiType, ia) == vpiArrayVar,
           element != NULL && vpi_get(vpiType, element) == vpiIntegerVar,
           element != NULL ? (int)vpi_get(vpiArrayMember, element) : -1);

    it = vpi_iterate(vpiMemory, NULL);
    while (it != NULL && count < 4 && (h = vpi_scan(it)) != NULL)
        names[count++] = copy_of(vpi_get_str(vpiName, h));
    qsort(names, (size_t)count, sizeof names[0], by_name);
    printf("the vpiMemory relationship gives %d arrays:", count);
    for (k = 0; k < count; k++)
        printf(" %s", names[k]);
    printf("\n");
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
