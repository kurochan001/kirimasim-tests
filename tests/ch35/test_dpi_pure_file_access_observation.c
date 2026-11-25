#include <stdio.h>

#ifdef __cplusplus
extern "C" {
#endif

static int roundtrip(FILE *stream, int value)
{
    int observed = -1;
    if (stream != NULL) {
        if (fputc(value, stream) != EOF && fseek(stream, 0, SEEK_SET) == 0)
            observed = fgetc(stream);
        if (fclose(stream) != 0)
            return -1;
    }
    return observed;
}

int dpi_file_direct(int seed)
{
    return roundtrip(tmpfile(), seed);
}

static int initialize_indirect(int seed)
{
    return roundtrip(tmpfile(), seed ^ 17);
}

int dpi_file_indirect(int seed)
{
    return initialize_indirect(seed);
}

#ifdef __cplusplus
}
#endif
