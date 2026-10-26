/* VPI application of test_vpi_class_internal_scopes (IEEE 1800-2023 37.31, 37.32, 37.33). */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "vpi_user.h"
#include "sv_vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

#define TOP "test_vpi_class_internal_scopes"
#define MAX 8

static const char *sprop(PLI_INT32 property, vpiHandle h)
{
    PLI_BYTE8 *s = h != NULL ? vpi_get_str(property, h) : NULL;
    return s != NULL ? s : "(none)";
}

static int by_text(const void *a, const void *b)
{
    return strcmp(*(const char *const *)a, *(const char *const *)b);
}

/* Collects the internal scopes of owner, sorted, and prints each one and
   whether relation back gives owner. */
static void scopes(const char *label, vpiHandle owner, PLI_INT32 relation)
{
    vpiHandle it = owner != NULL ? vpi_iterate(vpiInternalScope, owner) : NULL, h;
    const char *names[MAX];
    vpiHandle handles[MAX];
    char storage[MAX][48];
    int n = 0, i, j;

    for (i = 0; i < MAX; i++)
        names[i] = NULL;
    while (it != NULL && (h = vpi_scan(it)) != NULL && n < MAX) {
        snprintf(storage[n], sizeof storage[0], "%s (%s)", sprop(vpiName, h),
                 sprop(vpiType, h));
        names[n] = storage[n];
        handles[n++] = h;
    }
    for (i = 0; i < n; i++)
        for (j = i + 1; j < n; j++)
            if (by_text(&names[i], &names[j]) > 0) {
                const char *t = names[i];
                vpiHandle th = handles[i];
                names[i] = names[j];
                handles[i] = handles[j];
                names[j] = t;
                handles[j] = th;
            }
    vpi_printf((PLI_BYTE8 *)"%s: internal scopes", label);
    for (i = 0; i < n; i++)
        vpi_printf((PLI_BYTE8 *)"%s%s", i ? ", " : " ", names[i]);
    vpi_printf((PLI_BYTE8 *)"%s\n", n ? "" : " none");
    for (i = 0; i < n; i++) {
        if (relation != 0) {
            vpiHandle back = vpi_handle(relation, handles[i]);
            vpi_printf((PLI_BYTE8 *)"    %s: back to class %d\n", names[i],
                       back != NULL && owner != NULL && vpi_compare_objects(back, owner));
        } else {
            vpi_printf((PLI_BYTE8 *)"    %s: type %s\n", names[i],
                       sprop(vpiType, handles[i]));
        }
    }
}

static PLI_INT32 classscope_calltf(PLI_BYTE8 *user_data)
{
    vpiHandle it = vpi_iterate(vpiClassDefn, NULL), cls = NULL, h;
    vpiHandle var, spec, obj, scope_handle, top;

    (void)user_data;
    while (it != NULL && (h = vpi_scan(it)) != NULL)
        if (strcmp(sprop(vpiName, h), "cs_c") == 0) {
            cls = h;
            break;
        }
    top = vpi_handle_by_name((PLI_BYTE8 *)TOP, NULL);
    scope_handle = cls != NULL ? vpi_handle(vpiScope, cls) : NULL;
    vpi_printf((PLI_BYTE8 *)"class definition cs_c: scope is top %d\n",
               scope_handle != NULL && top != NULL
               && vpi_compare_objects(scope_handle, top));
    scopes("class definition cs_c", cls, vpiClassDefn);

    var = vpi_handle_by_name((PLI_BYTE8 *)TOP ".obj", NULL);
    spec = var != NULL ? vpi_handle(vpiTypespec, var) : NULL;
    scopes("d typespec", spec, vpiClassTypespec);

    obj = var != NULL ? vpi_handle(vpiClassObj, var) : NULL;
    scopes("class object", obj, 0);
    return 0;
}

static void register_all(void)
{
    s_vpi_systf_data d;
    memset(&d, 0, sizeof d);
    d.type = vpiSysTask;
    d.tfname = (PLI_BYTE8 *)"$vt_classscope";
    d.calltf = classscope_calltf;
    vpi_register_systf(&d);
}

void (*vlog_startup_routines[])(void) = {register_all, 0};

#ifdef __cplusplus
}
#endif
