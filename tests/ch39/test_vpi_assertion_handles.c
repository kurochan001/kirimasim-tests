/* VPI application of test_vpi_assertion_handles (IEEE 1800-2023 39.3). */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "sv_vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

#define TOP "test_vpi_assertion_handles"
#define MAX 16

struct named {
    char *full;
    vpiHandle h;
};

/* vpi_get_str reuses one buffer (38.11), so each string is copied. */
static char *str_of(PLI_INT32 prop, vpiHandle h)
{
    PLI_BYTE8 *s = h ? vpi_get_str(prop, h) : NULL;
    char *copy;
    if (s == NULL)
        return NULL;
    copy = (char *)malloc(strlen(s) + 1);
    strcpy(copy, s);
    return copy;
}

static const char *type_name(vpiHandle h)
{
    switch (vpi_get(vpiType, h)) {
    case vpiAssert: return "assert";
    case vpiAssume: return "assume";
    case vpiCover: return "cover";
    case vpiRestrict: return "restrict";
    default: return "other type";
    }
}

static int is_label(const char *name)
{
    return name && (strcmp(name, "a_req") == 0 || strcmp(name, "m_ack") == 0
                    || strcmp(name, "r_req") == 0 || strcmp(name, "c_ack") == 0);
}

static int by_full_name(const void *a, const void *b)
{
    return strcmp(((const struct named *)a)->full, ((const struct named *)b)->full);
}

static void describe(vpiHandle h)
{
    char *name = str_of(vpiName, h), *full = str_of(vpiFullName, h);
    char *file = str_of(vpiFile, h);
    vpiHandle inst = vpi_handle(vpiInstance, h);
    char *inst_name = str_of(vpiFullName, inst), *def = str_of(vpiDefName, inst);
    const char *base = file ? strrchr(file, '/') : NULL;

    vpi_printf("%s: %s, name %s, line %d, file %s\n", full ? full : "(null)", type_name(h),
               name ? name : "(null)", (int)vpi_get(vpiStartLine, h),
               base ? base + 1 : (file ? file : "(null)"));
    vpi_printf("  instance %s of module %s, clock inferred %d\n",
               inst_name ? inst_name : "(null)", def ? def : "(null)",
               (int)vpi_get(vpiIsClockInferred, h));
}

static PLI_INT32 assertions_calltf(PLI_BYTE8 *user_data)
{
    struct named list[MAX];
    int n = 0, others = 0, i;
    vpiHandle it, h, top, leaf, by_name;

    (void)user_data;
    it = vpi_iterate(vpiAssertion, NULL);
    while (it && (h = vpi_scan(it)) != NULL) {
        char *name = str_of(vpiName, h);
        if (is_label(name) && n < MAX) {
            list[n].full = str_of(vpiFullName, h);
            if (list[n].full == NULL)
                list[n].full = name;
            list[n].h = h;
            n++;
        } else {
            others++;
            vpi_printf("unnamed assertion: %s\n", type_name(h));
        }
    }
    qsort(list, n, sizeof list[0], by_full_name);
    vpi_printf("all assertions: %d named, %d unnamed\n", n, others);
    for (i = 0; i < n; i++)
        describe(list[i].h);

    leaf = vpi_handle_by_name((PLI_BYTE8 *)TOP ".u", NULL);
    n = 0;
    it = leaf ? vpi_iterate(vpiAssertion, leaf) : NULL;
    while (it && (h = vpi_scan(it)) != NULL) {
        char *name = str_of(vpiName, h);
        vpi_printf("assertion of u: %s (%s)\n", name ? name : "(null)", type_name(h));
        n++;
    }
    vpi_printf("assertions of u: %d\n", n);

    by_name = vpi_handle_by_name((PLI_BYTE8 *)TOP ".u.c_ack", NULL);
    vpi_printf("by full name %s.u.c_ack: %s\n", TOP, by_name ? type_name(by_name) : "not found");
    top = vpi_handle_by_name((PLI_BYTE8 *)TOP, NULL);
    by_name = top ? vpi_handle_by_name((PLI_BYTE8 *)"a_req", top) : NULL;
    if (by_name) {
        char *full = str_of(vpiFullName, by_name);
        vpi_printf("by name a_req in %s: %s %s\n", TOP, type_name(by_name), full ? full : "(null)");
    } else {
        vpi_printf("by name a_req in %s: not found\n", TOP);
    }
    return 0;
}

static void register_all(void)
{
    s_vpi_systf_data d;
    memset(&d, 0, sizeof d);
    d.type = vpiSysTask;
    d.tfname = (PLI_BYTE8 *)"$vt_assertions";
    d.calltf = assertions_calltf;
    vpi_register_systf(&d);
}

void (*vlog_startup_routines[])(void) = {register_all, 0};

#ifdef __cplusplus
}
#endif
