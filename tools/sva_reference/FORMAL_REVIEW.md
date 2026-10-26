# Symbolic formal checks (2026-10-26)

For an introduction and operating guide in Japanese, see
[`SVA参照評価器とフォーマル検証`](../../docs/sva-reference-formal-verification.md).

The extended formal suite has 40 independent semantic-model comparisons.
All 40 bounded checks passed. The 22 sequence models also passed unbounded
PDR equivalence proofs. Four reachability checks passed, and five deliberately
incorrect references each failed with a counterexample. That is 71 tool jobs:
66 expected PASS results and five expected FAIL results; no UNKNOWN, TIMEOUT
or ERROR result was accepted.

An additional ABC PDR backend negative control also returned FAIL with a VCD
for the tied-first-match mistake. It is recorded separately in
[`fixtures/formal_pdr_negative.json`](fixtures/formal_pdr_negative.json);
its model hash equals the corresponding BMC mutant's hash. The main 71-job
report and this one extra backend check are kept distinct.

The source-bound result is
[`fixtures/formal_symbolic_results.json`](fixtures/formal_symbolic_results.json).
It records case expressions, clauses, models/configuration hashes, input
domains, depths, modes, tool versions and statuses. Full regenerated RTL,
SBY configurations, solver logs and traces are written to the chosen run
directory. The negative-control VCDs are also retained in
[`fixtures/formal_counterexamples/`](fixtures/formal_counterexamples/).

## What is checked

The old ten formal-pilot models used fixed stimulus. These checks leave input
letters/words unconstrained; there are no assume statements restricting them
to suite stimulus or expected outputs.

- **22 sequences:** the actual Python weighted-derivative implementation is
  exported as a complete finite-state machine, with its match multiplicities.
  Separately written RTL monitors compute interval endpoint matches from
  sampled history, or use counters/flags for the five unbounded patterns.
  Both sides start one attempt at the first sample, including an initial empty
  match where applicable. Equality is asserted at every prefix, not just the
  eventual Boolean truth. BMC covers 8 steps for finite patterns and 16 for
  the five unbounded patterns. `prove` with ABC PDR additionally established
  equality at all prefix lengths for these 22 specific expressions.
- **16 finite-word properties:** actual `Engine.property` results are exported
  as exhaustive lookup tables and compared with independent RTL formulas.
  Checks include implication/followed-by, empty alignment, the four until
  forms, and strong/weak nexttime/always/eventually at the finite boundary.
  Both the result status (including vacuity/holds/pending) and its deciding
  tick are checked. Horizons are one, two or three samples; the expressions
  and exact bounds are recorded per case.
- **Six four-state sampled functions:** two-bit vectors are encoded with two
  binary bits per four-state bit (0, 1, x, z). All 256 previous/current vector
  pairs check `$sampled`, `$past`, `$rose`, `$fell`, `$stable` and `$changed`
  against independent bit-encoding comparisons from 16.9.3/F.3.4.4.
- **Gated `$past`:** all 4,096 four-sample words of a two-bit binary value and
  a one-bit gate check ordinary/gated history at depths one and two, at every
  sample. Declaration defaults are fixed to two-bit 1. An independent RTL
  history queue emits its old state before consuming the current gate/value.

The 18 finite-word/table models cover 6,692 input words in total. Those models
are combinational circuits representing the entire recorded sample word;
their SBY depth of 2 is solver steps, not a claim to use only two samples.
Sequence models instead consume one input letter per solver step. The
sequence export contains 108 residual states across its 22 machines.

`formal_cases.py` is the separately authored specification; it imports neither
the SVA parser nor the evaluator. The references paraphrase clauses 16.9,
16.12 and Annex F. The actual side comes from `automata.py`, `engine.py` and
`sampled.py`. No suite `.expected` or simulator assertion result is used to
construct either side. No original SVA test is parsed by Yosys/slang; Yosys
only consumes the exported synthesizable verification circuit.

## Reachability and deliberate mistakes

The four cover jobs reach a tied `first_match`, multiple containment matches,
the second goto occurrence followed by its consequent, and an x-to-1 sampled
rise. This complements the unconstrained-input assertions with concrete
witnesses of interesting behavior.

Each negative control changes only its independent reference, leaving the
actual evaluator export unchanged:

- Collapsing tied `first_match` results from two to one fails. A witness has
  no earlier `b`, then both `b` and `c` true at the earliest ending tick.
- Excluding the inner `within` match that ends at the outer right endpoint
  fails. The witness has an inner match only at that endpoint.
- Moving `empty ##1 b` one tick late fails as soon as `b` is true at the
  current tick.
- Treating followed-by without an antecedent match as vacuous success fails.
  The witness starts with the antecedent's first operand false: the actual
  result is failure at tick 0. This is the rule behind the M3 correction.
- Letting gated `$past` consume the current gated sample before returning its
  answer fails. With gate values 0,0,0,1 and values all zero, the last gated
  history lookup must still return the declaration default 1.

These are expected failures that validate the checking pipeline; they are not
newly discovered errors in the current evaluator or suite expectations. The
counterexamples were inspected and are bound to their model and VCD hashes.

## Reproduce and inspect

```sh
# Run BMC, streaming PDR proofs, selected covers and negative controls.
# FORMAL_RUN_DIR must be new or empty; previous runs are never overwritten.
python3 tools/sva_reference/formal.py --sby "$SBY_BIN" \
  --output-dir "$FORMAL_RUN_DIR"

# Limit the workload, retaining the relevant proof/cover/negative control.
python3 tools/sva_reference/formal.py --sby "$SBY_BIN" \
  --case first_match_tie --case gated_past --output-dir "$FORMAL_SMALL_DIR"

# Export reviewable RTL without installing or executing a formal tool.
python3 tools/sva_reference/formal.py --emit-only --output-dir "$FORMAL_RTL_DIR"

# Check saved source bindings and task completeness; this does not rerun SBY.
python3 tools/sva_reference/formal.py \
  --check-results tools/sva_reference/fixtures/formal_symbolic_results.json
```

`SBY_BIN` points to the SBY executable in a working OSS CAD Suite; its sibling
Yosys, Yices and ABC executables are used only inside child-process environments.
The user's PATH and simulator tool selections are not changed. This run used
OSS CAD Suite 20260816, Yosys 0.68+71, SBY 0.68, Yices 2.7.0 and ABC 1.01.
The existing formal service's known PASS, FAIL and cover smoke checks also
returned their expected results before the extended run.

Unknown statuses, inconsistent exit codes, missing status files, and missing
negative-control/cover witnesses fail the run. Generation is deterministic;
source changes during a run invalidate its report. Saved-report checks reject
changed sources, incomplete task plans and unsuccessful tasks. A state-space
export over its size/count limit is rejected, rather than truncated.

Ten offline regressions cover input packing/prefix multiplicities, expectation
independence, unconstrained inputs, mutations, export limits, tool modes,
status/exit-code handling, witness requirements, overwrite prevention and
report freshness/completeness. They do not require or invoke formal tools.

## Limits of the result

The proofs are for the listed expressions, bounds, widths and initial-state
contracts. They do not prove all possible SVA expressions or Python programs.
Sequence/property inputs here are two-state; only the sampled-function model
explicitly covers x/z encodings. Scheduler regions, procedural assertion
queues, arbitrary arithmetic/types, VPI, multiple clocks and liveness of an
arbitrary unbounded strong property remain outside these checks. The finite
property tables are bounded-word results, not unbounded temporal proofs.

The independent RTL specifications are themselves human-reviewable models
authored by AI from the supplied standard. Agreement is useful evidence, not
a proof that either encoding exhausts every normative exception. Four-state
default extraction from arbitrary SV source is also not proven by this suite.

These jobs check the semantic evaluator and its selected independent models.
They do not verify the implementation of a SystemVerilog simulator, compile
the original unsupported SVA directly, change `:oracle:` metadata or increase
simulator execution coverage. No dedicated CI job was enabled; how formal
checks should be required in CI remains a separate decision.

Tool-mode references: [SBY configuration reference](https://yosyshq.readthedocs.io/projects/sby/en/stable/reference.html)
and [YosysHQ formal extensions](https://github.com/YosysHQ/sby/blob/main/docs/source/verilog.rst).

Validation completed: all 193 repository unittests passed, including 113 SVA
reference tests. The 45 concrete suite comparisons still match, and README,
generator, catalog, coverage-depth, metadata, behavior/source-audit and
requirement-matching consistency checks passed. Work is isolated and remains
uncommitted; the main worktree's concurrent changes were not modified.
