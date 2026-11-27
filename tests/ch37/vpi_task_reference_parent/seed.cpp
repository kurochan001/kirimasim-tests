#include <sukimasim/vpi/vpi_impl.h>

extern "C" vpiHandle make_reference_view(vpiHandle declaration, vpiHandle target)
{
    if (!declaration || !target || vpi_get(vpiType, target) != vpiRefObj) return nullptr;

    // Exercise a separate view so that the HDL declaration retains its lexical parent.
    auto &vpi = sukimasim::vpi::VPIInterface::getInstance();
    vpiHandle view = vpi.createHandle(vpi_get(vpiType, declaration), vpi_get_str(vpiName, declaration));
    vpi.getHandleImpl(view)->addRelationObject(vpiParent, vpi.getHandleImpl(target));
    return view;
}
