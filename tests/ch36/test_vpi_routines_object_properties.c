/* VPI application of test_vpi_routines_object_properties (IEEE 1800-2023 36.11, Table 36-4). */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "vpi_user.h"
#include "sv_vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

#define TOP "test_vpi_routines_object_properties"

/* vpi_get_str uses one buffer for every call (38.11), so each string is copied. */
static const char *str_prop(PLI_INT32 prop, vpiHandle obj, char *buf, size_t size)
{
    const char *s = vpi_get_str(prop, obj);
    snprintf(buf, size, "%s", s ? s : "NULL");
    return buf;
}

/* vpiObjId of a class variable, or vpiUndefined when it cannot be had. */
static PLI_INT64 obj_id(const char *name)
{
    char full[96];
    vpiHandle var;
    snprintf(full, sizeof full, "%s.%s", TOP, name);
    var = vpi_handle_by_name(full, NULL);
    return var == NULL ? vpiUndefined : vpi_get64(vpiObjId, var);
}

static PLI_INT32 at_one(p_cb_data data)
{
    vpiHandle sv = vpi_handle_by_name((PLI_BYTE8 *)TOP ".sv", NULL);
    vpiHandle u = vpi_handle_by_name((PLI_BYTE8 *)TOP ".u", NULL);
    vpiHandle u1 = vpi_handle_by_name((PLI_BYTE8 *)TOP ".u1", NULL);
    PLI_INT64 id_a, id_b, id_c, id_n;
    char a[96], b[96], c[96];

    (void)data;
    if (sv == NULL || u == NULL || u1 == NULL) {
        vpi_printf("objects not found\n");
        return 0;
    }
    vpi_printf("vpi_get: vpiSize of sv %d, vpiSigned of sv %d, vpiSigned of u %d, "
               "vpiVector of sv %d, vpiScalar of sv %d, vpiScalar of u %d\n",
               (int)vpi_get(vpiSize, sv), (int)vpi_get(vpiSigned, sv),
               (int)vpi_get(vpiSigned, u), (int)vpi_get(vpiVector, sv),
               (int)vpi_get(vpiScalar, sv), (int)vpi_get(vpiScalar, u));
    id_a = obj_id("a");
    id_b = obj_id("b");
    id_c = obj_id("c");
    id_n = obj_id("n");
    vpi_printf("vpi_get64: vpiObjId of a and b equal %d, nonzero %d, of c different %d, "
               "of n %lld, PLI_INT64 of %d bytes\n", id_a == id_b,
               id_a != 0 && id_a != vpiUndefined,
               id_c != id_a && id_c != 0 && id_c != vpiUndefined, (long long)id_n,
               (int)sizeof id_a);
    str_prop(vpiName, sv, a, sizeof a);
    str_prop(vpiFullName, sv, b, sizeof b);
    vpi_printf("vpi_get_str: vpiName of sv %s, vpiFullName of sv %s\n", a, b);
    str_prop(vpiName, u1, a, sizeof a);
    str_prop(vpiFullName, u1, b, sizeof b);
    str_prop(vpiDefName, u1, c, sizeof c);
    vpi_printf("vpi_get_str: vpiName of u1 %s, vpiFullName of u1 %s, vpiDefName of u1 %s\n",
               a, b, c);
    return 0;
}

static PLI_INT32 on_start(p_cb_data data)
{
    static s_vpi_time one;
    s_cb_data d;

    (void)data;
    one.type = vpiSimTime;
    one.high = 0;
    one.low = 1;
    memset(&d, 0, sizeof d);
    d.reason = cbAfterDelay;
    d.cb_rtn = at_one;
    d.time = &one;
    vpi_register_cb(&d);
    return 0;
}

static void register_start(void)
{
    s_cb_data d;
    memset(&d, 0, sizeof d);
    d.reason = cbStartOfSimulation;
    d.cb_rtn = on_start;
    vpi_register_cb(&d);
}

void (*vlog_startup_routines[])(void) = {register_start, 0};

#ifdef __cplusplus
}
#endif
