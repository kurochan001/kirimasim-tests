/* Independent C side for the DPI/NBA cross tests (1800-2023 35.6.1, H.8.8). */
#include <limits.h>

#if INT_MAX != 2147483647
#error These DPI tests require the standard 32-bit C int mapping.
#endif

#ifdef __cplusplus
extern "C" {
#endif

int cross_dpi_nba_input(int value)
{
    return value;
}

int cross_dpi_nba_output(int *value)
{
    /* An output argument's initial value is unspecified; never read it. */
    *value = -61;
    return 53;
}

int cross_dpi_nba_inout(int *value)
{
    int before = *value;
    /* The masked value is at most 255; signed arithmetic stays in range. */
    *value = (int)((unsigned int)before & 255u) - 73;
    return before;
}

#ifdef __cplusplus
}
#endif
