/* VPI application of test_vpi_struct_union_flags_members (IEEE 1800-2023 37.25, 37.26). */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "sv_vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

#define TOP "test_vpi_struct_union_flags_members"
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

static const char *kind(vpiHandle h)
{
    if (h == NULL)
        return "NULL";
    switch (vpi_get(vpiType, h)) {
    case vpiStructVar: return "struct var";
    case vpiUnionVar: return "union var";
    case vpiStructTypespec: return "struct typespec";
    case vpiUnionTypespec: return "union typespec";
    case vpiIntTypespec: return "int typespec";
    case vpiBitTypespec: return "bit typespec";
    case vpiLogicTypespec: return "logic typespec";
    case vpiVoidTypespec: return "void typespec";
    default: return "other type";
    }
}

static const char *rand_type(vpiHandle h)
{
    switch (vpi_get(vpiRandType, h)) {
    case vpiRand: return "rand";
    case vpiRandC: return "randc";
    case vpiNotRand: return "not random";
    default: return "undefined";
    }
}

static void flags(const char *label, vpiHandle h)
{
    vpi_printf("%s: %s, tagged %d, soft %d, packed %d\n", label, kind(h),
               (int)vpi_get(vpiTagged, h), (int)vpi_get(vpiSoft, h), (int)vpi_get(vpiPacked, h));
}

static void members(const char *label, vpiHandle t, int with_rand)
{
    vpiHandle it = t ? vpi_iterate(vpiTypespecMember, t) : NULL, m, mt;
    struct item list[MAX];
    int n = 0, i;

    while (it != NULL && (m = vpi_scan(it)) != NULL) {
        if (n == MAX)
            continue;
        list[n].name = str(vpi_get_str(vpiName, m));
        list[n++].h = m;
    }
    qsort(list, n, sizeof list[0], by_name);
    vpi_printf("members of %s (%d):", label, n);
    for (i = 0; i < n; i++) {
        mt = vpi_handle(vpiTypespec, list[i].h);
        vpi_printf(" %s (%s", list[i].name, kind(mt));
        if (mt != NULL && vpi_get_str(vpiName, mt) != NULL)
            vpi_printf(" named %s", str(vpi_get_str(vpiName, mt)));
        if (with_rand)
            vpi_printf(", %s", rand_type(list[i].h));
        vpi_printf(")");
    }
    vpi_printf("\n");
}

static PLI_INT32 flags_calltf(PLI_BYTE8 *user_data)
{
    static const char *const vars[] = {"vsp", "vsu", "vup", "vut", "vus"};
    vpiHandle v[5];
    char full[128];
    int i;

    (void)user_data;
    for (i = 0; i < 5; i++) {
        snprintf(full, sizeof full, "%s.%s", TOP, vars[i]);
        v[i] = vpi_handle_by_name((PLI_BYTE8 *)full, NULL);
        if (v[i] == NULL) {
            vpi_printf("%s: not found\n", vars[i]);
            return 0;
        }
    }
    for (i = 0; i < 5; i++)
        flags(vars[i], v[i]);
    for (i = 0; i < 5; i++) {
        snprintf(full, sizeof full, "typespec of %s", vars[i]);
        flags(full, vpi_handle(vpiTypespec, v[i]));
    }
    members("su_t", vpi_handle(vpiTypespec, v[1]), 1);
    members("upk_t", vpi_handle(vpiTypespec, v[2]), 0);
    members("ut_t", vpi_handle(vpiTypespec, v[3]), 0);
    members("us_t", vpi_handle(vpiTypespec, v[4]), 0);
    return 0;
}

static void register_all(void)
{
    s_vpi_systf_data d;
    memset(&d, 0, sizeof d);
    d.type = vpiSysTask;
    d.tfname = (PLI_BYTE8 *)"$vt_flags";
    d.calltf = flags_calltf;
    vpi_register_systf(&d);
}

void (*vlog_startup_routines[])(void) = {register_all, 0};

#ifdef __cplusplus
}
#endif
