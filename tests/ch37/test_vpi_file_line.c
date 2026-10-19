/* VPI application of test_vpi_file_line (IEEE 1800-2023 37.3.3). */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

#define TOP "test_vpi_file_line"

/* The last part of a path; the tool may give the file name with directories. */
static const char *base_name(PLI_BYTE8 *path)
{
    const char *slash;
    if (path == NULL)
        return "(null)";
    slash = strrchr(path, '/');
    return slash ? slash + 1 : path;
}

static void show(const char *name, PLI_INT32 line_prop, PLI_INT32 file_prop, const char *label)
{
    char full[64];
    vpiHandle h;

    snprintf(full, sizeof full, "%s.%s", TOP, name);
    h = vpi_handle_by_name(full, NULL);
    if (h == NULL) {
        vpi_printf("%s: not found\n", name);
        return;
    }
    vpi_printf("%s: line %d, file %s\n", label, (int)vpi_get(line_prop, h),
               base_name(vpi_get_str(file_prop, h)));
}

static PLI_INT32 lines_calltf(PLI_BYTE8 *user_data)
{
    (void)user_data;
    show("r", vpiLineNo, vpiFile, "r");
    show("w", vpiLineNo, vpiFile, "w");
    show("after_line", vpiLineNo, vpiFile, "after_line");
    show("u", vpiLineNo, vpiFile, "u");
    show("u.n", vpiLineNo, vpiFile, "u.n");
    show("u", vpiDefLineNo, vpiDefFile, "definition of u");
    return 0;
}

static void register_all(void)
{
    s_vpi_systf_data d;
    memset(&d, 0, sizeof d);
    d.type = vpiSysTask;
    d.tfname = (PLI_BYTE8 *)"$vt_lines";
    d.calltf = lines_calltf;
    vpi_register_systf(&d);
}

void (*vlog_startup_routines[])(void) = {register_all, 0};

#ifdef __cplusplus
}
#endif
