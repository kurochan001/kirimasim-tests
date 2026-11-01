<a id="triage-of-40-test-side-failures-2026-10-28"></a>

# テスト側失敗 40 本のトリアージ（2026-10-28）

[English](test-failure-triage-20261028.en.md) / [日本語](test-failure-triage-20261028.md)

> 以下は修正前のトリアージ記録です。テスト側のIssue #6–#12・#15–#19は
> [46本の修正](test-side-fixes-20261028.md)、#13・#14は
> [ランナー選択の修正](runner-selection-20261028.md)で対応済みです。

対象: kirimasim `a2420294` で 7,740 本を実行した結果の fail 176 本のうち、 テスト側の 40 本です。39 本が confirmed、1 本が likely です。

- スイート: `b83d0ffd`（2026-10-28）
- 結果: 手元の実行記録（JSON、7,740 本、fail 462）
- 関連: kirimasim の [失敗の再解析](https://github.com/kurochan001/kirimasim/blob/main/docs/kirimasim_failure_analysis_2026-10-28.md)、[非 slang のトリアージ](https://github.com/kurochan001/kirimasim/blob/main/docs/kirimasim_nonslang_triage_2026-10-28.md)

> この記録は判断の記録です。修正は `docs/test-side-fixes-20261028.md` にまとめ、
> 規格の節を根拠にテストと期待値を直しました。

<a id="1--counts-by-issue"></a>

## 1. Issue 別の件数

|Issue| 内容 | 件数 |
|---:|---|---:|
| #6 | checker の initial 代入・always_comb 内宣言（5 本） | 5 |
| #7 |遅延アサーションのアクションが代入（3本）| 3 |
| #8 |severity / `$fatal` / clocking の regex（5 本）| 5 |
| #9 |readmemh の開始/終了（1 本）| 1 |
| #10 |specparam／program信号／checker内遅延（3本）| 3 |
| #15 | 文法に反する構文（6 本） | 6 |
| #16 |マルチクロック・ユニーク・アングルインクルー・インタフェース内モジュール・モッドポート・宣言前使用（7本）| 7 |
| #17 |`$future_gclk`・`local`・仮想interfaceポート・`out`・soft共用体（6本）| 6 |
| #18 | 配列クエリへの real/shortreal/event（3 本） | 3 |
| #19 | `1'b1[*]` を property に使用（1 本） | 1 |

<a id="2--records-in-groups-of-1-tests"></a>

## 2. 1 本ずつの記録

| テスト |Issue| 確度 | 節 | 理由 |
|---|---:|---|---|---|
| `ch17/test_checker_always_statement_kinds` | #6 |可能性が高い| 1800-2023 17.5 |17.5 はブロックアイテムの宣言をリスト化しません。for-loop宣言は確認が必要です|
| `ch17/test_checker_body_procedural_and_generate_items` | #6 |確認しました| 1800-2023 17.5 17.7 A.1.8 |17.5/17.7.1 : initial は let 、アサーション、イベントコントロールのみを含むことができる|
| `ch17/test_checker_declaration_and_port_forms` | #6 |確認しました| 1800-2023 17.2 A.1.2 A.1.8 |17.5/17.7.1 : initial は let 、アサーション、イベントコントロールのみを含むことができる|
| `ch17/test_checker_rand_and_nested_checker` | #6 |確認しました| 1800-2023 17.2 17.7 A.1.8 |17.7.1: チェッカー変数は初期手続きで割り当てられません|
| `ch6/test_design_element_static_lifetime` | #6 |確認しました| 1800-2023 6.21 |17.5/17.7.1：checkerのinitial内の代入と、通常のalways|
| `ch17/test_checker_assertion_placement` | #7 |確認しました| 1800-2023 17.3 17.5 16.14.6 16.4 |16.4.1: 遅延アサーションアクションはサブルーティンコールでなければなりません|
| `ch17/test_checker_body_items` | #7 |確認しました| 1800-2023 17.2 17.5 17.3 17.7 17.1 |16.4.1: 遅延アサーションアクションはサブルーティンコールでなければなりません|
| `ch17/test_checker_procedural_deferred_assertion` | #7 |確認しました| 1800-2023 17.3 16.4.1 16.14.6.1 |16.4.1: 遅延アサーションアクションはサブルーティンコールでなければなりません|
| `ch16/test_ch16_sim_clocking_single` | #8 |確認しました| 1800-2023 16.16 16.16.1 |16.16: 明示的クロックとマルチクロックの両方のルールが適用されます。正規表現が狭すぎます|
| `ch20/test_fatal_form_finish_number_and_arguments` | #8 |確認しました| 1800-2023 20.10 20.2 A.1.4 |20.10: メッセージフォーマットはツールで定義されます。正則表現はどちらの順序でも受け入れなければなりません|
| `ch20/test_fatal_form_finish_number_only` | #8 |確認しました| 1800-2023 20.10 20.2 A.1.4 |20.10: メッセージフォーマットはツールで定義されます。正則表現はどちらの順序でも受け入れなければなりません|
| `ch20/test_fatal_form_without_parentheses` | #8 |確認しました| 1800-2023 20.10 20.2 A.1.4 |20.10: メッセージフォーマットはツールで定義されます。正則表現はどちらの順序でも受け入れなければなりません|
| `ch20/test_severity_tasks_report_contents` | #8 |確認しました| 1800-2023 20.10 22.13 |20.10: メッセージフォーマットはツールで定義されます。正則表現はどちらの順序でも受け入れなければなりません|
| `ch21/test_readmemh_address_range` | #9 |確認しました| 1800-2023 21.4.3 21.4.1 7.4.4 |21.4/21.4.3：start／finishは最上位次元を指定するため、2…5は範囲外です|
| `ch11/test_A_extra_specparam_range` | #10 |確認しました| 1800-2023 11.2.1 6.20.5 A.8.4 |6.20.5: specparam localparam を初期化できません|
| `ch17/test_checker_declaration_scope_kinds` | #10 |確認しました| 1800-2023 17.2 |24.3: プログラム信号はプログラムの外から読めません|
| `ch23/test_scope_creators_all_kinds` | #10 |確認しました| 1800-2023 23.9 |17.5：checkerのinitialには遅延や$displayを含めてはならない|
| `ch11/test_conditional_predicate_and_integral_branch` | #15 |確認しました| 1800-2023 11.4.11 |12.6.3：matches節はcond_patternであり、括弧付きの式ではない|
| `ch11/test_tagged_union_expression_and_matches_precedence` | #15 |確認しました| 1800-2023 11.9 7.3.2 A.8.3 A.10 |12.6：matchesは述語またはcase ... matches内でだけ許される|
| `ch12/test_pattern_conditional_predicate` | #15 |確認しました| 1800-2023 12.6.3 12.6.2 11.4.11 |12.6.3：matches節はcond_patternであり、括弧付きの式ではない|
| `ch12/test_pattern_match_known_result` | #15 |確認しました| 1800-2023 12.6 12.6.1 |12.6：matchesは述語またはcase ... matches内でだけ許される|
| `ch19/test_cg_bin_syntax_all_forms` | #15 |確認しました| 1800-2023 19.5 19.5.1 19.5.2 19.5.3 19.5.4 19.11.1 |19.5：ワイルドカードはbins_keyword、not =より前に置く|
| `ch23/test_syntax_port_expression_and_explicit_ports` | #15 |確認しました| 1800-2023 23.2.2.1 23.2.2.2 23.2.2.3 A.1.3 |付属 B: cell は予約キーワードであり、ポート識別子にはなりません|
| `ch16/test_nexttime_always_eventually_alignment` | #16 |確認しました| 1800-2023 16.12.10 16.12.11 16.12.13 |16.13.1: ## 1 と ## 0 のみが異なるクロックのオペランドを組み合わせることができる|
| `ch16/test_triggered_matched_multiclock` | #16 |確認しました| 1800-2023 16.13.5 16.13.6 16.13.1 16.7 16.14.3 |16.13.1: マルチクロックオペランドを組み合わせるには ## 1 と ## 0 のみが必要です|
| `ch18/test_uniqueness_constraint_forms` | #16 |確認しました| 1800-2023 18.5.4 18.5 A.10 |18.5.4: range_list は変数名を付けるが、このテストは満足できるようにするには rand 変数が必要です。|
| `ch22/test_22_extra_include_syntax` | #16 |確認しました| 1800-2023 22.4 22.5.1 |22.4：山括弧形式のincludeは標準の場所だけを検索する|
| `ch25/test_interface_abstract_methods_and_broadcast` | #16 |確認しました| 1800-2023 25.2 25.7.4 |25.5: modport はリストされている名前にアクセスを制限します。値は呼び出し者にない|
| `ch25/test_interface_extern_and_generate_items` | #16 |確認しました| 1800-2023 25.7 25.3 A.1.6 A.2.9 |25.3: インターフェースにモジュールをインスタンスできません|
| `ch5/test_attribute_prefix_positions` | #16 |確認しました| 1800-2023 5.12 |6.10：使用後の明示的なネット宣言は再宣言である。インスタンスより前で宣言する|
| `ch16/test_ch16_sim_checker_history` | #17 |確認しました| 1800-2023 16.5.1 17.7 16.9.4 |16.9.4: $future_gclk はシーケンスまたはプロパティ表現のみで許可されます|
| `ch16/test_sequence_formal_arguments_substitution` | #17 |確認しました| 1800-2023 16.8 16.8.1 16.12.18 16.12.19 |16.8.1：仮引数の方向指定にはlocalキーワードが必要|
| `ch16/test_sequence_local_formal_assignment` | #17 |確認しました| 1800-2023 16.8.1 |16.8.1：inout／output local仮引数の実引数は、ローカル変数でなければならない|
| `ch25/test_virtual_interface_data_type_forms` | #17 |確認しました| 1800-2023 25.9 25.9.2 A.2.2.1 |25.9：仮想interfaceをポートとして使用してはならない|
| `ch6/test_void_return_and_tagged_union_void_member` | #17 |確認しました| 1800-2023 6.13 7.3.2 11.9 |6.13: direction キーワードは output で、out ではありません|
| `ch7/test_union_grammar_forms` | #17 |確認しました| 1800-2023 7.3 |7.3.1：soft packed共用体でも、メンバーは整数型である必要がある|
| `ch20/test_array_query_dimension_counts` | #18 |確認しました| 1800-2023 20.7 |20.7：real、shortreal、eventは、配列／整数型／文字列の対象領域外|
| `ch20/test_array_query_functions` | #18 |確認しました| 1800-2023 20.7 |20.7：real、shortreal、eventは、配列／整数型／文字列の対象領域外|
| `ch20/test_array_query_invalid_dimension_all_x` | #18 |確認しました| 1800-2023 20.7 21.2.1.3 |20.7：real、shortreal、eventは、配列／整数型／文字列の対象領域外|
| `ch16/test_A_extra_repetitions` | #19 |確認しました| 1800-2023 16.9.2 A.2.10 |16.12.22：プロパティとして使用するシーケンスは、空マッチを許してはならない|

<a id="3-how-to-proceed-with-the-correction"></a>

## 3. 修正の進め方

- 期待値の変更は、規格の節と「なぜ今の期待値が規格に反するか」を書いた別 PR にする。
- テストの設計そのものを直す場合（checker の initial、文法、modport など）も、 `src/` の変更と同じ PR に混ぜない。
- likely の 1 本（`ch17/test_checker_always_statement_kinds`）は、 宣言を checker body に移す書き換えにしてから確定する。
- Issue #13（formal テストの誤実行）と #14（kirimasim の分類順）は [ランナー選択の修正](runner-selection-20261028.md)で対応した。
- テスト側の #6–#12、#15–#19 は [テスト側の修正](test-side-fixes-20261028.md)で対応した。

<a id="4-related"></a>

## 4. 関連

- slang 上流への報告候補は、kirimasim の `docs/notes/slang-*-issue-draft.md` に下書きがある。 まだ slang のリポジトリには投稿していません。
- 286 本の「`:expected_stdout:` なし」は、268 formal / 16 unsupported / 2 テスト整備に分かれる。 この 40 本とは別枠。
