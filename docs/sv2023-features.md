# IEEE 1800-2023で加わった機能のテスト

[English](sv2023-features.en.md) / [日本語](sv2023-features.md)

1800-2023で加わった機能ごとに、その機能を実際に使うテストの本数と裏付けをまとめます。台帳は`coverage/sv2023-features.json`で、この資料は`tools/sv2023_features.py --update`が作ります。台帳のテストは、正規表現で出した候補を一本ずつ読んで確かめたものです。機能の一覧はDVConのチュートリアル「A Subjective Review on IEEE Std 1800-2023」の18項目に、`ref static`・実数のカバーポイント・型パラメータの制限を加えたものです。規格には改訂で加わった機能の一覧がなく、この3つが2023で加わったものかは規格の本文だけでは確かめられません。

## 一覧

| 機能 | 条項 | テスト | 正常系 | 規格違反 | 固定版の裏付け | 規格のみ | I | V | K | G | 要求（対応済み／行数） | 一覧の出典 |
| --- | --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | --- |
| [type(this)](#type-this) | 6.23, 8.11 | 5 | 4 | 1 | 4 | 1 | 1 | 4 | 2 | 5 | 2/2 | DVConの18項目 |
| [ifdef系の指令の論理式](#ifdef-expression) | 22.6 | 4 | 3 | 1 | 2 | 2 | 1 | 2 | 3 | 4 | 5/5 | DVConの18項目 |
| [配列メソッド呼び出しの index_argument](#array-method-index-argument) | 7.12, 7.12.4 | 5 | 5 | 0 | 0 | 5 | 0 | 0 | 0 | 5 | 3/3 | DVConの18項目 |
| [class :final](#class-final) | 8.3, 8.13 | 11 | 7 | 4 | 10 | 1 | 0 | 10 | 6 | 11 | 2/2 | DVConの18項目 |
| [dist の default 項目](#dist-default) | 18.5.3 | 8 | 5 | 3 | 0 | 8 | 3 | 3 | 3 | 8 | 3/3 | DVConの18項目 |
| [real 型の coverpoint・real の bins と type_option.real_interval](#real-coverpoint) | 19.5, 19.5.1, 19.5.1.1, 19.5.2, 19.5.3, 19.5.4, 19.6, 19.7.1, 19.10 | 21 | 12 | 9 | 0 | 21 | 9 | 0 | 9 | 21 | 26/26 | 追加の3項目 |
| [$stacktrace](#stacktrace) | 20.17.2, 11.2.1 | 6 | 3 | 3 | 6 | 0 | 2 | 6 | 5 | 6 | 2/2 | DVConの18項目 |
| [システム関数 $timeunit と $timeprecision](#timeunit-timeprecision-functions) | 20.4, 20.4.1, 11.2.1 | 8 | 8 | 0 | 1 | 7 | 0 | 1 | 7 | 8 | 25/25 | DVConの18項目 |
| [制限付き型パラメータ（type enum / struct / union / class / interface class）](#type-parameter-restriction) | 6.20.3 | 10 | 5 | 5 | 8 | 2 | 4 | 8 | 9 | 10 | 2/2 | 追加の3項目 |
| [コンストラクタの default 引数（function new(default…)、super.new(default)、extends Base(default)）](#constructor-default-arguments) | 8.17, 8.3, 8.15 | 15 | 6 | 9 | 0 | 15 | 7 | 8 | 11 | 15 | 14/14 | DVConの18項目 |
| [配列メソッド map](#array-map-method) | 7.12.5, 7.12 | 8 | 5 | 3 | 2 | 6 | 2 | 2 | 3 | 8 | 3/3 | DVConの18項目 |
| [union soft（soft packed union）](#soft-packed-union) | 7.3.1, 7.3, 7.2 | 8 | 7 | 1 | 4 | 4 | 0 | 4 | 4 | 8 | 8/8 | DVConの18項目 |
| [三重引用符の文字列リテラル](#triple-quoted-string) | 5.9, 5.9.1, A.8.8, 22.5.1 | 9 | 7 | 2 | 5 | 4 | 1 | 5 | 9 | 9 | 13/13 | DVConの18項目 |
| [rand real 変数](#rand-real) | 18.4, 18.4.1, 18.5.3, 18.5.4, 18.5.5, 18.5.6, 18.5.9 | 10 | 4 | 6 | 0 | 10 | 4 | 4 | 6 | 10 | 8/8 | DVConの18項目 |
| [constraint の :initial / :extends / :final](#constraint-dynamic-override) | 18.5.2, 18.5, 18.5.10, 8.3 | 15 | 4 | 11 | 5 | 10 | 11 | 7 | 11 | 15 | 11/11 | DVConの18項目 |
| [weak_reference クラス](#weak-reference) | 8.29, 8.30, 8.30.1, 8.30.2, 8.30.3, 8.30.4, 8.30.5, G.7, G.1 | 13 | 12 | 1 | 0 | 13 | 1 | 1 | 1 | 13 | 20/27 | DVConの18項目 |
| [covergroup extends（派生クラスの埋め込み covergroup）](#covergroup-inheritance) | 19.3, 19.4, 19.4.1, A.2.11 | 13 | 6 | 7 | 0 | 13 | 7 | 6 | 7 | 13 | 12/12 | DVConの18項目 |
| [ref static 引数](#ref-static) | 13.5.2, 13.3, 13.4, A.2.7 | 22 | 18 | 4 | 0 | 22 | 0 | 0 | 20 | 22 | 8/8 | 追加の3項目 |
| [許容誤差範囲 [A +/- B] と [A +%- B]](#tolerance-ranges) | 11.4.13, 18.5.3, 19.5.1, A.2.11, A.6.7 | 29 | 26 | 3 | 0 | 29 | 3 | 2 | 22 | 29 | 10/10 | DVConの18項目 |
| [function / task の :initial / :extends / :final](#method-dynamic-override) | 8.20, 8.3, 8.24, 13.3, 13.4, 35.5.4, A.2.6, A.2.7 | 33 | 11 | 22 | 17 | 16 | 14 | 19 | 30 | 33 | 24/24 | DVConの18項目 |

保存済みの結果：I Icarus Verilog 13.0、V Verilator、K kirimasim、L Lyra、G Ghost。テストの今の入力と同じ入力で保存された結果のどれかがpassならp、なければ-。規格違反のテストでは、未対応の構文による拒否もpassに見えることがあります。

<a id="type-this"></a>

## type(this)

- 条項: 6.23, 8.11
- 規格が定める不正な形: this は type(this) として、または非 static メソッド・制約・インライン制約メソッド・クラス内 covergroup の中でのみ使え、クラスの外の type(this) はエラーである。 (8.11)
- 要求（対応済み／行数）: `SV2023-6.23-EXTRACT-TYPE-THIS`, `SV2023-8.11-EXTRACT-THIS-CONTEXT`

| テスト | 種類 | `:oracle:` | 保存済みの結果 |
| --- | --- | --- | --- |
| [`ch8/test_type_this`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/ch8/test_type_this.sv) | 正常系 | `spec` | `I- V- Kp Gp` |
| [`ch8/test_type_this_final_class_typedef`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/ch8/test_type_this_final_class_typedef.sv) | 正常系 | `spec verilator@5.054` | `I- Vp K- Gp` |
| [`ch8/test_type_this_inherited_method_lexical_class`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/ch8/test_type_this_inherited_method_lexical_class.sv) | 正常系 | `spec verilator@5.054` | `I- Vp K- Gp` |
| [`ch8/test_type_this_parameterized_specialization`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/ch8/test_type_this_parameterized_specialization.sv) | 正常系 | `spec verilator@5.054` | `I- Vp K- Gp` |
| [`ch8/test_illegal_type_this_outside_class`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/ch8/test_illegal_type_this_outside_class.sv) | 規格違反 | `spec verilator@5.052` | `Ip Vp Kp Gp` |

<a id="ifdef-expression"></a>

## ifdef系の指令の論理式

- 条項: 22.6
- 規格が定める不正な形: 構文 22-5 は式にマクロ名・括弧・!・二項演算子 &&, ||, ->, <-> だけを認めており、他の演算子は構文に含まれない（独立した shall not の文はない）。 (22.6)
- 要求（対応済み／行数）: `SV2023-22.6-EXTRACT-CONDITIONAL-EVALUATION`, `SV2023-22.6-EXTRACT-CONDITIONAL-GRAMMAR`, `SV2023-22.6-EXTRACT-FIRST-SUCCESS`, `SV2023-22.6-EXTRACT-IFNDEF-NEGATION`, `SV2023-22.6-EXTRACT-DIRECTIVES-NOT-DEFINED`

| テスト | 種類 | `:oracle:` | 保存済みの結果 |
| --- | --- | --- | --- |
| [`ch22/test_ifdef_branches_and_expressions`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/ch22/test_ifdef_branches_and_expressions.sv) | 正常系 | `spec` | `I- V- Kp Gp` |
| [`ch22/test_ifdef_directive_names_not_defined`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/ch22/test_ifdef_directive_names_not_defined.sv) | 正常系 | `spec` | `I- V- K- Gp` |
| [`ch22/test_ifdef_expression`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/ch22/test_ifdef_expression.sv) | 正常系 | `spec verilator@5.052` | `I- Vp Kp Gp` |
| [`ch22/test_illegal_ifdef_expression_operator`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/ch22/test_illegal_ifdef_expression_operator.sv) | 規格違反 | `spec verilator@5.052` | `Ip Vp Kp Gp` |

<a id="array-method-index-argument"></a>

## 配列メソッド呼び出しの index_argument

- 条項: 7.12, 7.12.4
- 規格が定める不正な形: なし。
- 要求（対応済み／行数）: `SV2023-7.12-EXTRACT-INDEX-NAME-DEFAULT`, `SV2023-7.12-EXTRACT-METHOD-CALL-GRAMMAR`, `SV2023-7.12.4-EXTRACT-INDEX-RENAME`

| テスト | 種類 | `:oracle:` | 保存済みの結果 |
| --- | --- | --- | --- |
| [`ch7/test_array_method_index_argument`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/ch7/test_array_method_index_argument.sv) | 正常系 | `spec` | `I- V- K- Gp` |
| [`ch7/test_array_method_index_argument_class_assoc_nested`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/ch7/test_array_method_index_argument_class_assoc_nested.sv) | 正常系 | `spec` | `I- V- K- Gp` |
| [`ch7/test_array_method_index_argument_without_iterator`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/ch7/test_array_method_index_argument_without_iterator.sv) | 正常系 | `spec` | `I- V- K- Gp` |
| [`ch7/test_array_method_iterator_index_names_and_selects`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/ch7/test_array_method_iterator_index_names_and_selects.sv) | 正常系 | `spec` | `I- V- K- Gp` |
| [`ch7/test_map_element_types_and_index_names`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/ch7/test_map_element_types_and_index_names.sv) | 正常系 | `spec` | `I- V- K- Gp` |

<a id="class-final"></a>

## class :final

- 条項: 8.3, 8.13
- 規格が定める不正な形: final 指定子付きで宣言したクラスは拡張できず、そこから派生するとエラーである。 (8.13)
- 要求（対応済み／行数）: `SV2023-8.3-EXTRACT-CLASS-DECLARATION`, `SV2023-8.13-EXTRACT-FINAL-CLASS`

| テスト | 種類 | `:oracle:` | 保存済みの結果 |
| --- | --- | --- | --- |
| [`ch6/test_type_param_restricted_abstract_final_scoped`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/ch6/test_type_param_restricted_abstract_final_scoped.sv) | 正常系 | `spec verilator@5.054` | `I- Vp K- Gp` |
| [`ch8/test_class_declaration_grammar_forms`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/ch8/test_class_declaration_grammar_forms.sv) | 正常系 | `spec verilator@5.052` | `I- Vp K- Gp` |
| [`ch8/test_constructor_default_through_implicit_constructor`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/ch8/test_constructor_default_through_implicit_constructor.sv) | 正常系 | `spec` | `I- V- K- Gp` |
| [`ch8/test_final_class_and_method`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/ch8/test_final_class_and_method.sv) | 正常系 | `spec verilator@5.052` | `I- Vp Kp Gp` |
| [`ch8/test_final_class_parameterized_implements`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/ch8/test_final_class_parameterized_implements.sv) | 正常系 | `spec verilator@5.054` | `I- Vp K- Gp` |
| [`ch8/test_syntax_class_and_interface_class_headers`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/ch8/test_syntax_class_and_interface_class_headers.sv) | 正常系 | `spec verilator@5.052` | `I- Vp Kp Gp` |
| [`ch8/test_type_this_final_class_typedef`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/ch8/test_type_this_final_class_typedef.sv) | 正常系 | `spec verilator@5.054` | `I- Vp K- Gp` |
| [`ch8/test_illegal_final_class_extended`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/ch8/test_illegal_final_class_extended.sv) | 規格違反 | `spec verilator@5.052` | `I- Vp Kp Gp` |
| [`ch8/test_illegal_final_class_extends`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/ch8/test_illegal_final_class_extends.sv) | 規格違反 | `spec verilator@5.052` | `I- Vp Kp Gp` |
| [`ch8/test_illegal_final_class_specialization_extended`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/ch8/test_illegal_final_class_specialization_extended.sv) | 規格違反 | `spec verilator@5.054` | `I- Vp Kp Gp` |
| [`ch8/test_illegal_final_derived_class_in_package_extended`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/ch8/test_illegal_final_derived_class_in_package_extended.sv) | 規格違反 | `spec verilator@5.054` | `I- Vp Kp Gp` |

<a id="dist-default"></a>

## dist の default 項目

- 条項: 18.5.3
- 規格が定める不正な形: default 項目は :/ と重みを使わなければならず（重みの省略や := はエラー）、1 つの分布に default 項目は高々 1 つしか置けない。 (18.5.3)
- 要求（対応済み／行数）: `SV2023-18.5.3-EXTRACT-DEFAULT-COMPLEMENT`, `SV2023-18.5.3-EXTRACT-DEFAULT-DIVIDE-UNIQUE`, `SV2023-18.5.3-EXTRACT-DIST-MEMBERSHIP`

| テスト | 種類 | `:oracle:` | 保存済みの結果 |
| --- | --- | --- | --- |
| [`ch18/test_constraint_grammar_forms`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/ch18/test_constraint_grammar_forms.sv) | 正常系 | `spec` | `I- V- K- Gp` |
| [`ch18/test_dist_default_complement`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/ch18/test_dist_default_complement.sv) | 正常系 | `spec` | `I- V- K- Gp` |
| [`ch18/test_dist_default_in_implication_inline_foreach`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/ch18/test_dist_default_in_implication_inline_foreach.sv) | 正常系 | `spec` | `I- V- K- Gp` |
| [`ch18/test_dist_default_only_and_conflicts`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/ch18/test_dist_default_only_and_conflicts.sv) | 正常系 | `spec` | `I- V- K- Gp` |
| [`ch18/test_dist_default_weight`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/ch18/test_dist_default_weight.sv) | 正常系 | `spec` | `I- V- K- Gp` |
| [`ch18/test_illegal_dist_default_colon_equal`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/ch18/test_illegal_dist_default_colon_equal.sv) | 規格違反 | `spec` | `Ip Vp Kp Gp` |
| [`ch18/test_illegal_dist_default_no_weight`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/ch18/test_illegal_dist_default_no_weight.sv) | 規格違反 | `spec` | `Ip Vp Kp Gp` |
| [`ch18/test_illegal_dist_two_defaults`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/ch18/test_illegal_dist_two_defaults.sv) | 規格違反 | `spec` | `Ip Vp Kp Gp` |

<a id="real-coverpoint"></a>

## real 型の coverpoint・real の bins と type_option.real_interval

- 条項: 19.5, 19.5.1, 19.5.1.1, 19.5.2, 19.5.3, 19.5.4, 19.6, 19.7.1, 19.10
- 規格が定める不正な形: real 式の coverpoint は少なくとも 1 つの明示的な bins を持たなければならない（自動 bins は作られない）。 (19.5); real coverpoint の default bin に [] や [N] の配列表記は使えない。 (19.5.1); real coverpoint の bins に with 句は使えない。 (19.5.1.1); real 値の遷移 bins は使えない。 (19.5.2); real coverpoint の wildcard bins は使えない。 (19.5.4); cross に real 変数を直接指定できず、real 式は明示的な coverpoint で包まなければならない（この形のテストは見つからなかった）。 (19.6); type_option.real_interval を設定できるのは covergroup と coverpoint のレベルだけで、cross では設定できない。 (19.7.1)
- 要求（対応済み／行数）: `SV2023-19.5-EXTRACT-COVERPOINT-DOMAIN`, `SV2023-19.5-EXTRACT-REAL-EXPLICIT-BINS`, `SV2023-19.5.1-EXTRACT-EXCESS-REAL-BINS`, `SV2023-19.5.1-EXTRACT-FIXED-REAL-DISTRIBUTION`, `SV2023-19.5.1-EXTRACT-MERGE-IDENTICAL-INTERVALS`, `SV2023-19.5.1-EXTRACT-REAL-BIN-FORMS`, `SV2023-19.5.1-EXTRACT-REAL-BIN-NAMES`, `SV2023-19.5.1-EXTRACT-REAL-DEFAULT-NO-ARRAY`, `SV2023-19.5.1-EXTRACT-REAL-DOLLAR-RANGE`, `SV2023-19.5.1-EXTRACT-REAL-INTERVAL-ENDS`, `SV2023-19.5.1-EXTRACT-REAL-OPEN-PARTITION`, `SV2023-19.5.1-EXTRACT-REAL-RANGE`, `SV2023-19.5.1-EXTRACT-REAL-TOLERANCE`, `SV2023-19.5.1.1-EXTRACT-WITH-FILTER`, `SV2023-19.5.2-EXTRACT-TRANSITION-INTEGRAL`, `SV2023-19.5.3-EXTRACT-AUTO-WHEN-NO-NORMAL`, `SV2023-19.5.4-EXTRACT-WILDCARD-SAMPLES`, `SV2023-19.6-EXTRACT-CROSS-ITEMS`, `SV2023-19.7.1-EXTRACT-TYPE-DEFAULTS`, `SV2023-19.7.1-EXTRACT-TYPE-LEVEL-REAL-INTERVAL-COVERGROUP`, `SV2023-19.7.1-EXTRACT-TYPE-LEVEL-REAL-INTERVAL-COVERPOINT`, `SV2023-19.7.1-EXTRACT-TYPE-LEVEL-REAL-INTERVAL-CROSS`, `SV2023-19.7.1-EXTRACT-TYPE-OPTION-MUTATION`, `SV2023-19.7.1-EXTRACT-TYPE-OPTION-REAL-INTERVAL`, `SV2023-19.10-EXTRACT-GROUP-TYPE-OPTION-STRUCT`, `SV2023-19.10-EXTRACT-POINT-TYPE-OPTION-STRUCT`

| テスト | 種類 | `:oracle:` | 保存済みの結果 |
| --- | --- | --- | --- |
| [`ch19/test_cg_auto_bins_only_ignored_and_real`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/ch19/test_cg_auto_bins_only_ignored_and_real.sv) | 正常系 | `spec` | `I- V- K- Gp` |
| [`ch19/test_cg_real_bin_intervals`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/ch19/test_cg_real_bin_intervals.sv) | 正常系 | `spec` | `I- V- K- Gp` |
| [`ch19/test_cg_real_bins_fixed_and_dollar`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/ch19/test_cg_real_bins_fixed_and_dollar.sv) | 正常系 | `spec` | `I- V- K- Gp` |
| [`ch19/test_cg_real_bins_tolerance_and_merge`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/ch19/test_cg_real_bins_tolerance_and_merge.sv) | 正常系 | `spec` | `I- V- K- Gp` |
| [`ch19/test_cg_real_coverpoint_cross`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/ch19/test_cg_real_coverpoint_cross.sv) | 正常系 | `spec` | `I- V- K- Gp` |
| [`ch19/test_cg_real_fixed_bin_items_and_names`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/ch19/test_cg_real_fixed_bin_items_and_names.sv) | 正常系 | `spec` | `I- V- K- Gp` |
| [`ch19/test_cg_real_fixed_bins_listed_order`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/ch19/test_cg_real_fixed_bins_listed_order.sv) | 正常系 | `spec` | `I- V- K- Gp` |
| [`ch19/test_cg_real_interval_covergroup_level`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/ch19/test_cg_real_interval_covergroup_level.sv) | 正常系 | `spec` | `I- V- K- Gp` |
| [`ch19/test_cg_real_open_bin_names_merge`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/ch19/test_cg_real_open_bin_names_merge.sv) | 正常系 | `spec` | `I- V- K- Gp` |
| [`ch19/test_option_member_defaults`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/ch19/test_option_member_defaults.sv) | 正常系 | `spec` | `I- V- K- Gp` |
| [`ch19/test_option_struct_member_types`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/ch19/test_option_struct_member_types.sv) | 正常系 | `spec` | `I- V- K- Gp` |
| [`ch19/test_option_struct_members`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/ch19/test_option_struct_members.sv) | 正常系 | `spec` | `I- V- K- Gp` |
| [`ch19/test_illegal_cg_cross_real_variable`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/ch19/test_illegal_cg_cross_real_variable.sv) | 規格違反 | `spec` | `Ip V- Kp Gp` |
| [`ch19/test_illegal_cg_real_bins_with`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/ch19/test_illegal_cg_real_bins_with.sv) | 規格違反 | `spec` | `Ip V- Kp Gp` |
| [`ch19/test_illegal_cg_real_default_bin_array`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/ch19/test_illegal_cg_real_default_bin_array.sv) | 規格違反 | `spec` | `Ip V- Kp Gp` |
| [`ch19/test_illegal_cg_real_default_bin_n`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/ch19/test_illegal_cg_real_default_bin_n.sv) | 規格違反 | `spec` | `Ip V- Kp Gp` |
| [`ch19/test_illegal_cg_real_no_bins`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/ch19/test_illegal_cg_real_no_bins.sv) | 規格違反 | `spec` | `Ip V- Kp Gp` |
| [`ch19/test_illegal_cg_real_transition_bins`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/ch19/test_illegal_cg_real_transition_bins.sv) | 規格違反 | `spec` | `Ip V- Kp Gp` |
| [`ch19/test_illegal_cg_real_transition_domain`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/ch19/test_illegal_cg_real_transition_domain.sv) | 規格違反 | `spec` | `Ip V- Kp Gp` |
| [`ch19/test_illegal_cg_real_wildcard`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/ch19/test_illegal_cg_real_wildcard.sv) | 規格違反 | `spec` | `Ip V- Kp Gp` |
| [`gen/ch19/test_gen_cglevel_type_option_real_interval_cross`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/gen/ch19/test_gen_cglevel_type_option_real_interval_cross.sv) | 規格違反 | `spec` | `Ip V- Kp Gp` |

<a id="stacktrace"></a>

## $stacktrace

- 条項: 20.17.2, 11.2.1
- 規格が定める不正な形: 構文 20-18 では $stacktrace は引数を取らないので、引数付きの呼び出しは不正である。 (20.17.2); $stacktrace は定数システム関数呼び出しに使えるシステム関数に含まれず、パラメータ値のような定数式には書けない。 (11.2.1)
- 要求（対応済み／行数）: `SV2023-20.17.2-EXTRACT-STACKTRACE-CONTEXT`, `SV2023-20.17.2-EXTRACT-STACKTRACE-RESULT`

| テスト | 種類 | `:oracle:` | 保存済みの結果 |
| --- | --- | --- | --- |
| [`ch20/test_stacktrace_function`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/ch20/test_stacktrace_function.sv) | 正常系 | `spec verilator@5.052` | `I- Vp Kp Gp` |
| [`ch20/test_stacktrace_function_call_contexts`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/ch20/test_stacktrace_function_call_contexts.sv) | 正常系 | `spec verilator@5.052` | `I- Vp Kp Gp` |
| [`ch20/test_stacktrace_function_string_value`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/ch20/test_stacktrace_function_string_value.sv) | 正常系 | `spec verilator@5.052` | `I- Vp K- Gp` |
| [`ch11/test_illegal_stacktrace_in_constant_expression`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/ch11/test_illegal_stacktrace_in_constant_expression.sv) | 規格違反 | `spec verilator@5.052` | `Ip Vp Kp Gp` |
| [`ch13/test_illegal_stacktrace_in_constant_function`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/ch13/test_illegal_stacktrace_in_constant_function.sv) | 規格違反 | `spec verilator@5.054` | `Ip Vp Kp Gp` |
| [`ch20/test_illegal_stacktrace_argument`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/ch20/test_illegal_stacktrace_argument.sv) | 規格違反 | `spec verilator@5.052` | `I- Vp Kp Gp` |

<a id="timeunit-timeprecision-functions"></a>

## システム関数 $timeunit と $timeprecision

- 条項: 20.4, 20.4.1, 11.2.1
- 規格が定める不正な形: なし。
- 要求（対応済み／行数）: `SV2023-20.4.1-EXTRACT-COMPILATION-SCOPE`, `SV2023-20.4.1-EXTRACT-CURRENT-SCOPE`, `SV2023-20.4.1-EXTRACT-EXPONENT-RANGE`, `SV2023-20.4.1-EXTRACT-NAMED-SCOPE`, `SV2023-20.4.1-EXTRACT-ROOT-SCOPE`, `SV2023-20.4.1-EXTRACT-TIMESCALE-QUERIES`, `SV2023-11.2.1-EXTRACT-CONSTANT-TIMESCALE-NAME`, `SV2023-20.4.1-EXTRACT-EXPONENT-0`, `SV2023-20.4.1-EXTRACT-EXPONENT-1`, `SV2023-20.4.1-EXTRACT-EXPONENT-2`, `SV2023-20.4.1-EXTRACT-EXPONENT-NEG1`, `SV2023-20.4.1-EXTRACT-EXPONENT-NEG2`, `SV2023-20.4.1-EXTRACT-EXPONENT-NEG3`, `SV2023-20.4.1-EXTRACT-EXPONENT-NEG4`, `SV2023-20.4.1-EXTRACT-EXPONENT-NEG5`, `SV2023-20.4.1-EXTRACT-EXPONENT-NEG6`, `SV2023-20.4.1-EXTRACT-EXPONENT-NEG7`, `SV2023-20.4.1-EXTRACT-EXPONENT-NEG8`, `SV2023-20.4.1-EXTRACT-EXPONENT-NEG9`, `SV2023-20.4.1-EXTRACT-EXPONENT-NEG10`, `SV2023-20.4.1-EXTRACT-EXPONENT-NEG11`, `SV2023-20.4.1-EXTRACT-EXPONENT-NEG12`, `SV2023-20.4.1-EXTRACT-EXPONENT-NEG13`, `SV2023-20.4.1-EXTRACT-EXPONENT-NEG14`, `SV2023-20.4.1-EXTRACT-EXPONENT-NEG15`

| テスト | 種類 | `:oracle:` | 保存済みの結果 |
| --- | --- | --- | --- |
| [`ch11/test_expr_timescale_constants`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/ch11/test_expr_timescale_constants.sv) | 正常系 | `spec` | `I- V- K- Gp` |
| [`ch20/test_timeprecision_exponent_table`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/ch20/test_timeprecision_exponent_table.sv) | 正常系 | `spec` | `I- V- Kp Gp` |
| [`ch20/test_timeunit_exponent_table`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/ch20/test_timeunit_exponent_table.sv) | 正常系 | `spec verilator@5.052` | `I- Vp Kp Gp` |
| [`ch20/test_timeunit_package_interface_program_nested`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/ch20/test_timeunit_package_interface_program_nested.sv) | 正常系 | `spec` | `I- V- Kp Gp` |
| [`ch20/test_timeunit_timeprecision_functions`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/ch20/test_timeunit_timeprecision_functions.sv) | 正常系 | `spec` | `I- V- Kp Gp` |
| [`ch20/test_timeunit_timescale_precedence`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/ch20/test_timeunit_timescale_precedence.sv) | 正常系 | `spec` | `I- V- Kp Gp` |
| [`ch20/test_timeunit_unit_root`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/ch20/test_timeunit_unit_root.sv) | 正常系 | `spec` | `I- V- Kp Gp` |
| [`imported/ch20/test_time_query_matrix`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/imported/ch20/test_time_query_matrix.sv) | 正常系 | `spec` | `I- V- Kp Gp` |

<a id="type-parameter-restriction"></a>

## 制限付き型パラメータ（type enum / struct / union / class / interface class）

- 条項: 6.20.3
- 規格が定める不正な形: 制限付き型パラメータに、指定した基本カテゴリに属さない型を与えるとエラーである。 (6.20.3)
- 要求（対応済み／行数）: `SV2023-6.20.3-EXTRACT-BASIC-TYPE-RESTRICTION`, `SV2023-6.20.3-EXTRACT-RESTRICTION-CONFORMANCE`

| テスト | 種類 | `:oracle:` | 保存済みの結果 |
| --- | --- | --- | --- |
| [`ch6/test_parameter_declaration_forms`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/ch6/test_parameter_declaration_forms.sv) | 正常系 | `spec verilator@5.052` | `I- Vp Kp Gp` |
| [`ch6/test_type_param_restricted_abstract_final_scoped`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/ch6/test_type_param_restricted_abstract_final_scoped.sv) | 正常系 | `spec verilator@5.054` | `I- Vp K- Gp` |
| [`ch6/test_type_param_restricted_class_and_interface_lists`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/ch6/test_type_param_restricted_class_and_interface_lists.sv) | 正常系 | `spec verilator@5.052` | `I- Vp Kp Gp` |
| [`ch6/test_type_param_restricted_conforming_types`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/ch6/test_type_param_restricted_conforming_types.sv) | 正常系 | `spec verilator@5.052` | `I- Vp Kp Gp` |
| [`ch6/test_type_param_restricted_kinds`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/ch6/test_type_param_restricted_kinds.sv) | 正常系 | `spec verilator@5.052` | `I- Vp Kp Gp` |
| [`ch6/test_illegal_class_restricted_type_parameter_via_type_parameter`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/ch6/test_illegal_class_restricted_type_parameter_via_type_parameter.sv) | 規格違反 | `spec verilator@5.054` | `Ip Vp Kp Gp` |
| [`ch6/test_illegal_enum_restricted_type_parameter_default_int`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/ch6/test_illegal_enum_restricted_type_parameter_default_int.sv) | 規格違反 | `spec` | `Ip V- Kp Gp` |
| [`ch6/test_illegal_enum_restricted_type_parameter_given_int`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/ch6/test_illegal_enum_restricted_type_parameter_given_int.sv) | 規格違反 | `spec verilator@5.052` | `Ip Vp Kp Gp` |
| [`ch6/test_illegal_interface_class_restricted_type_parameter_given_class`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/ch6/test_illegal_interface_class_restricted_type_parameter_given_class.sv) | 規格違反 | `spec` | `I- V- Kp Gp` |
| [`ch6/test_illegal_struct_restricted_type_parameter_given_union`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/ch6/test_illegal_struct_restricted_type_parameter_given_union.sv) | 規格違反 | `spec verilator@5.052` | `Ip Vp Kp Gp` |

<a id="constructor-default-arguments"></a>

## コンストラクタの default 引数（function new(default…)、super.new(default)、extends Base(default)）

- 条項: 8.17, 8.3, 8.15
- 規格が定める不正な形: default はコンストラクタ引数リストに高々 1 回、サブクラスでのみ書け、スーパークラスの引数名と同じ名前の引数とは併用できず、スーパークラス引数の既定値がローカルメンバを参照する場合はエラーである。 (8.17); コンストラクタ引数リストに default がないときの super.new(default) はエラーであり、extends Base(default) のときユーザ定義コンストラクタは default を含まなければならない。 (8.17)
- 要求（対応済み／行数）: `SV2023-8.3-EXTRACT-CLASS-DECLARATION`, `SV2023-8.3-EXTRACT-ONE-CONSTRUCTOR-DEFAULT`, `SV2023-8.15-EXTRACT-IMPLICIT-SUPER-NEW`, `SV2023-8.17-EXTRACT-AFTER-DEFAULT-ARGUMENT`, `SV2023-8.17-EXTRACT-DEFAULT-EXPANSION`, `SV2023-8.17-EXTRACT-DEFAULT-NAME-CONFLICT`, `SV2023-8.17-EXTRACT-DEFAULT-ONCE`, `SV2023-8.17-EXTRACT-DEFAULT-REQUIRES-SUBCLASS`, `SV2023-8.17-EXTRACT-EXTENDS-DEFAULT-EXPLICIT`, `SV2023-8.17-EXTRACT-EXTENDS-DEFAULT-IMPLICIT`, `SV2023-8.17-EXTRACT-IMPLICIT-DEFAULT-FORWARD`, `SV2023-8.17-EXTRACT-NO-LOCAL-DEFAULT-DEPENDENCY`, `SV2023-8.17-EXTRACT-SUPER-DEFAULT-FORWARD`, `SV2023-8.17-EXTRACT-SUPER-DEFAULT-REQUIRES-EXPANSION`

| テスト | 種類 | `:oracle:` | 保存済みの結果 |
| --- | --- | --- | --- |
| [`ch8/test_class_constructor_default_argument_expansion`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/ch8/test_class_constructor_default_argument_expansion.sv) | 正常系 | `spec` | `I- V- Kp Gp` |
| [`ch8/test_constructor_default_argument`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/ch8/test_constructor_default_argument.sv) | 正常系 | `spec` | `I- V- Kp Gp` |
| [`ch8/test_constructor_default_empty_and_inout`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/ch8/test_constructor_default_empty_and_inout.sv) | 正常系 | `spec` | `I- V- K- Gp` |
| [`ch8/test_constructor_default_parameterized_superclass`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/ch8/test_constructor_default_parameterized_superclass.sv) | 正常系 | `spec` | `I- V- K- Gp` |
| [`ch8/test_constructor_default_through_implicit_constructor`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/ch8/test_constructor_default_through_implicit_constructor.sv) | 正常系 | `spec` | `I- V- K- Gp` |
| [`ch8/test_super_new_default`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/ch8/test_super_new_default.sv) | 正常系 | `spec` | `I- V- K- Gp` |
| [`ch8/test_illegal_constructor_default_name_conflict`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/ch8/test_illegal_constructor_default_name_conflict.sv) | 規格違反 | `spec` | `Ip Vp Kp Gp` |
| [`ch8/test_illegal_constructor_default_outside_subclass`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/ch8/test_illegal_constructor_default_outside_subclass.sv) | 規格違反 | `spec` | `Ip Vp Kp Gp` |
| [`ch8/test_illegal_constructor_default_repeated`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/ch8/test_illegal_constructor_default_repeated.sv) | 規格違反 | `spec` | `Ip Vp Kp Gp` |
| [`ch8/test_illegal_constructor_default_twice`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/ch8/test_illegal_constructor_default_twice.sv) | 規格違反 | `spec` | `Ip Vp Kp Gp` |
| [`ch8/test_illegal_default_depends_on_local_member`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/ch8/test_illegal_default_depends_on_local_member.sv) | 規格違反 | `spec` | `Ip Vp Kp Gp` |
| [`ch8/test_illegal_extends_default_without_default_argument`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/ch8/test_illegal_extends_default_without_default_argument.sv) | 規格違反 | `spec` | `I- V- Kp Gp` |
| [`ch8/test_illegal_super_default_without_expansion`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/ch8/test_illegal_super_default_without_expansion.sv) | 規格違反 | `spec` | `Ip Vp Kp Gp` |
| [`ch8/test_illegal_super_new_default_with_extends_default`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/ch8/test_illegal_super_new_default_with_extends_default.sv) | 規格違反 | `spec` | `I- Vp Kp Gp` |
| [`ch8/test_illegal_super_new_default_without_default`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/ch8/test_illegal_super_new_default_without_default.sv) | 規格違反 | `spec` | `Ip Vp Kp Gp` |

<a id="array-map-method"></a>

## 配列メソッド map

- 条項: 7.12.5, 7.12
- 規格が定める不正な形: map() には with 句が必須で、結果は元の配列の次元範囲とインデックス型を保つため、別の要素型・インデックス型の配列への代入はエラーである。 (7.12.5)
- 要求（対応済み／行数）: `SV2023-7.12.5-EXTRACT-MAP-REQUIRED-WITH`, `SV2023-7.12.5-EXTRACT-MAP-SELF-DETERMINED-TYPE`, `SV2023-7.12.5-EXTRACT-MAP-SHAPE`

| テスト | 種類 | `:oracle:` | 保存済みの結果 |
| --- | --- | --- | --- |
| [`ch7/test_array_map_method`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/ch7/test_array_map_method.sv) | 正常系 | `spec` | `I- V- K- Gp` |
| [`ch7/test_map_element_types_and_index_names`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/ch7/test_map_element_types_and_index_names.sv) | 正常系 | `spec` | `I- V- K- Gp` |
| [`ch7/test_map_result_to_same_array`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/ch7/test_map_result_to_same_array.sv) | 正常系 | `spec verilator@5.052` | `I- Vp K- Gp` |
| [`ch7/test_map_result_type_range_and_keys`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/ch7/test_map_result_type_range_and_keys.sv) | 正常系 | `spec` | `I- V- K- Gp` |
| [`ch7/test_map_selects_order_and_empty`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/ch7/test_map_selects_order_and_empty.sv) | 正常系 | `spec` | `I- V- K- Gp` |
| [`ch7/test_illegal_map_assoc_result_to_other_index_type`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/ch7/test_illegal_map_assoc_result_to_other_index_type.sv) | 規格違反 | `spec` | `Ip V- Kp Gp` |
| [`ch7/test_illegal_map_int_elements_to_string_queue`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/ch7/test_illegal_map_int_elements_to_string_queue.sv) | 規格違反 | `spec` | `Ip V- Kp Gp` |
| [`ch7/test_illegal_map_without_with`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/ch7/test_illegal_map_without_with.sv) | 規格違反 | `spec verilator@5.052` | `I- Vp Kp Gp` |

<a id="soft-packed-union"></a>

## union soft（soft packed union）

- 条項: 7.3.1, 7.3, 7.2
- 規格が定める不正な形: packed 次元が後ろに付く union は soft か packed（または両方）を持たなければならず、どちらもなければエラーである。 (7.3)
- 要求（対応済み／行数）: `SV2023-7.2-EXTRACT-UNION-DIMENSION-QUALIFIER`, `SV2023-7.3-EXTRACT-AGGREGATE-FOOTNOTES`, `SV2023-7.3-EXTRACT-UNION-GRAMMAR`, `SV2023-7.3.1-EXTRACT-SOFT-RECURSIVE`, `SV2023-7.3.1-EXTRACT-SOFT-RIGHT-ALIGN`, `SV2023-7.3.1-EXTRACT-SOFT-SIZE`, `SV2023-7.3.1-EXTRACT-SOFT-VARYING-SIZE`, `SV2023-7.3.1-EXTRACT-SOFT-WRITE-HIGH-UNCHANGED`

| テスト | 種類 | `:oracle:` | 保存済みの結果 |
| --- | --- | --- | --- |
| [`ch37/test_vpi_struct_union_flags_members`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/ch37/test_vpi_struct_union_flags_members.sv) | 正常系 | `spec` | `I- V- K- Gp` |
| [`ch37/test_vpi_struct_union_net_flags`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/ch37/test_vpi_struct_union_net_flags.sv) | 正常系 | `spec` | `I- V- K- Gp` |
| [`ch6/test_data_type_keyword_forms`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/ch6/test_data_type_keyword_forms.sv) | 正常系 | `spec verilator@5.052` | `I- Vp Kp Gp` |
| [`ch7/test_soft_packed_union`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/ch7/test_soft_packed_union.sv) | 正常系 | `spec verilator@5.052` | `I- Vp Kp Gp` |
| [`ch7/test_soft_packed_union_nested_layout`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/ch7/test_soft_packed_union_nested_layout.sv) | 正常系 | `spec verilator@5.052` | `I- Vp Kp Gp` |
| [`ch7/test_tagged_union_keywords_and_members`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/ch7/test_tagged_union_keywords_and_members.sv) | 正常系 | `spec` | `I- V- K- Gp` |
| [`ch7/test_union_grammar_forms`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/ch7/test_union_grammar_forms.sv) | 正常系 | `spec` | `I- V- K- Gp` |
| [`ch7/test_illegal_union_packed_dimension_needs_soft_or_packed`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/ch7/test_illegal_union_packed_dimension_needs_soft_or_packed.sv) | 規格違反 | `spec verilator@5.054` | `I- Vp Kp Gp` |

<a id="triple-quoted-string"></a>

## 三重引用符の文字列リテラル

- 条項: 5.9, 5.9.1, A.8.8, 22.5.1
- 規格が定める不正な形: マクロ本文では、`""" の中の（バックスラッシュのない）改行はマクロ定義を終了させ（通常の三重引用符リテラルとは異なる）、そこにある普通の " は同じ行で閉じなければならない文字列リテラルを始める。残った本文は通常のソースとなりエラーになる。 (22.5.1)
- 要求（対応済み／行数）: `SV2023-5.9-EXTRACT-STRING-DELIMITERS`, `SV2023-5.9-EXTRACT-TRIPLE-CHARACTERS`, `SV2023-5.9-EXTRACT-TRIPLE-ESCAPE-SAME`, `SV2023-5.9-EXTRACT-TRIPLE-RAW-NEWLINE`, `SV2023-5.9-EXTRACT-TRIPLE-RAW-QUOTE`, `SV2023-5.9.1-EXTRACT-TRIPLE-ESCAPES-SUPPORTED`, `SV2023-A.8.8-EXTRACT-ITEMS`, `SV2023-A.8.8-EXTRACT-STRING`, `SV2023-22.5.1-EXTRACT-MACRO-ARGUMENT-DELIMITERS`, `SV2023-22.5.1-EXTRACT-MACRO-LINE-CONTINUATION`, `SV2023-22.5.1-EXTRACT-MACRO-MIXED-QUOTES`, `SV2023-22.5.1-EXTRACT-MACRO-TRIPLE-QUOTE`, `SV2023-22.5.1-EXTRACT-MACRO-TRIPLE-STRING`

| テスト | 種類 | `:oracle:` | 保存済みの結果 |
| --- | --- | --- | --- |
| [`ch22/test_macro_grave_triple_quote`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/ch22/test_macro_grave_triple_quote.sv) | 正常系 | `spec` | `I- V- Kp Gp` |
| [`ch22/test_macro_grave_triple_quote_expansion_steps`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/ch22/test_macro_grave_triple_quote_expansion_steps.sv) | 正常系 | `spec` | `I- V- Kp Gp` |
| [`ch22/test_macro_grave_triple_quote_inner_quotes`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/ch22/test_macro_grave_triple_quote_inner_quotes.sv) | 正常系 | `spec verilator@5.052` | `I- Vp Kp Gp` |
| [`ch22/test_macro_triple_quoted_string_newline`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/ch22/test_macro_triple_quoted_string_newline.sv) | 正常系 | `spec verilator@5.052` | `I- Vp Kp Gp` |
| [`ch5/test_string_backslash_newline_continuation`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/ch5/test_string_backslash_newline_continuation.sv) | 正常系 | `spec verilator@5.052` | `I- Vp Kp Gp` |
| [`ch5/test_triple_quoted_and_quoted_string_contents`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/ch5/test_triple_quoted_and_quoted_string_contents.sv) | 正常系 | `spec verilator@5.052` | `I- Vp Kp Gp` |
| [`ch5/test_triple_quoted_string`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/ch5/test_triple_quoted_string.sv) | 正常系 | `spec verilator@5.052` | `I- Vp Kp Gp` |
| [`ch22/test_illegal_macro_grave_triple_quote_newline_ends_text`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/ch22/test_illegal_macro_grave_triple_quote_newline_ends_text.sv) | 規格違反 | `spec` | `Ip V- Kp Gp` |
| [`ch22/test_illegal_macro_grave_triple_quote_plain_quote_unclosed`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/ch22/test_illegal_macro_grave_triple_quote_plain_quote_unclosed.sv) | 規格違反 | `spec` | `I- V- Kp Gp` |

<a id="rand-real"></a>

## rand real 変数

- 条項: 18.4, 18.4.1, 18.5.3, 18.5.4, 18.5.5, 18.5.6, 18.5.9
- 規格が定める不正な形: real 変数（および real の配列）を randc で宣言してはならない。 (18.4); dist の real 範囲には明示的な :/ の重みが必要で、省略や := はエラーである。 (18.5.3)
- 要求（対応済み／行数）: `SV2023-18.4-EXTRACT-SINGULAR-TYPES`, `SV2023-18.4.1-EXTRACT-REAL-UNIFORM`, `SV2023-18.5.3-EXTRACT-DIST-ITEM-TYPES`, `SV2023-18.5.3-EXTRACT-REAL-SINGLE-WEIGHT`, `SV2023-18.5.4-EXTRACT-UNIQUE-GROUP`, `SV2023-18.5.5-EXTRACT-IMPLICATION-FORM`, `SV2023-18.5.6-EXTRACT-IF-FORM`, `SV2023-18.5.9-EXTRACT-ORDER-VARIABLE-TYPES`

| テスト | 種類 | `:oracle:` | 保存済みの結果 |
| --- | --- | --- | --- |
| [`ch18/test_rand_real_constraint`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/ch18/test_rand_real_constraint.sv) | 正常系 | `spec` | `I- V- K- Gp` |
| [`ch18/test_rand_real_kinds_and_arrays`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/ch18/test_rand_real_kinds_and_arrays.sv) | 正常系 | `spec` | `I- V- K- Gp` |
| [`ch18/test_rand_real_uniform_and_dist`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/ch18/test_rand_real_uniform_and_dist.sv) | 正常系 | `spec` | `I- V- K- Gp` |
| [`ch18/test_rand_real_unique_and_conditions`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/ch18/test_rand_real_unique_and_conditions.sv) | 正常系 | `spec` | `I- V- K- Gp` |
| [`ch18/test_illegal_dist_real_range_colon_equal`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/ch18/test_illegal_dist_real_range_colon_equal.sv) | 規格違反 | `spec` | `Ip Vp Kp Gp` |
| [`ch18/test_illegal_dist_real_range_no_weight`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/ch18/test_illegal_dist_real_range_no_weight.sv) | 規格違反 | `spec` | `Ip Vp Kp Gp` |
| [`ch18/test_illegal_dist_real_tolerance_colon_equal`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/ch18/test_illegal_dist_real_tolerance_colon_equal.sv) | 規格違反 | `spec` | `Ip V- Kp Gp` |
| [`ch18/test_illegal_randc_real`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/ch18/test_illegal_randc_real.sv) | 規格違反 | `spec` | `I- Vp Kp Gp` |
| [`ch18/test_illegal_randc_real_array`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/ch18/test_illegal_randc_real_array.sv) | 規格違反 | `spec` | `I- Vp Kp Gp` |
| [`ch18/test_illegal_unique_real_and_int`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/ch18/test_illegal_unique_real_and_int.sv) | 規格違反 | `spec` | `Ip V- Kp Gp` |

<a id="constraint-dynamic-override"></a>

## constraint の :initial / :extends / :final

- 条項: 18.5.2, 18.5, 18.5.10, 8.3
- 規格が定める不正な形: :initial は基底の制約を置き換えてはならず、:extends は置き換えなければならない。:initial と :extends は排他的で、:final の制約はサブクラスで置き換えられず、指定子はプロトタイプと外部ブロックの両方にあるか両方にないかでなければならない。 (18.5.2); pure 制約に final は使えず、static 制約に動的オーバーライド指定子は使えない（18.5.10）。 (18.5)
- 要求（対応済み／行数）: `SV2023-8.3-EXTRACT-NO-PURE-FINAL`, `SV2023-18.5-EXTRACT-PURE-NO-FINAL`, `SV2023-18.5-EXTRACT-STATIC-NO-OVERRIDE`, `SV2023-18.5.2-EXTRACT-EXTENDS-REQUIRES-OVERRIDE`, `SV2023-18.5.2-EXTRACT-FINAL-CONSTRAINT`, `SV2023-18.5.2-EXTRACT-INITIAL-EXTENDS-EXCLUSIVE`, `SV2023-18.5.2-EXTRACT-INITIAL-NO-OVERRIDE`, `SV2023-18.5.2-EXTRACT-MATCH-PROTOTYPE-SPECIFIERS`, `SV2023-18.5.10-EXTRACT-STATIC-NO-SPECIFIER`, `SV2023-A.10-EXTRACT-FOOTNOTE-11`, `SV2023-A.10-EXTRACT-FOOTNOTE-8`

| テスト | 種類 | `:oracle:` | 保存済みの結果 |
| --- | --- | --- | --- |
| [`ch18/test_constraint_final_constraint_mode_inline`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/ch18/test_constraint_final_constraint_mode_inline.sv) | 正常系 | `spec verilator@5.054` | `I- Vp K- Gp` |
| [`ch18/test_constraint_override_specifiers_prototypes_pure_param`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/ch18/test_constraint_override_specifiers_prototypes_pure_param.sv) | 正常系 | `spec verilator@5.054` | `I- Vp K- Gp` |
| [`ch18/test_constraint_override_specifiers_three_levels`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/ch18/test_constraint_override_specifiers_three_levels.sv) | 正常系 | `spec verilator@5.054` | `I- Vp K- Gp` |
| [`ch18/test_constraint_prototype_and_specifier_forms`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/ch18/test_constraint_prototype_and_specifier_forms.sv) | 正常系 | `spec verilator@5.052` | `I- Vp K- Gp` |
| [`ch18/test_illegal_constraint_extends_no_override`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/ch18/test_illegal_constraint_extends_no_override.sv) | 規格違反 | `spec` | `Ip V- Kp Gp` |
| [`ch18/test_illegal_constraint_final_replaced`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/ch18/test_illegal_constraint_final_replaced.sv) | 規格違反 | `spec` | `Ip V- Kp Gp` |
| [`ch18/test_illegal_constraint_final_replacement_replaced`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/ch18/test_illegal_constraint_final_replacement_replaced.sv) | 規格違反 | `spec` | `Ip V- Kp Gp` |
| [`ch18/test_illegal_constraint_initial_extends`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/ch18/test_illegal_constraint_initial_extends.sv) | 規格違反 | `spec verilator@5.052` | `Ip Vp Kp Gp` |
| [`ch18/test_illegal_constraint_initial_override`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/ch18/test_illegal_constraint_initial_override.sv) | 規格違反 | `spec` | `Ip V- Kp Gp` |
| [`ch18/test_illegal_constraint_specifier_block_mismatch`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/ch18/test_illegal_constraint_specifier_block_mismatch.sv) | 規格違反 | `spec` | `Ip V- Kp Gp` |
| [`ch18/test_illegal_constraint_specifier_prototype_mismatch`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/ch18/test_illegal_constraint_specifier_prototype_mismatch.sv) | 規格違反 | `spec` | `Ip V- Kp Gp` |
| [`ch18/test_illegal_pure_constraint_final`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/ch18/test_illegal_pure_constraint_final.sv) | 規格違反 | `spec` | `Ip Vp Kp Gp` |
| [`ch18/test_illegal_static_constraint_override`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/ch18/test_illegal_static_constraint_override.sv) | 規格違反 | `spec` | `Ip V- Kp Gp` |
| [`ch18/test_illegal_static_constraint_specifier`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/ch18/test_illegal_static_constraint_specifier.sv) | 規格違反 | `spec` | `Ip V- Kp Gp` |
| [`ch8/test_illegal_pure_constraint_final`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/ch8/test_illegal_pure_constraint_final.sv) | 規格違反 | `spec` | `Ip Vp Kp Gp` |

<a id="weak-reference"></a>

## weak_reference クラス

- 条項: 8.29, 8.30, 8.30.1, 8.30.2, 8.30.3, 8.30.4, 8.30.5, G.7, G.1
- 規格が定める不正な形: weak_reference はクラス型のパラメータを取り、それ以外の型（例えば int）で特殊化するとコンパイルエラーである。 (8.30.1)
- 要求（対応済み／行数）: `SV2023-8.29-EXTRACT-UNREACHABLE` (-), `SV2023-8.29-EXTRACT-WEAK-RECLAMATION-REFERENCE` (-), `SV2023-8.29-EXTRACT-WEAKLY-REACHABLE` (-), `SV2023-8.30.1-EXTRACT-ATOMIC-WEAK-CLEAR` (-), `SV2023-8.30.1-EXTRACT-STD-WEAK-REFERENCE`, `SV2023-8.30.1-EXTRACT-WEAK-CLASS-TYPE`, `SV2023-8.30.1-EXTRACT-WEAK-REFERENCE-NONRETAINING` (-), `SV2023-8.30.1-EXTRACT-WEAK-WRAPPER-GC` (-), `SV2023-8.30.2-EXTRACT-NULL-NO-WARNING`, `SV2023-8.30.2-EXTRACT-SIGNATURE`, `SV2023-8.30.2-EXTRACT-WRAPPER-IDENTITY`, `SV2023-8.30.3-EXTRACT-GET-EVENT-CONTROL`, `SV2023-8.30.3-EXTRACT-GET-REFERENT`, `SV2023-8.30.3-EXTRACT-SIGNATURE`, `SV2023-8.30.4-EXTRACT-CLEAR-NULL`, `SV2023-8.30.4-EXTRACT-SIGNATURE`, `SV2023-8.30.5-EXTRACT-LIFETIME-UNIQUE-ID`, `SV2023-8.30.5-EXTRACT-NULL-ZERO`, `SV2023-8.30.5-EXTRACT-NUMERIC-ID-NONRETAINING` (-), `SV2023-8.30.5-EXTRACT-SIGNATURE`, `SV2023-8.30.5-EXTRACT-STABLE-POLYMORPHIC-ID`, `SV2023-G.1-EXTRACT-CONTENTS`, `SV2023-G.7-EXTRACT-CLEAR`, `SV2023-G.7-EXTRACT-GET`, `SV2023-G.7-EXTRACT-ID`, `SV2023-G.7-EXTRACT-NEW`, `SV2023-G.7-EXTRACT-PARAMETER`

| テスト | 種類 | `:oracle:` | 保存済みの結果 |
| --- | --- | --- | --- |
| [`ch26/test_std_package_system_types`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/ch26/test_std_package_system_types.sv) | 正常系 | `spec` | `I- V- K- Gp` |
| [`ch8/test_object_strongly_reachable`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/ch8/test_object_strongly_reachable.sv) | 正常系 | `spec` | `I- V- K- Gp` |
| [`ch8/test_weak_reference_clear_void_no_arguments`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/ch8/test_weak_reference_clear_void_no_arguments.sv) | 正常系 | `spec` | `I- V- K- Gp` |
| [`ch8/test_weak_reference_get_clear`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/ch8/test_weak_reference_get_clear.sv) | 正常系 | `spec` | `I- V- K- Gp` |
| [`ch8/test_weak_reference_get_id`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/ch8/test_weak_reference_get_id.sv) | 正常系 | `spec` | `I- V- K- Gp` |
| [`ch8/test_weak_reference_get_id_static_longint`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/ch8/test_weak_reference_get_id_static_longint.sv) | 正常系 | `spec` | `I- V- K- Gp` |
| [`ch8/test_weak_reference_get_id_unique_across_types`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/ch8/test_weak_reference_get_id_unique_across_types.sv) | 正常系 | `spec` | `I- V- K- Gp` |
| [`ch8/test_weak_reference_id_alias_after_clear`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/ch8/test_weak_reference_id_alias_after_clear.sv) | 正常系 | `spec` | `I- V- K- Gp` |
| [`ch8/test_weak_reference_null_referent_no_warning`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/ch8/test_weak_reference_null_referent_no_warning.sv) | 正常系 | `spec` | `I- V- K- Gp` |
| [`ch8/test_weak_reference_prototypes`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/ch8/test_weak_reference_prototypes.sv) | 正常系 | `spec` | `I- V- K- Gp` |
| [`ch8/test_weak_reference_std_scope_and_strong_reachability`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/ch8/test_weak_reference_std_scope_and_strong_reachability.sv) | 正常系 | `spec` | `I- V- K- Gp` |
| [`ch8/test_weak_reference_wait_cleared`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/ch8/test_weak_reference_wait_cleared.sv) | 正常系 | `spec` | `I- V- K- Gp` |
| [`ch8/test_illegal_weak_reference_scalar_type`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/ch8/test_illegal_weak_reference_scalar_type.sv) | 規格違反 | `spec` | `Ip Vp Kp Gp` |

<a id="covergroup-inheritance"></a>

## covergroup extends（派生クラスの埋め込み covergroup）

- 条項: 19.3, 19.4, 19.4.1, A.2.11
- 規格が定める不正な形: covergroup の extends 形式はクラスの中でのみ許される。 (19.3); covergroup extends は基底クラスに存在する covergroup を指さなければならず（基底がなければエラー）、派生側は基底の引数とカバレッジイベントを引き継ぐので独自のものを宣言できない。 (19.4.1); 派生 covergroup は基底クラスの local メンバについて新しいカバレッジモデルを定義してはならない。 (19.4)
- 要求（対応済み／行数）: `SV2023-19.3-EXTRACT-EXTENDS-CLASS-ONLY`, `SV2023-19.4-EXTRACT-ENCAPSULATED-PROPERTIES`, `SV2023-19.4.1-EXTRACT-ADD-COVERPOINT`, `SV2023-19.4.1-EXTRACT-DISTINCT-COVERAGE-TYPES`, `SV2023-19.4.1-EXTRACT-EMBEDDED-EXTENDS`, `SV2023-19.4.1-EXTRACT-INHERIT-ARGS-EVENT`, `SV2023-19.4.1-EXTRACT-INHERIT-COMPONENTS`, `SV2023-19.4.1-EXTRACT-OVERRIDE-COVERPOINT`, `SV2023-19.4.1-EXTRACT-OVERRIDE-OPTIONS`, `SV2023-19.4.1-EXTRACT-REPLACE-INSTANCE`, `SV2023-A.10-EXTRACT-FOOTNOTE-29`, `SV2023-A.2.11-EXTRACT-COVERGROUP`

| テスト | 種類 | `:oracle:` | 保存済みの結果 |
| --- | --- | --- | --- |
| [`ch19/test_cg_derived_option_override`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/ch19/test_cg_derived_option_override.sv) | 正常系 | `spec` | `I- V- K- Gp` |
| [`ch19/test_cg_embedded_inheritance`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/ch19/test_cg_embedded_inheritance.sv) | 正常系 | `spec` | `I- V- K- Gp` |
| [`ch19/test_cg_extends_inherited_event_base_handle`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/ch19/test_cg_extends_inherited_event_base_handle.sv) | 正常系 | `spec` | `I- V- K- Gp` |
| [`ch19/test_cg_extends_type_option_inherited`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/ch19/test_cg_extends_type_option_inherited.sv) | 正常系 | `spec` | `I- V- K- Gp` |
| [`ch19/test_cg_inheritance_args_and_cross`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/ch19/test_cg_inheritance_args_and_cross.sv) | 正常系 | `spec` | `I- V- K- Gp` |
| [`ch19/test_covergroup_declaration_and_option_forms`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/ch19/test_covergroup_declaration_and_option_forms.sv) | 正常系 | `spec` | `I- V- K- Gp` |
| [`ch19/test_illegal_cg_extends_missing_base`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/ch19/test_illegal_cg_extends_missing_base.sv) | 規格違反 | `spec` | `Ip Vp Kp Gp` |
| [`ch19/test_illegal_cg_extends_not_base`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/ch19/test_illegal_cg_extends_not_base.sv) | 規格違反 | `spec` | `Ip Vp Kp Gp` |
| [`ch19/test_illegal_cg_extends_outside_class`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/ch19/test_illegal_cg_extends_outside_class.sv) | 規格違反 | `spec` | `Ip Vp Kp Gp` |
| [`ch19/test_illegal_cg_extends_own_arguments`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/ch19/test_illegal_cg_extends_own_arguments.sv) | 規格違反 | `spec` | `Ip Vp Kp Gp` |
| [`ch19/test_illegal_cg_extends_own_event`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/ch19/test_illegal_cg_extends_own_event.sv) | 規格違反 | `spec` | `Ip Vp Kp Gp` |
| [`ch19/test_illegal_cg_extends_property_name`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/ch19/test_illegal_cg_extends_property_name.sv) | 規格違反 | `spec` | `Ip Vp Kp Gp` |
| [`ch19/test_illegal_covergroup_derived_base_local`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/ch19/test_illegal_covergroup_derived_base_local.sv) | 規格違反 | `spec` | `Ip V- Kp Gp` |

<a id="ref-static"></a>

## ref static 引数

- 条項: 13.5.2, 13.3, 13.4, A.2.7
- 規格が定める不正な形: ref static 仮引数に、automatic 変数、動的サイズ配列の要素、非 static クラスプロパティ、static のない ref 仮引数を渡してはならない。 (13.5.2)
- 要求（対応済み／行数）: `SV2023-13.5.2-EXTRACT-REF-AUTOMATIC-RESTRICTIONS`, `SV2023-13.5.2-EXTRACT-REF-STATIC-ACCEPTED-ACTUALS`, `SV2023-13.5.2-EXTRACT-REF-STATIC-ACTUALS`, `SV2023-13.5.2-EXTRACT-REF-STATIC-AUTOMATIC-CONTEXTS`, `SV2023-13.3-EXTRACT-DIRECTION-INHERITANCE`, `SV2023-13.3-EXTRACT-TASK-PORT-GRAMMAR`, `SV2023-13.4-EXTRACT-FUNCTION-DIRECTION-DEFAULT`, `SV2023-A.2.7-EXTRACT-TF-DIRECTION`

| テスト | 種類 | `:oracle:` | 保存済みの結果 |
| --- | --- | --- | --- |
| [`ch13/test_function_formal_ref_static_direction_inherited`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/ch13/test_function_formal_ref_static_direction_inherited.sv) | 正常系 | `spec` | `I- V- Kp Gp` |
| [`ch13/test_ref_static_accepted_actuals`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/ch13/test_ref_static_accepted_actuals.sv) | 正常系 | `spec` | `I- V- K- Gp` |
| [`ch13/test_ref_static_const_waits_after_return`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/ch13/test_ref_static_const_waits_after_return.sv) | 正常系 | `spec` | `I- V- Kp Gp` |
| [`ch13/test_ref_static_force_release`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/ch13/test_ref_static_force_release.sv) | 正常系 | `spec` | `I- V- K- Gp` |
| [`ch13/test_task_direction_and_port_forms`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/ch13/test_task_direction_and_port_forms.sv) | 正常系 | `spec` | `I- V- Kp Gp` |
| [`ch13/test_task_formal_inherits_ref_static_nonblocking`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/ch13/test_task_formal_inherits_ref_static_nonblocking.sv) | 正常系 | `spec` | `I- V- Kp Gp` |
| [`ch13/test_tf_port_directions_ref_static_and_item_forms`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/ch13/test_tf_port_directions_ref_static_and_item_forms.sv) | 正常系 | `spec` | `I- V- Kp Gp` |
| [`ch9/test_ref_static_fork_join_none_after_return`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/ch9/test_ref_static_fork_join_none_after_return.sv) | 正常系 | `spec` | `I- V- Kp Gp` |
| [`gen/ch10/test_gen_ref_static_array_event_nba_w65_ascending`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/gen/ch10/test_gen_ref_static_array_event_nba_w65_ascending.sv) | 正常系 | `spec` | `I- V- Kp Gp` |
| [`gen/ch10/test_gen_ref_static_array_event_nba_w65_descending`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/gen/ch10/test_gen_ref_static_array_event_nba_w65_descending.sv) | 正常系 | `spec` | `I- V- Kp Gp` |
| [`gen/ch10/test_gen_ref_static_array_event_nba_w8_ascending`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/gen/ch10/test_gen_ref_static_array_event_nba_w8_ascending.sv) | 正常系 | `spec` | `I- V- Kp Gp` |
| [`gen/ch10/test_gen_ref_static_array_event_nba_w8_descending`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/gen/ch10/test_gen_ref_static_array_event_nba_w8_descending.sv) | 正常系 | `spec` | `I- V- Kp Gp` |
| [`gen/ch10/test_gen_ref_static_delayed_nba_w65_logic`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/gen/ch10/test_gen_ref_static_delayed_nba_w65_logic.sv) | 正常系 | `spec` | `I- V- Kp Gp` |
| [`gen/ch10/test_gen_ref_static_delayed_nba_w8_bit`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/gen/ch10/test_gen_ref_static_delayed_nba_w8_bit.sv) | 正常系 | `spec` | `I- V- Kp Gp` |
| [`gen/ch10/test_gen_ref_static_nested_packed_event_nba_w65_outside_parent`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/gen/ch10/test_gen_ref_static_nested_packed_event_nba_w65_outside_parent.sv) | 正常系 | `spec` | `I- V- Kp Gp` |
| [`gen/ch10/test_gen_ref_static_nested_packed_event_nba_w65_valid`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/gen/ch10/test_gen_ref_static_nested_packed_event_nba_w65_valid.sv) | 正常系 | `spec` | `I- V- Kp Gp` |
| [`gen/ch10/test_gen_ref_static_nested_packed_event_nba_w8_outside_parent`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/gen/ch10/test_gen_ref_static_nested_packed_event_nba_w8_outside_parent.sv) | 正常系 | `spec` | `I- V- Kp Gp` |
| [`gen/ch10/test_gen_ref_static_nested_packed_event_nba_w8_valid`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/gen/ch10/test_gen_ref_static_nested_packed_event_nba_w8_valid.sv) | 正常系 | `spec` | `I- V- Kp Gp` |
| [`ch13/test_illegal_ref_static_given_automatic_variable`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/ch13/test_illegal_ref_static_given_automatic_variable.sv) | 規格違反 | `spec` | `I- V- Kp Gp` |
| [`ch13/test_illegal_ref_static_given_dynamic_array_element`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/ch13/test_illegal_ref_static_given_dynamic_array_element.sv) | 規格違反 | `spec` | `I- V- Kp Gp` |
| [`ch13/test_illegal_ref_static_given_non_static_property`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/ch13/test_illegal_ref_static_given_non_static_property.sv) | 規格違反 | `spec` | `I- V- Kp Gp` |
| [`ch13/test_illegal_ref_static_given_plain_ref_argument`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/ch13/test_illegal_ref_static_given_plain_ref_argument.sv) | 規格違反 | `spec` | `I- V- Kp Gp` |

<a id="tolerance-ranges"></a>

## 許容誤差範囲 [A +/- B] と [A +%- B]

- 条項: 11.4.13, 18.5.3, 19.5.1, A.2.11, A.6.7
- 規格が定める不正な形: dist の real の許容誤差範囲は real 範囲なので :/ の重みが必要である（:= はエラー）。文字列の中心や unique リスト中の許容誤差範囲が不正になるのは、減算・加算による定義と unique の規則から導かれるもので、専用の文はない。 (18.5.3)
- 要求（対応済み／行数）: `SV2023-11.4.13-EXTRACT-ABSOLUTE-TOLERANCE`, `SV2023-11.4.13-EXTRACT-RELATIVE-TOLERANCE`, `SV2023-11.4.13-EXTRACT-TOLERANCE-ORDER-TYPE`, `SV2023-11.4.13-EXTRACT-TOLERANCE-TRUNCATES`, `SV2023-11.4.13-EXTRACT-INSIDE-GRAMMAR`, `SV2023-18.5.3-EXTRACT-DIST-ITEM-TYPES`, `SV2023-18.5.3-EXTRACT-REAL-SINGLE-WEIGHT`, `SV2023-19.5.1-EXTRACT-REAL-TOLERANCE`, `SV2023-A.2.11-EXTRACT-COVERAGE-RANGES`, `SV2023-A.6.7-EXTRACT-VALUE-RANGE`

| テスト | 種類 | `:oracle:` | 保存済みの結果 |
| --- | --- | --- | --- |
| [`ch11/test_expr_inside_set_forms`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/ch11/test_expr_inside_set_forms.sv) | 正常系 | `spec` | `I- V- Kp Gp` |
| [`ch11/test_inside_ranges_tolerance_unknown_and_types`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/ch11/test_inside_ranges_tolerance_unknown_and_types.sv) | 正常系 | `spec` | `I- V- Kp Gp` |
| [`ch11/test_inside_tolerance_center_type`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/ch11/test_inside_tolerance_center_type.sv) | 正常系 | `spec` | `I- V- Kp Gp` |
| [`ch11/test_inside_tolerance_ranges`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/ch11/test_inside_tolerance_ranges.sv) | 正常系 | `spec` | `I- V- Kp Gp` |
| [`ch12/test_syntax_case_matches_and_inside_forms`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/ch12/test_syntax_case_matches_and_inside_forms.sv) | 正常系 | `spec` | `I- V- K- Gp` |
| [`ch18/test_dist_tolerance_range_weights`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/ch18/test_dist_tolerance_range_weights.sv) | 正常系 | `spec` | `I- V- K- Gp` |
| [`ch18/test_rand_real_uniform_and_dist`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/ch18/test_rand_real_uniform_and_dist.sv) | 正常系 | `spec` | `I- V- K- Gp` |
| [`ch19/test_cg_real_bins_tolerance_and_merge`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/ch19/test_cg_real_bins_tolerance_and_merge.sv) | 正常系 | `spec` | `I- V- K- Gp` |
| [`ch19/test_cg_tolerance_bin_arrays_transitions`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/ch19/test_cg_tolerance_bin_arrays_transitions.sv) | 正常系 | `spec` | `I- V- K- Gp` |
| [`ch19/test_covergroup_bins_and_range_forms`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/ch19/test_covergroup_bins_and_range_forms.sv) | 正常系 | `spec` | `I- V- K- Gp` |
| [`gen/ch11/test_gen_cross_range_w129_s_ss_l_abs_tol_bound_x_m`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/gen/ch11/test_gen_cross_range_w129_s_ss_l_abs_tol_bound_x_m.sv) | 正常系 | `spec` | `I- V- Kp Gp` |
| [`gen/ch11/test_gen_cross_range_w129_s_us_l_rel_tol_bound_z_m`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/gen/ch11/test_gen_cross_range_w129_s_us_l_rel_tol_bound_z_m.sv) | 正常系 | `spec` | `I- V- Kp Gp` |
| [`gen/ch11/test_gen_cross_range_w129_w_us_b_abs_tol_known_s`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/gen/ch11/test_gen_cross_range_w129_w_us_b_abs_tol_known_s.sv) | 正常系 | `spec` | `I- V- Kp Gp` |
| [`gen/ch11/test_gen_cross_range_w1_s_uu_b_rel_tol_lhs_x_m`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/gen/ch11/test_gen_cross_range_w1_s_uu_b_rel_tol_lhs_x_m.sv) | 正常系 | `spec` | `I- V- Kp Gp` |
| [`gen/ch11/test_gen_cross_range_w1_s_uu_l_abs_tol_bound_z_m`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/gen/ch11/test_gen_cross_range_w1_s_uu_l_abs_tol_bound_z_m.sv) | 正常系 | `spec` | `I- V- Kp Gp` |
| [`gen/ch11/test_gen_cross_range_w1_s_uu_l_abs_tol_lhs_x_m`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/gen/ch11/test_gen_cross_range_w1_s_uu_l_abs_tol_lhs_x_m.sv) | 正常系 | `spec` | `I- V- Kp Gp` |
| [`gen/ch11/test_gen_cross_range_w1_s_uu_l_rel_tol_bound_x_m`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/gen/ch11/test_gen_cross_range_w1_s_uu_l_rel_tol_bound_x_m.sv) | 正常系 | `spec` | `I- V- Kp Gp` |
| [`gen/ch11/test_gen_cross_range_w32_n_su_b_abs_tol_bound_x_s`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/gen/ch11/test_gen_cross_range_w32_n_su_b_abs_tol_bound_x_s.sv) | 正常系 | `spec` | `I- V- Kp Gp` |
| [`gen/ch11/test_gen_cross_range_w32_w_us_b_rel_tol_bound_z_s`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/gen/ch11/test_gen_cross_range_w32_w_us_b_rel_tol_bound_z_s.sv) | 正常系 | `spec` | `I- V- Kp Gp` |
| [`gen/ch11/test_gen_cross_range_w33_s_uu_b_abs_tol_lhs_x_s`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/gen/ch11/test_gen_cross_range_w33_s_uu_b_abs_tol_lhs_x_s.sv) | 正常系 | `spec` | `I- V- Kp Gp` |
| [`gen/ch11/test_gen_cross_range_w33_w_su_b_rel_tol_bound_x_s`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/gen/ch11/test_gen_cross_range_w33_w_su_b_rel_tol_bound_x_s.sv) | 正常系 | `spec` | `I- V- Kp Gp` |
| [`gen/ch11/test_gen_cross_range_w64_n_uu_l_rel_tol_lhs_x_s`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/gen/ch11/test_gen_cross_range_w64_n_uu_l_rel_tol_lhs_x_s.sv) | 正常系 | `spec` | `I- V- Kp Gp` |
| [`gen/ch11/test_gen_cross_range_w64_w_uu_b_abs_tol_bound_z_s`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/gen/ch11/test_gen_cross_range_w64_w_uu_b_abs_tol_bound_z_s.sv) | 正常系 | `spec` | `I- V- Kp Gp` |
| [`gen/ch11/test_gen_cross_range_w65_n_ss_l_rel_tol_known_s`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/gen/ch11/test_gen_cross_range_w65_n_ss_l_rel_tol_known_s.sv) | 正常系 | `spec` | `I- V- Kp Gp` |
| [`gen/ch11/test_gen_cross_range_w65_n_us_l_abs_tol_known_m`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/gen/ch11/test_gen_cross_range_w65_n_us_l_abs_tol_known_m.sv) | 正常系 | `spec` | `I- V- Kp Gp` |
| [`gen/ch11/test_gen_cross_range_w65_s_su_b_rel_tol_known_m`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/gen/ch11/test_gen_cross_range_w65_s_su_b_rel_tol_known_m.sv) | 正常系 | `spec` | `I- V- Kp Gp` |
| [`ch11/test_illegal_inside_tolerance_string_center`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/ch11/test_illegal_inside_tolerance_string_center.sv) | 規格違反 | `spec` | `Ip Vp Kp Gp` |
| [`ch18/test_illegal_dist_real_tolerance_colon_equal`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/ch18/test_illegal_dist_real_tolerance_colon_equal.sv) | 規格違反 | `spec` | `Ip V- Kp Gp` |
| [`ch18/test_illegal_unique_tolerance_range`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/ch18/test_illegal_unique_tolerance_range.sv) | 規格違反 | `spec` | `Ip Vp K- Gp` |

<a id="method-dynamic-override"></a>

## function / task の :initial / :extends / :final

- 条項: 8.20, 8.3, 8.24, 13.3, 13.4, 35.5.4, A.2.6, A.2.7
- 規格が定める不正な形: :initial は virtual / pure virtual メソッドをオーバーライドしてはならず、:extends は virtual メソッドをオーバーライドしなければならない。:initial と :extends は排他的で、:final のメソッドは（virtual かどうかによらず）オーバーライドできず、pure virtual メソッドは :final にできない。 (8.20); 指定子は非 interface クラスのメソッドにだけ使え、クラスの外、interface class、DPI import の task / function には使えない（13.3、13.4、35.5.4、A.10 脚注 25）。 (8.3)
- 要求（対応済み／行数）: `SV2023-8.3-EXTRACT-DYNAMIC-OVERRIDE-SYNTAX`, `SV2023-8.3-EXTRACT-NO-PURE-FINAL`, `SV2023-8.3-EXTRACT-OVERRIDE-NONINTERFACE-METHOD`, `SV2023-8.20-EXTRACT-EXTENDS-IMPLIES-VIRTUAL`, `SV2023-8.20-EXTRACT-EXTENDS-REQUIRES-VIRTUAL-OVERRIDE`, `SV2023-8.20-EXTRACT-FINAL-NO-IMPLIED-VIRTUAL`, `SV2023-8.20-EXTRACT-FINAL-NO-OVERRIDE`, `SV2023-8.20-EXTRACT-INITIAL-EXTENDS-EXCLUSIVE`, `SV2023-8.20-EXTRACT-INITIAL-NO-IMPLIED-VIRTUAL`, `SV2023-8.20-EXTRACT-INITIAL-NO-VIRTUAL-OVERRIDE`, `SV2023-8.20-EXTRACT-PURE-NOT-FINAL`, `SV2023-8.24-EXTRACT-EXTERN-PROTOTYPE`, `SV2023-13.3-EXTRACT-OVERRIDE-METHOD-ONLY`, `SV2023-13.3-EXTRACT-TASK-GRAMMAR`, `SV2023-13.4-EXTRACT-FUNCTION-GRAMMAR`, `SV2023-13.4-EXTRACT-FUNCTION-TYPE-FOOTNOTES`, `SV2023-35.5.4-EXTRACT-PROTOTYPE-RESTRICTIONS`, `SV2023-A.2.6-EXTRACT-DECL`, `SV2023-A.2.6-EXTRACT-PROTOTYPE`, `SV2023-A.2.7-EXTRACT-DECL`, `SV2023-A.2.7-EXTRACT-OVERRIDES`, `SV2023-A.2.7-EXTRACT-PROTOTYPE`, `SV2023-A.10-EXTRACT-FOOTNOTE-25`, `SV2023-A.10-EXTRACT-FOOTNOTE-8`

| テスト | 種類 | `:oracle:` | 保存済みの結果 |
| --- | --- | --- | --- |
| [`ch13/test_a2_7_dynamic_override_specifiers`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/ch13/test_a2_7_dynamic_override_specifiers.sv) | 正常系 | `spec verilator@5.052` | `I- Vp Kp Gp` |
| [`ch13/test_function_declaration_scoped_and_override_forms`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/ch13/test_function_declaration_scoped_and_override_forms.sv) | 正常系 | `spec verilator@5.054` | `I- Vp K- Gp` |
| [`ch13/test_task_declaration_grammar_and_nesting`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/ch13/test_task_declaration_grammar_and_nesting.sv) | 正常系 | `spec` | `I- Vp Kp Gp` |
| [`ch8/test_class_declaration_grammar_forms`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/ch8/test_class_declaration_grammar_forms.sv) | 正常系 | `spec verilator@5.052` | `I- Vp K- Gp` |
| [`ch8/test_class_virtual_dispatch_and_initial`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/ch8/test_class_virtual_dispatch_and_initial.sv) | 正常系 | `spec` | `I- V- Kp Gp` |
| [`ch8/test_class_virtual_override_of_nonvirtual_and_initial`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/ch8/test_class_virtual_override_of_nonvirtual_and_initial.sv) | 正常系 | `spec verilator@5.052` | `I- Vp Kp Gp` |
| [`ch8/test_extern_method_prototype_qualifiers`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/ch8/test_extern_method_prototype_qualifiers.sv) | 正常系 | `spec verilator@5.052` | `I- Vp Kp Gp` |
| [`ch8/test_final_class_and_method`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/ch8/test_final_class_and_method.sv) | 正常系 | `spec verilator@5.052` | `I- Vp Kp Gp` |
| [`ch8/test_final_method_not_virtual_vpi`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/ch8/test_final_method_not_virtual_vpi.sv) | 正常系 | `spec` | `I- V- K- Gp` |
| [`ch8/test_method_initial_extends`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/ch8/test_method_initial_extends.sv) | 正常系 | `spec verilator@5.052` | `I- Vp Kp Gp` |
| [`ch9/test_structured_procedure_forms_and_subroutine_lifetimes`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/ch9/test_structured_procedure_forms_and_subroutine_lifetimes.sv) | 正常系 | `spec verilator@5.054` | `I- Vp Kp Gp` |
| [`ch13/test_illegal_dynamic_override_specifier_in_interface_class`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/ch13/test_illegal_dynamic_override_specifier_in_interface_class.sv) | 規格違反 | `spec` | `I- V- Kp Gp` |
| [`ch13/test_illegal_dynamic_override_specifier_on_module_task`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/ch13/test_illegal_dynamic_override_specifier_on_module_task.sv) | 規格違反 | `spec` | `I- V- Kp Gp` |
| [`ch13/test_illegal_function_override_specifier_interface_class`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/ch13/test_illegal_function_override_specifier_interface_class.sv) | 規格違反 | `spec` | `I- V- Kp Gp` |
| [`ch13/test_illegal_function_override_specifier_outside_class`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/ch13/test_illegal_function_override_specifier_outside_class.sv) | 規格違反 | `spec` | `Ip V- Kp Gp` |
| [`ch35/test_illegal_dpi_import_override_specifier`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/ch35/test_illegal_dpi_import_override_specifier.sv) | 規格違反 | `spec` | `Ip V- Kp Gp` |
| [`ch8/test_illegal_extends_nonvirtual_method`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/ch8/test_illegal_extends_nonvirtual_method.sv) | 規格違反 | `spec` | `Ip V- Kp Gp` |
| [`ch8/test_illegal_final_method_overridden`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/ch8/test_illegal_final_method_overridden.sv) | 規格違反 | `spec verilator@5.052` | `I- Vp Kp Gp` |
| [`ch8/test_illegal_final_pure_virtual`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/ch8/test_illegal_final_pure_virtual.sv) | 規格違反 | `spec` | `Ip V- Kp Gp` |
| [`ch8/test_illegal_initial_method_overrides_pure_virtual`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/ch8/test_illegal_initial_method_overrides_pure_virtual.sv) | 規格違反 | `spec verilator@5.052` | `Ip Vp Kp Gp` |
| [`ch8/test_illegal_initial_method_overrides_virtual`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/ch8/test_illegal_initial_method_overrides_virtual.sv) | 規格違反 | `spec verilator@5.052` | `Ip Vp Kp Gp` |
| [`ch8/test_illegal_method_extends_without_base`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/ch8/test_illegal_method_extends_without_base.sv) | 規格違反 | `spec verilator@5.052` | `Ip Vp Kp Gp` |
| [`ch8/test_illegal_method_initial_and_extends`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/ch8/test_illegal_method_initial_and_extends.sv) | 規格違反 | `spec verilator@5.052` | `Ip Vp Kp Gp` |
| [`ch8/test_illegal_method_initial_overrides`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/ch8/test_illegal_method_initial_overrides.sv) | 規格違反 | `spec verilator@5.052` | `Ip Vp Kp Gp` |
| [`ch8/test_illegal_method_initial_with_extends_specifier`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/ch8/test_illegal_method_initial_with_extends_specifier.sv) | 規格違反 | `spec verilator@5.052` | `Ip Vp Kp Gp` |
| [`ch8/test_illegal_nonvirtual_final_method_overridden`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/ch8/test_illegal_nonvirtual_final_method_overridden.sv) | 規格違反 | `spec verilator@5.052` | `I- Vp Kp Gp` |
| [`ch8/test_illegal_override_specifier_in_interface_class`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/ch8/test_illegal_override_specifier_in_interface_class.sv) | 規格違反 | `spec` | `I- V- Kp Gp` |
| [`ch8/test_illegal_override_specifier_outside_class`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/ch8/test_illegal_override_specifier_outside_class.sv) | 規格違反 | `spec` | `Ip V- Kp Gp` |
| [`ch8/test_illegal_pure_virtual_final`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/ch8/test_illegal_pure_virtual_final.sv) | 規格違反 | `spec` | `Ip Vp Kp Gp` |
| [`ch8/test_illegal_pure_virtual_method_final`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/ch8/test_illegal_pure_virtual_method_final.sv) | 規格違反 | `spec` | `Ip V- Kp Gp` |
| [`ch8/test_illegal_virtual_final_method_overridden_in_subclass`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/ch8/test_illegal_virtual_final_method_overridden_in_subclass.sv) | 規格違反 | `spec verilator@5.052` | `I- Vp Kp Gp` |
| [`ch9/test_illegal_override_specifier_in_interface_class`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/ch9/test_illegal_override_specifier_in_interface_class.sv) | 規格違反 | `spec` | `I- V- Kp Gp` |
| [`ch9/test_illegal_override_specifier_on_module_function`](https://github.com/kurochan001/kirimasim-tests/blob/main/tests/ch9/test_illegal_override_specifier_on_module_function.sv) | 規格違反 | `spec` | `Ip V- Kp Gp` |
