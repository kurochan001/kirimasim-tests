/* C++ side of test_35_extra_35_5_1_6_cxx_linkage (IEEE 1800-2023 35.5.1.6). */
#include "svdpi.h"

/* Compiled as C++, the helper triple has C++ linkage inside a namespace;
   compiled as C, it is a plain static function. */
#ifdef __cplusplus
namespace dpi_internal {
int triple(int x) { return 3 * x; }
}
using dpi_internal::triple;
#else
static int triple(int x) { return 3 * x; }
#endif

#ifdef __cplusplus
extern "C" {
#endif

extern int sv_plus(int x);

int cxx_chain(int v)
{
    /* The exported SystemVerilog function is called through C linkage. */
    int sum = sv_plus(v);
    return triple(v) + sum;
}

#ifdef __cplusplus
}
#endif
