<a id="附属書ヘッダvpiテストの追加と既存テストの照合2026-10-23"></a>

# Adding annex-header / VPI tests and mapping existing tests (2026-10-23)

[English](header-vpi-tests-and-matching-20261023.en.md) / [日本語](header-vpi-tests-and-matching-20261023.md)

> Counts, percentages, and pending statuses in this document record their respective work dates.
> The current value is [Aggregated Summary](behavior-coverage-summary.en.md); the approval history for the denominator and interpretations is in
> See [Results of requirement extraction](requirement-extraction.en.md).

[Current aggregates](behavior-coverage-summary.en.md) / [Mapping registry](test-requirement-matching.en.md) / [Progress and observations on accumulation](existing-test-matching-review-20261022.en.md) / [Differences between simulators and the standard](simulator-differences.md)

After exceeding 20%, work continued toward 50% and was stopped partway through. This record reports integration into the ledger of only the independently validated portion. The new test and the comparison proposal which have not been verified are not included.

<a id="集計"></a>

## Aggregation

|Item|Before|After|
| --- | ---: | ---: |
|Mapped requirements (provisional requirement coverage by test design)| 2,465（20.009741%） | **3,889（31.569121%）** |
|Requirements with recorded passes for current inputs (provisional verified-execution rate)| 1,292（10.487864%） | **2,396（19.449631%）** |
|The supported requirements in this article (chapters 1 to 40, lines 9,486)| 2,430（25.62%） | 2,779（29.30%） |
|Requirements with AND collective evidence| 126 | 147 |
|Pending assessments (test count / assessment count)|406 tests, 546 items|433 tests, 578 items|
|Number of tests| 3,938 | 3,986 |
|Tests with mappings| 1,386 | 1,539 |

- Added 1,465 pieces of mapping evidence, increasing mapped requirements by 1,424.
- Most of the increments are in the C header of the appendix. In K.2 and M.2, 1 constants are registered as 1 requirement rows, with 855 rows for constants alone. The provisional values are calculated by giving the same weight to all the registered lines, so we have included the values for this text only.
- Definitive design/execution values both remain undetermined. Denominator approval, semantic deduplication and resolution of interpretation issues remain outstanding.
- The reviewer is AI (Claude Opus 5.5). A verification agent separate from the author attempted to disprove the proposals; this was not independent human verification.

<a id="内訳"></a>

## Breakdown

<a id="1-附属書のcヘッダを検証する新規テスト24本1081要求"></a>

### 1. New tests for annex C headers (24 tests, 1,081 requirements)

|Test|Content|Requirements|
| --- | --- | ---: |
|`ch36/test_vpi_user_h_*_constants` (5 tests)|The values of the 456 constants in vpi_user.h (K.2)| 456 |
|`ch36/test_sv_vpi_user_h_*_constants` (6 tests)|The values of the 399 constants in sv_vpi_user.h (M.2), and sharing between vpiCoverMax / vpiCoveredMax| 400 |
| `ch36/test_vpi_user_h_routine_declarations` |Types of 41 routine declarations in K.2| 41 |
| `ch36/test_vpi_user_h_type_declarations`、`test_vpi_user_h_type_guards` |PLI types, vpiHandle, structure field types/order/typedef names/unions, and guards| 10 |
| `ch36/test_sv_vpi_user_h_declarations` |Structure of M.2, callback type, vpi_register_assertion_cb, guard, vpi_user.h read| 5 |
| `ch35/test_svdpi_h_declarations`、`test_svdpi_h_after_vpi_user_h`、`test_svdpi_h_sv_mask` |66 routine declarations, types, macros, guards, and svDpiVersion in svdpi.h (I.2 / I.3, H.10.1.2)| 78 |
|`ch36/test_vpi_compatibility_h_*` (6 tests)|Per-edition name mapping for vpi_compatibility.h (L.2), edition selection for 36.12.2.1, and the inclusion position of K.2| 91 |

Verification method:

- Constant values were derived from `#define` in the standard text for expected output. Simulator output was not used. Validators also independently extracted and compared values in 3 ways from the text and PDF.
- The constant is enclosed in `#ifdef`, so if it is not defined, the line is missing. Use the value as a `enum` initializer, causing compilation to stop unless it is an integer constant expression. Compilation also stops through division by zero for values outside the int range. For each of the 855 constants, the verifier tried 8 mutation types (+1, floating-point, ±2^32, a u suffix, a string, an empty definition, and an undefined macro). Of 27,360 builds across clang/gcc and C/C++, 0 matched expected output.
- Compare whether the declarations exactly match the standard's types in unevaluated expressions, using `_Generic` in C11 and `decltype` in C++. No linking is therefore needed, even for routines the simulator does not implement. Changing return types, argument types, pointer depth, const qualification and presence of varargs 1 at a time was confirmed to change the corresponding line to 0.
- The compatibility test confirmed that the vpi_compatibility.h and vpi_user.h recovered from the specification text matched the expected output in both C and C++.
- The verification was performed 3 times. In round 1, all constants were rejected because `(int)` casts could not distinguish floating-point definitions. In round 2, all were rejected again because values outside the int range are truncated. Both tests were fixed. Also fixed tests following findings about guards, union identity, `SV_MASK` expressions, and include placement.
- The following rows were not mapped. Both include conditions that cannot be observed by header declaration alone.
  - Rows specifying usage rules or the meanings of values: DELAY-FIELD, the members of VALUE and ARRAY, STEP-STRUCT, TIME, VECTOR, STRENGTH, SYSTF, and L.1 INCLUSION.
  - SIZE-TYPES, including Windows-only branches.
  - I.3 SCALARS checks values only with `#if` (the test has been fixed but has not been revalidated).
  - I.3 UNSIGNED, whose undefined behavior when N = 32 depends on the compiler.
  - I.3 MASK, which includes the non‐observable conditions.
- Simulator results:
  - Verilator 5.052: 17 tests matched with both 1/73 seeds.
  - Icarus Verilog 13.0: no tests match because the header contains only some constants/declarations.
  - The 6 compatibility tests and `test_svdpi_h_sv_mask` agree with neither simulator, so they remain `:oracle: spec` only.

<a id="2-37章のvpiオブジェクトモデルの新規テスト24本193要求"></a>

### 2 . New tests of the VPI object model in the 37 chapter (24 tests, 193 requirement)

- These tests actually traverse instance/scope/block/net/port/ref-object relations and detailed rules with C helpers, comparing retrieved values.
- Authors wrote 26 tests; separate validators checked every test and proposed mapping. 24 tests passed; 195 proposed mappings were accepted and 36 rejected. 2 `test_vpi_io_decl_relations_props` and `test_vpi_nettype_net_select_kind` are not included because some of the expected values cannot be derived from the standard.
- 23 tests have only `:oracle: spec`. Icarus 13.0 cannot compile the C helper because its header lacks constants; Verilator 5.052 cannot call the system task registered with VPI. Confirmed that the C helper compiles against 1800-2023-version standard headers without warnings in C and with only string-literal conversion warnings in C++. `test_vpi_def_line_directive` matches Icarus 13.0.

<a id="3-既存テストの照合150要求"></a>

### 3. Compare to existing test (150 requirement)

- Unmapped requirements in 9 ranges (3.12.1–6.3.1, 6.16.1–15.5.4, 20.4.2–21.3.1, 24.3–28.5, 37.10–37.16) were matched against existing tests citing them.
- Worked in pairs of 1 mapping agents and 1 validation agents; 166 proposed mappings were accepted and 91 rejected. The requirements that were met by the existing tests alone were 150.
- The low acceptance rate mainly has the following 3 causes.
  - No existing test exercises the requirement’s conditions.
  - Observes only one side of type/sign/boundary conditions.
  - The quotation section is not sufficient, and it is out of the object of the comparison (there were many examples that could be matched by adding the quotation, but because the input of the test changed and the execution evidence became old, this time it was ignored).

<a id="追加した指摘と保留m98m129"></a>

## Added findings and holds (M98–M129)

|Number|Test|Distinction|Key points|
| --- | --- | --- | --- |
| M98 | `ch11/test_real_operand_result_types` |Expected value|real/shortreal is not a bit-stream type, and 20.6.2 does not specify `$bits` for that expression.|
| M99 | `ch37/test_vpi_nettype_declarations` |Citation|Tag vpiNetTypedef, used in the diagram in 37.10, is not defined in Annex M.|
| M100 | `ch20/test_pla_sync_snapshot_versus_async_update` |Expected value|Uses a net as an output actual argument to PLA. 20.16 requires a variable.|
| M101 | `ch14/test_clocking_output_skew_cycle_delay` |Citation|Observes immediate and next-cycle drives, but does not cite 14.16.|
| M102 | `ch8/test_illegal_final_class_extended` |Expected value|The stderr references only the filename and line number, and cannot distinguish between the `:final` non-compliant errors.|
| M103 | `ch8/test_super_new_default` |Partial observations|All base arguments are int, input, and positional, so only some default-expansion conditions are observed.|
| M104 | `ch8/test_class_typed_param` |Partial observations|Does not construct/compare specializations with class types as type parameters.|
| M105 | `ch7/test_queue_edge_cases` |Partial observations|Does not cause writes beyond a bounded queue's limit.|
| M106 | `ch11/test_let_nested` |Composite requirements|Substitution and parentheses are observed, but checking conformance after expansion requires a standard-violation test.|
| M107 | `ch39/test_vpi_assertion_system_task_control` |Expected value|The callback of `$assertkill` with arguments does not match Table 20-8.|
| M108 | `ch20/test_assertcontrol` |Partial observations|The same output is obtained in an implementation where unlock does nothing.|
| M109 | `ch21/test_monitor_end_of_step` |Partial observations|Cannot distinguish whether output is always produced on resume.|
| M110 | `ch11/test_shortreal_result_and_condition_types` |Expected value|As with M98, the standard does not define `$bits` for shortreal/real expressions.|
| M111 | `ch4/test_reactive_region_set_order` |Expected value|The expected line order conflicts with 4.5’s reference algorithm, which executes Re-NBA updates in the Reactive region.|
| M112 | `ch4/test_pli_phase_chain_after_nba_and_end_write` |Expected value|It assumes Post-NBA even though cbReadWriteSynch may occur in either Pre-NBA or Post-NBA.|
| M113 | `ch5/test_attrib_module` |Partial observations|The value of the attribute has never been read.|
| M114 | `ch6/test_untyped_parameter_width_from_override` |Partial observations|Does not observe real-valued overrides or conditions where LSB is 0.|
| M115 |Ibid.|Expected value|Fixes unsized 1 width at 32, while the standard specifies only a minimum of 32.|
| M116 | `ch6/test_dollar_parameter_unbounded` |Partial observations|Does not test values contained in `[$:6]`.|
| M117 | `ch6/test_illegal_automatic_variable_nonblocking` |Composite requirements|Covers automatic variables only, with no dynamic-array-element case.|
| M118 | `ch6/test_illegal_dynamic_array_element_continuous` |Composite requirements|Covers dynamic-array elements only, with no automatic-variable case.|
| M119 | `ch10/test_comb_strength_multi` |Partial observations|An incorrect implementation treating highz0 as another strength gives the same result.|
| M120–M123 |`ch14/test_illegal_clocking_*` (outside compilation units, packages, functions, tasks)|Expected value|Because `clk` is undeclared, an undeclared-identifier diagnostic can also produce an error on the expected line.|
| M124 | `ch15/test_semaphore_edge` |Citation|The failure of try_get is directly observed, but the quotation is not corresponding.|
| M125 | `ch15/test_mailbox_typeless_try_type_check` |Citation|Observes dynamic type checking of a typeless mailbox, but the cited clause does not cover it.|
| M126 | `ch14/test_clocking_input_with_expression` |Citation|The value immediately before 1step is observed, filling the gap in M71, but the cited clause does not cover it.|
| M127–M129 | `ch28/test_primitives_multi_input`、`test_gate_primitives`、`test_gate_primitives_2` |Expected value|The variable is connected to the output terminal of the gate. 28.3 grammar requires net_lvalue.|

The categories “expected value,” “partial observation,” “composite requirement,” and “citation” correspond to `oracle_issue`, `partial_observation`, `compound_requirement`, and `citation_refinement`, respectively. The input and expected values of these tests are not changed in this task.

<a id="実行証跡"></a>

## Execution evidence

The new 48 tests was saved separately as the next 3 run. The results of all cases are not overwritten.

- `coverage/results/header-vpi-tests-20261023-icarus13.json`：Icarus Verilog 13.0（v13_0-dirty）。1 pass、47 known。
- `coverage/results/header-vpi-tests-20261023-verilator-seed1.json`：Verilator 5.052（seed 1）。17 pass、31 known。
- `coverage/results/header-vpi-tests-20261023-verilator-seed73.json`：Verilator 5.052（seed 73）。17 pass、31 known。

`known` is not counted as a success. For mapped existing tests, check saved-result input hashes and runner consistency.

<a id="残っている作業"></a>

## Remaining work

- 50%'s target has not been reached.
- Mapping/new-test creation continued in the remaining segments, but unvalidated tests and proposals were not integrated. They are planned for inclusion after later verification.
- Ranges waiting for matching:
  - The reserved-keyword rows of Annex B and the version-specific keyword rows of 22.14.x are positive-case requirements. They cannot be mapped because reservation can only be observed with illegal-design tests.
  - Excluded Annex F (formal assertion semantics) and Chapter 34 (protected envelopes).
