#include <stddef.h>
#include <stdio.h>
#include <string.h>
#include "vpi_user.h"

#if defined(_WIN32)
#include <io.h>
#define vt_dup _dup
#define vt_dup2 _dup2
#define vt_close _close
#define vt_fileno _fileno
#else
#include <unistd.h>
#define vt_dup dup
#define vt_dup2 dup2
#define vt_close close
#define vt_fileno fileno
#endif

#ifdef __cplusplus
extern "C" {
#endif

static int contains_line(FILE *stream, const char *needle)
{
    char text[1024];
    if (stream == NULL)
        return 0;
    while (fgets(text, sizeof text, stream) != NULL)
        if (strstr(text, needle) != NULL)
            return 1;
    return 0;
}

static PLI_INT32 probe_flush(PLI_BYTE8 *unused)
{
    FILE *capture = tmpfile();
    int console = vt_fileno(stdout);
    int saved = vt_dup(console);
    (void)unused;
    if (capture == NULL || saved < 0) {
        if (capture != NULL)
            fclose(capture);
        if (saved >= 0)
            vt_close(saved);
        return 0;
    }

    fflush(stdout);
    if (vt_dup2(vt_fileno(capture), console) < 0) {
        vt_close(saved);
        fclose(capture);
        return 0;
    }

    const char *marker = "live VPI bytes 847, no newline";
    vpi_printf("%s", marker);
    int status = vpi_flush();
    rewind(capture);
    int console_has_marker = contains_line(capture, marker);
    FILE *log = fopen("active-vpi.log", "r");
    int log_has_marker = contains_line(log, marker);
    if (log != NULL)
        fclose(log);

    vt_dup2(saved, console);
    vt_close(saved);
    fclose(capture);
    vpi_printf("flush status=%d output present=%d log present=%d\n",
               status, console_has_marker, log_has_marker);
    return 0;
}

static void install(void)
{
    s_vpi_systf_data task = {0};
    task.type = vpiSysTask;
    task.tfname = (PLI_BYTE8 *)"$vt_flush_observe";
    task.calltf = probe_flush;
    vpi_register_systf(&task);
}

void (*vlog_startup_routines[])(void) = {install, NULL};

#ifdef __cplusplus
}
#endif
