/* Inspect DPI_EXTERN during declaration expansion, before the header removes it. */
#define STRINGIFY_TOKENS(...) #__VA_ARGS__
#define EXPANDED_TOKENS(...) STRINGIFY_TOKENS(__VA_ARGS__)
#ifdef __cplusplus
#define CHECK_EMPTY_DEFAULT static_assert
#else
#define CHECK_EMPTY_DEFAULT _Static_assert
#endif

#define DPI_PROTOTYPES
#define XXTERN \
    CHECK_EMPTY_DEFAULT(sizeof(EXPANDED_TOKENS(DPI_EXTERN)) == 1, "expected empty DPI_EXTERN"); \
    extern int default_qualifier_seen;
#define EETERN XXTERN
#include "svdpi.h"

#ifdef __cplusplus
extern "C" {
#endif

int check_default_dpi_qualifier(void)
{
    svBitVecVal word = 0x80;
    return default_qualifier_seen == 17 && svGetBitselBit(&word, 7) == sv_1;
}

#ifdef __cplusplus
}
#endif

int default_qualifier_seen = 17;
