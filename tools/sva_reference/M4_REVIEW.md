# M4: single-clock sampled functions (2026-10-26)

The user selected sampled functions for the first M4 extension. All seven
audited inputs match their existing expectations: 35 sampled ticks, six
assertion action events and 39 output lines. No additional expected-output,
test-source or oracle change was needed for M4. M2's ten and M3's 28 tests
still match, including M3's separately approved corrections.

[`fixtures/m4_inventory.json`](fixtures/m4_inventory.json) accounts for all
20 legal spec-only candidates that actually call one of these six functions.
Seven are evaluated; 13 mixed-feature cases are deferred with source hashes,
reasons and evidence. Deferred cases are not successful evaluations or a claim
of full sampled-function support. Changed/new unaudited cases report a gap
instead of disappearing or being classified from a parser failure.

## Semantics and normative checks

The implementation was written from 16.5.1 and 16.9.3 before opening these
seven expectations. The supplied PDF was checked at PDF pages 394–395 and
415–419 (printed pages 393–394 and 414–418); declaration/type defaults use
6.8 Table 6-7 and 6.11 Table 6-8. The repository contains paraphrases and
test vectors, not copied standard prose.

`sampled.History` evaluates static integral operands independently of property
attempts and calls. `$sampled` selects this time step's sampled operand;
`$past` selects a strictly earlier tick, filters by its gating expression,
and falls back to recursively evaluated declaration/type defaults if history
is insufficient. Omitting optional arguments retains their defaults. An
explicit clock argument must resolve to the same scalar edge as this history.

`$rose` and `$fell` compare only the least significant bit; x/z to 1 is a rise,
and x/z to 0 is a fall. `$stable` and `$changed` compare the whole four-state
vector. At the first tick these functions compare against declaration/type
defaults. A system-call operand retains its own width and sign before use in
the surrounding expression.

The sequence/property engine calls the same history evaluator for Boolean
atoms, property if/case selectors and supported sampled disable conditions.
Action-only live names are evaluated from a separately audited current-value
snapshot, while sampled calls still use the sampled history. An off-clock
sampled disable is rejected without a time-step Preponed snapshot. History
functions in disable conditions require an explicit clock; `$sampled` does not.

Sixteen normative regressions cover all 16 four-state LSB transitions, upper
bit changes, defaults, gating/omissions, independent history, compound operands,
signed widths, explicit clocks, action/current separation, temporal operands
and failure boundaries. Seven integration regressions check generation before
comparison, emit-only independence, projection, NBA snapshots, source/default
provenance, keyword boundaries in clock arguments and missing audit entries.

## Audited inputs and report schedules

Four tests call functions in clocked procedures:

- `ch16/test_past_gating_expression`: six ticks; integer input and gating bits
  change between edges. The tick counter only labels displays. The scalar
  literal gate array is projected to an indexed expression for Icarus.
- `ch16/test_rose_fell_lsb_four_state`: 18 ticks; the read-only literal vector
  array is projected to indexed expressions. Inputs change at falling edges,
  preserving the rising-edge Preponed samples. The counter is report-only.
- `ch16/test_value_change_first_tick`: two ticks; uninitialized/initialized
  static operands exercise their different default sampled values.
- `ch16/test_sampled_value_functions_with_clocking_event`: three captured
  ticks; only the source's displays at times 15 and 25 are emitted. Explicit
  clocks equal the procedural clock. No report changes stimulus or termination.

Three tests read live values in assertion actions:

- `ch16/test_sampled_in_action_block`: one tick, one failure; the NBA assignment
  has changed live `b` before the failure display, while `$sampled(b)` is 1.
- `ch16/test_sampled_without_clocking_event`: four ticks, four failure actions
  and a final counter display. Two NBA assignments update live `a`/`b`; the
  actions only increment a report counter and display values.
- `ch4/test_preponed_sample_observed_before_action`: one tick, one pass action;
  the selected Preponed `data` is 0 and the live NBA-updated value is 1.

For these exact three sources there are no Reactive writers, action feedback,
Re-NBA updates or same-slot glitches of selected inputs. Their settled VCD
values therefore equal the live values read by these actions. This is a
source-bound scheduling audit, not a general event-region simulation claim.
All reporting/action code is stripped before Icarus runs; no simulator
assertion or sampled-function result is used by the evaluator.

Whole-source hashes in [`fixtures/m4_cases.json`](fixtures/m4_cases.json) bind
these audits. Input caches also bind projected source, declaration types,
default sampled values, selected signals, clock/edge and current-value mode.
Refreshing all seven input caches with Icarus 13.0 stable reproduced them
byte-for-byte. The three NBA/action-read sources were also projected and run
with Verilator 5.052; every selected sampled and settled value agreed, with
proportional clock timestamps allowing for VCD precision differences.
[`fixtures/m4_verilator_input_audit.json`](fixtures/m4_verilator_input_audit.json)
binds this input-only check to source/cache hashes. Outputs are all generated
before comparison begins.

## Remaining boundaries and use

The 13 deferred inputs combine sampled calls with global future functions,
two clock histories/inference, automatic variables/const casts, event/sequence
methods, procedural assertion queues, checker elaboration, or VPI assertion
control. One also needs time-zero VCD edge discovery and user-function
evaluation with a live free variable. The exact per-file list is in
[`fixtures/m4_deferred.json`](fixtures/m4_deferred.json). This extension does
not silently approximate those features.

```sh
python3 tools/sva_reference/check.py --sampled
python3 tools/sva_reference/check.py --sampled --emit-only --json
python3 tools/sva_reference/check.py --sampled --output-dir "$M4_OUTPUT_DIR"
python3 tools/sva_reference/check.py --sampled --refresh-traces \
  --iverilog-bin "$IVERILOG13_BIN"
```

Offline runs use Python's standard library and cached inputs. `--emit-only`
does not read expectations; a mismatch exits 1 and a gap/error exits 2. No
simulator verification rate, oracle value or dedicated CI job was added.

Validation completed: all 183 repository unittests passed, including 103 SVA
reference tests. The README statistics, generated tests, catalog, coverage
depth, metadata lint, behavior coverage/source audit and requirement-matching
checks also passed. Work remains in the isolated worktree; no M4 commit or
push has been made.
