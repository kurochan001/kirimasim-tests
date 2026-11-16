# Slow-workload causes and optimization prototypes: Mac, 2026-11-16

[English](simulation-speed-analysis-20261116.md) / [日本語](simulation-speed-analysis-20261116.ja.md)

The large wide-arithmetic gap is primarily caused by bit-at-a-time shifts, selections and concatenation writes. Gates/UDP, memory, NBA and waiting processes also pay repeated operand-type lookup and generic VM instruction costs. Prototypes using word operations and precomputed immutable type information reduced measured time by about 74% for wide arithmetic, 19% for gates/UDP and 15% for memory.

These are experimental proposals in a separate worktree, not changes to the simulator main branch. The original [0.1.0 comparison](simulation-speed-20261116.md) and its thirteen-design measurements are preserved.

## Scope and method

The baseline is kirimasim 0.1.0 `cfa2ccd75989c1ebb9ed63303271183377364cf0`, Icarus 14.0 devel `1eba3690d8314d79927df8690a7d97642dd93ce0`, Apple M5 Max / macOS 27.2.1. Prototypes use the same release flags (`-O3 -DNDEBUG -ffp-contract=off`). The Mac-local simulator main `c152d237` has no `src/vm` / `src/kernel` difference from that baseline. No Icarus implementation source was inspected.

Six release designs and three prototype designs were observed with macOS `sample` at 1 ms intervals. Percentages are collapsed leaf stack observations divided by the computing worker thread samples. The parent thread waiting for the worker to finish is excluded. Inlining and sampling error prevent treating these as exact CPU-time attribution. Profiled elapsed times are excluded from speed comparisons.

Unprofiled timings were collected from 2026-11-15T22:15:19.418529+00:00 to 2026-11-15T22:24:24.534737+00:00 UTC. Each tool has one n=1 warmup, then five repetitions each of n=1 and N, serially alternating tool/count order. Δ is `median(T(N))−median(T(1))`, without extrapolation or a claim of complete startup/front-end separation. Start load [10.73, 12.02, 11.73], finish load [7.9, 10.05, 10.83]. No other campaign builds or tests ran during sampling.

## Wide arithmetic

In [kernel/wide.cpp](https://github.com/kurochan001/kirimasim/blob/cfa2ccd75989c1ebb9ed63303271183377364cf0/src/kernel/wide.cpp#L396), `shl`, `ashr`, `bits` and `put` extract and write individual bits in both A/B planes. Of 4,285 worker observations, they account for 16.4%, 17.2%, 14.0% and 15.6%, respectively: 63.2% combined. `operator new` and `mi_free` together account for about 5.8%, supporting removal of bit-at-a-time work first.

The prototype moves both four-state planes in 64-bit words. Shifts support arbitrary width, sign extension, X/Z and excessive amounts. Selection and put use a word path only at aligned 64-bit boundaries, retaining the old path otherwise. `wide_arith` Δ changes from 6.598356 s in release to 1.828983 s with word operations alone, and 1.724225 s with type caching too. Four-state semantics and temporary allocation are retained.

## Gates, memory and NBA

[VM execute](https://github.com/kurochan001/kirimasim/blob/cfa2ccd75989c1ebb9ed63303271183377364cf0/src/vm/vm.cpp#L6374) selects class/string/real paths on each instruction, and [`typeOf`](https://github.com/kurochan001/kirimasim/blob/cfa2ccd75989c1ebb9ed63303271183377364cf0/src/vm/vm.cpp#L1955) follows operand kinds into type tables. Types are immutable during execution, yet repeated checks look them up again. `typeOf` leaf observations account for 10.2% in gates/UDP, 9.9% in memory and 14.4% in NBA. Caching the first operand type in `InstrInfo` after all temporary types are known reduces those observations to 1.0% for gates/UDP and 1.1% for memory.

The truth-table function `udpOutput` itself accounts for about 3.3% in the gate design. There are 227,200,844 VM instructions, 26,000,096 process wakeups and 38,400,158 wait subscriptions. Optimizing only the truth-table function is unlikely to close the large gap; instruction predecoding and repeated static trigger construction in `waitTriggers` are further candidates.

Memory executes 192,014,364 VM instructions, 8,000,000 time advances and 24,000,000 NBA updates. There is no evidence that copying the whole large array dominates: scalar loads/stores, indices, instruction dispatch and scheduler work accumulate. The NBA design executes 1,313,999,693 VM instructions.

## Prototype timings

| Design | Release Δ s | Prototype Δ s | Icarus Δ s | Time reduction from release | Prototype/Icarus |
|---|---:|---:|---:|---:|---:|
| `wide_arith` | 6.598356 | 1.724225 | 2.011740 | 73.87% | 0.857 |
| `gate_udp` | 4.986564 | 4.042842 | 2.672747 | 18.93% | 1.513 |
| `mem_rw` | 4.017768 | 3.428447 | 2.844983 | 14.67% | 1.205 |
| `nba_shift` | 21.479964 | 17.809353 | 18.533768 | 17.09% | 0.961 |
| `proc_wait` | 5.896676 | 5.439492 | 5.084767 | 7.75% | 1.070 |

An additional three-round type-cache-only control gives combined/type-only Δ ratios of 1.001 for gates and 1.018 for memory. These designs use 32-bit paths, so the small word-change contribution supports attributing the main improvement to type caching. This is descriptive three-round evidence, not a statistical equivalence test.

## Verified scope and remaining checks

- Seven existing wide/valsem tests pass, plus 122,184 additional comparisons covering boundaries, signedness, X/Z, outside selections and in-place operations. No expected value was changed.
- All 176 invocations in the five-case comparison exit successfully. All five full-count repetitions match the expected line and n=1 outputs agree across tools. The additional type-only control also matches.
- The prototype matches all twelve existing designs plus the X/Z addition. All counters also match on the six designs with baseline profile records. The gains do not come from changed outputs or fewer logical events.
- Full simulator `local_ci.py`, sanitizer configurations, production-scale startup/RSS remain unverified. Full VM regressions, including real/class behavior, are required before adoption. No thirteen-design prototype speed score is claimed.

## Countermeasure priority

1. **Word operations for wide values:** the first adoption candidate directly addresses the large gap without changing the public API. Add formal regression matrices for unaligned boundaries, aliases and X/Z before adoption.
2. **Precompute immutable type information:** the first-operand cache is a small VM change with measured benefit. Keeping a type per instruction also requires assessing startup and memory on large SIR designs.
3. **Predecode typed instructions and operand locations**, and reuse constructed static trigger information, to address the remaining gate/UDP overhead. Benefits are not measured yet. Preserve NBA ordering, delta cycles, iff, VPI/force, references and frame lifetimes; do not simply skip events.
4. Reassess **temporary-buffer allocation and copying** after word optimization. Allocation/free has a larger share in the prototype wide profile. Scratch storage needs explicit treatment of reentrancy, GC roots and tempStack reallocation.

## Evidence and reproduction

Build the baseline in release mode, then apply the [word-operation patch](measurements/2026-11-16/word-ops.patch) and [type-cache patch](measurements/2026-11-16/type-cache.patch) in a separate worktree. Both also pass `git apply --check` against the current Mac-local main. The patches are concrete proposals for review.

Retained evidence: [all timings](measurements/2026-11-16/prototype-results.json), [type-only control](measurements/2026-11-16/type-only-control.json), [profile summary](measurements/2026-11-16/profile-summary.json), [thirteen output/counter checks](measurements/2026-11-16/prototype-validation.json), and [build/review provenance](measurements/2026-11-16/prototype-provenance.json). Build the [additional reference checker](measurements/2026-11-16/boundary_reference.cpp) with wide.cpp, valsem/value.cpp and valsem/logic.cpp from the same baseline. Raw sample logs retain machine identifiers and are kept private; the public summary contains functions and worker observations.

## WSL2 confirmation

The [rerun and prototype results](simulation-speed-wsl2-followup-20261116.md) arrived at `ee544e7f`. CPU attribution is from Mac, while the same patches now have measured Linux gains too. All thirteen outputs and complete counter sets match release and the Mac prototype.

| Design | Mac time reduction | WSL2 time reduction | WSL2 prototype/Icarus |
|---|---:|---:|---:|
| `wide_arith` | 73.87% | 51.36% | 1.223 |
| `gate_udp` | 18.93% | 15.72% | 1.478 |
| `mem_rw` | 14.67% | 14.16% | 1.487 |
| `nba_shift` | 17.09% | 18.57% | 1.102 |
| `proc_wait` | 7.75% | 14.01% | 1.270 |

Linux wide gains are smaller than Mac, and this five-case prototype still takes longer than Icarus. The results support optimizing kernel work and common VM costs, without establishing causes of between-environment differences.
