/* C side of test_35_extra_35_5_3_chain_attribute (IEEE 1800-2023 35.5.3). */
#include "svdpi.h"

#ifdef __cplusplus
extern "C" {
#endif

extern int sv_double(int x);

static int shared_level(int v, int use_export)
{
    if (use_export)
        return sv_double(v);
    return 2 * v;
}

int c_ctx_attr(int v, int use_export)
{
    if (svGetScope() == 0)
        return -1;
    return shared_level(v, use_export);
}

int c_nc_attr(int v, int use_export)
{
    return shared_level(v, use_export);
}

#ifdef __cplusplus
}
#endif
