#include <stddef.h>
#include <string.h>
#include "adapter.h"
#include "envelope_ranges.h"

static const char *denied_operation;
static vpiHandle argument_iterator;
static vpiHandle protected_argument;

static int in_envelope(vpiHandle object)
{
    if (object == NULL)
        return 0;
    if (object == protected_argument)
        return 1;
    PLI_INT32 line = vpi_get(vpiLineNo, object);
    for (size_t index = 0; index < sizeof envelope_ranges / sizeof envelope_ranges[0]; ++index)
        if (envelope_ranges[index][0] < line && line < envelope_ranges[index][1])
            return 1;
    return 0;
}

static int forbidden(vpiHandle object, const char *operation)
{
    denied_operation = in_envelope(object) ? operation : NULL;
    return denied_operation != NULL;
}

PLI_INT32 access_get(PLI_INT32 property, vpiHandle object)
{
    denied_operation = NULL;
    if (property == vpiIsProtected)
        return in_envelope(object);
    if (property == vpiType || (property == vpiSize && object != NULL && object == protected_argument))
        return vpi_get(property, object);
    if (forbidden(object, "vpi_get"))
        return vpiUndefined;
    return vpi_get(property, object);
}

PLI_INT64 access_get64(PLI_INT32 property, vpiHandle object)
{
    if (forbidden(object, "vpi_get64"))
        return vpiUndefined;
    return vpi_get64(property, object);
}

PLI_BYTE8 *access_get_str(PLI_INT32 property, vpiHandle object)
{
    return forbidden(object, "vpi_get_str") ? NULL : vpi_get_str(property, object);
}

vpiHandle access_handle(PLI_INT32 type, vpiHandle object)
{
    return forbidden(object, "vpi_handle") ? NULL : vpi_handle(type, object);
}

vpiHandle access_index(vpiHandle object, PLI_INT32 index)
{
    return forbidden(object, "vpi_handle_by_index") ? NULL : vpi_handle_by_index(object, index);
}

vpiHandle access_multi_index(vpiHandle object, PLI_INT32 count, PLI_INT32 *indices)
{
    if (forbidden(object, "vpi_handle_by_multi_index"))
        return NULL;
    return vpi_handle_by_multi_index(object, count, indices);
}

vpiHandle access_name(PLI_BYTE8 *name, vpiHandle scope)
{
    if (forbidden(scope, "vpi_handle_by_name"))
        return NULL;
    /* The fixture uses simple identifiers separated by dots. Resolve only
       the ancestor prefixes before looking up the supplied terminal name. */
    char prefix[192];
    size_t length = strlen(name);
    if (length >= sizeof prefix)
        return NULL;
    memcpy(prefix, name, length + 1);
    for (char *dot = strchr(prefix, '.'); dot != NULL; dot = strchr(dot + 1, '.')) {
        *dot = '\0';
        vpiHandle ancestor = vpi_handle_by_name((PLI_BYTE8 *)prefix, scope);
        *dot = '.';
        if (forbidden(ancestor, "vpi_handle_by_name"))
            return NULL;
    }
    return vpi_handle_by_name(name, scope);
}

vpiHandle access_iterate(PLI_INT32 type, vpiHandle object)
{
    if (!forbidden(object, "vpi_iterate"))
        return vpi_iterate(type, object);
    if (type == vpiArgument && (vpi_get(vpiType, object) == vpiSysTaskCall ||
                                vpi_get(vpiType, object) == vpiSysFuncCall)) {
        denied_operation = NULL;
        argument_iterator = vpi_iterate(type, object);
        return argument_iterator;
    }
    return NULL;
}

vpiHandle access_scan(vpiHandle iterator)
{
    vpiHandle item = vpi_scan(iterator);
    if (iterator == argument_iterator) {
        /* Runtime expression handles may not have a separate source line. */
        protected_argument = item;
        if (item == NULL)
            argument_iterator = NULL;
    }
    return item;
}

PLI_INT32 access_error(p_vpi_error_info info)
{
    if (denied_operation == NULL)
        return vpi_chk_error(info);
    if (info != NULL) {
        info->level = vpiError;
        info->code = (PLI_BYTE8 *)"protected_object";
        info->message = (PLI_BYTE8 *)denied_operation;
    }
    return vpiError;
}
