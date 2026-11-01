<a id="既存テストの要求照合制御文ループ2026-10-23"></a>

# Existing-test requirement mapping: control statements and loops (2026-10-23)

[English](existing-test-matching-control-flow-20261023.en.md) / [日本語](existing-test-matching-control-flow-20261023.md)

> Counts, percentages, and pending statuses in this document record their respective work dates.
> The current value is [Aggregated Summary](behavior-coverage-summary.en.md); the approval history for the denominator and interpretations is in
> See [Results of requirement extraction](requirement-extraction.en.md).

[Current coverage](behavior-coverage-summary.en.md) / [Comparison ledger for all tests](test-requirement-matching.en.md) / [Immediately preceding test additions](expression-gap-tests-20261023.en.md)

<a id="今回の進捗"></a>

## Progress in this round

Reviewed the relevant clauses of Chapter 12 and 9.3.5 in the supplied IEEE 1800-2023, comparing existing stimuli and expected output for conditionals, case statements, patterns, loops, jumps, and statement labels. Related function-return observations in 13.4.1 are also mapped.

- Tests with a registered mapping to at least one requirement: increased from 762 to 813 (added 51 of the 3,923 total tests).
- Mapped requirements: 672 → 698 rows (26 added). The new match base is 72.
- Execution-verified requirements: 606 → 624 rows (18 added).
- Provisional requirement coverage (test design): 5.67% (698/12,319).
- The provisional execution confirmation rate is 5.07% ( 624/12,319 ).
- Finalized values: both design and execution remain unfinalized. Denominator approval, deduplication, and pending interpretations remain outstanding.
- Tests without even one registered mapping: 3,110. Mappings based on verification content for every case remain incomplete.

Registered-test counts mean tests with at least one observation mapped to a requirement, not completion of all observations/requirements across 813 tests. Comparison was performed by AI; it has not been independently checked by a human.

Test inputs, expected values, citations, runners, and requirement definitions are unchanged. Preserved definitions of 12,319 requirement rows, existing mapping rationale, collective evidence, hold decisions, and the denominator identifier. Previously uncommitted changes are retained too.

<a id="採用した観測と集合証拠"></a>

## Accepted observations and set-level evidence

[test_case_exact_xz_match.sv](../tests/ch12/test_case_exact_xz_match.sv) checks that the same X/Z bits match in ordinary case and that the value with X does not match a known different value. The form using variables as both controller and items is also observed.

[test_comb_foreach_3d_break.sv](../tests/ch12/test_comb_foreach_3d_break.sv) breaks at k = 2 on the first row of the 3-dimensional foreach, leaving only the total 1. Exiting only the inner dimension adds subsequent rows/planes, making it distinguishable from exiting the whole foreach. The first position [1][2] containing value 3 also differs from [2][1] with the dimension order reversed, so it was also used as evidence of traversal order.

Used controls where while executes 0 times with an initially false condition and do-while executes 1 times under the same condition. Use sums/counts and termination to verify that continue skips the rest of the body, executes the for step, and advances to the next iteration. An extra FAIL line at the end also fails because output comparison requires an exact match.

Added new set-level evidence for the following 3 requirements. Requirements with set-level evidence total 21 rows. Require every member of a group to succeed in the same run.

- casez/casex differences: tests of selector/item X/Z wildcards, plus a control showing casez does not treat X as a wildcard. Saved `icarus.json` all successful in the same run.
- The form of return: functions that return values, bare return of tasks that skip subsequent changes, and bare return of void functions. `ch13/test_return_stmt.sv` and `ch13/test_stmt_return_2.sv` succeeded in the same `verilator.json` run.
- Jump syntax: return expression / bare return combined with break / continue. `ch13/test_return_stmt.sv` and `ch12/test_control_flow_2.sv` are successful in both full suite runs.

For 8 pattern requirements, registered structure, tagged-union, constant, wildcard, binding, and filter observations as design mappings; absent usable recorded passes, they do not count toward execution verification.

Simulators were not rerun. Retained the saved Icarus 13.0 / Verilator 5.052 results for all 3,912 tests and separate execution results for tests subsequently added or given citation changes, and checked them against the current input hashes. We do not treat partial execution as a rerun of all 3,923 tests, nor do we synthesize partial success of different executions as a set of proofs. Also corrected the cumulative-review entry's mistaken claim of rerunning all 3,923 tests to reflect the actual execution scope.

<a id="m232値のintでselectorのxzが失われる"></a>

## M23: 2-state int loses selector X/Z

For example: [test_control_flow.sv](../tests/ch12/test_control_flow.sv), [test_control_flow_4.sv](../tests/ch12/test_control_flow_4.sv), [test_stmt_ext.sv](../tests/ch12/test_stmt_ext.sv).

The test assigns X/Z literals to int before case comparison, so the controller no longer contains X/Z. Item-side ?/X wildcard observations have verification value and were mapped to the appropriate rules, but do not establish selector-side X/Z handling. For the latter, used a test preserving logic.

The display “casez handles X as wildcard match” in [test_x_z_propagation.sv](../tests/ch11/test_x_z_propagation.sv) is also an incorrect description of the rule. In fact, 01 does not match selector x1, and ? 1 hides its position in the Z on the item side, so result = 2. This is a check case that casez does not make X a wildcard in the selector. The display and expected values have not been changed.

<a id="m24全要素の和と対称なcontinue条件では順序を区別できない"></a>

## M24: summing all elements and using a symmetric continue condition cannot distinguish traversal order

Totals/visit counts over all elements, such as [test_ct_foreach_nd.sv](../tests/ch12/test_ct_foreach_nd.sv), and final arrays set from indices remain identical even if dimension nesting order is reversed. For traversal-order evidence, used the dedicated test above whose early-exit position changes.

The T2 test for this is also worth noting. Since continue has only j == 1, it always excludes all k of the j. Correct continue per tuple and incorrectly skipping all remaining k values produce the same total 484. This case is not mapped to the complete foreach continue-boundary requirement.

The final break in [test_foreach_loop_2.sv](../tests/ch12/test_foreach_loop_2.sv) is also checked only through sum \>= 6. If you ignore break and process the sum of all elements to 15, it will pass.

<a id="m25uniquepriorityの分岐結果だけでは違反報告を確認できない"></a>

## M25: The violation report cannot be verified by the branch result of unique/priority alone.

For example, [test_unique_case_edge_cases.sv](../tests/ch12/test_unique_case_edge_cases.sv), [test_unique_priority_unique0_basic.sv](../tests/ch12/test_unique_priority_unique0_basic.sv).

Checking post-branch values does not establish capture of multiple-match or no-default/no-match violation reports. An unchanged variable on no-match in unique0 does not distinguish the presence of unnecessary warnings. Treat value comparison, presence/absence of reporting, and report timing as separate observations.

Pure-comparison conditions in else-if / priority-if also produce identical output even if later conditions are unnecessarily evaluated after the first true condition. Registered the rule allowing chained syntax, leaving complete evaluation-order / search-termination requirements pending.

<a id="m26repeat回数の入力が変わらない"></a>

## M26: repeat-count input remains unchanged

For example: [test_repeat_loop.sv](../tests/ch12/test_repeat_loop.sv), [test_statement_repeat.sv](../tests/ch12/test_statement_repeat.sv), [test_repeat_loop_3.sv](../tests/ch12/test_repeat_loop_3.sv).

The tests do not change repeat(count) or repeat(count*2) inputs within the body or observe count-function call counts. An incorrect implementation reevaluating the same value each time gives identical output, so this does not establish evaluation only once at the start. A repeat(0)-only boundary check does not approve the whole requirement row including negative/X/Z counts.

<a id="m27未観測の制御変数省略形寿命"></a>

## M27: unobserved control variables, omitted forms, and lifetimes

Multiple init of [test_for_loop_adv_edge_cases.sv](../tests/ch12/test_for_loop_adv_edge_cases.sv) does not read j with body only counter++. This passes even when j's initialization/step are ignored. [test_for_loop_3.sv](../tests/ch12/test_for_loop_3.sv) uses i+j and i\<j, providing valid observations for both variables, but the row's function-call step remains unverified. Compound rows with omitted init/test/step also remain pending.

[test_foreach_index_shadows_outer.sv](../tests/ch12/test_foreach_index_shadows_outer.sv) external variable invariance is a strong observation of scope, but it does not verify the automatic storage separation in simultaneous activation or the form of naming the implicit scope in label. Despite strings in its name, [test_array_loops_and_strings.sv](../tests/ch7/test_array_loops_and_strings.sv) also uses foreach only on fixed arrays and does not traverse a string.

<a id="m28case-insideとパターンの特殊条件"></a>

## M28: Special conditions for case inside and pattern.

The known constant set in [test_case_inside.sv](../tests/ch12/test_case_inside.sv) gives the same result under ordinary case. This does not verify asymmetric wildcards, inside nonmatches returning X, or controller/item evaluation counts and ordering.

There are valid observations for pattern binding and filter success/failure, but there are no observations for the knowledge of results including X/Z, short circuits after failed && &section, scope leaks to false branches, and ambiguous Boolean filters. Registered in-case binding/filter observations without claiming coverage of their separate requirements.

<a id="保留判断と検査"></a>

## Hold decisions and checks

Added 38 tests and 47 mappings to [Review judgement table](../coverage/test-matching-reviews.json), bringing the totals to 194 tests and 214 mappings. This is a number of scope-limited decisions, not a number of completed reviews of the entire file, and is not added to the coverage.

Checked management-tool 74 tests, standard-material hashes, consistency of mapping/execution evidence, and generated-artifact/metadata consistency.
