# Daily simulation-speed benchmarks

[English](daily-benchmark.md) / [日本語](daily-benchmark.ja.md)

The independent [Daily benchmark workflow](../.github/workflows/benchmark.yml) measures elapsed time. Functional Nightly checks language results; a faster incorrect result cannot pass this benchmark's output checks. Functional `nightly.yml`, its judgments, the `results` branch, and the dated speed records are unchanged.

[Latest attempt and trends](https://github.com/kurochan001/kirimasim-tests/tree/benchmark-results#readme) · [Actions and logs](https://github.com/kurochan001/kirimasim-tests/actions/workflows/benchmark.yml). The results branch is created by the first published formal attempt. A failed attempt remains visible and is never labeled a completed campaign.

## Comparisons and fixed definitions

[bench/daily.json](../bench/daily.json) is the reviewed definition. Initially it selects four common cases from kirimasim v0.1.0: `comb_chain` (3,000,000 steps), `mem_rw` (4,000,000 clocks), `nba_shift` (1,000,000 clocks), and `wide_arith` (1,500,000 iterations). Their source files stay in the kirimasim repository, pinned at `cfa2ccd75989c1ebb9ed63303271183377364cf0`; they are not copied or selected from the daily latest checkout.

The additional `bench/fourstate_mix.sv` stays here at its recorded content hash, with 1,000,000 iterations. It observes X/Z, case equality and unknown detection. Verilator is explicitly excluded from this case before compilation; a two-state approximation is not compared as if it did equivalent work. The common cases observe deterministic values meaningful to every selected simulator. This selection is not a score for all SystemVerilog workloads.

Four tool identities are separate:

- **latest**: kirimasim `main`, resolved once by `benchmark_setup.py resolve` before any builds. All later steps use that exact SHA.
- **baseline**: kirimasim v0.1.0, peeled commit `cfa2ccd75989c1ebb9ed63303271183377364cf0`.
- **icarus**: Icarus Verilog v13_0 / 13.0, commit `30a7d1a11b7586aa0fc868e509f04f514effc0ad`.
- **verilator**: Verilator v5.054, peeled commit `bbb60a403932a9f695cb6ff001ceb73de6ad9234`.

The tags and full commits were resolved from the upstream Git repositories. The setup builds pinned sources as black boxes, without inspecting GPL implementation code. Baseline, Icarus and Verilator pins never automatically follow their main branches. Version strings, binary/companion hashes and build receipts are recorded independently of benchmark/driver hashes.

Lyra is initially omitted: there is no local Lyra executable or dedicated runner, and its additional backend toolchain/build is not needed to complete the four-tool daily comparison. The existing pinned `tools/bench.py` adapter already supports `lyra` / `lyra_llvm`. To add it, first verify a fixed commit and a reproducible build, add a prepared tool and its version checks, then explicitly register supported cases and fixed comparison groups. A missing executable must not become a zero-second sample.

## What the clock measures

Every formal campaign uses one machine, serial commands, one n=1 warmup per tool/case, and five runs each at n=1 and the original full N. Tool order reverses by case/round; count order reverses each round. Each design compilation finishes before its executable is measured. All simulator installations finish before the campaign. No workload reduction or expectation-skipping `bench.py --n` mode is used.

The main metric is **incremental elapsed time**: `median(T(N)) - median(T(1))`, the extra wall-clock time associated with increased work. It is not a measurement of isolated simulation CPU time and does not prove complete removal of startup, parsing or elaboration.

- The result keeps every warmup/small/large invocation, elapsed seconds, exit code, timeout, checked result line and RSS, plus median/minimum/maximum/MAD. MAD is the median absolute distance from the median, a description of dispersion rather than a confidence interval.
- Icarus and Verilator design compilation is timed separately. kirimasim interprets the source in each invocation, so parsing/elaboration is included in T(1) and T(N); its separate design-build field is absent. Simulator installation/build time is recorded in provenance, not added to design-build time.
- kirimasim uses the release preset (`-O3 -DNDEBUG`, checked `-ffp-contract=off`, no fast-math). Icarus uses `-g2012` then `vvp -n`. Verilator uses the existing adapter's `--binary --timing` and default generated C++ optimization, explicitly `--threads 1 --build-jobs 1`. Tracing and requested assertions are off. No case benchmarks waveform or log I/O.
- Linux RSS reuses the adapter's 10 ms VmHWM observer; a very short process can have no sample, and the observed maximum is not a guaranteed peak. macOS uses wait4 ru_maxrss. RSS is not substituted with zero when unavailable.
- An incremental time below 0.05 seconds, or near the observed dispersion, carries a noise caution. The program does not increase N automatically. A zero/negative/non-finite difference produces no ratio.

The full-N expected lines are the existing unchanged benchmark headers. Fixed n=1 expectations are independently calculated: `nba_shift` samples the reset cycle (zero sum); `mem_rw` uses the old rdata=0 and raddr=5 with one LFSR update; `wide_arith` performs one modular 256/128-bit update; `comb_chain` sums the initial chain result and its first xorshift-driven result. `reference_fourstate_mix.py` supplies the scalar standard-derived reference for the X/Z case. Expectations are not learned from a faster simulator.

## Reading results and trends

For every pair the ratio is **latest kirimasim incremental elapsed / comparison tool incremental elapsed**. Below 1 favors latest, above 1 favors the comparison tool. Latest-versus-baseline is performance evolution; latest-versus-Icarus/Verilator is OSS comparison. Running the baseline in the same campaign helps interpret runner variation but does not remove all environmental noise.

Five geometric means have fixed member sets:

- regression-common: latest/baseline on all four common cases;
- regression-fourstate: latest/baseline on `fourstate_mix`;
- icarus-common: latest/Icarus on all four common cases;
- icarus-fourstate: latest/Icarus on `fourstate_mix`;
- verilator-common: latest/Verilator on all four common cases.

Every listed member is required. Missing, failed or non-positive measurements make that group's mean missing. The report shows the member list and available/required count; it never silently averages only successful cases. SVG lines break at missing points. Individual case measurements and failure reasons remain available in raw JSON even when the aggregate is missing.

A latest/baseline group ratio above 1.15 is a descriptive caution only. It does not fail functional tests or assert statistical significance. `measured`, `unsupported`, `output_mismatch`, `build_failed`, `run_failed`, `timeout`, and `incomparable` are distinct states. Unsupported is a declared feature exclusion, not a heuristic for a compiler crash. Any bad warmup or measured repetition invalidates the tool/case; no failed repetition is discarded to manufacture a median.

A series fingerprint includes the definition/configuration, driver, aggregation code and pinned adapter hashes; CPU model, cores, memory, OS, architecture, compiler, runner image, repetition count and settings. Different definitions/environments are not joined. Latest commits intentionally vary within a series. GitHub-hosted machines are ephemeral, even when these non-identifying descriptors match: the values remain **shared-runner reference measurements**, and small daily movements are not established performance changes.

## Run manually or locally

In Actions select **Daily benchmark → Run workflow → formal**. It runs automatically at **20:17 UTC / 05:17 JST the next day**, after functional Nightly's 19:23 UTC / 04:23 JST. GitHub may delay scheduled starts. Actual start/end times are retained. `smoke` checks `wide_arith` and `fourstate_mix` at unchanged full N with one repetition; all output/count/exit checks remain enabled, but smoke data never enters performance history.

The same CLI works on macOS and Linux. Git, Python 3.10+, a C++23 compiler supported by kirimasim, CMake 3.28+, Ninja, compression headers, and the OSS tools' build prerequisites are required. Ubuntu prerequisites are listed in the workflow; Homebrew builds need sufficiently recent bison/flex on PATH. Choose a quiet machine and new output directory:

```sh
WORK=/path/to/private/benchmark-work
mkdir -p "$WORK"
python3 tools/benchmark_setup.py resolve --out "$WORK/plan.json"
python3 tools/benchmark_setup.py prepare --plan "$WORK/plan.json" \
  --root "$WORK/build" --install "$WORK/install" --out "$WORK/inventory.json" --jobs 2
python3 tools/daily_benchmark.py --inventory "$WORK/inventory.json" \
  --environment fixed-local-profile --out "$WORK/run-001"
python3 tools/benchmark_history.py append --directory "$WORK/report" "$WORK/run-001/results.json"
```

For a validated smoke add `--smoke --only wide_arith fourstate_mix` to the measurement command, with another output directory. `benchmark_history.py append` deliberately rejects smoke data. Existing executables can be supplied instead of inventory using `--benchmark-root` at the frozen commit, `--latest-commit` as a full resolved SHA, and four `--tool latest=... --tool baseline=... --tool icarus=... --tool verilator=...` options. kirimasim SHA/version and OSS release strings are checked. Externally supplied OSS builds have no source-build attestation; the result marks this provenance limitation. Use setup receipts for formal reproducible installations.

A nonblocking shared lock excludes concurrent setup/measurement commands on one local host. Use the same `--lock` path across users/containers sharing a fixed measurement machine. Other programs do not honor this lock: the operator must also keep unrelated builds/benchmarks off that machine. The workflow concurrency group serializes its complete build/measurement/publication lifecycle. Hosted jobs run on an isolated VM; shifting the schedule alone is not the exclusion mechanism.

## History, failure and permissions

Only the publish job has `contents: write`. It runs only for formal attempts on main, appends to **benchmark-results**, and uses a normal push. The branch is created without copying main. `runs/actions-RUN_ID-ATTEMPT.json` is immutable; same-day manual executions and reruns have separate IDs. Exact repeated ingestion is idempotent; reuse of an ID with changed data is rejected. Nothing changes functional results history or commits daily samples to main. A retry of only the publish job reuses the originating measurement artifact and run identity; rerun the measurement job or all jobs to collect new samples.

The branch holds small per-run JSON samples, an index, the latest attempt, bilingual README reports and SVG charts. Full sanitized command/build logs are Actions artifacts (14 days), linked through the attempt's run URL. No inventory containing executable paths, source trees or build directories is uploaded. An interrupted campaign or setup failure is recorded as infrastructure failure, with missing group values; partially obtained samples are kept. If upload/publication itself fails, inspect that job and its artifacts; no successful publication is claimed.

No new secret or registered private runner is required. Repository Actions must permit the existing pinned actions and allow the publish job's contents permission; branch rules must allow its normal append to benchmark-results. The setup cache key includes OS/architecture, runner image/compiler, fixed configuration/setup hashes and latest commit. Each restored receipt verifies commit, compiler/options and installed-file hashes. Simulator builds and cache transfers finish before timing begins.

For a fixed self-hosted machine, first register it and record a stable non-identifying profile, then change only the measurement job's `runs-on` to its actual registered labels and the CLI environment label. Keep the shared workflow/host locks, exclusive machine use and single serial job; do not add PR triggers or grant the measurement job write credentials. Run new reference campaigns in a new series; never pool their times with hosted Ubuntu or another Mac/Linux machine.

## Updating and validating the benchmark

Changing pins, cases, N, expected lines, settings or driver logic requires an explicit definition review. Verify tags resolve to real full commits and builds run; update source/adapter hashes and standard-derived expectations with reasons. Bump the definition label. The fingerprint separates changed conditions automatically, but the label helps readers. Never rewrite old run files, old speed records, functional expectations, or simulator behavior to make timing succeed.

```sh
python3 -m unittest discover -s tools -p 'test_daily_benchmark.py'
python3 -m unittest discover -s tools -p 'test_benchmark_compare.py'
actionlint .github/workflows/benchmark.yml
```

Tests cover all-repetition admission, fixed aggregates, declared exclusions, timeouts, non-positive deltas, rerun-safe append, separated series, report/SVG generation and gaps. Full suite checks additionally exercise the unchanged functional infrastructure. Real smoke output checks and the first Actions publication should be reported separately from these automated checks; the presence of a workflow file alone does not establish daily operation.
