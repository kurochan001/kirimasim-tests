/* VPI application of test_38_extra_scalar_val (IEEE 1800-2023 38.15). */
#include <string.h>
#include "vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

#define TOP "test_38_extra_scalar_val."

static const char *scalar_name(PLI_INT32 value)
{
    return value == vpi0 ? "vpi0" : value == vpi1 ? "vpi1" : value == vpiX ? "vpiX"
           : value == vpiZ ? "vpiZ" : value == vpiH ? "vpiH"
           : value == vpiL ? "vpiL" : "another";
}

static void show(const char *name)
{
    char full[96];
    vpiHandle h;
    s_vpi_value v;

    strcpy(full, TOP);
    strcat(full, name);
    h = vpi_handle_by_name((PLI_BYTE8 *)full, NULL);
    if (h == NULL) {
        vpi_printf((PLI_BYTE8 *)"%s: not found\n", name);
        return;
    }
    memset(&v, 0, sizeof v);
    v.format = vpiScalarVal;
    vpi_get_value(h, &v);
    vpi_printf((PLI_BYTE8 *)"%s: %s\n", name, scalar_name(v.value.scalar));
}

static PLI_INT32 read_calltf(PLI_BYTE8 *user_data)
{
    (void)user_data;
    show("zero_v");
    show("one_v");
    show("x_v");
    show("z_v");
    return 0;
}

static void register_all(void)
{
    s_vpi_systf_data d;

    memset(&d, 0, sizeof d);
    d.type = vpiSysTask;
    d.tfname = (PLI_BYTE8 *)"$vt_read";
    d.calltf = read_calltf;
    vpi_register_systf(&d);
}

void (*vlog_startup_routines[])(void) = {register_all, 0};

#ifdef __cplusplus
}
#endif
