#define SV_BIT_PACKED_ARRAY(WIDTH, NAME) \
    struct { unsigned long long reserved; unsigned char bits[((WIDTH) + 7) / 8]; } NAME
#define SV_LOGIC_PACKED_ARRAY(WIDTH, NAME) \
    struct { unsigned long long reserved; unsigned char planes[2][((WIDTH) + 7) / 8]; } NAME
