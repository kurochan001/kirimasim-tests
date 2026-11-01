<a id="未登録テストの照合第1回2026-10-25"></a>

# Unregistered-test comparison: round 1 (2026-10-25)

[English](existing-test-matching-unregistered-20261025.en.md) / [日本語](existing-test-matching-unregistered-20261025.md)

> Counts, percentages, and pending statuses in this document record their respective work dates.
> The current value is [Aggregated Summary](behavior-coverage-summary.en.md); the approval history for the denominator and interpretations is in
> See [Results of requirement extraction](requirement-extraction.en.md).

[Current coverage](behavior-coverage-summary.en.md) / [Comparison ledger for all tests](test-requirement-matching.en.md) / [Matching method](requirements-to-tests-method.en.md) / [Findings from previous rounds](existing-test-matching-review-20261022.en.md)

This document records the first segment of mapping begun with 2,514 existing tests lacking registered mappings. Compared test stimulus/expected output against IEEE 1800-2023 text and integrated only mappings that passed attempted refutation by independent validators.

- Newly mapped tests: 45 (unregistered 2,514 → 2,498). The additions comprise 6 new tests for requirements previously deferred for insufficient stimulus, and 23 tests imported from the simulator’s CTest suite.
- Newly mapped requirements: 99 rows (7,341 → 7,440 rows).
- The provisional requirements coverage (test design): 59.590876% → 60.394513% ( 7,440/12,319 ). 65% left 568 rows.
- The provisional execution confirmation rate remains the same as 33.566036% ( 4,135/12,319 ). The simulators were not rerun.
- Decisions to hold mappings: 490 files and 1,061 pairs (`citation_refinement` 33, `compound_requirement` 109, `oracle_issue` 49, `partial_observation` 530).

The registered test count is the number of tests mapped to at least one requirement. This does not mean that all observations in the 16 tests have been fully reviewed. Content-based requirement matching for all tests remains incomplete.

<a id="方法"></a>

## Method

Candidates were read in `propose.py` of [Reference kit](../tools/matching_kit/README.md) and proposed in `add` and `hold`; a separate reviewer challenged them in `verdict`, and `merge.py` applied only accepted mappings to the registry. Proposals, assessments, and work notes are outside the repository (`/tmp/opencode/matching/`); only `merge.py` and generation tools update repository contents.

Registration criteria follow Chapter 6 of [Methodological documentation](requirements-to-tests-method.en.md).

- The stimulus must cause all the conditions of the demand.
- The expected output must distinguish an implementation that violates only that requirement.
- Do not rely only on names, descriptions, cited clauses, or the presence of API calls.
- Do not rely on checks only for non-NULL, checks passing with a constant result, self-comparisons, count-only checks, or observations with unspecified order.
- For requirements demanding detection of standard violations, use only tests with both `:should_fail_because:` and `:expected_stderr_regex:`.

If you are lost, you do not register, but you record as a reserve with limited scope. A deferral records a deferred mapping to that requirement; it is not approval of the entire test.

<a id="登録した対応"></a>

## Registered mappings

The following is a summary of each chapter. The requirement ID corresponds to the line of `coverage/behaviors.json`.

|Chapter|Test|Requirements|
|---|---|---|
| 5.6.3 | [test_vpi_systf_names](../tests/ch36/test_vpi_systf_names.sv) | `PLI-SYSTEM-EXTENSION`、`SYSTEM-NAME-CHARACTERS`、`SYSTEM-PREFIX` |
| 11.4.6 | [test_gen_xz_wne_03](../tests/gen/ch11/test_gen_xz_wne_03.sv) | `UNMASKED-UNKNOWN` |
| 11.5.3 | [test_static_prefix_disjoint_field_drivers](../tests/ch11/test_static_prefix_disjoint_field_drivers.sv) | `LONGEST-STATIC-PREFIX` |
| 13.6 | [test_dpi_import_calls_exported_value](../tests/ch13/test_dpi_import_calls_exported_value.sv) | `DPI-SUBROUTINES` |
| 16.5 | [test_assertion_clocked_by_named_event](../tests/ch16/test_assertion_clocked_by_named_event.sv) | `CLOCK-TICK` |
| 16.14.6.4 | [test_procedural_concurrent_assertions](../tests/ch16/test_procedural_concurrent_assertions.sv) | `DISABLE-PROCESS` |
| 18.5.10 | [test_static_constraint_mode](../tests/ch18/test_static_constraint_mode.sv) | `STATIC-BLOCK`、`STATIC-MODE-SHARED` |
| 19.8.1 | [test_cg_sample_from_contexts](../tests/ch19/test_cg_sample_from_contexts.sv) | `CUSTOM-SAMPLE-CONTEXT` |
| 19.11.3 | [test_cg_merge_auto_and_transition_names](../tests/ch19/test_cg_merge_auto_and_transition_names.sv) | `SCALAR-BIN-IDENTITY`、`TRANSITION-IDENTITY`、`AUTO-BIN-IDENTITY` |
| 21.2.1.6 | [test_pattern_format_enum_string_null](../tests/ch21/test_pattern_format_enum_string_null.sv) | `PATTERN-STRING`、`PATTERN-HANDLES` |
| 21.3.7 | [test_file_fflush_ferror](../tests/ch21/test_file_fflush_ferror.sv) | `FERROR-CLEAR` |
| 23.2.1 | [test_module_header_styles](../tests/ch23/test_module_header_styles.sv) | `HEADER-STYLES` |
| 23.3.3.7.1 | [test_interconnect_port_merge](../tests/ch23/test_interconnect_port_merge.sv) | `INTERCONNECT-MERGE` |
| 36.3 | [test_vpi_systf_names](../tests/ch36/test_vpi_systf_names.sv) | `NAME-CASE` |
| 38.10 | [test_vpi_gate_delays](../tests/ch38/test_vpi_gate_delays.sv) | `DELAY-LAYOUT-0-0` |
| 38.32 | [test_vpi_gate_delays](../tests/ch38/test_vpi_gate_delays.sv) | `PUT-LAYOUT-0-0` |
| 38.35 | [test_vpi_put_value_array](../tests/ch38/test_vpi_put_value_array.sv) | `ONE-VALUE` |
| 6.18 / 8.27 | [test_typedef_declaration_forms](../tests/ch6/test_typedef_declaration_forms.sv) | `CLASS-FORWARD-OMISSION` |
| A.2.1.3 | [test_typedef_declaration_forms](../tests/ch6/test_typedef_declaration_forms.sv) | `TYPEDEF`、`FORWARD-TYPES` |

This registration comprises 45 tests: the 16 above plus 29 new tests for the following 2 clauses. The main observations are as follows.

- 36.3 / 5.6.3: register with PLI names differing only in case (2 names), names containing `$`, names containing digits, and 72-character 2 names differing only in their final 1 characters; verify that 6 names execute under their respective registered names. Simultaneously observe case sensitivity, arbitrary length, significance of every character, and additional system tasks registered through PLI.
- 19.11.3: in `merge_instances`, coverage values confirm name collisions involving individual bins (`one_t` 100.00), transition arrays (`t` 50.00), and automatic bins (33.33 → 66.67).
- 19.8.1: the overridden `sample` with arguments receives data from an automatic function (1/8), a forked 2 process (3/8), and a sequence match item (4/8). Distinguishes sequence values sampled as `d` in Preponed (2 and 6) from `d` after NBA (6 and 7), which would produce 5/8.
- 38.10 / 38.32: verify that in `mtm_flag=FALSE` and `pulsere_flag=FALSE`, `da[0]` is delay number 1 and `da[1]` is delay number 2. Distinguishes reversed ordering through the read value `3 5` and the post-configuration rising edge 17 and falling edge 39.
- 6.18/8.27/A.2.1.3: values such as `deep_t=32`, `w5_t=5`, and `p=3,4/2` check that `typedef Fwd;` resolves to a later `class Fwd;`, the 3 alternatives of typedef and 4 kinds of unpacked dimensions, and 5 forward-type keywords.
- 18.5.10: declaration of `static constraint` and sharing of constraint_mode across all objects. The same output also includes a control showing that ordinary constraint `c_d` is not shared.

<a id="刺激の追記で解消した保留新規テスト6本"></a>

## Pending items resolved by added stimulus (6 new tests)

6 new tests were added for 13 requirements previously deferred because existing stimuli did not exercise all required conditions. Derived expected values from the standard first, then confirmed matches with Icarus Verilog 13.0 (and, for some tests, Verilator 5.052).

|Requirements|New tests|Additional stimulus| `:oracle:` |
|---|---|---|---|
| 5.6.1 `ESCAPE-CHARACTER-DOMAIN` | [test_escaped_identifier_character_domain](../tests/ch5/test_escaped_identifier_character_domain.sv) |Each printable ASCII character from 33 through 126, standard-example multicharacter names, and escaped keyword `\net`| iverilog + verilator |
| 5.7.1 `FILL-CONTEXT` | [test_unsized_fill_all_values](../tests/ch5/test_unsized_fill_all_values.sv) |`'0` / `'1` / `'x` / `'z` × 8/33/65 bits; self-determined-width `$bits('1)`| iverilog |
| 5.8 `TIME-NUMERIC-FORM` | [test_time_literal_units_and_fraction](../tests/ch5/test_time_literal_units_and_fraction.sv) |`fs/ps/ns/us/ms/s` with 6 units and fixed-point `3.5ns`| iverilog + verilator |
| 11.4.6 `RIGHT-ONLY-WILDCARD` | [test_wildcard_lhs_unknown](../tests/ch11/test_wildcard_lhs_unknown.sv) |x/z in LHS (not wildcards); `?`/x/z in RHS matches 0/1/x/z in LHS; a known mismatch determines 0| iverilog |
| 20.7 `DIMENSION-NUMBERING`、`PREDEFINED-INTEGER-DIMENSION`、`DIMENSIONS`、`UNPACKED-DIMENSIONS` | [test_array_query_functions](../tests/ch20/test_array_query_functions.sv) |Dimension numbering of a 4-dimensional array, typedef expansion, the single packed dimension of integer types, and dimension counts for packed / unpacked / dynamic / string / real| verilator |
| 20.7 `ARRAY-QUERY-SYNTAX`、`CONSTANT-ARRAY-QUERY`、`INCREMENT`、`RIGHT-BOUND`、`INVALID-DIMENSION` | [test_array_query_types_and_invalid](../tests/ch20/test_array_query_types_and_invalid.sv) |Type arguments, constant expressions, -1 for empty queues/dynamic arrays, and all-x results for invalid dimensions| spec |

- 5.6.1: because Icarus 13.0 incorrectly parses the 1-character name `\#` as a special name, `#` is stimulated inside `\a#b`. The other 93 characters are declared as individual names. Their character codes are concatenated for display to verify resolution 1 characters at a time.
- 5.7.1: existing tests covered only `'0`/`'1`, so `'x`/`'z`, a 33/65-bit context, and self-determined width 1 were added.
- 5.8: only integer values in `ns` units were present, so all 6 units and fractional parts were added.
- 11.4.6: the initial validation found “no line where a wildcard in RHS faces a known 0 in LHS,” so added 4 lines including `0000 ==? ????` and obtained revalidation. Separately observes that x/z in LHS are not wildcards, that wildcards in RHS match all of 0/1/x/z, and that a known mismatch determines 0.
- 20.7: because array queries in Icarus 13.0 reject type arguments and constant expressions, return 0 for `$right`/`$increment` on an empty queue, and count `int dyn[]` as 0 dimensions, they were split into 4 executable requirements and 5 specification-only requirements. Executable cases agree on Verilator 5.052; Icarus differs only in dynamic-array dimension counts.
- All 6 tests passed `lint_metadata.py`, and `runsim.py` produced the results documented in `:oracle:`. Because Verilator uses 2 values, it cannot execute the `'x`/`'z` tests or wildcard comparisons with a nonconstant RHS having 4 values.

<a id="シミュレータ側の-ctest-スイートからの取り込み23本"></a>

## Import from the simulator-side CTest suite (23 tests)

`tests/suite` in `../kirimasim` contains 2,818 SystemVerilog tests with the same metadata format (`:lrm:`, `:oracle:`, `:expected_stdout:`). This format is compatible with existing suites, and can be imported without duplicating filenames or contents. However, there are some restrictions.

- 2,125 tests have `:expected_stderr:` (exact matching of warning/error strings), which is not this suite's `:expected_stderr_regex:` format, so they cannot be integrated as-is.
- The 57 illegal-design tests have no `:expected_stderr_regex:`.
- 61 tests have simulator-specific options in `:args:`.
- In 26 files, the first cited clause is Annex A, which does not follow the directory convention (`chNN`).
- `:tags:` denotes categories such as `proc` and `sched`, so it was changed to `chNN`; `:generator:` was removed because this repository has no corresponding generator, and `test_` is appended to filenames.

Integrated 540 of these tests in a batch and prioritized requirements when mapping. There were 641 candidate rows for unmapped requirements; linking all would reach 65.13%. 21 tests and 58 rows were registered. The rest were deferred for partial observations, composite requirements or unchecked diagnostics. The 519 tests that did not result in registration has been removed to avoid increasing the number of unregistered tests (it remains on the original kirimasim side).

|Chapter|Examples of integrated and registered tests|Primary requirements|
|---|---|---|
| 21 | test_display_radix_forms、test_display_finish、test_time_format_matrix、test_empty_argument_matrix |Formatting, %%, %t, empty arguments|
| 21 | test_file_close_fd、test_file_output_initial |File descriptor, fdisplay|
| 23 | test_net_port_merge_kinds、test_instance_arrays |Table 23-1 port collapse, instance array|
| 9 | test_edge_matrix、test_delay_value_matrix |Edge table 9-2, x/z delay|
| 10 | test_delay_matrix、test_procedural_continuous_assign、test_net_strengths_wire |Vector delays, force, and strengths|
| 6/12/20/22/28 | test_package_call_matrix、test_cond_truth、test_time_query_matrix、test_unconnected_drive_none_module、test_gate_containers |Continuous assignment, if truth value, time query, unconnected port, gate array|

- The test is placed in `tests/imported/chNN/`, and the directory contents (input digest) of the existing chapter are not changed.
- Expected results were rederived from the standard in each batch and independently verified, rather than reused unchanged from the original suite.
- Rejected `test_always_star` because self-reading in the `always @*` body makes it nonconvergent even under the standard.
- For `test_instance_arrays` and `test_net_port_merge_kinds`, `:oracle:` does not match actual simulator results. The expected value is in accordance with the specification, so the link is established, but it is a candidate for correction of `:oracle:`.

<a id="65-への見通し"></a>

### The prospect of 65%

- Now 60.39%. 65% requires the remaining 568 line.
- The upper limit of the candidates for inclusion is 65.13%, which is the maximum if all the remaining candidates are fully observed. The actual registration rate is about 24%, so the realistic reach point for this pool alone is around 62%.
- Reaching 65% requires normalizing the 2,125 warning tests containing `:expected_stderr:`, or creating new tests for unmapped requirements (approximately 4,900 rows).

<a id="却下した対応案"></a>

## Rejected mapping proposals

The verification officer refuted this proposal and did not register it. Rejection does not prohibit future resubmissions.

|Requirements|Test|Rejection reasons (summary)|
|---|---|---|
| 5.6.1 `ESCAPE-CHARACTER-DOMAIN` | test_escaped_identifier_with_dot |`.` 1 Stimulate only the character, not the entire character area of the escape identifier|
| 5.7.1 `FILL-CONTEXT` | test_unsized_fill_wide_part_select_nba |Uses only `'0` / `'1` and does not exercise filling every bit with `'x` / `'z`|
| 5.8 `TIME-NUMERIC-FORM` | test_time_literal_scaled_to_unit |Uses only integers and `ns`, without exercising other units or fractional parts|
| 11.4.6 `RIGHT-ONLY-WILDCARD` | test_gen_xz_weq_01 |There is no row in which `z` of LHS faces a known RHS bit, so the test cannot distinguish an implementation that treats `z` as a wildcard|
| 11.4.10 `SHIFT-SIGN-CONTEXT` | test_gen_width_ashr_01 |Only one shift direction with a signed left operand is exercised; this cannot distinguish zero filling for an unsigned left operand|
| 16.12.17 `NO-NEGATION-STRONG` | test_illegal_recursive_property_negated |The 6 operators are stimulated only by `not`, and no rejection of the remaining 5 operators is observed.|
| 16.16 `MULTICLOCK-LEADING` | test_illegal_multiclock_two_leading_clocks |Observes only mandatory clauses without stimulating inherited default leading clocks permitted by another clause|
| 19.6.1.4 `CROSS-SET-EXPRESSION` | test_cg_cross_set_expression |Checks array-literal acceptance and bin selection without observing nonliteral expressions or cast requirements|
| 19.11.3 `AUTO-CROSS-IDENTITY` | test_cg_merge_auto_and_transition_names |An instance-weighted average with merging disabled also yields 8.33/16.67, so it cannot distinguish the union|
| 21.2.1.6 `PATTERN-ENUM` | test_pattern_format_enum_string_null |Displays only names of valid values without exercising base-type display for invalid values|
| 23.2.1 `MODULE-HEADER-FIELDS` | test_module_header_styles |Expected output does not refute incorrect default lifetime / port types; `(8 bits)` is the parent variable's width|
| 39.4.1 `SYSTEM-ENABLE-FAIL-TEXT` | test_vpi_assertion_system_control |Possible dependence on same-time system-callback ordering|
| 39.4.1 `SYSTEM-DISABLE-FAIL-TEXT` | test_vpi_assertion_system_control |Ibid.|
| 39.5.1 `CONTROL-VPIASSERTIONSYSEND` | test_vpi_assertion_sys_end_discards_and_blocks |The claim that 1 tests observe discarding, stopping new attempts and subsequent control after SysEnd could not be substantiated|
| 40.3.2.1 `RETURN-SV-COV-CHECK-SV-COV-NOCOV` | test_coverage_uninstantiated_module |Even an implementation that always returns NOCOV passes; there is no contrast with OK or PARTIAL|

<a id="保留の傾向"></a>

## Patterns in pending mappings

The 1,061 deferred pairs are divided into the following 4 categories.

- `partial_observation`: only a part of the multiple conditions of the requirement is stimulated. Examples: printing only the width of `$bits` without a bit-stream cast; checking only the false protection-flag branch in VPI, only the signed shift case, or only `get` in a constraint.
- `compound_requirement`: 1 rows bundle multiple independent conditions. Examples: the 6 operator in `16.12.17`, multiple forms of bin identity in `19.11.3`, and the 7 header items in `23.2.1`. The requirement must be split by condition, or a AND set of multiple tests is needed.
- `oracle_issue`: expected values depend on implementation choices, or the standard does not uniquely specify order/timing. Examples: Pre/Post-NBA for `cbReadWriteSynch`, callback ordering at the same time, and values after releasing a VPI handle.
- `citation_refinement`: The section referenced by the test `:lrm:` is different from the section of the actual API. Examples: citing `38.16` (array retrieval) while calling only `vpi_get`, or citing `38.31` (put_data) while calling only `vpi_release_handle`.

`propose.py` automatically excludes pending entries, so resolve the pending reason before reproposing the same test/requirement pair.

<a id="残りと次の候補"></a>

## The remaining and next candidates

- The total number of tests is 6,038 tests (including the new 29 tests). 2,498 tests remain unregistered. About 380 of them have no candidate requirement at all, requiring requirement-ledger splitting and observable definitions.
- Of 4,952 unmapped requirement rows, approximately 1,970 have candidate unregistered tests. The remainder have no candidate tests and require new tests.
- 197 This tests is the only candidate test for either of the non-compliant requirements. 1 There are few tests that can satisfy multiple requirements, but it is worth checking them out first.
- Candidates for the next segment: type conversions in `ch6`, VPI arrays and handles in `ch38`, `$bits` in `ch20`, non-ANSI ports in `ch23`, and the remaining coverage requirements in `ch19`.
- For generated tests (`tests/gen/`), multiple tests can observe the same requirement, so registered only the 1 most complete tests and kept the rest pending.

<a id="再現"></a>

## Reproduction

```sh
python3 tools/matching_kit/partition.py /tmp/opencode/matching/assign
python3 tools/matching_kit/propose.py scope /tmp/opencode/matching/assign/p01-*.json
python3 tools/matching_kit/propose.py test tests/chN/test_x.sv
python3 tools/matching_kit/propose.py req SV2023-...
python3 tools/matching_kit/merge.py /tmp/opencode/matching/proposals/wave2 \
  --reviewer 'DeepSeek V4.1 Flash (AI); not an independent human review' --date 2026-10-25
python3 tools/behavior_coverage.py --update
python3 tools/requirement_matching.py --update
python3 tools/behavior_coverage.py --check --require-source-reviewed
python3 tools/requirement_matching.py --check
python3 -m unittest discover -s tools -p 'test_*.py'
```

<a id="注意"></a>

## Attention

- AI has done the comparison and verification, and is not an independent human review. This is also recorded in the ledger's `reviewer` field.
- Test bodies, expected values, requirement definitions, and saved execution results are unchanged. The expected value is derived from the specification text and the output of the simulator is not written to the expected value.
- Because simulators were not rerun, the 26 new requirements lack recorded pass results for current inputs. The design compliance is registered only, and the execution confirmation rate is not increased.
- The `:oracle: spec` tests (coverage in ch19, interconnect in ch23, VPI system tasks in ch36, etc.) have no execution support because neither Icarus 13.0 nor Verilator 5.052 agrees.
