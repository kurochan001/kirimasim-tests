/* VPI application of test_vpi_net_array_elements_indices (IEEE 1800-2023 37.16). */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "sv_vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

#define TOP "test_vpi_net_array_elements_indices"
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

static int int_value(vpiHandle expr)
{
    s_vpi_value v;
    v.format = vpiIntVal;
    vpi_get_value(expr, &v);
    return (int)v.value.integer;
}

static void indices(vpiHandle h)
{
    vpiHandle it = vpi_iterate(vpiIndex, h), x;
    vpi_printf(", indices");
    if (it == NULL) {
        vpi_printf(" NULL");
        return;
    }
    while ((x = vpi_scan(it)) != NULL)
        vpi_printf(" %d", int_value(x));
}

static void parent(vpiHandle h)
{
    vpiHandle p = vpi_handle(vpiParent, h);
    vpi_printf(", parent %s", p ? copy(vpi_get_str(vpiName, p)) : "NULL");
}

static PLI_INT32 elements_calltf(PLI_BYTE8 *user_data)
{
    vpiHandle ma = vpi_handle_by_name((PLI_BYTE8 *)TOP ".ma", NULL);
    vpiHandle lone = vpi_handle_by_name((PLI_BYTE8 *)TOP ".lone", NULL);
    vpiHandle it, h, e, b;
    char *names[MAX], *parents[MAX];
    PLI_INT32 idx[2] = {2, 1};
    int n = 0, k = 0, members = 1, i, j;

    (void)user_data;
    it = ma ? vpi_iterate(vpiNet, ma) : NULL;
    while (it && (h = vpi_scan(it)) != NULL) {
        vpiHandle p = vpi_handle(vpiParent, h);
        char *pn = p ? copy(vpi_get_str(vpiName, p)) : copy((PLI_BYTE8 *)"NULL");
        if (n == MAX)
            continue;
        names[n++] = copy(vpi_get_str(vpiFullName, h));
        if (vpi_get(vpiArrayMember, h) != 1)
            members = 0;
        for (j = 0; j < k && strcmp(parents[j], pn) != 0; j++)
            ;
        if (j == k)
            parents[k++] = pn;
    }
    qsort(names, n, sizeof names[0], by_name);
    vpi_printf("nets of ma:");
    for (i = 0; i < n; i++)
        vpi_printf(" %s", names[i]);
    vpi_printf("; all array members %d; parents:", n > 0 && members);
    for (i = 0; i < k; i++)
        vpi_printf(" %s", parents[i]);
    vpi_printf("\n");

    e = ma ? vpi_handle_by_multi_index(ma, 2, idx) : NULL;
    if (e == NULL) {
        vpi_printf("ma[2][1] not found\n");
        return 0;
    }
    vpi_printf("element: name %s", copy(vpi_get_str(vpiName, e)));
    vpi_printf(", full name %s, array member %d", copy(vpi_get_str(vpiFullName, e)),
               (int)vpi_get(vpiArrayMember, e));
    indices(e);
    parent(e);
    vpi_printf("\n");

    n = 0;
    k = 1;
    it = vpi_iterate(vpiBit, e);
    while (it && (h = vpi_scan(it)) != NULL) {
        vpiHandle p = vpi_handle(vpiParent, h);
        n++;
        if (p == NULL || !vpi_compare_objects(p, e))
            k = 0;
    }
    vpi_printf("bits of the element: %d, each with the element as parent %d\n", n, n > 0 && k);

    b = vpi_handle_by_index(e, 3);
    if (b == NULL) {
        vpi_printf("bit 3 not found\n");
        return 0;
    }
    h = vpi_handle(vpiIndex, b);
    vpi_printf("bit: full name %s, vpiIndex %d", copy(vpi_get_str(vpiFullName, b)),
               h ? int_value(h) : -1);
    indices(b);
    parent(b);
    vpi_printf("\n");

    if (lone != NULL) {
        vpi_printf("lone: array member %d", (int)vpi_get(vpiArrayMember, lone));
        indices(lone);
        parent(lone);
        vpi_printf("\n");
    }
    return 0;
}

static void register_all(void)
{
    s_vpi_systf_data d;
    memset(&d, 0, sizeof d);
    d.type = vpiSysTask;
    d.tfname = (PLI_BYTE8 *)"$vt_elements";
    d.calltf = elements_calltf;
    vpi_register_systf(&d);
}

void (*vlog_startup_routines[])(void) = {register_all, 0};

#ifdef __cplusplus
}
#endif
