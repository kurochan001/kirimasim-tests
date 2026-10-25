/* C side of test_package_dpi_and_assertion_items (IEEE 1800-2023 26.2, 35.5.3). */
#include "svdpi.h"

#ifdef __cplusplus
extern "C" {
#endif

extern int sv_add(int a, int b);

int c_scaled_sum(int a, int b)
{
    return 10 * sv_add(a, b);
}

#ifdef __cplusplus
}
#endif
