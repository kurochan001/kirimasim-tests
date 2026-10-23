/* VPI application of test_vpi_instance_item_relations (IEEE 1800-2023 37.10). */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "sv_vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

#define TOP "test_vpi_instance_item_relations"
#define MAX 16

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

/* Prints the sorted names of vpi_iterate(type, inst), then the distinct full
   names that vpiInstance gives for those items. With check_array, also whether
   every item is an array variable object. */
static void show(const char *label, vpiHandle inst, PLI_INT32 type, const char *tname,
                 int check_array)
{
    vpiHandle it = vpi_iterate(type, inst), h;
    char *names[MAX], *owners[MAX];
    int n = 0, k = 0, i, j, arrays = 1;

    while (it && (h = vpi_scan(it)) != NULL) {
        vpiHandle owner = vpi_handle(vpiInstance, h);
        char *o = owner ? copy(vpi_get_str(vpiFullName, owner)) : copy((PLI_BYTE8 *)"NULL");
        if (n == MAX)
            continue;
        names[n++] = copy(vpi_get_str(vpiName, h));
        if (vpi_get(vpiType, h) != vpiArrayVar)
            arrays = 0;
        for (j = 0; j < k && strcmp(owners[j], o) != 0; j++)
            ;
        if (j == k)
            owners[k++] = o;
    }
    qsort(names, n, sizeof names[0], by_name);
    qsort(owners, k, sizeof owners[0], by_name);
    vpi_printf("%s %s:", label, tname);
    for (i = 0; i < n; i++)
        vpi_printf(" %s", names[i]);
    if (n == 0)
        vpi_printf(" none");
    if (check_array)
        vpi_printf(" (array variable objects %d)", n > 0 && arrays);
    vpi_printf("; vpiInstance:");
    for (i = 0; i < k; i++)
        vpi_printf(" %s", owners[i]);
    vpi_printf("\n");
}

static PLI_INT32 items_calltf(PLI_BYTE8 *user_data)
{
    vpiHandle ua = vpi_handle_by_name((PLI_BYTE8 *)TOP ".m.ua", NULL);
    vpiHandle ub = vpi_handle_by_name((PLI_BYTE8 *)TOP ".m.ub", NULL);

    (void)user_data;
    if (ua == NULL || ub == NULL) {
        vpi_printf("instances not found\n");
        return 0;
    }
    show("ua", ua, vpiTaskFunc, "vpiTaskFunc", 0);
    show("ua", ua, vpiNet, "vpiNet", 0);
    show("ua", ua, vpiVariables, "vpiVariables", 0);
    show("ua", ua, vpiReg, "vpiReg", 0);
    show("ua", ua, vpiNamedEvent, "vpiNamedEvent", 0);
    show("ua", ua, vpiParameter, "vpiParameter", 0);
    show("ua", ua, vpiSpecParam, "vpiSpecParam", 0);
    show("ua", ua, vpiTypedef, "vpiTypedef", 0);
    show("ua", ua, vpiAssertion, "vpiAssertion", 0);
    show("ua", ua, vpiProgram, "vpiProgram", 0);
    show("ub", ub, vpiArrayNet, "vpiArrayNet", 0);
    show("ub", ub, vpiVariables, "vpiVariables", 0);
    show("ub", ub, vpiRegArray, "vpiRegArray", 1);
    show("ub", ub, vpiMemory, "vpiMemory", 1);
    show("ub", ub, vpiNamedEventArray, "vpiNamedEventArray", 0);
    show("ub", ub, vpiProgramArray, "vpiProgramArray", 0);
    show("ub", ub, vpiClassDefn, "vpiClassDefn", 0);
    return 0;
}

static void register_all(void)
{
    s_vpi_systf_data d;
    memset(&d, 0, sizeof d);
    d.type = vpiSysTask;
    d.tfname = (PLI_BYTE8 *)"$vt_items";
    d.calltf = items_calltf;
    vpi_register_systf(&d);
}

void (*vlog_startup_routines[])(void) = {register_all, 0};

#ifdef __cplusplus
}
#endif
