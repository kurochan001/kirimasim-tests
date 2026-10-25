/* VPI application of test_vpi_property_kinds_access_routines (IEEE 1800-2023 37.4.2). */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

#define TOP "test_vpi_property_kinds_access_routines"

/* Integer and Boolean properties: vpi_get, of type PLI_INT32. String
   properties: vpi_get_str, of type PLI_BYTE8 *. Assigning the routines to
   pointers of these types fails to compile when their types differ. */
static PLI_INT32 (*get_int)(PLI_INT32, vpiHandle) = vpi_get;
static PLI_BYTE8 *(*get_str)(PLI_INT32, vpiHandle) = vpi_get_str;

static vpiHandle find(const char *name)
{
    char full[160];
    vpiHandle h;
    snprintf(full, sizeof full, "%s.%s", TOP, name);
    h = vpi_handle_by_name((PLI_BYTE8 *)full, NULL);
    if (h == NULL)
        vpi_printf((PLI_BYTE8 *)"%s: not found\n", full);
    return h;
}

static const char *text(PLI_BYTE8 *s)
{
    return s != NULL ? (const char *)s : "(null)";
}

static void int_props(vpiHandle vec, vpiHandle one, vpiHandle bus)
{
    PLI_INT32 size_vec = get_int(vpiSize, vec), size_one = get_int(vpiSize, one);
    PLI_INT32 size_bus = get_int(vpiSize, bus);
    vpi_printf((PLI_BYTE8 *)"vpi_get(vpiSize): vec %d, one %d, bus %d\n", (int)size_vec,
               (int)size_one, (int)size_bus);
    vpi_printf((PLI_BYTE8 *)"vpi_get(vpiVector): vec %d, one %d, bus %d\n",
               (int)get_int(vpiVector, vec), (int)get_int(vpiVector, one),
               (int)get_int(vpiVector, bus));
    vpi_printf((PLI_BYTE8 *)"vpi_get(vpiScalar): vec %d, one %d, bus %d\n",
               (int)get_int(vpiScalar, vec), (int)get_int(vpiScalar, one),
               (int)get_int(vpiScalar, bus));
}

/* vpi_get_str may reuse its buffer (38.11), so each string is printed
   before the next call. */
static void str_props(vpiHandle vec, vpiHandle bus)
{
    vpi_printf((PLI_BYTE8 *)"vpi_get_str(vpiName): vec %s,", text(get_str(vpiName, vec)));
    vpi_printf((PLI_BYTE8 *)" bus %s\n", text(get_str(vpiName, bus)));
    vpi_printf((PLI_BYTE8 *)"vpi_get_str(vpiFullName): %s\n", text(get_str(vpiFullName, bus)));
}

static void value_of(const char *label, vpiHandle h)
{
    s_vpi_value v;
    v.format = vpiBinStrVal;
    vpi_get_value(h, &v);
    vpi_printf((PLI_BYTE8 *)"vpi_get_value(vpiBinStrVal) of %s: %s\n", label,
               text(v.value.str));
}

static void path_delays(void)
{
    vpiHandle cell = find("c"), it, path;
    s_vpi_time t[2];
    s_vpi_delay d;
    int n = 0;

    if (cell == NULL)
        return;
    it = vpi_iterate(vpiModPath, cell);
    while (it != NULL && (path = vpi_scan(it)) != NULL) {
        n++;
        memset(&d, 0, sizeof d);
        memset(t, 0, sizeof t);
        d.da = t;
        d.no_of_delays = 2;
        d.time_type = vpiScaledRealTime;
        vpi_get_delays(path, &d);
        vpi_printf((PLI_BYTE8 *)"vpi_get_delays of the module path: rise %g, fall %g\n",
                   t[0].real, t[1].real);
    }
    if (n == 0)
        vpi_printf((PLI_BYTE8 *)"no module path\n");
}

static PLI_INT32 props_calltf(PLI_BYTE8 *user_data)
{
    vpiHandle vec = find("vec"), one = find("one"), bus = find("bus");

    (void)user_data;
    if (vec == NULL || one == NULL || bus == NULL)
        return 0;
    int_props(vec, one, bus);
    str_props(vec, bus);
    value_of("vec", vec);
    value_of("bus", bus);
    path_delays();
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
