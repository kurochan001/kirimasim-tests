#include <stdlib.h>

#ifdef __cplusplus
extern "C" {
#endif

static int *payload;

void *new_foreign_payload(void)
{
    payload = (int *)malloc(sizeof(*payload));
    if (payload == NULL)
        abort();
    *payload = 23;
    return payload;
}

int read_foreign_payload(void *value)
{
    return value == payload && value != NULL ? *payload : -1;
}

int read_native_payload(void)
{
    return read_foreign_payload(payload);
}

void free_foreign_payload(void)
{
    free(payload);
    payload = NULL;
}

#ifdef __cplusplus
}
#endif
