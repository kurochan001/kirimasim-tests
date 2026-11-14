/* C side of test_implicit_variable_from_each_call_category (IEEE 1800-2023 13.4.1, 35.5). */
#include "svdpi.h"

#ifdef __cplusplus
extern "C" {
#endif

int c_scaled(int x)
{
    return 16 * x + 3;
}

#ifdef __cplusplus
}
#endif
