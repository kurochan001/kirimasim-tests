#ifdef __cplusplus
extern "C" {
#endif

int dpi_pure_lookup(int seed)
{
    return 3 * seed + 2;
}

int dpi_local_history(int seed)
{
    static int calls;
    return seed + ++calls;
}

static int global_calls;

static int advance_global_history(void)
{
    return ++global_calls;
}

int dpi_global_history(int seed)
{
    return seed + advance_global_history();
}

#ifdef __cplusplus
}
#endif
