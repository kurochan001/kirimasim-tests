/* VPI application of test_vpi_var_bit_parents (IEEE 1800-2023 37.17). */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "sv_vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

#define TOP "test_vpi_var_bit_parents"
#define MAX 16

struct item {
    char *name;
    vpiHandle h;
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

static int int_value(vpiHandle h)
{
    s_vpi_value v;
    v.format = vpiIntVal;
    vpi_get_value(h, &v);
    return (int)v.value.integer;
}

static int same(vpiHandle a, vpiHandle b)
{
    return a != NULL && b != NULL && vpi_compare_objects(a, b) ? 1 : 0;
}

/* Returns -1 when vpi_iterate(vpiBit) is NULL. */
static int bits(vpiHandle var, struct item *list)
{
    vpiHandle it = var ? vpi_iterate(vpiBit, var) : NULL, h;
    int n = 0;
    if (it == NULL)
        return -1;
    while ((h = vpi_scan(it)) != NULL) {
        if (n == MAX)
            continue;
        list[n].name = copy(vpi_get_str(vpiName, h));
        list[n++].h = h;
    }
    qsort(list, n, sizeof list[0], by_name);
    return n;
}

static void each_bit(const char *name)
{
    vpiHandle var = find(name), x;
    struct item list[MAX];
    int n = bits(var, list), i;

    vpi_printf("bits of %s (%d):\n", name, n);
    for (i = 0; i < n; i++) {
        x = vpi_handle(vpiIndex, list[i].h);
        vpi_printf("  %s: var bit %d, size %d, index %d, value %d, parent is %s %d\n",
                   list[i].name, vpi_get(vpiType, list[i].h) == vpiVarBit ? 1 : 0,
                   (int)vpi_get(vpiSize, list[i].h), x ? int_value(x) : -1,
                   int_value(list[i].h), name, same(vpi_handle(vpiParent, list[i].h), var));
    }
}

static void none(const char *name)
{
    struct item list[MAX];
    int n = bits(find(name), list);
    if (n < 0)
        vpi_printf("bits of %s: NULL\n", name);
    else
        vpi_printf("bits of %s: %d\n", name, n);
}

static void constant_selects(const char *label, vpiHandle var)
{
    struct item list[MAX];
    int n = bits(var, list), i;
    vpi_printf("constant select of the bits of %s:", label);
    for (i = 0; i < n; i++)
        vpi_printf(" %d", (int)vpi_get(vpiConstantSelect, list[i].h));
    vpi_printf(" (%d bits)\n", n);
}

static PLI_INT32 bits_calltf(PLI_BYTE8 *user_data)
{
    vpiHandle m2 = find("m2"), pe = find("pe"), dl = find("dl"), x, it;
    struct item list[MAX];
    int n, i, var_bits = 0, parent_pe = 0;

    (void)user_data;
    if (m2 == NULL || pe == NULL || dl == NULL) {
        vpi_printf("not found\n");
        return 0;
    }
    each_bit("lv");
    each_bit("bv");
    each_bit("sv");
    each_bit("uv");

    n = bits(m2, list);
    vpi_printf("bits of m2 (%d):", n);
    for (i = 0; i < n; i++)
        vpi_printf(" %s", list[i].name);
    vpi_printf("\n");
    for (i = 0; i < n; i++)
        if (strcmp(list[i].name, "m2[1][2]") == 0) {
            x = vpi_handle(vpiIndex, list[i].h);
            vpi_printf("  m2[1][2]: size %d, value %d, index %d, indices",
                       (int)vpi_get(vpiSize, list[i].h), int_value(list[i].h),
                       x ? int_value(x) : -1);
            it = vpi_iterate(vpiIndex, list[i].h);
            if (it == NULL)
                vpi_printf(" NULL");
            while (it != NULL && (x = vpi_scan(it)) != NULL)
                vpi_printf(" %d", int_value(x));
            vpi_printf(", parent is m2 %d\n", same(vpi_handle(vpiParent, list[i].h), m2));
        }

    n = bits(pe, list);
    for (i = 0; i < n; i++) {
        if (vpi_get(vpiType, list[i].h) == vpiVarBit)
            var_bits++;
        if (same(vpi_handle(vpiParent, list[i].h), pe))
            parent_pe++;
    }
    vpi_printf("bits of pe: %d, var bits %d, with pe as parent %d\n", n, var_bits, parent_pe);

    none("iv");
    none("rv");
    none("st");

    constant_selects("lv", find("lv"));
    constant_selects("dl[0]", vpi_handle_by_index(dl, 0));
    return 0;
}

static void register_all(void)
{
    s_vpi_systf_data d;
    memset(&d, 0, sizeof d);
    d.type = vpiSysTask;
    d.tfname = (PLI_BYTE8 *)"$vt_bits";
    d.calltf = bits_calltf;
    vpi_register_systf(&d);
}

void (*vlog_startup_routines[])(void) = {register_all, 0};

#ifdef __cplusplus
}
#endif
