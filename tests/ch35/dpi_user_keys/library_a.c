#include <stdint.h>
#include "svdpi.h"

#ifdef __cplusplus
extern "C" {
#endif

static void *private_key_a(void)
{
    static int key;
    return &key;
}

static int read_a(void *key)
{
    const int *value = (const int *)svGetUserData(svGetScope(), key);
    return value ? *value : -1;
}

int user_keys_a_put(int slot)
{
    static int own[] = {1017, 3017};
    static int shared[] = {4422, 6422};
    const svScope scope = svGetScope();
    const int first = svPutUserData(scope, private_key_a(), &own[slot]);
    /* The deliberately shared numeric token is used only as an opaque key. */
    const int second = svPutUserData(scope, (void *)(uintptr_t)7, &shared[slot]);
    return first || second ? -1 : 0;
}

int user_keys_a_private(void) { return read_a(private_key_a()); }
int user_keys_a_numeric(void) { return read_a((void *)(uintptr_t)7); }

#ifdef __cplusplus
}
#endif

/* The ordinary suite uses one helper. The prebuilt-library check builds B separately. */
#ifndef DPI_BUILD_SEPARATE_LIBRARIES
#include "library_b.cpp"
#endif
