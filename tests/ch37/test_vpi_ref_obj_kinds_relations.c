/* VPI application of test_vpi_ref_obj_kinds_relations (IEEE 1800-2023 37.15). */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "sv_vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

#define TOP "test_vpi_ref_obj_kinds_relations"
#define MAX 8

enum {
    NAME = 1,      /* vpiName and vpiFullName */
    PARENT = 2,    /* vpiParent */
    TYPESPEC = 4,  /* vpiTypespec */
    INSTANCE = 8,  /* vpiInstance */
    TASKFUNC = 16, /* vpiTaskFunc */
    DEFNAME = 32,  /* vpiDefName */
    PORTS = 64,    /* vpi_iterate(vpiPorts) */
    GENERIC = 128  /* vpiGeneric */
};

static int by_name(const void *a, const void *b)
{
    return strcmp(*(const char *const *)a, *(const char *const *)b);
}

/* vpi_get_str reuses its buffer (38.11), so every string is copied. */
static char *copy(PLI_BYTE8 *s)
{
    const char *t = s ? s : "(null)";
    char *c = (char *)malloc(strlen(t) + 1);
    strcpy(c, t);
    return c;
}

static void actual(vpiHandle ro)
{
    vpiHandle a = vpi_handle(vpiActual, ro);
    const char *kind;
    if (a == NULL) {
        vpi_printf(", actual NULL");
        return;
    }
    switch (vpi_get(vpiType, a)) {
    case vpiInterface: kind = "interface"; break;
    case vpiLogicVar: kind = "logic var"; break;
    case vpiIntVar: kind = "int var"; break;
    case vpiVarBit: kind = "var bit"; break;
    default: kind = "other object"; break;
    }
    vpi_printf(", actual %s %s", kind, copy(vpi_get_str(vpiFullName, a)));
}

static void describe(vpiHandle ro, int what)
{
    vpiHandle h, it;
    PLI_INT32 g;
    char *names[MAX];
    int n = 0, i;

    if (ro == NULL || vpi_get(vpiType, ro) != vpiRefObj) {
        vpi_printf("not a ref obj");
        return;
    }
    vpi_printf("ref obj");
    if (what & NAME) {
        vpi_printf(", name %s", copy(vpi_get_str(vpiName, ro)));
        vpi_printf(", full name %s", copy(vpi_get_str(vpiFullName, ro)));
    }
    actual(ro);
    if (what & GENERIC) {
        g = vpi_get(vpiGeneric, ro);
        if (g == vpiUndefined)
            vpi_printf(", generic vpiUndefined");
        else
            vpi_printf(", generic %d", (int)g);
    }
    if (what & DEFNAME)
        vpi_printf(", def name %s", copy(vpi_get_str(vpiDefName, ro)));
    if (what & PARENT) {
        h = vpi_handle(vpiParent, ro);
        if (h == NULL)
            vpi_printf(", parent NULL");
        else if (vpi_get(vpiType, h) == vpiRefObj)
            vpi_printf(", parent ref obj %s", copy(vpi_get_str(vpiName, h)));
        else
            vpi_printf(", parent not a ref obj");
    }
    if (what & TYPESPEC) {
        h = vpi_handle(vpiTypespec, ro);
        if (h == NULL)
            vpi_printf(", typespec NULL");
        else if (vpi_get(vpiType, h) == vpiLogicTypespec)
            vpi_printf(", typespec vpiLogicTypespec");
        else if (vpi_get(vpiType, h) == vpiIntTypespec)
            vpi_printf(", typespec vpiIntTypespec");
        else
            vpi_printf(", typespec of another type");
    }
    if (what & INSTANCE) {
        h = vpi_handle(vpiInstance, ro);
        vpi_printf(", instance %s", h ? copy(vpi_get_str(vpiFullName, h)) : "NULL");
    }
    if (what & TASKFUNC) {
        h = vpi_handle(vpiTaskFunc, ro);
        vpi_printf(", task func %s", h ? copy(vpi_get_str(vpiName, h)) : "NULL");
    }
    if (what & PORTS) {
        it = vpi_iterate(vpiPorts, ro);
        while (it && (h = vpi_scan(it)) != NULL)
            if (n < MAX)
                names[n++] = copy(vpi_get_str(vpiName, h));
        qsort(names, n, sizeof names[0], by_name);
        vpi_printf(", vpiPorts:");
        for (i = 0; i < n; i++)
            vpi_printf(" %s", names[i]);
        if (n == 0)
            vpi_printf(" none");
    }
}

static PLI_INT32 ref_calltf(PLI_BYTE8 *user_data)
{
    vpiHandle args = vpi_iterate(vpiArgument, vpi_handle(vpiSysTfCall, NULL));
    vpiHandle label = vpi_scan(args), ro = vpi_scan(args);
    s_vpi_value v;
    char *l;

    (void)user_data;
    vpi_free_object(args);
    v.format = vpiStringVal;
    vpi_get_value(label, &v);
    l = copy(v.value.str);
    vpi_printf("use of %s: ", l);
    if (strcmp(l, "r") == 0)
        describe(ro, NAME | GENERIC | PARENT | TYPESPEC | INSTANCE);
    else if (strcmp(l, "r[1]") == 0)
        describe(ro, GENERIC | PARENT);
    else if (strcmp(l, "s.v") == 0)
        describe(ro, GENERIC | TYPESPEC);
    else
        describe(ro, GENERIC | TYPESPEC | TASKFUNC);
    vpi_printf("\n");
    return 0;
}

static PLI_INT32 ports_calltf(PLI_BYTE8 *user_data)
{
    vpiHandle m = vpi_handle_by_name((PLI_BYTE8 *)TOP ".m", NULL);
    vpiHandle it = m ? vpi_iterate(vpiPort, m) : NULL, p, hc, ports[MAX], io;
    struct { char *name; vpiHandle h; } ios[MAX];
    int i, j, n = 0;

    (void)user_data;
    memset(ports, 0, sizeof ports);
    while (it && (p = vpi_scan(it)) != NULL) {
        int index = (int)vpi_get(vpiPortIndex, p);
        if (index >= 0 && index < MAX)
            ports[index] = p;
    }
    for (i = 0; i < MAX; i++) {
        p = ports[i];
        if (p == NULL)
            continue;
        vpi_printf("port %s: high conn ", copy(vpi_get_str(vpiName, p)));
        hc = vpi_handle(vpiHighConn, p);
        if (hc != NULL && vpi_get(vpiType, hc) == vpiRefObj)
            describe(hc, 0);
        else
            vpi_printf("%s", hc ? copy(vpi_get_str(vpiName, hc)) : "NULL");
        vpi_printf("\n  low conn ");
        describe(vpi_handle(vpiLowConn, p),
                 NAME | GENERIC | TYPESPEC | INSTANCE | PORTS | (i < 2 ? DEFNAME : 0));
        vpi_printf("\n");
    }
    it = m ? vpi_iterate(vpiIODecl, m) : NULL;
    while (it && (io = vpi_scan(it)) != NULL) {
        if (n == MAX)
            continue;
        ios[n].name = copy(vpi_get_str(vpiName, io));
        ios[n++].h = io;
    }
    for (i = 1; i < n; i++)
        for (j = i; j > 0 && strcmp(ios[j - 1].name, ios[j].name) > 0; j--) {
            char *tn = ios[j].name;
            vpiHandle th = ios[j].h;
            ios[j] = ios[j - 1];
            ios[j - 1].name = tn;
            ios[j - 1].h = th;
        }
    for (i = 0; i < n; i++) {
        io = vpi_handle(vpiExpr, ios[i].h);
        vpi_printf("io decl %s: expr ", ios[i].name);
        if (io != NULL && vpi_get(vpiType, io) == vpiRefObj)
            vpi_printf("ref obj %s\n", copy(vpi_get_str(vpiName, io)));
        else
            vpi_printf("not a ref obj\n");
    }
    return 0;
}

static void register_all(void)
{
    s_vpi_systf_data d;
    memset(&d, 0, sizeof d);
    d.type = vpiSysTask;
    d.tfname = (PLI_BYTE8 *)"$vt_ref";
    d.calltf = ref_calltf;
    vpi_register_systf(&d);
    d.tfname = (PLI_BYTE8 *)"$vt_ports";
    d.calltf = ports_calltf;
    vpi_register_systf(&d);
}

void (*vlog_startup_routines[])(void) = {register_all, 0};

#ifdef __cplusplus
}
#endif
