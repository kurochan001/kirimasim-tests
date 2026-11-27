#include <stdio.h>
#include "formats.h"

#ifdef __cplusplus
extern "C" {
#endif

#ifdef TEST_REFERENCE_FORMATS
#define read_value reference_get_value
#else
#define read_value vpi_get_value
#endif

static void report_words(const s_vpi_vecval *words, PLI_INT32 width)
{
    vpi_printf(" width=%d words=", (int)width);
    for (PLI_INT32 word = 0; word < (width + 31) / 32; ++word)
        vpi_printf("%s%x/%x", word ? "," : "", (unsigned)words[word].aval, (unsigned)words[word].bval);
    vpi_printf("\n");
}

static void report_value(const char *name)
{
    char path[96];
    snprintf(path, sizeof path, "test_vpi_misc_extension_formats.%s", name);
    vpiHandle object = vpi_handle_by_name((PLI_BYTE8 *)path, NULL);
    s_vpi_value value = {0};
    value.format = vpiVectorVal;
    if (object != NULL)
        read_value(object, &value);
    if (value.format != vpiVectorVal || value.value.vector == NULL) {
        vpi_printf("%s standard vector missing\n", name);
        return;
    }
    vpi_printf("%s standard", name);
    report_words(value.value.vector, vpi_get(vpiSize, object));

#ifdef TEST_REFERENCE_FORMATS
    value.format = testBitPlanes;
    value.value.misc = NULL;
    read_value(object, &value);
    if (value.format == testBitPlanes && value.value.misc != NULL) {
        const struct bit_planes *planes = (const struct bit_planes *)value.value.misc;
        vpi_printf("%s misc id=%08x", name, (unsigned)value.format);
        report_words(planes->words, planes->width);
    }

    value.format = testStateCounts;
    value.value.misc = NULL;
    read_value(object, &value);
    if (value.format == testStateCounts && value.value.misc != NULL) {
        const struct state_counts *counts = (const struct state_counts *)value.value.misc;
        vpi_printf("%s misc id=%08x counts=%d/%d/%d/%d\n", name, (unsigned)value.format,
                   (int)counts->zero, (int)counts->one, (int)counts->x, (int)counts->z);
    }

    value.format = testUnregistered;
    read_value(object, &value);
    vpi_printf("%s unknown rejected=%d\n", name,
               value.format == vpiSuppressVal && value.value.misc == NULL);
#elif defined(TEST_NATIVE_FORMATS)
    const PLI_INT32 ids[] = {testBitPlanes, testStateCounts, testUnregistered};
    for (unsigned index = 0; index < sizeof ids / sizeof ids[0]; ++index) {
        s_vpi_error_info error = {0};
        value.format = ids[index];
        value.value.misc = NULL;
        vpi_chk_error(&error);
        read_value(object, &value);
        vpi_printf("%s native requested=%08x returned=%08x data=%d error=%d\n",
                   name, (unsigned)ids[index], (unsigned)value.format, value.value.misc != NULL,
                   (int)vpi_chk_error(&error));
    }
#endif
}

static PLI_INT32 at_end(p_cb_data callback)
{
    (void)callback;
    report_value("wide");
    report_value("narrow");
    return 0;
}

static void install(void)
{
    s_cb_data callback = {0};
    callback.reason = cbEndOfSimulation;
    callback.cb_rtn = at_end;
    vpi_register_cb(&callback);
}

void (*vlog_startup_routines[])(void) = {install, NULL};

#ifdef __cplusplus
}
#endif
