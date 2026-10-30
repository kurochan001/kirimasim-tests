/* VPI application of test_vpi_program_interface_relations (IEEE 1800-2023 37.9). */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "vpi_user.h"
#include "sv_vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

#define TOP "test_vpi_program_interface_relations"
#define MAX 8

/* vpi_get_str() returns every string in one buffer (38.11), so each string is
   copied into one of a few buffers, enough for the strings of one line. */
static const char *sprop(PLI_INT32 property, vpiHandle h)
{
    static char copies[4][64];
    static int next;
    char *c = copies[next++ % 4];
    PLI_BYTE8 *s = h != NULL ? vpi_get_str(property, h) : NULL;

    snprintf(c, sizeof copies[0], "%s", s != NULL ? s : "(none)");
    return c;
}

static vpiHandle by_name(const char *path)
{
    char full[128];
    snprintf(full, sizeof full, "%s.%s", TOP, path);
    return vpi_handle_by_name((PLI_BYTE8 *)full, NULL);
}

static int by_text(const void *a, const void *b)
{
    return strcmp(*(const char *const *)a, *(const char *const *)b);
}

/* The interface instances of a program, sorted by name. */
static void interfaces(vpiHandle prog)
{
    vpiHandle it = prog != NULL ? vpi_iterate(vpiInterface, prog) : NULL, h;
    const char *names[MAX];
    vpiHandle handles[MAX];
    char storage[MAX][48];
    int n = 0, i, j;

    while (it != NULL && (h = vpi_scan(it)) != NULL && n < MAX) {
        snprintf(storage[n], sizeof storage[0], "%s", sprop(vpiName, h));
        names[n] = storage[n];
        handles[n++] = h;
    }
    for (i = 0; i < n; i++)
        for (j = i + 1; j < n; j++)
            if (by_text(&names[i], &names[j]) > 0) {
                const char *t = names[i];
                vpiHandle th = handles[i];
                names[i] = names[j];
                handles[i] = handles[j];
                names[j] = t;
                handles[j] = th;
            }
    vpi_printf((PLI_BYTE8 *)"%s: type %s, interfaces", sprop(vpiName, prog),
               sprop(vpiType, prog));
    if (n == 0)
        vpi_printf((PLI_BYTE8 *)" none\n");
    else {
        vpi_printf((PLI_BYTE8 *)" ");
        for (i = 0; i < n; i++)
            vpi_printf((PLI_BYTE8 *)"%s%s", i ? "," : "", names[i]);
        vpi_printf((PLI_BYTE8 *)"\n");
        for (i = 0; i < n; i++) {
            vpiHandle back = vpi_handle(vpiInstance, handles[i]);
            vpi_printf((PLI_BYTE8 *)"  %s: instance is %s %d\n", names[i],
                       sprop(vpiName, prog),
                       back != NULL && prog != NULL && vpi_compare_objects(back, prog));
        }
    }
}

static PLI_INT32 program_calltf(PLI_BYTE8 *user_data)
{
    vpiHandle one = by_name("one"), two = by_name("two");
    vpiHandle it, arr;

    (void)user_data;
    interfaces(one);
    it = two != NULL ? vpi_iterate(vpiInterfaceArray, two) : NULL;
    arr = it != NULL ? vpi_scan(it) : NULL;
    vpi_printf((PLI_BYTE8 *)"%s: type %s, interface arrays", sprop(vpiName, two),
               sprop(vpiType, two));
    if (arr == NULL) {
        vpi_printf((PLI_BYTE8 *)" none\n");
        return 0;
    }
    vpi_printf((PLI_BYTE8 *)" %s\n", sprop(vpiName, arr));
    {
        vpiHandle back = vpi_handle(vpiInstance, arr);
        vpi_printf((PLI_BYTE8 *)"  %s: type %s, instance is %s %d\n",
                   sprop(vpiName, arr), sprop(vpiType, arr), sprop(vpiName, two),
                   back != NULL && two != NULL && vpi_compare_objects(back, two));
    }
    {
        int i;
        for (i = 0; i < MAX; i++) {
            vpiHandle el = vpi_handle_by_index(arr, i);
            if (el != NULL) {
                vpiHandle back = vpi_handle(vpiInstance, el);
                vpi_printf((PLI_BYTE8 *)"  element %d: type %s, instance is %s %d\n",
                           i, sprop(vpiType, el), sprop(vpiName, two),
                           back != NULL && two != NULL && vpi_compare_objects(back, two));
            }
        }
    }
    return 0;
}

static void register_all(void)
{
    s_vpi_systf_data d;
    memset(&d, 0, sizeof d);
    d.type = vpiSysTask;
    d.tfname = (PLI_BYTE8 *)"$vt_program";
    d.calltf = program_calltf;
    vpi_register_systf(&d);
}

void (*vlog_startup_routines[])(void) = {register_all, 0};

#ifdef __cplusplus
}
#endif
