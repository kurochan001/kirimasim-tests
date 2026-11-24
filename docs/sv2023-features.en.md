# Tests of the features added by IEEE 1800-2023

[English](sv2023-features.en.md) / [日本語](sv2023-features.md)

For each feature added by 1800-2023, the number of tests that exercise it and what backs their expectations. The ledger is `coverage/sv2023-features.json`; `tools/sv2023_features.py --update` writes this report. The tests of the ledger were read one by one from candidates found by regular expressions. The features are the 18 items of the DVCon tutorial "A Subjective Review on IEEE Std 1800-2023" and `ref static`, real coverpoints and type parameter restrictions. The standard has no list of the features its revision added, so whether these last three are new in 2023 cannot be confirmed from its text alone.

## Summary

| Feature | Clauses | Tests | Legal | Illegal | Fixed-release oracle | Standard only | I | V | K | G | Requirements (mapped / rows) | Listed in |
| --- | --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | --- |
| [type(this)](#type-this) | 6.23, 8.11 | 5 | 4 | 1 | 4 | 1 | 1 | 4 | 2 | 5 | 2/2 | the 18 DVCon items |
| [Logical expressions in the ifdef directives](#ifdef-expression) | 22.6 | 4 | 3 | 1 | 2 | 2 | 1 | 2 | 3 | 4 | 5/5 | the 18 DVCon items |
| [Index argument of an array method call](#array-method-index-argument) | 7.12, 7.12.4 | 5 | 5 | 0 | 0 | 5 | 0 | 0 | 0 | 5 | 3/3 | the 18 DVCon items |
| [class :final](#class-final) | 8.3, 8.13 | 11 | 7 | 4 | 10 | 1 | 0 | 10 | 6 | 11 | 2/2 | the 18 DVCon items |
| [default item of dist](#dist-default) | 18.5.3 | 8 | 5 | 3 | 0 | 8 | 3 | 3 | 3 | 8 | 3/3 | the 18 DVCon items |
| [Real coverpoints, real bins and type_option.real_interval](#real-coverpoint) | 19.5, 19.5.1, 19.5.1.1, 19.5.2, 19.5.3, 19.5.4, 19.6, 19.7.1, 19.10 | 21 | 12 | 9 | 0 | 21 | 9 | 0 | 9 | 21 | 26/26 | the three added items |
| [$stacktrace](#stacktrace) | 20.17.2, 11.2.1 | 6 | 3 | 3 | 6 | 0 | 2 | 6 | 5 | 6 | 0/2 | the 18 DVCon items |
| [$timeunit and $timeprecision system functions](#timeunit-timeprecision-functions) | 20.4, 20.4.1, 11.2.1 | 8 | 8 | 0 | 1 | 7 | 0 | 1 | 7 | 8 | 25/25 | the 18 DVCon items |
| [Restricted type parameters (type enum/struct/union/class/interface class)](#type-parameter-restriction) | 6.20.3 | 10 | 5 | 5 | 8 | 2 | 4 | 8 | 9 | 10 | 2/2 | the three added items |
| [default in constructor argument lists (function new(default...), super.new(default), extends Base(default))](#constructor-default-arguments) | 8.17, 8.3, 8.15 | 15 | 6 | 9 | 0 | 15 | 7 | 8 | 11 | 15 | 14/14 | the 18 DVCon items |
| [map array method](#array-map-method) | 7.12.5, 7.12 | 8 | 5 | 3 | 2 | 6 | 2 | 2 | 3 | 8 | 3/3 | the 18 DVCon items |
| [union soft (soft packed union)](#soft-packed-union) | 7.3.1, 7.3, 7.2 | 8 | 7 | 1 | 4 | 4 | 0 | 4 | 4 | 8 | 8/8 | the 18 DVCon items |
| [Triple-quoted string literals](#triple-quoted-string) | 5.9, 5.9.1, A.8.8, 22.5.1 | 9 | 7 | 2 | 5 | 4 | 1 | 5 | 9 | 9 | 13/13 | the 18 DVCon items |
| [rand real variables](#rand-real) | 18.4, 18.4.1, 18.5.3, 18.5.4, 18.5.5, 18.5.6, 18.5.9 | 10 | 4 | 6 | 0 | 10 | 4 | 4 | 6 | 10 | 8/8 | the 18 DVCon items |
| [constraint :initial / :extends / :final](#constraint-dynamic-override) | 18.5.2, 18.5, 18.5.10, 8.3 | 15 | 4 | 11 | 5 | 10 | 11 | 7 | 11 | 15 | 11/11 | the 18 DVCon items |
| [weak_reference class](#weak-reference) | 8.29, 8.30, 8.30.1, 8.30.2, 8.30.3, 8.30.4, 8.30.5, G.7, G.1 | 13 | 12 | 1 | 0 | 13 | 1 | 1 | 1 | 13 | 20/27 | the 18 DVCon items |
| [covergroup extends (derived embedded covergroup)](#covergroup-inheritance) | 19.3, 19.4, 19.4.1, A.2.11 | 13 | 6 | 7 | 0 | 13 | 7 | 6 | 7 | 13 | 12/12 | the 18 DVCon items |
| [ref static arguments](#ref-static) | 13.5.2, 13.3, 13.4, A.2.7 | 22 | 18 | 4 | 0 | 22 | 0 | 0 | 20 | 22 | 8/8 | the three added items |
| [Tolerance ranges [A +/- B] and [A +%- B]](#tolerance-ranges) | 11.4.13, 18.5.3, 19.5.1, A.2.11, A.6.7 | 29 | 26 | 3 | 0 | 29 | 3 | 2 | 22 | 29 | 10/10 | the 18 DVCon items |
| [function/task :initial / :extends / :final](#method-dynamic-override) | 8.20, 8.3, 8.24, 13.3, 13.4, 35.5.4, A.2.6, A.2.7 | 33 | 11 | 22 | 17 | 16 | 14 | 19 | 30 | 33 | 24/24 | the 18 DVCon items |

Saved results: I Icarus Verilog 13.0, V Verilator, K kirimasim, L Lyra, G Ghost. p when a result saved for the current input of the test passes, - otherwise. For an illegal design a rejection caused by unsupported syntax can also look like a pass.

<a id="type-this"></a>

## type(this)

- Clauses: 6.23, 8.11
- Illegal forms the standard defines: this may appear only as type(this) or inside nonstatic methods, constraints, inlined constraint methods and class-embedded covergroups, so type(this) outside any class is an error. (8.11)
- Requirements (mapped / rows): `SV2023-6.23-EXTRACT-TYPE-THIS`, `SV2023-8.11-EXTRACT-THIS-CONTEXT`

| Test | Kind | `:oracle:` | Saved results |
| --- | --- | --- | --- |
| [`ch8/test_type_this`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/ch8/test_type_this.sv) | legal | `spec` | `I- V- Kp Gp` |
| [`ch8/test_type_this_final_class_typedef`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/ch8/test_type_this_final_class_typedef.sv) | legal | `spec verilator@5.054` | `I- Vp K- Gp` |
| [`ch8/test_type_this_inherited_method_lexical_class`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/ch8/test_type_this_inherited_method_lexical_class.sv) | legal | `spec verilator@5.054` | `I- Vp K- Gp` |
| [`ch8/test_type_this_parameterized_specialization`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/ch8/test_type_this_parameterized_specialization.sv) | legal | `spec verilator@5.054` | `I- Vp K- Gp` |
| [`ch8/test_illegal_type_this_outside_class`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/ch8/test_illegal_type_this_outside_class.sv) | illegal | `spec verilator@5.052` | `Ip Vp Kp Gp` |

<a id="ifdef-expression"></a>

## Logical expressions in the ifdef directives

- Clauses: 22.6
- Illegal forms the standard defines: Syntax 22-5 allows only macro names, parentheses, ! and the binary operators &&, ||, -> and <-> in the expression; other operators are not part of the syntax (the standard gives no separate shall-not sentence). (22.6)
- Requirements (mapped / rows): `SV2023-22.6-EXTRACT-CONDITIONAL-EVALUATION`, `SV2023-22.6-EXTRACT-CONDITIONAL-GRAMMAR`, `SV2023-22.6-EXTRACT-FIRST-SUCCESS`, `SV2023-22.6-EXTRACT-IFNDEF-NEGATION`, `SV2023-22.6-EXTRACT-DIRECTIVES-NOT-DEFINED`

| Test | Kind | `:oracle:` | Saved results |
| --- | --- | --- | --- |
| [`ch22/test_ifdef_branches_and_expressions`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/ch22/test_ifdef_branches_and_expressions.sv) | legal | `spec` | `I- V- Kp Gp` |
| [`ch22/test_ifdef_directive_names_not_defined`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/ch22/test_ifdef_directive_names_not_defined.sv) | legal | `spec` | `I- V- K- Gp` |
| [`ch22/test_ifdef_expression`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/ch22/test_ifdef_expression.sv) | legal | `spec verilator@5.052` | `I- Vp Kp Gp` |
| [`ch22/test_illegal_ifdef_expression_operator`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/ch22/test_illegal_ifdef_expression_operator.sv) | illegal | `spec verilator@5.052` | `Ip Vp Kp Gp` |

<a id="array-method-index-argument"></a>

## Index argument of an array method call

- Clauses: 7.12, 7.12.4
- Illegal forms the standard defines: None.
- Requirements (mapped / rows): `SV2023-7.12-EXTRACT-INDEX-NAME-DEFAULT`, `SV2023-7.12-EXTRACT-METHOD-CALL-GRAMMAR`, `SV2023-7.12.4-EXTRACT-INDEX-RENAME`

| Test | Kind | `:oracle:` | Saved results |
| --- | --- | --- | --- |
| [`ch7/test_array_method_index_argument`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/ch7/test_array_method_index_argument.sv) | legal | `spec` | `I- V- K- Gp` |
| [`ch7/test_array_method_index_argument_class_assoc_nested`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/ch7/test_array_method_index_argument_class_assoc_nested.sv) | legal | `spec` | `I- V- K- Gp` |
| [`ch7/test_array_method_index_argument_without_iterator`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/ch7/test_array_method_index_argument_without_iterator.sv) | legal | `spec` | `I- V- K- Gp` |
| [`ch7/test_array_method_iterator_index_names_and_selects`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/ch7/test_array_method_iterator_index_names_and_selects.sv) | legal | `spec` | `I- V- K- Gp` |
| [`ch7/test_map_element_types_and_index_names`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/ch7/test_map_element_types_and_index_names.sv) | legal | `spec` | `I- V- K- Gp` |

<a id="class-final"></a>

## class :final

- Clauses: 8.3, 8.13
- Illegal forms the standard defines: A class declared with the final specifier cannot be extended; deriving from it is an error. (8.13)
- Requirements (mapped / rows): `SV2023-8.3-EXTRACT-CLASS-DECLARATION`, `SV2023-8.13-EXTRACT-FINAL-CLASS`

| Test | Kind | `:oracle:` | Saved results |
| --- | --- | --- | --- |
| [`ch6/test_type_param_restricted_abstract_final_scoped`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/ch6/test_type_param_restricted_abstract_final_scoped.sv) | legal | `spec verilator@5.054` | `I- Vp K- Gp` |
| [`ch8/test_class_declaration_grammar_forms`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/ch8/test_class_declaration_grammar_forms.sv) | legal | `spec verilator@5.052` | `I- Vp K- Gp` |
| [`ch8/test_constructor_default_through_implicit_constructor`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/ch8/test_constructor_default_through_implicit_constructor.sv) | legal | `spec` | `I- V- K- Gp` |
| [`ch8/test_final_class_and_method`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/ch8/test_final_class_and_method.sv) | legal | `spec verilator@5.052` | `I- Vp Kp Gp` |
| [`ch8/test_final_class_parameterized_implements`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/ch8/test_final_class_parameterized_implements.sv) | legal | `spec verilator@5.054` | `I- Vp K- Gp` |
| [`ch8/test_syntax_class_and_interface_class_headers`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/ch8/test_syntax_class_and_interface_class_headers.sv) | legal | `spec verilator@5.052` | `I- Vp Kp Gp` |
| [`ch8/test_type_this_final_class_typedef`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/ch8/test_type_this_final_class_typedef.sv) | legal | `spec verilator@5.054` | `I- Vp K- Gp` |
| [`ch8/test_illegal_final_class_extended`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/ch8/test_illegal_final_class_extended.sv) | illegal | `spec verilator@5.052` | `I- Vp Kp Gp` |
| [`ch8/test_illegal_final_class_extends`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/ch8/test_illegal_final_class_extends.sv) | illegal | `spec verilator@5.052` | `I- Vp Kp Gp` |
| [`ch8/test_illegal_final_class_specialization_extended`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/ch8/test_illegal_final_class_specialization_extended.sv) | illegal | `spec verilator@5.054` | `I- Vp Kp Gp` |
| [`ch8/test_illegal_final_derived_class_in_package_extended`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/ch8/test_illegal_final_derived_class_in_package_extended.sv) | illegal | `spec verilator@5.054` | `I- Vp Kp Gp` |

<a id="dist-default"></a>

## default item of dist

- Clauses: 18.5.3
- Illegal forms the standard defines: The default item must use :/ with a weight (omitting the weight or using := is an error) and a distribution may have at most one default item. (18.5.3)
- Requirements (mapped / rows): `SV2023-18.5.3-EXTRACT-DEFAULT-COMPLEMENT`, `SV2023-18.5.3-EXTRACT-DEFAULT-DIVIDE-UNIQUE`, `SV2023-18.5.3-EXTRACT-DIST-MEMBERSHIP`

| Test | Kind | `:oracle:` | Saved results |
| --- | --- | --- | --- |
| [`ch18/test_constraint_grammar_forms`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/ch18/test_constraint_grammar_forms.sv) | legal | `spec` | `I- V- K- Gp` |
| [`ch18/test_dist_default_complement`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/ch18/test_dist_default_complement.sv) | legal | `spec` | `I- V- K- Gp` |
| [`ch18/test_dist_default_in_implication_inline_foreach`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/ch18/test_dist_default_in_implication_inline_foreach.sv) | legal | `spec` | `I- V- K- Gp` |
| [`ch18/test_dist_default_only_and_conflicts`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/ch18/test_dist_default_only_and_conflicts.sv) | legal | `spec` | `I- V- K- Gp` |
| [`ch18/test_dist_default_weight`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/ch18/test_dist_default_weight.sv) | legal | `spec` | `I- V- K- Gp` |
| [`ch18/test_illegal_dist_default_colon_equal`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/ch18/test_illegal_dist_default_colon_equal.sv) | illegal | `spec` | `Ip Vp Kp Gp` |
| [`ch18/test_illegal_dist_default_no_weight`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/ch18/test_illegal_dist_default_no_weight.sv) | illegal | `spec` | `Ip Vp Kp Gp` |
| [`ch18/test_illegal_dist_two_defaults`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/ch18/test_illegal_dist_two_defaults.sv) | illegal | `spec` | `Ip Vp Kp Gp` |

<a id="real-coverpoint"></a>

## Real coverpoints, real bins and type_option.real_interval

- Clauses: 19.5, 19.5.1, 19.5.1.1, 19.5.2, 19.5.3, 19.5.4, 19.6, 19.7.1, 19.10
- Illegal forms the standard defines: A coverpoint of a real expression must have at least one explicit bins construct (no automatic bins). (19.5); A default bin of a real coverpoint cannot use the [] or [N] array notation. (19.5.1); A with clause is not allowed on bins of a real coverpoint. (19.5.1.1); Transition bins of real values are not allowed. (19.5.2); Wildcard bins of a real coverpoint are not allowed. (19.5.4); A cross cannot name a real variable directly; a real expression must be wrapped in an explicit coverpoint (no test for this form found). (19.6); type_option.real_interval can be set only at the covergroup and coverpoint levels, not in a cross. (19.7.1)
- Requirements (mapped / rows): `SV2023-19.5-EXTRACT-COVERPOINT-DOMAIN`, `SV2023-19.5-EXTRACT-REAL-EXPLICIT-BINS`, `SV2023-19.5.1-EXTRACT-EXCESS-REAL-BINS`, `SV2023-19.5.1-EXTRACT-FIXED-REAL-DISTRIBUTION`, `SV2023-19.5.1-EXTRACT-MERGE-IDENTICAL-INTERVALS`, `SV2023-19.5.1-EXTRACT-REAL-BIN-FORMS`, `SV2023-19.5.1-EXTRACT-REAL-BIN-NAMES`, `SV2023-19.5.1-EXTRACT-REAL-DEFAULT-NO-ARRAY`, `SV2023-19.5.1-EXTRACT-REAL-DOLLAR-RANGE`, `SV2023-19.5.1-EXTRACT-REAL-INTERVAL-ENDS`, `SV2023-19.5.1-EXTRACT-REAL-OPEN-PARTITION`, `SV2023-19.5.1-EXTRACT-REAL-RANGE`, `SV2023-19.5.1-EXTRACT-REAL-TOLERANCE`, `SV2023-19.5.1.1-EXTRACT-WITH-FILTER`, `SV2023-19.5.2-EXTRACT-TRANSITION-INTEGRAL`, `SV2023-19.5.3-EXTRACT-AUTO-WHEN-NO-NORMAL`, `SV2023-19.5.4-EXTRACT-WILDCARD-SAMPLES`, `SV2023-19.6-EXTRACT-CROSS-ITEMS`, `SV2023-19.7.1-EXTRACT-TYPE-DEFAULTS`, `SV2023-19.7.1-EXTRACT-TYPE-LEVEL-REAL-INTERVAL-COVERGROUP`, `SV2023-19.7.1-EXTRACT-TYPE-LEVEL-REAL-INTERVAL-COVERPOINT`, `SV2023-19.7.1-EXTRACT-TYPE-LEVEL-REAL-INTERVAL-CROSS`, `SV2023-19.7.1-EXTRACT-TYPE-OPTION-MUTATION`, `SV2023-19.7.1-EXTRACT-TYPE-OPTION-REAL-INTERVAL`, `SV2023-19.10-EXTRACT-GROUP-TYPE-OPTION-STRUCT`, `SV2023-19.10-EXTRACT-POINT-TYPE-OPTION-STRUCT`

| Test | Kind | `:oracle:` | Saved results |
| --- | --- | --- | --- |
| [`ch19/test_cg_auto_bins_only_ignored_and_real`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/ch19/test_cg_auto_bins_only_ignored_and_real.sv) | legal | `spec` | `I- V- K- Gp` |
| [`ch19/test_cg_real_bin_intervals`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/ch19/test_cg_real_bin_intervals.sv) | legal | `spec` | `I- V- K- Gp` |
| [`ch19/test_cg_real_bins_fixed_and_dollar`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/ch19/test_cg_real_bins_fixed_and_dollar.sv) | legal | `spec` | `I- V- K- Gp` |
| [`ch19/test_cg_real_bins_tolerance_and_merge`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/ch19/test_cg_real_bins_tolerance_and_merge.sv) | legal | `spec` | `I- V- K- Gp` |
| [`ch19/test_cg_real_coverpoint_cross`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/ch19/test_cg_real_coverpoint_cross.sv) | legal | `spec` | `I- V- K- Gp` |
| [`ch19/test_cg_real_fixed_bin_items_and_names`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/ch19/test_cg_real_fixed_bin_items_and_names.sv) | legal | `spec` | `I- V- K- Gp` |
| [`ch19/test_cg_real_fixed_bins_listed_order`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/ch19/test_cg_real_fixed_bins_listed_order.sv) | legal | `spec` | `I- V- K- Gp` |
| [`ch19/test_cg_real_interval_covergroup_level`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/ch19/test_cg_real_interval_covergroup_level.sv) | legal | `spec` | `I- V- K- Gp` |
| [`ch19/test_cg_real_open_bin_names_merge`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/ch19/test_cg_real_open_bin_names_merge.sv) | legal | `spec` | `I- V- K- Gp` |
| [`ch19/test_option_member_defaults`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/ch19/test_option_member_defaults.sv) | legal | `spec` | `I- V- K- Gp` |
| [`ch19/test_option_struct_member_types`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/ch19/test_option_struct_member_types.sv) | legal | `spec` | `I- V- K- Gp` |
| [`ch19/test_option_struct_members`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/ch19/test_option_struct_members.sv) | legal | `spec` | `I- V- K- Gp` |
| [`ch19/test_illegal_cg_cross_real_variable`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/ch19/test_illegal_cg_cross_real_variable.sv) | illegal | `spec` | `Ip V- Kp Gp` |
| [`ch19/test_illegal_cg_real_bins_with`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/ch19/test_illegal_cg_real_bins_with.sv) | illegal | `spec` | `Ip V- Kp Gp` |
| [`ch19/test_illegal_cg_real_default_bin_array`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/ch19/test_illegal_cg_real_default_bin_array.sv) | illegal | `spec` | `Ip V- Kp Gp` |
| [`ch19/test_illegal_cg_real_default_bin_n`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/ch19/test_illegal_cg_real_default_bin_n.sv) | illegal | `spec` | `Ip V- Kp Gp` |
| [`ch19/test_illegal_cg_real_no_bins`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/ch19/test_illegal_cg_real_no_bins.sv) | illegal | `spec` | `Ip V- Kp Gp` |
| [`ch19/test_illegal_cg_real_transition_bins`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/ch19/test_illegal_cg_real_transition_bins.sv) | illegal | `spec` | `Ip V- Kp Gp` |
| [`ch19/test_illegal_cg_real_transition_domain`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/ch19/test_illegal_cg_real_transition_domain.sv) | illegal | `spec` | `Ip V- Kp Gp` |
| [`ch19/test_illegal_cg_real_wildcard`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/ch19/test_illegal_cg_real_wildcard.sv) | illegal | `spec` | `Ip V- Kp Gp` |
| [`gen/ch19/test_gen_cglevel_type_option_real_interval_cross`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/gen/ch19/test_gen_cglevel_type_option_real_interval_cross.sv) | illegal | `spec` | `Ip V- Kp Gp` |

<a id="stacktrace"></a>

## $stacktrace

- Clauses: 20.17.2, 11.2.1
- Illegal forms the standard defines: Syntax 20-18 gives $stacktrace no arguments, so a call with an argument is not valid. (20.17.2); $stacktrace is not among the system functions allowed in constant system function calls, so it cannot appear in a constant expression such as a parameter value. (11.2.1)
- Requirements (mapped / rows): `SV2023-20.17.2-EXTRACT-STACKTRACE-CONTEXT` (-), `SV2023-20.17.2-EXTRACT-STACKTRACE-RESULT` (-)

| Test | Kind | `:oracle:` | Saved results |
| --- | --- | --- | --- |
| [`ch20/test_stacktrace_function`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/ch20/test_stacktrace_function.sv) | legal | `spec verilator@5.052` | `I- Vp Kp Gp` |
| [`ch20/test_stacktrace_function_call_contexts`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/ch20/test_stacktrace_function_call_contexts.sv) | legal | `spec verilator@5.052` | `I- Vp Kp Gp` |
| [`ch20/test_stacktrace_function_string_value`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/ch20/test_stacktrace_function_string_value.sv) | legal | `spec verilator@5.052` | `I- Vp K- Gp` |
| [`ch11/test_illegal_stacktrace_in_constant_expression`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/ch11/test_illegal_stacktrace_in_constant_expression.sv) | illegal | `spec verilator@5.052` | `Ip Vp Kp Gp` |
| [`ch13/test_illegal_stacktrace_in_constant_function`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/ch13/test_illegal_stacktrace_in_constant_function.sv) | illegal | `spec verilator@5.054` | `Ip Vp Kp Gp` |
| [`ch20/test_illegal_stacktrace_argument`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/ch20/test_illegal_stacktrace_argument.sv) | illegal | `spec verilator@5.052` | `I- Vp Kp Gp` |

<a id="timeunit-timeprecision-functions"></a>

## $timeunit and $timeprecision system functions

- Clauses: 20.4, 20.4.1, 11.2.1
- Illegal forms the standard defines: None.
- Requirements (mapped / rows): `SV2023-20.4.1-EXTRACT-COMPILATION-SCOPE`, `SV2023-20.4.1-EXTRACT-CURRENT-SCOPE`, `SV2023-20.4.1-EXTRACT-EXPONENT-RANGE`, `SV2023-20.4.1-EXTRACT-NAMED-SCOPE`, `SV2023-20.4.1-EXTRACT-ROOT-SCOPE`, `SV2023-20.4.1-EXTRACT-TIMESCALE-QUERIES`, `SV2023-11.2.1-EXTRACT-CONSTANT-TIMESCALE-NAME`, `SV2023-20.4.1-EXTRACT-EXPONENT-0`, `SV2023-20.4.1-EXTRACT-EXPONENT-1`, `SV2023-20.4.1-EXTRACT-EXPONENT-2`, `SV2023-20.4.1-EXTRACT-EXPONENT-NEG1`, `SV2023-20.4.1-EXTRACT-EXPONENT-NEG2`, `SV2023-20.4.1-EXTRACT-EXPONENT-NEG3`, `SV2023-20.4.1-EXTRACT-EXPONENT-NEG4`, `SV2023-20.4.1-EXTRACT-EXPONENT-NEG5`, `SV2023-20.4.1-EXTRACT-EXPONENT-NEG6`, `SV2023-20.4.1-EXTRACT-EXPONENT-NEG7`, `SV2023-20.4.1-EXTRACT-EXPONENT-NEG8`, `SV2023-20.4.1-EXTRACT-EXPONENT-NEG9`, `SV2023-20.4.1-EXTRACT-EXPONENT-NEG10`, `SV2023-20.4.1-EXTRACT-EXPONENT-NEG11`, `SV2023-20.4.1-EXTRACT-EXPONENT-NEG12`, `SV2023-20.4.1-EXTRACT-EXPONENT-NEG13`, `SV2023-20.4.1-EXTRACT-EXPONENT-NEG14`, `SV2023-20.4.1-EXTRACT-EXPONENT-NEG15`

| Test | Kind | `:oracle:` | Saved results |
| --- | --- | --- | --- |
| [`ch11/test_expr_timescale_constants`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/ch11/test_expr_timescale_constants.sv) | legal | `spec` | `I- V- K- Gp` |
| [`ch20/test_timeprecision_exponent_table`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/ch20/test_timeprecision_exponent_table.sv) | legal | `spec` | `I- V- Kp Gp` |
| [`ch20/test_timeunit_exponent_table`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/ch20/test_timeunit_exponent_table.sv) | legal | `spec verilator@5.052` | `I- Vp Kp Gp` |
| [`ch20/test_timeunit_package_interface_program_nested`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/ch20/test_timeunit_package_interface_program_nested.sv) | legal | `spec` | `I- V- Kp Gp` |
| [`ch20/test_timeunit_timeprecision_functions`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/ch20/test_timeunit_timeprecision_functions.sv) | legal | `spec` | `I- V- Kp Gp` |
| [`ch20/test_timeunit_timescale_precedence`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/ch20/test_timeunit_timescale_precedence.sv) | legal | `spec` | `I- V- Kp Gp` |
| [`ch20/test_timeunit_unit_root`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/ch20/test_timeunit_unit_root.sv) | legal | `spec` | `I- V- Kp Gp` |
| [`imported/ch20/test_time_query_matrix`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/imported/ch20/test_time_query_matrix.sv) | legal | `spec` | `I- V- Kp Gp` |

<a id="type-parameter-restriction"></a>

## Restricted type parameters (type enum/struct/union/class/interface class)

- Clauses: 6.20.3
- Illegal forms the standard defines: It is an error to give a restricted type parameter a type that does not belong to the stated basic category. (6.20.3)
- Requirements (mapped / rows): `SV2023-6.20.3-EXTRACT-BASIC-TYPE-RESTRICTION`, `SV2023-6.20.3-EXTRACT-RESTRICTION-CONFORMANCE`

| Test | Kind | `:oracle:` | Saved results |
| --- | --- | --- | --- |
| [`ch6/test_parameter_declaration_forms`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/ch6/test_parameter_declaration_forms.sv) | legal | `spec verilator@5.052` | `I- Vp Kp Gp` |
| [`ch6/test_type_param_restricted_abstract_final_scoped`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/ch6/test_type_param_restricted_abstract_final_scoped.sv) | legal | `spec verilator@5.054` | `I- Vp K- Gp` |
| [`ch6/test_type_param_restricted_class_and_interface_lists`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/ch6/test_type_param_restricted_class_and_interface_lists.sv) | legal | `spec verilator@5.052` | `I- Vp Kp Gp` |
| [`ch6/test_type_param_restricted_conforming_types`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/ch6/test_type_param_restricted_conforming_types.sv) | legal | `spec verilator@5.052` | `I- Vp Kp Gp` |
| [`ch6/test_type_param_restricted_kinds`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/ch6/test_type_param_restricted_kinds.sv) | legal | `spec verilator@5.052` | `I- Vp Kp Gp` |
| [`ch6/test_illegal_class_restricted_type_parameter_via_type_parameter`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/ch6/test_illegal_class_restricted_type_parameter_via_type_parameter.sv) | illegal | `spec verilator@5.054` | `Ip Vp Kp Gp` |
| [`ch6/test_illegal_enum_restricted_type_parameter_default_int`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/ch6/test_illegal_enum_restricted_type_parameter_default_int.sv) | illegal | `spec` | `Ip V- Kp Gp` |
| [`ch6/test_illegal_enum_restricted_type_parameter_given_int`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/ch6/test_illegal_enum_restricted_type_parameter_given_int.sv) | illegal | `spec verilator@5.052` | `Ip Vp Kp Gp` |
| [`ch6/test_illegal_interface_class_restricted_type_parameter_given_class`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/ch6/test_illegal_interface_class_restricted_type_parameter_given_class.sv) | illegal | `spec` | `I- V- Kp Gp` |
| [`ch6/test_illegal_struct_restricted_type_parameter_given_union`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/ch6/test_illegal_struct_restricted_type_parameter_given_union.sv) | illegal | `spec verilator@5.052` | `Ip Vp Kp Gp` |

<a id="constructor-default-arguments"></a>

## default in constructor argument lists (function new(default...), super.new(default), extends Base(default))

- Clauses: 8.17, 8.3, 8.15
- Illegal forms the standard defines: default may appear at most once in a constructor argument list, only in a subclass, must not be combined with an argument that repeats a superclass argument name, and is an error when a superclass argument default refers to a local member. (8.17); super.new(default) is an error when the constructor argument list has no default; with extends Base(default) a user-defined constructor must contain default. (8.17)
- Requirements (mapped / rows): `SV2023-8.3-EXTRACT-CLASS-DECLARATION`, `SV2023-8.3-EXTRACT-ONE-CONSTRUCTOR-DEFAULT`, `SV2023-8.15-EXTRACT-IMPLICIT-SUPER-NEW`, `SV2023-8.17-EXTRACT-AFTER-DEFAULT-ARGUMENT`, `SV2023-8.17-EXTRACT-DEFAULT-EXPANSION`, `SV2023-8.17-EXTRACT-DEFAULT-NAME-CONFLICT`, `SV2023-8.17-EXTRACT-DEFAULT-ONCE`, `SV2023-8.17-EXTRACT-DEFAULT-REQUIRES-SUBCLASS`, `SV2023-8.17-EXTRACT-EXTENDS-DEFAULT-EXPLICIT`, `SV2023-8.17-EXTRACT-EXTENDS-DEFAULT-IMPLICIT`, `SV2023-8.17-EXTRACT-IMPLICIT-DEFAULT-FORWARD`, `SV2023-8.17-EXTRACT-NO-LOCAL-DEFAULT-DEPENDENCY`, `SV2023-8.17-EXTRACT-SUPER-DEFAULT-FORWARD`, `SV2023-8.17-EXTRACT-SUPER-DEFAULT-REQUIRES-EXPANSION`

| Test | Kind | `:oracle:` | Saved results |
| --- | --- | --- | --- |
| [`ch8/test_class_constructor_default_argument_expansion`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/ch8/test_class_constructor_default_argument_expansion.sv) | legal | `spec` | `I- V- Kp Gp` |
| [`ch8/test_constructor_default_argument`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/ch8/test_constructor_default_argument.sv) | legal | `spec` | `I- V- Kp Gp` |
| [`ch8/test_constructor_default_empty_and_inout`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/ch8/test_constructor_default_empty_and_inout.sv) | legal | `spec` | `I- V- K- Gp` |
| [`ch8/test_constructor_default_parameterized_superclass`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/ch8/test_constructor_default_parameterized_superclass.sv) | legal | `spec` | `I- V- K- Gp` |
| [`ch8/test_constructor_default_through_implicit_constructor`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/ch8/test_constructor_default_through_implicit_constructor.sv) | legal | `spec` | `I- V- K- Gp` |
| [`ch8/test_super_new_default`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/ch8/test_super_new_default.sv) | legal | `spec` | `I- V- K- Gp` |
| [`ch8/test_illegal_constructor_default_name_conflict`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/ch8/test_illegal_constructor_default_name_conflict.sv) | illegal | `spec` | `Ip Vp Kp Gp` |
| [`ch8/test_illegal_constructor_default_outside_subclass`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/ch8/test_illegal_constructor_default_outside_subclass.sv) | illegal | `spec` | `Ip Vp Kp Gp` |
| [`ch8/test_illegal_constructor_default_repeated`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/ch8/test_illegal_constructor_default_repeated.sv) | illegal | `spec` | `Ip Vp Kp Gp` |
| [`ch8/test_illegal_constructor_default_twice`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/ch8/test_illegal_constructor_default_twice.sv) | illegal | `spec` | `Ip Vp Kp Gp` |
| [`ch8/test_illegal_default_depends_on_local_member`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/ch8/test_illegal_default_depends_on_local_member.sv) | illegal | `spec` | `Ip Vp Kp Gp` |
| [`ch8/test_illegal_extends_default_without_default_argument`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/ch8/test_illegal_extends_default_without_default_argument.sv) | illegal | `spec` | `I- V- Kp Gp` |
| [`ch8/test_illegal_super_default_without_expansion`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/ch8/test_illegal_super_default_without_expansion.sv) | illegal | `spec` | `Ip Vp Kp Gp` |
| [`ch8/test_illegal_super_new_default_with_extends_default`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/ch8/test_illegal_super_new_default_with_extends_default.sv) | illegal | `spec` | `I- Vp Kp Gp` |
| [`ch8/test_illegal_super_new_default_without_default`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/ch8/test_illegal_super_new_default_without_default.sv) | illegal | `spec` | `Ip Vp Kp Gp` |

<a id="array-map-method"></a>

## map array method

- Clauses: 7.12.5, 7.12
- Illegal forms the standard defines: map() requires a with clause, and the result keeps the dimension range and index type of the source array, so assigning it to an array with another element type or index type is an error. (7.12.5)
- Requirements (mapped / rows): `SV2023-7.12.5-EXTRACT-MAP-REQUIRED-WITH`, `SV2023-7.12.5-EXTRACT-MAP-SELF-DETERMINED-TYPE`, `SV2023-7.12.5-EXTRACT-MAP-SHAPE`

| Test | Kind | `:oracle:` | Saved results |
| --- | --- | --- | --- |
| [`ch7/test_array_map_method`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/ch7/test_array_map_method.sv) | legal | `spec` | `I- V- K- Gp` |
| [`ch7/test_map_element_types_and_index_names`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/ch7/test_map_element_types_and_index_names.sv) | legal | `spec` | `I- V- K- Gp` |
| [`ch7/test_map_result_to_same_array`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/ch7/test_map_result_to_same_array.sv) | legal | `spec verilator@5.052` | `I- Vp K- Gp` |
| [`ch7/test_map_result_type_range_and_keys`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/ch7/test_map_result_type_range_and_keys.sv) | legal | `spec` | `I- V- K- Gp` |
| [`ch7/test_map_selects_order_and_empty`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/ch7/test_map_selects_order_and_empty.sv) | legal | `spec` | `I- V- K- Gp` |
| [`ch7/test_illegal_map_assoc_result_to_other_index_type`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/ch7/test_illegal_map_assoc_result_to_other_index_type.sv) | illegal | `spec` | `Ip V- Kp Gp` |
| [`ch7/test_illegal_map_int_elements_to_string_queue`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/ch7/test_illegal_map_int_elements_to_string_queue.sv) | illegal | `spec` | `Ip V- Kp Gp` |
| [`ch7/test_illegal_map_without_with`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/ch7/test_illegal_map_without_with.sv) | illegal | `spec verilator@5.052` | `I- Vp Kp Gp` |

<a id="soft-packed-union"></a>

## union soft (soft packed union)

- Clauses: 7.3.1, 7.3, 7.2
- Illegal forms the standard defines: A union followed by a packed dimension must carry soft or packed (or both); without either it is an error. (7.3)
- Requirements (mapped / rows): `SV2023-7.2-EXTRACT-UNION-DIMENSION-QUALIFIER`, `SV2023-7.3-EXTRACT-AGGREGATE-FOOTNOTES`, `SV2023-7.3-EXTRACT-UNION-GRAMMAR`, `SV2023-7.3.1-EXTRACT-SOFT-RECURSIVE`, `SV2023-7.3.1-EXTRACT-SOFT-RIGHT-ALIGN`, `SV2023-7.3.1-EXTRACT-SOFT-SIZE`, `SV2023-7.3.1-EXTRACT-SOFT-VARYING-SIZE`, `SV2023-7.3.1-EXTRACT-SOFT-WRITE-HIGH-UNCHANGED`

| Test | Kind | `:oracle:` | Saved results |
| --- | --- | --- | --- |
| [`ch37/test_vpi_struct_union_flags_members`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/ch37/test_vpi_struct_union_flags_members.sv) | legal | `spec` | `I- V- K- Gp` |
| [`ch37/test_vpi_struct_union_net_flags`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/ch37/test_vpi_struct_union_net_flags.sv) | legal | `spec` | `I- V- K- Gp` |
| [`ch6/test_data_type_keyword_forms`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/ch6/test_data_type_keyword_forms.sv) | legal | `spec verilator@5.052` | `I- Vp Kp Gp` |
| [`ch7/test_soft_packed_union`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/ch7/test_soft_packed_union.sv) | legal | `spec verilator@5.052` | `I- Vp Kp Gp` |
| [`ch7/test_soft_packed_union_nested_layout`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/ch7/test_soft_packed_union_nested_layout.sv) | legal | `spec verilator@5.052` | `I- Vp Kp Gp` |
| [`ch7/test_tagged_union_keywords_and_members`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/ch7/test_tagged_union_keywords_and_members.sv) | legal | `spec` | `I- V- K- Gp` |
| [`ch7/test_union_grammar_forms`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/ch7/test_union_grammar_forms.sv) | legal | `spec` | `I- V- K- Gp` |
| [`ch7/test_illegal_union_packed_dimension_needs_soft_or_packed`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/ch7/test_illegal_union_packed_dimension_needs_soft_or_packed.sv) | illegal | `spec verilator@5.054` | `I- Vp Kp Gp` |

<a id="triple-quoted-string"></a>

## Triple-quoted string literals

- Clauses: 5.9, 5.9.1, A.8.8, 22.5.1
- Illegal forms the standard defines: In macro text, an unescaped newline inside a grave-accent triple quote ends the macro definition (unlike inside a plain triple-quoted literal), and an ordinary quote there starts a string literal that must close on its line; text left over is ordinary source and is an error. (22.5.1)
- Requirements (mapped / rows): `SV2023-5.9-EXTRACT-STRING-DELIMITERS`, `SV2023-5.9-EXTRACT-TRIPLE-CHARACTERS`, `SV2023-5.9-EXTRACT-TRIPLE-ESCAPE-SAME`, `SV2023-5.9-EXTRACT-TRIPLE-RAW-NEWLINE`, `SV2023-5.9-EXTRACT-TRIPLE-RAW-QUOTE`, `SV2023-5.9.1-EXTRACT-TRIPLE-ESCAPES-SUPPORTED`, `SV2023-A.8.8-EXTRACT-ITEMS`, `SV2023-A.8.8-EXTRACT-STRING`, `SV2023-22.5.1-EXTRACT-MACRO-ARGUMENT-DELIMITERS`, `SV2023-22.5.1-EXTRACT-MACRO-LINE-CONTINUATION`, `SV2023-22.5.1-EXTRACT-MACRO-MIXED-QUOTES`, `SV2023-22.5.1-EXTRACT-MACRO-TRIPLE-QUOTE`, `SV2023-22.5.1-EXTRACT-MACRO-TRIPLE-STRING`

| Test | Kind | `:oracle:` | Saved results |
| --- | --- | --- | --- |
| [`ch22/test_macro_grave_triple_quote`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/ch22/test_macro_grave_triple_quote.sv) | legal | `spec` | `I- V- Kp Gp` |
| [`ch22/test_macro_grave_triple_quote_expansion_steps`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/ch22/test_macro_grave_triple_quote_expansion_steps.sv) | legal | `spec` | `I- V- Kp Gp` |
| [`ch22/test_macro_grave_triple_quote_inner_quotes`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/ch22/test_macro_grave_triple_quote_inner_quotes.sv) | legal | `spec verilator@5.052` | `I- Vp Kp Gp` |
| [`ch22/test_macro_triple_quoted_string_newline`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/ch22/test_macro_triple_quoted_string_newline.sv) | legal | `spec verilator@5.052` | `I- Vp Kp Gp` |
| [`ch5/test_string_backslash_newline_continuation`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/ch5/test_string_backslash_newline_continuation.sv) | legal | `spec verilator@5.052` | `I- Vp Kp Gp` |
| [`ch5/test_triple_quoted_and_quoted_string_contents`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/ch5/test_triple_quoted_and_quoted_string_contents.sv) | legal | `spec verilator@5.052` | `I- Vp Kp Gp` |
| [`ch5/test_triple_quoted_string`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/ch5/test_triple_quoted_string.sv) | legal | `spec verilator@5.052` | `I- Vp Kp Gp` |
| [`ch22/test_illegal_macro_grave_triple_quote_newline_ends_text`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/ch22/test_illegal_macro_grave_triple_quote_newline_ends_text.sv) | illegal | `spec` | `Ip V- Kp Gp` |
| [`ch22/test_illegal_macro_grave_triple_quote_plain_quote_unclosed`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/ch22/test_illegal_macro_grave_triple_quote_plain_quote_unclosed.sv) | illegal | `spec` | `I- V- Kp Gp` |

<a id="rand-real"></a>

## rand real variables

- Clauses: 18.4, 18.4.1, 18.5.3, 18.5.4, 18.5.5, 18.5.6, 18.5.9
- Illegal forms the standard defines: A real variable (or an array of reals) shall not be declared randc. (18.4); A real range in a dist requires an explicit :/ weight; omitting it or using := is an error. (18.5.3)
- Requirements (mapped / rows): `SV2023-18.4-EXTRACT-SINGULAR-TYPES`, `SV2023-18.4.1-EXTRACT-REAL-UNIFORM`, `SV2023-18.5.3-EXTRACT-DIST-ITEM-TYPES`, `SV2023-18.5.3-EXTRACT-REAL-SINGLE-WEIGHT`, `SV2023-18.5.4-EXTRACT-UNIQUE-GROUP`, `SV2023-18.5.5-EXTRACT-IMPLICATION-FORM`, `SV2023-18.5.6-EXTRACT-IF-FORM`, `SV2023-18.5.9-EXTRACT-ORDER-VARIABLE-TYPES`

| Test | Kind | `:oracle:` | Saved results |
| --- | --- | --- | --- |
| [`ch18/test_rand_real_constraint`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/ch18/test_rand_real_constraint.sv) | legal | `spec` | `I- V- K- Gp` |
| [`ch18/test_rand_real_kinds_and_arrays`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/ch18/test_rand_real_kinds_and_arrays.sv) | legal | `spec` | `I- V- K- Gp` |
| [`ch18/test_rand_real_uniform_and_dist`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/ch18/test_rand_real_uniform_and_dist.sv) | legal | `spec` | `I- V- K- Gp` |
| [`ch18/test_rand_real_unique_and_conditions`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/ch18/test_rand_real_unique_and_conditions.sv) | legal | `spec` | `I- V- K- Gp` |
| [`ch18/test_illegal_dist_real_range_colon_equal`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/ch18/test_illegal_dist_real_range_colon_equal.sv) | illegal | `spec` | `Ip Vp Kp Gp` |
| [`ch18/test_illegal_dist_real_range_no_weight`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/ch18/test_illegal_dist_real_range_no_weight.sv) | illegal | `spec` | `Ip Vp Kp Gp` |
| [`ch18/test_illegal_dist_real_tolerance_colon_equal`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/ch18/test_illegal_dist_real_tolerance_colon_equal.sv) | illegal | `spec` | `Ip V- Kp Gp` |
| [`ch18/test_illegal_randc_real`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/ch18/test_illegal_randc_real.sv) | illegal | `spec` | `I- Vp Kp Gp` |
| [`ch18/test_illegal_randc_real_array`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/ch18/test_illegal_randc_real_array.sv) | illegal | `spec` | `I- Vp Kp Gp` |
| [`ch18/test_illegal_unique_real_and_int`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/ch18/test_illegal_unique_real_and_int.sv) | illegal | `spec` | `Ip V- Kp Gp` |

<a id="constraint-dynamic-override"></a>

## constraint :initial / :extends / :final

- Clauses: 18.5.2, 18.5, 18.5.10, 8.3
- Illegal forms the standard defines: :initial must not replace a base constraint; :extends must replace one; :initial and :extends are mutually exclusive; a :final constraint cannot be replaced by a subclass; the specifiers must appear on both the prototype and the external block or on neither. (18.5.2); A pure constraint shall not use final, and static constraints shall not use dynamic override specifiers (18.5.10). (18.5)
- Requirements (mapped / rows): `SV2023-8.3-EXTRACT-NO-PURE-FINAL`, `SV2023-18.5-EXTRACT-PURE-NO-FINAL`, `SV2023-18.5-EXTRACT-STATIC-NO-OVERRIDE`, `SV2023-18.5.2-EXTRACT-EXTENDS-REQUIRES-OVERRIDE`, `SV2023-18.5.2-EXTRACT-FINAL-CONSTRAINT`, `SV2023-18.5.2-EXTRACT-INITIAL-EXTENDS-EXCLUSIVE`, `SV2023-18.5.2-EXTRACT-INITIAL-NO-OVERRIDE`, `SV2023-18.5.2-EXTRACT-MATCH-PROTOTYPE-SPECIFIERS`, `SV2023-18.5.10-EXTRACT-STATIC-NO-SPECIFIER`, `SV2023-A.10-EXTRACT-FOOTNOTE-11`, `SV2023-A.10-EXTRACT-FOOTNOTE-8`

| Test | Kind | `:oracle:` | Saved results |
| --- | --- | --- | --- |
| [`ch18/test_constraint_final_constraint_mode_inline`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/ch18/test_constraint_final_constraint_mode_inline.sv) | legal | `spec verilator@5.054` | `I- Vp K- Gp` |
| [`ch18/test_constraint_override_specifiers_prototypes_pure_param`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/ch18/test_constraint_override_specifiers_prototypes_pure_param.sv) | legal | `spec verilator@5.054` | `I- Vp K- Gp` |
| [`ch18/test_constraint_override_specifiers_three_levels`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/ch18/test_constraint_override_specifiers_three_levels.sv) | legal | `spec verilator@5.054` | `I- Vp K- Gp` |
| [`ch18/test_constraint_prototype_and_specifier_forms`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/ch18/test_constraint_prototype_and_specifier_forms.sv) | legal | `spec verilator@5.052` | `I- Vp K- Gp` |
| [`ch18/test_illegal_constraint_extends_no_override`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/ch18/test_illegal_constraint_extends_no_override.sv) | illegal | `spec` | `Ip V- Kp Gp` |
| [`ch18/test_illegal_constraint_final_replaced`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/ch18/test_illegal_constraint_final_replaced.sv) | illegal | `spec` | `Ip V- Kp Gp` |
| [`ch18/test_illegal_constraint_final_replacement_replaced`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/ch18/test_illegal_constraint_final_replacement_replaced.sv) | illegal | `spec` | `Ip V- Kp Gp` |
| [`ch18/test_illegal_constraint_initial_extends`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/ch18/test_illegal_constraint_initial_extends.sv) | illegal | `spec verilator@5.052` | `Ip Vp Kp Gp` |
| [`ch18/test_illegal_constraint_initial_override`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/ch18/test_illegal_constraint_initial_override.sv) | illegal | `spec` | `Ip V- Kp Gp` |
| [`ch18/test_illegal_constraint_specifier_block_mismatch`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/ch18/test_illegal_constraint_specifier_block_mismatch.sv) | illegal | `spec` | `Ip V- Kp Gp` |
| [`ch18/test_illegal_constraint_specifier_prototype_mismatch`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/ch18/test_illegal_constraint_specifier_prototype_mismatch.sv) | illegal | `spec` | `Ip V- Kp Gp` |
| [`ch18/test_illegal_pure_constraint_final`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/ch18/test_illegal_pure_constraint_final.sv) | illegal | `spec` | `Ip Vp Kp Gp` |
| [`ch18/test_illegal_static_constraint_override`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/ch18/test_illegal_static_constraint_override.sv) | illegal | `spec` | `Ip V- Kp Gp` |
| [`ch18/test_illegal_static_constraint_specifier`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/ch18/test_illegal_static_constraint_specifier.sv) | illegal | `spec` | `Ip V- Kp Gp` |
| [`ch8/test_illegal_pure_constraint_final`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/ch8/test_illegal_pure_constraint_final.sv) | illegal | `spec` | `Ip Vp Kp Gp` |

<a id="weak-reference"></a>

## weak_reference class

- Clauses: 8.29, 8.30, 8.30.1, 8.30.2, 8.30.3, 8.30.4, 8.30.5, G.7, G.1
- Illegal forms the standard defines: weak_reference takes a class type parameter; specializing it with any other type (for example int) is a compilation error. (8.30.1)
- Requirements (mapped / rows): `SV2023-8.29-EXTRACT-UNREACHABLE` (-), `SV2023-8.29-EXTRACT-WEAK-RECLAMATION-REFERENCE` (-), `SV2023-8.29-EXTRACT-WEAKLY-REACHABLE` (-), `SV2023-8.30.1-EXTRACT-ATOMIC-WEAK-CLEAR` (-), `SV2023-8.30.1-EXTRACT-STD-WEAK-REFERENCE`, `SV2023-8.30.1-EXTRACT-WEAK-CLASS-TYPE`, `SV2023-8.30.1-EXTRACT-WEAK-REFERENCE-NONRETAINING` (-), `SV2023-8.30.1-EXTRACT-WEAK-WRAPPER-GC` (-), `SV2023-8.30.2-EXTRACT-NULL-NO-WARNING`, `SV2023-8.30.2-EXTRACT-SIGNATURE`, `SV2023-8.30.2-EXTRACT-WRAPPER-IDENTITY`, `SV2023-8.30.3-EXTRACT-GET-EVENT-CONTROL`, `SV2023-8.30.3-EXTRACT-GET-REFERENT`, `SV2023-8.30.3-EXTRACT-SIGNATURE`, `SV2023-8.30.4-EXTRACT-CLEAR-NULL`, `SV2023-8.30.4-EXTRACT-SIGNATURE`, `SV2023-8.30.5-EXTRACT-LIFETIME-UNIQUE-ID`, `SV2023-8.30.5-EXTRACT-NULL-ZERO`, `SV2023-8.30.5-EXTRACT-NUMERIC-ID-NONRETAINING` (-), `SV2023-8.30.5-EXTRACT-SIGNATURE`, `SV2023-8.30.5-EXTRACT-STABLE-POLYMORPHIC-ID`, `SV2023-G.1-EXTRACT-CONTENTS`, `SV2023-G.7-EXTRACT-CLEAR`, `SV2023-G.7-EXTRACT-GET`, `SV2023-G.7-EXTRACT-ID`, `SV2023-G.7-EXTRACT-NEW`, `SV2023-G.7-EXTRACT-PARAMETER`

| Test | Kind | `:oracle:` | Saved results |
| --- | --- | --- | --- |
| [`ch26/test_std_package_system_types`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/ch26/test_std_package_system_types.sv) | legal | `spec` | `I- V- K- Gp` |
| [`ch8/test_object_strongly_reachable`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/ch8/test_object_strongly_reachable.sv) | legal | `spec` | `I- V- K- Gp` |
| [`ch8/test_weak_reference_clear_void_no_arguments`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/ch8/test_weak_reference_clear_void_no_arguments.sv) | legal | `spec` | `I- V- K- Gp` |
| [`ch8/test_weak_reference_get_clear`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/ch8/test_weak_reference_get_clear.sv) | legal | `spec` | `I- V- K- Gp` |
| [`ch8/test_weak_reference_get_id`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/ch8/test_weak_reference_get_id.sv) | legal | `spec` | `I- V- K- Gp` |
| [`ch8/test_weak_reference_get_id_static_longint`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/ch8/test_weak_reference_get_id_static_longint.sv) | legal | `spec` | `I- V- K- Gp` |
| [`ch8/test_weak_reference_get_id_unique_across_types`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/ch8/test_weak_reference_get_id_unique_across_types.sv) | legal | `spec` | `I- V- K- Gp` |
| [`ch8/test_weak_reference_id_alias_after_clear`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/ch8/test_weak_reference_id_alias_after_clear.sv) | legal | `spec` | `I- V- K- Gp` |
| [`ch8/test_weak_reference_null_referent_no_warning`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/ch8/test_weak_reference_null_referent_no_warning.sv) | legal | `spec` | `I- V- K- Gp` |
| [`ch8/test_weak_reference_prototypes`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/ch8/test_weak_reference_prototypes.sv) | legal | `spec` | `I- V- K- Gp` |
| [`ch8/test_weak_reference_std_scope_and_strong_reachability`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/ch8/test_weak_reference_std_scope_and_strong_reachability.sv) | legal | `spec` | `I- V- K- Gp` |
| [`ch8/test_weak_reference_wait_cleared`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/ch8/test_weak_reference_wait_cleared.sv) | legal | `spec` | `I- V- K- Gp` |
| [`ch8/test_illegal_weak_reference_scalar_type`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/ch8/test_illegal_weak_reference_scalar_type.sv) | illegal | `spec` | `Ip Vp Kp Gp` |

<a id="covergroup-inheritance"></a>

## covergroup extends (derived embedded covergroup)

- Clauses: 19.3, 19.4, 19.4.1, A.2.11
- Illegal forms the standard defines: The extends form of a covergroup is allowed only inside a class. (19.3); covergroup extends must name a covergroup that exists in a base class (a missing base is an error); the derived covergroup takes the base arguments and coverage event, so it cannot declare its own. (19.4.1); A derived covergroup shall not define a new coverage model for a local member of the base class. (19.4)
- Requirements (mapped / rows): `SV2023-19.3-EXTRACT-EXTENDS-CLASS-ONLY`, `SV2023-19.4-EXTRACT-ENCAPSULATED-PROPERTIES`, `SV2023-19.4.1-EXTRACT-ADD-COVERPOINT`, `SV2023-19.4.1-EXTRACT-DISTINCT-COVERAGE-TYPES`, `SV2023-19.4.1-EXTRACT-EMBEDDED-EXTENDS`, `SV2023-19.4.1-EXTRACT-INHERIT-ARGS-EVENT`, `SV2023-19.4.1-EXTRACT-INHERIT-COMPONENTS`, `SV2023-19.4.1-EXTRACT-OVERRIDE-COVERPOINT`, `SV2023-19.4.1-EXTRACT-OVERRIDE-OPTIONS`, `SV2023-19.4.1-EXTRACT-REPLACE-INSTANCE`, `SV2023-A.10-EXTRACT-FOOTNOTE-29`, `SV2023-A.2.11-EXTRACT-COVERGROUP`

| Test | Kind | `:oracle:` | Saved results |
| --- | --- | --- | --- |
| [`ch19/test_cg_derived_option_override`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/ch19/test_cg_derived_option_override.sv) | legal | `spec` | `I- V- K- Gp` |
| [`ch19/test_cg_embedded_inheritance`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/ch19/test_cg_embedded_inheritance.sv) | legal | `spec` | `I- V- K- Gp` |
| [`ch19/test_cg_extends_inherited_event_base_handle`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/ch19/test_cg_extends_inherited_event_base_handle.sv) | legal | `spec` | `I- V- K- Gp` |
| [`ch19/test_cg_extends_type_option_inherited`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/ch19/test_cg_extends_type_option_inherited.sv) | legal | `spec` | `I- V- K- Gp` |
| [`ch19/test_cg_inheritance_args_and_cross`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/ch19/test_cg_inheritance_args_and_cross.sv) | legal | `spec` | `I- V- K- Gp` |
| [`ch19/test_covergroup_declaration_and_option_forms`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/ch19/test_covergroup_declaration_and_option_forms.sv) | legal | `spec` | `I- V- K- Gp` |
| [`ch19/test_illegal_cg_extends_missing_base`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/ch19/test_illegal_cg_extends_missing_base.sv) | illegal | `spec` | `Ip Vp Kp Gp` |
| [`ch19/test_illegal_cg_extends_not_base`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/ch19/test_illegal_cg_extends_not_base.sv) | illegal | `spec` | `Ip Vp Kp Gp` |
| [`ch19/test_illegal_cg_extends_outside_class`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/ch19/test_illegal_cg_extends_outside_class.sv) | illegal | `spec` | `Ip Vp Kp Gp` |
| [`ch19/test_illegal_cg_extends_own_arguments`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/ch19/test_illegal_cg_extends_own_arguments.sv) | illegal | `spec` | `Ip Vp Kp Gp` |
| [`ch19/test_illegal_cg_extends_own_event`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/ch19/test_illegal_cg_extends_own_event.sv) | illegal | `spec` | `Ip Vp Kp Gp` |
| [`ch19/test_illegal_cg_extends_property_name`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/ch19/test_illegal_cg_extends_property_name.sv) | illegal | `spec` | `Ip Vp Kp Gp` |
| [`ch19/test_illegal_covergroup_derived_base_local`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/ch19/test_illegal_covergroup_derived_base_local.sv) | illegal | `spec` | `Ip V- Kp Gp` |

<a id="ref-static"></a>

## ref static arguments

- Clauses: 13.5.2, 13.3, 13.4, A.2.7
- Illegal forms the standard defines: A ref static formal shall not be given an automatic variable, an element of a dynamically sized array, a non-static class property or a ref formal without static. (13.5.2)
- Requirements (mapped / rows): `SV2023-13.5.2-EXTRACT-REF-AUTOMATIC-RESTRICTIONS`, `SV2023-13.5.2-EXTRACT-REF-STATIC-ACCEPTED-ACTUALS`, `SV2023-13.5.2-EXTRACT-REF-STATIC-ACTUALS`, `SV2023-13.5.2-EXTRACT-REF-STATIC-AUTOMATIC-CONTEXTS`, `SV2023-13.3-EXTRACT-DIRECTION-INHERITANCE`, `SV2023-13.3-EXTRACT-TASK-PORT-GRAMMAR`, `SV2023-13.4-EXTRACT-FUNCTION-DIRECTION-DEFAULT`, `SV2023-A.2.7-EXTRACT-TF-DIRECTION`

| Test | Kind | `:oracle:` | Saved results |
| --- | --- | --- | --- |
| [`ch13/test_function_formal_ref_static_direction_inherited`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/ch13/test_function_formal_ref_static_direction_inherited.sv) | legal | `spec` | `I- V- Kp Gp` |
| [`ch13/test_ref_static_accepted_actuals`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/ch13/test_ref_static_accepted_actuals.sv) | legal | `spec` | `I- V- K- Gp` |
| [`ch13/test_ref_static_const_waits_after_return`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/ch13/test_ref_static_const_waits_after_return.sv) | legal | `spec` | `I- V- Kp Gp` |
| [`ch13/test_ref_static_force_release`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/ch13/test_ref_static_force_release.sv) | legal | `spec` | `I- V- K- Gp` |
| [`ch13/test_task_direction_and_port_forms`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/ch13/test_task_direction_and_port_forms.sv) | legal | `spec` | `I- V- Kp Gp` |
| [`ch13/test_task_formal_inherits_ref_static_nonblocking`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/ch13/test_task_formal_inherits_ref_static_nonblocking.sv) | legal | `spec` | `I- V- Kp Gp` |
| [`ch13/test_tf_port_directions_ref_static_and_item_forms`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/ch13/test_tf_port_directions_ref_static_and_item_forms.sv) | legal | `spec` | `I- V- Kp Gp` |
| [`ch9/test_ref_static_fork_join_none_after_return`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/ch9/test_ref_static_fork_join_none_after_return.sv) | legal | `spec` | `I- V- Kp Gp` |
| [`gen/ch10/test_gen_ref_static_array_event_nba_w65_ascending`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/gen/ch10/test_gen_ref_static_array_event_nba_w65_ascending.sv) | legal | `spec` | `I- V- Kp Gp` |
| [`gen/ch10/test_gen_ref_static_array_event_nba_w65_descending`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/gen/ch10/test_gen_ref_static_array_event_nba_w65_descending.sv) | legal | `spec` | `I- V- Kp Gp` |
| [`gen/ch10/test_gen_ref_static_array_event_nba_w8_ascending`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/gen/ch10/test_gen_ref_static_array_event_nba_w8_ascending.sv) | legal | `spec` | `I- V- Kp Gp` |
| [`gen/ch10/test_gen_ref_static_array_event_nba_w8_descending`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/gen/ch10/test_gen_ref_static_array_event_nba_w8_descending.sv) | legal | `spec` | `I- V- Kp Gp` |
| [`gen/ch10/test_gen_ref_static_delayed_nba_w65_logic`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/gen/ch10/test_gen_ref_static_delayed_nba_w65_logic.sv) | legal | `spec` | `I- V- Kp Gp` |
| [`gen/ch10/test_gen_ref_static_delayed_nba_w8_bit`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/gen/ch10/test_gen_ref_static_delayed_nba_w8_bit.sv) | legal | `spec` | `I- V- Kp Gp` |
| [`gen/ch10/test_gen_ref_static_nested_packed_event_nba_w65_outside_parent`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/gen/ch10/test_gen_ref_static_nested_packed_event_nba_w65_outside_parent.sv) | legal | `spec` | `I- V- Kp Gp` |
| [`gen/ch10/test_gen_ref_static_nested_packed_event_nba_w65_valid`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/gen/ch10/test_gen_ref_static_nested_packed_event_nba_w65_valid.sv) | legal | `spec` | `I- V- Kp Gp` |
| [`gen/ch10/test_gen_ref_static_nested_packed_event_nba_w8_outside_parent`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/gen/ch10/test_gen_ref_static_nested_packed_event_nba_w8_outside_parent.sv) | legal | `spec` | `I- V- Kp Gp` |
| [`gen/ch10/test_gen_ref_static_nested_packed_event_nba_w8_valid`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/gen/ch10/test_gen_ref_static_nested_packed_event_nba_w8_valid.sv) | legal | `spec` | `I- V- Kp Gp` |
| [`ch13/test_illegal_ref_static_given_automatic_variable`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/ch13/test_illegal_ref_static_given_automatic_variable.sv) | illegal | `spec` | `I- V- Kp Gp` |
| [`ch13/test_illegal_ref_static_given_dynamic_array_element`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/ch13/test_illegal_ref_static_given_dynamic_array_element.sv) | illegal | `spec` | `I- V- Kp Gp` |
| [`ch13/test_illegal_ref_static_given_non_static_property`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/ch13/test_illegal_ref_static_given_non_static_property.sv) | illegal | `spec` | `I- V- Kp Gp` |
| [`ch13/test_illegal_ref_static_given_plain_ref_argument`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/ch13/test_illegal_ref_static_given_plain_ref_argument.sv) | illegal | `spec` | `I- V- Kp Gp` |

<a id="tolerance-ranges"></a>

## Tolerance ranges [A +/- B] and [A +%- B]

- Clauses: 11.4.13, 18.5.3, 19.5.1, A.2.11, A.6.7
- Illegal forms the standard defines: A real tolerance range in a dist is a real range, so it needs a :/ weight (:= is an error). Other illegal uses (a string center, a tolerance range in a unique list) follow from the definition by subtraction and addition and from the unique rule, not from a dedicated sentence. (18.5.3)
- Requirements (mapped / rows): `SV2023-11.4.13-EXTRACT-ABSOLUTE-TOLERANCE`, `SV2023-11.4.13-EXTRACT-RELATIVE-TOLERANCE`, `SV2023-11.4.13-EXTRACT-TOLERANCE-ORDER-TYPE`, `SV2023-11.4.13-EXTRACT-TOLERANCE-TRUNCATES`, `SV2023-11.4.13-EXTRACT-INSIDE-GRAMMAR`, `SV2023-18.5.3-EXTRACT-DIST-ITEM-TYPES`, `SV2023-18.5.3-EXTRACT-REAL-SINGLE-WEIGHT`, `SV2023-19.5.1-EXTRACT-REAL-TOLERANCE`, `SV2023-A.2.11-EXTRACT-COVERAGE-RANGES`, `SV2023-A.6.7-EXTRACT-VALUE-RANGE`

| Test | Kind | `:oracle:` | Saved results |
| --- | --- | --- | --- |
| [`ch11/test_expr_inside_set_forms`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/ch11/test_expr_inside_set_forms.sv) | legal | `spec` | `I- V- Kp Gp` |
| [`ch11/test_inside_ranges_tolerance_unknown_and_types`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/ch11/test_inside_ranges_tolerance_unknown_and_types.sv) | legal | `spec` | `I- V- Kp Gp` |
| [`ch11/test_inside_tolerance_center_type`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/ch11/test_inside_tolerance_center_type.sv) | legal | `spec` | `I- V- Kp Gp` |
| [`ch11/test_inside_tolerance_ranges`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/ch11/test_inside_tolerance_ranges.sv) | legal | `spec` | `I- V- Kp Gp` |
| [`ch12/test_syntax_case_matches_and_inside_forms`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/ch12/test_syntax_case_matches_and_inside_forms.sv) | legal | `spec` | `I- V- K- Gp` |
| [`ch18/test_dist_tolerance_range_weights`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/ch18/test_dist_tolerance_range_weights.sv) | legal | `spec` | `I- V- K- Gp` |
| [`ch18/test_rand_real_uniform_and_dist`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/ch18/test_rand_real_uniform_and_dist.sv) | legal | `spec` | `I- V- K- Gp` |
| [`ch19/test_cg_real_bins_tolerance_and_merge`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/ch19/test_cg_real_bins_tolerance_and_merge.sv) | legal | `spec` | `I- V- K- Gp` |
| [`ch19/test_cg_tolerance_bin_arrays_transitions`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/ch19/test_cg_tolerance_bin_arrays_transitions.sv) | legal | `spec` | `I- V- K- Gp` |
| [`ch19/test_covergroup_bins_and_range_forms`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/ch19/test_covergroup_bins_and_range_forms.sv) | legal | `spec` | `I- V- K- Gp` |
| [`gen/ch11/test_gen_cross_range_w129_s_ss_l_abs_tol_bound_x_m`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/gen/ch11/test_gen_cross_range_w129_s_ss_l_abs_tol_bound_x_m.sv) | legal | `spec` | `I- V- Kp Gp` |
| [`gen/ch11/test_gen_cross_range_w129_s_us_l_rel_tol_bound_z_m`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/gen/ch11/test_gen_cross_range_w129_s_us_l_rel_tol_bound_z_m.sv) | legal | `spec` | `I- V- Kp Gp` |
| [`gen/ch11/test_gen_cross_range_w129_w_us_b_abs_tol_known_s`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/gen/ch11/test_gen_cross_range_w129_w_us_b_abs_tol_known_s.sv) | legal | `spec` | `I- V- Kp Gp` |
| [`gen/ch11/test_gen_cross_range_w1_s_uu_b_rel_tol_lhs_x_m`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/gen/ch11/test_gen_cross_range_w1_s_uu_b_rel_tol_lhs_x_m.sv) | legal | `spec` | `I- V- Kp Gp` |
| [`gen/ch11/test_gen_cross_range_w1_s_uu_l_abs_tol_bound_z_m`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/gen/ch11/test_gen_cross_range_w1_s_uu_l_abs_tol_bound_z_m.sv) | legal | `spec` | `I- V- Kp Gp` |
| [`gen/ch11/test_gen_cross_range_w1_s_uu_l_abs_tol_lhs_x_m`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/gen/ch11/test_gen_cross_range_w1_s_uu_l_abs_tol_lhs_x_m.sv) | legal | `spec` | `I- V- Kp Gp` |
| [`gen/ch11/test_gen_cross_range_w1_s_uu_l_rel_tol_bound_x_m`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/gen/ch11/test_gen_cross_range_w1_s_uu_l_rel_tol_bound_x_m.sv) | legal | `spec` | `I- V- Kp Gp` |
| [`gen/ch11/test_gen_cross_range_w32_n_su_b_abs_tol_bound_x_s`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/gen/ch11/test_gen_cross_range_w32_n_su_b_abs_tol_bound_x_s.sv) | legal | `spec` | `I- V- Kp Gp` |
| [`gen/ch11/test_gen_cross_range_w32_w_us_b_rel_tol_bound_z_s`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/gen/ch11/test_gen_cross_range_w32_w_us_b_rel_tol_bound_z_s.sv) | legal | `spec` | `I- V- Kp Gp` |
| [`gen/ch11/test_gen_cross_range_w33_s_uu_b_abs_tol_lhs_x_s`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/gen/ch11/test_gen_cross_range_w33_s_uu_b_abs_tol_lhs_x_s.sv) | legal | `spec` | `I- V- Kp Gp` |
| [`gen/ch11/test_gen_cross_range_w33_w_su_b_rel_tol_bound_x_s`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/gen/ch11/test_gen_cross_range_w33_w_su_b_rel_tol_bound_x_s.sv) | legal | `spec` | `I- V- Kp Gp` |
| [`gen/ch11/test_gen_cross_range_w64_n_uu_l_rel_tol_lhs_x_s`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/gen/ch11/test_gen_cross_range_w64_n_uu_l_rel_tol_lhs_x_s.sv) | legal | `spec` | `I- V- Kp Gp` |
| [`gen/ch11/test_gen_cross_range_w64_w_uu_b_abs_tol_bound_z_s`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/gen/ch11/test_gen_cross_range_w64_w_uu_b_abs_tol_bound_z_s.sv) | legal | `spec` | `I- V- Kp Gp` |
| [`gen/ch11/test_gen_cross_range_w65_n_ss_l_rel_tol_known_s`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/gen/ch11/test_gen_cross_range_w65_n_ss_l_rel_tol_known_s.sv) | legal | `spec` | `I- V- Kp Gp` |
| [`gen/ch11/test_gen_cross_range_w65_n_us_l_abs_tol_known_m`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/gen/ch11/test_gen_cross_range_w65_n_us_l_abs_tol_known_m.sv) | legal | `spec` | `I- V- Kp Gp` |
| [`gen/ch11/test_gen_cross_range_w65_s_su_b_rel_tol_known_m`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/gen/ch11/test_gen_cross_range_w65_s_su_b_rel_tol_known_m.sv) | legal | `spec` | `I- V- Kp Gp` |
| [`ch11/test_illegal_inside_tolerance_string_center`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/ch11/test_illegal_inside_tolerance_string_center.sv) | illegal | `spec` | `Ip Vp Kp Gp` |
| [`ch18/test_illegal_dist_real_tolerance_colon_equal`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/ch18/test_illegal_dist_real_tolerance_colon_equal.sv) | illegal | `spec` | `Ip V- Kp Gp` |
| [`ch18/test_illegal_unique_tolerance_range`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/ch18/test_illegal_unique_tolerance_range.sv) | illegal | `spec` | `Ip Vp K- Gp` |

<a id="method-dynamic-override"></a>

## function/task :initial / :extends / :final

- Clauses: 8.20, 8.3, 8.24, 13.3, 13.4, 35.5.4, A.2.6, A.2.7
- Illegal forms the standard defines: :initial must not override a virtual or pure virtual method; :extends must override a virtual method; :initial and :extends are mutually exclusive; a :final method cannot be overridden (virtual or not); a pure virtual method cannot be :final. (8.20); The specifiers are legal only on methods of a non-interface class; a task or function outside a class, in an interface class, or a DPI import (35.5.4) cannot have them (13.3, 13.4, A.10 footnote 25). (8.3)
- Requirements (mapped / rows): `SV2023-8.3-EXTRACT-DYNAMIC-OVERRIDE-SYNTAX`, `SV2023-8.3-EXTRACT-NO-PURE-FINAL`, `SV2023-8.3-EXTRACT-OVERRIDE-NONINTERFACE-METHOD`, `SV2023-8.20-EXTRACT-EXTENDS-IMPLIES-VIRTUAL`, `SV2023-8.20-EXTRACT-EXTENDS-REQUIRES-VIRTUAL-OVERRIDE`, `SV2023-8.20-EXTRACT-FINAL-NO-IMPLIED-VIRTUAL`, `SV2023-8.20-EXTRACT-FINAL-NO-OVERRIDE`, `SV2023-8.20-EXTRACT-INITIAL-EXTENDS-EXCLUSIVE`, `SV2023-8.20-EXTRACT-INITIAL-NO-IMPLIED-VIRTUAL`, `SV2023-8.20-EXTRACT-INITIAL-NO-VIRTUAL-OVERRIDE`, `SV2023-8.20-EXTRACT-PURE-NOT-FINAL`, `SV2023-8.24-EXTRACT-EXTERN-PROTOTYPE`, `SV2023-13.3-EXTRACT-OVERRIDE-METHOD-ONLY`, `SV2023-13.3-EXTRACT-TASK-GRAMMAR`, `SV2023-13.4-EXTRACT-FUNCTION-GRAMMAR`, `SV2023-13.4-EXTRACT-FUNCTION-TYPE-FOOTNOTES`, `SV2023-35.5.4-EXTRACT-PROTOTYPE-RESTRICTIONS`, `SV2023-A.2.6-EXTRACT-DECL`, `SV2023-A.2.6-EXTRACT-PROTOTYPE`, `SV2023-A.2.7-EXTRACT-DECL`, `SV2023-A.2.7-EXTRACT-OVERRIDES`, `SV2023-A.2.7-EXTRACT-PROTOTYPE`, `SV2023-A.10-EXTRACT-FOOTNOTE-25`, `SV2023-A.10-EXTRACT-FOOTNOTE-8`

| Test | Kind | `:oracle:` | Saved results |
| --- | --- | --- | --- |
| [`ch13/test_a2_7_dynamic_override_specifiers`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/ch13/test_a2_7_dynamic_override_specifiers.sv) | legal | `spec verilator@5.052` | `I- Vp Kp Gp` |
| [`ch13/test_function_declaration_scoped_and_override_forms`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/ch13/test_function_declaration_scoped_and_override_forms.sv) | legal | `spec verilator@5.054` | `I- Vp K- Gp` |
| [`ch13/test_task_declaration_grammar_and_nesting`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/ch13/test_task_declaration_grammar_and_nesting.sv) | legal | `spec` | `I- Vp Kp Gp` |
| [`ch8/test_class_declaration_grammar_forms`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/ch8/test_class_declaration_grammar_forms.sv) | legal | `spec verilator@5.052` | `I- Vp K- Gp` |
| [`ch8/test_class_virtual_dispatch_and_initial`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/ch8/test_class_virtual_dispatch_and_initial.sv) | legal | `spec` | `I- V- Kp Gp` |
| [`ch8/test_class_virtual_override_of_nonvirtual_and_initial`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/ch8/test_class_virtual_override_of_nonvirtual_and_initial.sv) | legal | `spec verilator@5.052` | `I- Vp Kp Gp` |
| [`ch8/test_extern_method_prototype_qualifiers`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/ch8/test_extern_method_prototype_qualifiers.sv) | legal | `spec verilator@5.052` | `I- Vp Kp Gp` |
| [`ch8/test_final_class_and_method`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/ch8/test_final_class_and_method.sv) | legal | `spec verilator@5.052` | `I- Vp Kp Gp` |
| [`ch8/test_final_method_not_virtual_vpi`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/ch8/test_final_method_not_virtual_vpi.sv) | legal | `spec` | `I- V- K- Gp` |
| [`ch8/test_method_initial_extends`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/ch8/test_method_initial_extends.sv) | legal | `spec verilator@5.052` | `I- Vp Kp Gp` |
| [`ch9/test_structured_procedure_forms_and_subroutine_lifetimes`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/ch9/test_structured_procedure_forms_and_subroutine_lifetimes.sv) | legal | `spec verilator@5.054` | `I- Vp Kp Gp` |
| [`ch13/test_illegal_dynamic_override_specifier_in_interface_class`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/ch13/test_illegal_dynamic_override_specifier_in_interface_class.sv) | illegal | `spec` | `I- V- Kp Gp` |
| [`ch13/test_illegal_dynamic_override_specifier_on_module_task`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/ch13/test_illegal_dynamic_override_specifier_on_module_task.sv) | illegal | `spec` | `I- V- Kp Gp` |
| [`ch13/test_illegal_function_override_specifier_interface_class`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/ch13/test_illegal_function_override_specifier_interface_class.sv) | illegal | `spec` | `I- V- Kp Gp` |
| [`ch13/test_illegal_function_override_specifier_outside_class`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/ch13/test_illegal_function_override_specifier_outside_class.sv) | illegal | `spec` | `Ip V- Kp Gp` |
| [`ch35/test_illegal_dpi_import_override_specifier`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/ch35/test_illegal_dpi_import_override_specifier.sv) | illegal | `spec` | `Ip V- Kp Gp` |
| [`ch8/test_illegal_extends_nonvirtual_method`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/ch8/test_illegal_extends_nonvirtual_method.sv) | illegal | `spec` | `Ip V- Kp Gp` |
| [`ch8/test_illegal_final_method_overridden`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/ch8/test_illegal_final_method_overridden.sv) | illegal | `spec verilator@5.052` | `I- Vp Kp Gp` |
| [`ch8/test_illegal_final_pure_virtual`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/ch8/test_illegal_final_pure_virtual.sv) | illegal | `spec` | `Ip V- Kp Gp` |
| [`ch8/test_illegal_initial_method_overrides_pure_virtual`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/ch8/test_illegal_initial_method_overrides_pure_virtual.sv) | illegal | `spec verilator@5.052` | `Ip Vp Kp Gp` |
| [`ch8/test_illegal_initial_method_overrides_virtual`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/ch8/test_illegal_initial_method_overrides_virtual.sv) | illegal | `spec verilator@5.052` | `Ip Vp Kp Gp` |
| [`ch8/test_illegal_method_extends_without_base`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/ch8/test_illegal_method_extends_without_base.sv) | illegal | `spec verilator@5.052` | `Ip Vp Kp Gp` |
| [`ch8/test_illegal_method_initial_and_extends`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/ch8/test_illegal_method_initial_and_extends.sv) | illegal | `spec verilator@5.052` | `Ip Vp Kp Gp` |
| [`ch8/test_illegal_method_initial_overrides`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/ch8/test_illegal_method_initial_overrides.sv) | illegal | `spec verilator@5.052` | `Ip Vp Kp Gp` |
| [`ch8/test_illegal_method_initial_with_extends_specifier`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/ch8/test_illegal_method_initial_with_extends_specifier.sv) | illegal | `spec verilator@5.052` | `Ip Vp Kp Gp` |
| [`ch8/test_illegal_nonvirtual_final_method_overridden`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/ch8/test_illegal_nonvirtual_final_method_overridden.sv) | illegal | `spec verilator@5.052` | `I- Vp Kp Gp` |
| [`ch8/test_illegal_override_specifier_in_interface_class`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/ch8/test_illegal_override_specifier_in_interface_class.sv) | illegal | `spec` | `I- V- Kp Gp` |
| [`ch8/test_illegal_override_specifier_outside_class`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/ch8/test_illegal_override_specifier_outside_class.sv) | illegal | `spec` | `Ip V- Kp Gp` |
| [`ch8/test_illegal_pure_virtual_final`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/ch8/test_illegal_pure_virtual_final.sv) | illegal | `spec` | `Ip Vp Kp Gp` |
| [`ch8/test_illegal_pure_virtual_method_final`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/ch8/test_illegal_pure_virtual_method_final.sv) | illegal | `spec` | `Ip V- Kp Gp` |
| [`ch8/test_illegal_virtual_final_method_overridden_in_subclass`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/ch8/test_illegal_virtual_final_method_overridden_in_subclass.sv) | illegal | `spec verilator@5.052` | `I- Vp Kp Gp` |
| [`ch9/test_illegal_override_specifier_in_interface_class`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/ch9/test_illegal_override_specifier_in_interface_class.sv) | illegal | `spec` | `I- V- Kp Gp` |
| [`ch9/test_illegal_override_specifier_on_module_function`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/ch9/test_illegal_override_specifier_on_module_function.sv) | illegal | `spec` | `Ip V- Kp Gp` |
