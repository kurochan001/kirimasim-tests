/* C side of test_dpi_unpacked_aggregate_arguments (IEEE 1800-2023 H.7.8, H.8.4). */
#include <stdio.h>
#include "svdpi.h"

#ifdef __cplusplus
extern "C" {
#endif

/* The C declarations of the purely unpacked SystemVerilog structures. */
typedef struct {
    int id;
    double w;
    char b;
} leaf_t;
typedef struct {
    leaf_t pair[2];
    int counts[3];
    short s;
} tree_t;
typedef struct {
    int r;
    char c;
    int plain;
} chosen_t;
/* mixed_t has packed members; C only passes its address on. */
typedef struct vt_mixed vt_mixed;

extern void sv_tree(const tree_t *t);
extern void sv_mixed(const vt_mixed *m);

double c_tree(const tree_t *t, tree_t *o)
{
    double sum = t->pair[0].id + t->pair[0].w + t->pair[0].b + t->pair[1].id + t->pair[1].w +
                 t->pair[1].b + t->counts[0] + t->counts[1] + t->counts[2] + t->s;

    o->pair[0].id = 7;
    o->pair[0].w = 0.25;
    o->pair[0].b = -1;
    o->pair[1].id = 8;
    o->pair[1].w = 0.75;
    o->pair[1].b = 2;
    o->counts[0] = 1;
    o->counts[1] = 2;
    o->counts[2] = 3;
    o->s = -300;
    return sum;
}

void c_build_tree(void)
{
    tree_t t;

    t.pair[0].id = 11;
    t.pair[0].w = 2.5;
    t.pair[0].b = 5;
    t.pair[1].id = 12;
    t.pair[1].w = 3.5;
    t.pair[1].b = -6;
    t.counts[0] = 4;
    t.counts[1] = 5;
    t.counts[2] = 6;
    t.s = 7;
    sv_tree(&t);
}

void c_forward(const vt_mixed *m)
{
    sv_mixed(m);
}

int c_chosen(const chosen_t *s)
{
    return s->r * 100 + s->c * 10 + s->plain;
}

#ifdef __cplusplus
}
#endif
