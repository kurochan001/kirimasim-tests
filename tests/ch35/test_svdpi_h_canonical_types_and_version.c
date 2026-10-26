/* C side of test_svdpi_h_canonical_types_and_version (IEEE 1800-2023 H.5, H.10). */
#include "svdpi.h"
#include <stddef.h>
#include <stdint.h>
#include <stdio.h>
#include <string.h>

/* SAME_TYPE(e, T) is 1 when the unevaluated expression e has exactly type T. */
#ifdef __cplusplus
template <typename A, typename B> struct vt_same { enum { value = 0 }; };
template <typename A> struct vt_same<A, A> { enum { value = 1 }; };
#define SAME_TYPE(e, T) ((int)vt_same<decltype(e), T>::value)
#else
#define SAME_TYPE(e, T) _Generic((e), T: 1, default: 0)
#endif

#ifdef __cplusplus
extern "C" {
#endif

void dpi_check_svdpi_header(void)
{
    printf("scalar types: svBit and svLogic are unsigned 8-bit %d %d\n",
           SAME_TYPE((svBit)0, uint8_t) && sizeof(svBit) == 1,
           SAME_TYPE((svLogic)0, uint8_t) && sizeof(svLogic) == 1);
    printf("vector types: svBitVecVal uint32_t, svLogicVecVal two of it %d %d\n",
           SAME_TYPE((svBitVecVal)0, uint32_t) && sizeof(svBitVecVal) == 4,
           SAME_TYPE(((svLogicVecVal *)0)->aval, uint32_t) &&
           SAME_TYPE(((svLogicVecVal *)0)->bval, uint32_t) &&
           offsetof(svLogicVecVal, aval) < offsetof(svLogicVecVal, bval) &&
           sizeof(svLogicVecVal) == 2 * sizeof(uint32_t));
    printf("reference types: svScope and svOpenArrayHandle are void* %d %d\n",
           SAME_TYPE((svScope)0, void *), SAME_TYPE((svOpenArrayHandle)0, void *));
    printf("canonical constants sv_0 sv_1 sv_z sv_x are 0 1 2 3 %d\n",
           sv_0 == 0 && sv_1 == 1 && sv_z == 2 && sv_x == 3);
    printf("chunks of 1 32 33 64 65 bits %d %d %d %d %d\n",
           SV_PACKED_DATA_NELEMS(1), SV_PACKED_DATA_NELEMS(32),
           SV_PACKED_DATA_NELEMS(33), SV_PACKED_DATA_NELEMS(64),
           SV_PACKED_DATA_NELEMS(65));
    printf("masks and bit extraction %u %u %u %u\n",
           (unsigned)SV_MASK(8), (unsigned)SV_GET_UNSIGNED_BITS(0x12345678u, 8),
           (unsigned)SV_GET_SIGNED_BITS(0x0000007fu, 8),
           (unsigned)SV_GET_SIGNED_BITS(0x180u, 8));

    {
        const char *version = svDpiVersion();
        printf("version 1800-2005 %d %d\n",
               SAME_TYPE(&svDpiVersion, const char *(*)(void)),
               version != NULL && strcmp(version, "1800-2005") == 0);
    }

    printf("scope routines %d %d %d\n",
           SAME_TYPE(&svGetScope, svScope (*)(void)) &&
           SAME_TYPE(&svSetScope, svScope (*)(svScope)) &&
           SAME_TYPE(&svGetNameFromScope, const char *(*)(svScope)) &&
           SAME_TYPE(&svGetScopeFromName, svScope (*)(const char *)),
           SAME_TYPE(&svPutUserData, int (*)(svScope, void *, void *)) &&
           SAME_TYPE(&svGetUserData, void *(*)(svScope, void *)),
           SAME_TYPE(&svGetCallerInfo, int (*)(const char **, int *)) &&
           SAME_TYPE(&svIsDisabledState, int (*)(void)) &&
           SAME_TYPE(&svAckDisabledState, void (*)(void)) &&
           SAME_TYPE(&svGetTime, int (*)(svScope, svTimeVal *)));
    printf("open array routines %d %d %d\n",
           SAME_TYPE(&svLeft, int (*)(svOpenArrayHandle, int)) &&
           SAME_TYPE(&svRight, int (*)(svOpenArrayHandle, int)) &&
           SAME_TYPE(&svLow, int (*)(svOpenArrayHandle, int)) &&
           SAME_TYPE(&svHigh, int (*)(svOpenArrayHandle, int)) &&
           SAME_TYPE(&svIncrement, int (*)(svOpenArrayHandle, int)) &&
           SAME_TYPE(&svSize, int (*)(svOpenArrayHandle, int)) &&
           SAME_TYPE(&svDimensions, int (*)(svOpenArrayHandle)),
           SAME_TYPE(&svGetArrayPtr, void *(*)(svOpenArrayHandle)) &&
           SAME_TYPE(&svSizeOfArray, int (*)(svOpenArrayHandle)),
           SAME_TYPE(&svGetArrElemPtr1, void *(*)(svOpenArrayHandle, int)) &&
           SAME_TYPE(&svGetArrElemPtr2,
                     void *(*)(svOpenArrayHandle, int, int)) &&
           SAME_TYPE(&svGetArrElemPtr3,
                     void *(*)(svOpenArrayHandle, int, int, int)));
    printf("element value routines %d %d %d\n",
           SAME_TYPE(&svGetBitArrElem1, svBit (*)(svOpenArrayHandle, int)) &&
           SAME_TYPE(&svPutBitArrElem1,
                     void (*)(svOpenArrayHandle, svBit, int)) &&
           SAME_TYPE(&svGetBitArrElemVecVal,
                     void (*)(svBitVecVal *, svOpenArrayHandle, int, ...)),
           SAME_TYPE(&svGetLogicArrElem1, svLogic (*)(svOpenArrayHandle, int)) &&
           SAME_TYPE(&svPutLogicArrElem1,
                     void (*)(svOpenArrayHandle, svLogic, int)) &&
           SAME_TYPE(&svGetLogicArrElem2VecVal,
                     void (*)(svLogicVecVal *, svOpenArrayHandle, int, int)) &&
           SAME_TYPE(&svPutLogicArrElemVecVal,
                     void (*)(svOpenArrayHandle, const svLogicVecVal *, int, ...)),
           SAME_TYPE(&svPutBitArrElem2VecVal,
                     void (*)(svOpenArrayHandle, const svBitVecVal *, int, int)));
    printf("canonical bit and part select routines %d %d %d\n",
           SAME_TYPE(&svGetBitselBit, svBit (*)(const svBitVecVal *, int)) &&
           SAME_TYPE(&svPutBitselBit, void (*)(svBitVecVal *, int, svBit)) &&
           SAME_TYPE(&svGetBitselLogic, svLogic (*)(const svLogicVecVal *, int)) &&
           SAME_TYPE(&svPutBitselLogic, void (*)(svLogicVecVal *, int, svLogic)),
           SAME_TYPE(&svGetPartselBit,
                     void (*)(svBitVecVal *, const svBitVecVal *, int, int)) &&
           SAME_TYPE(&svGetPartselLogic,
                     void (*)(svLogicVecVal *, const svLogicVecVal *, int, int)),
           SAME_TYPE(&svPutPartselBit,
                     void (*)(svBitVecVal *, svBitVecVal, int, int)) &&
           SAME_TYPE(&svPutPartselLogic,
                     void (*)(svLogicVecVal *, svLogicVecVal, int, int)));
    fflush(stdout);
}

#ifdef __cplusplus
}
#endif
