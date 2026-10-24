/* VPI application of test_vpi_packed_array_var_kinds (IEEE 1800-2023 37.18). */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "sv_vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

#define TOP "test_vpi_packed_array_var_kinds"
#define MAX 8

struct item {
    char *name;
    vpiHandle h;
};

struct counts {
    int levels, levels_flags, leaves, leaves_kind, leaves_flags;
};

/* vpi_get_str reuses its buffer (38.11), so every string is copied. */
static char *copy(PLI_BYTE8 *s)
{
    const char *t = s ? s : "(null)";
    char *c = (char *)malloc(strlen(t) + 1);
    strcpy(c, t);
    return c;
}

static int by_name(const void *a, const void *b)
{
    return strcmp(((const struct item *)a)->name, ((const struct item *)b)->name);
}

static vpiHandle find(const char *name)
{
    char full[128];
    snprintf(full, sizeof full, "%s.%s", TOP, name);
    return vpi_handle_by_name((PLI_BYTE8 *)full, NULL);
}

static int both_flags(vpiHandle h)
{
    return vpi_get(vpiVector, h) == 1 && vpi_get(vpiPacked, h) == 1;
}

/* Walks vpiElement down to the leaves. */
static void walk(vpiHandle h, PLI_INT32 leaf_type, struct counts *c)
{
    vpiHandle it = vpi_iterate(vpiElement, h), e;
    while (it != NULL && (e = vpi_scan(it)) != NULL) {
        if (vpi_get(vpiType, e) == vpiPackedArrayVar) {
            c->levels++;
            if (both_flags(e))
                c->levels_flags++;
            walk(e, leaf_type, c);
        } else {
            c->leaves++;
            if (vpi_get(vpiType, e) == leaf_type)
                c->leaves_kind++;
            if (both_flags(e))
                c->leaves_flags++;
        }
    }
}

static void describe(const char *name, PLI_INT32 leaf_type, const char *leaf)
{
    vpiHandle h = find(name), it, r;
    struct counts c = {0, 0, 0, 0, 0};
    int product = 1, n = 0;

    if (h == NULL) {
        vpi_printf("%s: not found\n", name);
        return;
    }
    it = vpi_iterate(vpiRange, h);
    while (it != NULL && (r = vpi_scan(it)) != NULL) {
        product *= (int)vpi_get(vpiSize, r);
        n++;
    }
    vpi_printf("%s: packed array var %d, packed %d, vector %d, size %d, %d ranges, product of "
               "their sizes %d\n", name, vpi_get(vpiType, h) == vpiPackedArrayVar ? 1 : 0,
               (int)vpi_get(vpiPacked, h), (int)vpi_get(vpiVector, h), (int)vpi_get(vpiSize, h),
               n, product);
    walk(h, leaf_type, &c);
    vpi_printf("  intermediate packed array vars %d (both flags TRUE %d), leaves %d (%s vars %d, "
               "both flags TRUE %d)\n", c.levels, c.levels_flags, c.leaves, leaf, c.leaves_kind,
               c.leaves_flags);
}

static int elements(vpiHandle h, struct item *list)
{
    vpiHandle it = h ? vpi_iterate(vpiElement, h) : NULL, e;
    int n = 0;
    while (it != NULL && (e = vpi_scan(it)) != NULL) {
        if (n == MAX)
            continue;
        list[n].name = copy(vpi_get_str(vpiName, e));
        list[n++].h = e;
    }
    qsort(list, n, sizeof list[0], by_name);
    return n;
}

static PLI_INT32 packed_calltf(PLI_BYTE8 *user_data)
{
    struct item top[MAX], sub[MAX];
    int n, m, i, j;

    (void)user_data;
    describe("pas", vpiStructVar, "struct");
    describe("pau", vpiUnionVar, "union");
    describe("pae", vpiEnumVar, "enum");

    n = elements(find("pae"), top);
    for (i = 0; i < n; i++)
        if (strcmp(top[i].name, "pae[1]") == 0) {
            vpi_printf("pae[1]: constant select %d\n", (int)vpi_get(vpiConstantSelect, top[i].h));
            m = elements(top[i].h, sub);
            for (j = 0; j < m; j++)
                if (strcmp(sub[j].name, "pae[1][2]") == 0)
                    vpi_printf("pae[1][2]: constant select %d\n",
                               (int)vpi_get(vpiConstantSelect, sub[j].h));
        }
    n = elements(vpi_handle_by_index(find("dpe"), 0), sub);
    vpi_printf("subelements of dpe[0] (%d): constant select", n);
    for (i = 0; i < n; i++)
        vpi_printf(" %d", (int)vpi_get(vpiConstantSelect, sub[i].h));
    vpi_printf("\n");
    return 0;
}

static void register_all(void)
{
    s_vpi_systf_data d;
    memset(&d, 0, sizeof d);
    d.type = vpiSysTask;
    d.tfname = (PLI_BYTE8 *)"$vt_packed";
    d.calltf = packed_calltf;
    vpi_register_systf(&d);
}

void (*vlog_startup_routines[])(void) = {register_all, 0};

#ifdef __cplusplus
}
#endif
