#include <stdio.h>

/* With no object selected, the ordinary DPI runner builds all four functions. */
#ifdef ANNEX_J_OBJECT
__attribute__((constructor)) static void report_loading(void)
{
    printf("loaded Annex J %c\n", 'a' + ANNEX_J_OBJECT - 1);
    fflush(stdout);
}
#endif

#ifdef __cplusplus
extern "C" {
#endif

#if !defined(ANNEX_J_OBJECT) || ANNEX_J_OBJECT == 1
int annex_j_a(int value) { return value + 11; }
#endif

#if !defined(ANNEX_J_OBJECT) || ANNEX_J_OBJECT == 2
int annex_j_b(int value) { return value + 22; }
#endif

#if !defined(ANNEX_J_OBJECT) || ANNEX_J_OBJECT == 3
int annex_j_c(int value) { return value + 33; }
#endif

#if !defined(ANNEX_J_OBJECT) || ANNEX_J_OBJECT == 4
int annex_j_d(int value) { return value + 44; }
#endif

#ifdef __cplusplus
}
#endif
