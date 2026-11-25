#include <stdint.h>
#include "svdpi.h"

#ifdef __cplusplus
extern "C" {
#endif

static void *private_key_b(void)
{
    static int key;
    return &key;
}

static int read_b(void *key)
{
    const int *value = (const int *)svGetUserData(svGetScope(), key);
    return value ? *value : -1;
}

int user_keys_b_put(int slot)
{
    static int own[] = {2071, 4071};
    static int shared[] = {5533, 7533};
    const svScope scope = svGetScope();
    const int first = svPutUserData(scope, private_key_b(), &own[slot]);
    const int second = svPutUserData(scope, (void *)(uintptr_t)7, &shared[slot]);
    return first || second ? -1 : 0;
}

int user_keys_b_private(void) { return read_b(private_key_b()); }
int user_keys_b_numeric(void) { return read_b((void *)(uintptr_t)7); }

#ifdef __cplusplus
}
#endif
