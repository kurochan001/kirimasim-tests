<a id="既存テストの要求照合で見つかった問題2026-10-22開始2026-10-23更新"></a>

# Issues found during existing-test requirement mapping (started 2026-10-22, updated 2026-10-23)

[English](existing-test-matching-review-20261022.en.md) / [日本語](existing-test-matching-review-20261022.md)

> Counts, percentages, and pending statuses in this document record their respective work dates.
> The current value is [Aggregated Summary](behavior-coverage-summary.en.md); the approval history for the denominator and interpretations is in
> See [Results of requirement extraction](requirement-extraction.en.md).

Scope is the mapping between existing tests and the IEEE 1800-2023 requirement ledger. This report does not report that the mapping based on the verification content of all tests has been completed. See both [Comparison ledger for all tests](test-requirement-matching.en.md) and [Current measurements](behavior-coverage-summary.en.md). For further results, see [Unregistered test match (2026-10-25)](existing-test-matching-unregistered-20261025.en.md), [Denominator review](denominator-review-20261028.en.md), and [Gap investigation (2026-10-29)](coverage-gap-recommendations-20261029.en.md).

<a id="今回の到達点"></a>

## Progress achieved in this work

- Registered unapproved candidates based on cited clauses and input hashes for all 3,938 tests in the mapping ledger.
- Tests with registered mappings increased from 55 to 1,386, and mapped requirement rows increased from 114 to 2,465. This counts tests with at least one mapped observation; it does not mean all observations/requirements across 1,386 tests are fully reviewed.
- Track 2,552 unregistered tests as outstanding work. Mappings based on verification content for every case remain incomplete.
- Used the saved Icarus 13.0 / Verilator 5.052 execution results for all 3,912 tests, plus separate execution results for added tests and tests with changed citations. Partial runs are not treated as a batch rerun of all 3,938 tests. Known mismatches are not counted as successes. See the linked summary and execution evidence for success counts.
- Provisional requirement coverage (test design) of the registered rows is 20.009741% (2,465/12,319), and execution verification coverage is 10.49% (1,292/12,319). The definitive value remains undetermined. The measurement rule 3 handles requirements shared across multiple tests. Its version and the denominator identifier were retained in the history.
- The stimulus, expectation, and requirement definitions of the existing test are not changed. In addition to the earlier 7 tests and 4 tests from the subroutine comparison, clarified or corrected only the `:lrm:` citations in 7 tests from the associative-array comparison, and reran them after updating. The stimulus, expected-value, and assessment issues described from M01 onward are unchanged by this mapping work.

<a id="最新の続行結果2026-10-26"></a>

## Latest continuation results (2026-10-26)
From 2026-10-25 through day 26, verified and integrated all remaining segments awaiting validation.
- Comparison proposals: adopted 397 of 402 for p01, p05, p07, p12; 461 of 473 for p09, p10, p13, p15; and 507 of 513 for annex and gap ranges (a01–a05, g05, g08, g09, h01, h02).
- Tests: New tests (256 tests, 188 tests, and 176 tests) have been added. Tests found defective during review were corrected where possible, including input ports missing `var`, diagnostic line numbers, and `:oracle:` annotations; semantically incorrect tests were removed.
- Additional tests: wrote 18 tests for requirements in K.2, I.3, and N.2, plus 30 tests for assertion control, coverage, checker, and 1364 VPI; added them after independent validation. For Annex A syntax tests, integrated 369 mappings and 93 tests from 517 proposed mappings.
- `:oracle:`: among the tests previously supported by the standard alone, recorded `iverilog@13.0` for the 277 tests in which Icarus 13.0 reproduces the expected output and diagnostics, then reran them.
- Existing-test matching: candidate tests within 12 were independently reviewed, 341 requirements were mapped, and 1,392 cases observing only part of a requirement were recorded as deferred.

The totals are 9,585 requirements (77.80664%) and 5,424 requirements with recorded pass results (44.029548%), exceeding the 75% target. The main text alone (Chapters 1–40) gives 77.46%.

<a id="2026-10-24の続行結果"></a>

## Continued results for 2026-10-24
In [Round 2 of new tests for unmapped requirements](gap-tests-2-20261024.en.md), resumed the suspended creation work for the 8 range and incorporated 933 independently verified new tests and proposed comparisons. The totals are 7,341 mapped requirements (59.590876%), with recorded pass results for 4,135 requirements (33.566036%). The main text alone (Chapters 1–40) gives 62.57%. Verification rejected 102 of 1,030 comparison proposals and identified 26 of 962 new tests as defective. New types of flaws included an example of a comment on the same line as `` `line `` overlapping violations of 22.12 and an example of a virtual interface being an input port without a type.

The result of the previous 2026-10-24. In [New tests for unmapped requirements](gap-tests-20261024.en.md), incorporated 594 new tests and proposed comparisons for the independently verified 13 range. The totals are 6,430 requirements (52.195795%) and 3,734 requirements with recorded pass results (30.310902%), exceeding the 50% target. The main text alone (Chapters 1–40) gives 53.47%. Verification rejected 166 of 2,215 comparison proposals and identified 30 of 624 new tests as defective. The form declaring a 2-state input port without a kind (`input int`, which becomes a net under 23.2.2.3 and 6.7.1 and violates the standard) appeared in 1 integrated tests (fixed) and 7 existing tests (not yet fixed).

The result of the previous 2026-10-24. Reworked reserved-word rows into standard-violation tests in [Re-evaluate the requirement extraction log.](requirement-extraction.en.md), resolving 27 pending interpretations. The subsequent [Generating illegal-design tests for reserved keywords](keyword-tests-20261024.en.md) added mappings between 496 generated tests and 497 requirements, bringing the totals to 4,386 mapped requirements (35.603539%), with recorded pass results for 2,893 requirements (23.484049%). The main text alone (Chapters 1–40) gives 31.92%.

<a id="2026-10-23の続行結果"></a>

## Continued results for 2026-10-23
Integrated the independently validated portion in [Adding and mapping annex-header / VPI tests](header-vpi-tests-and-matching-20261023.en.md). The totals are 3,889 mapped requirements (31.569121%), with recorded pass results for 2,396 requirements (19.449631%). Added 24 new tests for the C headers in Annexes I/K/L/M (1,081 requirements), 24 new VPI tests for Clause 37 (193 requirements), mappings for 150 requirements from existing tests, and 32 deferral decisions for M98–M129. Most of the increase comes from constant rows in the annexes; for the main text alone (Chapters 1–40), coverage is 29.30% (2,779/9,486). The target of 50% has not been met, and the pre-verification portion has not been included.

The following records the earlier 20% milestone. [Mapping results exceeding 20%](existing-test-matching-20percent-20261023.en.md) achieved this goal. The totals are 2,465 mapped requirements (20.009741%), with recorded pass results for 1,292 requirements (10.487864%). The mapping based on the verification content of all tests is still incomplete. Added 1,296 pieces of evidence from 418 tests, preserving requirement definitions, denominator, and existing inputs. Added M65–M97 and 42 hold decisions. The final audit excluded 20 provisional mappings that conflicted with existing deferrals and replaced them with 20 mappings using different fixtures.

The previous [VPI comparison and results reaching 10%](existing-test-matching-vpi-20261023.en.md) added 442 pieces of mapping evidence from 55 tests, increasing mapped requirement rows from 810 to 1,242 (+432 additional rows). The provisional requirement coverage (test design) 10.081987% has been verified to exceed 10%. Execution verification covers 754 rows, 6.12%. Recorded M59–M64, 39 scope-specific assessments, and 5 items of AND set-level evidence. Existing inputs and requirement definitions are retained. Did not rerun original tests; compared input/runner hashes against saved results. In the immediately preceding [Compiler-directive review results](existing-test-matching-preprocessor-20261023.en.md), added mapping evidence for 32 tests, 18 requirement rows, and 85 mappings. M52–M58 records set-level evidence for 5 cases and scope-specific assessments for 41 cases. We compare the current input hash with the saved execution trace without changing the existing stimulus, expectation, and metadata. All 18 new requirement rows have recorded pass results. This is not a rerun of all the previous tests or an addition of new tests. In the immediately preceding [Adding tests for missing associative-array observations](associative-gap-tests-20261023.en.md), added 15 new tests, 24 requirement rows, and evidence for 28 mappings in response to M45–M50. On Verilator 5.052 with seed 1/73, 8 tests agreed and 7 were known; on Icarus 13.0, 15 were known. Execution-verified requirements increased by 12 rows. Only measured results for the updated inputs are accepted. In the immediately preceding [Associative-array review results](existing-test-matching-associative-arrays-20261023.en.md), added mapping evidence for 35 tests, 22 requirement rows, and 74 mappings. Records M44–M51, collective evidence for 12 cases, citation corrections in 7 tests, and reruns of 40 tests. In the immediately preceding [Array-method review results](existing-test-matching-array-methods-20261023.en.md), added mapping evidence for 35 tests, 21 requirement rows, and 119 mappings. The collection of evidence of M36 - M43 and reasons for retention, and 8 is recorded. In the immediately preceding [Review results for classes, construction and methods](existing-test-matching-classes-20261023.en.md), added mapping evidence for 45 tests, 27 requirement rows, and 92 mappings. The collection of evidence of M29 - M35 and reasons for retention, and 3 is recorded. The immediately preceding [Review of control statements and loops](existing-test-matching-control-flow-20261023.en.md) added mappings for 51 tests and 26 requirement rows. Records M23–M28, set-level evidence, execution evidence, and pending reasons. In the immediately preceding [Adding tests for missing observations](expression-gap-tests-20261023.en.md), added 11 new tests and mappings for 29 requirement rows in response to M18–M22, and ran them with the updated inputs. In the immediately preceding comparison of formula, width, signedness, and arithmetic, the support of the 29 tests, 42 requirement line has been added. [Expression and arithmetic review results](existing-test-matching-expressions-20261023.en.md) records M18–M22, collective evidence for exponentiation, reasons for not adopting proposals, and execution evidence. See [Review results of subroutines](existing-test-matching-subroutines-20261023.en.md) for the immediately preceding addition of 42 tests and 27 requirement rows, and [Assignment review results](existing-test-matching-review-20261023.en.md) for the earlier addition of 43 tests and 41 requirement rows. In the comparison part, the existing input and expected values are not changed, and the additional part is recorded as a new test. The requirement definitions are unchanged. The following records the progress and findings as of 2026-10-22.

<a id="前回の続行分の照合と検査コミット0e9cc29時点"></a>

## Previous continuation mapping and checks (as of commit 0e9cc29)

Compared strings, dynamic arrays, queues, enums, conversions, type/class constraints in tests of standard violations, and generated x/z propagation, shifts, and reductions, increasing the preceding 410 tests and 386 rows to 597 tests and 493 rows. Increase from the preceding state: 187 tests and 107 rows. The definition and the pass criteria for all 12,319 lines of the requirement have not been changed.

Scope-specific decisions for the 31 tests and 32 deferred mappings were recorded in [Review judgement table](../coverage/test-matching-reviews.json). Distinguish partial observations, expected-value/diagnostic issues, more specific citations, and compound-requirement cleanup. Check input hashes and evidence strings to detect stale assessments. This is not a count of fully reviewed files and does not contribute to the coverage numerator.

The following 7 tests were rerun on both simulators after making their citations more specific, without changing their stimuli or expected outputs. Each file is successful at least in one way, and no known mismatch or non-match is successful.

- `ch15/test_semaphore_multiple.sv`: 15.3.1–15.3.4。
- `ch6/test_enum_method_edge.sv`: Individual section of next/prev/num/name.
- `ch6/test_enum_methods_navigation.sv`: Individual section of an enumerative navigation name.
- `ch6/test_enum_methods_name_num.sv`: 6.19.5.5–6.19.5.6。
- `ch6/test_enum_explicit_cast_and_failed_dynamic_cast.sv`: 6.24.2。
- `ch7/test_dynamic_array_edge_cases.sv`: 7.5.1–7.5.3。
- `ch7/test_dynamic_array_corner.sv`: 7.5.1。

Because the citations changed after the full-suite run, earlier input hashes were not reused as successful evidence. Reruns of 7 tests were saved in `citation-refinement-icarus.json` and `citation-refinement-verilator.json`. The snapshot of the entire suite is not overwritten or synthesized by partial execution. There are currently 7 requirement rows using composite evidence. Only groups whose members all succeed in the same run are accepted.

Ran 74 management-tool tests, generated-artifact consistency checks, standard-material hash comparisons, and mapping-evidence consistency checks. Mechanical checks also confirmed no changes to the original stimuli or expected values.

<a id="2026-10-22の続行分プロセスイベント終了処理"></a>

## Continuation of 2026-10-22: processes, events, and termination

Increased from the previous 597 tests and 493 rows to 637 tests and 533 rows (an increase of 40 tests and 40 rows). There are 65 new mapping rationales. The review primarily covered event expressions, iff, fork start and completion, wait fork, disable, process states, sensitivity in always_comb, and final termination paths in Clause 9. It also checked #0 handling in 4.4.2.3, implicit termination through the DPI tests in Clause 35, and the VPI termination callbacks in Clause 36. For DPI / VPI, also read the related C files and checked actual calls and output.

This test input has not been changed. Compared input hashes and successful results from existing full-suite runs, increasing execution-verified requirements from 448 to 483 rows. Of 40 added rows, 5 lack complete successful-execution evidence and have design mappings only. We do not reread known mismatch/non-match to success, nor do we treat it as rerunning the simulator this time. The requirement definitions and acceptance criteria for all 12,319 rows, and the denominator identifier, are also unchanged.

The added collective evidence covers 5 requirements: disable fork for direct children and descendants of terminated intermediate parents, continuation from named blocks/tasks, termination of nested tasks/fork descendants, final after explicit/implicit termination, and wait conditions true initially or becoming true later. Requirements using collective evidence now total 12 rows. Success in only one subtest does not mean success in the entire row.

The recorded reasons for holding mappings now total 56 entries across 53 files (24 entries across 22 files added in this round). These counts represent judgments within a limited scope, not completed reviews of entire files. Identified new observation gaps in M07 and M08. In addition, we have kept some remaining cases with reasons, such as await which only waits for normal termination, kill which does not have a descendant, start/end without time observation, and sensitivity tests which lack specific child citation.

The 74 test of the management tool and the conformity check of the requirements compliance, specification document hash, product and metadata were carried out.

<a id="m01-isunbounded-に数値リテラルを渡す正常系テスト"></a>

## M01: a positive test passing a numeric literal to $isunbounded

Scope: [test_system_isunbounded.sv](../tests/ch20/test_system_isunbounded.sv)。

Requires return value zero from `$isunbounded(100)` as the normal expected result. The text of standard 20.6.3 and Syntax 20-8 (physical page 631 of the supplied PDF) restrict the argument to a parameter name. Therefore, the current expectation that an implementation that rejects this call will fail is inappropriate. Acceptance by existing simulators alone does not make this stimulus conform to the standard.

For positive tests, declare objects such as `localparam int FINITE = 100` and pass their names. To verify rejection of literal arguments, separate it from positive behavior into a standard-violation test. The current file is not approved as a match for 20.6.3. Test bodies and expected values are unchanged.

<a id="m02-宣言名前だけではその機能の検証にならない"></a>

## M02: declarations and names alone do not verify a feature

Example: [test_macro_concat.sv](../tests/ch22/test_macro_concat.sv) defines a double backquoted name association to `MAKE_NAME(base)`, but does not call it. The `STRINGIFY` results, declaration macros, and nested numeric macros are observed, but this name-concatenation definition alone must not be counted as verification of `MACRO-TOKEN-DELIMITER`.

Also, `STRINGIFY` and `CONCAT` of [test_macro_advanced.sv](../tests/ch22/test_macro_advanced.sv) are just definitions. Actual calls must observe access to constructed identifiers and expected expansion strings. This registration adds no mappings based on those unused definitions.

<a id="m03-複合要求と正常系規格違反の区分によりそのまま承認できない行"></a>

## M03: rows that cannot be approved as written because of composite requirements and positive/standard-violation classifications

This identifies remaining requirement-ledger splitting/cleanup, not the absence of tests. For example, `SV2023-22.8-EXTRACT-NETTYPE-DEFAULT-NONE` combines default implicit wire with prohibition of undeclared nets through `default_nettype none` in one row. Because of `kind: error`, positive cases observing implicit wire alone cannot justify a mapping to the whole row.

[test_resetall_default_nettype.sv](../tests/ch22/test_resetall_default_nettype.sv) includes an observation that, after reset, the implicit net functions as a wire with width 1. Preserve that verification value by splitting positive and standard-violation tests into independent requirement units before mapping. Splitting requirements would change the sources, denominator and baseline, so this matching work neither relaxed requirements nor excluded them from the denominator.

The observation in [test_semaphore_blocking_keys.sv](../tests/ch15/test_semaphore_blocking_keys.sv) that 2 keys can be obtained after `put(3)` from an initial 2 keys does not establish capacity beyond the initial value or that exactly 1 keys remain afterward. Even if the implementation truncates to 2 keys or consumes too many, both subsequent 2-key requests fail. Waiting/release observations have value, but are not mapped to whole requirements for preserving remaining keys or unlimited capacity.

<a id="m04-semaphoretry_get-の成功を正確な1に限定した期待値"></a>

## M04: an expected value that restricts successful semaphore.try_get results to exactly 1

Scope: [test_std_package_access.sv](../tests/ch26/test_std_package_access.sv) and its [Expected output](../tests/ch26/test_std_package_access.expected).

Print `s1.try_get()` unchanged, with expected output `semaphore: 1, std::semaphore: 0`. The standard's 15.3.4 (physical page 374–375 of the supplied PDF) defines a successful return value as a “positive integer,” without restricting it to exactly 1. For example, an implementation returning 2 on success conforms to the standard but fails the current test comparison.

Normalize the success judgment to `s1.try_get() > 0` and check 0 on failure. This file observes references to and shadowing of the standard package, but its mappings have not been approved in its current state because of this expectation problem. Test bodies and expected values are unchanged.

<a id="m05-stringcompare-の非ゼロ結果を正確な--1-に限定した期待出力"></a>

## M05: expected output that restricts nonzero string.compare results to exactly -1

Scope: [test_string_methods_extended.sv](../tests/ch6/test_string_methods_extended.sv) and its [Expected output](../tests/ch6/test_string_methods_extended.expected).

Display the actual comparison result between `"abc"` and `"abd"` and require `Test 7 PASS: compare=-1`. Standard 6.16.6 specifies negative/zero/positive according to ordering, without fixing the absolute nonzero value. For example, even a conforming implementation returning -2 would fail against the current expected output. In addition, the internal judgement is `!= 0`, so the incorrect size relationship of positive values is also passed in the internal judgement.

Use `< 0` for the internal check, and make successful output observe only the sign of the comparison result. Other string operations in this file also have verification value, but requirement-mapping approval remains pending with the current expected values. Test bodies and expected values are unchanged.

<a id="m06-規格違反テストの行番号一致だけでは意図した違反の検出を確認できない"></a>

## M06 : Only line number matching in the non-conformity test cannot confirm the detection of the intended non-conformity

For example, [test_illegal_interconnect_data_type.sv](../tests/ch6/test_illegal_interconnect_data_type.sv) and [test_illegal_ref_in_static_function.sv](../tests/ch13/test_illegal_ref_in_static_function.sv).

The current standard-violation runner can classify a case as `pass` when the error line matches `expected_stderr_regex`. Rechecking the actual diagnostics showed that the former produced a syntax error with Icarus 13.0, and `Unsupported: interconnect` plus a syntax error with Verilator 5.052. The latter Icarus diagnostic rejects `Reference ports not supported yet` and non-input function arguments; it does not establish the prohibition on ref arguments with static lifetime. Verilator accepts the latter.

These are not errors in the tests’ violation stimuli. The problem is that the runner’s `pass` alone cannot distinguish rejection for an unsupported feature from detection of a language violation. Need to verify that a legal form of the same feature is accepted and check the diagnostic content for the intended violation. `oracle` in both files is only `spec`; requirement coverage does not treat it as an approved standard-violation test oracle for the fixed version, and this incidental `pass` is not counted toward execution verification coverage. Also recorded reasons for deferred registration in the review-assessment ledger.

<a id="m07-判定対象を観測せずにpassを表示するシナリオ"></a>

## M07 : Scenario to display PASS without observing the judged object

Test5–7 in [test_edge_detection.sv](../tests/ch9/test_edge_detection.sv) displays fixed PASS after applying rising and falling edges to sig and a change to rst_n. Only clk is monitored; there is no event detector or detected-event count for sig/rst_n. The expected output of this 3 scenario matches without processing the target edge altogether. Provide monitors per target signal and check detection counts and nondetections for each stimulus.

`accum_block` in [test_disable_stmt_edge_cases.sv](../tests/ch9/test_disable_stmt_edge_cases.sv) likewise does not check the local sum; after the block, it assigns 10 to a different count and displays `[PASS] Disable with accum`. This output remains unchanged even if sum advances to 55. Check the final value of the sum directly. Other scenarios with value checks, such as preserve_block, are mapped as collective evidence.

[test_task_disable_2.sv](../tests/ch9/test_task_disable_2.sv) uses inputs that keep found and row/col at the same values without stopping the search. conditional_process is given only 50, so it does not exercise negative inputs that enter disable or inputs greater than 100. After a stop, the counters that should not change, the duplicate object values, and the inputs that enter the branch are required. The return observation in this file is not used as proof of disable.

<a id="m08-遅延を実行しても遅延時間や右辺の評価時点を検査していない"></a>

## M08: executes a delay without checking its duration or when the right-hand side is evaluated

[test_timing_edge_cases.sv](../tests/ch9/test_timing_edge_cases.sv) checks the result of a constant assignment after `#(delay_val)` or `data = #5 8'hAA`, but does not observe times before and after the target delay or observations from another process while it waits. An incorrect implementation that ignores the delay at this assignment can produce the same PASS output. Also, because the right-hand side is a constant, the rules that save the value before waiting cannot be checked.

Check elapsed time and state before/after updates; to verify right-hand-side capture, change it during the wait. Registered these valid observations separately: existing [test_assign_delay_edge_cases.sv](../tests/ch9/test_assign_delay_edge_cases.sv) checks elapsed time, while [test_intra_assignment_repeat_nonblocking.sv](../tests/ch9/test_intra_assignment_repeat_nonblocking.sv) observes updated values/times after changing the right-hand side and repeat count. The single negative-repeat example in the latter test was not treated as evidence for the entire boundary requirement, which also includes 0, x, and z.

<a id="登録の基準"></a>

## Criteria for registration

Compare generated tests against generator expressions/tables and each output file; register only requirements whose actual inputs, observation positions, and expected values are verified. The following errors are not automatically converted to success: Cells in the truth table that do not appear, differences in signedness that do not appear in the result, and type, width, and error conditions that cannot be verified by compilation success alone. The mapping rationale, input SHA-256, reviewer and date are retained in `coverage/behaviors.json`. This mapping was performed by AI and does not imply independent human verification.

For package imports in module/interface/program headers, grouped 3 tests as `check_groups`. Do not equate partial success with complete-requirement success; require all 3 tests to succeed in the same run.
