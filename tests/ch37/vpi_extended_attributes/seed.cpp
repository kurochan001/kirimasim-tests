/* Populate existing Ghost VPI owners for relationships without portable source syntax. */
#include <cstddef>
#include <cstring>
#include <list>
#include <string>
#include <utility>

#include <sukimasim/ir/attribute_info.h>
#include <sukimasim/vpi/vpi_impl.h>
#include "client.h"

namespace {

using sukimasim::ir::AttributeInfo;
using sukimasim::vpi::VPIInterface;

std::list<AttributeInfo> values;

bool contrast_mode()
{
    s_vpi_vlog_info info{};
    if (!vpi_get_vlog_info(&info))
        return false;
    for (int i = 0; i < info.argc; ++i) {
        if (std::strcmp(info.argv[i], "+contrast_attribute_relations") == 0)
            return true;
    }
    return false;
}

}  // namespace

extern "C" int attach_fixture_attributes(const attribute_request *requests, size_t count,
                                          vpiHandle wrong_parent, vpiHandle wrong_iterator_owner)
{
    auto &vpi = VPIInterface::getInstance();
    const bool contrast = contrast_mode();
    for (size_t i = 0; i < count; ++i) {
        const attribute_request &request = requests[i];
        const bool wrong_iteration = contrast && i == MODULE_PATHS * ATTRIBUTES_PER_GROUP;
        const bool wrong_backlink = contrast && i == PATH_TERMINALS * ATTRIBUTES_PER_GROUP;
        auto *forward_owner = vpi.getHandleImpl(wrong_iteration ? wrong_iterator_owner : request.owner);
        auto *reverse_owner = vpi.getHandleImpl(wrong_backlink ? wrong_parent : request.owner);
        if (!forward_owner || !reverse_owner)
            return 0;
        AttributeInfo value;
        value.name = request.name;
        value.width = 32;
        if (request.format == vpiRealVal) {
            value.kind = AttributeInfo::Kind::Real;
            value.real = request.value + 0.5;
        } else {
            value.integer = request.value;
        }
        values.push_back(std::move(value));

        auto *attribute = vpi.getHandleImpl(vpi.createHandle(vpiAttribute, request.name, nullptr));
        if (!attribute)
            return 0;
        attribute->setInternalObject(&values.back());
        attribute->addRelationObject(vpiParent, reverse_owner);
        forward_owner->addRelationObject(vpiAttribute, attribute);
    }
    return 1;
}
