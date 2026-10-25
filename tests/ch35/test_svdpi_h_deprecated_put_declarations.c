/* C side of test_svdpi_h_deprecated_put_declarations (IEEE 1800-2023 35.3.2, I.3). */
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

void dpi_check_deprecated_put(void)
{
    printf("svPutBitVec32: void (bitref, const svBitVec32*, int) %d\n",
           SAME_TYPE(&svPutBitVec32, void (*)(bitref, const svBitVec32*, int)));
    printf("svPutLogicVec32: void (logicref, const svLogicVec32*, int) %d\n",
           SAME_TYPE(&svPutLogicVec32, void (*)(logicref, const svLogicVec32*, int)));
    printf("svPutSelectBit: void (bitref, int, svBit) %d\n",
           SAME_TYPE(&svPutSelectBit, void (*)(bitref, int, svBit)));
    printf("svPutSelectLogic: void (logicref, int, svLogic) %d\n",
           SAME_TYPE(&svPutSelectLogic, void (*)(logicref, int, svLogic)));
    printf("svPutPartSelectBit: void (bitref, svBitVec32, int, int) %d\n",
           SAME_TYPE(&svPutPartSelectBit, void (*)(bitref, svBitVec32, int, int)));
    printf("svPutPartSelectLogic: void (logicref, svLogicVec32, int, int) %d\n",
           SAME_TYPE(&svPutPartSelectLogic, void (*)(logicref, svLogicVec32, int, int)));
    printf("svPutBitArrElemVec32: void (svOpenArrayHandle, const svBitVec32*, int, ...) %d\n",
           SAME_TYPE(&svPutBitArrElemVec32,
                     void (*)(svOpenArrayHandle, const svBitVec32*, int, ...)));
    printf("svPutBitArrElem1Vec32: void (svOpenArrayHandle, const svBitVec32*, int) %d\n",
           SAME_TYPE(&svPutBitArrElem1Vec32,
                     void (*)(svOpenArrayHandle, const svBitVec32*, int)));
    printf("svPutBitArrElem2Vec32: void (svOpenArrayHandle, const svBitVec32*, int, int) %d\n",
           SAME_TYPE(&svPutBitArrElem2Vec32,
                     void (*)(svOpenArrayHandle, const svBitVec32*, int, int)));
    printf("svPutBitArrElem3Vec32: void (svOpenArrayHandle, const svBitVec32*, int, int, int) %d\n",
           SAME_TYPE(&svPutBitArrElem3Vec32,
                     void (*)(svOpenArrayHandle, const svBitVec32*, int, int, int)));
    printf("svPutLogicArrElemVec32: void (svOpenArrayHandle, const svLogicVec32*, int, ...) %d\n",
           SAME_TYPE(&svPutLogicArrElemVec32,
                     void (*)(svOpenArrayHandle, const svLogicVec32*, int, ...)));
    printf("svPutLogicArrElem1Vec32: void (svOpenArrayHandle, const svLogicVec32*, int) %d\n",
           SAME_TYPE(&svPutLogicArrElem1Vec32,
                     void (*)(svOpenArrayHandle, const svLogicVec32*, int)));
    printf("svPutLogicArrElem2Vec32: void (svOpenArrayHandle, const svLogicVec32*, int, int) %d\n",
           SAME_TYPE(&svPutLogicArrElem2Vec32,
                     void (*)(svOpenArrayHandle, const svLogicVec32*, int, int)));
    printf("svPutLogicArrElem3Vec32: void (svOpenArrayHandle, const svLogicVec32*, int, int, int) %d\n",
           SAME_TYPE(&svPutLogicArrElem3Vec32,
                     void (*)(svOpenArrayHandle, const svLogicVec32*, int, int, int)));
    fflush(stdout);
}

#ifdef __cplusplus
}
#endif
