/* C side of test_svdpi_h_declarations (IEEE 1800-2023 35.3.2, H.10.1, I.3). */
#include "svdpi.h"

/* uint8_t and uint32_t have to come from the header itself. */
typedef uint8_t vt_uint8;
typedef uint32_t vt_uint32;
/* What the preprocessor sees right after the header, before anything else. */
#ifdef VPI_VECVAL
#define VECVAL_DEFINED 1
#else
#define VECVAL_DEFINED 0
#endif
#ifdef VPI_TIME
#define TIME_DEFINED 1
#else
#define TIME_DEFINED 0
#endif
#ifdef DPI_EXTERN
#define DPI_EXTERN_GONE 0
#else
#define DPI_EXTERN_GONE 1
#endif
#if defined(DPI_PROTOTYPES) || defined(XXTERN) || defined(EETERN)
#define DPI_PROTOTYPES_GONE 0
#else
#define DPI_PROTOTYPES_GONE 1
#endif
/* #if takes an undefined name as 0, so each name is also checked with defined. */
#if defined(sv_0) && defined(sv_1) && defined(sv_z) && defined(sv_x) \
    && sv_0 == 0 && sv_1 == 1 && sv_z == 2 && sv_x == 3
#define SCALARS_OK 1
#else
#define SCALARS_OK 0
#endif
/* The same values as C constants: a name that is not a macro for an integer
   constant, which #if would take as 0, does not compile here. */
enum { vt_sv_0 = sv_0, vt_sv_1 = sv_1, vt_sv_z = sv_z, vt_sv_x = sv_x };
/* A second inclusion has to change nothing. sv_x is given another value
   first: a header without its include guard would define it again. */
#undef sv_x
#define sv_x 99
#include "svdpi.h"
#if defined(INCLUDED_SVDPI) && sv_x == 99
#define GUARD_OK 1
#else
#define GUARD_OK 0
#endif
#undef sv_x
#define sv_x 3
#include <stddef.h>
#include <stdio.h>
#include <string.h>

/* SAME_TYPE(e, T) is 1 when the unevaluated expression e has exactly type T.
   Nothing is called or linked: only the declarations of the header are used. */
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

#define CHECK(what, ok) printf("%s %d\n", what, (int)(ok))

void dpi_check_svdpi(void)
{
    const char *v = svDpiVersion();

    CHECK("INCLUDED_SVDPI defined and a second include changes nothing",
          GUARD_OK);
    CHECK("DPI_EXTERN undefined after the header",
          DPI_EXTERN_GONE);
    CHECK("DPI_PROTOTYPES XXTERN EETERN undefined after the header",
          DPI_PROTOTYPES_GONE);
    CHECK("uint8_t and uint32_t available with sizes 1 and 4",
          sizeof(vt_uint8) == 1 && sizeof(vt_uint32) == 4 && (vt_uint8)-1 == 255 && (vt_uint32)-1
          == 4294967295u);
    CHECK("sv_0 sv_1 sv_z sv_x are 0 1 2 3",
          SCALARS_OK && vt_sv_0 == 0 && vt_sv_1 == 1 && vt_sv_z == 2 && vt_sv_x == 3);
    CHECK("svScalar is uint8_t",
          SAME_TYPE((svScalar)0, uint8_t));
    CHECK("svBit and svLogic are svScalar",
          SAME_TYPE((svBit)0, svScalar) && SAME_TYPE((svLogic)0, svScalar));
    CHECK("svBitVecVal is uint32_t",
          SAME_TYPE((svBitVecVal)0, uint32_t));
    CHECK("VPI_VECVAL defined",
          VECVAL_DEFINED);
    CHECK("t_vpi_vecval aliases s_vpi_vecval p_vpi_vecval",
          SAME_TYPE((s_vpi_vecval *)0, struct t_vpi_vecval *) && SAME_TYPE((p_vpi_vecval)0, struct
          t_vpi_vecval *));
    CHECK("t_vpi_vecval aval bval uint32_t in this order",
          SAME_TYPE(((s_vpi_vecval *)0)->aval, uint32_t) && SAME_TYPE(((s_vpi_vecval *)0)->bval,
          uint32_t) && offsetof(s_vpi_vecval, aval) < offsetof(s_vpi_vecval, bval));
    CHECK("svLogicVecVal is s_vpi_vecval",
          SAME_TYPE((svLogicVecVal *)0, s_vpi_vecval *));
    CHECK("SV_PACKED_DATA_NELEMS of 1 32 33 64 65 is 1 1 2 2 3",
          SV_PACKED_DATA_NELEMS(1) == 1 && SV_PACKED_DATA_NELEMS(32) == 1 &&
          SV_PACKED_DATA_NELEMS(33) == 2 && SV_PACKED_DATA_NELEMS(64) == 2 &&
          SV_PACKED_DATA_NELEMS(65) == 3);
    CHECK("SV_GET_UNSIGNED_BITS of 0xabcd1234 with 32 8 1 is 0xabcd1234 0x34 0x0",
          SV_GET_UNSIGNED_BITS(0xabcd1234u, 32) == 0xabcd1234u &&
          SV_GET_UNSIGNED_BITS(0xabcd1234u, 8) == 0x34u && SV_GET_UNSIGNED_BITS(0xabcd1234u, 1) ==
          0x0u);
    CHECK("VPI_TIME defined",
          TIME_DEFINED);
    CHECK("t_vpi_time aliases s_vpi_time p_vpi_time",
          SAME_TYPE((s_vpi_time *)0, struct t_vpi_time *) && SAME_TYPE((p_vpi_time)0, struct
          t_vpi_time *));
    CHECK("t_vpi_time type int32_t high low uint32_t real double in this order",
          SAME_TYPE(((s_vpi_time *)0)->type, int32_t) && SAME_TYPE(((s_vpi_time *)0)->high,
          uint32_t) && SAME_TYPE(((s_vpi_time *)0)->low, uint32_t) && SAME_TYPE(((s_vpi_time
          *)0)->real, double) && offsetof(s_vpi_time, type) < offsetof(s_vpi_time, high) &&
          offsetof(s_vpi_time, high) < offsetof(s_vpi_time, low) && offsetof(s_vpi_time, low) <
          offsetof(s_vpi_time, real));
    CHECK("vpiScaledRealTime vpiSimTime vpiSuppressTime are 1 2 3",
          vpiScaledRealTime == 1 && vpiSimTime == 2 && vpiSuppressTime == 3);
    CHECK("svTimeVal is s_vpi_time",
          SAME_TYPE((svTimeVal *)0, s_vpi_time *));
    CHECK("sv_scaled_real_time sv_sim_time are vpiScaledRealTime vpiSimTime",
          sv_scaled_real_time == vpiScaledRealTime && sv_sim_time == vpiSimTime);
    CHECK("svAckDisabledState: void (void)",
          SAME_TYPE(&svAckDisabledState, void (*)(void)));
    CHECK("svDimensions: int (const svOpenArrayHandle h)",
          SAME_TYPE(&svDimensions, int (*)(const svOpenArrayHandle h)));
    CHECK("svDpiVersion: const char* (void)",
          SAME_TYPE(&svDpiVersion, const char* (*)(void)));
    CHECK("svGetArrElemPtr: void * (const svOpenArrayHandle, int indx1, ...)",
          SAME_TYPE(&svGetArrElemPtr, void * (*)(const svOpenArrayHandle, int indx1, ...)));
    CHECK("svGetArrElemPtr1: void * (const svOpenArrayHandle, int indx1)",
          SAME_TYPE(&svGetArrElemPtr1, void * (*)(const svOpenArrayHandle, int indx1)));
    CHECK("svGetArrElemPtr2: void * (const svOpenArrayHandle, int indx1, int indx2)",
          SAME_TYPE(&svGetArrElemPtr2, void * (*)(const svOpenArrayHandle, int indx1, int
          indx2)));
    CHECK("svGetArrElemPtr3: void * (const svOpenArrayHandle, int indx1, int indx2, int indx3)",
          SAME_TYPE(&svGetArrElemPtr3, void * (*)(const svOpenArrayHandle, int indx1, int indx2,
          int indx3)));
    CHECK("svGetArrayPtr: void * (const svOpenArrayHandle)",
          SAME_TYPE(&svGetArrayPtr, void * (*)(const svOpenArrayHandle)));
    CHECK("svGetBitArrElem: svBit (const svOpenArrayHandle s, int indx1, ...)",
          SAME_TYPE(&svGetBitArrElem, svBit (*)(const svOpenArrayHandle s, int indx1, ...)));
    CHECK("svGetBitArrElem1: svBit (const svOpenArrayHandle s, int indx1)",
          SAME_TYPE(&svGetBitArrElem1, svBit (*)(const svOpenArrayHandle s, int indx1)));
    CHECK("svGetBitArrElem1VecVal: void (svBitVecVal* d, const svOpenArrayHandle s, int indx1)",
          SAME_TYPE(&svGetBitArrElem1VecVal, void (*)(svBitVecVal* d, const svOpenArrayHandle s,
          int indx1)));
    CHECK("svGetBitArrElem2: svBit (const svOpenArrayHandle s, int indx1, int indx2)",
          SAME_TYPE(&svGetBitArrElem2, svBit (*)(const svOpenArrayHandle s, int indx1, int
          indx2)));
    CHECK("svGetBitArrElem2VecVal",
          SAME_TYPE(&svGetBitArrElem2VecVal, void (*)(svBitVecVal* d, const svOpenArrayHandle s,
          int indx1, int indx2)));
    CHECK("svGetBitArrElem3: svBit (const svOpenArrayHandle s, int indx1, int indx2, int indx3)",
          SAME_TYPE(&svGetBitArrElem3, svBit (*)(const svOpenArrayHandle s, int indx1, int indx2,
          int indx3)));
    CHECK("svGetBitArrElem3VecVal",
          SAME_TYPE(&svGetBitArrElem3VecVal, void (*)(svBitVecVal* d, const svOpenArrayHandle s,
          int indx1, int indx2, int indx3)));
    CHECK("svGetBitArrElemVecVal: void (svBitVecVal* d, const svOpenArrayHandle s, int indx1, ...)",
          SAME_TYPE(&svGetBitArrElemVecVal, void (*)(svBitVecVal* d, const svOpenArrayHandle s,
          int indx1, ...)));
    CHECK("svGetBitselBit: svBit (const svBitVecVal* s, int i)",
          SAME_TYPE(&svGetBitselBit, svBit (*)(const svBitVecVal* s, int i)));
    CHECK("svGetBitselLogic: svLogic (const svLogicVecVal* s, int i)",
          SAME_TYPE(&svGetBitselLogic, svLogic (*)(const svLogicVecVal* s, int i)));
    CHECK("svGetCallerInfo: int (const char** fileName, int *lineNumber)",
          SAME_TYPE(&svGetCallerInfo, int (*)(const char** fileName, int *lineNumber)));
    CHECK("svGetLogicArrElem: svLogic (const svOpenArrayHandle s, int indx1, ...)",
          SAME_TYPE(&svGetLogicArrElem, svLogic (*)(const svOpenArrayHandle s, int indx1, ...)));
    CHECK("svGetLogicArrElem1: svLogic (const svOpenArrayHandle s, int indx1)",
          SAME_TYPE(&svGetLogicArrElem1, svLogic (*)(const svOpenArrayHandle s, int indx1)));
    CHECK("svGetLogicArrElem1VecVal: void (svLogicVecVal* d, const svOpenArrayHandle s, int indx1)",
          SAME_TYPE(&svGetLogicArrElem1VecVal, void (*)(svLogicVecVal* d, const svOpenArrayHandle
          s, int indx1)));
    CHECK("svGetLogicArrElem2: svLogic (const svOpenArrayHandle s, int indx1, int indx2)",
          SAME_TYPE(&svGetLogicArrElem2, svLogic (*)(const svOpenArrayHandle s, int indx1, int
          indx2)));
    CHECK("svGetLogicArrElem2VecVal",
          SAME_TYPE(&svGetLogicArrElem2VecVal, void (*)(svLogicVecVal* d, const svOpenArrayHandle
          s, int indx1, int indx2)));
    CHECK("svGetLogicArrElem3: svLogic (const svOpenArrayHandle s, int indx1, int indx2, int indx3)",
          SAME_TYPE(&svGetLogicArrElem3, svLogic (*)(const svOpenArrayHandle s, int indx1, int
          indx2, int indx3)));
    CHECK("svGetLogicArrElem3VecVal",
          SAME_TYPE(&svGetLogicArrElem3VecVal, void (*)(svLogicVecVal* d, const svOpenArrayHandle
          s, int indx1, int indx2, int indx3)));
    CHECK("svGetLogicArrElemVecVal",
          SAME_TYPE(&svGetLogicArrElemVecVal, void (*)(svLogicVecVal* d, const svOpenArrayHandle
          s, int indx1, ...)));
    CHECK("svGetNameFromScope: const char* (const svScope)",
          SAME_TYPE(&svGetNameFromScope, const char* (*)(const svScope)));
    CHECK("svGetPartselBit: void (svBitVecVal* d, const svBitVecVal* s, int i, int w)",
          SAME_TYPE(&svGetPartselBit, void (*)(svBitVecVal* d, const svBitVecVal* s, int i, int
          w)));
    CHECK("svGetPartselLogic: void (svLogicVecVal* d, const svLogicVecVal* s, int i,int w)",
          SAME_TYPE(&svGetPartselLogic, void (*)(svLogicVecVal* d, const svLogicVecVal* s, int
          i,int w)));
    CHECK("svGetScope: svScope (void)",
          SAME_TYPE(&svGetScope, svScope (*)(void)));
    CHECK("svGetScopeFromName: svScope (const char* scopeName)",
          SAME_TYPE(&svGetScopeFromName, svScope (*)(const char* scopeName)));
    CHECK("svGetTime: int (const svScope scope, svTimeVal* time)",
          SAME_TYPE(&svGetTime, int (*)(const svScope scope, svTimeVal* time)));
    CHECK("svGetTimePrecision: int (const svScope scope, int32_t* time_precision)",
          SAME_TYPE(&svGetTimePrecision, int (*)(const svScope scope, int32_t* time_precision)));
    CHECK("svGetTimeUnit: int (const svScope scope, int32_t* time_unit)",
          SAME_TYPE(&svGetTimeUnit, int (*)(const svScope scope, int32_t* time_unit)));
    CHECK("svGetUserData: void* (const svScope scope, void* userKey)",
          SAME_TYPE(&svGetUserData, void* (*)(const svScope scope, void* userKey)));
    CHECK("svHigh: int (const svOpenArrayHandle h, int d)",
          SAME_TYPE(&svHigh, int (*)(const svOpenArrayHandle h, int d)));
    CHECK("svIncrement: int (const svOpenArrayHandle h, int d)",
          SAME_TYPE(&svIncrement, int (*)(const svOpenArrayHandle h, int d)));
    CHECK("svIsDisabledState: int (void)",
          SAME_TYPE(&svIsDisabledState, int (*)(void)));
    CHECK("svLeft: int (const svOpenArrayHandle h, int d)",
          SAME_TYPE(&svLeft, int (*)(const svOpenArrayHandle h, int d)));
    CHECK("svLow: int (const svOpenArrayHandle h, int d)",
          SAME_TYPE(&svLow, int (*)(const svOpenArrayHandle h, int d)));
    CHECK("svPutBitArrElem: void (const svOpenArrayHandle d, svBit value, int indx1, ...)",
          SAME_TYPE(&svPutBitArrElem, void (*)(const svOpenArrayHandle d, svBit value, int indx1,
          ...)));
    CHECK("svPutBitArrElem1: void (const svOpenArrayHandle d, svBit value, int indx1)",
          SAME_TYPE(&svPutBitArrElem1, void (*)(const svOpenArrayHandle d, svBit value, int
          indx1)));
    CHECK("svPutBitArrElem1VecVal: void (const svOpenArrayHandle d, const svBitVecVal* s, int indx1)",
          SAME_TYPE(&svPutBitArrElem1VecVal, void (*)(const svOpenArrayHandle d, const
          svBitVecVal* s, int indx1)));
    CHECK("svPutBitArrElem2: void (const svOpenArrayHandle d, svBit value, int indx1, int indx2)",
          SAME_TYPE(&svPutBitArrElem2, void (*)(const svOpenArrayHandle d, svBit value, int indx1,
          int indx2)));
    CHECK("svPutBitArrElem2VecVal",
          SAME_TYPE(&svPutBitArrElem2VecVal, void (*)(const svOpenArrayHandle d, const
          svBitVecVal* s, int indx1, int indx2)));
    CHECK("svPutBitArrElem3",
          SAME_TYPE(&svPutBitArrElem3, void (*)(const svOpenArrayHandle d, svBit value, int indx1,
          int indx2, int indx3)));
    CHECK("svPutBitArrElem3VecVal",
          SAME_TYPE(&svPutBitArrElem3VecVal, void (*)(const svOpenArrayHandle d, const
          svBitVecVal* s, int indx1, int indx2, int indx3)));
    CHECK("svPutBitArrElemVecVal",
          SAME_TYPE(&svPutBitArrElemVecVal, void (*)(const svOpenArrayHandle d, const svBitVecVal*
          s, int indx1, ...)));
    CHECK("svPutBitselBit: void (svBitVecVal* d, int i, svBit s)",
          SAME_TYPE(&svPutBitselBit, void (*)(svBitVecVal* d, int i, svBit s)));
    CHECK("svPutBitselLogic: void (svLogicVecVal* d, int i, svLogic s)",
          SAME_TYPE(&svPutBitselLogic, void (*)(svLogicVecVal* d, int i, svLogic s)));
    CHECK("svPutLogicArrElem: void (const svOpenArrayHandle d, svLogic value, int indx1, ...)",
          SAME_TYPE(&svPutLogicArrElem, void (*)(const svOpenArrayHandle d, svLogic value, int
          indx1, ...)));
    CHECK("svPutLogicArrElem1: void (const svOpenArrayHandle d, svLogic value, int indx1)",
          SAME_TYPE(&svPutLogicArrElem1, void (*)(const svOpenArrayHandle d, svLogic value, int
          indx1)));
    CHECK("svPutLogicArrElem1VecVal",
          SAME_TYPE(&svPutLogicArrElem1VecVal, void (*)(const svOpenArrayHandle d, const
          svLogicVecVal* s, int indx1)));
    CHECK("svPutLogicArrElem2: void (const svOpenArrayHandle d, svLogic value, int indx1, int indx2)",
          SAME_TYPE(&svPutLogicArrElem2, void (*)(const svOpenArrayHandle d, svLogic value, int
          indx1, int indx2)));
    CHECK("svPutLogicArrElem2VecVal",
          SAME_TYPE(&svPutLogicArrElem2VecVal, void (*)(const svOpenArrayHandle d, const
          svLogicVecVal* s, int indx1, int indx2)));
    CHECK("svPutLogicArrElem3",
          SAME_TYPE(&svPutLogicArrElem3, void (*)(const svOpenArrayHandle d, svLogic value, int
          indx1, int indx2, int indx3)));
    CHECK("svPutLogicArrElem3VecVal",
          SAME_TYPE(&svPutLogicArrElem3VecVal, void (*)(const svOpenArrayHandle d, const
          svLogicVecVal* s, int indx1, int indx2, int indx3)));
    CHECK("svPutLogicArrElemVecVal",
          SAME_TYPE(&svPutLogicArrElemVecVal, void (*)(const svOpenArrayHandle d, const
          svLogicVecVal* s, int indx1, ...)));
    CHECK("svPutPartselBit: void (svBitVecVal* d, const svBitVecVal s, int i, int w)",
          SAME_TYPE(&svPutPartselBit, void (*)(svBitVecVal* d, const svBitVecVal s, int i, int
          w)));
    CHECK("svPutPartselLogic: void (svLogicVecVal* d, const svLogicVecVal s, int i, int w)",
          SAME_TYPE(&svPutPartselLogic, void (*)(svLogicVecVal* d, const svLogicVecVal s, int i,
          int w)));
    CHECK("svPutUserData: int (const svScope scope, void *userKey, void* userData)",
          SAME_TYPE(&svPutUserData, int (*)(const svScope scope, void *userKey, void* userData)));
    CHECK("svRight: int (const svOpenArrayHandle h, int d)",
          SAME_TYPE(&svRight, int (*)(const svOpenArrayHandle h, int d)));
    CHECK("svSetScope: svScope (const svScope scope)",
          SAME_TYPE(&svSetScope, svScope (*)(const svScope scope)));
    CHECK("svSize: int (const svOpenArrayHandle h, int d)",
          SAME_TYPE(&svSize, int (*)(const svOpenArrayHandle h, int d)));
    CHECK("svSizeOfArray: int (const svOpenArrayHandle)",
          SAME_TYPE(&svSizeOfArray, int (*)(const svOpenArrayHandle)));
    CHECK("svDpiVersion returns 1800-2005 or SV3.1a",
          v != NULL && (strcmp(v, "1800-2005") == 0 || strcmp(v, "SV3.1a") == 0));
    fflush(stdout);
}

#ifdef __cplusplus
}
#endif
