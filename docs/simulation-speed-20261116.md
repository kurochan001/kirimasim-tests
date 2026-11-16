# kirimasim 0.1.0 versus Icarus 14.0 devel: Mac, WSL2 and countermeasures

[English](simulation-speed-20261116.md) / [日本語](simulation-speed-20261116.ja.md)

Geometric mean elapsed-time ratios on the same thirteen designs are **Mac 1.065, initial WSL2 1.193 and WSL2 rerun 1.220** (kirimasim/Icarus). **Both WSL2 release runs are provisional because external ctest/UVM activity overlapped.** Separate Linux prototype measurements reduce time about 51% for wide arithmetic, 16% for gates and 14% for memory, with all thirteen outputs/counter sets checked. The [received follow-up](simulation-speed-wsl2-followup-20261116.md) supplies the breakdown without introducing a P1 threshold.

## Reading guide and method

- [Mac details and all samples](simulation-speed-mac-20261116.md): Apple M5 Max, 18 logical CPUs, 128 GiB, macOS 27.2.1, AppleClang 21.0.0. OS indexing/editor background activity is recorded.
- [WSL2 details and receipt checks](simulation-speed-wsl2-20261116.md): Ryzen 9 7950X, 32 logical CPUs, 110 GiB, Ubuntu 24.04.4 / WSL2, Clang 20.1.8. Concurrent-load interference and spread are explicit.
- [Investigation, prototype patches and measured effects](simulation-speed-analysis-20261116.md): Mac profiling and contemporaneous release/prototype/Icarus timings.

kirimasim is fixed at v0.1.0 `cfa2ccd75989c1ebb9ed63303271183377364cf0`, and Icarus at the 14.0 devel snapshot retrieved at campaign start, `1eba3690d8314d79927df8690a7d97642dd93ce0`. The original twelve designs, standard-derived X/Z addition, N values, expectations and source/driver/adapter hashes match across platforms. All 858 release invocations across the three records passed output and exit checks.

Each tool has one n=1 warmup and five repetitions each of n=1 and N, serially alternating order. Primary Δ is `median(T(N))−median(T(1))`, and the ratio is `Δkirimasim/ΔIcarus`; below 1 favors kirimasim. Icarus compilation is separate, while kirimasim parsing/elaboration remains in each invocation. Full elapsed times, n=1, min/max and MAD are retained in the detailed records.

These are within-environment ratios on different CPUs, operating systems and compilers. Absolute machine speeds are not pooled, and geometric means weight designs equally as descriptive statistics. No complete startup separation or statistical significance is claimed.

## Release comparison

| Metric | Mac | Initial WSL2 (provisional) | WSL2 rerun (provisional) |
|---|---:|---:|---:|
| All thirteen geometric mean KM/I | 1.065 | 1.193 | 1.220 |
| Original twelve only | 1.080 | 1.211 | 1.240 |

| Design | N | Mac KM/I | WSL2 first | WSL2 rerun |
|---|---:|---:|---:|---:|
| `casez_struct` | 5,000,000 | 1.117 | 1.203 | 1.196 |
| `comb_chain` | 3,000,000 | 1.028 | 1.178 | 1.159 |
| `dyn_queue` | 4,000,000 | 0.589 | 0.720 | 0.724 |
| `fork_join` | 4,000,000 | 1.000 | 1.457 | 1.413 |
| `func_call` | 1,500,000 | 0.594 | 0.798 | 0.815 |
| `gate_udp` | 400,000 | 1.831 | 1.715 | 1.705 |
| `mem_rw` | 4,000,000 | 1.423 | 1.688 | 1.707 |
| `nba_burst` | 500,000 | 1.006 | 1.067 | 1.125 |
| `nba_shift` | 1,000,000 | 1.180 | 1.354 | 1.302 |
| `proc_wait` | 1,000,000 | 1.178 | 1.473 | 1.575 |
| `string_fmt` | 500,000 | 0.520 | 0.563 | 0.678 |
| `wide_arith` | 1,500,000 | 3.316 | 2.415 | 2.526 |
| `fourstate_mix` | 1,000,000 | 0.895 | 1.004 | 1.000 |

CPU, OS and compiler differ between platforms; these are within-environment ratios. Both original WSL2 records are retained, and the quiet-start rerun is not promoted to an idle baseline.

## Causes and countermeasure priority

Bit-at-a-time wide work and repeated lookup of immutable operand types remain the first optimization candidates. Both patches now have measured effects on both platforms. [Mac CPU attribution](simulation-speed-analysis-20261116.md) and [additional Linux measurements](simulation-speed-wsl2-followup-20261116.md) are recorded separately.

| Design | Mac time reduction | WSL2 time reduction | WSL2 prototype/Icarus |
|---|---:|---:|---:|
| `wide_arith` | 73.87% | 51.36% | 1.223 |
| `gate_udp` | 18.93% | 15.72% | 1.478 |
| `mem_rw` | 14.67% | 14.16% | 1.487 |
| `nba_shift` | 17.09% | 18.57% | 1.102 |
| `proc_wait` | 7.75% | 14.01% | 1.270 |

The Linux prototype still takes longer than Icarus in these five cases; remaining VM dispatch, static trigger construction and temporary buffers are further investigation targets. Both platforms have five repetitions on five timed designs and matching expected output on all thirteen. WSL2 matches all thirteen counter sets against release and Mac, and reports Wide 7/7, Valsem 15/15 and 122,184 additional reference checks. Adoption still requires full local CI, sanitizers, type/boundary/alias regressions and large-SIR memory/startup checks. Simulator main is unchanged.

## Follow-up and evidence

The latest private Git relay reply is `from-wsl/p1-speed-0.1.0-2026-11-16` at `ee544e7f`. The quiet-start rerun and prototype checks are received, verified and retained in the [follow-up](simulation-speed-wsl2-followup-20261116.md). A definitive idle release baseline remains unverified because external work overlapped the rerun.

Raw data, hashes, medians and spread are under [measurements/2026-11-16/](measurements/2026-11-16/) and its `wsl2-followup/` subdirectory. Earlier evidence, conformance counts, requirements and coverage remain unchanged.
