/* VPI application of test_vpi_array_var (IEEE 1800-2023 37.17, 37.20). */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "sv_vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

#define TOP "test_vpi_array_var"
#define MAX 8

static int int_value(vpiHandle h)
{
    s_vpi_value v;
    v.format = vpiIntVal;
    vpi_get_value(h, &v);
    return (int)v.value.integer;
}

static char *copy_of(PLI_BYTE8 *s)
{
    char *c = (char *)malloc(s ? strlen(s) + 1 : 7);
    strcpy(c, s ? s : "(null)");
    return c;
}

static int by_name(const void *a, const void *b)
{
    return strcmp(*(char *const *)a, *(char *const *)b);
}

static void describe_array(const char *label, vpiHandle a)
{
    vpiHandle left = vpi_handle(vpiLeftRange, a), right = vpi_handle(vpiRightRange, a);
    vpi_printf("%s: %s, size %d, scalar %d, vector %d, range %d:%d\n", label,
               vpi_get(vpiType, a) == vpiArrayVar ? "array var" : "other type",
               (int)vpi_get(vpiSize, a), (int)vpi_get(vpiScalar, a), (int)vpi_get(vpiVector, a),
               left ? int_value(left) : -1, right ? int_value(right) : -1);
}

static void describe_element(vpiHandle array, vpiHandle e)
{
    char *name = copy_of(vpi_get_str(vpiName, e));
    char *full = copy_of(vpi_get_str(vpiFullName, e));
    vpiHandle it = vpi_iterate(vpiIndex, e), index;
    int first = 1;

    vpi_printf("%s (%s): size %d, value %d, array member %d, parent is the array %d, index",
               name, full, (int)vpi_get(vpiSize, e), int_value(e), (int)vpi_get(vpiArrayMember, e),
               (int)vpi_compare_objects(vpi_handle(vpiParent, e), array));
    while (it && (index = vpi_scan(it)) != NULL) {
        vpi_printf("%s %d", first ? "" : ",", int_value(index));
        first = 0;
    }
    vpi_printf("%s\n", first ? " none" : "");
}

static PLI_INT32 array_calltf(PLI_BYTE8 *user_data)
{
    vpiHandle top = vpi_handle_by_name((PLI_BYTE8 *)TOP, NULL);
    vpiHandle mem = vpi_handle_by_name((PLI_BYTE8 *)TOP ".mem", NULL);
    vpiHandle q = vpi_handle_by_name((PLI_BYTE8 *)TOP ".q", NULL);
    vpiHandle it, h, e;
    char *names[MAX];
    int n = 0, i, found = 0;
    s_vpi_value v;

    (void)user_data;
    if (top == NULL || mem == NULL || q == NULL) {
        vpi_printf("not found\n");
        return 0;
    }
    describe_array("mem", mem);
    it = vpi_iterate(vpiReg, mem);
    while (it && (h = vpi_scan(it)) != NULL)
        if (n < MAX)
            names[n++] = copy_of(vpi_get_str(vpiName, h));
    qsort(names, n, sizeof names[0], by_name);
    vpi_printf("elements of mem:");
    for (i = 0; i < n; i++)
        vpi_printf(" %s", names[i]);
    vpi_printf("\n");
    describe_element(mem, vpi_handle_by_index(mem, 2));

    describe_array("q", q);
    e = vpi_handle_by_index(q, 3);
    vpi_printf("q[3]: %s\n", e && vpi_get(vpiType, e) == vpiIntVar ? "int var" : "other type");
    describe_element(q, e);

    it = vpi_iterate(vpiMemory, top);
    while (it && (h = vpi_scan(it)) != NULL)
        if (vpi_compare_objects(h, mem))
            found = 1;
    vpi_printf("mem among the vpiMemory arrays: %d\n", found);

    v.format = vpiIntVal;
    v.value.integer = 0x77;
    vpi_put_value(vpi_handle_by_index(mem, 1), &v, NULL, vpiNoDelay);
    return 0;
}

static void register_all(void)
{
    s_vpi_systf_data d;
    memset(&d, 0, sizeof d);
    d.type = vpiSysTask;
    d.tfname = (PLI_BYTE8 *)"$vt_array";
    d.calltf = array_calltf;
    vpi_register_systf(&d);
}

void (*vlog_startup_routines[])(void) = {register_all, 0};

#ifdef __cplusplus
}
#endif
