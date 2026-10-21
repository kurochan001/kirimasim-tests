/* VPI application of test_vpi_memory_word_objects (IEEE 1800-2023 37.20). */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

#define TOP "test_vpi_memory_word_objects"
#define MAX 8
#define LEN 64

static int by_text(const void *a, const void *b)
{
    return strcmp((const char *)a, (const char *)b);
}

static void list(const char *label, PLI_INT32 type, vpiHandle ref)
{
    char names[MAX][LEN];
    vpiHandle it = ref ? vpi_iterate(type, ref) : NULL, h;
    int n = 0, i;

    while (it && (h = vpi_scan(it)) != NULL) {
        PLI_BYTE8 *s = vpi_get_str(vpiName, h);
        if (n < MAX)
            snprintf(names[n++], LEN, "%s", s ? s : "(null)");
    }
    qsort(names, n, LEN, by_text);
    vpi_printf("%s:", label);
    for (i = 0; i < n; i++)
        vpi_printf(" %s", names[i]);
    vpi_printf("\n");
}

static int int_value(vpiHandle h)
{
    s_vpi_value v;
    if (h == NULL)
        return -1;
    v.format = vpiIntVal;
    vpi_get_value(h, &v);
    return (int)v.value.integer;
}

static vpiHandle find(const char *name)
{
    vpiHandle h = vpi_handle_by_name((PLI_BYTE8 *)name, NULL);
    if (h == NULL)
        vpi_printf("%s: not found\n", name);
    return h;
}

static PLI_INT32 memory_calltf(PLI_BYTE8 *user_data)
{
    vpiHandle top = find(TOP), blk = find(TOP ".blk"), mem = find(TOP ".mem");
    vpiHandle it, h, word = NULL;
    s_vpi_value v;

    (void)user_data;
    list("memories of the module", vpiMemory, top);
    list("memories of blk", vpiMemory, blk);
    if (mem == NULL)
        return 0;
    vpi_printf("mem: type vpiRegArray %d, size %d, range %d:%d\n",
               vpi_get(vpiType, mem) == vpiRegArray, (int)vpi_get(vpiSize, mem),
               int_value(vpi_handle(vpiLeftRange, mem)), int_value(vpi_handle(vpiRightRange, mem)));
    list("words of mem", vpiMemoryWord, mem);
    it = vpi_iterate(vpiMemoryWord, mem);
    while (it && (h = vpi_scan(it)) != NULL)
        if (word == NULL && int_value(vpi_handle(vpiIndex, h)) == 2)
            word = h;
    if (word == NULL) {
        vpi_printf("no word with index 2\n");
        return 0;
    }
    v.format = vpiHexStrVal;
    vpi_get_value(word, &v);
    vpi_printf("word with index 2: type vpiReg %d, size %d, range %d:%d, value %s\n",
               vpi_get(vpiType, word) == vpiReg, (int)vpi_get(vpiSize, word),
               int_value(vpi_handle(vpiLeftRange, word)),
               int_value(vpi_handle(vpiRightRange, word)), v.value.str);
    h = vpi_handle(vpiParent, word);
    vpi_printf("its parent is mem: %d\n", h ? (int)vpi_compare_objects(h, mem) : -1);
    h = vpi_handle_by_index(mem, 2);
    vpi_printf("mem by index 2 is that word: %d\n", h ? (int)vpi_compare_objects(h, word) : -1);
    return 0;
}

static void register_all(void)
{
    s_vpi_systf_data d;
    memset(&d, 0, sizeof d);
    d.type = vpiSysTask;
    d.tfname = (PLI_BYTE8 *)"$vt_memory";
    d.calltf = memory_calltf;
    vpi_register_systf(&d);
}

void (*vlog_startup_routines[])(void) = {register_all, 0};

#ifdef __cplusplus
}
#endif
