#ifdef __cplusplus
extern "C" {
#endif

void dpi_write_fresh_outputs(int seed, int *number, double *fraction)
{
    *number = 3 * seed + 2;
    *fraction = 0.5 * seed + 1.0;
}

#ifdef __cplusplus
}
#endif
