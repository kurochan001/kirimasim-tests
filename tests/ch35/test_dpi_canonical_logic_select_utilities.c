/* C side of test_dpi_canonical_logic_select_utilities (IEEE 1800-2023 H.11.5). */
#include <stdio.h>
#include "svdpi.h"

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

typedef svLogic (*get_bitsel_logic_t)(const svLogicVecVal *, int);
typedef void (*put_bitsel_logic_t)(svLogicVecVal *, int, svLogic);
typedef void (*get_partsel_logic_t)(svLogicVecVal *, const svLogicVecVal *, int, int);
typedef void (*put_partsel_logic_t)(svLogicVecVal *, const svLogicVecVal, int, int);
typedef void (*put_partsel_bit_t)(svBitVecVal *, const svBitVecVal, int, int);

static void source(svLogicVecVal *s)
{
    s[0].aval = 0x9abcdef0u;
    s[0].bval = 0x0000f00fu;
    s[1].aval = 0x000000c5u;
    s[1].bval = 0x0000005au;
}

void c_run(void)
{
    svLogicVecVal s[2], d[2], one;
    svBitVecVal b[2], w;
    int i;

    printf("svGetBitselLogic: svLogic (const svLogicVecVal*, int) %d\n",
           SAME_TYPE(&svGetBitselLogic, get_bitsel_logic_t));
    printf("svPutBitselLogic: void (svLogicVecVal*, int, svLogic) %d\n",
           SAME_TYPE(&svPutBitselLogic, put_bitsel_logic_t));
    printf("svGetPartselLogic: void (svLogicVecVal*, const svLogicVecVal*, int, int) %d\n",
           SAME_TYPE(&svGetPartselLogic, get_partsel_logic_t));
    printf("svPutPartselLogic: void (svLogicVecVal*, const svLogicVecVal, int, int) %d\n",
           SAME_TYPE(&svPutPartselLogic, put_partsel_logic_t));
    printf("svPutPartselBit: void (svBitVecVal*, const svBitVecVal, int, int) %d\n",
           SAME_TYPE(&svPutPartselBit, put_partsel_bit_t));

    /* Bit selects of the 4-state source, in both chunks. */
    source(s);
    printf("svGetBitselLogic of bits 0 to 7:");
    for (i = 0; i < 8; i++)
        printf(" %d", (int)svGetBitselLogic(s, i));
    printf("\nsvGetBitselLogic of bits 32 to 39:");
    for (i = 32; i < 40; i++)
        printf(" %d", (int)svGetBitselLogic(s, i));
    printf("\n");

    /* x into bit 33, z into bit 4, 1 into bit 12 (an x), 0 into bit 39. */
    svPutBitselLogic(s, 33, sv_x);
    svPutBitselLogic(s, 4, sv_z);
    svPutBitselLogic(s, 12, sv_1);
    svPutBitselLogic(s, 39, sv_0);
    printf("svPutBitselLogic: aval %08x %08x, bval %08x %08x\n", (unsigned)s[0].aval,
           (unsigned)s[1].aval, (unsigned)s[0].bval, (unsigned)s[1].bval);

    /* Gets of bits 35:28, across the chunk boundary, into a zero word, and of
       32 bits 35:4, which replace the whole word. */
    source(s);
    d[0].aval = 0;
    d[0].bval = 0;
    svGetPartselLogic(&d[0], s, 28, 8);
    printf("svGetPartselLogic of 35:28: aval %08x, bval %08x\n", (unsigned)d[0].aval,
           (unsigned)d[0].bval);
    d[0].aval = 0xaaaaaa55u;
    d[0].bval = 0x5555aa00u;
    svGetPartselLogic(&d[0], s, 4, 32);
    printf("svGetPartselLogic of 35:4: aval %08x, bval %08x\n", (unsigned)d[0].aval,
           (unsigned)d[0].bval);

    /* Put of 4 bits into 33:30; only the low 4 bits of the source count. */
    d[0].aval = 0x11111111u;
    d[1].aval = 0x22222222u;
    d[0].bval = 0x33333333u;
    d[1].bval = 0x44444444u;
    one.aval = 0xfffffff6u;
    one.bval = 0xfffffffcu;
    svPutPartselLogic(d, one, 30, 4);
    printf("svPutPartselLogic into 33:30: aval %08x %08x, bval %08x %08x\n",
           (unsigned)d[0].aval, (unsigned)d[1].aval, (unsigned)d[0].bval, (unsigned)d[1].bval);

    /* Puts of 8 bits into 19:12 of all ones and into 35:28 of all zeros. */
    b[0] = 0xffffffffu;
    b[1] = 0xffffffffu;
    svPutPartselBit(b, 0xffffff3cu, 12, 8);
    printf("svPutPartselBit into 19:12: %08x %08x\n", (unsigned)b[0], (unsigned)b[1]);
    b[0] = 0;
    b[1] = 0;
    svPutPartselBit(b, 0xa5u, 28, 8);
    printf("svPutPartselBit into 35:28: %08x %08x\n", (unsigned)b[0], (unsigned)b[1]);

    /* Puts of all 32 bits of the source word into 35:4. */
    b[0] = 0;
    b[1] = 0;
    svPutPartselBit(b, 0x89abcdefu, 4, 32);
    printf("svPutPartselBit of 32 bits into 35:4: %08x %08x\n", (unsigned)b[0], (unsigned)b[1]);
    d[0].aval = 0xffffffffu;
    d[1].aval = 0xffffffffu;
    d[0].bval = 0;
    d[1].bval = 0;
    one.aval = 0x12345678u;
    one.bval = 0x0000ffffu;
    svPutPartselLogic(d, one, 4, 32);
    printf("svPutPartselLogic of 32 bits into 35:4: aval %08x %08x, bval %08x %08x\n",
           (unsigned)d[0].aval, (unsigned)d[1].aval, (unsigned)d[0].bval, (unsigned)d[1].bval);

    /* Gets of 2-state part-selects of 8, 32 and 1 bits. That the bits above w
       stay as they were is checked by test_dpi_canonical_partsel_get_keeps_bits. */
    b[0] = 0x12345678u;
    b[1] = 0x9abcdef0u;
    w = 0;
    svGetPartselBit(&w, b, 28, 8);
    printf("svGetPartselBit of 35:28: %08x\n", (unsigned)w);
    w = 0xffffffffu;
    svGetPartselBit(&w, b, 0, 32);
    printf("svGetPartselBit of 31:0: %08x\n", (unsigned)w);
    w = 0;
    svGetPartselBit(&w, b, 36, 1);
    printf("svGetPartselBit of 36:36: %08x\n", (unsigned)w);
    fflush(stdout);
}

#ifdef __cplusplus
}
#endif
