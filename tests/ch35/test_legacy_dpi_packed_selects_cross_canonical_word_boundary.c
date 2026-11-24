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

CHECK_TYPE(svGetSelectBit, svBit (*)(svBitPackedArrRef, int));
CHECK_TYPE(svGetSelectLogic, svLogic (*)(svLogicPackedArrRef, int));
CHECK_TYPE(svPutSelectBit, void (*)(svBitPackedArrRef, int, svBit));
CHECK_TYPE(svPutSelectLogic, void (*)(svLogicPackedArrRef, int, svLogic));
CHECK_TYPE(svGetPartSelectBit, void (*)(svBitVec32 *, svBitPackedArrRef, int, int));
CHECK_TYPE(svGetPartSelectLogic, void (*)(svLogicVec32 *, svLogicPackedArrRef, int, int));
CHECK_TYPE(svPutPartSelectBit, void (*)(svBitPackedArrRef, svBitVec32, int, int));
CHECK_TYPE(svPutPartSelectLogic, void (*)(svLogicPackedArrRef, svLogicVec32, int, int));
CHECK_TYPE(svGetBits, svBitVec32 (*)(svBitPackedArrRef, int, int));
CHECK_TYPE(svGet32Bits, svBitVec32 (*)(svBitPackedArrRef, int));
CHECK_TYPE(svGet64Bits, uint64_t (*)(svBitPackedArrRef, int));
#undef CHECK_TYPE

static char show_logic(svLogic value)
{
    switch (value) {
    case sv_0: return '0';
    case sv_1: return '1';
    case sv_x: return 'x';
    case sv_z: return 'z';
    default: return '?';
    }
}

void legacy_selects(const svBitPackedArrRef bits, const svLogicPackedArrRef logic,
                    svBitPackedArrRef bit_output, svLogicPackedArrRef logic_output,
                    svLogicPackedArrRef wide_logic_output)
{
    svBitVec32 part_bits = 0;
    svLogicVec32 part_logic = {0, 0};
    svBitVec32 full_bits = 0;
    svLogicVec32 full_logic = {0, 0};

    svGetPartSelectBit(&part_bits, bits, 29, 8);
    svGetPartSelectLogic(&part_logic, logic, 29, 8);
    svGetPartSelectBit(&full_bits, bits, 10, 32);
    svGetPartSelectLogic(&full_logic, logic, 10, 32);
    printf("bit selectors=%u/%u part=%02x get=%02x/%08x/%016" PRIx64 "\n",
           (unsigned)svGetSelectBit(bits, 29), (unsigned)svGetSelectBit(bits, 36),
           part_bits & 0xff, svGetBits(bits, 29, 8) & 0xff, svGet32Bits(bits, 10),
           svGet64Bits(bits, 16));
    printf("logic selectors=%c/%c/%c/%c part=%02x/%02x\n",
           show_logic(svGetSelectLogic(logic, 29)), show_logic(svGetSelectLogic(logic, 30)),
           show_logic(svGetSelectLogic(logic, 31)), show_logic(svGetSelectLogic(logic, 32)),
           part_logic.c & 0xff, part_logic.d & 0xff);
    printf("full chunks bit=%08x logic=%08x/%08x\n", full_bits, full_logic.c, full_logic.d);

    const svBitVec32 zero_bits[SV_CANONICAL_SIZE(96)] = {0};
    const svLogicVec32 zero_logic[SV_CANONICAL_SIZE(45)] = {{0, 0}};
    const svLogicVec32 write_logic = {0x96, 0x5a};
    svPutBitVec32(bit_output, zero_bits, 96);
    svPutLogicVec32(logic_output, zero_logic, 45);
    svPutLogicVec32(wide_logic_output, zero_logic, 45);
    svPutPartSelectBit(bit_output, 0x96, 30, 8);
    svPutPartSelectLogic(logic_output, write_logic, 30, 8);
    const svLogicVec32 write_wide_logic = {0xaf000f00, 0x0ff00ff0};
    svPutPartSelectBit(bit_output, 0x8af12359, 40, 32);
    svPutPartSelectLogic(wide_logic_output, write_wide_logic, 10, 32);
    svPutSelectBit(bit_output, 95, 1);
    svPutSelectLogic(logic_output, 44, sv_x);
    fflush(stdout);
}

#ifdef __cplusplus
}
#endif
