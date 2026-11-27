#include <stddef.h>
#include "svdpi.h"

#ifdef DPI_USE_SOURCE_LAYOUT
#include "svdpi_src.h"

struct local_layout {
    SV_BIT_PACKED_ARRAY(65, bits)[2];
    SV_LOGIC_PACKED_ARRAY(65, state);
};
#endif

#ifdef __cplusplus
extern "C" {
#endif

#ifdef DPI_USE_SOURCE_LAYOUT
void legacy_source_shape(size_t shape[3])
{
    shape[0] = sizeof(((struct local_layout *)0)->bits[0]);
    shape[1] = sizeof(((struct local_layout *)0)->state);
    shape[2] = offsetof(struct local_layout, state);
}
#endif

void legacy_layout_transfer(const svBitPackedArrRef sent_bits, const svLogicPackedArrRef sent_logic,
                            svBitPackedArrRef received_bits, svLogicPackedArrRef received_logic)
{
    enum { width = 65, words = SV_CANONICAL_SIZE(width) };
    svBitVec32 bits[words];
    svLogicVec32 state[words];
    svGetBitVec32(bits, sent_bits, width);
    svGetLogicVec32(state, sent_logic, width);
#ifdef DPI_USE_SOURCE_LAYOUT
    struct local_layout scratch;
    svPutBitVec32(&scratch.bits[1], bits, width);
    svPutLogicVec32(&scratch.state, state, width);
    svGetBitVec32(bits, &scratch.bits[1], width);
    svGetLogicVec32(state, &scratch.state, width);
#endif
    svPutBitVec32(received_bits, bits, width);
    svPutLogicVec32(received_logic, state, width);
}

#ifdef __cplusplus
}
#endif
