<a id="既存テストの要求照合式幅符号算術2026-10-23"></a>

# The test is based on the existing test requirements: formula, width, signedness, arithmetic (2026-10-23).

[English](existing-test-matching-expressions-20261023.en.md) / [日本語](existing-test-matching-expressions-20261023.md)

> Counts, percentages, and pending statuses in this document record their respective work dates.
> The current value is [Aggregated Summary](behavior-coverage-summary.en.md); the approval history for the denominator and interpretations is in
> See [Results of requirement extraction](requirement-extraction.en.md).

[Current coverage](behavior-coverage-summary.en.md) / [Comparison ledger for all tests](test-requirement-matching.en.md) / [Immediately preceding subroutine mapping](existing-test-matching-subroutines-20261023.en.md)

This document records expression mapping at 751 tests and 643 requirement rows. See subsequent [Adding tests for missing observations](expression-gap-tests-20261023.en.md).

<a id="今回の進捗"></a>

## Progress in this round

Compared the text of 11.3.1–11.3.6, 11.4.3, 11.4.3.1, 11.4.10, and 11.6–11.8.4 in the supplied IEEE 1800-2023 against the existing stimuli and expected output. The observations that can distinguish the width, value and side effects of the formula are registered, not the existence of names or declarations.

- Tests with registered mappings: increased from 722 to 751 (added 29 of the 3,912 total tests).
- Mapped requirements: 601 → 643 rows (42 added). The new match base is 84.
- Execution-verified requirements: 536 → 577 rows (41 added).
- Provisional requirement coverage (test design): 5.22% (643/12,319). The provisional execution confirmation rate is 4.68% ( 577/12,319 ).
- Finalized values: both design and execution remain unfinalized. Requirement-unit cleanup, pending interpretations, and denominator approval remain.
- Tests without even one registered mapping: 3,161. Mappings based on verification content for every case remain incomplete.

Registered-test counts mean tests with at least one observation mapped to a requirement. This does not mean all observations/requirements across 751 tests are fully reviewed. Comparison by AI does not mean independent human verification.

Test inputs, expected values, citations, requirement definitions, and runners are unchanged. Verified preservation of 12,319 requirement-row definitions, existing mapping/set evidence, and the denominator identifier. Previously uncommitted changes are retained too.

<a id="採用した観測と実行証跡"></a>

## The observation and the practical evidence used.

[test_propagated_operand_sign.sv](../tests/ch11/test_propagated_operand_sign.sv) assigns the sum of signed and unsigned 8bit operands to 16bit and checks 510. Compare the same operation using destinations with different signs to distinguish incorrectly deriving operation signedness from the destination. Also registered the result 4294967296 of receiving the sum of 32bit unsigned and int into 64bit, along with a signed-cast control case.

[test_assignment_extension_steps.sv](../tests/ch11/test_assignment_extension_steps.sv) assigns signed values, unsigned values, $unsigned, and mixed-sign addition to the same 8bit unsigned destination. Distinct bit strings verify that sign/zero extension follows the right-hand-side type. [test_signed_extend_xz_sign_bit.sv](../tests/ch11/test_signed_extend_xz_sign_bit.sv) directly displays X/Z sign-bit extension into wider signed values and all-X results from signed addition.

The product FE01 of two 8bit FF operands in [test_multiplier_edge_cases.sv](../tests/ch11/test_multiplier_edge_cases.sv), and the product 0100 of two 8bit 10 operands in [test_expression_width.sv](../tests/ch11/test_expression_width.sv), lose upper bits unless the 16bit assignment context is applied before the operation. Also read the stimuli and outputs of all cases in the generated carry_03 / 07/08, and mapped them to the rule that propagates the wider context to the addition in `(a+b)>>1`.

[test_two_state_operations.sv](../tests/ch11/test_two_state_operations.sv) checks that the division-by-zero expression itself produces X even when both int operands have 2 values, and that subsequent assignment to int converts it to 0. The expression's $isunknown and separate assignment results for int / integer are distinguished.

For exponentiation with negative exponents, divided bases into 0, 1, -1, and positive/negative values of magnitude at least 2; also registered odd/even exponents for -1, zero exponents, and positive exponents only against requirement rows with corresponding observations. For the requirement covering both signedness and width, used collective evidence from [test_power_signed_base.sv](../tests/ch11/test_power_signed_base.sv), which has a signed-base control case, and [test_arithmetic_wider_than_64_bits.sv](../tests/ch11/test_arithmetic_wider_than_64_bits.sv), whose 96bit result preserves bit 70. Under the requirement that both succeed in the same run, each saved full-suite result on Icarus 13.0 and Verilator 5.052 satisfies it. Requirements with set-level evidence total 18 rows.

Inputs are unchanged, so compare saved execution results against current input hashes. This does not report simulator reruns in this work. No snapshots are combined, partial runs do not overwrite full-suite results, and known disagreements do not count as successes. Of the 42 newly mapped rows, the 1 requirement rows summarizing 1bit results for real logical, relational, and inside operations have no usable recorded pass results in [test_real_operand_result_types.sv](../tests/ch11/test_real_operand_result_types.sv), so they have design mappings only.

<a id="m18優先順位や結合順を取り違えても同じ結果となる入力"></a>

## M18: inputs giving identical results even with incorrect precedence or associativity

`0 || 1 && 1` in [test_operator_precedence.sv](../tests/ch11/test_operator_precedence.sv) still yields 1 when interpreted as `(0 || 1) && 1`. The adjacent parenthesized test yields the same value too, so it passes even if && and || precedence is reversed. Values whose results differ between interpretations, such as `1 || 0 && 0`, are needed.

`-3 * 2` also evaluates to -6 for both `(-3)*2` and `-(3*2)`, so it cannot distinguish unary-minus precedence. The expression labeled “Bitwise before comparison” is `(a & b) == 0`, whose parentheses specify the order. The standard's table gives comparison higher precedence than bitwise &; this display is not evidence of the general precedence rule.

`a+b+5` in [test_expression_precedence_basic.sv](../tests/ch11/test_expression_precedence_basic.sv) also gives the same result under either association because addition is associative. Observations of left association yielding 2 with `20/4/2`, or parentheses placing addition before multiplication, have verification value. These tests alone do not approve right associativity of conditional/implication/equivalence operators or equal-precedence conditions across the full table.

<a id="m19代入後の下位値だけでは中間の演算幅を確認できない"></a>

## M19: lower bits after assignment cannot establish the intermediate expression width

Test 2 in [test_expression_width.sv](../tests/ch11/test_expression_width.sv) checks 0100 using `a16 = a8 + 1`. However, the unsized integer 1 is at least 32bit, so this value arises even without width propagation from 16bit LHS. For evidence of the LHS context, used Test 3, which assigns the product of two 8bit operands to 16bit.

The final narrow values of [test_minimal_width_ops.sv](../tests/ch11/test_minimal_width_ops.sv), [test_arithmetic_overflow.sv](../tests/ch11/test_arithmetic_overflow.sv), [test_overflow_arith.sv](../tests/ch11/test_overflow_arith.sv), and [test_add_expr.sv](../tests/ch11/test_add_expr.sv) can sometimes agree even if intermediate calculations use a wider width and are truncated only at the end. Distinguish checking arithmetic results from checking the actual width of self-determined expressions.

In carry_01 / 02/04/05/06, LHS is narrower than the original operand, so even shifting the most significant carry produced at the maximum width right by 1bit leaves it outside the displayed range. This observation alone was not treated as evidence that a carry at the maximum width is retained or lost; priority was given to carry_03/07/08, where LHS is wider and the intermediate-width difference affects the output. The detailed comparison of each subvalue of the former with other computational requirements is a remaining task.

<a id="m20signedunsignedの値と返却幅の検査の違い"></a>

## M20: Difference between the value of $signed / $unsigned and the return width check

For example: [test_system_signed.sv](../tests/ch11/test_system_signed.sv), [test_cast_unsigned.sv](../tests/ch11/test_cast_unsigned.sv), [test_signed_unsign.sv](../tests/ch11/test_signed_unsign.sv).

These help check converted-sign values and extension but do not distinguish the return expression's own width with $bits or concatenation. Some $unsigned examples assigned to the same width agree even with a simple identity operation. An incorrectly changed return width may also be concealed by subsequent sign extension/truncation yielding the same value. Left the entire 11.7 requirement to return a packed-state value with the same bit count as the input pending.

<a id="m21名前だけのサイズcastと自己反転しても変わらない最小値"></a>

## M21: Size cast only by name and minimum value that does not change with self-inversion

Despite its name/heading Size Casting, [test_size_cast.sv](../tests/ch11/test_size_cast.sv) does not use size-cast `N'(expr)`. Part-select and concatenation results alone do not verify a cast's intermediate size context.

Unary minus on the minimum 8bit value -128 in [test_signed_overflow.sv](../tests/ch11/test_signed_overflow.sv) wraps back to -128 at the same width. This input alone passes even if negation is omitted. Registered addition-overflow observations; for unary-minus requirements, used a separate test observing 5 becoming FB.

<a id="m22複合要求の一部だけを観測する場合"></a>

## M22: When only part of the complex demand is observed.

[test_real_operand_result_types.sv](../tests/ch11/test_real_operand_result_types.sv) directly checks width 32 of shortreal + int, but has no example showing that shortreal, when used only as the condition, does not promote the type. The real-condition example uses real type. The complete shortreal row, including the condition-operand exception, remains pending.

[test_short_circuit_side_effects.sv](../tests/ch11/test_short_circuit_side_effects.sv) verifies absence of side effects under short-circuiting and retention of required side effects under bitwise operations. However, the evaluation does not stimulate the operand that results in an error at execution, so it is not a proof of the entire acceptance condition including error suppression.

<a id="保留判断と検査"></a>

## Hold decisions and checks

Added 35 entries across 32 files to [Review judgement table](../coverage/test-matching-reviews.json), bringing the totals to 167 entries across 156 files. This is a number of scope-limited decisions, not a number of completed reviews of the entire file, and is not added to the coverage.

The 74 test of the management tool, the hash of the specification document, the consistency of the corresponding basis and the proof of execution, and the consistency of the product and the metadata were checked.
