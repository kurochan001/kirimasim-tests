/* Populate ownership edges that ordinary source cannot construct. */
#include <cstring>
#include <string>
#include <sukimasim/vpi/vpi_impl.h>
#include "client.h"

namespace {

using sukimasim::vpi::VPIHandleImpl;
using sukimasim::vpi::VPIInterface;

bool use_concrete_path_parent()
{
    s_vpi_vlog_info info{};
    if (!vpi_get_vlog_info(&info))
        return false;
    for (int i = 0; i < info.argc; ++i) {
        if (std::strcmp(info.argv[i], "+path_parent_fallback") == 0)
            return true;
    }
    return false;
}

bool add_term(VPIHandleImpl *path, VPIHandleImpl *owner, bool input, const std::string &pin)
{
    auto &vpi = VPIInterface::getInstance();
    vpiHandle signal = vpi_handle_by_name(const_cast<char *>(pin.c_str()), owner->getHandle());
    auto *expression = signal ? vpi.getHandleImpl(signal) : nullptr;
    if (!expression)
        return false;
    auto *terminal = vpi.getHandleImpl(vpi.createHandle(vpiPathTerm, pin));
    if (!terminal)
        return false;
    terminal->addRelationObject(vpiExpr, expression);
    terminal->addRelationObject(vpiModPath, path);
    terminal->setProperty(vpiDirection, input ? vpiInput : vpiOutput);
    if (input)
        path->addModPathIn(terminal);
    else
        path->addModPathOut(terminal);
    return true;
}

bool add_path(VPIHandleImpl *iface, VPIHandleImpl *original, const std::string &input, bool concrete_parent)
{
    auto &vpi = VPIInterface::getInstance();
    auto *path = vpi.getHandleImpl(vpi.createHandle(vpiModPath, original->getName(), original->getInternalObject()));
    if (!path)
        return false;
    // The explicit instance edge is the same in both models. The contrast
    // also adds the private hierarchy entry read by the legacy fallback.
    path->addRelationObject(vpiInstance, iface);
    path->setFullName(iface->getFullName() + "." + path->getName());
    if (concrete_parent)
        iface->addChild(path);
    iface->addModulePath(path);
    return add_term(path, iface, true, input) && add_term(path, iface, false, "y");
}

}  // namespace

extern "C" int attach_fixture_ownership(const design_handles *design)
{
    auto &vpi = VPIInterface::getInstance();
    auto *root = vpi.getHandleImpl(design->top);
    auto *timing = vpi.getHandleImpl(design->timing);
    if (!root || !timing || timing->getModulePaths().size() != 2)
        return 0;
    const bool concrete_parent = use_concrete_path_parent();
    for (unsigned index = 0; index < 2; ++index) {
        auto *program = vpi.getHandleImpl(design->program[index]);
        auto *iface = vpi.getHandleImpl(design->path[index]);
        if (!program || !iface || iface->getParent() != root)
            return 0;
        for (vpiHandle child : {design->scalar[index], design->array[index]}) {
            auto *object = vpi.getHandleImpl(child);
            if (!object || object->getParent() != root)
                return 0;
            const std::string elaborated_name = object->getFullName();
            root->removeChild(object);
            program->addChild(object);
            // Ghost indexes physical array members through the array's source
            // name. Keep that lookup key while changing the ownership edge.
            if (object->getType() == vpiInterfaceArray)
                object->setFullName(elaborated_name);
        }
        int bindings = 0;
        for (auto *native : timing->getModulePaths()) {
            const auto &terms = native->getModPathIns();
            if (terms.size() != 1)
                return 0;
            vpiHandle source = vpi_handle(vpiExpr, terms.front()->getHandle());
            const char *name = source ? vpi_get_str(vpiName, source) : nullptr;
            if (!name || (std::strcmp(name, "a") != 0 && std::strcmp(name, "b") != 0))
                return 0;
            if (index == 1 && std::strcmp(name, "a") == 0)
                continue;
            if (!add_path(iface, native, name, concrete_parent))
                return 0;
            ++bindings;
        }
        if (bindings != (index == 0 ? 2 : 1))
            return 0;
    }
    return 1;
}
