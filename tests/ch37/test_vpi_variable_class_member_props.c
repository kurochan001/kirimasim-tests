/* VPI application of test_vpi_variable_class_member_props (IEEE 1800-2023 37.17). */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "sv_vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

#define TOP "test_vpi_variable_class_member_props"

static vpiHandle child(PLI_INT32 rel, vpiHandle ref, const char *name)
{
    vpiHandle it = ref ? vpi_iterate(rel, ref) : NULL, h, found = NULL;
    while (it != NULL && (h = vpi_scan(it)) != NULL) {
        PLI_BYTE8 *n = vpi_get_str(vpiName, h);
        if (found == NULL && n != NULL && strcmp(n, name) == 0)
            found = h;
    }
    return found;
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

static const char *visibility(vpiHandle h)
{
    switch (vpi_get(vpiVisibility, h)) {
    case vpiPublicVis: return "public";
    case vpiProtectedVis: return "protected";
    case vpiLocalVis: return "local";
    default: return "undefined";
    }
}

static const char *scheme(vpiHandle h)
{
    switch (vpi_get(vpiAllocScheme, h)) {
    case vpiAutomaticScheme: return "automatic";
    case vpiDynamicScheme: return "dynamic";
    case vpiOtherScheme: return "other";
    default: return "undefined";
    }
}

static PLI_INT32 props_calltf(PLI_BYTE8 *user_data)
{
    vpiHandle top = vpi_handle_by_name((PLI_BYTE8 *)TOP, NULL);
    vpiHandle defn = child(vpiClassDefn, top, "rc_c");
    vpiHandle o = vpi_handle_by_name((PLI_BYTE8 *)TOP ".o", NULL);
    vpiHandle obj = o ? vpi_handle(vpiClassObj, o) : NULL;
    vpiHandle mv = vpi_handle_by_name((PLI_BYTE8 *)TOP ".mv", NULL);
    vpiHandle mc = vpi_handle_by_name((PLI_BYTE8 *)TOP ".mc", NULL);
    static const char *const names[] = {"ra", "rc", "plain", "lo", "pr", "st", "cp"};
    vpiHandle h;
    int i;

    (void)user_data;
    if (defn == NULL || obj == NULL || mv == NULL || mc == NULL) {
        vpi_printf("not found\n");
        return 0;
    }
    for (i = 0; i < (int)(sizeof names / sizeof names[0]); i++) {
        h = child(vpiVariables, defn, names[i]);
        if (h == NULL) {
            vpi_printf("rc_c::%s: not found\n", names[i]);
            continue;
        }
        vpi_printf("rc_c::%s: rand type %s, visibility %s, constant variable %d\n", names[i],
                   rand_type(h), visibility(h), (int)vpi_get(vpiConstantVariable, h));
    }
    vpi_printf("mv: visibility %s, constant variable %d, alloc scheme %s\n", visibility(mv),
               (int)vpi_get(vpiConstantVariable, mv), scheme(mv));
    vpi_printf("mc: constant variable %d\n", (int)vpi_get(vpiConstantVariable, mc));

    h = child(vpiVariables, obj, "ra");
    vpi_printf("o.ra: %s, randomized %d, alloc scheme %s\n", h ? "found" : "NULL",
               h ? (int)vpi_get(vpiIsRandomized, h) : -1, h ? scheme(h) : "-");
    h = child(vpiVariables, obj, "rc");
    vpi_printf("o.rc: %s, randomized %d, rand type %s\n", h ? "found" : "NULL",
               h ? (int)vpi_get(vpiIsRandomized, h) : -1, h ? rand_type(h) : "-");
    h = child(vpiVariables, obj, "plain");
    vpi_printf("o.plain: %s, randomized %d, rand type %s, alloc scheme %s\n", h ? "found" : "NULL",
               h ? (int)vpi_get(vpiIsRandomized, h) : -1, h ? rand_type(h) : "-",
               h ? scheme(h) : "-");
    h = child(vpiVariables, obj, "st");
    vpi_printf("o.st: %s, alloc scheme %s\n", h ? "found" : "NULL", h ? scheme(h) : "-");
    return 0;
}

static void register_all(void)
{
    s_vpi_systf_data d;
    memset(&d, 0, sizeof d);
    d.type = vpiSysTask;
    d.tfname = (PLI_BYTE8 *)"$vt_props";
    d.calltf = props_calltf;
    vpi_register_systf(&d);
}

void (*vlog_startup_routines[])(void) = {register_all, 0};

#ifdef __cplusplus
}
#endif
