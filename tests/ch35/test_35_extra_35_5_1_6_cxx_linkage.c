/* C++ side of test_35_extra_35_5_1_6_cxx_linkage (IEEE 1800-2023 35.5.1.6). */
#include <cstdio>
#include "svdpi.h"

extern "C" int sv_plus(int x);

namespace dpi_internal {
int triple(int x) { return 3 * x; }
}

extern "C" int cxx_chain(int v) {
    /* The exported SystemVerilog function is called through C linkage. */
    int sum = sv_plus(v);
    return dpi_internal::triple(v) + sum;
}
