/* VPI application of test_vpi_type_constants_more (IEEE 1800-2023 37.3.2,
 * 37.3.6). */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "sv_vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

#define TOP "test_vpi_type_constants_more"

static vpiHandle by_name(const char *name)
{
    char full[96];
    snprintf(full, sizeof full, "%s%s", TOP, name);
    return vpi_handle_by_name((PLI_BYTE8 *)full, NULL);
}

static vpiHandle first(PLI_INT32 type, vpiHandle ref)
{
    vpiHandle it = ref ? vpi_iterate(type, ref) : NULL, h = NULL;
    if (it != NULL && (h = vpi_scan(it)) != NULL)
        vpi_release_handle(it);
    return h;
}

/* The type string of h, whether vpi_get(vpiType) is the constant expected for
 * that kind of object, and vpiIsProtected. */
static void type_of(const char *label, vpiHandle h, PLI_INT32 expected)
{
    PLI_BYTE8 *s;
    if (h == NULL) {
        vpi_printf((PLI_BYTE8 *)"%s: not found\n", label);
        return;
    }
    s = vpi_get_str(vpiType, h);
    vpi_printf((PLI_BYTE8 *)"%s: %s, vpi_get(vpiType) matches %d, protected %d\n", label,
               s ? s : "(null)", vpi_get(vpiType, h) == expected,
               (int)vpi_get(vpiIsProtected, h));
}

/* The string of an additional type property and whether vpi_get gives the
 * constant expected. */
static void subtype_of(const char *label, PLI_INT32 prop, vpiHandle h, PLI_INT32 expected)
{
    PLI_BYTE8 *s;
    if (h == NULL) {
        vpi_printf((PLI_BYTE8 *)"%s: not found\n", label);
        return;
    }
    s = vpi_get_str(prop, h);
    vpi_printf((PLI_BYTE8 *)"%s: %s, vpi_get matches %d\n", label, s ? s : "(null)",
               vpi_get(prop, h) == expected);
}

static PLI_INT32 never_called(p_cb_data data)
{
    (void)data;
    vpi_printf((PLI_BYTE8 *)"removed callback called\n");
    return 0;
}

static PLI_INT32 types_calltf(PLI_BYTE8 *user_data)
{
    vpiHandle call = vpi_handle(vpiSysTfCall, NULL), it, arg[4], cb, tchk;
    vpiHandle ga = by_name(".ga"), gb = by_name(".gb"), lu = by_name(".lu");
    s_cb_data d;
    s_vpi_time t;
    int n = 0;

    (void)user_data;
    type_of("port of u", first(vpiPort, by_name(".u")), vpiPort);
    type_of("fk", by_name(".fk"), vpiNamedFork);
    type_of("call of $vt_types", call, vpiSysTaskCall);
    type_of("its user systf", call ? vpi_handle(vpiUserSystf, call) : NULL, vpiUserSystf);
    it = call ? vpi_iterate(vpiArgument, call) : NULL;
    type_of("argument iterator", it, vpiIterator);
    while (it != NULL && (arg[n] = vpi_scan(it)) != NULL)
        if (++n == 4) {
            vpi_release_handle(it);
            break;
        }
    while (n < 4)
        arg[n++] = NULL;
    type_of("argument $time", arg[0], vpiSysFuncCall);
    type_of("argument 5", arg[1], vpiConstant);
    type_of("argument r[3:1]", arg[2], vpiPartSelect);
    type_of("argument a2 + b2", arg[3], vpiOperation);
    memset(&d, 0, sizeof d);
    t.type = vpiSimTime;
    t.high = 0;
    t.low = 100;
    d.reason = cbAfterDelay;
    d.cb_rtn = never_called;
    d.time = &t;
    cb = vpi_register_cb(&d);
    type_of("callback", cb, vpiCallback);
    if (cb != NULL)
        vpi_remove_cb(cb);
    type_of("g", by_name(".g"), vpiGenScopeArray);
    type_of("g[1]", by_name(".g[1]"), vpiGenScope);
    type_of("ga", ga, vpiGate);
    type_of("lu", lu, vpiUdp);
    type_of("definition of lu", lu ? vpi_handle(vpiUdpDefn, lu) : NULL, vpiUdpDefn);
    type_of("terminal of ga", first(vpiPrimTerm, ga), vpiPrimTerm);
    type_of("continuous assignment", first(vpiContAssign, by_name("")), vpiContAssign);
    tchk = first(vpiTchk, by_name(".u"));
    type_of("timing check of u", tchk, vpiTchk);
    type_of("its reference term", tchk ? vpi_handle(vpiTchkRefTerm, tchk) : NULL, vpiTchkTerm);
    subtype_of("ga primitive type", vpiPrimType, ga, vpiAndPrim);
    subtype_of("gb primitive type", vpiPrimType, gb, vpiBufif1Prim);
    subtype_of("definition of lu primitive type", vpiPrimType,
               lu ? vpi_handle(vpiUdpDefn, lu) : NULL, vpiSeqPrim);
    subtype_of("a2 + b2 operation type", vpiOpType, arg[3], vpiAddOp);
    subtype_of("timing check type", vpiTchkType, tchk, vpiSetup);
    return 0;
}

static void register_all(void)
{
    s_vpi_systf_data d;
    memset(&d, 0, sizeof d);
    d.type = vpiSysTask;
    d.tfname = (PLI_BYTE8 *)"$vt_types";
    d.calltf = types_calltf;
    vpi_register_systf(&d);
}

void (*vlog_startup_routines[])(void) = {register_all, 0};

#ifdef __cplusplus
}
#endif
