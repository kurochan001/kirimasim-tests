#include <string.h>

#ifdef MEASURE_MANAGED_HEAP
#include <sanitizer/allocator_interface.h>
#endif

#ifdef __cplusplus
extern "C" {
#endif

unsigned long long managed_heap_bytes(void)
{
#ifdef MEASURE_MANAGED_HEAP
    return __sanitizer_get_current_allocated_bytes();
#else
    return 0;
#endif
}

int check_managed_string(const char *contents)
{
    const size_t length = strlen(contents);
    return length > 0 && contents[0] == 'a' && contents[length - 1] == 'p' ? (int)length : -1;
}

#ifdef __cplusplus
}
#endif
