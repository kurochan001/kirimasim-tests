# kirimasim 0.1.0 versus Icarus 14.0 devel: Mac, WSL2 and countermeasures

[English](simulation-speed-20261116.md) / [日本語](simulation-speed-20261116.ja.md)

This is the entry point for the 2026-11-16 comparison and investigation. The geometric mean elapsed-time ratios on the same thirteen designs are **Mac 1.065 and WSL2 1.193** (kirimasim/Icarus): about 6.5% and 19.3% more time in these records. **The WSL2 run is provisional because external ctest/UVM activity overlapped**; a quiet rerun is requested. No P1 acceptance threshold is introduced; the per-workload breakdown identifies improvement candidates.

## Reading guide and method

- [Mac details and all samples](simulation-speed-mac-20261116.md): Apple M5 Max, 18 logical CPUs, 128 GiB, macOS 27.2.1, AppleClang 21.0.0. OS indexing/editor background activity is recorded.
- [WSL2 details and receipt checks](simulation-speed-wsl2-20261116.md): Ryzen 9 7950X, 32 logical CPUs, 110 GiB, Ubuntu 24.04.4 / WSL2, Clang 20.1.8. Concurrent-load interference and spread are explicit.
- [Investigation, prototype patches and measured effects](simulation-speed-analysis-20261116.md): Mac profiling and contemporaneous release/prototype/Icarus timings.

kirimasim is fixed at v0.1.0 `cfa2ccd75989c1ebb9ed63303271183377364cf0`, and Icarus at the 14.0 devel snapshot retrieved at campaign start, `1eba3690d8314d79927df8690a7d97642dd93ce0`. The original twelve designs, standard-derived X/Z addition, N values, expectations and source/driver/adapter hashes match across platforms. All 572 invocations passed output and exit checks.

Each tool has one n=1 warmup and five repetitions each of n=1 and N, serially alternating order. Primary Δ is `median(T(N))−median(T(1))`, and the ratio is `Δkirimasim/ΔIcarus`; below 1 favors kirimasim. Icarus compilation is separate, while kirimasim parsing/elaboration remains in each invocation. Full elapsed times, n=1, min/max and MAD are retained in the detailed records.

These are within-environment ratios on different CPUs, operating systems and compilers. Absolute machine speeds are not pooled, and geometric means weight designs equally as descriptive statistics. No complete startup separation or statistical significance is claimed.

## Release comparison

| Metric | Mac | WSL2 (provisional, concurrent load) |
|---|---:|---:|
| All thirteen geometric mean KM/I | 1.065 | 1.193 |
| Original twelve only | 1.080 | 1.211 |
| Output checks | 13/13 designs, 286 invocations match | 13/13 designs, 286 invocations match |

| Benchmark | N | Mac KM/I | WSL2 KM/I (provisional) |
|---|---:|---:|---:|
| `casez_struct` | 5,000,000 | 1.117 | 1.203 |
| `comb_chain` | 3,000,000 | 1.028 | 1.178 |
| `dyn_queue` | 4,000,000 | 0.589 | 0.720 |
| `fork_join` | 4,000,000 | 1.000 | 1.457 |
| `func_call` | 1,500,000 | 0.594 | 0.798 |
| `gate_udp` | 400,000 | 1.831 | 1.715 |
| `mem_rw` | 4,000,000 | 1.423 | 1.688 |
| `nba_burst` | 500,000 | 1.006 | 1.067 |
| `nba_shift` | 1,000,000 | 1.180 | 1.354 |
| `proc_wait` | 1,000,000 | 1.178 | 1.473 |
| `string_fmt` | 500,000 | 0.520 | 0.563 |
| `wide_arith` | 1,500,000 | 3.316 | 2.415 |
| `fourstate_mix` | 1,000,000 | 0.895 | 1.004 |

Wide arithmetic, gates/UDP and memory read/write have large gaps in both records. WSL2 also shows gaps in fork/join and waiting processes, but this record cannot separate compiler, CPU and concurrent-load effects. Linux CPU attribution and prototype benefits require separate checks.

## Causes and countermeasure priority

1. **Word operations for wide values.** Bit-at-a-time shifts, selections and concatenation writes account for 63.2% of Mac wide-worker observations. A 64-bit-word prototype reduces Δ from 6.598 s to 1.829 s, or 1.724 s with type caching too. It preserves X/Z while reducing time about 74%; contemporaneous Icarus is 2.012 s.
2. **Precompute immutable type information.** Caching repeated first-operand type lookups in the VM reduces time about 19% for gates, 15% for memory, 17% for NBA and 8% for waiting processes. A type-cache-only control is retained.
3. **Remaining VM work and static trigger construction.** The prototype still takes about 1.51 times Icarus for gates/UDP and 1.21 for memory. Typed/operand-location predecoding and reuse of wait information are next candidates. Their additional benefit is unmeasured and must preserve NBA ordering, delta cycles, iff, VPI/force and reference lifetimes.

The prototype has five-round timing comparisons on five designs, matching expected outputs on all thirteen designs, identical counters on six designs with baseline records, seven existing wide/valsem tests and 122,184 additional reference comparisons. It is not applied to simulator main. Adoption requires full local CI, sanitizers, type/boundary/alias regressions, large-SIR memory/startup assessment and WSL2 confirmation. The [investigation](simulation-speed-analysis-20261116.md) contains concrete proposed diffs.

## Follow-up and evidence

WSL2 results arrived via private Git relay `from-wsl/p1-speed-0.1.0-2026-11-16` at `f88c63e5`. The loaded run is preserved; a same-condition quiet rerun is requested under `linux/quiet-rerun/`, followed by separate prototype comparisons under `linux/prototypes/`. Those new results have not been received.

Raw samples, source/driver/binary hashes, medians and spread are in [measurements/2026-11-16/](measurements/2026-11-16/). Conformance counts, requirements, coverage and the [earlier measurement archive](readme-records-20261101.md#simulation-speed) are unchanged.
