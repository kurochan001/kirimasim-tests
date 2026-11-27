/* Transfer independently parsed information to the existing VPI objects. */
#include <cstring>
#include <sukimasim/vpi/vpi_impl.h>
#include "client.h"
#include "parsed_properties.h"

using sukimasim::vpi::VPIInterface;

extern "C" int set_constraint_virtual(vpiHandle object, const char *name)
{
    auto *handle = VPIInterface::getInstance().getHandleImpl(object);
    if (!handle || handle->getType() != vpiConstraint)
        return 0;
    for (const auto &entry : parsed_constraints) {
        if (std::strcmp(entry.name, name) == 0) {
            handle->setProperty(vpiVirtual, entry.is_virtual);
            return 1;
        }
    }
    return 0;
}

extern "C" int set_pattern_member_name(vpiHandle object, const char *binding)
{
    auto *handle = VPIInterface::getInstance().getHandleImpl(object);
    if (!handle || handle->getType() != vpiStructPattern)
        return 0;
    for (const auto &entry : parsed_members) {
        if (std::strcmp(entry.binding, binding) == 0) {
            handle->setStringProperty(vpiName, entry.name);
            return 1;
        }
    }
    return 0;
}
