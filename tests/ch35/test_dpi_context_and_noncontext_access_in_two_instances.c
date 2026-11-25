#ifdef __cplusplus
extern "C" {
#endif

extern int h65_read_cell(void);
extern void h65_write_cell(int next_state);

int h65_context(int delta)
{
    const int before = h65_read_cell();
    h65_write_cell(before + delta);
    return before;
}

int h65_arguments(int item, int *count)
{
    *count -= 2;
    return item * 3;
}

#ifdef __cplusplus
}
#endif
