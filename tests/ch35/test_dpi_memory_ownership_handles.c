/* C side of test_dpi_memory_ownership_handles (IEEE 1800-2023 35.5.1.4, H.6.6). */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "svdpi.h"

#ifdef __cplusplus
extern "C" {
#endif

#define MARK 0x5eed1234

struct block {
    int mark;
    int n;
};

static int live;
static char *kept;
static char *label;

void *c_alloc(int n)
{
    struct block *p = (struct block *)malloc(sizeof *p);
    p->mark = MARK;
    p->n = n;
    live++;
    return p;
}

int c_free(void *h)
{
    struct block *p = (struct block *)h;
    int n;

    if (p == NULL || p->mark != MARK)
        return -1;
    n = p->n;
    p->mark = 0;
    free(p);
    live--;
    return n;
}

int c_live(void) { return live; }

void c_keep(const char *s)
{
    free(kept);
    kept = (char *)malloc(strlen(s) + 1);
    strcpy(kept, s);
}

const char *c_kept(void) { return kept; }

const char *c_label(int n)
{
    if (label != NULL) {
        memset(label, '?', strlen(label));
        free(label);
    }
    label = (char *)malloc(16);
    snprintf(label, 16, "label %d", n);
    return label;
}

#ifdef __cplusplus
}
#endif
