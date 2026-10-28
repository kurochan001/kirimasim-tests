# テスト側失敗 40 本のトリアージ（2026-10-28）

対象: kirimasim `a2420294` で 7,740 本を実行した結果の fail 176 本のうち、
テスト側の 40 本です。39 本が confirmed、1 本が likely です。

- スイート: `b83d0ffd`（2026-10-28）
- 結果: 手元の実行記録（JSON、7,740 本、fail 462）
- 関連: kirimasim の [失敗の再解析](https://github.com/kurochan001/kirimasim/blob/main/docs/kirimasim_failure_analysis_2026-10-28.md)、[非 slang のトリアージ](https://github.com/kurochan001/kirimasim/blob/main/docs/kirimasim_nonslang_triage_2026-10-28.md)

> この記録は判断の記録であり、期待値・テストはまだ変更していません。
> 修正は規格の節を根拠に、期待値の変更だけを別の PR に分けます。

## 1. Issue 別の件数

| Issue | 内容 | 件数 |
|---:|---|---:|
| #6 | checker の initial 代入・always_comb 内宣言（5 本） | 5 |
| #7 | deferred assertion の action が代入（3 本） | 3 |
| #8 | severity / `$fatal` / clocking の regex（5 本） | 5 |
| #9 | readmemh の start/finish（1 本） | 1 |
| #10 | specparam / program signal / checker delay（3 本） | 3 |
| #15 | 文法に反する構文（6 本） | 6 |
| #16 | multiclock・unique・angle include・interface 内 module・modport・宣言前使用（7 本） | 7 |
| #17 | `$future_gclk`・`local`・virtual interface port・`out`・soft union（6 本） | 6 |
| #18 | 配列クエリへの real/shortreal/event（3 本） | 3 |
| #19 | `1'b1[*]` を property に使用（1 本） | 1 |

## 2. 1 本ずつの記録

| テスト | Issue | 確度 | 節 | 理由 |
|---|---:|---|---|---|
| `ch17/test_checker_always_statement_kinds` | #6 | likely | 1800-2023 17.5 | 17.5 does not list block item declarations; the for-loop declaration needs confirmation |
| `ch17/test_checker_body_procedural_and_generate_items` | #6 | confirmed | 1800-2023 17.5 17.7 A.1.8 | 17.5/17.7.1: initial may contain only let, assertions and an event control |
| `ch17/test_checker_declaration_and_port_forms` | #6 | confirmed | 1800-2023 17.2 A.1.2 A.1.8 | 17.5/17.7.1: initial may contain only let, assertions and an event control |
| `ch17/test_checker_rand_and_nested_checker` | #6 | confirmed | 1800-2023 17.2 17.7 A.1.8 | 17.7.1: a checker variable cannot be assigned in an initial procedure |
| `ch6/test_design_element_static_lifetime` | #6 | confirmed | 1800-2023 6.21 | 17.5/17.7.1: checker initial assignment and plain always |
| `ch17/test_checker_assertion_placement` | #7 | confirmed | 1800-2023 17.3 17.5 16.14.6 16.4 | 16.4.1: a deferred assertion action must be a subroutine call |
| `ch17/test_checker_body_items` | #7 | confirmed | 1800-2023 17.2 17.5 17.3 17.7 17.1 | 16.4.1: a deferred assertion action must be a subroutine call |
| `ch17/test_checker_procedural_deferred_assertion` | #7 | confirmed | 1800-2023 17.3 16.4.1 16.14.6.1 | 16.4.1: a deferred assertion action must be a subroutine call |
| `ch16/test_ch16_sim_clocking_single` | #8 | confirmed | 1800-2023 16.16 16.16.1 | 16.16: the explicit-clock and multiclock rules both apply; regex is too narrow |
| `ch20/test_fatal_form_finish_number_and_arguments` | #8 | confirmed | 1800-2023 20.10 20.2 A.1.4 | 20.10: message format is tool-defined; regex must accept either order |
| `ch20/test_fatal_form_finish_number_only` | #8 | confirmed | 1800-2023 20.10 20.2 A.1.4 | 20.10: message format is tool-defined; regex must accept either order |
| `ch20/test_fatal_form_without_parentheses` | #8 | confirmed | 1800-2023 20.10 20.2 A.1.4 | 20.10: message format is tool-defined; regex must accept either order |
| `ch20/test_severity_tasks_report_contents` | #8 | confirmed | 1800-2023 20.10 22.13 | 20.10: message format is tool-defined; regex must accept either order |
| `ch21/test_readmemh_address_range` | #9 | confirmed | 1800-2023 21.4.3 21.4.1 7.4.4 | 21.4/21.4.3: start/finish address the highest dimension, so 2..5 is out of range |
| `ch11/test_A_extra_specparam_range` | #10 | confirmed | 1800-2023 11.2.1 6.20.5 A.8.4 | 6.20.5: specparam cannot initialize a localparam |
| `ch17/test_checker_declaration_scope_kinds` | #10 | confirmed | 1800-2023 17.2 | 24.3: a program signal cannot be read from outside a program |
| `ch23/test_scope_creators_all_kinds` | #10 | confirmed | 1800-2023 23.9 | 17.5: a checker initial may not contain a delay or $display |
| `ch11/test_conditional_predicate_and_integral_branch` | #15 | confirmed | 1800-2023 11.4.11 | 12.6.3: a matches clause is a cond_pattern, not a parenthesized expression |
| `ch11/test_tagged_union_expression_and_matches_precedence` | #15 | confirmed | 1800-2023 11.9 7.3.2 A.8.3 A.10 | 12.6: matches is only allowed in a predicate or case ... matches |
| `ch12/test_pattern_conditional_predicate` | #15 | confirmed | 1800-2023 12.6.3 12.6.2 11.4.11 | 12.6.3: a matches clause is a cond_pattern, not a parenthesized expression |
| `ch12/test_pattern_match_known_result` | #15 | confirmed | 1800-2023 12.6 12.6.1 | 12.6: matches is only allowed in a predicate or case ... matches |
| `ch19/test_cg_bin_syntax_all_forms` | #15 | confirmed | 1800-2023 19.5 19.5.1 19.5.2 19.5.3 19.5.4 19.11.1 | 19.5: wildcard precedes bins_keyword, not = |
| `ch23/test_syntax_port_expression_and_explicit_ports` | #15 | confirmed | 1800-2023 23.2.2.1 23.2.2.2 23.2.2.3 A.1.3 | Annex B: cell is a reserved keyword and cannot be a port identifier |
| `ch16/test_nexttime_always_eventually_alignment` | #16 | confirmed | 1800-2023 16.12.10 16.12.11 16.12.13 | 16.13.1: only ##1 and ##0 may combine differently clocked operands |
| `ch16/test_triggered_matched_multiclock` | #16 | confirmed | 1800-2023 16.13.5 16.13.6 16.13.1 16.7 16.14.3 | 16.13.1: only ##1 and ##0 may combine a multiclocked operand |
| `ch18/test_uniqueness_constraint_forms` | #16 | confirmed | 1800-2023 18.5.4 18.5 A.10 | 18.5.4: the range_list names variables, but this test needs rand variables to be satisfiable |
| `ch22/test_22_extra_include_syntax` | #16 | confirmed | 1800-2023 22.4 22.5.1 | 22.4: angle-bracket include searches only the standard location |
| `ch25/test_interface_abstract_methods_and_broadcast` | #16 | confirmed | 1800-2023 25.2 25.7.4 | 25.5: a modport restricts access to the names it lists; value is not in caller |
| `ch25/test_interface_extern_and_generate_items` | #16 | confirmed | 1800-2023 25.7 25.3 A.1.6 A.2.9 | 25.3: a module cannot be instantiated in an interface |
| `ch5/test_attribute_prefix_positions` | #16 | confirmed | 1800-2023 5.12 | 6.10: the explicit net declaration after the use is a redeclaration; declare it before the instance |
| `ch16/test_ch16_sim_checker_history` | #17 | confirmed | 1800-2023 16.5.1 17.7 16.9.4 | 16.9.4: $future_gclk is only allowed in a sequence or property expression |
| `ch16/test_sequence_formal_arguments_substitution` | #17 | confirmed | 1800-2023 16.8 16.8.1 16.12.18 16.12.19 | 16.8.1: a formal direction requires the local keyword |
| `ch16/test_sequence_local_formal_assignment` | #17 | confirmed | 1800-2023 16.8.1 | 16.8.1: the actual of an inout/output local formal must be a local variable |
| `ch25/test_virtual_interface_data_type_forms` | #17 | confirmed | 1800-2023 25.9 25.9.2 A.2.2.1 | 25.9: a virtual interface shall not be used as a port |
| `ch6/test_void_return_and_tagged_union_void_member` | #17 | confirmed | 1800-2023 6.13 7.3.2 11.9 | 6.13: the direction keyword is output, not out |
| `ch7/test_union_grammar_forms` | #17 | confirmed | 1800-2023 7.3 | 7.3.1: a soft packed union still needs integral members |
| `ch20/test_array_query_dimension_counts` | #18 | confirmed | 1800-2023 20.7 | 20.7: real, shortreal and event are outside the array/integral/string domain |
| `ch20/test_array_query_functions` | #18 | confirmed | 1800-2023 20.7 | 20.7: real, shortreal and event are outside the array/integral/string domain |
| `ch20/test_array_query_invalid_dimension_all_x` | #18 | confirmed | 1800-2023 20.7 21.2.1.3 | 20.7: real, shortreal and event are outside the array/integral/string domain |
| `ch16/test_A_extra_repetitions` | #19 | confirmed | 1800-2023 16.9.2 A.2.10 | 16.12.22: a sequence used as a property shall not admit an empty match |

## 3. 修正の進め方

- 期待値の変更は、規格の節と「なぜ今の期待値が規格に反するか」を書いた別 PR にする。
- テストの設計そのものを直す場合（checker の initial、文法、modport など）も、
  `src/` の変更と同じ PR に混ぜない。
- likely の 1 本（`ch17/test_checker_always_statement_kinds`）は、
  宣言を checker body に移す書き換えにしてから確定する。
- Issue #13（formal テストの誤実行）と #14（kirimasim の分類順）は
  [ランナー選択の修正](runner-selection-20261028.md)で対応した。

## 4. 関連

- slang 上流への報告候補は、kirimasim の `docs/notes/slang-*-issue-draft.md` に下書きがある。
  まだ slang のリポジトリには投稿していません。
- 286 本の「`:expected_stdout:` なし」は、268 formal / 16 unsupported / 2 テスト整備に分かれる。
  この 40 本とは別枠。
