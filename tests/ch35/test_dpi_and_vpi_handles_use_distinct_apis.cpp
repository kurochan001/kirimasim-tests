#include <cstdio>
#include <type_traits>
#include "svdpi.h"
#include "vpi_user.h"

static_assert(!std::is_same<svOpenArrayHandle, vpiHandle>::value,
              "DPI and VPI expose distinct handle types");

#ifdef DPI_API_WITH_VPI_SIGNATURE
decltype(&vpi_release_handle) dpi_api_with_vpi_signature = &svDimensions;
#endif
#ifdef VPI_API_WITH_DPI_SIGNATURE
decltype(&svDimensions) vpi_api_with_dpi_signature = &vpi_release_handle;
#endif

extern "C" int inspect_handles(const svOpenArrayHandle array)
{
    const svScope scope = svGetScope();
    const char *name = scope ? svGetNameFromScope(scope) : nullptr;
    if (!name)
        return -1;
    char path[256];
    const int length = std::snprintf(path, sizeof path, "%s.values", name);
    if (length < 0 || length >= (int)sizeof path)
        return -2;

    vpiHandle vpi_array = vpi_handle_by_name(path, nullptr);
    if (!vpi_array)
        return -3;
    vpiHandle item = vpi_handle_by_index(vpi_array, 1);
    if (!item) {
        vpi_release_handle(vpi_array);
        return -4;
    }
    s_vpi_value value{};
    value.format = vpiIntVal;
    vpi_get_value(item, &value);
    vpi_release_handle(item);
    vpi_release_handle(vpi_array);
    return (1000 * svSize(array, 1)) + value.value.integer;
}
