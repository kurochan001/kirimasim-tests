#include <stdio.h>
#include "svdpi.h"

#ifdef __cplusplus
extern "C" {
#endif

enum { packed_width = 45, chunks = SV_CANONICAL_SIZE(packed_width) };

struct bit_storage {
    svBitVec32 words[chunks];
    unsigned sentinel;
};

struct logic_storage {
    svLogicVec32 words[chunks];
    unsigned sentinel;
};

static void report(const char *kind, const struct bit_storage *bits,
                   const struct logic_storage *logic)
{
    printf("%s bit=%04x_%08x logic=%04x/%04x_%08x/%08x\n", kind,
           bits->words[1] & 0x1fffu, bits->words[0],
           logic->words[1].c & 0x1fffu, logic->words[1].d & 0x1fffu,
           logic->words[0].c, logic->words[0].d);
}

void legacy_open_array_transfer(const svOpenArrayHandle flags, const svOpenArrayHandle atoms)
{
    const unsigned guard = 0x13579bdfu;
    struct bit_storage first_bits = {{0}, guard};
    struct bit_storage other_bits = {{0}, guard};
    struct logic_storage first_logic = {{{0, 0}}, guard};
    struct logic_storage other_logic = {{{0, 0}}, guard};

    svGetBitArrElem2Vec32(first_bits.words, flags, 5, -2);
    svGetLogicArrElem2Vec32(first_logic.words, atoms, 5, -2);
    svGetBitArrElemVec32(other_bits.words, flags, 4, -1);
    svGetLogicArrElemVec32(other_logic.words, atoms, 4, -1);
    report("specialized", &first_bits, &first_logic);
    report("variadic", &other_bits, &other_logic);
    printf("bounds kept bit=%d%d logic=%d%d\n",
           first_bits.sentinel == guard, other_bits.sentinel == guard,
           first_logic.sentinel == guard, other_logic.sentinel == guard);

    const svBitVec32 first_flag[chunks] = {0x5555aaaau, 0x1a0bu};
    const svLogicVec32 first_atom[chunks] = {{0x120000aau, 0x00ff0000u}, {0x07f2u, 0x00f0u}};
    const svBitVec32 other_flag[chunks] = {0xfedcba98u, 0x0033u};
    const svLogicVec32 other_atom[chunks] = {{0x0f345678u, 0xff000000u}, {0x0012u, 0}};
    svPutBitArrElem2Vec32(flags, first_flag, 4, -3);
    svPutLogicArrElem2Vec32(atoms, first_atom, 4, -3);
    svPutBitArrElemVec32(flags, other_flag, 5, -1);
    svPutLogicArrElemVec32(atoms, other_atom, 5, -1);
    fflush(stdout);
}

#ifdef __cplusplus
}
#endif
