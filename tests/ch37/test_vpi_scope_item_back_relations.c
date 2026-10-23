/* VPI application of test_vpi_scope_item_back_relations (IEEE 1800-2023 37.12). */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "sv_vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

#define TOP "test_vpi_scope_item_back_relations"
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

/* Prints the sorted names of vpi_iterate(type, scope) and the distinct full
   names that vpiScope gives for those items. */
static void show(const char *label, vpiHandle scope, PLI_INT32 type, const char *tname)
{
    vpiHandle it = scope ? vpi_iterate(type, scope) : NULL, h;
    char *names[MAX], *backs[MAX];
    int n = 0, k = 0, i, j;

    while (it && (h = vpi_scan(it)) != NULL) {
        vpiHandle back = vpi_handle(vpiScope, h);
        char *b = back ? copy(vpi_get_str(vpiFullName, back)) : copy((PLI_BYTE8 *)"NULL");
        if (n == MAX)
            continue;
        names[n++] = copy(vpi_get_str(vpiName, h));
        for (j = 0; j < k && strcmp(backs[j], b) != 0; j++)
            ;
        if (j == k)
            backs[k++] = b;
    }
    qsort(names, n, sizeof names[0], by_name);
    qsort(backs, k, sizeof backs[0], by_name);
    vpi_printf("%s %s:", label, tname);
    for (i = 0; i < n; i++)
        vpi_printf(" %s", names[i]);
    if (n == 0)
        vpi_printf(" none");
    vpi_printf("; vpiScope:");
    for (i = 0; i < k; i++)
        vpi_printf(" %s", backs[i]);
    vpi_printf("\n");
}

static PLI_INT32 items_calltf(PLI_BYTE8 *user_data)
{
    vpiHandle nb = vpi_handle_by_name((PLI_BYTE8 *)TOP ".nb", NULL);
    vpiHandle g = vpi_handle_by_name((PLI_BYTE8 *)TOP ".g", NULL);

    (void)user_data;
    show("nb", nb, vpiReg, "vpiReg");
    show("nb", nb, vpiRegArray, "vpiRegArray");
    show("nb", nb, vpiMemory, "vpiMemory");
    show("nb", nb, vpiNamedEvent, "vpiNamedEvent");
    show("nb", nb, vpiNamedEventArray, "vpiNamedEventArray");
    show("nb", nb, vpiParameter, "vpiParameter");
    show("nb", nb, vpiTypedef, "vpiTypedef");
    show("nb", nb, vpiLetDecl, "vpiLetDecl");
    show("g", g, vpiPropertyDecl, "vpiPropertyDecl");
    show("g", g, vpiSequenceDecl, "vpiSequenceDecl");
    show("g", g, vpiConcurrentAssertions, "vpiConcurrentAssertions");
    return 0;
}

static void register_all(void)
{
    s_vpi_systf_data d;
    memset(&d, 0, sizeof d);
    d.type = vpiSysTask;
    d.tfname = (PLI_BYTE8 *)"$vt_scope_items";
    d.calltf = items_calltf;
    vpi_register_systf(&d);
}

void (*vlog_startup_routines[])(void) = {register_all, 0};

#ifdef __cplusplus
}
#endif
