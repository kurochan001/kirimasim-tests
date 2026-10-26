# SVA reference evaluator: M0, M1 and M2

M0 was completed on 2026-10-26, starting at repository revision `b2de3bc5`.
M1 adds the expression/declaration parser and a single-clock semantic engine.
M2 reproduces all ten pilot outputs with that general engine. M3 (the wider
test population) has not been run yet. Source/trace integration limits are
documented below.
Only Python 3.10+ and its standard library are required for offline use.

## Result and decision

The three pilot traces agree with every sampled input tick of the independent
formal-pilot models: `goto_nc.sv` (21 ticks), `next_ev.sv` (24 ticks), and
`binary_ops.sv` (25 ticks). Those models are external working materials;
their stimulus functions are transcribed into `m0.audit_stimulus`.
Model output assertions are not inputs to the evaluator.
The trace fixtures retain the final timestamp as well as every selected edge.

The small clause-based pilot evaluators produce 3, 10 and 25 action events,
respectively. For all three tests, option A (Python adapters) and option B
(Icarus action replay) produce identical output. After both implementations
were complete, their outputs were compared with the existing `.expected`
files; all three agree. No test, expectation or metadata was changed.

**Use option A for v1.** The option B experiment puts actions in module
procedures after `#0`. This is the Inactive region, not the Reactive region
required by 1800-2023 4.4.2.3 to 4.4.2.6, 16.14.1 and 16.14.3. The reproducible
NBA probe sets `current <= 1` at the same timestamp as a scheduled action:
the replay reads 0, whereas a Reactive action must read 1. Moving by one time
precision step would change `$time` and is not a general solution either.
Option B stays here solely as an experiment, never as a reference backend.

## Run the experiments

From the repository root, offline (does not read expected output):

```sh
PYTHONPATH=tools python3 -m sva_reference.m0
python3 -m unittest discover -s tools -p 'test_*.py'
```

To regenerate traces, execute both output strategies, compare the independently
generated outputs, and demonstrate the scheduling limitation:

```sh
PYTHONPATH=tools python3 -m sva_reference.m0 \
  --iverilog-bin "$IVERILOG13_BIN" --refresh-traces \
  --compare-expected --probe-replay-order
```

Set `IVERILOG13_BIN` to the directory containing both `iverilog` and `vvp`
from Icarus Verilog **13.0 stable**. The version is checked. Compilation and
execution run in temporary directories with timeouts. Simulator output is
never used to derive SVA truth values.

The general trace extraction entry point is:

```sh
PYTHONPATH=tools python3 -m sva_reference.trace \
  tests/ch16/test_sequence_goto_nonconsecutive.sv \
  --iverilog-bin "$IVERILOG13_BIN" \
  --clock test_sequence_goto_nonconsecutive.clk \
  --signals test_sequence_goto_nonconsecutive.s test_sequence_goto_nonconsecutive.b \
            test_sequence_goto_nonconsecutive.c \
  --output trace.json
```

Extraction requires a source audit confirming that removed actions do not
affect stimulus or termination. It is not an automatic proof of independence.

## Trace contract and audit

- `trace.py` reads exact hierarchical VCD names, including aliases, and
  normalizes vectors to full-width lowercase binary strings with x/z,
  following 21.7.2.2 and Table 21-8. Scalar positive and negative edges include
  the four-state transitions of 9.4.2, Table 9-2.
- `sampled` contains the values strictly before the edge timestamp (16.5.1).
  `settled` contains the final VCD values at that timestamp. It must not be
  used as an Observed-region value for `disable iff` or as a general Reactive
  action value; further iterations of event regions may occur.
- Time-zero edges require declaration/type defaults (16.5.1), so they are
  explicitly rejected for now. Real/event samples, VCD dump gaps and detected
  multiple clock transitions in a timestamp are also rejected. A VCD writer
  can hide delta-cycle glitches: a single glitch-free clock and continuously
  dumped static integral signals remain prerequisites (16.5).
- JSON provenance hashes the entire `.sv` input and the ordered signal list,
  clock, edge, and extraction protocol. Changed inputs/configuration invalidate
  the cache. No absolute paths or expected-output contents enter fixtures.
  `load_trace` validates the provenance before returning any samples.
- `source.py` tokenizes comments and strings, locates labeled module-level
  directives, and removes each entire directive including its actions. It
  handles the bounded statement forms used by M0; procedural assertions,
  named SVA declarations, generate contexts, multiple modules, external files,
  preprocessor dependencies and runtime arguments are outside M0 and rejected.
  This is a source rewriter, not the M1 expression parser.

The three source audits are bound to full-source hashes in `fixtures/sources.json`:

- `test_sequence_goto_nonconsecutive`: actions only increment `n_goto` and
  `n_nonconsecutive`. Only `report` reads these counters, in `$display`.
  Stimulus and `$finish` never depend on them. Reports are at 61, 131, 201 ns.
- `test_property_nexttime_eventually`: actions only increment four failure
  counters, read by `$display` and reset between phases. `later`, the loop
  index and stimulus do not depend on them. Reports are at 60 ns intervals.
- `test_property_binary_operator_forms`: actions only increment nine failure
  counters, read by `$display` and reset between phases. `ps`, `qs`, the loop
  index and stimulus do not depend on them. Reports are at 50 ns intervals.

All decision windows used by these adapters complete before simulation end;
there is no M0 claim about strong/weak end-of-trace behavior or vacuity.
`m0.evaluate` produces only events for actions present in these three tests,
not a full success/failure/vacuity/disable attempt record. Its source hash
guard refuses reuse after any source change; changing the manifest requires
a new source/adapter audit.

The normative PDF was read locally for 4.4.2, 16.5.1, 16.9.2, 16.12.7,
16.12.10, 16.12.12, 16.12.13, 16.14 and 21.7.2. The implementation paraphrases
rules and cites clauses; it does not reproduce standard prose.

## M1: parsing and semantics

The M1 engine is separate from the three fixed M0 evaluators:

- `parser.py` implements the binding powers and associativity of Tables 16-1
  and 16-3. It parses the v1 sequence/property operators, clock/disable
  prefixes, `if`/`else`, `case`, and integral Boolean expressions.
- `module.py` locates named declarations and directives. It binds positional,
  named, omitted and default expression arguments, inherits formal types,
  inserts the casts of 16.8.1/F.4.1, resolves module-body constant parameters,
  and supports an empty default clocking block and default disable condition.
  Recursive definitions and multiple clocks fail explicitly.
- `values.py` evaluates finite-width four-state integral expressions, including
  arithmetic context sizing, signedness, selections, logical/bitwise operators,
  equality and ternary merging (6.11, 6.24.1, 11.4, 11.6 and 11.8).
- `automata.py` consumes sequences one tick at a time using weighted regular
  derivatives. Coefficients preserve multiplicity; fusion excludes empty
  operands (16.9.2.1); `first_match` freezes the earliest matches, including
  ties (16.9.8). Future viability uses the abstract top letter and cycle
  detection of residuals (F.5), without selecting a finite lookahead limit.
- `engine.py` exposes sequence matches, per-attempt property decisions and
  sequence coverage. Implication checks every antecedent match; followed-by
  uses the dual form of F.3.4.3.6. Property decisions include their tick/time;
  no simulator evaluates the assertion expressions.

Example, using already sampled values:

```python
from sva_reference.engine import Engine

engine = Engine([{"a": "1", "b": "0"}, {"a": "0", "b": "1"}], times=[5, 15])
result = engine.property("a |=> b")
assert (result.status, result.tick, result.time) == ("success", 1, 15)
```

Tick indices in the Python API are zero-based. `Match(start, start - 1)`
represents an empty interval. A sequence can return duplicate `Match` objects;
do not deduplicate them. Property coverage instead reports at most one
successful result per attempt.

`Engine` inputs are already sampled, including declaration defaults if the
first clock edge is at time zero. Strings are unsigned bit vectors. Use
`Bits(bits, signed=True)` for signed declarations; nonzero or ascending packed
ranges use `Bits(bits, lsb=..., ascending=...)`. The engine does not guess the
declared type from VCD values. `parse_module` returns expanded specs and source
actions; it does not execute stimulus or action blocks.

Finite words have the four satisfaction levels of 16.12.21/F.5.3.2. A result
with `status="holds"` or `status="pending"` has no decision tick; its
`finite_truth` records neutral finite-word satisfaction. In particular, a weak
unfinished sequence can hold while a strong unfinished sequence is pending.
Neither result is assigned a pass/fail action at an invented final clock tick.
Vacuity from an absent antecedent or an unselected conditional is recorded;
the general nonvacuity relation of F.5.3.3 remains outside the requested v1.

`disable iff` requires a complete, ordered current-value event stream, not
sampled or end-of-slot VCD values. Supply `Current(time, values)` for each
Observed tick and `Current(time, values, "change")` for other updates. Events
at the same timestamp retain region order. Only events from the attempt's
starting Observed snapshot through its deciding Observed snapshot can cancel
it; an off-clock reset can cancel a pending attempt too. Missing current-value
evidence is an error. M0 VCD fixtures intentionally do not claim to provide it.

### M1 validation and remaining integration work

`test_sva_reference_semantics.py` adds 38 tests covering the operator families,
type/argument rules, finite-trace levels, disable boundaries and failure ticks.
`fixtures/lrm_examples.json` stores only clause/figure IDs and reduced Boolean
input/result data from Figures 16-5, 16-6, 16-10, 16-11, 16-12 and 16-13.
The containment example in 16.9.10 is included as well; its sampled predicate
is supplied as an input rather than implementing a sampled-value function.
The PDF waveform pages were inspected visually. Further tests cover the
16.9.8 tie example, the 16.9.2.1 empty concatenation equivalence and the
16.12.16 delay-selection example. No standard prose is copied into fixtures.

All ten pilot sources parse. On the three existing M0 trace fixtures, the
general engine reproduces all action schedules of the independently written
M0 evaluators. This comparison happens after the normative tests. M1 tests do
not read suite `.expected` files or simulator assertion outputs.
Validation on 2026-10-26: all 131 tests in the repository's standard unittest
discovery passed, including 51 SVA reference tests (13 M0 and 38 M1).

The source frontend still intentionally accepts a bounded source subset:
one plain module, integral formal types with literal packed ranges, body
parameter declarations without external overrides, expression/signal actuals,
and the procedural source forms already handled by M0. It does not elaborate
an arbitrary SystemVerilog design. An unbounded repetition whose operand
admits an empty match is rejected rather than collapsing infinitely many
empty decompositions into a finite match count. These boundaries are explicit
`Unsupported` errors; they are not verification successes.

The M0 fixed evaluators are not used by the M2 pipeline below.

For queue-based pilots, removing directives alone is insufficient for the
Icarus stimulus backend: 13.0 crashes while compiling the queue argument of
the `times(int q[$])` reporting function. See the observation in
[`docs/simulator-differences.md`](../../docs/simulator-differences.md).
M2 omits that reporting-only code from a disposable stimulus copy after an
explicit dependency audit. The original test remains intact.

## M2: ten pilot outputs

On 2026-10-26, all ten independently generated outputs matched the existing
suite expectations exactly: **188 sampled ticks, 117 action events, 45 display
lines, zero differences**. The engine's semantics required no M2 changes.

- `test_sequence_goto_nonconsecutive`: 21 ticks, 3 actions, matched.
- `test_sequence_throughout_within`: 33 ticks, 5 actions, matched.
- `test_property_until_strong_forms`: 20 ticks, 5 actions, matched.
- `test_sequence_first_match`: 15 ticks, 15 actions, matched.
- `test_sequence_and_or_intersect`: 14 ticks, 12 actions, matched.
- `test_sequence_consecutive_repetition`: 11 ticks, 9 actions, matched.
- `test_property_nexttime_eventually`: 24 ticks, 10 actions, matched.
- `test_followed_by_existential`: 15 ticks, 20 actions, matched.
- `test_property_binary_operator_forms`: 25 ticks, 25 actions, matched.
- `test_sequence_empty_match_concatenation`: 10 ticks, 13 actions, matched.

Run all ten offline, or check a single audited source:

```sh
python3 tools/sva_reference/check.py --pilots
python3 tools/sva_reference/check.py tests/ch16/test_sequence_first_match.sv
```

Generation without opening any expected-output file:

```sh
python3 tools/sva_reference/check.py --pilots --emit-only --output-dir "$M2_OUTPUT_DIR"
```

Refresh stimulus traces with the pinned Icarus release, then compare:

```sh
python3 tools/sva_reference/check.py --pilots --refresh-traces \
  --iverilog-bin "$IVERILOG13_BIN" --output-dir "$M2_OUTPUT_DIR"
```

`--output-dir` saves `.actual` stdout and `.events.json` action/attempt evidence
for each pilot. `--json` returns comparison results and diffs. A mismatch exits
1; unsupported or stale inputs exit 2. Without `--emit-only`, all selected
outputs are generated before the first expectation is opened. No code copies
an expectation into an adapter. The M2 adapters and source audit are limited
to the listed ten inputs; `--pilots` is not M3 coverage of the full suite.

### Stimulus projection and cache evidence

`bridge.py` carries top-level primitive integral declaration width, signedness,
two-state status and packed range into `Bits`, and checks these against VCD.
It rejects missing type metadata or a wrong clock/edge. Synthetic tests cover
signed ascending vectors, nonzero index bases, two-state unknowns and widths.

The independent source/dependency audits are bound to whole-input hashes in
`fixtures/pilot_sources.json`:

- In the five queue-reporting tests (throughout/within, first_match,
  and/or/intersect, consecutive repetition and empty concatenation), actions
  only push `$time` into report queues. Those queues are only read by
  `times()` in the final displays. Neither function nor displays affect the
  stimulus, delays, control flow or `$finish`.
- In the five counter-reporting tests (goto/nonconsecutive, until forms,
  nexttime/eventually, followed-by and binary operators), actions only
  increment report counters. The counters are read for display and, except
  for the cumulative goto test, reset between phases. Stimulus and termination
  never depend on their values.
- Projection starts from `parse_module(...).stimulus`, which already excludes
  SVA declarations, directives and actions. It replaces each display with a
  null statement, preserving controls such as `#1; #9;`. Only the explicitly
  selected report function `times` is removed. Other stimulus functions,
  task calls, assignments, resets and timing statements remain.
- `fixtures/m2/` caches include the original input hash, exact projected-source
  hash, extraction protocol, clock/edge, signal list and declaration metadata.
  Any change to those inputs invalidates reuse. Expected-output content is
  not part of stimulus provenance. Source changes also require a fresh
  independence/report audit, not an automatic manifest update.
- Every one of the 188 samples agrees with the external formal-pilot model's
  independently written `stim()` function. Only each input function was
  compiled for that check; none of the formal assertions or result counters
  was used. `fixtures/m2/stimulus_inputs.json` retains these input-only vectors,
  signal order, model filename and input-function hash for offline regression.

`pilots.py` uses the general `Engine` for all sequence/property evaluation.
It retains every cover-sequence match and creates at most one property action
per attempt. The output adapter reads display formats and arguments from the
source and formats event counters or time queues. Phase durations and formal
names are the small test-specific part, guarded by the audited source hash.
Duplicate time pushes are preserved; reports reset phase counters at their
audited boundaries. An action at the report timestamp is rejected as requiring
a scheduling review. All actual M2 report timestamps lie between clock edges.

`test_sva_reference_pilots.py` adds 14 offline regressions for the full ten-file
comparison, independent generation, input vectors, duplicate coverage actions,
phase resets, projection boundaries, cache invalidation and typed trace input.
All 145 tests in standard repository unittest discovery passed, including 65
SVA reference tests. Both refreshed Icarus traces and offline cached execution
produced ten matches.
No dedicated workflow or simulator dependency was added to CI; these tests
use the repository's existing unittest discovery.

M3 is next: classify and evaluate the remaining in-scope population, reporting
every unsupported case and any difference with its clause-based judgment.

Recording evaluator verification in metadata/coverage and enabling evaluator
jobs in CI remain user decisions. M2 changes neither oracle metadata nor
coverage ledgers and does not count these comparisons as simulator execution
verification.
