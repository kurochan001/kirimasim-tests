/* IEEE 1800-2023 38.17: an option-file argument points to a recursive argv. */
#include <stddef.h>
#include <string.h>
#include "vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

typedef PLI_BYTE8 *const *option_list;

static int text_is(const PLI_BYTE8 *value, const char *expected)
{
    return value && strcmp(value, expected) == 0;
}

static int file_is(const PLI_BYTE8 *value, const char *expected)
{
    const char *separator = value ? strrchr(value, '/') : NULL;
    return text_is(separator ? separator + 1 : value, expected);
}

/* Compare the known flat filename by byte, stopping on the first mismatch.
   A flat filename is still a string and must never be decoded as a pointer. */
static int flat_filename(const PLI_BYTE8 *value, const char *filename)
{
    if (!value)
        return 0;
    while (*value == *filename) {
        if (*filename == '\0')
            return 1;
        value++;
        filename++;
    }
    return 0;
}

static void inspect_files(const PLI_BYTE8 *argument)
{
    option_list outer, inner;
    int outer_matches, inner_matches;

    if (flat_filename(argument, "outer.f")) {
        vpi_printf("options: flat outer filename\n");
        return;
    }
    outer = (option_list)argument;
    outer_matches = outer && file_is(outer[0], "outer.f") &&
        text_is(outer[1], "+define+VT_FROM_OUTER=17") &&
        text_is(outer[2], "-f") && outer[3] && outer[4] == NULL;
    if (!outer_matches) {
        vpi_printf("options: outer=0 inner=0\n");
        return;
    }
    if (flat_filename(outer[3], "inner.f")) {
        vpi_printf("options: flat inner filename\n");
        return;
    }
    inner = (option_list)outer[3];
    inner_matches = file_is(inner[0], "inner.f") &&
        text_is(inner[1], "+define+VT_FROM_INNER=29") &&
        file_is(inner[2], "test_vpi_vlog_info_nested_option_files.sv") && inner[3] == NULL;
    vpi_printf("options: outer=1 inner=%d\n", inner_matches);
}

static PLI_INT32 observe(p_cb_data callback)
{
    s_vpi_vlog_info info = {0};
    int ok = vpi_get_vlog_info(&info);
    int file_option = 0, outside = 0;
    const PLI_BYTE8 *file_argument = NULL;

    (void)callback;
    for (int i = 1; ok && info.argv && i < info.argc; i++) {
        if (text_is(info.argv[i], "-f") && i + 1 < info.argc) {
            file_option++;
            file_argument = info.argv[++i];
        } else if (text_is(info.argv[i], "+outside=31")) {
            outside++;
        }
    }
    vpi_printf("vlog: ok=%d outside=%d file_option=%d\n", ok, outside, file_option);
    if (file_option == 1)
        inspect_files(file_argument);
    return 0;
}

static void register_all(void)
{
    s_cb_data callback = {0};
    callback.reason = cbStartOfSimulation;
    callback.cb_rtn = observe;
    vpi_register_cb(&callback);
}

void (*vlog_startup_routines[])(void) = {register_all, NULL};

#ifdef __cplusplus
}
#endif
