#include "vpi_user.h"

static PLI_INT32 report(const PLI_BYTE8 *label)
{
    vpi_printf("vendor startup %s\n", label);
    return 0;
}

static void add(const char *name, const char *label)
{
    s_vpi_systf_data task = {
        .type = vpiSysTask, .tfname = name, .calltf = report, .user_data = label,
    };
    vpi_register_systf(&task);
}

void register_vendor_startup_first(void)
{
    add("$vendor_startup_first", "first");
}

void register_vendor_startup_second(void)
{
    add("$vendor_startup_second", "second");
}
