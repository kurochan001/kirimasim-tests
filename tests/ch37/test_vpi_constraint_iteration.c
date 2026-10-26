/* VPI application of test_vpi_constraint_iteration (IEEE 1800-2023 37.31, 37.32, 37.34). */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "vpi_user.h"
#include "sv_vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

#define TOP "test_vpi_constraint_iteration"
#define MAX 16

static const char *sprop(PLI_INT32 property, vpiHandle h)
{
    PLI_BYTE8 *s = h != NULL ? vpi_get_str(property, h) : NULL;
    return s != NULL ? s : "(none)";
}

static vpiHandle find_class(const char *name)
{
    vpiHandle it = vpi_iterate(vpiClassDefn, NULL), h;

    while (it != NULL && (h = vpi_scan(it)) != NULL)
        if (strcmp(sprop(vpiName, h), name) == 0) {
            vpi_release_handle(it);
            return h;
        }
    return NULL;
}

/* Prints the constraints of an object in iteration order. */
static void list(const char *label, vpiHandle owner)
{
    vpiHandle it = owner != NULL ? vpi_iterate(vpiConstraint, owner) : NULL, c;

    vpi_printf((PLI_BYTE8 *)"%s:", label);
    if (it == NULL)
        vpi_printf((PLI_BYTE8 *)" none");
    else
        while ((c = vpi_scan(it)) != NULL)
            vpi_printf((PLI_BYTE8 *)" %s", sprop(vpiName, c));
    vpi_printf((PLI_BYTE8 *)"\n");
}

static int by_text(const void *a, const void *b)
{
    return strcmp(*(const char *const *)a, *(const char *const *)b);
}

static PLI_INT32 con_calltf(PLI_BYTE8 *user_data)
{
    vpiHandle base = find_class("ci_base"), der = find_class("ci_der");
    vpiHandle var, spec, ext, base_spec;
    vpiHandle it, c;
    const char *names[MAX];
    char storage[MAX][48];
    int n = 0, i, j;

    (void)user_data;
    list("constraints of class ci_base", base);
    list("constraints of class ci_der", der);

    var = vpi_handle_by_name((PLI_BYTE8 *)TOP ".d", NULL);
    spec = var != NULL ? vpi_handle(vpiTypespec, var) : NULL;
    list("constraints of d typespec", spec);
    ext = spec != NULL ? vpi_handle(vpiExtends, spec) : NULL;
    base_spec = ext != NULL ? vpi_handle(vpiClassTypespec, ext) : NULL;
    list("constraints of its base typespec", base_spec);

    it = vpi_iterate(vpiConstraint, NULL);
    while (it != NULL && (c = vpi_scan(it)) != NULL && n < MAX) {
        snprintf(storage[n], sizeof storage[0], "%s", sprop(vpiName, c));
        names[n] = storage[n];
        n++;
    }
    for (i = 0; i < n; i++)
        for (j = i + 1; j < n; j++)
            if (by_text(&names[i], &names[j]) > 0) {
                const char *t = names[i];
                names[i] = names[j];
                names[j] = t;
            }
    vpi_printf((PLI_BYTE8 *)"constraints from NULL root: %d (", n);
    for (i = 0; i < n; i++)
        vpi_printf((PLI_BYTE8 *)"%s%s", i ? "," : "", names[i]);
    vpi_printf((PLI_BYTE8 *)")\n");
    return 0;
}

static void register_all(void)
{
    s_vpi_systf_data d;
    memset(&d, 0, sizeof d);
    d.type = vpiSysTask;
    d.tfname = (PLI_BYTE8 *)"$vt_con";
    d.calltf = con_calltf;
    vpi_register_systf(&d);
}

void (*vlog_startup_routines[])(void) = {register_all, 0};

#ifdef __cplusplus
}
#endif
