/* VPI application of test_vpi_struct_union_net_flags (IEEE 1800-2023 37.26). */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "sv_vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

#define TOP "test_vpi_struct_union_net_flags"
#define MAX 8

struct item {
    char *name;
    vpiHandle h;
};

/* vpi_get_str reuses its buffer (38.11), so every string is copied; NULL is shown. */
static char *str(PLI_BYTE8 *s)
{
    const char *t = s ? s : "NULL";
    char *c = (char *)malloc(strlen(t) + 1);
    strcpy(c, t);
    return c;
}

static int by_name(const void *a, const void *b)
{
    return strcmp(((const struct item *)a)->name, ((const struct item *)b)->name);
}

static int same(vpiHandle a, vpiHandle b)
{
    return a != NULL && b != NULL && vpi_compare_objects(a, b) ? 1 : 0;
}

static const char *kind(vpiHandle h)
{
    switch (vpi_get(vpiType, h)) {
    case vpiStructNet: return "struct net";
    case vpiUnionNet: return "union net";
    case vpiNet: return "logic net";
    default: return "other type";
    }
}

static void describe(const char *name)
{
    char full[128];
    vpiHandle n, it, m;
    struct item list[MAX];
    int count = 0, i;

    snprintf(full, sizeof full, "%s.%s", TOP, name);
    n = vpi_handle_by_name((PLI_BYTE8 *)full, NULL);
    if (n == NULL) {
        vpi_printf("%s: not found\n", name);
        return;
    }
    vpi_printf("%s: %s, tagged %d, soft %d, packed %d\n", name, kind(n), (int)vpi_get(vpiTagged, n),
               (int)vpi_get(vpiSoft, n), (int)vpi_get(vpiPacked, n));
    it = vpi_iterate(vpiMember, n);
    while (it != NULL && (m = vpi_scan(it)) != NULL) {
        if (count == MAX)
            continue;
        list[count].name = str(vpi_get_str(vpiName, m));
        list[count++].h = m;
    }
    qsort(list, count, sizeof list[0], by_name);
    vpi_printf("  members (%d):", count);
    for (i = 0; i < count; i++)
        vpi_printf(" %s (%s, parent is %s %d)", list[i].name, kind(list[i].h), name,
                   same(vpi_handle(vpiParent, list[i].h), n));
    vpi_printf("\n");
}

static PLI_INT32 nets_calltf(PLI_BYTE8 *user_data)
{
    (void)user_data;
    describe("snp");
    describe("snu");
    describe("unp");
    describe("uns");
    describe("unu");
    return 0;
}

static void register_all(void)
{
    s_vpi_systf_data d;
    memset(&d, 0, sizeof d);
    d.type = vpiSysTask;
    d.tfname = (PLI_BYTE8 *)"$vt_nets";
    d.calltf = nets_calltf;
    vpi_register_systf(&d);
}

void (*vlog_startup_routines[])(void) = {register_all, 0};

#ifdef __cplusplus
}
#endif
