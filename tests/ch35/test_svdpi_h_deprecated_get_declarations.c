/* C side of test_svdpi_h_deprecated_get_declarations (IEEE 1800-2023 35.3.2, I.3). */
#include "svdpi.h"
#include <stdio.h>

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

/* The pointer types of the packed-array routine parameters. */
typedef svBitPackedArrRef bitref;
typedef svLogicPackedArrRef logicref;

void dpi_check_deprecated_get(void)
{
    printf("svSizeOfBitPackedArr: int (int) %d\n",
           SAME_TYPE(&svSizeOfBitPackedArr, int (*)(int)));
    printf("svSizeOfLogicPackedArr: int (int) %d\n",
           SAME_TYPE(&svSizeOfLogicPackedArr, int (*)(int)));
    printf("svGetBitVec32: void (svBitVec32*, bitref, int) %d\n",
           SAME_TYPE(&svGetBitVec32, void (*)(svBitVec32*, bitref, int)));
    printf("svGetLogicVec32: void (svLogicVec32*, logicref, int) %d\n",
           SAME_TYPE(&svGetLogicVec32, void (*)(svLogicVec32*, logicref, int)));
    printf("svGetSelectBit: svBit (bitref, int) %d\n",
           SAME_TYPE(&svGetSelectBit, svBit (*)(bitref, int)));
    printf("svGetSelectLogic: svLogic (logicref, int) %d\n",
           SAME_TYPE(&svGetSelectLogic, svLogic (*)(logicref, int)));
    printf("svGetPartSelectBit: void (svBitVec32*, bitref, int, int) %d\n",
           SAME_TYPE(&svGetPartSelectBit, void (*)(svBitVec32*, bitref, int, int)));
    printf("svGetPartSelectLogic: void (svLogicVec32*, logicref, int, int) %d\n",
           SAME_TYPE(&svGetPartSelectLogic, void (*)(svLogicVec32*, logicref, int, int)));
    printf("svGetBits: svBitVec32 (bitref, int, int) %d\n",
           SAME_TYPE(&svGetBits, svBitVec32 (*)(bitref, int, int)));
    printf("svGet32Bits: svBitVec32 (bitref, int) %d\n",
           SAME_TYPE(&svGet32Bits, svBitVec32 (*)(bitref, int)));
    printf("svGet64Bits: uint64_t (bitref, int) %d\n",
           SAME_TYPE(&svGet64Bits, uint64_t (*)(bitref, int)));
    printf("svGetBitArrElemVec32: void (svBitVec32*, svOpenArrayHandle, int, ...) %d\n",
           SAME_TYPE(&svGetBitArrElemVec32,
                     void (*)(svBitVec32*, svOpenArrayHandle, int, ...)));
    printf("svGetBitArrElem1Vec32: void (svBitVec32*, svOpenArrayHandle, int) %d\n",
           SAME_TYPE(&svGetBitArrElem1Vec32,
                     void (*)(svBitVec32*, svOpenArrayHandle, int)));
    printf("svGetBitArrElem2Vec32: void (svBitVec32*, svOpenArrayHandle, int, int) %d\n",
           SAME_TYPE(&svGetBitArrElem2Vec32,
                     void (*)(svBitVec32*, svOpenArrayHandle, int, int)));
    printf("svGetBitArrElem3Vec32: void (svBitVec32*, svOpenArrayHandle, int, int, int) %d\n",
           SAME_TYPE(&svGetBitArrElem3Vec32,
                     void (*)(svBitVec32*, svOpenArrayHandle, int, int, int)));
    printf("svGetLogicArrElemVec32: void (svLogicVec32*, svOpenArrayHandle, int, ...) %d\n",
           SAME_TYPE(&svGetLogicArrElemVec32,
                     void (*)(svLogicVec32*, svOpenArrayHandle, int, ...)));
    printf("svGetLogicArrElem1Vec32: void (svLogicVec32*, svOpenArrayHandle, int) %d\n",
           SAME_TYPE(&svGetLogicArrElem1Vec32,
                     void (*)(svLogicVec32*, svOpenArrayHandle, int)));
    printf("svGetLogicArrElem2Vec32: void (svLogicVec32*, svOpenArrayHandle, int, int) %d\n",
           SAME_TYPE(&svGetLogicArrElem2Vec32,
                     void (*)(svLogicVec32*, svOpenArrayHandle, int, int)));
    printf("svGetLogicArrElem3Vec32: void (svLogicVec32*, svOpenArrayHandle, int, int, int) %d\n",
           SAME_TYPE(&svGetLogicArrElem3Vec32,
                     void (*)(svLogicVec32*, svOpenArrayHandle, int, int, int)));
    fflush(stdout);
}

#ifdef __cplusplus
}
#endif
