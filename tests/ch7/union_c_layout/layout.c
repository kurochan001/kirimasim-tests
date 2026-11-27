#include <stddef.h>
#include <string.h>

typedef struct {
    signed char marker;
    long long codepoint;
    double ratio;
} c_left;

typedef struct {
    signed char marker;
    long long codepoint;
    short mode;
    double score;
} c_right;

typedef union { c_left left; c_right right; } c_overlay;

void measure_c_layout(size_t *values)
{
    const size_t layout[] = {
        sizeof(c_overlay), _Alignof(c_overlay), offsetof(c_overlay, left), offsetof(c_overlay, right),
        sizeof(c_left), _Alignof(c_left), offsetof(c_left, marker), offsetof(c_left, codepoint),
        offsetof(c_left, ratio),
        sizeof(c_right), _Alignof(c_right), offsetof(c_right, marker), offsetof(c_right, codepoint),
        offsetof(c_right, mode), offsetof(c_right, score),
    };
    memcpy(values, layout, sizeof layout);
}

int observe_c_left(const void *payload, size_t bytes)
{
    c_overlay specimen;
    if (bytes != sizeof specimen)
        return 0;
    memcpy(&specimen, payload, bytes);
    return specimen.left.ratio == 3.75 && specimen.right.marker == 23
        && specimen.right.codepoint == 4815162342LL;
}

int write_c_right(void *payload, size_t bytes)
{
    c_overlay specimen = {.right = {62, -391827465LL, -51, -0.75}};
    if (bytes != sizeof specimen)
        return 0;
    memcpy(payload, &specimen, bytes);
    return 1;
}
