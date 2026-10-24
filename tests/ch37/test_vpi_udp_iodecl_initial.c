/* VPI application of test_vpi_udp_iodecl_initial (IEEE 1800-2023 37.36). */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "vpi_user.h"
#include "sv_vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

#define TOP "test_vpi_udp_iodecl_initial"
#define MAX 8
#define LEN 32

static int by_text(const void *x, const void *y)
{
    return strcmp((const char *)x, (const char *)y);
}

static const char *name_of(vpiHandle h)
{
    PLI_BYTE8 *s = h != NULL ? vpi_get_str(vpiName, h) : NULL;
    return s != NULL ? s : "(none)";
}

static void describe(const char *inst)
{
    char full[96], names[MAX][LEN], def[96];
    vpiHandle udp, defn, it, io, back, init, stmt, rhs;
    int n = 0, same = 0, i;
    s_vpi_value v;

    snprintf(full, sizeof full, "%s.%s", TOP, inst);
    udp = vpi_handle_by_name((PLI_BYTE8 *)full, NULL);
    defn = udp != NULL ? vpi_handle(vpiUdpDefn, udp) : NULL;
    if (defn == NULL) {
        vpi_printf((PLI_BYTE8 *)"%s: no UDP definition\n", inst);
        return;
    }
    snprintf(def, sizeof def, "%s", vpi_get_str(vpiDefName, defn));
    it = vpi_iterate(vpiIODecl, defn);
    while (it != NULL && (io = vpi_scan(it)) != NULL) {
        back = vpi_handle(vpiUdpDefn, io);
        if (back != NULL && vpi_compare_objects(back, defn))
            same++;
        if (n < MAX)
            snprintf(names[n], LEN, "%s", name_of(io));
        n++;
    }
    qsort(names, (size_t)(n < MAX ? n : MAX), LEN, by_text);
    vpi_printf((PLI_BYTE8 *)"%s (%s): io declarations", inst, def);
    for (i = 0; i < n && i < MAX; i++)
        vpi_printf((PLI_BYTE8 *)" %s", names[i]);
    vpi_printf((PLI_BYTE8 *)", leading back to this definition: %d of %d\n", same, n);

    init = vpi_handle(vpiInitial, defn);
    if (init == NULL) {
        vpi_printf((PLI_BYTE8 *)"%s: initial NULL\n", inst);
        return;
    }
    stmt = vpi_handle(vpiStmt, init);
    rhs = stmt != NULL ? vpi_handle(vpiRhs, stmt) : NULL;
    v.format = vpiIntVal;
    v.value.integer = -1;
    if (rhs != NULL)
        vpi_get_value(rhs, &v);
    vpi_printf((PLI_BYTE8 *)"%s: initial of type vpiInitial %d, statement an assignment %d, "
                            "value %d\n", inst, vpi_get(vpiType, init) == vpiInitial,
               stmt != NULL && vpi_get(vpiType, stmt) == vpiAssignment, (int)v.value.integer);
}

static PLI_INT32 udps_calltf(PLI_BYTE8 *user_data)
{
    (void)user_data;
    describe("u1");
    describe("u0");
    describe("ux");
    return 0;
}

static void register_all(void)
{
    s_vpi_systf_data d;
    memset(&d, 0, sizeof d);
    d.type = vpiSysTask;
    d.tfname = (PLI_BYTE8 *)"$vt_udps";
    d.calltf = udps_calltf;
    vpi_register_systf(&d);
}

void (*vlog_startup_routines[])(void) = {register_all, 0};

#ifdef __cplusplus
}
#endif
