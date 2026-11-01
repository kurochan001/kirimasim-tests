<a id="式のレビューで不足していた観測へのテスト追加2026-10-23"></a>

# Adding tests for observations missing from the expression review (2026-10-23)

[English](expression-gap-tests-20261023.en.md) / [日本語](expression-gap-tests-20261023.md)

> Counts, percentages, and pending statuses in this document record their respective work dates.
> The current value is [Aggregated Summary](behavior-coverage-summary.en.md); the approval history for the denominator and interpretations is in
> See [Results of requirement extraction](requirement-extraction.en.md).

[Original review and M18 – M22](existing-test-matching-expressions-20261023.en.md) / [Current coverage](behavior-coverage-summary.en.md)

This document records the state immediately after adding 11 tests: 762 tests and 672 requirement rows. See subsequent [Control statement and loop matching results](existing-test-matching-control-flow-20261023.en.md).

<a id="追加した内容"></a>

## Additions

Added 11 tests with expected outputs derived from the standard where the review found insufficient discriminatory power. Existing test stimuli and expected values are unchanged.

- M18: inputs whose values change if precedence or associativity is wrong. [test_precedence_distinguishing_values.sv](../tests/ch11/test_precedence_distinguishing_values.sv) compares logical, unary/addition, comparison/bitwise, arithmetic, conditional, and implication/equivalence expressions with differently parenthesized versions. For example, `1 || 0 && 0` is 1, and `(1 || 0) && 0` is 0.
- M19: The width of the formula itself is not hidden in the value after assignment. [test_self_determined_operator_widths.sv](../tests/ch11/test_self_determined_operator_widths.sv) checks binary 10 and unary 3 operations using $bits, distinguishing addition inside concatenations from addition in 64bit context. [test_logical_reduction_expression_widths.sv](../tests/ch11/test_logical_reduction_expression_widths.sv) uses inputs whose truth value changes if the operands are incorrectly narrowed to the 1bit result width.
- M19: width exceptions for shifts, exponentiation, concatenation, conditionals, and comparisons. [test_shift_power_self_determined_count.sv](../tests/ch11/test_shift_power_self_determined_count.sv) distinguishes the left operand of 4bit, the right operand of 64bit, and signed negative exponents / shift amounts. [test_concat_replication_conditional_widths.sv](../tests/ch11/test_concat_replication_conditional_widths.sv) checks concatenation/replication widths, self-determined items, condition/branch widths, and unsigned selections from signed source values. [test_comparison_operand_context_width.sv](../tests/ch11/test_comparison_operand_context_width.sv) distinguishes the common comparison width, the 1bit result, and the rule that the enclosing 64bit assignment context does not propagate into comparison operands.
- M20: actual forms and signs of values returned by $signed / $unsigned. [test_signed_system_cast_shape_and_value.sv](../tests/ch11/test_signed_system_cast_shape_and_value.sv) separately observes the width of 8bit / 65bit, the single packed dimension and range, the bit sequence, signedness, and extension.
- M21: Intermediate context by actual size specified cast. [test_size_cast_intermediate_context.sv](../tests/ch6/test_size_cast_intermediate_context.sv) checks that the sum of identical 8bit operands is 0100 in a 16bit context, but 0000 with an intermediate 8bit cast. Checks also include truncation, extension, signedness preservation and packed ranges.
- M22: shortreal promotion and the condition-operand exception. [test_shortreal_result_and_condition_types.sv](../tests/ch11/test_shortreal_result_and_condition_types.sv) distinguishes 32bit for shortreal from 64bit for real. When using shortreal only as a condition, use the 4bit branch, which detects erroneous promotion to 32bit shortreal.
- M22: suppression of side effects and runtime errors through short-circuiting. [test_short_circuit_suppresses_fatal_operand.sv](../tests/ch11/test_short_circuit_suppresses_fatal_operand.sv) places a function that increments a counter and executes $fatal when evaluated in &&, ||, -\>, and unselected conditional branches. The expected result is to continue to the end and output the number of calls 0.
- M22: real 1bit results independent of shortreal support. [test_real_boolean_results_without_shortreal.sv](../tests/ch11/test_real_boolean_results_without_shortreal.sv) checks the widths and values of logical, relational and inside expressions on real operands.

M18‐M22 is an addition to fill in the missing observations, and does not mean that the test addition of all functions of the standard is completed. The operators and combinations in the priority table are not treated as having been encompassed, nor are the remaining complex requirements.

<a id="規格との対応と割合"></a>

## Standard mappings and percentages

Added 34 mapping rationales. The identifier of the row and the denominator of the requirement definition 12,319 has not been changed.

- All tests: 3,912 → 3,923.
- Tests with at least one registered requirement mapping: 751 → 762. 3,161 tests remain unregistered.
- Mapped requirements: 643 → 672 rows (29 added).
- Execution-verified requirements: 577 → 606 rows (29 added).
- The provisional requirements coverage (test design): 5.22% to 5.45% (672/12,319).
- The provisional execution confirmation rate is 4.68% to 4.92% ( 606/12,319 ).
- Finalized values: both design and execution remain unfinalized. Denominator approval, deduplication, and pending interpretations remain outstanding.

Of the 29 newly mapped rows, 28 have recorded passing results; the 1 rows for shortreal have design mappings only. The 1 rows for real 1bit results, previously supported only by test design, now also have execution evidence from newly separated tests, bringing the total increase in execution-confirmed rows to 29. The registered test count does not mean that every observation and requirement in each file has been reviewed. Comparison against the standard was performed by AI, not independently verified by a human.

<a id="実行結果とシミュレータ差"></a>

## Execution results and simulator differences

Ran the 11 updated tests with fixed versions Icarus 13.0 and Verilator 5.052. Verilator is verified with both the initial seed 1 and 73.

- Icarus 13.0: 6 tests passed; 5 were known mismatches that could not compile.
- Verilator 5.052: both seeds 10 successful, 1 known inconsistent.
- At least one of them succeeded: 10 tests. The 1 tests in shortreal differ on both tools; retain standard-derived expected values.

Icarus stops the compiler in an array query to a cast expression, and in a short-circuit test executes $fatal of a non-selective function. We also confirmed that temporary reference examples without the query part can be compiled. For the expression width of shortreal, Icarus uses 1bit and Verilator uses 64bit; neither is registered as an oracle. These differences have been added to [Simulator-difference records](simulator-differences.md#cases-added-after-the-2026-10-23-expression-review).

The runtime input SHA-256 and the result including the runner hash, version and seed are saved below.

- [expression-gaps-20261023-icarus13.json](../coverage/results/expression-gaps-20261023-icarus13.json)
- [expression-gaps-20261023-verilator-seed1.json](../coverage/results/expression-gaps-20261023-verilator-seed1.json)
- [expression-gaps-20261023-verilator-seed73.json](../coverage/results/expression-gaps-20261023-verilator-seed73.json)

Partial runs were neither combined with nor used to overwrite the earlier full results for all 3,912 tests. Only measured pass results matching the current inputs count as success; known results and compilation failures are not converted to successes.

<a id="判別力と管理ファイルの検査"></a>

## Checks of discriminatory power and management files

19 kinds of incorrect behavior were injected into temporary files, and it was confirmed that after the code was compiled after the changes, all comparisons with the original expected results failed.

- Incorrect precedence/associativity: 9 types.
- 7 fault types: removing self-determined boundaries, narrowing logical operands / shift amounts / conditions, incorrectly signing shift results, leaking context into concatenation items, and leaking enclosing context into comparisons.
- Widening a system cast, widening a size cast’s intermediate result, and forcing evaluation of a short-circuited branch: 3 kinds.

The first 16 kinds were checked with Icarus 13.0, and the remaining 3 kinds with Verilator 5.052. The temporary variation is not added to the normal test, nor is the original test or the expected output changed. This checks discrimination against representative faults; it does not guarantee detection of every incorrect implementation.

Checks covered 74 tests of the management tools, standard-document hashes, consistency of inputs/mapping rationales/execution evidence, and consistency of the catalog/statistics/depth/generated files/metadata. Retain existing requirement definitions, mapping evidence, set evidence, pending assessments, and previously uncommitted changes.
