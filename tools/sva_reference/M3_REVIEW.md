# M3 discrepancy review (2026-10-26)

The additional population was implemented and independently generated before
opening its expected outputs. After checking source projection, sampled inputs,
action adapters and the normative PDF, 26 tests initially matched and the two below required
expectation/explanation corrections. The user approved both corrections on
2026-10-26; they are applied, and all 28 additional tests now match.
The full survey is [`fixtures/m3_inventory.json`](fixtures/m3_inventory.json).

The PDF pages checked were printed pages 413, 445, 449 and 480 (PDF pages 414,
446, 450 and 481); the empty-match/alignment/followed-by pages were also viewed
as rendered images. These notes paraphrase the rules rather than copying them.

## 1. Followed-by trials without an antecedent match

Test: `tests/ch16/test_property_implication_operator_forms.sv`.

The source's four directives are module-level. By 16.14.5, each starts a new
attempt on every clock tick, including the four ticks per phase where `go`
is zero. At those four starts, `go ##1 a` cannot match. Sections 16.12.7 and
16.12.9 distinguish the operators: implication succeeds vacuously without a
match; followed-by requires a match and therefore fails. There is no outer
`go |-> ...` guard on the followed-by directives in this test.

Each followed-by failure counter consequently includes four failures plus any
failure of the attempt that starts with `go` high. The first phase gives
`#-# 4, #=# 5`, the second gives `5, 4`, and the third gives `5, 5`. The two
implication counts do not change. The original expectation omitted all four
non-go-started failures in every phase.

The source explanation also describes the end of `go ##1 a` inaccurately:
`go` is at the first phase tick and `a` at the second, so the antecedent ends
at the second tick, one tick after its start. The corrected comment makes both
that alignment and the four extra starts explicit.

The generated result is:

```text
x at tick 1: |-> 0, |=> 1, #-# 4, #=# 5
x at tick 2: |-> 1, |=> 0, #-# 5, #=# 4
x at tick 0: |-> 1, |=> 1, #-# 5, #=# 5
```

The focused unit regression uses an independent five-tick input word and
checks the unguarded forms against an explicitly guarded form. It does not
read this test's expectation to choose a result.

## 2. Empty repetition does not add a clock tick

Test: `tests/ch16/test_zero_repetition_no_sample.sv`.

Section 16.9.2.1 reduces `empty ##1 b` to `b` at the current tick. Thus
`start |-> (a[*0] ##1 b)` checks `b` at the tick where `start` is true.
For `(a[*0]) |=> b`, the empty-antecedent case in 16.12.7 aligns the
consequent to the current tick of this singly clocked property as well.
The fact that `a[*0]` takes no sample (16.12.22) does not insert a delay.

At time 10, the sampled `start` is 1 and `b` is 0: both assertions fail
immediately. At time 20, both are 1: both new attempts pass immediately.
Neither assertion has a pending attempt waiting for a tick at time 30.
The correct counts at the display at time 25 are therefore:

```text
zero: pass=1 fail=1; antecedent: pass=1 fail=1
```

The original expected output had zero failures, and the explanation incorrectly
delayed both checks to the next tick. The approved correction changes those counts,
the explanation/inline timing comments and the cited clauses, preserving the
stimulus and assertion expressions. A focused unit test checks both decisions
directly on the two sampled ticks at times 10 and 20.

## Approved correction and evidence boundaries

The user approved both corrections on 2026-10-26. The two expected outputs,
explanations and relevant citations are corrected. Assertion expressions and
stimulus are unchanged. The judgment file retains the original source,
expectation and generated-output hashes alongside the corrected bindings;
refreshed Icarus stimulus traces independently reproduce all 28 outputs.

The required simulator reruns are saved separately as
`coverage/results/sva-m3-corrections-20261026-icarus13.json` and the corresponding
`verilator-seed1.json` / `verilator-seed73.json` files. Both tests are `known`
in all three runs: the pinned simulators reject the unsupported SVA syntax.
These runs do not verify the expected outputs. The behavior observations,
evidence strings and input hashes were reviewed and updated; no matching-review
record referred to either test. Generated catalogs and coverage reports are
refreshed with the repository's prescribed checks.

No oracle metadata was changed. Reference matches do not count as simulator
verification or increase execution coverage. No issue or PR was sent upstream.
