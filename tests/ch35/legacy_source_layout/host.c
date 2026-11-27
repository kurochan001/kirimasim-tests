#include <assert.h>
#include <stddef.h>
#include <stdio.h>
#include <string.h>
#include "svdpi.h"

enum {
    width = 65,
    word_count = SV_CANONICAL_SIZE(width),
    byte_count = (width + 7) / 8,
};

#ifdef BYTE_LAYOUT
typedef struct {
    unsigned long long reserved;
    unsigned char data[byte_count];
} native_bits;
typedef struct {
    unsigned long long reserved;
    unsigned char aval[byte_count], bval[byte_count];
} native_logic;

static unsigned get_bit(const unsigned char *bytes, int index)
{
    return (bytes[index / 8] >> (index % 8)) & 1u;
}

static void set_bit(unsigned char *bytes, int index, unsigned value)
{
    bytes[index / 8] |= (unsigned char)((value & 1u) << (index % 8));
}
#else
typedef struct { svBitVec32 words[word_count]; } native_bits;
typedef struct { svLogicVec32 words[word_count]; } native_logic;
#endif

struct host_layout {
    native_bits bits[2];
    native_logic state;
};

void svGetBitVec32(svBitVec32 *dst, const svBitPackedArrRef src, int size)
{
    native_bits native;
    assert(size == width);
    memcpy(&native, src, sizeof native);
#ifdef BYTE_LAYOUT
    memset(dst, 0, word_count * sizeof(*dst));
    for (int i = 0; i < size; ++i)
        dst[i / 32] |= get_bit(native.data, i) << (i % 32);
#else
    memcpy(dst, native.words, sizeof native.words);
#endif
}

void svGetLogicVec32(svLogicVec32 *dst, const svLogicPackedArrRef src, int size)
{
    native_logic native;
    assert(size == width);
    memcpy(&native, src, sizeof native);
#ifdef BYTE_LAYOUT
    memset(dst, 0, word_count * sizeof(*dst));
    for (int i = 0; i < size; ++i) {
        dst[i / 32].c |= get_bit(native.aval, i) << (i % 32);
        dst[i / 32].d |= get_bit(native.bval, i) << (i % 32);
    }
#else
    memcpy(dst, native.words, sizeof native.words);
#endif
}

void svPutBitVec32(svBitPackedArrRef dst, const svBitVec32 *src, int size)
{
    native_bits native = {0};
    assert(size == width);
#ifdef BYTE_LAYOUT
    for (int i = 0; i < size; ++i)
        set_bit(native.data, i, src[i / 32] >> (i % 32));
#else
    memcpy(native.words, src, sizeof native.words);
#endif
    memcpy(dst, &native, sizeof native);
}

void svPutLogicVec32(svLogicPackedArrRef dst, const svLogicVec32 *src, int size)
{
    native_logic native = {0};
    assert(size == width);
#ifdef BYTE_LAYOUT
    for (int i = 0; i < size; ++i) {
        set_bit(native.aval, i, src[i / 32].c >> (i % 32));
        set_bit(native.bval, i, src[i / 32].d >> (i % 32));
    }
#else
    memcpy(native.words, src, sizeof native.words);
#endif
    memcpy(dst, &native, sizeof native);
}

void legacy_layout_transfer(const svBitPackedArrRef sent_bits, const svLogicPackedArrRef sent_logic,
                            svBitPackedArrRef received_bits, svLogicPackedArrRef received_logic);

#ifdef CHECK_SOURCE_SHAPE
void legacy_source_shape(size_t shape[3]);
#endif

static void exercise(int pass, const svBitVec32 *bits, const svLogicVec32 *state)
{
    native_bits input_bits, output_bits;
    native_logic input_state, output_state;
    svBitVec32 compared_bits[word_count];
    svLogicVec32 compared_state[word_count];
    svPutBitVec32(&input_bits, bits, width);
    svPutLogicVec32(&input_state, state, width);
    legacy_layout_transfer(&input_bits, &input_state, &output_bits, &output_state);
    svGetBitVec32(compared_bits, &output_bits, width);
    svGetLogicVec32(compared_state, &output_state, width);
    int bits_agree = 1, state_agrees = 1;
    for (int i = 0; i < word_count; ++i) {
        bits_agree &= compared_bits[i] == bits[i];
        state_agrees &= compared_state[i].c == state[i].c && compared_state[i].d == state[i].d;
    }
    printf("pass=%d bit=%d logic=%d\n", pass, bits_agree, state_agrees);
}

int main(void)
{
    const size_t host[] = {sizeof(native_bits), sizeof(native_logic), offsetof(struct host_layout, state)};
    printf("host shape bit=%zu logic=%zu state=%zu\n", host[0], host[1], host[2]);
#ifdef CHECK_SOURCE_SHAPE
    size_t application[3];
    legacy_source_shape(application);
    int matches = host[0] == application[0] && host[1] == application[1] && host[2] == application[2];
    printf("source layout matches host=%d\n", matches);
    if (!matches)
        return 3;
#endif
    const svBitVec32 bits[][word_count] = {
        {0xabcdef00u, 0x23456789u, 1u},
        {0x0192e43fu, 0x84091280u, 0u},
    };
    const svLogicVec32 state[][word_count] = {
        {{0x765f3010u, 0x000f0f00u}, {0xfedcba98u, 0u}, {1u, 0u}},
        {{0x90078f34u, 0x00f00f00u}, {0x0033f23fu, 0x0000f000u}, {0u, 0u}},
    };
    exercise(1, bits[0], state[0]);
    exercise(2, bits[1], state[1]);
    return 0;
}
