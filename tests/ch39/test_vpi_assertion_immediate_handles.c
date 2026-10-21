/* VPI application of test_vpi_assertion_immediate_handles (IEEE 1800-2023 39.3). */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "sv_vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

#define MAX 8

struct item {
    char *name;
    const char *kind;
};

static const char *kind_of(PLI_INT32 type)
{
    switch (type) {
    case vpiImmediateAssert: return "immediate assert";
    case vpiImmediateAssume: return "immediate assume";
    case vpiImmediateCover: return "immediate cover";
    default: return NULL;
    }
}

static int by_name(const void *pa, const void *pb)
{
    return strcmp(((const struct item *)pa)->name, ((const struct item *)pb)->name);
}

static PLI_INT32 list_calltf(PLI_BYTE8 *user_data)
{
    struct item items[MAX];
    int n = 0, i;
    vpiHandle it, a;

    (void)user_data;
    it = vpi_iterate(vpiAssertion, NULL);
    while (it != NULL && (a = vpi_scan(it)) != NULL) {
        const char *kind = kind_of(vpi_get(vpiType, a));
        PLI_BYTE8 *name;
        if (kind == NULL || n == MAX)
            continue;
        name = vpi_get_str(vpiName, a);
        if (name == NULL)
            continue;
        items[n].name = (char *)malloc(strlen(name) + 1);
        strcpy(items[n].name, name);
        items[n].kind = kind;
        n++;
    }
    qsort(items, n, sizeof items[0], by_name);
    for (i = 0; i < n; i++) {
        vpi_printf("%s: %s\n", items[i].name, items[i].kind);
        free(items[i].name);
    }
    vpi_printf("immediate assertions: %d\n", n);
    return 0;
}

static void register_all(void)
{
    s_vpi_systf_data d;

    memset(&d, 0, sizeof d);
    d.type = vpiSysTask;
    d.tfname = (PLI_BYTE8 *)"$vt_list";
    d.calltf = list_calltf;
    vpi_register_systf(&d);
}

void (*vlog_startup_routines[])(void) = {register_all, 0};

#ifdef __cplusplus
}
#endif
