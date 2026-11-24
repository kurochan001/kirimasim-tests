#include <locale.h>
#include <stddef.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <wchar.h>
#include "vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

static int log_has_output(void)
{
    FILE *log = fopen("format-vpi.log", "r");
    char line[1024];
    int found = 0;
    if (log == NULL)
        return 0;
    while (!found && fgets(line, sizeof line, log) != NULL)
        found = strstr(line, "formatted [007] +12") != NULL;
    fclose(log);
    return found;
}

static PLI_INT32 probe(PLI_BYTE8 *unused)
{
    (void)unused;
    int count = vpi_printf("formatted [%03d] %+d\n", 7, 12);
    vpi_flush();
    vpi_printf("printed count=%d log contains=%d\n", count, log_has_output());

    const char *current = setlocale(LC_CTYPE, NULL);
    if (current == NULL)
        return 0;
    size_t length = strlen(current) + 1;
    char *restore = (char *)malloc(length);
    if (restore == NULL)
        return 0;
    memcpy(restore, current, length);
    if (setlocale(LC_CTYPE, "C") == NULL) {
        free(restore);
        return 0;
    }
    char buffer[16];
    const wint_t outside_c_locale = 0x100;
    int c_result = snprintf(buffer, sizeof buffer, "%lc", outside_c_locale);
    int vpi_result = vpi_printf("%lc", outside_c_locale);
    setlocale(LC_CTYPE, restore);
    free(restore);

    vpi_printf("C encoding error=%d vpi EOF=%d\n", c_result < 0, vpi_result == EOF);
    return 0;
}

static void install(void)
{
    s_vpi_systf_data task = {0};
    task.type = vpiSysTask;
    task.tfname = (PLI_BYTE8 *)"$vt_check_print";
    task.calltf = probe;
    vpi_register_systf(&task);
}

void (*vlog_startup_routines[])(void) = {install, NULL};

#ifdef __cplusplus
}
#endif
