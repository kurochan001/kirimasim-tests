/* C side of test_svdpi_h_packed_element_copy (IEEE 1800-2023 I.3, H.12.5). */
#include "svdpi.h"
#include <stdio.h>

#ifdef __cplusplus
extern "C" {
#endif

void c_copy(const svOpenArrayHandle w, const svOpenArrayHandle l)
{
    svBitVecVal got[SV_PACKED_DATA_NELEMS(64)];
    svBitVecVal put[SV_PACKED_DATA_NELEMS(64)];
    svLogicVecVal lgot[SV_PACKED_DATA_NELEMS(32)];
    svLogicVecVal lput[SV_PACKED_DATA_NELEMS(32)];

    got[0] = got[1] = 0xdeadbeefu;
    svGetBitArrElem1VecVal(got, w, 0);
    printf("two chunks of a 64-bit element: %08x %08x, both written %d\n", (unsigned)got[0],
           (unsigned)got[1], got[0] != 0xdeadbeefu && got[1] != 0xdeadbeefu);

    put[0] = 0x11112222u;
    put[1] = 0x33334444u;
    svPutBitArrElem1VecVal(w, put, 1);

    lgot[0].aval = 0xdeadbeefu;
    lgot[0].bval = 0xffffffffu;
    svGetLogicArrElem1VecVal(lgot, l, 0);
    printf("a 32-bit logic element: aval %08x bval %08x\n", (unsigned)lgot[0].aval,
           (unsigned)lgot[0].bval);

    lput[0].aval = 0xdeadbeefu;
    lput[0].bval = 0;
    svPutLogicArrElem1VecVal(l, lput, 1);
    fflush(stdout);
}

#ifdef __cplusplus
}
#endif
