#include <stdio.h>

#ifdef __cplusplus
extern "C" {
#endif

#ifdef SV_LOADER_LEFT
__attribute__((constructor)) static void left_loaded(void)
{
    puts("loaded left");
    fflush(stdout);
}
#endif

#ifdef SV_LOADER_RIGHT
__attribute__((constructor)) static void right_loaded(void)
{
    puts("loaded right");
    fflush(stdout);
}
#endif

#ifndef SV_LOADER_RIGHT
int from_left(int value)
{
    return value + 23;
}
#endif

#ifndef SV_LOADER_LEFT
int from_right(int value)
{
    return value * 3;
}
#endif

#ifdef __cplusplus
}
#endif
