/* C side of test_dpi_scalar_logic_reg_encoding (IEEE 1800-2023 H.7.4, H.10.1.1). */
#include <stdio.h>
#include "svdpi.h"

#ifdef __cplusplus
extern "C" {
#endif

svLogic c_codes(svLogic l, svLogic r, int *lc, int *rc)
{
    *lc = (int)l;
    *rc = (int)r;
    return (svLogic)(l ^ 1);
}

void c_make(int code, svLogic *l, svLogic *r)
{
    printf("c_make: the inout reg had code %d\n", (int)*r);
    fflush(stdout);
    *l = (svLogic)code;
    *r = (svLogic)(3 - code);
}

int c_bit(svBit b)
{
    return (int)b;
}

#ifdef __cplusplus
}
#endif
