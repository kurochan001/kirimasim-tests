typedef struct {
    char marker;
    long long serial;
    short short_field;
    double ratio;
    int last;
} native_t;

#ifdef DPI_STRUCT_LAYOUT_PROBE
#include <stddef.h>

const unsigned dpi_struct_layout[] = {
    offsetof(native_t, marker), offsetof(native_t, serial), offsetof(native_t, short_field),
    offsetof(native_t, ratio), offsetof(native_t, last), sizeof(native_t), _Alignof(native_t),
};
#else
#include <stdio.h>
#include "svdpi.h"

#ifdef __cplusplus
extern "C" {
#endif

void native_transfer(const native_t *src, native_t *dst)
{
    printf("native input=%d\n", src->marker == 9 && src->serial == -6000000003LL &&
           src->short_field == -1234 && src->ratio == 3.25 && src->last == -314159);
    dst->marker = 13;
    dst->serial = 6000000003LL;
    dst->short_field = -1231;
    dst->ratio = 6.50;
    dst->last = -314166;
    fflush(stdout);
}

static void packed_words(const char *label, const svLogicVecVal *src, svLogicVecVal *dst)
{
    printf("%s words=%08x/%08x,%x/%x\n", label,
           (unsigned)src[0].aval, (unsigned)src[0].bval,
           (unsigned)(src[1].aval & 3u), (unsigned)(src[1].bval & 3u));
    dst[0].aval = src[0].aval ^ 0x10u;
    dst[0].bval = src[0].bval;
    dst[1].aval = (src[1].aval ^ src[1].bval) & 3u;
    dst[1].bval = src[1].bval & 3u;
    fflush(stdout);
}

void packet_transfer(const svLogicVecVal *src, svLogicVecVal *dst)
{
    packed_words("packet", src, dst);
}

void grid_transfer(const svLogicVecVal *src, svLogicVecVal *dst)
{
    packed_words("grid", src, dst);
}

#ifdef __cplusplus
}
#endif
#endif
