/* VPI application of test_vpi_named_event_array_prefix (IEEE 1800-2023 37.61). */
#include <stdio.h>
#include <string.h>
#include "vpi_user.h"
#include "sv_vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

#define TOP "test_vpi_named_event_array_prefix"

static const char *name_of(vpiHandle h)
{
    const char *s = h != NULL ? vpi_get_str(vpiName, h) : NULL;
    return s != NULL ? s : "NULL";
}

static const char *kind_of(vpiHandle h)
{
    if (h == NULL)
        return "NULL";
    switch (vpi_get(vpiType, h)) {
    case vpiNamedEventArray: return "named event array";
    case vpiClassVar: return "class var";
    default: {
        const char *s = vpi_get_str(vpiType, h);
        return s != NULL ? s : "other";
    }
    }
}

static void show(const char *label, vpiHandle e)
{
    vpiHandle p = e != NULL ? vpi_handle(vpiPrefix, e) : NULL;

    vpi_printf((PLI_BYTE8 *)"%s: %s, prefix %s %s, has actual %d\n", label, kind_of(e),
               kind_of(p), name_of(p), e != NULL ? (int)vpi_get(vpiHasActual, e) : -1);
}

/* The typespec of the class variable c is a specialization (37.32
   detail 1), for which the vpiNamedEventArray iteration is supported. */
static vpiHandle class_typespec(void)
{
    vpiHandle c = vpi_handle_by_name((PLI_BYTE8 *)TOP ".c", NULL);

    return c != NULL ? vpi_handle(vpiTypespec, c) : NULL;
}

static PLI_INT32 ev_calltf(PLI_BYTE8 *user_data)
{
    vpiHandle e = vpi_handle_by_name((PLI_BYTE8 *)TOP ".c.e", NULL);
    vpiHandle ts = class_typespec();
    vpiHandle it = ts != NULL ? vpi_iterate(vpiNamedEventArray, ts) : NULL;
    vpiHandle f = it != NULL ? vpi_scan(it) : NULL;

    (void)user_data;
    show("c.e", e);
    show("typespec e", f);
    return 0;
}

static void register_all(void)
{
    s_vpi_systf_data d;

    memset(&d, 0, sizeof d);
    d.type = vpiSysTask;
    d.tfname = (PLI_BYTE8 *)"$vt_ev";
    d.calltf = ev_calltf;
    vpi_register_systf(&d);
}

void (*vlog_startup_routines[])(void) = {register_all, 0};

#ifdef __cplusplus
}
#endif
