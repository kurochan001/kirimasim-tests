/* C functions of test_c_identifier_dpi_linkage_names (IEEE 1800-2023 35.5.4). */
#include "svdpi.h"

#ifdef __cplusplus
extern "C" {
#endif

int _c_ident9(int a)
{
    return a * 10;
}

int c_ident2(int a)
{
    return a + 100;
}

#ifdef __cplusplus
}
#endif
