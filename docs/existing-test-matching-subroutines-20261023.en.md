<a id="既存テストの要求照合サブルーチン2026-10-23"></a>

# Existing-test requirement mapping: subroutines (2026-10-23)

[English](existing-test-matching-subroutines-20261023.en.md) / [日本語](existing-test-matching-subroutines-20261023.md)

> Counts, percentages, and pending statuses in this document record their respective work dates.
> The current value is [Aggregated Summary](behavior-coverage-summary.en.md); the approval history for the denominator and interpretations is in
> See [Results of requirement extraction](requirement-extraction.en.md).

[Current coverage](behavior-coverage-summary.en.md) / [Comparison ledger for all tests](test-requirement-matching.en.md) / [Comparison of the immediately preceding assignment system](existing-test-matching-review-20261023.en.md)

This document records subroutine matching at the milestone of 722 tests and 601 requirement rows. See subsequent [Continued expression and arithmetic results](existing-test-matching-expressions-20261023.en.md).

<a id="今回の進捗"></a>

## Progress in this round

Compared the supplied IEEE 1800-2023 text against existing stimuli and expected results, focusing on Chapter 13 arguments, copy timing, lifetimes, defaults, named arguments, constant functions, forward references, and parameterized subroutines. The observations of related 4.9.7, 6.21, and 8.6 are also supported.

- Registered bindings: Increased from 680 to 722 tests (42 added out of 3,912 total).
- Mapped requirements: 574 → 601 rows (27 added). The new match base is 59.
- Execution-verified requirements: 509 → 536 rows (27 added). All 27 added rows have usable recorded pass results.
- Provisional requirement coverage (test design): 4.88% (601/12,319). The provisional execution confirmation rate is 4.35% ( 536/12,319 ).
- Finalized values: both design and execution remain unfinalized. Requirement-unit cleanup, pending interpretations, and denominator approval remain.
- Tests without a registered mapping to even one requirement: 3,190. Mappings based on verification content for every case remain incomplete.

The registered count includes tests with at least one mapped observation. It does not mean that every observation and requirement in all 722 tests has been fully reviewed. Comparison by AI does not mean independent human verification.

<a id="有効な観測と集合証拠"></a>

## Valid observations and set-level evidence

[test_sched_subroutine_copy_out.sv](../tests/ch4/test_sched_subroutine_copy_out.sv) compare output/inout /ref during delay. An output actual retains old value 1 during the call; a ref actual changes to 33 before return. For inout, 12, calculated from 2 at call time, is copied out on return even if the actual argument is externally changed to 100. This checks copy timing and differences from ref more directly than observing only final post-return values.

[test_array_args_by_value_ref.sv](../tests/ch7/test_array_args_by_value_ref.sv) checks that modifying fixed-array, dynamic-array, queue, or associative-array formals passed by value preserves the original array's values and size. Separately observe values changed inside the function and values retained by the caller.

We also registered that the static formal is shared in the simultaneous call, and the automatic formal is separated, that the automatic local/output is initialized and the static local/output is maintained, and that the default is evaluated in the declaration side scope every time even if there is a variable with the same name on the call side. Also checked suppression of ordinary $display during constant evaluation versus runtime display, forward-reference resolution, and static-method results with varied types/widths.

Added set-level evidence for 4 requirements covering ANSI/body-form task declarations, automatic local/formal initialization, static local/formal retention, and reordered named arguments / omitted defaults. Requirements with set-level evidence total 17 rows. Each group must be successful in the same run.

<a id="引用を具体化した4本と再実行"></a>

## 4 tests with more specific citations and reruns

The stimulus, expectation, and demand definitions remain unchanged, and only the following `:lrm:` quotation is added.

- `ch13/test_static_task_shared_activation.sv`：13.3.1。
- `ch13/test_task_output_formal_initial_value.sv`：13.3.2。
- `ch4/test_sched_subroutine_copy_out.sv`：13.5。
- `ch7/test_array_args_by_value_ref.sv`：13.5.1。

Ran Icarus 13.0 and Verilator 5.052 with updated inputs. Icarus has 2 passes and 2 known mismatches; Verilator has 3 passes and 1 known mismatches; all 4 tests have a recorded pass for the current input with at least one of them. Known inconsistencies are not included in success.

The results of the execution were saved in `coverage/results/subroutine-citation-refinement-20261023-icarus13.json` and `coverage/results/subroutine-citation-refinement-20261023-verilator.json`. The initial results from the Icarus 14.0 development version in the default environment are also retained separately as `subroutine-citation-refinement-20261023-icarus.json`, with the actual version recorded. For set-level evidence of automatic local/output initialization, grouped the required 2 tests into one run on Icarus 13.0 and used `subroutine-initialization-group-20261023-icarus13.json`, in which all 2 tests succeeded. Existing full-suite evidence was neither overwritten nor combined with partial runs. The test that is not changed this time compares the saved execution result with the current input hash.

<a id="m13復帰後のrefの値だけでは即時共有を確認できない"></a>

## M13: the ref value after return alone cannot establish immediate sharing

For example: [test_ref_arg.sv](../tests/ch13/test_ref_arg.sv), [test_task_ref.sv](../tests/ch13/test_task_ref.sv), [test_ref_arg_edge_cases.sv](../tests/ch13/test_ref_arg_edge_cases.sv).

These check increment, swap, and array-update results, but observations occur only after return. An incorrect implementation treating ref as inout copy-in/copy-out gives the same result. Observations during the call, updates between actual and formal, or observations of aliases that pass the same variable to multiple refs are required. Registered dedicated tests where another process reads the actual before return for immediate-visibility / shared-reference requirements.

The object operation of [test_ref_const_ref_detailed.sv](../tests/ch13/test_ref_const_ref_detailed.sv) is also only a change of `obj.value`, not a change of the handle itself. Copying a handle still shares object contents, so this does not verify ref updates to the actual handle. Event triggering must also be distinguished from passing an event by value while referring to the same synchronization object.

<a id="m14明示actualでdefaultを上書きしても未使用式の非評価は証明できない"></a>

## M14: overriding a default with an explicit actual does not prove that the unused expression is not evaluated

For example, [test_default_argument_declaring_scope.sv](../tests/ch13/test_default_argument_declaring_scope.sv), [test_default_value_expressions.sv](../tests/ch13/test_default_value_expressions.sv).

Explicit actuals confirm that the default value is not used, but the default expression has no observable side effects. The output is not affected by the extra evaluation of the unused equation. Use a default function with observable side effects, such as an evaluation counter, and check those effects both with the actual omitted and explicitly supplied. The valid observations of default declarations and the re-evaluation of declaration-side scopes are registered in a separate requirement.

<a id="m15宣言順の加算だけでは名前付き引数の対応を確認しにくい"></a>

## M15: addition in declaration order poorly distinguishes named-argument binding

[test_function_call_patterns.sv](../tests/ch13/test_function_call_patterns.sv) checks 30 with `add(.a(10), .b(20))`. Addition gives the same result whether arguments are passed positionally in declaration order or a/b are swapped.

`divide(.b(3), .a(10), .remainder(rem))` in [test_function_corner.sv](../tests/ch13/test_function_corner.sv) is passed in a different order from the declaration, and the quotient 3 is checked, distinguishing it from positional interpretation. The mapping combines this with another test that omits a default input in a named task call.

<a id="m16ファイル名と実際に宣言したサブルーチンの寿命種類の違い"></a>

## M16: differences between the filename and the lifetime and kind of subroutine actually declared

- [test_auto_task.sv](../tests/ch13/test_auto_task.sv) has no tasks, only functions. factorial also uses a loop, not recursion.
- [test_task_recursion.sv](../tests/ch13/test_task_recursion.sv) is also a function. Do not count recursive-function calculations as nested tasks.
- [test_func_static.sv](../tests/ch13/test_func_static.sv) and [test_task_static.sv](../tests/ch13/test_task_static.sv) are subroutine-automatic and local-explicit static.

The final 2 tests verify a local static override and were registered under 6.21. This is distinguished from the established rule where the unspecified subroutine is static and the reverse proof of automatic local within the static subroutine.

<a id="m17未呼び出しの戻り値型と元変数を持たない値渡しの確認"></a>

## M17: Verification of return type without call and pass without parent variable

[test_func_return_2.sv](../tests/ch13/test_func_return_2.sv) declares functions returning shortint / byte / enum, but neither calls them nor checks their values. Observe 5 types: int, 16bit unsigned, real, 32bit logic, and string. Not all declared categories are operationally verified.

`modify_arg(5)` in [test_func_scope.sv](../tests/ch13/test_func_scope.sv) passes literals, so it cannot observe whether formal changes fail to propagate to original variables. The module_var invariant check for the same file is a check of a variable other than actual. Verifying value-copy isolation requires checking the original variable or array before and after the operation.

<a id="保留理由と検査"></a>

## Reasons for deferral and checks

This round added scope-specific decisions for 34 tests and 38 cases, bringing [Review judgement table](../coverage/test-matching-reviews.json) to a cumulative 124 tests and 132 cases. This is not a total number of completed revisions of the file, nor is it added to the coverage. Retain reasons for insufficient in-call observations, unused definitions, partial compound requirements, and insufficient citations.

The identifier of the row and the denominator of the requirement definition 12,319 has not been changed. Check management-tool 74 tests, standard-material hashes, mapping/execution-evidence consistency, and generated-artifact/metadata consistency.
