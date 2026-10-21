/* VPI application of test_vpi_generate_scope_contents (IEEE 1800-2023 37.85). */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

#define TOP "test_vpi_generate_scope_contents"
#define MAX 8
#define LEN 96

struct entry {
    char text[LEN];
};

static int by_text(const void *a, const void *b)
{
    return strcmp(((const struct entry *)a)->text, ((const struct entry *)b)->text);
}

static int value_of(vpiHandle h)
{
    s_vpi_value v;
    v.format = vpiIntVal;
    vpi_get_value(h, &v);
    return (int)v.value.integer;
}

static void print_sorted(const char *label, struct entry *list, int n)
{
    int i;
    qsort(list, n, sizeof list[0], by_text);
    vpi_printf("%s:", label);
    for (i = 0; i < n; i++)
        vpi_printf("%s %s", i ? "," : "", list[i].text);
    vpi_printf("\n");
}

static void scopes(const char *label, vpiHandle ref)
{
    struct entry list[MAX];
    vpiHandle it = ref ? vpi_iterate(vpiInternalScope, ref) : NULL, h;
    int n = 0;

    while (it && (h = vpi_scan(it)) != NULL) {
        PLI_BYTE8 *s = vpi_get_str(vpiFullName, h);
        if (n < MAX)
            snprintf(list[n++].text, LEN, "%s gen scope %d", s ? s : "(null)",
                     vpi_get(vpiType, h) == vpiGenScope);
    }
    print_sorted(label, list, n);
}

static void parameters(const char *label, vpiHandle ref)
{
    struct entry list[MAX];
    vpiHandle it = ref ? vpi_iterate(vpiParameter, ref) : NULL, h;
    int n = 0;

    while (it && (h = vpi_scan(it)) != NULL) {
        PLI_BYTE8 *s = vpi_get_str(vpiName, h);
        if (n < MAX)
            snprintf(list[n++].text, LEN, "%s local %d = %d", s ? s : "(null)",
                     (int)vpi_get(vpiLocalParam, h), value_of(h));
    }
    print_sorted(label, list, n);
}

static vpiHandle find(const char *name)
{
    char full[LEN];
    vpiHandle h;
    snprintf(full, sizeof full, "%s%s", TOP, name);
    h = vpi_handle_by_name(full, NULL);
    if (h == NULL)
        vpi_printf("%s: not found\n", full);
    return h;
}

static PLI_INT32 gen_calltf(PLI_BYTE8 *user_data)
{
    vpiHandle x, scope;
    PLI_BYTE8 *s;

    (void)user_data;
    scopes("scopes in the module", find(""));
    scopes("scopes in outer[1]", find(".outer[1]"));
    parameters("parameters of outer[1]", find(".outer[1]"));
    parameters("parameters of outer[1].inner[2]", find(".outer[1].inner[2]"));
    parameters("parameters of cond", find(".cond"));
    x = find(".outer[1].inner[2].x");
    if (x != NULL) {
        vpi_printf("outer[1].inner[2].x: size %d\n", (int)vpi_get(vpiSize, x));
        scope = vpi_handle(vpiScope, x);
        s = scope ? vpi_get_str(vpiFullName, scope) : NULL;
        vpi_printf("its scope: %s\n", s ? s : "(none)");
    }
    return 0;
}

static void register_all(void)
{
    s_vpi_systf_data d;
    memset(&d, 0, sizeof d);
    d.type = vpiSysTask;
    d.tfname = (PLI_BYTE8 *)"$vt_gen";
    d.calltf = gen_calltf;
    vpi_register_systf(&d);
}

void (*vlog_startup_routines[])(void) = {register_all, 0};

#ifdef __cplusplus
}
#endif
