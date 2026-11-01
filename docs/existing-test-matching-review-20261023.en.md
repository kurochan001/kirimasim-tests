<a id="既存テストの要求照合代入系の続行結果2026-10-23"></a>

# Existing-test requirement mapping: assignment continuation results (2026-10-23)

[English](existing-test-matching-review-20261023.en.md) / [日本語](existing-test-matching-review-20261023.md)

> Counts, percentages, and pending statuses in this document record their respective work dates.
> The current value is [Aggregated Summary](behavior-coverage-summary.en.md); the approval history for the denominator and interpretations is in
> See [Results of requirement extraction](requirement-extraction.en.md).

[Current coverage](behavior-coverage-summary.en.md) / [Comparison ledger for all tests](test-requirement-matching.en.md) / [Findings from previous rounds](existing-test-matching-review-20261022.en.md)

This document records the assignment review at the milestone of 680 tests and 574 requirement rows. See subsequent [Subroutine continuation results](existing-test-matching-subroutines-20261023.en.md) and latest [Continued expression and arithmetic results](existing-test-matching-expressions-20261023.en.md).

<a id="対応登録の進捗"></a>

## Mapping-registration progress

Compared the existing stimulus and expected output against the supplied IEEE 1800-2023 text, focusing on assignments, NBA, delays, procedural continuous assignments, initialization, assignment patterns, and unpacked array concatenation.

- Tests with registered mappings: increased from 637 to 680 (added 43 of the 3,912 total tests).
- requirement lines supported: from 533 to 574 (41 added). There are 76 new mapping rationales.
- Execution-verified requirements: 483 → 509 rows.
- Provisional requirement coverage (test design): 4.66% (574/12,319). The provisional execution confirmation rate is 4.13% ( 509/12,319 ).
- Finalized values: both design and execution remain unfinalized. Denominator approval, semantic deduplication and resolution of interpretation issues remain outstanding.
- Tests without even one registered mapping: 3,232. The mapping based on the verification content of all tests is not complete.

The registered test count is the number of tests with at least one observation mapped to a requirement. 680 This does not mean that all observations and requirements have been examined. Of the 41 added rows, 15 have no record of an acceptable pass result, so only their design mappings are registered.

This time, we do not change the test body, expected value, citation, runner, and requirement definition. Compared the saved execution results for Icarus 13.0 / Verilator 5.052 against the current input hashes. The simulator is not rerun this time, and the known inconsistency and non-compatibility are not converted to success.

<a id="登録した主な観測"></a>

## Main registered observations

- Capture of the old right-hand side in NBA, pre-update values, continued procedural execution during delay/event waits, and scheduling order for the same update time.
- Stimulus that changes the index after scheduling distinguishes NBA target capture from target evaluation when a blocking delayed assignment resumes.
- Event waits resume within the same time step after a NBA update.
- Procedural assign overrides ordinary assignments; after deassign, the value persists, stops following inputs, and ordinary assignments resume.
- Short-pulse cancellation by inertial delay, composition of net/driver delays, and net delays from module outputs.
- Declaration initialization is not a continuous driver; initial values at procedural start; sign/zero extension.
- The assignment context of return/static cast/non-default pattern items of the function.
- Array-concatenation item expansion order, empty concatenations, context differences between string and array concatenation, and expansion of typed array items.

For net-delay requirements, 2 tests covering a continuous-assignment driver and a module-output driver were used as collective evidence. Require both to succeed in the same run; one succeeding alone does not make the entire row execution-verified. Requirements with set-level evidence total 13 rows.

<a id="m09論理値だけでは駆動強度を検証できない"></a>

## M09: logical values alone do not verify drive strength

Scope: [test_strength_ops.sv](../tests/ch10/test_strength_ops.sv)、 [test_strength_edge_cases.sv](../tests/ch10/test_strength_edge_cases.sv)。

Although strong/weak/pull and similar strengths are specified, each net has one driver and observations cover only logical 0/1. For example, a incorrect implementation that treats weak as strong will still have the same current output. We need to either make drivers of different strengths compete on the same net, or observe the strength itself. highz0 / strong1 in strength_ops also observes only 1 inputs and does not check that the result becomes z when given 0. These are not matched to the entire requirement to verify the meaning of the strength.

<a id="m10テスト名表示と実際に検査する代入動作の違い"></a>

## M10: Difference between test name and display and assignment action that is actually tested.

T18 in [test_ct_assignment_complex.sv](../tests/ch10/test_ct_assignment_complex.sv) displays `packed NBA`, but the actual statement is the blocking assignment `nba_packed = 16'hBEEF`. To verify NBA, use `<=` and separately observe values before and after updating. This comment is about T18 and does not deny other NBA scenarios in the same file.

[test_nba_complex_lhs_extended.sv](../tests/ch10/test_nba_complex_lhs_extended.sv) uses variable index idx but does not change it between scheduling and update. An incorrect implementation that evaluates the index at update time writes to the same location. The observation is therefore registered only for the legal LHS form, not as confirmation of when the target is captured.

Multiple NBA to nonoverlapping slices in [test_nba_part_select.sv](../tests/ch10/test_nba_part_select.sv) and [test_nba_complex_lhs.sv](../tests/ch10/test_nba_complex_lhs.sv) also give the same final value when update order is reversed. Mapped preservation of ordering to the same destination using another test with overlapping updates.

<a id="m11明示deassign後の再接続はassignによる暗黙の置換を実行しない"></a>

## M11: Reconnection after explicit deassign does not perform implicit substitution by assign

Scope: [test_assign_deassign_2.sv](../tests/ch10/test_assign_deassign_2.sv)、 [test_assign_proc.sv](../tests/ch10/test_assign_proc.sv)。

Both explicitly deassign before a new assign. To test 10.6.1's rule that assign releases/replaces an existing assign, apply a new assign while the old one remains active, then change both right-hand sides and verify that the old connection is broken. Keep this distinct from valid observations of retention after explicit deassign and resumption of ordinary assignment.

<a id="m12値や時刻を観測しないシナリオの扱い"></a>

## M12: Handling of scenarios without values or time observations

Test7 and Test10 in [test_assign_edge_cases.sv](../tests/ch10/test_assign_edge_cases.sv) display fixed PASS after repeatedly changing the inputs or selector, without reading the output value. The same expected output can be produced without implementing propagation in this 2 scenario. Output after each change must be checked directly.

The delay1 check in [test_continuous_assign_2.sv](../tests/ch10/test_continuous_assign_2.sv) observes only the old value at #0 and the new value at #2. Unable to verify the delay to the exact 1 unit. A timed transition sequence of another rise/fall delay test was registered to the propagation delay and short pulse cancellation requirement.

Similarly, the test of reading the net after waiting for #1 after release is not a complete proof of immediate return. Also recorded that driving only one alias side does not verify bidirectionality, and not changing the right-hand side during force does not verify continuous reevaluation.

<a id="保留理由と検査"></a>

## Reasons for deferral and checks

This round added scope-specific decisions for 37 tests and 38 cases, bringing [Review judgement table](../coverage/test-matching-reviews.json) to a cumulative 90 tests and 94 cases. Retain evidence strings and input hashes for partial observations, compound requirements, insufficient citations, and related issues. Deferred decisions are not added to coverage or counted as completed reviews of entire files.

Verified that 12,319 requirement definitions, the denominator identifier, and standard-material hashes are unchanged. Checks also cover 74 tests of the management tools, consistency between mapping rationales and execution evidence, and consistency of generated files and metadata.
