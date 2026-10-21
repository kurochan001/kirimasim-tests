/* VPI application of test_vpi_packed_array_levels (IEEE 1800-2023 37.18). */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "sv_vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

#define TOP "test_vpi_packed_array_levels"
#define MAX 8

struct named {
    char name[32];
    vpiHandle h;
};

static int by_name(const void *a, const void *b)
{
    return strcmp(((const struct named *)a)->name, ((const struct named *)b)->name);
}

/* The elements of obj from vpiElement, sorted by name; printed as a list. */
static int elements(const char *label, vpiHandle obj, struct named *list)
{
    vpiHandle it = obj ? vpi_iterate(vpiElement, obj) : NULL, h;
    int n = 0, i;
    while (it && (h = vpi_scan(it)) != NULL) {
        PLI_BYTE8 *s = vpi_get_str(vpiName, h);
        if (n == MAX)
            continue;
        snprintf(list[n].name, sizeof list[n].name, "%s", s ? s : "(null)");
        list[n++].h = h;
    }
    qsort(list, n, sizeof list[0], by_name);
    vpi_printf("elements of %s:", label);
    for (i = 0; i < n; i++)
        vpi_printf(" %s", list[i].name);
    vpi_printf("\n");
    return n;
}

static vpiHandle pick(struct named *list, int n, const char *name)
{
    int i;
    for (i = 0; i < n; i++)
        if (strcmp(list[i].name, name) == 0)
            return list[i].h;
    return NULL;
}

static int int_of(vpiHandle expr)
{
    s_vpi_value v;
    if (expr == NULL)
        return -1;
    v.format = vpiIntVal;
    vpi_get_value(expr, &v);
    return (int)v.value.integer;
}

static const char *kind(vpiHandle h)
{
    switch (vpi_get(vpiType, h)) {
    case vpiPackedArrayVar: return "packed array var";
    case vpiStructVar: return "struct var";
    default: return "other type";
    }
}

static int same(vpiHandle a, vpiHandle b)
{
    return a && b ? (int)vpi_compare_objects(a, b) : 0;
}

#define SHOW_SU 1  /* vpiStructUnionMember */
#define SHOW_PA 2  /* vpiPackedArrayMember */
#define SHOW_IDX 4 /* the vpiIndex iteration of an element of a packed array */

/* One line for a subelement: type, size, parent, the properties that the
 * standard fixes for it, and the value. */
static void describe(const char *label, vpiHandle h, vpiHandle parent, const char *pname,
                     int show)
{
    vpiHandle it, ix;
    s_vpi_value v;
    if (h == NULL) {
        vpi_printf("%s: not found\n", label);
        return;
    }
    vpi_printf("%s: %s, size %d, parent is %s %d", label, kind(h), (int)vpi_get(vpiSize, h),
               pname, same(vpi_handle(vpiParent, h), parent));
    if (show & SHOW_SU)
        vpi_printf(", struct member %d", (int)vpi_get(vpiStructUnionMember, h));
    if (show & SHOW_PA)
        vpi_printf(", packed array member %d", (int)vpi_get(vpiPackedArrayMember, h));
    if (show & SHOW_IDX) {
        vpi_printf(", indices:");
        it = vpi_iterate(vpiIndex, h);
        while (it && (ix = vpi_scan(it)) != NULL)
            vpi_printf(" %d", int_of(ix));
    }
    v.format = vpiHexStrVal;
    vpi_get_value(h, &v);
    vpi_printf(", value %s\n", v.value.str ? v.value.str : "(null)");
}

static PLI_INT32 levels_calltf(PLI_BYTE8 *user_data)
{
    vpiHandle pav = vpi_handle_by_name((PLI_BYTE8 *)TOP ".pav", NULL);
    vpiHandle rv = vpi_handle_by_name((PLI_BYTE8 *)TOP ".rv", NULL);
    vpiHandle it, r, pp = NULL, sub;
    struct named top_list[MAX], sub_list[MAX], pp_list[MAX];
    int n, first = 1;

    (void)user_data;
    if (pav == NULL || rv == NULL) {
        vpi_printf("pav or rv not found\n");
        return 0;
    }
    vpi_printf("pav: %s, size %d, ranges:", kind(pav), (int)vpi_get(vpiSize, pav));
    it = vpi_iterate(vpiRange, pav);
    while (it && (r = vpi_scan(it)) != NULL) {
        vpi_printf("%s %d:%d", first ? "" : ",", int_of(vpi_handle(vpiLeftRange, r)),
                   int_of(vpi_handle(vpiRightRange, r)));
        first = 0;
    }
    vpi_printf("\n");
    n = elements("pav", pav, top_list);
    sub = pick(top_list, n, "pav[1]");
    describe("pav[1]", sub, pav, "pav", SHOW_SU | SHOW_PA | SHOW_IDX);
    n = elements("pav[1]", sub, sub_list);
    describe("pav[1][2]", pick(sub_list, n, "pav[1][2]"), pav, "pav", SHOW_PA | SHOW_IDX);

    it = vpi_iterate(vpiMember, rv);
    while (it && (r = vpi_scan(it)) != NULL) {
        PLI_BYTE8 *s = vpi_get_str(vpiName, r);
        if (s && strcmp(s, "pp") == 0)
            pp = r;
    }
    describe("rv.pp", pp, rv, "rv", SHOW_SU);
    n = elements("rv.pp", pp, pp_list);
    describe("rv.pp[1]", pick(pp_list, n, "pp[1]"), pp, "rv.pp",
             SHOW_SU | SHOW_PA | SHOW_IDX);
    return 0;
}

static void register_all(void)
{
    s_vpi_systf_data d;
    memset(&d, 0, sizeof d);
    d.type = vpiSysTask;
    d.tfname = (PLI_BYTE8 *)"$vt_levels";
    d.calltf = levels_calltf;
    vpi_register_systf(&d);
}

void (*vlog_startup_routines[])(void) = {register_all, 0};

#ifdef __cplusplus
}
#endif
