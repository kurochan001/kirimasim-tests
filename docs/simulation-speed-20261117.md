# Speed improvements adopted for kirimasim 0.1.1: Mac, 2026-11-17

[English](simulation-speed-20261117.md) / [日本語](simulation-speed-20261117.ja.md)

Version 0.1.1 adopts word-based wide operations, an immutable first-operand type cache, and integral/void instruction routing. **The latest three-input direct comparison beats Icarus only on `proc_wait`: time ratios are gate 1.467, memory 1.093 and waiting 0.977 (kirimasim/Icarus).** It does not establish that the final source beats Icarus on all thirteen designs.

The earlier optimized source `7f5a9134` has a complete thirteen-input comparison: geometric mean time ratio 0.823 against Icarus and 0.774 against the unoptimized baseline, with smaller time on ten of thirteen inputs. The final routing source `1745b8fc` was timed on three inputs. These are separate campaigns; their ratios are not multiplied or pooled into a new thirteen-input score.

## Scope and method

- Apple M5 Max, 18 logical CPUs, 128 GiB, macOS 27.2.1. kirimasim uses AppleClang 21.0.0.21000401, release `-O3 -DNDEBUG -ffp-contract=off`, without fast-math; release-flag checks pass.
- Baseline `c152d237ac8dbd1b81349e7d578c25504d4ae8d5` has the same `src/` and CMake build settings as v0.1.0. The first optimized source is `7f5a9134f227e3d42491397105c745e11a5ed54a`; the additional routing source is `1745b8fc4e712d2b04fda5416184d3fc060358be`. The measurements precede the version-number change; 0.1.1 adopts these kernel/VM changes.
- Pinned Icarus is 14.0 devel `1eba3690d8314d79927df8690a7d97642dd93ce0`, using the same executable hashes as the previous Mac campaign. It is executed as a black box; its implementation source was not inspected.
- The original twelve `kirimasim/bench/*.sv` inputs and `kirimasim-tests/bench/fourstate_mix.sv` retain their N values and expected lines. Each variant has one n=1 warmup and five repetitions each of n=1 and N, with serial, alternating order.
- The metric is Δ = `median(T(N)) - median(T(1))`, seconds. Icarus compilation is separate; kirimasim parsing and elaboration are in its invocation. Baseline subtraction does not prove complete frontend separation. Raw invocation medians, min/max/MAD, RSS, commands, versions and hashes are retained.
- **These are provisional measurements with concurrent local CI.** External ctest/kirimasim activity and load averages were recorded, and the user agreed to proceed under that condition. Five-repeat descriptive statistics do not establish confidence intervals or performance gates.
- Dedicated Linux performance/RSS remeasurement of the adopted source remains deferred while WSL2 is busy. The [older Linux prototype results](simulation-speed-wsl2-followup-20261116.md) remain dated evidence for different sources.

## Thirteen inputs at 7f5a9134

This campaign compares baseline, optimized kirimasim and Icarus within the same serial campaign: 13 × 3 × (1 warmup + 5 small + 5 large) = 429 successful execution/output checks. All input/binary hashes remain unchanged. The geometric means weight designs equally, not by a production workload mix.

| Design | N | Baseline Δ s | 7f5a9134 Δ s | Icarus Δ s | 7f/Icarus | Reduction from baseline % |
|---|---:|---:|---:|---:|---:|---:|
| `casez_struct` | 5,000,000 | 3.629 | 2.744 | 3.208 | 0.855 | 24.4 |
| `comb_chain` | 3,000,000 | 8.144 | 7.052 | 8.049 | 0.876 | 13.4 |
| `dyn_queue` | 4,000,000 | 3.220 | 2.754 | 5.470 | 0.503 | 14.5 |
| `fork_join` | 4,000,000 | 4.162 | 3.819 | 4.076 | 0.937 | 8.2 |
| `func_call` | 1,500,000 | 4.348 | 3.911 | 7.364 | 0.531 | 10.0 |
| `gate_udp` | 400,000 | 4.977 | 4.111 | 2.713 | 1.515 | 17.4 |
| `mem_rw` | 4,000,000 | 4.097 | 3.486 | 2.923 | 1.193 | 14.9 |
| `nba_burst` | 500,000 | 0.092 | 0.076 | 0.091 | 0.837 | 17.0 |
| `nba_shift` | 1,000,000 | 21.786 | 18.094 | 18.800 | 0.962 | 16.9 |
| `proc_wait` | 1,000,000 | 5.999 | 5.413 | 5.165 | 1.048 | 9.8 |
| `string_fmt` | 500,000 | 3.742 | 3.163 | 7.169 | 0.441 | 15.5 |
| `wide_arith` | 1,500,000 | 6.932 | 1.773 | 2.023 | 0.877 | 74.4 |
| `fourstate_mix` | 1,000,000 | 1.133 | 0.924 | 1.287 | 0.718 | 18.5 |

The combined wide/type changes reduce `wide_arith` by 74.4% in this campaign. The wide-operation-only contribution is not inferred from this combined result. `gate_udp`, `mem_rw` and `proc_wait` remain above Icarus at this revision.

[All 429 executions](measurements/2026-11-17/main-7f5a9134-three-way.json). Campaign: 2026-11-17 01:38:08 JST to 2026-11-17 01:54:41 JST.

## Additional routing change at 1745b8fc

After every body result and block-parameter type is collected, the VM classifies instructions whose result is integral or void and whose operands all have integral static types. They skip unrelated class/container/string/real dispatch checks. Reference and typed-handle paths, kernel value operations and scheduler calls are retained. The first trial classified only integral results; the adopted source also includes void-result writes.

| Design | 7f5a9134 Δ s | First trial Δ s | 1745b8fc Δ s | Reduction from 7f % |
|---|---:|---:|---:|---:|
| `gate_udp` | 4.070 | 3.971 | 3.899 | 4.2 |
| `mem_rw` | 3.450 | 3.149 | 3.105 | 10.0 |
| `proc_wait` | 5.364 | 5.158 | 5.107 | 4.8 |

This is a separate three-variant comparison, 99 successful executions, at 2026-11-16T17:25:22.875115+00:00 to 2026-11-16T17:29:22.364149+00:00 UTC. These reductions describe the change from 7f5a9134, not a reduction from Icarus.

[Paired samples and complete counters](measurements/2026-11-17/dispatch-paired.json). The source patch recorded while building from parent 7f5a9134 is byte-identical to the subsequent commit 1745b8fc. Raw records retain their investigation status at measurement time; the adoption status is recorded here.

## Direct comparison of 1745b8fc and Icarus

The committed source was rebuilt and compared directly using the unchanged `tools/benchmark_compare.py`, five repetitions per count and tool plus warmup: 66 successful execution/output checks, all fingerprints unchanged. Time range: 2026-11-16T20:52:29.557147+00:00 to 2026-11-16T20:54:21.543282+00:00 UTC.

| Design | 1745b8fc Δ s | Icarus Δ s | 1745/Icarus |
|---|---:|---:|---:|
| `gate_udp` | 3.815 | 2.600 | 1.467 |
| `mem_rw` | 3.039 | 2.781 | 1.093 |
| `proc_wait` | 4.975 | 5.093 | 0.977 |

Only `proc_wait` has a smaller median Δ among these three. The final source does not yet have a thirteen-input timing score; the other ten inputs were checked for output/counter equality, not retimed in this follow-up.

[Direct comparison: all 66 executions](measurements/2026-11-17/dispatch-icarus.json).

## Remaining CPU work

Two macOS `sample` captures per input, at 1 ms intervals, describe the worker thread of 7f5a9134. The join-waiting parent is excluded. Self observations subtract direct child counts; the execute family includes compiler-generated lambdas. Inclusive categories overlap and are not exact CPU-time attribution. All six profile runs match expected output; their instrumented elapsed times are excluded from speed results.

| Design | Worker observations | execute family self % | runBody self % | waitTriggers inclusive % | udpOutput inclusive % |
|---|---:|---:|---:|---:|---:|
| `gate_udp` | 5206 | 31.1 | 19.0 | 13.6 | 3.7 |
| `mem_rw` | 5187 | 32.4 | 14.5 | 2.8 | 0.0 |
| `proc_wait` | 6906 | 28.1 | 25.6 | 0.0 | 0.0 |

Next candidates are operand-kind/temp-offset/PC predecoding, reusable static trigger construction for gates, and small slot/NBA registration paths for memory. Their gains are unmeasured. Preserve instruction limits, NBA issue order, delta cycles, iff/watch/strength behavior, frame/GC lifetimes, force and VPI notifications. Zero-delay NBA already uses an arena; a new payload allocator is not assumed necessary.

[Profile summary](measurements/2026-11-17/dispatch-profile.json).

## Startup, memory and correctness

On this Mac, `InstrInfo` grows from 72 to 88 bytes for the first-operand cache, and stays 88 bytes when the routing bit is placed in existing padding. In the earlier 404,001-instruction probe, the first cache increased peak RSS by about 6 MiB. The additional routing bit has this separate verified-SIR load/empty-run probe, with one warmup and seven alternating repetitions per size and variant:

| SIR instructions | 7f-equivalent load ms | Routing load ms | Load MAD ms, before/after | Peak RSS MiB, before/after |
|---|---:|---:|---:|---:|
| 101,001 | 2.719 | 2.750 | 0.069 / 0.065 | 36.52 / 36.50 |
| 404,001 | 10.969 | 11.044 | 0.106 / 0.128 | 134.17 / 134.16 |

The 404,001-instruction difference is about 0.076 ms, alongside MAD 0.106/0.128 ms. These probe times exclude the source frontend and are not general overhead bounds. [All load samples](measurements/2026-11-17/dispatch-load.json).

All thirteen outputs and complete counter key/value sets match the source-identical parent reference. The counts include the same logical events; no expected value, performance threshold, language contract or dependency was changed. The recorded dev run passes 13,858 tests. The full local-CI run is the pre-push gate for the 0.1.1 source, separate from this measurement campaign.

## Evidence and reproduction

The records under [measurements/2026-11-17/](measurements/2026-11-17/) retain the sources, exact versions, hashes, every sample and [build/source provenance](measurements/2026-11-17/build-and-source-provenance.json). Home paths and machine/user identifiers are excluded; raw sample logs remain private. The older [0.1.0 report](simulation-speed-20261116.md) and [prototype analysis](simulation-speed-analysis-20261116.md) retain their original dates and values.

For the final three-input comparison, use the pinned builds and test-repository driver:

```sh
python3 tools/benchmark_compare.py \
  --benchmark-root "$SOURCE" --kirimasim "$KIRIMASIM" --iverilog "$IVERILOG" \
  --kirimasim-commit 1745b8fc4e712d2b04fda5416184d3fc060358be \
  --icarus-commit 1eba3690d8314d79927df8690a7d97642dd93ce0 \
  --only gate_udp mem_rw proc_wait --runs 5 --out "$RESULTS"
```

This pins the measured pre-release source; a 0.1.1 checkout has a later version-metadata/documentation commit. Binary version and source hashes must match the chosen commit. Use the [portable three-way driver](measurements/2026-11-17/three_way_measure.py) for the earlier baseline/7f/Icarus ordering, and the recorded [SIR probe](measurements/2026-11-17/metadata_load.cpp) with [its build helper](measurements/2026-11-17/prepare_load.py) for loading. No simulator source or expectation should change during a campaign.
