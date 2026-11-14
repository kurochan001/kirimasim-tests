/* VPI application of test_vpi_get_value_array_user_buffers (IEEE 1800-2023
 * 38.16). */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

#define TOP "test_vpi_get_value_array_user_buffers"
#define NUM 3
#define EXTRA 16
#define FILL 0xA5
#define LINE 256

static vpiHandle by_name(const char *name)
{
    char full[96];
    snprintf(full, sizeof full, "%s.%s", TOP, name);
    return vpi_handle_by_name((PLI_BYTE8 *)full, NULL);
}

/* Sets the union member that the format uses to p. */
static void set_member(s_vpi_arrayvalue *v, void *p)
{
    switch ((PLI_INT32)v->format) {
    case vpiIntVal: v->value.integers = (PLI_INT32 *)p; break;
    case vpiShortIntVal: v->value.shortints = (PLI_INT16 *)p; break;
    case vpiLongIntVal: v->value.longints = (PLI_INT64 *)p; break;
    case vpiRealVal: v->value.reals = (double *)p; break;
    case vpiShortRealVal: v->value.shortreals = (float *)p; break;
    case vpiTimeVal: v->value.times = (struct t_vpi_time *)p; break;
    case vpiVectorVal: v->value.vectors = (struct t_vpi_vecval *)p; break;
    default: v->value.rawvals = (PLI_BYTE8 *)p; break;
    }
}

/* The union member that the format uses. */
static void *get_member(const s_vpi_arrayvalue *v)
{
    switch ((PLI_INT32)v->format) {
    case vpiIntVal: return v->value.integers;
    case vpiShortIntVal: return v->value.shortints;
    case vpiLongIntVal: return v->value.longints;
    case vpiRealVal: return v->value.reals;
    case vpiShortRealVal: return v->value.shortreals;
    case vpiTimeVal: return v->value.times;
    case vpiVectorVal: return v->value.vectors;
    default: return v->value.rawvals;
    }
}

/* Appends the values of buffer, in the given format, to line. */
static void describe(PLI_INT32 format, const void *buffer, char *line, size_t size)
{
    size_t n = strlen(line);
    int k;

    for (k = 0; k < NUM * 4 && n < size; k++) {
        int w = 0;
        switch (format) {
        case vpiIntVal:
            if (k < NUM)
                w = snprintf(line + n, size - n, " %d", (int)((const PLI_INT32 *)buffer)[k]);
            break;
        case vpiShortIntVal:
            if (k < NUM)
                w = snprintf(line + n, size - n, " %d", (int)((const PLI_INT16 *)buffer)[k]);
            break;
        case vpiLongIntVal:
            if (k < NUM)
                w = snprintf(line + n, size - n, " %lld",
                             (long long)((const PLI_INT64 *)buffer)[k]);
            break;
        case vpiRealVal:
            if (k < NUM)
                w = snprintf(line + n, size - n, " %g", ((const double *)buffer)[k]);
            break;
        case vpiShortRealVal:
            if (k < NUM)
                w = snprintf(line + n, size - n, " %g", (double)((const float *)buffer)[k]);
            break;
        case vpiTimeVal:
            if (k < NUM) {
                const s_vpi_time *t = (const s_vpi_time *)buffer + k;
                w = snprintf(line + n, size - n, " %u:%u", (unsigned)t->high,
                             (unsigned)t->low);
            }
            break;
        case vpiVectorVal:
            /* Two words per 40-bit element; bits 40 to 63 are masked. */
            if (k < NUM * 2) {
                const s_vpi_vecval *q = (const s_vpi_vecval *)buffer + k;
                unsigned mask = k % 2 == 0 ? 0xffffffffu : 0xffu;
                w = snprintf(line + n, size - n, " %08x/%08x", (unsigned)q->aval & mask,
                             (unsigned)q->bval & mask);
            }
            break;
        case vpiRawFourStateVal:
            /* ngroups is 2 for 12 bits: aval bytes, then bval bytes. */
            if (k < NUM * 4) {
                unsigned b = ((const unsigned char *)buffer)[k];
                w = snprintf(line + n, size - n, " %02x", k % 2 == 0 ? b : b & 0x0fu);
            }
            break;
        case vpiRawTwoStateVal:
            if (k < NUM * 2) {
                unsigned b = ((const unsigned char *)buffer)[k];
                w = snprintf(line + n, size - n, " %02x", k % 2 == 0 ? b : b & 0x0fu);
            }
            break;
        default:
            break;
        }
        if (w > 0)
            n += (size_t)w;
    }
}

/* Reads NUM elements from index 1 into a buffer of exactly size bytes that
 * the application allocates, followed by EXTRA guard bytes. */
static void user_read(const char *array, PLI_INT32 format, const char *label, size_t size)
{
    vpiHandle h = by_name(array);
    s_vpi_arrayvalue v;
    PLI_INT32 index[1];
    unsigned char *mine;
    char line[LINE];
    int k, intact = 1;

    if (h == NULL) {
        vpi_printf((PLI_BYTE8 *)"%s: not found\n", array);
        return;
    }
    mine = (unsigned char *)malloc(size + EXTRA);
    if (mine == NULL)
        return;
    memset(mine, FILL, size + EXTRA);
    memset(&v, 0, sizeof v);
    v.format = (PLI_UINT32)format;
    v.flags = vpiUserAllocFlag;
    set_member(&v, mine);
    index[0] = 1;
    vpi_get_value_array(h, &v, index, NUM);
    for (k = 0; k < EXTRA; k++)
        if (mine[size + k] != FILL)
            intact = 0;
    snprintf(line, sizeof line, "%s, %s: buffer kept %d, values", array, label,
             get_member(&v) == (void *)mine);
    describe(format, mine, line, sizeof line);
    vpi_printf((PLI_BYTE8 *)"%s, after it intact %d\n", line, intact);
    free(mine);
}

static PLI_INT32 on_delay(p_cb_data cb)
{
    vpiHandle ia = by_name("ia"), ra = by_name("ra");
    s_vpi_arrayvalue v;
    PLI_INT32 index[1];
    PLI_INT16 *mine;
    int copy[NUM], dummy = 0, k;

    (void)cb;
    user_read("ia", vpiIntVal, "3 PLI_INT32", NUM * sizeof(PLI_INT32));
    user_read("sa", vpiShortIntVal, "3 PLI_INT16", NUM * sizeof(PLI_INT16));
    user_read("la", vpiLongIntVal, "3 PLI_INT64", NUM * sizeof(PLI_INT64));
    user_read("ra", vpiRealVal, "3 double", NUM * sizeof(double));
    user_read("fa", vpiShortRealVal, "3 float", NUM * sizeof(float));
    user_read("ta", vpiTimeVal, "3 s_vpi_time", NUM * sizeof(s_vpi_time));
    user_read("wa", vpiVectorVal, "12 words", ((40 + 31) / 32) * 2 * NUM * sizeof(PLI_INT32));
    user_read("xa", vpiRawFourStateVal, "12 bytes", ((12 + 7) / 8) * NUM * 2);
    user_read("ba", vpiRawTwoStateVal, "6 bytes", ((12 + 7) / 8) * NUM);

    if (ia == NULL || ra == NULL) {
        vpi_printf((PLI_BYTE8 *)"an array is missing\n");
        return 0;
    }

    /* An error with the application's buffer: it keeps its own pointer. */
    mine = (PLI_INT16 *)malloc(NUM * sizeof(PLI_INT16));
    memset(&v, 0, sizeof v);
    v.format = (PLI_UINT32)vpiShortIntVal;
    v.flags = vpiUserAllocFlag;
    v.value.shortints = mine;
    index[0] = 1;
    vpi_get_value_array(ia, &v, index, NUM);
    vpi_printf((PLI_BYTE8 *)"vpiShortIntVal of int elements, own buffer: value pointer NULL %d\n",
               mine != NULL && v.value.shortints == NULL);
    free(mine);

    /* Errors with VPI storage; the member starts as a non-NULL pointer. */
    memset(&v, 0, sizeof v);
    v.format = (PLI_UINT32)vpiShortRealVal;
    v.value.rawvals = (PLI_BYTE8 *)&dummy;
    index[0] = 1;
    vpi_get_value_array(ia, &v, index, NUM);
    vpi_printf((PLI_BYTE8 *)"vpiShortRealVal of int elements, VPI storage: value pointer NULL %d\n",
               v.value.rawvals == NULL);
    memset(&v, 0, sizeof v);
    v.format = (PLI_UINT32)vpiStringVal;
    v.value.rawvals = (PLI_BYTE8 *)&dummy;
    index[0] = 1;
    vpi_get_value_array(ia, &v, index, NUM);
    vpi_printf((PLI_BYTE8 *)"vpiStringVal, VPI storage: value pointer NULL %d\n",
               v.value.rawvals == NULL);

    /* VPI storage: copy what is kept, then make another call. */
    memset(&v, 0, sizeof v);
    v.format = (PLI_UINT32)vpiIntVal;
    index[0] = 1;
    vpi_get_value_array(ia, &v, index, NUM);
    vpi_printf((PLI_BYTE8 *)"ia, VPI storage given %d\n", v.value.integers != NULL);
    for (k = 0; k < NUM; k++)
        copy[k] = v.value.integers != NULL ? (int)v.value.integers[k] : -1;
    memset(&v, 0, sizeof v);
    v.format = (PLI_UINT32)vpiRealVal;
    index[0] = 0;
    vpi_get_value_array(ra, &v, index, 4);
    vpi_printf((PLI_BYTE8 *)"ra, VPI storage given %d\n", v.value.reals != NULL);
    vpi_printf((PLI_BYTE8 *)"copy of ia after the call for ra: %d %d %d\n", copy[0], copy[1],
               copy[2]);
    return 0;
}

static void register_all(void)
{
    static s_vpi_time when;
    s_cb_data cb;

    when.type = vpiSimTime;
    when.high = 0;
    when.low = 1;
    memset(&cb, 0, sizeof cb);
    cb.reason = cbAfterDelay;
    cb.cb_rtn = on_delay;
    cb.time = &when;
    vpi_register_cb(&cb);
}

void (*vlog_startup_routines[])(void) = {register_all, 0};

#ifdef __cplusplus
}
#endif
