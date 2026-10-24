/* VPI application of test_vpi_class_object_members (IEEE 1800-2023 37.33). */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "vpi_user.h"
#include "sv_vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

#define TOP "test_vpi_class_object_members"
#define MAX 8
#define LEN 64

static int by_text(const void *x, const void *y)
{
    return strcmp((const char *)x, (const char *)y);
}

static const char *name_of(vpiHandle h)
{
    PLI_BYTE8 *s = h != NULL ? vpi_get_str(vpiName, h) : NULL;
    return s != NULL ? s : "(none)";
}

static int int_value(vpiHandle h)
{
    s_vpi_value v;
    if (h == NULL)
        return -1;
    v.format = vpiIntVal;
    vpi_get_value(h, &v);
    return (int)v.value.integer;
}

static vpiHandle find(const char *name)
{
    char full[96];
    snprintf(full, sizeof full, "%s.%s", TOP, name);
    return vpi_handle_by_name((PLI_BYTE8 *)full, NULL);
}

static void names(vpiHandle obj, PLI_INT32 type, const char *label)
{
    vpiHandle it = vpi_iterate(type, obj), h;
    char list[MAX][LEN];
    int n = 0, i;

    while (it != NULL && (h = vpi_scan(it)) != NULL)
        if (n < MAX)
            snprintf(list[n++], LEN, "%s", name_of(h));
    qsort(list, (size_t)n, LEN, by_text);
    vpi_printf((PLI_BYTE8 *)"%s:", label);
    for (i = 0; i < n; i++)
        vpi_printf((PLI_BYTE8 *)" %s", list[i]);
    vpi_printf((PLI_BYTE8 *)"\n");
}

static void parameters(vpiHandle ref, const char *label)
{
    vpiHandle it = vpi_iterate(vpiParameter, ref), h;
    char list[MAX][LEN];
    int n = 0, i;

    while (it != NULL && (h = vpi_scan(it)) != NULL)
        if (n < MAX)
            snprintf(list[n++], LEN, "%s = %d (local %d)", name_of(h), int_value(h),
                     (int)vpi_get(vpiLocalParam, h));
    qsort(list, (size_t)n, LEN, by_text);
    vpi_printf((PLI_BYTE8 *)"%s:", label);
    for (i = 0; i < n; i++)
        vpi_printf((PLI_BYTE8 *)"%s %s", i ? "," : "", list[i]);
    vpi_printf((PLI_BYTE8 *)"\n");
}

static void types(void)
{
    vpiHandle p = find("p"), n = find("n"), obj;
    char declared[32];

    obj = p != NULL ? vpi_handle(vpiClassObj, p) : NULL;
    /* vpi_get_str can reuse its buffer, so the first name is copied. */
    snprintf(declared, sizeof declared, "%s",
             name_of(vpi_handle(vpiClassDefn, vpi_handle(vpiClassTypespec, p))));
    vpi_printf((PLI_BYTE8 *)"p: declared type of %s, its object created as %s\n", declared,
               obj != NULL ? name_of(vpi_handle(vpiClassDefn, vpi_handle(vpiClassTypespec, obj)))
               : "(no object)");
    vpi_printf((PLI_BYTE8 *)"n: class obj NULL %d\n", n != NULL && vpi_handle(vpiClassObj, n) == NULL);
}

static void identities(void)
{
    static const char *const vars[5] = {"q", "r", "p", "o1", "o2"};
    PLI_INT64 id[5], idn;
    vpiHandle obj;
    int i, j, distinct = 1, nonzero = 1, objects_match = 1;

    for (i = 0; i < 5; i++) {
        id[i] = vpi_get64(vpiObjId, find(vars[i]));
        obj = vpi_handle(vpiClassObj, find(vars[i]));
        if (obj == NULL || vpi_get64(vpiObjId, obj) != id[i])
            objects_match = 0;
        if (id[i] == 0)
            nonzero = 0;
    }
    /* q and r share an object; p, o1 and o2 are three other live objects */
    for (i = 1; i < 5; i++)
        for (j = i + 1; j < 5; j++)
            if (id[i] == id[j] || (i > 1 && id[i] == id[0]) || (j > 1 && id[j] == id[0]))
                distinct = 0;
    idn = vpi_get64(vpiObjId, find("n"));
    vpi_printf((PLI_BYTE8 *)"object ids: q and r equal %d, q p o1 o2 distinct %d, nonzero %d, "
                            "variable id is its object's id %d, n is 0: %d\n",
               id[0] == id[1], distinct, nonzero, objects_match, idn == 0);
}

static PLI_INT32 obj_calltf(PLI_BYTE8 *user_data)
{
    vpiHandle q = find("q"), obj, ts, it, h, by_name;
    int vifs = 0, arrays = 0, vif = 0;

    (void)user_data;
    types();
    obj = q != NULL ? vpi_handle(vpiClassObj, q) : NULL;
    if (obj == NULL) {
        vpi_printf((PLI_BYTE8 *)"q: no class obj\n");
        return 0;
    }
    names(obj, vpiVariables, "variables of the object of q");
    it = vpi_iterate(vpiVariables, obj);
    while (it != NULL && (h = vpi_scan(it)) != NULL)
        if (strcmp(name_of(h), "vifs") == 0 && vpi_get(vpiType, h) == vpiArrayVar)
            arrays++;
    it = vpi_iterate(vpiVirtualInterfaceVar, obj);
    while (it != NULL && (h = vpi_scan(it)) != NULL)
        if (vpi_get(vpiType, h) == vpiVirtualInterfaceVar) {
            vifs++;
            if (strcmp(name_of(h), "vif") == 0)
                vif++;
        }
    vpi_printf((PLI_BYTE8 *)"vifs as one vpiArrayVar among the variables %d, "
                            "virtual interface vars %d, vif among them %d\n", arrays, vifs, vif);
    names(obj, vpiMethods, "methods");
    names(obj, vpiConstraint, "constraints");
    names(obj, vpiNamedEvent, "named events");
    names(obj, vpiNamedEventArray, "named event arrays");
    parameters(obj, "parameters of the object");
    ts = vpi_handle(vpiClassTypespec, q);
    parameters(ts, "parameters of the class typespec of q");
    identities();
    by_name = vpi_handle_by_name((PLI_BYTE8 *)TOP ".q.id", NULL);
    vpi_printf((PLI_BYTE8 *)"by name %s.q.id: found %d, value %d\n", TOP, by_name != NULL,
               int_value(by_name));
    return 0;
}

static void register_all(void)
{
    s_vpi_systf_data d;
    memset(&d, 0, sizeof d);
    d.type = vpiSysTask;
    d.tfname = (PLI_BYTE8 *)"$vt_obj";
    d.calltf = obj_calltf;
    vpi_register_systf(&d);
}

void (*vlog_startup_routines[])(void) = {register_all, 0};

#ifdef __cplusplus
}
#endif
