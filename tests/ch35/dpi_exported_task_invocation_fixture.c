#ifdef __cplusplus
extern "C" {
#endif

extern int br_sv_action(int tag);

int br_enter_task(int tag, int *status)
{
    *status = br_sv_action(tag);
    return *status;
}

int br_enter_function(int tag)
{
    return br_sv_action(tag);
}

#ifdef __cplusplus
}
#endif
