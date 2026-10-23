/* VPI application of test_vpi_import_referenced_items (IEEE 1800-2023 37.12). */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "sv_vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

#define MAX 12

struct item {
    char *name;
    vpiHandle h;
};

static int by_name(const void *a, const void *b)
{
    return strcmp(((const struct item *)a)->name, ((const struct item *)b)->name);
}

/* vpi_get_str reuses its buffer (38.11), so every string is copied. */
static char *copy(PLI_BYTE8 *s)
{
    const char *t = s ? s : "(null)";
    char *c = (char *)malloc(strlen(t) + 1);
    strcpy(c, t);
    return c;
}

static PLI_INT32 imports_calltf(PLI_BYTE8 *user_data)
{
    vpiHandle top = vpi_handle_by_name((PLI_BYTE8 *)"test_vpi_import_referenced_items", NULL);
    vpiHandle it = top ? vpi_iterate(vpiImport, top) : NULL, h;
    struct item list[MAX];
    int n = 0, i;

    (void)user_data;
    while (it && (h = vpi_scan(it)) != NULL) {
        if (n == MAX)
            continue;
        list[n].name = copy(vpi_get_str(vpiName, h));
        list[n++].h = h;
    }
    qsort(list, n, sizeof list[0], by_name);
    vpi_printf("imported items: %d\n", n);
    for (i = 0; i < n; i++) {
        h = list[i].h;
        vpi_printf("%s: ", list[i].name);
        switch (vpi_get(vpiType, h)) {
        case vpiIntVar:
            vpi_printf("variable %s\n", copy(vpi_get_str(vpiFullName, h)));
            break;
        case vpiParameter: vpi_printf("parameter\n"); break;
        case vpiFunction: vpi_printf("function\n"); break;
        case vpiTask: vpi_printf("task\n"); break;
        case vpiNamedEvent: vpi_printf("named event\n"); break;
        case vpiLogicTypespec: vpi_printf("typespec\n"); break;
        default: vpi_printf("other type\n"); break;
        }
    }
    return 0;
}

static void register_all(void)
{
    s_vpi_systf_data d;
    memset(&d, 0, sizeof d);
    d.type = vpiSysTask;
    d.tfname = (PLI_BYTE8 *)"$vt_imports";
    d.calltf = imports_calltf;
    vpi_register_systf(&d);
}

void (*vlog_startup_routines[])(void) = {register_all, 0};

#ifdef __cplusplus
}
#endif
