#include <stddef.h>
#include <string.h>
#include "sv_vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

#define TOP "test_vpi_assertion_start_occurs_only_for_evaluated_instances"

struct starts {
    unsigned at_tick[3];
    unsigned other_tick;
};

static struct starts property, sequence;
static unsigned property_registration, sequence_registration;
static unsigned unused_property, unused_sequence, unused_starts;

static PLI_INT32 record(PLI_INT32 reason, p_vpi_time time, vpiHandle assertion,
                        p_vpi_attempt_info info, PLI_BYTE8 *user_data)
{
    (void)assertion;
    (void)info;
    struct starts *item = (struct starts *)user_data;
    if (item == NULL) {
        unused_starts++;
        return 0;
    }
    double tick = -1.0;
    if (time != NULL && time->type == vpiScaledRealTime)
        tick = time->real;
    if (time != NULL && time->type == vpiSimTime && time->high == 0)
        tick = time->low;
    if (reason == cbAssertionStart) {
        for (unsigned index = 0; index < 3; ++index) {
            if (tick == 5 + 10 * index) {
                item->at_tick[index]++;
                return 0;
            }
        }
    }
    item->other_tick++;
    return 0;
}

static vpiHandle declaration_in(vpiHandle scope, PLI_INT32 type, const char *name)
{
    vpiHandle iterator = vpi_iterate(type, scope);
    vpiHandle item, found = NULL;
    while (iterator != NULL && (item = vpi_scan(iterator)) != NULL) {
        const char *actual = vpi_get_str(vpiName, item);
        if (actual != NULL && strcmp(actual, name) == 0)
            found = item;
    }
    return found;
}

static unsigned watch_live(vpiHandle scope, const char *label, PLI_INT32 type,
                           struct starts *item)
{
    vpiHandle statement = vpi_handle_by_name((PLI_BYTE8 *)label, scope);
    if (statement == NULL)
        return 0;
    vpiHandle instance = vpi_handle(vpiProperty, statement);
    if (instance != NULL && vpi_get(vpiType, instance) == vpiPropertySpec)
        instance = vpi_handle(vpiPropertyExpr, instance);
    return instance != NULL && vpi_get(vpiType, instance) == type &&
           vpi_register_assertion_cb(instance, cbAssertionStart, record,
                                     (PLI_BYTE8 *)item) != NULL;
}

static unsigned watch_unused(vpiHandle scope, PLI_INT32 type, const char *name)
{
    vpiHandle declaration = declaration_in(scope, type, name);
    if (declaration == NULL)
        return 0;
    /* The unused declaration must never start an evaluation, even if the
       registration is accepted. */
    vpi_register_assertion_cb(declaration, cbAssertionStart, record, NULL);
    return 1;
}

static PLI_INT32 watch_call(PLI_BYTE8 *unused)
{
    (void)unused;
    vpiHandle scope = vpi_handle_by_name((PLI_BYTE8 *)TOP, NULL);
    if (scope != NULL) {
        property_registration = watch_live(scope, "checked", vpiPropertyInst, &property);
        sequence_registration = watch_live(scope, "covered", vpiSequenceInst, &sequence);
        unused_property = watch_unused(scope, vpiPropertyDecl, "p_unused");
        unused_sequence = watch_unused(scope, vpiSequenceDecl, "s_unused");
    }
    return 0;
}

static PLI_INT32 report(PLI_BYTE8 *unused)
{
    (void)unused;
    vpi_printf("instance registrations=%u%u unused declarations=%u%u\n",
               property_registration, sequence_registration, unused_property, unused_sequence);
    vpi_printf("property starts=%u%u%u sequence starts=%u%u%u\n",
               property.at_tick[0], property.at_tick[1], property.at_tick[2],
               sequence.at_tick[0], sequence.at_tick[1], sequence.at_tick[2]);
    vpi_printf("unused starts=%u other time starts=%u\n",
               unused_starts, property.other_tick + sequence.other_tick);
    return 0;
}

static void add_task(const char *name, PLI_INT32 (*callback)(PLI_BYTE8 *))
{
    s_vpi_systf_data definition = {0};
    definition.type = vpiSysTask;
    definition.tfname = (PLI_BYTE8 *)name;
    definition.calltf = callback;
    vpi_register_systf(&definition);
}

static void setup(void)
{
    add_task("$vt_watch_start", watch_call);
    add_task("$vt_start_report", report);
}

void (*vlog_startup_routines[])(void) = {setup, NULL};

#ifdef __cplusplus
}
#endif
