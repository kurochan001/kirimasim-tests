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
Features outside the eleven supported profiles are not automatically explored.
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

Eleven profiles are currently supported. This does not generalize every finite model to arbitrary inputs.

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

- `shift_context` applies `<<`/`>>`/`<<<`/`>>>` to arbitrary four-state source bits, crossing source signedness,
  destination width (±1 bit), bit/logic and 8/32/65-bit signed/unsigned counts.
  Counts mix 0/1, boundaries around original/evaluation widths, all ones, arbitrary bits and partially unknown values.
  Context extension precedes shifting; arithmetic right shifts replicate the sign bit, including X/Z.
  Counts are self-determined: a signed all-ones count is still a huge nonnegative amount and does not propagate its sign/width to the expression.
  Unknown counts produce all X before truncation and bit conversion. Grounds are IEEE 1800-2023 11.4.10, 11.6.1, 11.8.1/2 and 6.11.2.
- `cast_pipeline` exposes intermediate size, signed/unsigned and typed bit/logic casts, crossing source sign, cast width (±1 bit),
  a destination two bits wider than the original, an optional operation and bit/logic storage.
  Signing casts retain width; typed cast types are unsigned; one-bit narrow casts are excluded.
  The optional operation adds signed two-bit positive one, checking conversion into typed bit before subsequent arithmetic.
  Input, cast value and final result are displayed separately. Grounds are IEEE 1800-2023 6.24.1, 6.11.2, 11.6.1 and 11.8.1/2.

- `streaming_context` crosses left/right streaming, pack/unpack, positive slice size, optional three-bit tags and bit/logic storage.
  Inputs and tags are arbitrary; slice sizes include 1/2/3/4/7/8/16/17/32/33 and boundaries around the source width.
  Partial edge blocks are not padded; unpack applies the inverse pack permutation. Total input/output widths match.
  Grounds are IEEE 1800-2023 11.4.14.1/2/3 and 6.11.2. Dynamic arrays, with clauses and unequal-size padding/truncation are excluded.
- `concat_assignment_sequence` crosses total widths 2/32/33/64/65/129 and arbitrary positive two-way partitions,
  RHS width (±1 bit) and sign, each item's bit/logic state, member signedness and blocking/NBA updates.
  Initial values, input words, RHS changes immediately after scheduling, order and repeated writes are saved.
  The model resizes the RHS to the whole concatenation before partitioning and per-item conversion, comparing immediate/next-tick values,
  sign-extended item reads and unsigned concatenation reads. Grounds are IEEE 1800-2023 11.4.12, 10.7, 10.4.1/2, 6.11.2 and 11.8.1/2.
  Targets are distinct static whole variables; overlapping targets, slices and multiple-writer races are excluded.

- `comparison_context` covers ten operators: four relational, logical equality/inequality, case equality/inequality and wildcard equality/inequality.
  It crosses both operand signs, RHS width (±1 bit) and 1/7/33/65/130-bit destinations.
  Inputs are arbitrary four-state words; approximately one-quarter of RHS words are resized copies of the LHS.
  Operands determine the common comparison width/sign; the unsigned one-bit result is separately extended into logic and bit destinations.
  Checks include known mismatches resolving logical equality and RHS-only X/Z wildcards. Grounds are IEEE 1800-2023 11.4.4/5/6, 11.6.1, 11.8.2 and 6.11.2.
- `packed_logic_context` observes all six unary reductions and logical negation for each input.
  It crosses source bit/logic and sign, direct/arbitrary contiguous slice/known zero-or-one prefix, and destination state/width.
  Source bit conversion precedes expression formation; known zero controls AND, known one controls OR, and XOR propagates unknowns.
  Unsigned one-bit results are extended before destination bit conversion. Grounds are IEEE 1800-2023 11.4.9, 11.4.7, 11.6.1, 11.8.1 and 6.11.2.
  Binary logical operators, short-circuit side effects and out-of-range slices are excluded.

Most widths are 1/32/33/64/65/129; concatenated assignments start at total width 2. This includes the arithmetic models' legal one-bit operand/destination width differences.
Arithmetic mixes random values with zero, one and type boundaries; write, conditional, package, shift, cast, streaming, concatenation, comparison and reduction profiles also generate X/Z.
Profiles receive approximately equal case counts; a seed chooses their order and legal parameters.
For packed_write_sequence, the first operation is a write, the second a read when present, and subsequent operations choose read/write.
Combinations can repeat. Random sampling is not a guarantee of pairwise or three-factor coverage.

The package profile initializes at time zero, arms observers at time one and first writes at time five. One producer updates every five ticks; the immediate destination and next-tick observer state are sampled separately. An initially zero target completes its wait at time one; later changes do not overwrite that first wake history. The sequence starts with a shared-target write, mixes shared/neighbor/control writes with approximately one-quarter repeated writes, and ends with a known-zero shared-target write to check progress. A one-operation case contains only that final write.

Out-of-range or variable observer indices, empty containers, races between independent writers, arbitrary concurrent scheduling, classes, constraint solving and `randomize()` itself are outside scope.
Random generation with multiple legal solutions needs a separate constraint-satisfaction check rather than exact output equality.

The first 2026-11-03 addition expanded the default allocation from three to five profiles. That checkpoint allocated 96 cases as 20/19/19/19/19 to the first five profiles listed above, down from 32 each with three profiles. It retained the total case/vector budget while exploring more mechanisms and changed the default stimulus stream for the same seed.
The subsequent shift/cast checkpoint had seven profiles: 96 cases allocated 14 to each earlier profile and 13 to each new one. At that checkpoint each earlier profile received fewer samples and the default corpus changed from five profiles, while total case/vector, worker and timeout limits were retained.
The streaming/concatenation checkpoint had nine profiles: 96 cases allocated 11 to each of the first six and 10 to each remaining profile. It retained total case/vector, worker and timeout limits while extending scope and changing the default stimulus stream.
The comparison/reduction addition brings the current total to eleven profiles. The default 96 cases allocate nine to each of the first eight profiles above and eight to each remaining profile. Each earlier profile receives fewer samples; total case/vector, worker and timeout limits remain unchanged. Default generation changes its stimulus stream for the same seed.
To regenerate the previous nine-profile corpus, specify `--models expression_context division_context packed_write_sequence conditional_context package_change_sequence shift_context cast_pipeline streaming_context concat_assignment_sequence`. This explicit selection retains its previous streams, distribution and generated bytes.
To regenerate the previous seven-profile corpus, specify `--models expression_context division_context packed_write_sequence conditional_context package_change_sequence shift_context cast_pipeline`. This explicit selection retains its previous streams, distribution and generated bytes.
To regenerate the previous five-profile corpus, specify `--models expression_context division_context packed_write_sequence conditional_context package_change_sequence`. This explicit selection, like the original three-profile selection, preserves its previous streams, distribution and generated bytes.
To regenerate the old allocation, specify `--models expression_context division_context packed_write_sequence`.
Use `--replay` for saved stimuli rather than regenerating them. The manifest format and original profiles' materialized bytes remain compatible; existing source hashes and reference-drift reporting identify code changes.

```sh
# Explore only comparisons and reductions; fetch/build latest main immediately beforehand.
python3 tools/run_random_cross.py \
  --kirimasim /path/to/latest-build/kirimasim --commit VERIFIED_FULL_COMMIT \
  --seed 731 --models comparison_context packed_logic_context \
  --cases 96 --vectors 8 --jobs 4 --timeout 5 --time-budget 120 \
  --output my-results/predicate-profiles-731
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

<a id="eleven-profile-validation"></a>

### Comparison/reduction extension and validation (2026-11-03)

The [eleven-profile qualification record](../coverage/interaction-qualification/random-cross-eleven-profiles.json) and
[saved 96-case manifest](../coverage/interaction-qualification/random-cross-eleven-profiles-manifest.json) preserve this addition.
kirimasim `d73d8922dfa2`, fetched, configured and built from upstream main immediately before execution, passes 352 cases:
96 mixed cases at each of seeds 1/731/20261103 and 32 cases per new profile at the maximum 32 vectors.
No core code changes are introduced. Explicit selection of the previous three, five, seven or nine profiles retains previous
manifest/SV/expectation hashes at three seeds each. One saved replay per new profile passes with identical original bytes and no reference drift.

Reference checks cover every legal fixed comparison row with four inputs and every fixed logical-reduction row with known baselines.
Separate checks use integer comparisons on arbitrary known values, single-bit equality truth tables and independent reduction folds over
all four-state sequences of lengths 1–4. Hand-calculated cases cover RHS-only wildcards, known mismatches and unknowns,
AND/OR controlling values, slice/input-conversion order and unsigned one-bit results widened to 130 bits from signed inputs.
Each reduction vector observes seven operations; these are not counted as separate fixed tests.

Four saved controls all pass on kirimasim and fixed Icarus 13.0. Fixed Verilator 5.052 passes two known-input cases and excludes two X/Z cases as unsupported.
These are not all-simulator successes or automatic fixed-oracle registrations.
Four actual SV mutations all exit normally and differ from original expectations: wrong operand signedness, swapped wildcard operands,
early source bit conversion and incorrect sign extension of a one-bit result.
The qualification embeds the actual control manifest; full local artifacts are under `my-results/random-predicate-20261103/`.
Original inputs, expectations and failure outputs remain intact, outside fixed-suite, chapter-matrix and requirement-coverage counts.

All 878 tool regressions, including 128 random-related tests, and 13 consistency checks pass. The Check generation/single-case-replay CLI, explicit new-profile selection, 115 language pairs and 53,289 local links were checked. Formal GitHub Check and Nightly have not run for these changes.

```sh
# Fetch/build latest main immediately beforehand; replay saved stimuli.
python3 tools/run_random_cross.py \
  --kirimasim /path/to/latest-build/kirimasim --commit VERIFIED_FULL_COMMIT \
  --replay coverage/interaction-qualification/random-cross-eleven-profiles-manifest.json \
  --output my-results/eleven-profiles-saved-replay
python3 -m unittest discover -s tools -p 'test_random_cross*.py'
```

<a id="nine-profile-validation"></a>

### Streaming/concatenation extension and validation (2026-11-03)

The [nine-profile qualification record](../coverage/interaction-qualification/random-cross-nine-profiles.json) and
[saved 96-case manifest](../coverage/interaction-qualification/random-cross-nine-profiles-manifest.json) preserve this addition.
kirimasim `d73d8922dfa2`, fetched, configured and built from upstream main immediately before execution, passes 352 cases:
96 mixed cases at each of seeds 1/731/20261103 and 32 cases per new profile at the maximum 32 vectors/operations.
No core code changes are introduced. Explicit selection of the previous three, five or seven profiles retains their
previous manifest/SV/expectation hashes at three seeds each. One saved replay per new profile passes with identical original bytes and no reference drift.

Reference checks cover every legal fixed streaming row, both input phases of every legal fixed concatenation row,
and separate integer calculations across arbitrary concatenation partitions and known values.
A separate block decoder checks streams of lengths 1–132; correctness is not based only on round trips.
Hand-calculated observations distinguish partial-block pack/unpack, old pre-NBA state, captured values after RHS changes,
mixed bit/logic conversion and member sign extension.
Four actual SV mutations all exit normally and differ from original expectations: wrong stream direction,
missing inverse permutation, early concatenation updates and missing per-item bit conversion.

Five saved public-tool controls all pass on kirimasim. Fixed Icarus 13.0 records one pass and four known:
three streaming compilation rejections and one concatenation retaining Z in a bit item.
Fixed Verilator 5.052 records two pass, one known partial-block unpack using the pack permutation,
and two unsupported X/Z cases. None is converted to success or automatically registered as a fixed oracle;
inputs and expectations are not weakened to match differences.
The qualification includes the actual control manifest; full local artifacts are under `my-results/random-struct-20261103/`.
These samples do not enter fixed-suite, chapter-matrix or requirement-coverage counts and are distinct from formal Check/Nightly runs.

All 862 tool regressions, including 112 random-related tests, and 13 consistency checks pass. The Check generation/single-case-replay CLI, explicit new-profile selection, 115 language pairs and 53,285 local links were checked. Formal GitHub Check and Nightly have not run for these changes.

```sh
# Fetch/build latest main immediately beforehand; replay saved stimuli.
python3 tools/run_random_cross.py \
  --kirimasim /path/to/latest-build/kirimasim --commit VERIFIED_FULL_COMMIT \
  --replay coverage/interaction-qualification/random-cross-nine-profiles-manifest.json \
  --output my-results/nine-profiles-saved-replay
python3 -m unittest discover -s tools -p 'test_random_cross*.py'
```

<a id="seven-profile-validation"></a>

### Shift/cast extension and validation (2026-11-03)

The [seven-profile qualification record](../coverage/interaction-qualification/random-cross-seven-profiles.json) and
[saved 96-case manifest](../coverage/interaction-qualification/random-cross-seven-profiles-manifest.json) preserve this addition.
kirimasim `d73d8922dfa2`, fetched, configured and built from upstream main immediately before execution, passes 352 cases:
96 mixed cases at each of seeds 1/731/20261103 and 32 cases per new profile at the maximum 32 vectors.
No core code changes are introduced. Explicit selection of the previous five profiles, as well as the original three,
retains previous manifest/SV/expectation hashes at three seeds.
One saved replay per new profile passes with identical original bytes and no reference drift.

Reference checks cover every legal fixed shift/cast row and separate integer calculations on arbitrary known values.
Hand-calculated boundaries cover left shifts after evaluation-width extension, 65-bit all-ones counts,
arithmetic replication of X/Z, unknown counts, cast signedness and typed-bit conversion before addition.
Four actual SV mutations all exit normally and differ from original expectations: arithmetic-to-logical right shift,
ignored count, changed cast signedness and delayed bit conversion. Original inputs, expectations and failure outputs remain intact.

For four public-tool comparisons using the same saved stimuli, kirimasim and fixed Icarus 13.0 each pass all four;
fixed Verilator 5.052 passes two known-input cases and excludes two requiring X/Z as unsupported.
These are not all-simulator successes or automatic fixed-oracle registrations.
Local artifacts are under `my-results/random-bits-20261103/`, outside fixed-suite, chapter-matrix and requirement-coverage counts.

All 846 tool regressions, including 96 random-related tests, and 13 consistency checks pass. The Check generation/single-case-replay CLI, explicit new-profile selection, 115 language pairs and 53,277 local links were checked. Formal GitHub Check and Nightly have not run for these changes.

```sh
# Fetch/build latest main immediately beforehand; rerun saved stimuli.
python3 tools/run_random_cross.py \
  --kirimasim /path/to/latest-build/kirimasim --commit VERIFIED_FULL_COMMIT \
  --replay coverage/interaction-qualification/random-cross-seven-profiles-manifest.json \
  --output my-results/seven-profiles-saved-replay
python3 -m unittest discover -s tools -p 'test_random_cross*.py'
```

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
from generation. Explicitly selecting the original three, five, seven or nine profiles in their original order preserves their random streams and distributions; overall limits are unchanged. Ordered operations, repeated writes and initial state are input;
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
