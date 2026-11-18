# Daily and weekly simulation-speed benchmarks

[English](daily-benchmark.md) / [日本語](daily-benchmark.ja.md)

The independent [Daily and weekly benchmarks workflow](../.github/workflows/benchmark.yml) measures elapsed time. Functional Nightly checks language results; a faster incorrect result cannot pass this benchmark's output checks. Functional `nightly.yml`, its judgments, the `results` branch, and the dated speed records are unchanged.

[Latest attempt and trends](https://github.com/kurochan001/kirimasim-tests/tree/benchmark-results#readme) · [Actions and logs](https://github.com/kurochan001/kirimasim-tests/actions/workflows/benchmark.yml). The results branch is created by the first published formal attempt. A failed attempt remains visible and is never labeled a completed campaign.

## Overall graph in the README

The README shows one daily elapsed-time ratio with **latest Icarus Verilog 14.0 devel = 1**. For each of the fixed 25 daily designs (22 common + 3 four-state), calculate `kirimasim incremental elapsed / Icarus 14 devel incremental elapsed`, then take the **equal-weight geometric mean** of those 25 ratios. 0.97 means 3% less elapsed time across this set; 1.10 means 10% more. Lower is faster; this is the inverse of a speed multiplier. Average all 25 directly, rather than giving the 22-case and 3-case subgroup means equal weights. This describes the selected designs, not every SystemVerilog workload.

Resolve latest kirimasim and Icarus `master` once each before preparation; freeze both full SHAs for the entire campaign. Check the Icarus executable identifies as 14.0 devel. If upstream moves to 15, review the tracked version rather than silently labeling it 14. Both projects change, so a relative movement cannot be attributed solely to kirimasim. Fixed baseline kirimasim, Icarus 13 and Verilator comparisons remain in the details.

Use the last-started formal attempt per JST date, retaining every raw attempt. A later failed attempt does not fall back to an earlier success. Any mismatch, failure, timeout, non-positive difference or incomplete member makes the 25-case mean missing. No-attempt days also break the curve. Different environment/definition series are never joined. The gray 1 is a mathematical reference, not an imputed measurement. A legend's last valid value need not describe the latest attempt.

The [graph](https://raw.githubusercontent.com/kurochan001/kirimasim-tests/benchmark-results/charts/daily-icarus14.svg) and [daily selections / summary JSON](https://github.com/kurochan001/kirimasim-tests/blob/benchmark-results/headline.json) update on the results branch. The new curve starts with actual Icarus 14 formal data; historical Icarus 13 measurements are not relabeled.

## Comparisons and fixed definitions

[bench/daily.json](../bench/daily.json) selects **25 daily designs and 3 larger weekly designs** from one shared manifest. The daily set retains **all thirteen original designs**: the twelve standalone designs from kirimasim v0.1.0 plus this repository's four-state case. The common twelve are `casez_struct`, `comb_chain`, `dyn_queue`, `fork_join`, `func_call`, `gate_udp`, `mem_rw`, `nba_burst`, `nba_shift`, `proc_wait`, `string_fmt`, `wide_arith`. Each retains its original N and full expected output. Their source files stay in the kirimasim repository, pinned at `cfa2ccd75989c1ebb9ed63303271183377364cf0`; they are not copied or selected from the daily latest checkout.

Definition `daily-v4-icarus14` has 22 common and 3 four-state cases; `weekly-v2-icarus14` has 3 common cases. The old `daily-v1` (5) and `daily-v2-thirteen` (13) runs remain immutable in their own series. Their means are not expanded-suite results. Reports label each series with its definition and case count. Daily and weekly selections have separate fingerprints, latest-result files, tables and charts; a weekly publication cannot replace the latest daily result.

The additional `bench/fourstate_mix.sv` stays here at its recorded content hash, with 1,000,000 iterations. It observes X/Z, case equality and unknown detection. Verilator is explicitly excluded from all three four-state cases before compilation; a two-state approximation is not compared as if it did equivalent work. The common cases observe deterministic values meaningful to every selected simulator. This selection is not a score for all SystemVerilog workloads.

## Added workloads and independent expectations

The twelve daily additions are original designs in this repository:

- `fifo_stream`: a 64-word synchronous FIFO, simultaneous transfers, full/empty backpressure, ordered data checks, accepted-read and pending-word counts.
- `uart_loopback`: separate transmitter and receiver modules; start bit, eight data bits and stop bit. One simulation clock per serial bit, with payload order, frame count and framing errors checked; it is not an oversampling/noise test.
- `bus_fabric`: four address-decoded register banks with 32 words each, clocked writes and reads from different addresses. It is a small original register bus, not a claimed implementation of a named bus standard.
- `hierarchy_fanout`: input changes propagated through 128 combinational leaf modules, with every output folded into a checksum.
- `event_fanout`: 256 clock-sensitive workers with sparse updates; the final count of every worker is observed.
- `clock_domains`: three independent clocks with periods 4/6/10 and independently predictable edge counts. It does not test clock-domain crossing correctness.
- `word_boundary`: changing 64/65-bit operands, rotation, shifts across the word boundary and variable bit selection.
- `wide_divide`: 257-bit unsigned division and remainder by changing nonzero divisors (1–65,521, stored in a 33-bit operand).
- `packed_slice`: changing 511-bit state and 32-bit indexed reads/writes across storage-word boundaries.
- `memory_scatter`: 32,768 32-bit words (128 KiB logical data), deterministic irregular reads/writes, including aliases.
- `fourstate_arith`: 65-bit known/X/Z arithmetic, arithmetic right shift, fully unknown-result counts and known-result checksums.
- `resolved_bus`: four drivers on an 8-bit tri-state bus, floating, agreeing and conflicting drivers; known-bit checksums and observed X/Z bit counts.

The three weekly scale designs are:

- `large_hierarchy`: a five-level four-way module tree, 1,024 clocked leaves and 341 internal nodes; independently gated leaf updates and a reduced root result.
- `large_memory`: 262,144 32-bit words (1 MiB logical data) with 64-word strided bursts per iteration and one simulation-time unit between bursts. The zero-time safety guard remains enabled. Logical data size is not simulator RSS.
- `stream_pipeline`: eight registered stages, 32 parallel 32-bit lanes, valid propagation, global clock-enable stalls and final drain. Payload checksum and accepted frame count are checked independently of pipeline timing.

These supplement focused kernels with original small RTL systems and larger structures; they do not claim to represent every application or a complete processor workload. Class-based verification, assertions/coverage overhead and waveform I/O are not benchmarked by this definition.

[`bench/reference_expanded.py`](../bench/reference_expanded.py) calculates expectations without reading simulator output: a transaction FIFO, transmitted bytes, a flat memory model, modular integers, closed-form clock/event counts, a flat leaf-state model, per-token pipeline transforms and scalar four-state net resolution. Both full-N and n=1 expectations are frozen in the manifest and source headers. N means FIFO cycles, bus write/read pairs (two clock cycles per pair), offered pipeline cycles (followed by eight drain cycles), UART frames, and 30-time-unit clock blocks (observed at time 30N+1). Other designs use the described iterations. N=1 initialization/elaboration may itself be substantial for large designs. All reference source hashes are recorded and protected throughout measurement. `spec_check: ai` identifies AI checking, not human review.

New workload counts were chosen before formal measurement using correctness preflights to reduce obviously short executions, then frozen; the original thirteen counts and expectations were not changed. A preflight is not formal speed evidence. Counts are never adjusted automatically per simulator or day; short/noisy or non-positive differences still carry the usual caution/missing status.

Five tool identities are separate:

- **latest**: kirimasim `main`, resolved once by `benchmark_setup.py resolve` before any builds. All later steps use that exact SHA.
- **baseline**: kirimasim v0.1.0, peeled commit `cfa2ccd75989c1ebb9ed63303271183377364cf0`.
- **icarus**: Icarus Verilog v13_0 / 13.0, commit `dfeee909ed9f20b4870dd93423156c0170c0e1ff`.
- **icarus_devel**: Icarus Verilog 14.0 devel, `refs/heads/master` resolved once at campaign start. Initial black-box build verified commit `0b15315c14177986b98fcad2940c0c3f98fdc8f9`. Its installation and records are separate from fixed Icarus 13.
- **verilator**: Verilator v5.054, peeled commit `bbb60a403932a9f695cb6ff001ceb73de6ad9234`.

The tags and full commits were resolved from the upstream Git repositories. The setup builds pinned sources as black boxes, without inspecting GPL implementation code. Baseline, Icarus and Verilator pins never automatically follow their main branches. Version strings, binary/companion hashes and build receipts are recorded independently of benchmark/driver hashes.

Lyra is initially omitted: there is no local Lyra executable or dedicated runner, and its additional backend toolchain/build is not needed to complete the daily comparison. The existing pinned `tools/bench.py` adapter already supports `lyra` / `lyra_llvm`. To add it, first verify a fixed commit and a reproducible build, add a prepared tool and its version checks, then explicitly register supported cases and fixed comparison groups. A missing executable must not become a zero-second sample.

## What the clock measures

Every formal campaign uses one machine, serial commands, one n=1 warmup per tool/case, and five runs each at n=1 and the original full N. Tool order reverses by case/round; count order reverses each round. Each design compilation finishes before its executable is measured. All simulator installations finish before the campaign. No workload reduction or expectation-skipping `bench.py --n` mode is used.

The main metric is **incremental elapsed time**: `median(T(N)) - median(T(1))`, the extra wall-clock time associated with increased work. It is not a measurement of isolated simulation CPU time and does not prove complete removal of startup, parsing or elaboration.

- The result keeps every warmup/small/large invocation, elapsed seconds, exit code, timeout, checked result line and RSS, plus median/minimum/maximum/MAD. MAD is the median absolute distance from the median, a description of dispersion rather than a confidence interval.
- Icarus and Verilator design compilation is timed separately. kirimasim interprets the source in each invocation, so parsing/elaboration is included in T(1) and T(N); its separate design-build field is absent. Simulator installation/build time is recorded in provenance, not added to design-build time.
- kirimasim uses the release preset (`-O3 -DNDEBUG`, checked `-ffp-contract=off`, no fast-math). Icarus uses `-g2012` then `vvp -n`. Verilator uses the existing adapter's `--binary --timing` and default generated C++ optimization, explicitly `--threads 1 --build-jobs 1`. Tracing and requested assertions are off. No case benchmarks waveform or log I/O.
- Linux RSS reuses the adapter's 10 ms VmHWM observer; a very short process can have no sample, and the observed maximum is not a guaranteed peak. macOS uses wait4 ru_maxrss. RSS is not substituted with zero when unavailable.
- An incremental time below 0.05 seconds, or near the observed dispersion, carries a noise caution. The program does not increase N automatically. A zero/negative/non-finite difference produces no ratio.

The full-N expected lines are the existing unchanged benchmark headers. Fixed n=1 expectations are independently calculated: `nba_shift` samples the reset cycle (zero sum); `mem_rw` uses the old rdata=0 and raddr=5 with one LFSR update; `wide_arith` performs one modular 256/128-bit update; `comb_chain` sums the initial chain result and its first xorshift-driven result. `reference_fourstate_mix.py` supplies the scalar standard-derived reference for the X/Z case. Expectations are not learned from a faster simulator. The eight added n=1 references follow the original source rules: the first decoder word changes register 13, leaving the three printed registers at their initial values; one queue push/drain sums to 1; the first fork/join round gives a=1, b=1, c=1, d=0; four recursive mixes give s=2 and sum=1683697; the first LCG/majority update gives 610673f5; one NBA leaves value 0; at time 3 only the delay-2 processes have woken, summing to 15255; and the first formatted string's FNV-1a hash is dcc025c8. The fixed Verilator 5.054 adapter also passed an original active-region versus post-delay NBA probe, so `nba_burst` is included with `--timing` rather than assuming older INITIALDLY behavior.

## Reading results and trends

For every pair the ratio is **latest kirimasim incremental elapsed / comparison tool incremental elapsed**. Below 1 favors latest, above 1 favors the comparison tool. Latest-versus-baseline is performance evolution; latest-versus-Icarus/Verilator is OSS comparison. Running the baseline in the same campaign helps interpret runner variation but does not remove all environmental noise.

The original five geometric means keep their exact member sets:

- regression-common: latest/baseline on all twelve common cases;
- regression-fourstate: latest/baseline on `fourstate_mix`;
- icarus-common: latest/Icarus on all twelve common cases;
- icarus-fourstate: latest/Icarus on `fourstate_mix`;
- verilator-common: latest/Verilator on all twelve common cases.

Five additional `expanded-*` groups cover all 22 daily common cases or all 3 daily four-state cases with the same peers. Three original `weekly-*` groups cover exactly the three weekly cases against baseline, Icarus 13 and Verilator. `daily-overall-icarus14` adds the fixed 25-case headline; `weekly-icarus14-common` compares all three weekly cases with Icarus 14 devel. These are separately reported fixed sets; weekly results never join daily means.

Every listed member is required. Missing, failed or non-positive measurements make that group's mean missing. The report shows the member list and available/required count; it never silently averages only successful cases. SVG lines break at missing points. Individual case measurements and failure reasons remain available in raw JSON even when the aggregate is missing.

A latest/baseline group ratio above 1.15 is a descriptive caution only. It does not fail functional tests or assert statistical significance. `measured`, `unsupported`, `output_mismatch`, `build_failed`, `run_failed`, `timeout`, and `incomparable` are distinct states. Unsupported is a declared feature exclusion, not a heuristic for a compiler crash. Any bad warmup or measured repetition invalidates the tool/case; no failed repetition is discarded to manufacture a median.

A series fingerprint includes the definition/configuration, driver, aggregation code and pinned adapter hashes; CPU model, cores, memory, OS, architecture, compiler, runner image, repetition count and settings. Different definitions/environments are not joined. Both development commits intentionally vary within a series. GitHub-hosted machines are ephemeral, even when these non-identifying descriptors match: the values remain **shared-runner reference measurements**, and small daily movements are not established performance changes.

## Run manually or locally

In Actions select **Daily and weekly benchmarks → Run workflow**, choose `profile=daily` or `weekly`, and `mode=formal`. Daily starts at **20:17 UTC / 05:17 JST the next day**. Weekly starts on **Sunday 23:47 UTC / Monday 08:47 JST**. Functional Nightly remains 19:23 UTC / 04:23 JST. Both speed profiles share the same concurrency group and local lock; schedules alone do not prevent overlap. GitHub may delay starts; actual start/end times are retained. The measurement job has a 180-minute limit including preparation. `mode=smoke` runs one validated full-N repetition on daily `wide_arith`, `fourstate_mix`, `fifo_stream`, `resolved_bus`, or weekly `large_memory`; smoke data never enters performance history.

The same CLI works on macOS and Linux. Git, Python 3.10+, a C++23 compiler supported by kirimasim, CMake 3.28+, Ninja, compression headers, and the OSS tools' build prerequisites are required. Ubuntu prerequisites are listed in the workflow; Homebrew builds need sufficiently recent bison/flex on PATH. Choose a quiet machine and new output directory:

```sh
WORK=/path/to/private/benchmark-work
mkdir -p "$WORK"
python3 tools/benchmark_setup.py resolve --out "$WORK/plan.json"
python3 tools/benchmark_setup.py prepare --plan "$WORK/plan.json" \
  --root "$WORK/build" --install "$WORK/install" --out "$WORK/inventory.json" --jobs 2
python3 tools/daily_benchmark.py --profile daily --inventory "$WORK/inventory.json" \
  --environment fixed-local-profile --out "$WORK/run-001"
python3 tools/benchmark_history.py append --directory "$WORK/report" "$WORK/run-001/results.json"
```

For weekly use `--profile weekly` with another output directory and the same prepared inventory. Both profiles resolve both development heads once per campaign; if running both from one prepared inventory, they intentionally use that same SHA. To track a newer latest, resolve and prepare again.

For a validated daily smoke add `--smoke --only wide_arith fourstate_mix` to the measurement command, with another output directory; a weekly smoke can use `--profile weekly --smoke --only large_memory`. `benchmark_history.py append` deliberately rejects smoke data. Existing executables can be supplied instead of inventory using `--benchmark-root` at the frozen commit, `--latest-commit` as a full resolved SHA, and five `--tool latest=... --tool baseline=... --tool icarus=... --tool verilator=... --tool icarus_devel=...` plus `--tool-commit icarus_devel=FULL_SHA` options. kirimasim SHA/version and OSS release strings are checked. Externally supplied OSS builds have no source-build attestation; the result marks this provenance limitation. Use setup receipts for formal reproducible installations.

A nonblocking shared lock excludes concurrent setup/measurement commands on one local host. Use the same `--lock` path across users/containers sharing a fixed measurement machine. Other programs do not honor this lock: the operator must also keep unrelated builds/benchmarks off that machine. The workflow concurrency group serializes its complete build/measurement/publication lifecycle. Hosted jobs run on an isolated VM; shifting the schedule alone is not the exclusion mechanism.

## History, failure and permissions

Only the publish job has `contents: write`. It runs only for formal attempts on main, appends to **benchmark-results**, and uses a normal push. The branch is created without copying main. `runs/actions-RUN_ID-ATTEMPT.json` is immutable; same-day manual executions and reruns have separate IDs. Exact repeated ingestion is idempotent; reuse of an ID with changed data is rejected. Nothing changes functional results history or commits daily samples to main. A retry of only the publish job reuses the originating measurement artifact and run identity; rerun the measurement job or all jobs to collect new samples.

The branch holds small per-run JSON samples, an index, `latest.json` (latest of either profile), `latest-daily.json`, `latest-weekly.json`, bilingual README reports, SVG charts and daily overall `headline.json`. Full sanitized command/build logs are Actions artifacts (14 days), linked through the attempt's run URL. No inventory containing executable paths, source trees or build directories is uploaded. An interrupted campaign or setup failure is recorded as infrastructure failure, with missing group values; partially obtained samples are kept. If upload/publication itself fails, inspect that job and its artifacts; no successful publication is claimed.

No new secret or registered private runner is required. Repository Actions must permit the existing pinned actions and allow the publish job's contents permission; branch rules must allow its normal append to benchmark-results. The setup cache key includes OS/architecture, runner image/compiler, fixed configuration/setup hashes and both resolved development commits. A case-only definition change may restore a previous installation cache for the same platform/compiler image. Each restored receipt still verifies commit, compiler/options, installation prefix, recipe and installed-file hashes; an incompatible receipt rebuilds its tool. Simulator builds and cache transfers finish before timing begins.

The workflow prerequisite-install step targets Ubuntu; use an Ubuntu fixed runner, or adapt that step and compiler/PATH settings for another OS (the measurement CLI itself supports macOS and Linux). For a fixed self-hosted machine, first register it and record a stable non-identifying profile, then change only the measurement job's `runs-on` to its actual registered labels and the CLI environment label. Keep the shared workflow/host locks, exclusive machine use and single serial job; do not add PR triggers or grant the measurement job write credentials. Run new reference campaigns in a new series; never pool their times with hosted Ubuntu or another Mac/Linux machine.

## Updating and validating the benchmark

Changing pins, cases, N, expected lines, settings or driver logic requires an explicit definition review. Verify tags resolve to real full commits and builds run; update source/adapter hashes and standard-derived expectations with reasons. Bump the definition label. The fingerprint separates changed conditions automatically, but the label helps readers. Never rewrite old run files, old speed records, functional expectations, or simulator behavior to make timing succeed.

```sh
python3 -m unittest discover -s tools -p 'test_daily_benchmark.py'
python3 -m unittest discover -s tools -p 'test_benchmark*.py'
python3 bench/reference_expanded.py --check
actionlint .github/workflows/benchmark.yml
```

Tests cover all-repetition admission, fixed aggregates, declared exclusions, timeouts, non-positive deltas, rerun-safe append, separated series, report/SVG generation and gaps. Full suite checks additionally exercise the unchanged functional infrastructure. Real smoke output checks and the first Actions publication should be reported separately from these automated checks; the presence of a workflow file alone does not establish daily operation.
