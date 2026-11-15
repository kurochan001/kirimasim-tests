# kirimasim 0.1.0 versus Icarus 14.0 devel: Mac, 2026-11-16

[English](simulation-speed-mac-20261116.md) / [日本語](simulation-speed-mac-20261116.ja.md)

On this Mac, the geometric mean **kirimasim/Icarus elapsed-time ratio was 1.065** across 13/13 comparable designs: kirimasim took about 6.5% more time by this metric. The original twelve alone give 1.080; kirimasim had a smaller baseline-subtracted elapsed time Δ in 5/13 designs including the addition. Ratios below 1 favor kirimasim. The geometric mean weights designs equally and does not model a production workload mix.

Per-design ratios range from 0.520 (`string_fmt`) to 3.316 (`wide_arith`). The aggregate is close to Icarus, but the gaps in wide arithmetic (3.316), gates/UDP (1.831) and memory read/write (1.423) prevent a claim of equivalent performance across these workloads. These are candidates for subsequent profiling; this timing comparison does not establish the causes. This measurement introduces no P1 acceptance threshold and makes no claim about Linux or other designs.

## Targets and environment

- kirimasim [v0.1.0](https://github.com/kurochan001/kirimasim/releases/tag/v0.1.0), commit `cfa2ccd75989c1ebb9ed63303271183377364cf0`. AppleClang 21.0.0.21000401, release (`-O3 -DNDEBUG -ffp-contract=off`, no fast-math); release flag check passed.
- Icarus [master](https://github.com/steveicarus/iverilog/tree/1eba3690d8314d79927df8690a7d97642dd93ce0), retrieved at campaign start and frozen at `1eba3690d8314d79927df8690a7d97642dd93ce0`. Executable version: `14.0 (devel) (1eba369)`. Same Apple clang 21.0.0, standard configure flags `-g -O2`.
- Apple M5 Max, arm64, 18 logical CPUs, 128 GiB, macOS 27.2.1 (26B131). No CPU affinity or frequency pinning was applied.
- Start `2026-11-15T21:26:12.058953+00:00`, finish `2026-11-15T21:37:49.785805+00:00` (UTC; November 16 in Japan). Load averages at start [10.23, 10.99, 11.37], at finish [10.62, 10.07, 10.25]. OS indexing and editor activity remained; this was not a dedicated idle machine. No other build or test suite from this campaign ran during sampling.

## Method

The twelve existing `bench/*.sv` designs from the same release are unchanged. An original [fourstate_mix](../bench/fourstate_mix.sv) adds explicit X/Z stimuli missing from that set. Both tools use identical source, N and expectations.

1. Compile each Icarus design once with `iverilog -g2012` and time `vvp -n`. Compilation time is recorded separately. kirimasim runs source directly, so parsing and elaboration remain in its invocation time.
2. Warm up each tool once at n=1, then run n=1 and N five times each, serially. Tool order reverses by case/round and count order by round. Elapsed time uses a monotonic clock; each invocation has a 600-second limit.
3. Primary metric Δ is `median(T(N)) − median(T(1))`; the ratio is `Δkirimasim / ΔIcarus`. This is measured baseline subtraction, not proof of complete startup/front-end separation. Counts are not extrapolated. Full invocation medians are also reported below. These are descriptive statistics from five repetitions, without a confidence interval or claim of statistical significance.
4. Every full-count output must exactly match its unchanged expected line. All n=1 lines must agree across tools/rounds; the addition also has a standard-derived n=1 expectation. Nonzero exits, timeouts, mismatches, incomplete repetitions and non-positive differences receive no speed ratio. Source, driver, adapter and binary SHA-256 fingerprints must remain unchanged throughout.

## Results

| Benchmark | N | kirimasim Δ s | Icarus Δ s | KM/I ratio |
|---|---:|---:|---:|---:|
| `casez_struct` | 5,000,000 | 3.475524 | 3.111596 | 1.117 |
| `comb_chain` | 3,000,000 | 8.094163 | 7.876193 | 1.028 |
| `dyn_queue` | 4,000,000 | 3.218709 | 5.464449 | 0.589 |
| `fork_join` | 4,000,000 | 4.119411 | 4.119934 | 1.000 |
| `func_call` | 1,500,000 | 4.333494 | 7.292099 | 0.594 |
| `gate_udp` | 400,000 | 4.949989 | 2.703258 | 1.831 |
| `mem_rw` | 4,000,000 | 4.045235 | 2.842332 | 1.423 |
| `nba_burst` | 500,000 | 0.089609 | 0.089082 | 1.006 |
| `nba_shift` | 1,000,000 | 21.787320 | 18.457518 | 1.180 |
| `proc_wait` | 1,000,000 | 5.915084 | 5.021758 | 1.178 |
| `string_fmt` | 500,000 | 3.704463 | 7.125530 | 0.520 |
| `wide_arith` | 1,500,000 | 6.701178 | 2.020566 | 3.316 |
| `fourstate_mix` | 1,000,000 | 1.139078 | 1.273255 | 0.895 |

### Elapsed times and spread

All values are seconds. Full is the entire N-count invocation; n=1 is the baseline. MAD is the full-count median absolute deviation.

| Benchmark | Tool | Full median | n=1 median | Full min–max | Full MAD |
|---|---|---:|---:|---:|---:|
| `casez_struct` | kirimasim | 3.482588 | 0.007064 | 3.397827–3.499184 | 0.014591 |
| `casez_struct` | icarus | 3.117500 | 0.005904 | 3.024863–3.179745 | 0.062156 |
| `comb_chain` | kirimasim | 8.101501 | 0.007338 | 8.045990–8.277816 | 0.049022 |
| `comb_chain` | icarus | 7.881441 | 0.005247 | 7.772372–7.973193 | 0.049315 |
| `dyn_queue` | kirimasim | 3.226375 | 0.007666 | 3.168336–3.250636 | 0.024261 |
| `dyn_queue` | icarus | 5.470586 | 0.006137 | 5.416148–5.503133 | 0.032547 |
| `fork_join` | kirimasim | 4.126998 | 0.007588 | 4.122964–4.189692 | 0.001584 |
| `fork_join` | icarus | 4.125825 | 0.005891 | 4.114671–4.209971 | 0.011154 |
| `func_call` | kirimasim | 4.340832 | 0.007337 | 4.315741–4.377881 | 0.024242 |
| `func_call` | icarus | 7.298112 | 0.006013 | 7.225969–7.308245 | 0.010134 |
| `gate_udp` | kirimasim | 4.957692 | 0.007704 | 4.926173–5.045257 | 0.031519 |
| `gate_udp` | icarus | 2.709707 | 0.006449 | 2.650870–2.770765 | 0.008645 |
| `mem_rw` | kirimasim | 4.053659 | 0.008424 | 4.010041–4.086705 | 0.019087 |
| `mem_rw` | icarus | 2.848539 | 0.006207 | 2.821233–2.893246 | 0.021252 |
| `nba_burst` | kirimasim | 0.096886 | 0.007277 | 0.096129–0.097607 | 0.000358 |
| `nba_burst` | icarus | 0.094657 | 0.005575 | 0.093887–0.095956 | 0.000588 |
| `nba_shift` | kirimasim | 21.794651 | 0.007332 | 21.514410–21.997767 | 0.172663 |
| `nba_shift` | icarus | 18.463639 | 0.006121 | 18.329879–18.731632 | 0.133760 |
| `proc_wait` | kirimasim | 5.923610 | 0.008526 | 5.903763–5.962519 | 0.019847 |
| `proc_wait` | icarus | 5.028180 | 0.006422 | 5.013378–5.055429 | 0.014802 |
| `string_fmt` | kirimasim | 3.712126 | 0.007663 | 3.669652–3.767028 | 0.042474 |
| `string_fmt` | icarus | 7.131563 | 0.006034 | 7.094122–7.228829 | 0.033475 |
| `wide_arith` | kirimasim | 6.708965 | 0.007787 | 6.677806–6.720462 | 0.005353 |
| `wide_arith` | icarus | 2.026584 | 0.006018 | 2.021719–2.054379 | 0.003006 |
| `fourstate_mix` | kirimasim | 1.146992 | 0.007915 | 1.116061–1.150318 | 0.003116 |
| `fourstate_mix` | icarus | 1.279502 | 0.006246 | 1.275192–1.289583 | 0.004098 |

## Basis of the added benchmark

`fourstate_mix` combines 32-bit continuous bitwise logic, X/Z inputs, case equality and `$isunknown`, observing after #1 each iteration. Expectations follow IEEE 1800-2023 11.4.5, 11.4.8, 20.9 and 32-bit unsigned modular arithmetic. The original PDF's AND/XOR truth tables were visually checked.

The [Python reference](../bench/reference_fourstate_mix.py) runs no simulator. A separate AI verifier recalculated using a four-state bit-mask model and independent phase counts. The verifier had already read the reference file, so this is not reference-blind verification. It remains `spec_check: ai`. At one million iterations: `checksum=a0ea5e58 unknowns=250000 x_hits=250000 z_hits=500000`; at n=1: `checksum=00008abc unknowns=0 x_hits=0 z_hits=0`. Conformance requirements, denominators and coverage are unchanged.

## Reproduction and evidence

```sh
# Set BENCHMARK_ROOT to the pinned kirimasim v0.1.0 source worktree;
# set KIRIMASIM and IVERILOG to the freshly built executables.
# vvp must be installed beside iverilog.
python3 tools/benchmark_compare.py \
  --benchmark-root "$BENCHMARK_ROOT" \
  --kirimasim "$KIRIMASIM" --iverilog "$IVERILOG" \
  --kirimasim-commit cfa2ccd75989c1ebb9ed63303271183377364cf0 \
  --icarus-commit 1eba3690d8314d79927df8690a7d97642dd93ce0 \
  --extra-bench bench/fourstate_mix.sv --runs 5 --out "$RESULTS"
```

[All samples and execution checks](measurements/2026-11-16/mac-results.json) retain the 13 designs × 2 tools × (1 warmup + 5 n=1 + 5 N) invocations, expected lines, commands, separate Icarus compilation times, RSS, versions and source/binary hashes. See also [build and review provenance](measurements/2026-11-16/build-provenance.json). macOS RSS uses ru_maxrss, a different measure from WSL2 VmHWM.

## Linux / WSL2

WSL2 results were received on the private Git relay at `from-wsl/p1-speed-0.1.0-2026-11-16` (`f88c63e5`), with all thirteen designs, 286 invocations and input hashes checked. The [WSL2 detail](simulation-speed-wsl2-20261116.md) is retained as provisional evidence because external ctest/UVM activity overlapped. See the [cross-platform overview](simulation-speed-20261116.md).

[Profiling and optimization proposals](simulation-speed-analysis-20261116.md) investigate the slow workloads and record separate prototype experiments.
