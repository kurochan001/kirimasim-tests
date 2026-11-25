#include <cstdio>
#include <stdexcept>

#ifdef DPI_PROBE_ESCAPE
#define DPI_EXCEPTION_SPEC
#else
#define DPI_EXCEPTION_SPEC noexcept
#endif

extern "C" int cxx_boundary_function(int, int *) DPI_EXCEPTION_SPEC;
extern "C" int cxx_boundary_task(int, int *, int *) DPI_EXCEPTION_SPEC;

int main()
{
    int caught = -1;
    int value = -1;
    try {
        value = cxx_boundary_function(-1, &caught);
        std::printf("function returned value=%d caught=%d\n", value, caught);
    } catch (const std::out_of_range &) {
        std::puts("function exception reached native caller");
    }

    caught = value = -1;
    try {
        const int status = cxx_boundary_task(-2, &value, &caught);
        std::printf("task returned status=%d value=%d caught=%d\n", status, value, caught);
    } catch (const std::out_of_range &) {
        std::puts("task exception reached native caller");
    }
}
