#include <stdexcept>

#ifdef DPI_PROBE_CPP_LINKAGE
#define DPI_LINKAGE
#else
#define DPI_LINKAGE extern "C"
#endif

#ifdef DPI_PROBE_ESCAPE
#define DPI_EXCEPTION_SPEC
#else
#define DPI_EXCEPTION_SPEC noexcept
#endif

static int lookup(int index)
{
    if (index < 0)
        throw std::out_of_range("negative index");
    return index * 3;
}

static int boundary_value(int index, int recovery, int *caught) DPI_EXCEPTION_SPEC
{
    *caught = 0;
#ifdef DPI_PROBE_ESCAPE
    (void)recovery;
    return lookup(index);
#else
    try {
        return lookup(index);
    } catch (const std::out_of_range &) {
        *caught = 1;
        return recovery;
    }
#endif
}

DPI_LINKAGE int cxx_boundary_function(int index, int *caught) DPI_EXCEPTION_SPEC
{
    return boundary_value(index, -19, caught);
}

DPI_LINKAGE int cxx_boundary_task(int index, int *value, int *caught) DPI_EXCEPTION_SPEC
{
    *value = boundary_value(index, -29, caught);
    return 0;
}
