#include <stdio.h>

#ifdef __cplusplus
extern "C" {
#endif

int matches_host_mode(const char *path, const char *mode, int count,
                      unsigned long long observed)
{
    FILE *file = fopen(path, mode);
    unsigned long long bytes = 0;
    int length = 0;
    int next;
    if (file == NULL)
        return 0;
    while (length < 9 && (next = fgetc(file)) != EOF) {
        bytes = (bytes << 8) | (unsigned)next;
        ++length;
    }
    int matched = !ferror(file) && length <= 8 && count == length && bytes == observed;
    fclose(file);
    return matched;
}

#ifdef __cplusplus
}
#endif
