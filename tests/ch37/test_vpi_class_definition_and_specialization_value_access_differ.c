#include <stddef.h>
#include <string.h>
#include "sv_vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

#define TOP "test_vpi_class_definition_and_specialization_value_access_differ"
#define SENTINEL (-1638724511)

struct fields {
    vpiHandle own;
    vpiHandle shared;
};

static struct fields members(vpiHandle scope)
{
    struct fields result = {NULL, NULL};
    vpiHandle it = scope != NULL ? vpi_iterate(vpiVariables, scope) : NULL, h;
    while (it != NULL && (h = vpi_scan(it)) != NULL) {
        const char *name = vpi_get_str(vpiName, h);
        if (name != NULL && strcmp(name, "own") == 0)
            result.own = h;
        if (name != NULL && strcmp(name, "shared") == 0)
            result.shared = h;
    }
    return result;
}

static unsigned read_int(vpiHandle h, PLI_INT32 *out)
{
    s_vpi_value value = {0};
    value.format = vpiIntVal;
    value.value.integer = SENTINEL;
    *out = SENTINEL;
    if (h == NULL)
        return 0;

    vpi_get_value(h, &value);
    s_vpi_error_info error = {0};
    if (vpi_chk_error(&error) >= vpiWarning || value.format != vpiIntVal ||
        value.value.integer == SENTINEL)
        return 0;

    *out = value.value.integer;
    return 1;
}

static unsigned probe_then_try_write(vpiHandle h)
{
    if (h == NULL)
        return 0;

    PLI_INT32 unused;
    unsigned no_read = !read_int(h, &unused);
    s_vpi_value value = {0};
    value.format = vpiIntVal;
    value.value.integer = 999;
    vpi_put_value(h, &value, NULL, vpiNoDelay);
    return no_read;
}

static vpiHandle typespec(const char *path)
{
    vpiHandle variable = vpi_handle_by_name((PLI_BYTE8 *)path, NULL);
    return variable != NULL ? vpi_handle(vpiTypespec, variable) : NULL;
}

static void show_specialization(const char *label, vpiHandle scope)
{
    const struct fields f = members(scope);
    unsigned no_own = probe_then_try_write(f.own);
    PLI_INT32 shared;
    read_int(f.shared, &shared);
    vpi_printf("%s specialization members=%d%d own unavailable=%u shared=%d\n",
               label, f.own != NULL, f.shared != NULL, no_own, (int)shared);
}

static PLI_INT32 inspect(PLI_BYTE8 *unused)
{
    (void)unused;
    vpiHandle first = typespec(TOP ".one"), second = typespec(TOP ".two");
    vpiHandle d1 = first != NULL ? vpi_handle(vpiClassDefn, first) : NULL;
    vpiHandle d2 = second != NULL ? vpi_handle(vpiClassDefn, second) : NULL;

    vpi_printf("class routes same definition=%d distinct specializations=%d\n",
               d1 != NULL && d2 != NULL && vpi_compare_objects(d1, d2),
               first != NULL && second != NULL && !vpi_compare_objects(first, second));

    const struct fields d = members(d1);
    unsigned no_own = probe_then_try_write(d.own);
    unsigned no_shared = probe_then_try_write(d.shared);
    vpi_printf("definition members=%d%d unavailable=%u%u\n",
               d.own != NULL, d.shared != NULL, no_own, no_shared);
    show_specialization("first", first);
    show_specialization("second", second);
    return 0;
}

static void setup(void)
{
    s_vpi_systf_data definition = {0};
    definition.type = vpiSysTask;
    definition.tfname = "$vt_probe_class_value_routes";
    definition.calltf = inspect;
    vpi_register_systf(&definition);
}

void (*vlog_startup_routines[])(void) = {setup, NULL};

#ifdef __cplusplus
}
#endif
