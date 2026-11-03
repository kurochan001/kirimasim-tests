<a id="モデルに基づくランダムクロス比較"></a>

# Model-based random cross comparisons

[日本語](random-cross-verification.md)

Bounded random comparisons supplement Check's fixed cross regressions in Nightly.
The same stimulus drives a SystemVerilog design and a Python reference, comparing outputs uniquely determined by the standard.
Existing cases, oracles and finite-model denominators remain intact. Random samples and their successes do not increase
fixed-suite test counts, chapter-matrix pass counts or requirement coverage.

<a id="purpose-and-roles"></a>

## Purpose and roles

The goal is to search for counterexamples involving data-dependent bugs and feature interactions by varying
concrete input values, initial states and operation histories beyond the fixed representative cases.
With the same widths, signs and indexing forms, different values can expose overflow or extension errors;
different write orders can change later reads and observations of untouched bits.
Preserve failures as reproducible evidence and carry confirmed mechanisms into fixed regressions.

- **Fixed regressions and finite interaction models** repeatedly check selected factor combinations and mandatory boundaries.
  Do not replace them with a hope that random sampling will select those boundaries.
- **These random comparisons** explore additional values and sequences within supported profiles. Python generates randomness;
  simulators and references receive the same concrete stimuli. This does not test agreement between simulator random streams
  or the constraint solver behind `randomize()`.
- **Internal-model comparisons and libFuzzer in kirimasim** use the core repository's infrastructure for value semantics,
  scheduling, compilation and related mechanisms. Maintain them separately from this external comparison of SV inputs.
  See the [core validation policy](https://github.com/kurochan001/kirimasim/blob/main/docs/VALIDATION.md).

Passing samples do not prove correctness for all inputs/sequences, coverage of every factor combination or absence of undiscovered bugs.
Features outside the five supported profiles are not automatically explored.
Generation uses a distribution defined in code and a seed; automatic adaptation using coverage feedback is not implemented.
Some reference calculations share functions with fixed interaction tests, so repeated random comparisons alone cannot rule out oracle defects.
Combine standard review, hand-calculated boundaries and [reference/runner regressions](../tools/test_random_cross.py).

<a id="verification-process"></a>

## Verification process

1. **Choose legal conditions.** Allocate approximately equal case counts to supported profiles; the seed selects order and legal parameters.
   The [generator and reference module](../tools/random_cross_models.py) define scope and constraints.
2. **Materialize values and history.** For each arithmetic value, choose a boundary candidate with probability 1/4:
   zero, one, all-one bits, the MSB-only pattern or that pattern minus one. Otherwise draw a bit pattern of the selected width.
   Redraw a zero divisor as nonzero; choose array positions within the legal range for the selected slice width.
   Write sequences generate initial state, positions, data and operation order, also injecting X/Z.
   Writing A→reading→writing B→reading in one slice is distinct from reversing A and B.
3. **Create SV and expectations from identical stimuli.** Expose arithmetic results or whole-vector state after operations for comparison
   against standard-derived reference calculations. Check intermediate reads and untouched bits, not just a final value.
4. **Record execution conditions and compare.** Use kirimasim fetched/built immediately before execution and existing normalization/verdict logic.
   Optional comparators receive the same saved SV; compare each tool individually with its expectation.
   Simulator agreement or a majority vote alone is not a pass criterion.
5. **Save and replay.** Keep actual stimuli, SV, expectations, outputs, versions and fingerprints as well as the seed.
   Use [saved-stimulus replay](#immutable-replay) without redrawing. Unsupported, timed-out, unexecuted or stale evidence is not success.
6. **Carry failures into fixed regressions.** Distinguish specification, reference, runner and simulator problems;
   move confirmed mechanisms toward [fixed regression candidates](#failure-regression). Preserve original failure evidence after a successful retry.

Previously used widths or signedness remain eligible. [Duplicate admission](#exploration-admission) applies only to identical optional exploration jobs;
fixed regressions, formal Nightly and explicit replay execute again.

<a id="scope"></a>

<a id="対象と生成方法"></a>

## Scope and generation

Five profiles are currently supported. This does not generalize every finite model to arbitrary inputs.

- `expression_context` crosses widths, signedness, destination width and addition/subtraction/multiplication with arbitrary known input bits.
  It reuses the reference in `generators/interaction_expr.py`.
- `division_context` compares natural-width and destination-width quotient/remainder results using
  `generators/interaction_divide.py`, including signed division toward zero. Inputs are known and divisors are nonzero;
  zero division and X/Z inputs remain in fixed regressions.
- `packed_write_sequence` crosses ascending/descending packed declarations, `+:`/`-:` and bit/logic storage.
  Each case fixes its slice width, varying legal positions, data and read/write sequences.
  Whole-vector observations also check preservation of unselected bits and conversion of X/Z in two-state storage.

- `conditional_context` supplies arbitrary four-state branch values to `?:`, crossing signs, destination width (including ±1 bit) and bit/logic storage.
  Known conditions select one branch; X/Z conditions merge bits after context extension, including Z/Z becoming X.
  Truncation and bit-storage conversion happen afterwards. Original branch values and conditions are displayed.
  Branches have equal original widths; one-bit narrow destinations are excluded.
- `package_change_sequence` crosses width, bit/logic, qualified/wildcard/explicit imports, scalar/fixed-array storage,
  blocking/NBA, whole-word/low-bit event sensitivity and logical/case-equality wait conditions.
  It varies initial shared/neighbor/control values and write sequences, comparing two observers and an independent control.
  Observations include always_comb sensitivity through external function reads, notification counts/times/whole-word history,
  current wait predicates and retained wake history. It shares the [fixed cross's mechanism and standard basis](interaction-verification.en.md#package-change-observers)
  without being limited to its eight fixed operations.

Widths are 1/32/33/64/65/129, with the arithmetic models' legal one-bit operand/destination width differences.
Arithmetic mixes random values with zero, one and type boundaries; write, conditional and package profiles also generate X/Z.
Profiles receive approximately equal case counts; a seed chooses their order and legal parameters.
For packed_write_sequence, the first operation is a write, the second a read when present, and subsequent operations choose read/write.
Combinations can repeat. Random sampling is not a guarantee of pairwise or three-factor coverage.

The package profile initializes at time zero, arms observers at time one and first writes at time five. One producer updates every five ticks; the immediate destination and next-tick observer state are sampled separately. An initially zero target completes its wait at time one; later changes do not overwrite that first wake history. The sequence starts with a shared-target write, mixes shared/neighbor/control writes with approximately one-quarter repeated writes, and ends with a known-zero shared-target write to check progress. A one-operation case contains only that final write.

Out-of-range or variable observer indices, empty containers, races between independent writers, arbitrary concurrent scheduling, classes, constraint solving and `randomize()` itself are outside scope.
Random generation with multiple legal solutions needs a separate constraint-satisfaction check rather than exact output equality.

The 2026-11-03 addition expands the default allocation from three to five profiles. At 96 cases the ordered counts above are 20/19/19/19/19, reducing each original profile's samples from 32 while retaining the total case/vector budget and exploring more mechanisms. Default generation therefore produces different stimuli for the same seed.
To regenerate the old allocation, specify `--models expression_context division_context packed_write_sequence`.
Use `--replay` for saved stimuli rather than regenerating them. The manifest format and original profiles' materialized bytes remain compatible; existing source hashes and reference-drift reporting identify code changes.

```sh
# Explore only the two new profiles; fetch/build latest main immediately beforehand.
python3 tools/run_random_cross.py \
  --kirimasim /path/to/latest-build/kirimasim --commit VERIFIED_FULL_COMMIT \
  --seed 731 --models conditional_context package_change_sequence \
  --cases 96 --vectors 8 --jobs 4 --timeout 5 --time-budget 120 \
  --output my-results/new-profiles-731
```

<a id="limits-and-verdicts"></a>

<a id="件数制限と判定"></a>

## Limits and verdicts

Nightly defaults to 96 cases, 8 vectors/operations per case, 4 workers, 5 seconds per case and 120 seconds for comparison execution.
CLI caps are 256 cases, 32 vectors/operations, 8 workers, 30 seconds per case and 600 seconds overall.
Cases not started before the overall deadline become `not_run`; a running case that times out becomes `fail`.
Build time is outside that comparison budget; the complete additional Nightly step has a 15-minute limit.

- `pass`: zero exit, no error diagnostic, and normalized stdout equals the expectation.
- `fail`: output difference, nonzero exit, crash, error diagnostic, timeout or other execution failure.
- `known`: an Icarus/Verilator mismatch without a registered fixed-version oracle; never a pass.
- `unsupported`: kirimasim exits 2 with an unsupported diagnostic.
- `not_run`: the overall budget expires before starting the case.
- `stale`: SV, expectations, manifest, reference code or executable changes during execution.

The comparison CLI exits zero only if every case is a valid pass. Unsupported and unexecuted cases are never passes.
Zero exit from `--generate-only` means successful generation with zero execution passes.
Matching stdout with nonzero simulator exit still fails.

<a id="run-locally"></a>

<a id="最新ビルドで実行する"></a>

## Run a latest build locally

Fetch upstream main immediately before execution and build that commit. Use a dedicated clean simulator checkout to preserve
other work. From that checkout:

```sh
git fetch origin main
git switch --detach FETCH_HEAD
cmake --preset release
cmake --build --preset release
git rev-parse HEAD
build/release/src/driver/kirimasim --version
```

Pass the displayed full commit and its binary path from this repository:

```sh
python3 tools/run_random_cross.py \
  --kirimasim /path/to/kirimasim/build/release/src/driver/kirimasim \
  --commit VERIFIED_FULL_COMMIT --seed 731 \
  --cases 96 --vectors 8 --jobs 4 --timeout 5 --time-budget 120 \
  --output my-results/random-cross-731
```

`--commit` requires a 40-character commit matching the executable's version. This checks build identity, not upstream freshness;
the caller must fetch and build. Output directories must be new or empty so previous evidence is not overwritten.

<a id="replay"></a>

<a id="保存した刺激から再現する"></a>

## Replay saved stimuli

Output includes `manifest.json`, `run.json`, English/Japanese `report.md`/`report.ja.md`, `events.jsonl`, and SV, expectations,
stdout and stderr under `cases/`. The manifest records every actual input and operation, in addition to the seed.
The run records the suite commit and source-change flag, generator version, code hashes, simulator commit/version/binary hash,
input/expectation hashes, return codes and verdicts.

A seed alone may generate different stimuli after generator or environment changes; use the saved manifest for replay.
Again fetch/build immediately before execution and identify that simulator commit:

```sh
python3 tools/run_random_cross.py \
  --kirimasim /path/to/latest-build/kirimasim --commit VERIFIED_FULL_COMMIT \
  --replay my-results/random-cross-731/manifest.json \
  --case case_0007 --output my-results/random-cross-731-replay
```

Omit `--case` to rerun all saved cases. Replay rejects generation options such as seed, count or model selection.
It does not redraw stimuli. With the complete original artifact available, default to its SV and expectations and record differences from current reference materializations separately.
Explicitly select `--reference-policy current` to execute expectations from the current reference.
Manifest-only replay uses current materializations and cannot verify original SV/expectation bytes.
See [reference-change handling](#immutable-replay). Automatic counterexample minimization is not implemented.

Generation and inspection need no simulator:

```sh
python3 tools/run_random_cross.py --generate-only --seed 731 --cases 12 \
  --output my-results/random-cross-731-generated
```

<a id="ci"></a>

<a id="checkとnightlyの役割"></a>

## Check and Nightly responsibilities

[Check](../.github/workflows/check.yml) retains fixed regressions and consistency checks. New checks cover generation,
single-case replay from a saved manifest, byte-identical SV/expectations and tooling unit tests.
Check does not execute random cases on latest kirimasim.

The kirimasim job in [Nightly](../.github/workflows/nightly.yml) fetches/builds upstream main again after the fixed suite,
then immediately executes random comparisons. The seed is the GitHub run ID. A retry of the same run regenerates the same stimuli,
but a changed upstream revision means a new execution on that revision. Any non-pass fails the step;
the ordinary fixed-regression ratchet remains a separate check.

Replay data is saved in the dedicated `random-cross-kirimasim` artifact, and its English report enters Step Summary.
This artifact is outside the publisher's `results-*` selection and does not enter fixed history, charts or requirement coverage.
Local success or saved evidence is not a successful GitHub Nightly execution.

<a id="validation"></a>

<a id="導入時の検証"></a>

## Initial validation

See [qualification evidence](../coverage/interaction-qualification/random-cross.json) for actual revisions, counts, seeds,
fingerprints and fault detection. The [saved 96-case manifest](../coverage/interaction-qualification/random-cross-manifest.json)
can be supplied to `--replay`. These are not fixed-suite passes. Boundary witnesses and low-order coverage remain in fixed regressions.

<a id="five-profile-validation"></a>

### Five-profile extension and validation (2026-11-03)

The [new qualification record](../coverage/interaction-qualification/random-cross-five-profiles.json) and
[saved 96-case five-profile manifest](../coverage/interaction-qualification/random-cross-five-profiles-manifest.json) retain this extension's evidence.
Upstream main `d73d8922dfa2`, fetched, configured and built immediately before execution, passes 352 cases:
96 mixed cases at each of seeds 1/731/20261103 and 32 cases per new profile at the maximum 32 vectors/operations.
No core code changes are introduced. Explicitly selecting the original three profiles retains their previous manifest/SV/expectation hashes at three seeds.
Unit tests independently interpret 216 actual package programs using the [fixed cross's interpreter](../tools/qualify_pkgwatch.py),
in both forward and reverse observer-processing order. Conditional checks include all fixed-model boundary rows,
all single-bit input pairs and hand-calculated context-extension, Z/Z merge and bit-conversion examples.

Saved replay of one case from each new profile passes with identical original SV/expectation bytes and no reference drift.
Four separate saved controls all pass on kirimasim. Fixed Verilator 5.052 passes two known-input cases and excludes two requiring X/Z as unsupported;
fixed Icarus 13.0 passes one and retains three known differences: one conditional X/Z merge and two package compilation rejections.
Original outputs/diagnostics remain in local artifacts. These are not all-simulator successes or automatic fixed-oracle registrations.
Four actual SV faults also exit normally and differ from their original expectations: a wrong conditional branch,
function package binding, early wait and lost notification counts. Preserve original failures and expectations.
Local artifacts are under `my-results/random-profiles-20261103/`.

All 830 tool regressions, including 80 random-related checks, and 13 consistency checks pass. The Check generation/single-case-replay CLI and explicit new-profile selection also pass. All 115 language pairs and 53,273 local links are current. Random additions do not increase fixed-suite, chapter-matrix or requirement-coverage counts. Formal GitHub Check and Nightly have not run for these changes.

```sh
# Replay the published stimuli; fetch/build latest main immediately beforehand.
python3 tools/run_random_cross.py \
  --kirimasim /path/to/latest-build/kirimasim --commit VERIFIED_FULL_COMMIT \
  --replay coverage/interaction-qualification/random-cross-five-profiles-manifest.json \
  --output my-results/five-profiles-saved-replay
python3 -m unittest discover -s tools -p 'test_random_cross*.py'
```

<a id="exploration-admission"></a>

## Additional exploration admission

The policy is to repeat fixed regressions and formal Nightly, and prevent only
identical completed **additional exploration jobs** from being submitted again.
No parameter tuple, width, sign, input value or operation is permanently removed
from generation. Explicitly selecting the original three profiles in their original order preserves their random streams and distributions; overall limits are unchanged. Ordered operations, repeated writes and initial state are input;
equal parameter tuples do not imply equal verification.

```sh
python3 tools/run_random_cross.py \
  --kirimasim /path/to/latest-build/kirimasim --commit VERIFIED_FULL_COMMIT \
  --seed 731 --explore --history my-results/exploration.sqlite3 \
  --output my-results/exploration-731-first
# Repeat with a new output directory. Add --force to execute it anyway.
```

The standard-library SQLite database serializes admission of the entire job.
A live owner produces `in_flight`; a dead local owner is marked interrupted and
can be retried. PID start time guards against PID reuse. Use a local database;
an unknown remote owner is never automatically displaced. `--force` permits an
intentional concurrent retry without borrowing any result. Keep interrupted
artifacts; a new run always uses another directory. Fixed-suite runners do not
use this database. `--run-kind nightly` and explicit `--replay` bypass it even
when exploration options are supplied.

Only a valid, complete run with every required simulator/case at `pass` and exit
0 is eligible. Before omission, all saved evidence bytes are checked again.
The latest failed/interrupted/invalid attempt prevents fallback to an older
success. `fail`, `known`, `unsupported`, `not_run`, `stale`, launch failures and
partial comparisons are never reusable. A duplicate or in-flight submission
writes an `admission-only` run and English/Japanese reports, with zero current
passes and no execution results. CLI exit **3** means admission omission, **0**
means all required comparisons passed (or generation-only succeeded), **1**
means a comparison did not pass, and **2** means an invalid request/setup.
Do not treat exit 3 as a successful verification.

Input identity and execution identity are separate. Existing
`stimulus_sha256` still includes the case ID; additive `content_sha256` excludes
only that ID and retains all ordered stimulus. Exact job matching conservatively
also includes administrative IDs, generated SV/expectation bytes, artifact-local
`suite_results.input_digest`, existing `runner_digest`, generator/reference/
normalizer/adapter code hashes, every selected simulator, actual executable and
dependency hashes, version/commit, seed and initialization seed, limits/options,
selection, OS/Python and a hash of the entire inherited environment. Environment
values are not saved. Even irrelevant environment changes may cause a rerun.
Output directory, history database and force are admission controls, not input.

Native shared libraries are discovered with `otool`/`ldd`; macOS shared-cache
libraries use the exact OS build identity. Incomplete dependency evidence always
causes execution, never omission. Icarus compiler backends/configuration and
Verilator's C++ toolchain require a complete inventory: repeated `--dependency
FILE` arguments and `--dependencies-complete` explicitly attest that closure.
Do not attest completeness without identifying those resources. External comparison jobs always execute even with that inventory: their generated
simulation binaries are identified only after compilation, so they cannot establish
an exact prior execution identity at admission. The inventory still strengthens
provenance and stale checks. No external implementation source inspection is needed. Files, code, environment and
executables are checked again after execution; changes invalidate the result.

<a id="immutable-replay"></a>

## Preserve replay evidence and identify reference changes

Supply the **original artifact's** `manifest.json` to `--replay`, with its
`run.json` and `cases/` beside it. Original hashes are verified first. The new
artifact keeps copies under `origin/`, current materializations under
`current-reference/`, and structured differences in `run.json.replay`. Saved SV
and expected bytes are executed by default; changed current SV/expectations
make that observation `stale`, preserving its `observed_status`. Code-hash
changes are separately reported even when materialization is identical.

`--reference-policy current` explicitly tests the saved stimulus against the
current materialization and expectations, while retaining the original evidence
and differences. It does not repair or overwrite the original failure. A lone
manifest can still be replayed without redrawing, but its baseline is
`manifest_only`: it cannot establish what SV/expectation bytes an older run used.
Keep the complete artifact when investigating a failure.

<a id="saved-stimulus-comparison"></a>

## Check the same saved stimulus with public simulators

```sh
python3 tools/run_random_cross.py \
  --kirimasim /path/to/latest-build/kirimasim --commit VERIFIED_FULL_COMMIT \
  --replay my-results/random-cross-731/manifest.json --case case_0007 \
  --icarus /path/to/icarus/bin/iverilog --verilator /path/to/verilator \
  --simulator-seed 1 --timeout 30 --time-budget 120 \
  --output my-results/random-cross-731-public-check
```

The optional adapters invoke existing `run_icarus.run`/`run_verilator.run` in
isolated, time-bounded workers. The saved SV bytes go directly to each runner, including its original helper
paths. Existing expectation metadata keeps priority; only absent metadata uses
the saved sidecar expectation. Stimuli and expectations are not redrawn. Compiler/runtime commands,
stdout/stderr (including partial timeout logs), exit codes and executable hashes
are retained under `comparisons/SIMULATOR/CASE/`. `builds` and `comparisons`
identify each tool; `results`/`counts` remain the kirimasim view for compatibility.
Every required simulator must independently satisfy its expectation for CLI 0.
The shared simulator-specific expectation precedence and known-difference
classification remain intact. Matching tools or a majority vote prove nothing
without the standard-derived model. No fixed-version oracle is auto-registered.

Any saved packed stimulus containing X/Z, including conversion to `bit`, is
conservatively `unsupported` for Verilator. Its two-state output cannot prove
four-state behavior. The Verilator initialization seed is recorded separately;
it does not generate the SV stimuli. No assumption is made about equal tool
PRNG streams or equal constraint solutions. Future `randomize()` exploration
must check constraint satisfaction/state retention instead of solution equality.
Lyra/Ghost runners and external-simulator policy are unchanged; these adapters
do not handle Ghost or expose its private build/profile/diagnostics. Past tool
observations remain dated/versioned evidence, never a current kirimasim pass.

<a id="failure-regression"></a>

## Triage failures and prepare mechanism regressions

Retain the original failed artifact even when a later replay passes. First
separate specification interpretation, reference-model errors, runner errors
and simulator errors. For a reviewed language-level simulator defect:

```sh
python3 tools/promote_random_cross.py \
  --artifact my-results/FAILED_RUN --case case_0007 --simulator kirimasim \
  --classification simulator --confirmed --mechanism context_width \
  --chapter ch11 --lrm '1800-2023 11.8.2' \
  --explanation 'Describe the reviewed rule and observed violation' \
  --output my-results/context-width-draft
```

This verifies original inputs and creates `triage.json` and a fixed `tests/chNN`
draft, retaining the HDL body/expectation and provenance. It does not install the
draft, weaken expectations or register an oracle. Review the cited clauses and
mechanism before moving the draft into the existing chapter/generator, then
run metadata, generator and the relevant simulator checks. The draft reports
`lint_problems` (also on stdout); long literals remain unchanged so formatting
cannot silently remove the failure trigger. Resolve those issues under review
and reconfirm the defect before installing the candidate. Only a valid recorded
fail/known observation with unchanged current reference can become that draft;
pass/unsupported/not_run/stale are rejected. Other classifications create triage
only. Reference/runner defects need tests in their owning Python components;
internal value/scheduler/libFuzzer findings belong to kirimasim's unit/mechanism
matrices, not an unrelated language test. No newly confirmed simulator defect
is implied by the tooling's synthetic failure fixtures.

Formal Check still executes pinned Icarus 13.0 / Verilator 5.052; Nightly uses
development builds. Build caches/ccache save compilation, not execution.
Nightly records workflow run ID/attempt separately from the fresh random build
commit. The preceding fixed suite can use an earlier kirimasim revision in the
same workflow; inspect its own result version, not the later random build.
`results_ratchet.py` still gates only pass→fail; pass→unsupported and other
transitions are not silently added to that gate. Fixed boundary witnesses,
fingerprint-qualified interaction snapshots and fixed history remain separate.
