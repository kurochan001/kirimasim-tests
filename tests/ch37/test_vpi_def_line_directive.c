/* VPI application of test_vpi_def_line_directive (IEEE 1800-2023 37.10, 22.12). */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

#define TOP "test_vpi_def_line_directive"

static void show(const char *path)
{
    vpiHandle inst = vpi_handle_by_name((PLI_BYTE8 *)path, NULL);
    const char *file, *base;
    char name[64];

    if (inst == NULL) {
        vpi_printf("%s not found\n", path);
        return;
    }
    /* vpi_get_str reuses its buffer (38.11): the name is copied first. */
    snprintf(name, sizeof name, "%s", vpi_get_str(vpiName, inst));
    file = vpi_get_str(vpiDefFile, inst);
    base = file ? strrchr(file, '/') : NULL;
    base = base ? base + 1 : file ? file : "(null)";
    vpi_printf("%s: %s line %d\n", name, base, (int)vpi_get(vpiDefLineNo, inst));
}

static PLI_INT32 defs_calltf(PLI_BYTE8 *user_data)
{
    (void)user_data;
    show(TOP);
    show(TOP ".p");
    show(TOP ".m1");
    show(TOP ".m2");
    return 0;
}

static void register_all(void)
{
    s_vpi_systf_data d;
    memset(&d, 0, sizeof d);
    d.type = vpiSysTask;
    d.tfname = (PLI_BYTE8 *)"$vt_defs";
    d.calltf = defs_calltf;
    vpi_register_systf(&d);
}

void (*vlog_startup_routines[])(void) = {register_all, 0};

#ifdef __cplusplus
}
#endif
