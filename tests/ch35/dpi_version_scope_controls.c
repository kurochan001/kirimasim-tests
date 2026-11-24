#ifdef __cplusplus
extern "C" {
#endif

int scalar_legacy_scope(int value)
{
    return value + 17;
}

int scalar_current_scope(int value)
{
    return value * 3 - 2;
}

#ifdef __cplusplus
}
#endif
