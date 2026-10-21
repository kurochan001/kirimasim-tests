/* VPI application of test_vpi_udp_defn_entries (IEEE 1800-2023 37.36,
 * 37.35). */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

#define TOP "test_vpi_udp_defn_entries"
#define PREFIX "test_vpi_udp_defn_entries_"
#define MAX 8
#define LINE 96

static int by_text(const void *a, const void *b)
{
    return strcmp((const char *)a, (const char *)b);
}

/* The short name of a definition: its name without the common prefix. */
static const char *short_name(vpiHandle defn)
{
    PLI_BYTE8 *s = vpi_get_str(vpiDefName, defn);
    if (s == NULL)
        return "(null)";
    return strncmp(s, PREFIX, strlen(PREFIX)) == 0 ? s + strlen(PREFIX) : s;
}

/* Appends one character of a symbol, if it is not NUL. */
static void put_char(char *out, size_t size, unsigned c)
{
    size_t n = strlen(out);
    if (c != 0 && n + 1 < size) {
        out[n] = (char)c;
        out[n + 1] = '\0';
    }
}

/* The symbols of a table entry from its vector value (38.15). */
static void symbols(vpiHandle entry, char *out, size_t size)
{
    s_vpi_value v;
    int count = (int)vpi_get(vpiSize, entry), i;
    out[0] = '\0';
    v.format = vpiVectorVal;
    vpi_get_value(entry, &v);
    for (i = 0; i < count && v.value.vector; i++) {
        p_vpi_vecval w = &v.value.vector[i / 4];
        PLI_UINT32 word = (PLI_UINT32)(i % 4 < 2 ? w->aval : w->bval);
        unsigned half = (i % 2 == 0) ? (word >> 16) & 0xffff : word & 0xffff;
        if (i > 0)
            put_char(out, size, ' ');
        put_char(out, size, (half >> 8) & 0xff);
        put_char(out, size, half & 0xff);
    }
}

static const char *direction(vpiHandle h)
{
    switch (vpi_get(vpiDirection, h)) {
    case vpiInput: return "input";
    case vpiOutput: return "output";
    default: return "other direction";
    }
}

static void definition(vpiHandle defn)
{
    char lines[MAX][LINE], sym[LINE];
    vpiHandle it, h;
    int n = 0, i;

    it = vpi_iterate(vpiIODecl, defn);
    while (it && (h = vpi_scan(it)) != NULL)
        if (n < MAX) {
            PLI_BYTE8 *s = vpi_get_str(vpiName, h);
            snprintf(lines[n++], LINE, "%s %s", s ? s : "(null)", direction(h));
        }
    qsort(lines, n, sizeof lines[0], by_text);
    vpi_printf("%s: %d inputs, io declarations:", short_name(defn),
               (int)vpi_get(vpiSize, defn));
    for (i = 0; i < n; i++)
        vpi_printf("%s %s", i ? "," : "", lines[i]);
    vpi_printf("\n");

    n = 0;
    it = vpi_iterate(vpiTableEntry, defn);
    while (it && (h = vpi_scan(it)) != NULL)
        if (n < MAX) {
            symbols(h, sym, sizeof sym);
            snprintf(lines[n++], LINE, "symbols %s", sym);
        }
    qsort(lines, n, sizeof lines[0], by_text);
    for (i = 0; i < n; i++)
        vpi_printf("%s entry %s\n", short_name(defn), lines[i]);
}

static void terminals(vpiHandle udp, vpiHandle and2)
{
    char lines[MAX][LINE];
    vpiHandle it, h, defn = vpi_handle(vpiUdpDefn, udp);
    s_vpi_value v;
    int n = 0, i;

    it = vpi_iterate(vpiPrimTerm, udp);
    while (it && (h = vpi_scan(it)) != NULL)
        if (n < MAX) {
            v.format = vpiBinStrVal;
            vpi_get_value(h, &v);
            snprintf(lines[n++], LINE, "%d %s %s", (int)vpi_get(vpiTermIndex, h), direction(h),
                     v.value.str ? v.value.str : "(null)");
        }
    qsort(lines, n, sizeof lines[0], by_text);
    vpi_printf("u1: definition is and2 %d, terminals:",
               defn && and2 ? (int)vpi_compare_objects(defn, and2) : 0);
    for (i = 0; i < n; i++)
        vpi_printf("%s %s", i ? "," : "", lines[i]);
    vpi_printf("\n");
}

static PLI_INT32 udp_calltf(PLI_BYTE8 *user_data)
{
    vpiHandle it = vpi_iterate(vpiUdpDefn, NULL), h, and2 = NULL, seq = NULL;
    vpiHandle u1 = vpi_handle_by_name((PLI_BYTE8 *)TOP ".u1", NULL);
    vpiHandle u2 = vpi_handle_by_name((PLI_BYTE8 *)TOP ".u2", NULL);
    char names[MAX][LINE];
    s_vpi_value v;
    int n = 0, i;

    (void)user_data;
    while (it && (h = vpi_scan(it)) != NULL) {
        PLI_BYTE8 *s = vpi_get_str(vpiDefName, h);
        if (n < MAX)
            snprintf(names[n++], LINE, "%s", s ? s : "(null)");
        if (strcmp(short_name(h), "and2") == 0)
            and2 = h;
        else if (strcmp(short_name(h), "catch") == 0)
            seq = h;
    }
    qsort(names, n, sizeof names[0], by_text);
    vpi_printf("udp definitions:");
    for (i = 0; i < n; i++)
        vpi_printf(" %s", names[i]);
    vpi_printf("\n");
    if (and2 == NULL || seq == NULL || u1 == NULL || u2 == NULL) {
        vpi_printf("a definition or an instance was not found\n");
        return 0;
    }
    definition(and2);
    definition(seq);
    terminals(u1, and2);
    v.format = vpiScalarVal;
    v.value.scalar = vpi1;
    vpi_put_value(u2, &v, NULL, vpiNoDelay);
    return 0;
}

static void register_all(void)
{
    s_vpi_systf_data d;
    memset(&d, 0, sizeof d);
    d.type = vpiSysTask;
    d.tfname = (PLI_BYTE8 *)"$vt_udp";
    d.calltf = udp_calltf;
    vpi_register_systf(&d);
}

void (*vlog_startup_routines[])(void) = {register_all, 0};

#ifdef __cplusplus
}
#endif
