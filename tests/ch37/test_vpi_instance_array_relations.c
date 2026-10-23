/* VPI application of test_vpi_instance_array_relations (IEEE 1800-2023 37.11). */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "sv_vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

#define TOP "test_vpi_instance_array_relations"
#define MAX 8

static int by_name(const void *a, const void *b)
{
    return strcmp(*(const char *const *)a, *(const char *const *)b);
}

/* vpi_get_str reuses its buffer (38.11), so every string is copied. */
static char *copy(PLI_BYTE8 *s)
{
    const char *t = s ? s : "(null)";
    char *c = (char *)malloc(strlen(t) + 1);
    strcpy(c, t);
    return c;
}

static const char *kind(vpiHandle h)
{
    switch (vpi_get(vpiType, h)) {
    case vpiModuleArray: return "vpiModuleArray";
    case vpiInterfaceArray: return "vpiInterfaceArray";
    case vpiProgramArray: return "vpiProgramArray";
    case vpiGateArray: return "vpiGateArray";
    case vpiSwitchArray: return "vpiSwitchArray";
    case vpiUdpArray: return "vpiUdpArray";
    default: return "other type";
    }
}

/* Prints the sorted full names of vpi_iterate(down, arr) and the distinct
   local names of vpi_handle(up, element) over those elements. */
static void elements(const char *label, vpiHandle arr, PLI_INT32 down, const char *dname,
                     PLI_INT32 up, const char *uname)
{
    vpiHandle it = vpi_iterate(down, arr), h;
    char *names[MAX], *backs[MAX];
    int n = 0, k = 0, i, j;

    while (it && (h = vpi_scan(it)) != NULL) {
        vpiHandle back = vpi_handle(up, h);
        char *b = back ? copy(vpi_get_str(vpiName, back)) : copy((PLI_BYTE8 *)"NULL");
        if (n == MAX)
            continue;
        names[n++] = copy(vpi_get_str(vpiFullName, h));
        for (j = 0; j < k && strcmp(backs[j], b) != 0; j++)
            ;
        if (j == k)
            backs[k++] = b;
    }
    qsort(names, n, sizeof names[0], by_name);
    qsort(backs, k, sizeof backs[0], by_name);
    vpi_printf("%s %s:", label, dname);
    for (i = 0; i < n; i++)
        vpi_printf(" %s", names[i]);
    if (n == 0)
        vpi_printf(" none");
    vpi_printf("; %s of each:", uname);
    for (i = 0; i < k; i++)
        vpi_printf(" %s", backs[i]);
    vpi_printf("\n");
}

static vpiHandle header(const char *local)
{
    char full[96];
    vpiHandle arr;
    char *name, *fname;

    snprintf(full, sizeof full, "%s.%s", TOP, local);
    arr = vpi_handle_by_name(full, NULL);
    if (arr == NULL) {
        vpi_printf("%s: not found\n", local);
        return NULL;
    }
    name = copy(vpi_get_str(vpiName, arr));
    fname = copy(vpi_get_str(vpiFullName, arr));
    vpi_printf("%s: %s, name %s, full name %s, size %d\n", local, kind(arr), name, fname,
               (int)vpi_get(vpiSize, arr));
    return arr;
}

static void connections(vpiHandle arr)
{
    vpiHandle op = vpi_handle(vpiExpr, arr), it, h;

    if (op == NULL || vpi_get(vpiType, op) != vpiOperation) {
        vpi_printf("ma connections: not an operation\n");
        return;
    }
    vpi_printf("ma connections: vpiListOp %d, operands:", vpi_get(vpiOpType, op) == vpiListOp);
    it = vpi_iterate(vpiOperand, op);
    while (it && (h = vpi_scan(it)) != NULL)
        vpi_printf(" %s", copy(vpi_get_str(vpiName, h)));
    vpi_printf("\n");
}

static PLI_INT32 arrays_calltf(PLI_BYTE8 *user_data)
{
    vpiHandle a;

    (void)user_data;
    if ((a = header("ma")) != NULL) {
        connections(a);
        elements("ma", a, vpiInstance, "vpiInstance", vpiInstanceArray, "vpiInstanceArray");
        elements("ma", a, vpiModule, "vpiModule", vpiModuleArray, "vpiModuleArray");
    }
    if ((a = header("ifa")) != NULL)
        elements("ifa", a, vpiInstance, "vpiInstance", vpiInstanceArray, "vpiInstanceArray");
    if ((a = header("pga")) != NULL)
        elements("pga", a, vpiInstance, "vpiInstance", vpiInstanceArray, "vpiInstanceArray");
    if ((a = header("gb")) != NULL)
        elements("gb", a, vpiPrimitive, "vpiPrimitive", vpiPrimitiveArray, "vpiPrimitiveArray");
    if ((a = header("sw")) != NULL)
        elements("sw", a, vpiPrimitive, "vpiPrimitive", vpiPrimitiveArray, "vpiPrimitiveArray");
    if ((a = header("uda")) != NULL)
        elements("uda", a, vpiPrimitive, "vpiPrimitive", vpiPrimitiveArray, "vpiPrimitiveArray");
    return 0;
}

static void register_all(void)
{
    s_vpi_systf_data d;
    memset(&d, 0, sizeof d);
    d.type = vpiSysTask;
    d.tfname = (PLI_BYTE8 *)"$vt_arrays";
    d.calltf = arrays_calltf;
    vpi_register_systf(&d);
}

void (*vlog_startup_routines[])(void) = {register_all, 0};

#ifdef __cplusplus
}
#endif
