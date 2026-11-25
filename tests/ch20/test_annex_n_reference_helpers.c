#include <math.h>

#ifdef __cplusplus
extern "C" {
#endif

#ifdef ANNEX_N_REFERENCE_CHECK
static void print_error(const char *first, const char *second)
{
    (void)first;
    (void)second;
}

#include "annex_n_reference_input.h"

static double (*const uniform_call)(long *, long, long) = uniform;
static double (*const normal_call)(long *, long, long) = normal;
static double (*const exponential_call)(long *, long) = exponential;
static double (*const chi_square_call)(long *, long) = chi_square;
static double (*const t_call)(long *, long) = t;
static double (*const erlang_call)(long *, long, long) = erlangian;
static long (*const poisson_call)(long *, long) = poisson;

int annex_n_signatures(void)
{
    long seeds[] = {17, 17, 17, 17, 17, 17, 17};
    double samples[] = {
        uniform_call(&seeds[0], -5, 20), normal_call(&seeds[1], 1, 2),
        exponential_call(&seeds[2], 2), chi_square_call(&seeds[3], 3),
        t_call(&seeds[4], 4), erlang_call(&seeds[5], 2, 5),
    };
    long count = poisson_call(&seeds[6], 3);
    for (int index = 0; index < 6; ++index) {
        if (!isfinite(samples[index]) || seeds[index] == 17)
            return 0;
    }
    return count >= 0 && seeds[6] != 17;
}

int annex_n_uniform_ranges(void)
{
    const long start_seed = 17001;
    const long next_seed = 69069L * start_seed + 1;
    long same = start_seed, reverse = start_seed, explicit_range = start_seed;
    long ordered = start_seed, normalized = start_seed;
    double equal_sample = uniform_call(&same, 9, 9);
    double reverse_sample = uniform_call(&reverse, 21, -7);
    double explicit_sample = uniform_call(&explicit_range, 0, 2147483647L);
    double ordered_sample = uniform_call(&ordered, -37, 18);
    double unit_sample = uniform_call(&normalized, 0, 1);
    return next_seed == same && same == reverse && reverse == explicit_range
        && ordered == next_seed && normalized == next_seed
        && equal_sample == explicit_sample && reverse_sample == explicit_sample
        && explicit_sample > 0 && explicit_sample < 2147483647.0
        && unit_sample > 0 && unit_sample < 1
        && fabs(ordered_sample - (55.0 * unit_sample - 37.0)) < 1e-10;
}
#else
int annex_n_signatures(void) { return -1; }
int annex_n_uniform_ranges(void) { return -1; }
#endif

#ifdef __cplusplus
}
#endif
