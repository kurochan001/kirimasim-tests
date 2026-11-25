#include <stdlib.h>
#include <sys/mman.h>
#include <sys/socket.h>
#include <unistd.h>

#ifdef __cplusplus
extern "C" {
#endif

int dpi_env_pid(int seed)
{
    const char *key = "KIRIMASIM_DPI_EXTERNAL_FIXTURE";
    const char replacement[] = {(char)('a' + seed), '\0'};
    int result;
    const char *value;
    if (getenv(key) != NULL || getpid() < 1 || setenv(key, replacement, 1) != 0)
        return -1;
    value = getenv(key);
    result = value ? value[0] - 'a' : -1;
    return unsetenv(key) == 0 ? result : -1;
}

static int send_shared_byte(int seed)
{
    unsigned char *region = (unsigned char *)mmap(NULL, 1, PROT_READ | PROT_WRITE,
                                                 MAP_SHARED | MAP_ANONYMOUS, -1, 0);
    int endpoints[2], answer = -1;
    if (region == MAP_FAILED)
        return -1;
    if (socketpair(AF_UNIX, SOCK_STREAM, 0, endpoints) == 0) {
        *region = (unsigned char)seed;
        if (send(endpoints[0], region, 1, 0) == 1 &&
            recv(endpoints[1], region, 1, 0) == 1)
            answer = *region;
        close(endpoints[0]);
        close(endpoints[1]);
    }
    return munmap(region, 1) == 0 ? answer : -1;
}

int dpi_shared_socket(int seed)
{
    return send_shared_byte(seed);
}

#ifdef __cplusplus
}
#endif
