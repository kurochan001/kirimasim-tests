/* C side of test_dpi_fourstate_packed_semantics (IEEE 1800-2023 35.2.2.1). */
#include "svdpi.h"

#ifdef __cplusplus
extern "C" {
#endif

void c_put_special(svLogicVecVal *p, svLogicVecVal *v, svLogicVecVal *a)
{
    svPutBitselLogic(p, 12, sv_x);
    svPutBitselLogic(p, 5, sv_z);
    svPutBitselLogic(v, 3, sv_z);
    svPutBitselLogic(v, 0, sv_x);
    svPutBitselLogic(a, 7, sv_x);
}

#ifdef __cplusplus
}
#endif
