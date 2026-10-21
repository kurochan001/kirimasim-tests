/* VPI application of test_vpi_systf_registry_iteration (IEEE 1800-2023 36.3.1). */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

#define MAX_ENTRIES 8

struct entry {
    char name[32];
    PLI_INT32 type;
    const char *user_data;
    vpiHandle handle;
};

static struct entry registered[MAX_ENTRIES];
static int registered_count;

static int by_name(const void *a, const void *b)
{
    return strcmp(((const struct entry *)a)->name, ((const struct entry *)b)->name);
}

/* The handle that the registration of name returned, or NULL. */
static vpiHandle registration_of(const char *name)
{
    int i;

    for (i = 0; i < registered_count; i++)
        if (strcmp(registered[i].name, name) == 0)
            return registered[i].handle;
    return NULL;
}

static PLI_INT32 list_calltf(PLI_BYTE8 *user_data)
{
    vpiHandle call = vpi_handle(vpiSysTfCall, NULL);
    vpiHandle it, systf, own;
    struct entry found[MAX_ENTRIES];
    int count = 0, same = 1, i;

    (void)user_data;
    vpi_printf("the call of $vt_list is user-defined: %s\n",
               vpi_get(vpiUserDefn, call) == 1 ? "yes" : "no");
    it = vpi_iterate(vpiUserSystf, NULL);
    while (it != NULL && (systf = vpi_scan(it)) != NULL) {
        s_vpi_systf_data d;
        memset(&d, 0, sizeof d);
        vpi_get_systf_info(systf, &d);
        if (d.tfname == NULL || strncmp(d.tfname, "$vt_", 4) != 0 || count == MAX_ENTRIES)
            continue;
        snprintf(found[count].name, sizeof found[count].name, "%s", d.tfname);
        found[count].type = d.type;
        found[count].user_data = d.user_data;
        own = registration_of(found[count].name);
        same = same && own != NULL && vpi_compare_objects(own, systf);
        count++;
    }
    qsort(found, (size_t)count, sizeof found[0], by_name);
    for (i = 0; i < count; i++)
        vpi_printf("registered: %s, a %s, user data \"%s\"\n", found[i].name,
                   found[i].type == vpiSysTask ? "task"
                   : found[i].type == vpiSysFunc ? "function" : "?",
                   found[i].user_data != NULL ? found[i].user_data : "");
    vpi_printf("each is the object its registration returned: %s\n", same ? "yes" : "no");
    return 0;
}

static PLI_INT32 mark_calltf(PLI_BYTE8 *user_data)
{
    (void)user_data;
    vpi_printf("$vt_mark ran\n");
    return 0;
}

static PLI_INT32 triple_calltf(PLI_BYTE8 *user_data)
{
    vpiHandle call = vpi_handle(vpiSysTfCall, NULL);
    vpiHandle it = vpi_iterate(vpiArgument, call);
    vpiHandle arg = it != NULL ? vpi_scan(it) : NULL;
    s_vpi_value v;

    (void)user_data;
    if (arg == NULL)
        return 0;
    vpi_free_object(it);
    v.format = vpiIntVal;
    vpi_get_value(arg, &v);
    v.value.integer *= 3;
    vpi_put_value(call, &v, NULL, vpiNoDelay);
    return 0;
}

static void add(PLI_INT32 type, const char *name, PLI_INT32 (*calltf)(PLI_BYTE8 *),
                const char *routine)
{
    s_vpi_systf_data d;

    memset(&d, 0, sizeof d);
    d.type = type;
    d.sysfunctype = type == vpiSysFunc ? vpiIntFunc : 0;
    d.tfname = (PLI_BYTE8 *)name;
    d.calltf = calltf;
    d.user_data = (PLI_BYTE8 *)routine;
    snprintf(registered[registered_count].name, sizeof registered[0].name, "%s", name);
    registered[registered_count].handle = vpi_register_systf(&d);
    registered_count++;
}

static void register_first(void)
{
    add(vpiSysTask, "$vt_list", list_calltf, "first routine");
    add(vpiSysFunc, "$vt_triple", triple_calltf, "first routine");
}

static void register_second(void)
{
    add(vpiSysTask, "$vt_mark", mark_calltf, "second routine");
}

void (*vlog_startup_routines[])(void) = {register_first, register_second, 0};

#ifdef __cplusplus
}
#endif
