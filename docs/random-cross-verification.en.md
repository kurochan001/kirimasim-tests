<a id="モデルに基づくランダムクロス比較"></a>

# Model-based random cross comparisons

[日本語](random-cross-verification.md)

Bounded random comparisons supplement Check's fixed cross regressions in Nightly.
The same stimulus drives a SystemVerilog design and a Python reference, comparing outputs uniquely determined by the standard.
Existing cases, oracles and finite-model denominators remain intact. Random samples and their successes do not increase
fixed-suite test counts, chapter-matrix pass counts or requirement coverage.

<a id="scope"></a>

<a id="対象と生成方法"></a>

## Scope and generation

The initial implementation has three profiles. It does not generalize all current 65 models to arbitrary inputs.

- `expression_context` crosses widths, signedness, destination width and addition/subtraction/multiplication with arbitrary known input bits.
  It reuses the reference in `generators/interaction_expr.py`.
- `division_context` compares natural-width and destination-width quotient/remainder results using
  `generators/interaction_divide.py`, including signed division toward zero. Inputs are known and divisors are nonzero;
  zero division and X/Z inputs remain in fixed regressions.
- `packed_write_sequence` crosses ascending/descending packed declarations, `+:`/`-:` and bit/logic storage.
  Each case fixes its slice width, varying legal positions, data and read/write sequences.
  Whole-vector observations also check preservation of unselected bits and conversion of X/Z in two-state storage.

Widths are 1/32/33/64/65/129, with the arithmetic models' legal one-bit operand/destination width differences.
Arithmetic mixes random values with zero, one and type boundaries; write sequences also generate X/Z.
Profiles receive approximately equal case counts; a seed chooses their order and legal parameters.
The first operation is a write, the second a read when present, and subsequent operations choose read/write.
Combinations can repeat. Random sampling is not a guarantee of pairwise or three-factor coverage.

Out-of-range indices, empty containers, concurrent scheduling, classes, constraint solving and `randomize()` itself are outside scope.
Random generation with multiple legal solutions needs a separate constraint-satisfaction check rather than exact output equality.

<a id="limits-and-verdicts"></a>

<a id="件数制限と判定"></a>

## Limits and verdicts

Nightly defaults to 96 cases, 8 vectors/operations per case, 4 workers, 5 seconds per case and 120 seconds for comparison execution.
CLI caps are 256 cases, 32 vectors/operations, 8 workers, 30 seconds per case and 600 seconds overall.
Cases not started before the overall deadline become `not_run`; a running case that times out becomes `fail`.
Build time is outside that comparison budget; the complete additional Nightly step has a 15-minute limit.

- `pass`: zero exit, no error diagnostic, and normalized stdout equals the expectation.
- `fail`: output difference, nonzero exit, crash, error diagnostic, timeout or other execution failure.
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
It does not redraw stimuli. Changed reference code may produce changed expectations; compare code hashes and expectations
with the original artifact. Automatic counterexample minimization is not implemented.

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
