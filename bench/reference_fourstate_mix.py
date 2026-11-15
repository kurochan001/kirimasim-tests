"""Standard-derived reference; does not run or import any simulator."""

import argparse


def expected(n):
    if n < 1:
        raise ValueError("n must be positive")
    seed = 0x12345678
    checksum = 0
    for index in range(n):
        seed = (1664525 * seed + 1013904223) & 0xFFFFFFFF
        # AND clears the low half in even phases; odd phases retain seed.
        low_result = 0xFFFF if index % 2 == 0 else (seed & 0xFFFF) ^ 0xFFFF
        checksum = (checksum + (low_result ^ (seed >> 16))) & 0xFFFFFFFF
    # Only phase 2 produces X in r. Phases 1 and 2/3 preserve X and Z in a.
    unknowns = (n + 1) // 4
    x_hits = (n + 2) // 4
    z_hits = (n // 4) * 2 + max(0, n % 4 - 2)
    return (f"fourstate_mix n={n} checksum={checksum:08x} unknowns={unknowns} "
            f"x_hits={x_hits} z_hits={z_hits}")


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--n", type=int, default=1000000)
    print(expected(parser.parse_args().n))
