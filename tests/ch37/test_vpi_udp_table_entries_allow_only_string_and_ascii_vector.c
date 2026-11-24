#include <ctype.h>
#include <stddef.h>
#include "sv_vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

#define TOP "test_vpi_udp_table_entries_allow_only_string_and_ascii_vector"

static const PLI_INT32 other_formats[] = {
    vpiBinStrVal, vpiOctStrVal, vpiDecStrVal, vpiHexStrVal, vpiScalarVal,
    vpiIntVal, vpiRealVal, vpiTimeVal, vpiStrengthVal, vpiObjTypeVal
};

static void read_row(const char *label, const char *path)
{
    vpiHandle udp = vpi_handle_by_name((PLI_BYTE8 *)path, NULL);
    vpiHandle definition = udp != NULL ? vpi_handle(vpiUdpDefn, udp) : NULL;
    vpiHandle entries = definition != NULL ? vpi_iterate(vpiTableEntry, definition) : NULL;
    vpiHandle entry = entries != NULL ? vpi_scan(entries) : NULL;
    if (entry == NULL) {
        vpi_printf("%s: no table entry\n", label);
        return;
    }
    /* Single row, so exhaust the iterator and keep the row handle. */
    if (vpi_scan(entries) != NULL) {
        vpi_printf("%s: unexpected second row\n", label);
        vpi_release_handle(entries);
        return;
    }

    s_vpi_value text = {0};
    text.format = vpiStringVal;
    vpi_get_value(entry, &text);
    vpi_printf("%s text=", label);
    if (text.format == vpiStringVal && text.value.str != NULL) {
        const unsigned char *p = (const unsigned char *)text.value.str;
        for (; *p != '\0'; ++p) {
            if (!isspace(*p) && *p != ';')
                vpi_printf("%c", *p);
        }
    }
    vpi_printf("\n");

    s_vpi_value vector = {0};
    vector.format = vpiVectorVal;
    vpi_get_value(entry, &vector);
    if (vector.format == vpiVectorVal && vector.value.vector != NULL) {
        unsigned a = vector.value.vector[0].aval, b = vector.value.vector[0].bval;
        vpi_printf("%s vector=%08x/%08x\n", label, a, b);
    } else {
        vpi_printf("%s: no ASCII vector\n", label);
    }

    unsigned rejected = 0;
    const size_t count = sizeof other_formats / sizeof *other_formats;
    for (size_t i = 0; i < count; ++i) {
        s_vpi_value unavailable = {0};
        unavailable.format = other_formats[i];
        vpi_get_value(entry, &unavailable);
        s_vpi_error_info error = {0};
        rejected += vpi_chk_error(&error) >= vpiError || unavailable.format == vpiSuppressVal;
    }
    vpi_printf("%s rejected=%u/%u\n", label, rejected, (unsigned)count);
}

static PLI_INT32 inspect(PLI_BYTE8 *unused)
{
    (void)unused;
    read_row("combinational", TOP ".combinational");
    read_row("sequential", TOP ".sequential");
    return 0;
}

static void setup(void)
{
    s_vpi_systf_data definition = {0};
    definition.type = vpiSysTask;
    definition.tfname = "$vt_row_formats";
    definition.calltf = inspect;
    vpi_register_systf(&definition);
}

void (*vlog_startup_routines[])(void) = {setup, NULL};

#ifdef __cplusplus
}
#endif
