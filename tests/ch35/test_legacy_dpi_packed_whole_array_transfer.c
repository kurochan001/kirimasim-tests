#include <inttypes.h>
#include <stdio.h>
#include <stdlib.h>
#include "svdpi.h"

#ifdef __cplusplus
#include <type_traits>
#define CHECK_TYPE(name, type) static_assert(std::is_same<decltype(&name), type>::value, #name)
extern "C" {
#else
#define CHECK_TYPE(name, type) _Static_assert(_Generic(&name, type: 1, default: 0), #name)
#endif

CHECK_TYPE(svSizeOfBitPackedArr, int (*)(int));
CHECK_TYPE(svSizeOfLogicPackedArr, int (*)(int));
CHECK_TYPE(svGetBitVec32, void (*)(svBitVec32 *, svBitPackedArrRef, int));
CHECK_TYPE(svGetLogicVec32, void (*)(svLogicVec32 *, svLogicPackedArrRef, int));
CHECK_TYPE(svPutBitVec32, void (*)(svBitPackedArrRef, const svBitVec32 *, int));
CHECK_TYPE(svPutLogicVec32, void (*)(svLogicPackedArrRef, const svLogicVec32 *, int));
#undef CHECK_TYPE

void legacy_copy(const svBitPackedArrRef bit_input,
                 const svLogicPackedArrRef logic_input,
                 svBitPackedArrRef bit_output, svLogicPackedArrRef logic_output)
{
    enum { width = 45, chunks = SV_CANONICAL_SIZE(width) };
    svBitVec32 bits[chunks] = {0};
    svLogicVec32 logic[chunks] = {{0, 0}};
    int bit_size = svSizeOfBitPackedArr(width);
    int logic_size = svSizeOfLogicPackedArr(width);
    printf("positive sizes bit=%d logic=%d\n", bit_size > 0, logic_size > 0);
    if (bit_size <= 0 || logic_size <= 0)
        return;

    svGetBitVec32(bits, bit_input, width);
    svGetLogicVec32(logic, logic_input, width);
    printf("read bit=%04x_%08x logic=%04x/%04x_%08x/%08x\n",
           bits[1] & 0x1fff, bits[0], logic[1].c & 0x1fff, logic[1].d & 0x1fff,
           logic[0].c, logic[0].d);

    const svBitVec32 new_bits[chunks] = {0x89abcdef, 0x056a};
    const svLogicVec32 new_logic[chunks] = {{0x89f42067, 0x00f00f00}, {0x1037, 0x0f00}};
    svPutBitVec32(bit_output, new_bits, width);
    svPutLogicVec32(logic_output, new_logic, width);
    fflush(stdout);
}

#ifdef __cplusplus
}
#endif
