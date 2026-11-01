<a id="review-of-standard-only-tests-disagreeing-with-lyra-2026-10-25"></a>

# Lyra と一致しない「規格のみ」のテストの見直し（2026-10-25）

[English](lyra-disagreement-review-20261025.en.md) / [日本語](lyra-disagreement-review-20261025.md)

[シミュレータと規格の差異](simulator-differences.ja.md) / [Nightly resultsの見方](nightly-results.md) / [手順書](requirements-to-tests-method.md)

Lyra は `:oracle:` には使わず、比較用のシミュレータとして毎晩実行しています（[手順書](requirements-to-tests-method.md)の7.1と12節）。 その結果を、期待値を見直すきっかけとして使いました。

対象は、期待値が規格だけを根拠にしている（`:oracle: spec`）1,314本のうち、Lyra（固定コミット `7e2c604b9ab2`）が実行できたのに期待どおりにならなかった194本です。 2026年10月25日の定時の nightly（[実行40135271002](https://github.com/kurochan001/kirimasim-tests/actions/runs/40135271002)、suite commit `c87448b`）の結果を使いました。 kirimasim の結果も並べています。ただし、Lyra と kirimasim はフロントエンドに slang を共有しているので、構文解析や展開に関する両者の一致は、独立した裏付けになりません。

<a id="summary"></a>

## まとめ

| 分類 | 本数 | 見直しの結果 |
| --- | ---: | --- |
| 出力の不一致 | 65 | テストの判定の不備2本（下記、修正済み）。ほかは Lyra 側の未実装や誤りで、確かめた規則ではすべて期待値が正しかった |
| 規格上正しいコードを拒否（コンパイルエラー） | 28 | ほとんどが slang の診断。確かめたものは、すべてテストが正しく、slang の方が厳しすぎる |
| 規格違反のコードを受理 | 86 | どのシミュレータも期待した場所で拒否できていない。根拠は AI の検証だけなので、優先して見直す対象 |
| 内部エラー・クラッシュ | 10 | Lyra 側の問題 |
| 規格違反のコードを別の場所で拒否 | 5 | Lyra 側の問題 |

期待出力を誤りと判断したテストは、ありませんでした。

<a id="test-defect-found-the-assessment-regex-depends-on-formatting"></a>

## 見つかったテストの不備：判定の正規表現が書式に依存している

次の2本の `:expected_stderr_regex:` は、同じ行で `error` が場所（`ファイル:行:`）より前にあることを求めています。 これは Icarus Verilog（`ERROR: ファイル:行: …`）や Verilator（`%Error: ファイル:行: …`）の書式です。 kirimasim と Lyra は clang の書式（`ファイル:行: error: …`）で、場所が先に来ます。 重大度のタスクのメッセージの書式は、ツールに任されています（20.10）。テストのコメントにも「文言は比べない」とあります。

| テスト | `:oracle:` | 状況 |
| --- | --- | --- |
| `ch16/test_deferred_assertion_default_error` | `spec` | kirimasim は43行目と44行目だけを期待どおりエラーとして報告するが、書式のために不一致になる。Lyra も同じ |
| `ch16/test_immediate_assertion_default_error` | `spec verilator@5.052` | 同じ書き方。Lyra と kirimasim はどちらも `$assertcontrol` が未実装で、まだ表に出ていない |

2026年10月25日に、正規表現をどちらの順でも受け付ける形（`error[^\n]*ファイル:行:` と `ファイル:行:[^\n]*error` のどちらか）に直しました。 求める行と禁じる行は変えていません。コメントもあわせて直し、行番号が動かないようにしています。

- 2本を Icarus Verilog 13.0 と Verilator 5.052（seed 1/73）で再実行しました（`coverage/results/regex-refinement-20261025-*.json`）。
- `test_immediate_assertion_default_error` は、`:oracle:` に記載のとおり Verilator 5.052 で一致します。Icarus 13.0 は、これまでどおり2本とも known です。
- kirimasim では、`test_deferred_assertion_default_error` が一致するようになりました。
- 台帳の、正規表現の行を引用した根拠3件と、入力ハッシュを付け直しました。

<a id="rules-checked-against-the-standard"></a>

## 規格で確かめた規則

出力の不一致と、規格上正しいコードの拒否のうち、次のものは規格の本文で確かめ、期待値やテストが正しいと判断しました。

| テスト | 根拠 | 判断 |
| --- | --- | --- |
| `ch11/test_conditional_real_shortreal_branch_promotion` | 11.4.11、6.12 | shortreal は単精度なので 16777216.0。Lyra と kirimasim は倍精度のまま |
| `ch4/test_reactive_region_set_order` | 4.5 | active 領域の集合を先に処理するので、module 側が先に記録する |
| `ch6/test_string_atoreal_scan_rules` | 6.16.10、5.7.2 | 実数定数の下線は使えるので 10.25 |
| `atoi("-12")` などを含む4本 | 6.16.9 | atoi は符号を解釈しないので 0。kirimasim は期待どおり |
| `ch19/test_option_member_defaults` | 19.7.1 | カバーグループで設定した type option のうち、real_interval だけはカバーポイントの既定値になる |
| `ch11/test_stream_item_order_struct_union_object_assoc` ほか1本 | 11.4.14.1 | ビットストリーム型でない構造体・共用体・クラスも、要素ごとに並べる規則がある。slang の「bit-stream type でない」は厳しすぎる |
| `ch11/test_concatenation_pattern_string_operand_and_replication` | 11.4.12.2 | string のオペランドがあれば、ほかは暗黙に string へ変換される |
| interconnect の3本 | 6.6.8、23.3.3.7.2 | interconnect は端子の接続と net_alias に使える |

config の12本は Lyra が config を、タイミングチェックの28本は Lyra がタイミングチェックを実装していないための不一致です。

<a id="list"></a>

## 一覧

<a id="output-inconsistency-65-tests"></a>

### 出力の不一致（65本）

| テスト | kirimasim | Lyra の結果 |
| --- | --- | --- |
| `ch11/test_conditional_real_shortreal_branch_promotion` | 不一致 |行1は'3.5 1.5 1.0 16777217.0 16777217.0'だが、期待値は'3.5 1.5 1.0 16777216.0 16777217.0'|
| `ch16/test_deferred_assertion_default_error` | 不一致 |次に一致するメッセージがない：'(?i) \\ A(?![ \\ s \\ S]* test_deferred_assertion_default_error \\ .sv: 34 :)(?=[ \\ s \\ S]*error[^ \\ n]*…|
| `ch18/test_disable_soft_direct_reference` | 未対応 |行1は'ok=1 x=2 y=7 size=3 n=3'だが、期待値は'ok=1 x=2 y=7 size=3 n=5'|
| `ch18/test_rand_mode_array_element` | 未対応 |行3は'modes after a.rand_mode(0)=001'だが、期待値は'modes after a.rand_mode(0)=000'|
| `ch18/test_soft_priority_layers` | 未対応 |行4は'container over held object: h1.v=3'だが、期待値は'container over held object: h1.v=7'|
| `ch19/test_cg_bins_value_resolution` | 未対応 |行2は'p1=7 p2=3: cp1 0.00, cp2 0.00'だが、期待値は'p1=7 p2=3: cp1 50.00, cp2 50.00'|
| `ch19/test_cg_coverpoint_type_resolution` | 未対応 |行1は'v=4: 50.00'だが、期待値は'v=4: 25.00'|
| `ch19/test_cg_derived_option_override` | 未対応 |2号線は'derived: at_least 1, auto_bin_max 4, cp 0/4'時 予定は'de時 at_least 1 , auto_bin_max 4号線は1/4時|
| `ch19/test_cg_warned_bin_elements_removed` | 未対応 |行1は'u=2: cs 2/6, ct 0/1'だが、期待値は'u=2: cs 0/2, ct 0/1'|
| `ch19/test_cg_zero_denominator_items` | 未対応 |行2は'cz: inst 100.00 (0/0), type 0.00'だが、期待値は'cz: inst 100.00 (0/0), type 100.00'|
| `ch19/test_option_member_defaults` | 未対応 |行17は'  real_interval 1.00'だが、期待値は'  real_interval 0.25'|
| `ch20/test_associative_array_query_functions` | 未対応 |診断の抜粋（原文）：line 1 is 'a4: left=0 right=15 low=2 high=9 increment=15 size=2' , expected ' a4 : left = 0 right = 15 low = 2 high = 9 i…|
| `ch23/test_empty_named_connection_ignores_default` | 未対応 |行1は"omitted: 0111, .q(): xxxx, .q(4'h3): 0011, ordered and em..."で、期待値は" omitted: 0111, .q(): zzzz,…です。|
| `ch25/test_interface_specify_terminal` | 未対応 |行1は't=12: o=1'だが、期待値は't=12: o=0'|
| `ch31/test_timing_check_conditions_timestamps_and_notifiers` | 未対応 |行1は't=16 setup=0 hold=0 z=z'だが、期待値は't=16 setup=1 hold=1 z=z'|
| `ch31/test_timing_condition_forms_x_lsb` | 未対応 |行1は'en:'だが、期待値は'en: 20'|
| `ch31/test_timing_conditioned_event` | 未対応 |行1は'end: notifier=0'だが、期待値は'30: notifier=1'|
| `ch31/test_timing_edge_control_specifier` | 未対応 |行1は'edge[01] notifier:'だが、期待値は'edge[01] notifier: 40:1'|
| `ch31/test_timing_edge_descriptors_all` | 未対応 |行1は'edge[01]:'だが、期待値は'edge[01]: 11'|
| `ch31/test_timing_fullskew_event_based` | 未対応 |行1は'timer-based:'だが、期待値は'timer-based: 15 48'|
| `ch31/test_timing_nochange` | 未対応 |行1は'd inside: offsets 0 and 0: 0, offsets 2 and -1: 0'で、期待値は' d inside: offsets 0 and 0: 1, offsets…です。|
| `ch31/test_timing_nochange_offset_directions` | 未対応 |診断の抜粋（原文）：line 1 is 'd at 25: (0,0) 0 (0,2) 0 (-2,0) 0 (2,0) 0 (0,-2) 0' , expected 'd at 25 : ( 0,0 ) 1 ( 0,2 ) 1 ( -2,0 ) 1 ( 2 …|
| `ch31/test_timing_nochange_window_endpoints` | 未対応 |行1は'end: n1=0 n2=0'だが、期待値は'15: n1=1'|
| `ch31/test_timing_notifier_x_and_z` | 未対応 |行2は'after the first violation: nx known:  no, nz=z'で、期待値は' after the first violation: nx known: yes…です。|
| `ch31/test_timing_recovery_removal_recrem` | 未対応 |行1は'$recovery:'だが、期待値は'$recovery: 12 90'|
| `ch31/test_timing_recrem_all_arguments` | 未対応 |行1は'42: rst_n=0 drst=z clk=1 dclk=z'だが、期待値は'42: rst_n=0 drst=0 clk=1 dclk=1'|
| `ch31/test_timing_recrem_windows` | 未対応 |行1が欠落している。期待値は'10: n=1'|
| `ch31/test_timing_setup_hold_notifier` | 未対応 |行1が欠落している。期待値は'20: setup notifier=1 hold notifier=0'|
| `ch31/test_timing_setuphold` | 未対応 |行1は'limits 3 and 2:'だが、期待値は'limits 3 and 2: 20 21 40'|
| `ch31/test_timing_setuphold_all_arguments` | 未対応 |行1は'30: clk=0 dclk=z d=1 dd=z'だが、期待値は'30: clk=0 dclk=0 d=1 dd=1'|
| `ch31/test_timing_setuphold_as_setup_and_hold` | 未対応 |行1は'$setuphold:'だが、期待値は'$setuphold: 20 30 41 60 61'|
| `ch31/test_timing_skew_checks` | 未対応 |行1は'$skew:'だが、期待値は'$skew: 27 34 50'|
| `ch31/test_timing_skew_dormant_and_restart` | 未対応 |行2は'$timeskew, no data event:'だが、期待値は'$timeskew, no data event: 15'|
| `ch31/test_timing_skew_simultaneous_and_expiry` | 未対応 |行1は'$skew limit 0:'だが、期待値は'$skew limit 0: 21'|
| `ch31/test_timing_stability_windows_and_endpoints` | 未対応 |行2は't=26 setup=0 hold=0 removal=0 recovery=0'だが、期待値は't=26 setup=1 hold=1 removal=1 recovery=1'|
| `ch31/test_timing_timeskew_flags` | 未対応 |行1は'timer-based:'だが、期待値は'timer-based: 25'|
| `ch31/test_timing_timeskew_remain_active` | 未対応 |行1は'without remain_active_flag:'だが、期待値は'without remain_active_flag: 50'|
| `ch31/test_timing_vector_hold` | 未対応 |行1は'notifier changes:'だが、期待値は'notifier changes: 11:1 13:0'|
| `ch31/test_timing_vector_signal` | 未対応 |行1は'notifier changes:'だが、期待値は'notifier changes: 105:1 115:0 125:1'|
| `ch31/test_timing_width_period_notifier` | 未対応 |行1が欠落している。期待値は'23: width notifier=1 period notifier=0'|
| `ch31/test_timing_width_threshold_limit_edges` | 未対応 |行1は'$width limit 5 threshold 2:'だが、期待値は'$width limit 5 threshold 2: 33 44'|
| `ch31/test_timing_window_endpoints_zero_limits` | 未対応 |行1は'$setup limit 3:'だが、期待値は'$setup limit 3: 30'|
| `ch33/test_config_binding_descends_through_children` | 不一致 |行2は'test_config_binding_descends_through_children.m2.u_leaf: ...'で、期待値は' test_config_binding_descen…です。|
| `ch33/test_config_cell_parameter` | 不一致 |行1は'u1=1 u2=1'だが、期待値は'u1=5 u2=5'|
| `ch33/test_config_defparam_precedence` | 合格 |行1は'm.P=5 m.c.Q=6'だが、期待値は'm.P=9 m.c.Q=6'|
| `ch33/test_config_design_top` | 合格 |行1は'cfg_stray elaborated'だが、期待値は'top: test_config_design_top'|
| `ch33/test_config_design_two_tops` | 合格 |行1は'cfg2_stray is a top-level module'だが、期待値は'test_config_design_two_tops is a top-level module'|
| `ch33/test_config_hierarchical` | 不一致 |行1は'm1 leaf: aa, m2 leaf: aa'だが、期待値は'm1 leaf: aa, m2 leaf: bb'|
| `ch33/test_config_instance_deep_path` | 合格 |行1は'm1.leaf=aa m2.leaf=aa leaf=aa'だが、期待値は'm1.leaf=aa m2.leaf=bb leaf=aa'|
| `ch33/test_config_instance_use` | 合格 |行1は'u1=aa u2=aa'だが、期待値は'u1=aa u2=bb'|
| `ch33/test_config_library_binding_format` | 合格 |行3は'test_config_library_binding_format.u2.show: work.cfg_lib_a'で、期待値は' test_config_library_binding_…です。|
| `ch33/test_config_parameter_override` | 合格 |行1は'WIDTH=16'だが、期待値は'WIDTH=32'|
| `ch33/test_config_use_config_suffix` | 不一致 |行1は'm1 leaf: aa, m2 leaf: aa'だが、期待値は'm1 leaf: aa, m2 leaf: bb'|
| `ch33/test_config_use_without_library` | 合格 |行1は'u1=aa u2=aa u3=cc'だが、期待値は'u1=aa u2=bb u3=dd'|
| `ch35/test_dpi_put_user_data_error_result` | 未対応 |行1は'svPutUserData with NULL user data: 0'だが、期待値は'svPutUserData with NULL user data: -1'|
| `ch4/test_reactive_region_set_order` | 不一致 |行3は'program: v changed to 1'だが、期待値は'module: v changed to 1'|
| `ch6/test_string_ato_integer_scan_rules` | 合格 |行9は'atoi("-12")=-12'だが、期待値は'atoi("-12")=0'|
| `ch6/test_string_atoreal_scan_rules` | 不一致 |行2は'atoreal("1_0.2_5")=1.000'だが、期待値は'atoreal("1_0.2_5")=10.250'|
| `ch6/test_string_conversion` | 合格 |行1が欠落している。期待値は'PASS: String conversion methods'|
| `ch6/test_string_edge` | 合格 |行1は"FAIL: atoi('-999') should be 0, got -999"だが、期待値は'PASS: String edge cases'|
| `ch6/test_string_functions_comprehensive` | 合格 |行36は'  FAIL: "-456".atoi() = -456 (expected 0)'だが、期待値は'  PASS: "-456".atoi() = 0'|
| `ch6/test_string_ops_edge_cases` | 合格 |行16は'Test 16 FAIL: atoi of "-100" = -100 (expected 0)'だが、期待値は'Test 16 PASS: atoi of "-100" = 0'|
| `ch7/test_assoc_array_unknown_index` | 未対応 |行1は"aa[3'bzzz] = a8"だが、期待値は"aa[3'bzzz] = xx"|
| `ch7/test_assoc_invalid_write_reports_diagnostic` | 未対応 |'(?i:\\bwarn(?:ing)?\\b\|%Warning-)' にマッチするメッセージはありません|
| `ch7/test_assoc_missing_read_reports_diagnostic` | 未対応 |'(?i:\\bwarn(?:ing)?\\b\|%Warning-)' にマッチするメッセージはありません|

<a id="rejects-standard-compliant-code-28-tests"></a>

### 規格上正しいコードを拒否（28本）

| テスト | kirimasim | Lyra の結果 |
| --- | --- | --- |
| `ch11/test_concatenation_pattern_string_operand_and_replication_once` | 不一致 |連結に文字列と整数を混在させることはできない（必要ならキャストを使用する）[-Wstring-int-concat]|
| `ch11/test_stream_item_order_struct_union_object_assoc` | 不一致 |ストリーム式の型'su_t'はbitストリーム型ではない|
| `ch11/test_stream_unpack_consumes_left_converts_state_keeps_objects` | 不一致 |ストリーム式の型'pk_c'はbitストリーム型ではない|
| `ch16/test_cover_property_restrict` | 未対応 |宣言名を期待していた|
| `ch16/test_named_sequence_scopes_and_instances` | 不一致 |';'が必要|
| `ch16/test_nexttime_always_eventually_alignment` | 不一致 |アサーション式の先頭クロックが一意に定まらない|
| `ch16/test_triggered_matched_multiclock` | 不一致 |複数クロックのシーケンスオペランドは、##1と##0以外のシーケンス演算子では組み合わせられない|
| `ch16/test_untyped_formal_arguments` | 未対応 |アサーション項目構文のポート宣言が必要|
| `ch17/test_checker_context_inference` | 未対応 |この文脈には推論クロックがない|
| `ch17/test_checker_package_context` | 未対応 |この文脈には推論クロックがない|
| `ch19/test_cg_inheritance_args_and_cross` | 不一致 |'vf' の再定義 [-Wredefinition]|
| `ch21/test_evcd_dumpports_files_defaults_and_control_scope` | 不一致 |'logic[472:1]'から 'string'への暗黙の変換はありません;明示的な型変換は存在する。キャストを忘れていないか？|
| `ch21/test_evcd_dumpportslimit_named_by_variables` | 不一致 |'logic[400:1]'から 'string'への暗黙の変換はありません;明示的な型変換は存在する。キャストを忘れていないか？|
| `ch23/test_interconnect_primitive_broadcast_input` | 不一致 |netポート接続の外でinterconnect net 'connection'を参照できない|
| `ch23/test_interconnect_primitive_terminal` | 不一致 |netポート接続の外でinterconnect net 't'を参照できない|
| `ch25/test_interface_abstract_methods_and_broadcast` | 不一致 |modport 'am_bus.caller'を介して'value'にアクセスできない|
| `ch32/test_sdf_mtm_spec` | 未対応 |空の引数は許可されていません|
| `ch32/test_sdf_scale_factors` | 未対応 |空の引数は許可されていません|
| `ch32/test_sdf_scale_type_members` | 未対応 |空の引数は許可されていません|
| `ch35/test_dpi_canonical_partsel_get_keeps_bits` | 未対応 |プログラムのリンクが失敗しました|
| `ch35/test_dpi_dynamic_array_actual` | 未対応 |'int$[$]'型の値を'int$[]'型に代入できない|
| `ch6/test_interconnect_net_alias` | 未対応 |netポート接続の外でinterconnect net 'src'を参照できない|
| `ch6/test_nettype_alias_resolution_and_empty_drivers` | 不一致 |ポートのユーザー定義nettype 'voltage'は、接続先の'alias_two'と一致しない|
| `ch6/test_nettype_rename_matches` | 不一致 |ポートのユーザー定義nettype 'volt_net'は、接続先の'volt_alias'と一致しない|
| `ch6/test_nettype_resolution` | 不一致 |ユーザ定義のネットタイプのネットにフォースとリリースは適用できません|
| `ch6/test_user_nettype_resolution_forms` | 不一致 |net 'arr' はユーザ定義の nettype で部分的にドライブできません|
| `ch7/test_assoc_narrow_prev_next_overflow` | 不一致 |'bit[7:0]'型の引数を、等価でない型'int'の'ref'ポートに接続している|
| `ch7/test_assoc_traversal_narrow_index` | 不一致 |'bit[7:0]'型の引数を、等価でない型'int'の'ref'ポートに接続している|

<a id="accepts-standard-violating-code-86-tests-priority-review-targets"></a>

### 規格違反のコードを受理（86本、優先して見直す対象）

| テスト | kirimasim | Lyra の結果 |
| --- | --- | --- |
| `ch10/test_illegal_force_mixed_driven_variable` | 不一致 |設計は受理されたが、規格違反である|
| `ch10/test_illegal_lhs_assignment_pattern_member_width` | 未対応 |設計は受理されたが、規格違反である|
| `ch10/test_illegal_typed_lhs_assignment_pattern_member_width` | 未対応 |設計は受理されたが、規格違反である|
| `ch10/test_illegal_user_nettype_assignment_two_delays` | 未対応 |設計は受理されたが、規格違反である|
| `ch11/test_illegal_stream_with_on_two_dimensional_array` | 未対応 |設計は受理されたが、規格違反である|
| `ch12/test_illegal_for_type_reference_without_var` | 不一致 |設計は受理されたが、規格違反である|
| `ch12/test_illegal_pattern_constant_of_real_type` | 未対応 |設計は受理されたが、規格違反である|
| `ch13/test_illegal_constant_function_call_in_constant_context` | 不一致 |設計は受理されたが、規格違反である|
| `ch14/test_illegal_clocking_output_variable_force` | 未対応 |設計は受理されたが、規格違反である|
| `ch14/test_illegal_clocking_output_variable_procedural_assign` | 未対応 |設計は受理されたが、規格違反である|
| `ch15/test_illegal_mailbox_peek_unpacked_array` | 未対応 |設計は受理されたが、規格違反である|
| `ch15/test_illegal_mailbox_put_unpacked_array` | 未対応 |設計は受理されたが、規格違反である|
| `ch15/test_illegal_mailbox_try_get_unpacked_array` | 未対応 |設計は受理されたが、規格違反である|
| `ch15/test_illegal_mailbox_try_peek_unpacked_array` | 未対応 |設計は受理されたが、規格違反である|
| `ch15/test_illegal_mailbox_try_put_unpacked_array` | 未対応 |設計は受理されたが、規格違反である|
| `ch16/test_illegal_assertion_clocking_input_not_1step` | 未対応 |設計は受理されたが、規格違反である|
| `ch16/test_illegal_assertion_function_keeps_state` | 未対応 |設計は受理されたが、規格違反である|
| `ch16/test_illegal_assertion_function_side_effect` | 未対応 |設計は受理されたが、規格違反である|
| `ch16/test_illegal_attached_call_chandle_input` | 未対応 |設計は受理されたが、規格違反である|
| `ch16/test_illegal_cycle_delay_mintypmax` | 未対応 |設計は受理されたが、規格違反である|
| `ch16/test_illegal_deferred_assertion_const_ref_dynamic_actual` | 不一致 |設計は受理されたが、規格違反である|
| `ch16/test_illegal_local_variable_implicit_type` | 未対応 |設計は受理されたが、規格違反である|
| `ch16/test_illegal_local_variable_unassigned_compound_assignment` | 未対応 |設計は受理されたが、規格違反である|
| `ch16/test_illegal_nonoverlapping_antecedent_no_match` | 未対応 |設計は受理されたが、規格違反である|
| `ch16/test_illegal_sequence_event_formal_as_boolean` | 未対応 |設計は受理されたが、規格違反である|
| `ch16/test_illegal_sequence_formal_chandle_type` | 未対応 |設計は受理されたが、規格違反である|
| `ch16/test_illegal_sequence_formal_goto_operand` | 未対応 |設計は受理されたが、規格違反である|
| `ch16/test_illegal_triggered_ending_clock_differs` | 未対応 |設計は受理されたが、規格違反である|
| `ch17/test_illegal_checker_covergroup_constant_actual` | 未対応 |設計は受理されたが、規格違反である|
| `ch22/test_illegal_begin_keywords_without_end` | 不一致 |設計は受理されたが、規格違反である|
| `ch22/test_illegal_include_absolute_path_in_angle_brackets` | 不一致 |設計は受理されたが、規格違反である|
| `ch22/test_illegal_line_directive_trailing_comment` | 不一致 |設計は受理されたが、規格違反である|
| `ch23/test_illegal_interconnect_left_after_elaboration` | 未対応 |設計は受理されたが、規格違反である|
| `ch24/test_illegal_anonymous_program_hierarchical_reference` | 不一致 |設計は受理されたが、規格違反である|
| `ch25/test_illegal_generic_interface_port_dot_name` | 不一致 |設計は受理されたが、規格違反である|
| `ch25/test_illegal_interface_port_actual_through_generate_block` | 不一致 |設計は受理されたが、規格違反である|
| `ch25/test_illegal_interface_port_actual_through_instance_array` | 不一致 |設計は受理されたが、規格違反である|
| `ch25/test_illegal_modport_import_default_argument_without_prototype` | 不一致 |設計は受理されたが、規格違反である|
| `ch25/test_illegal_modport_import_from_module_without_prototype` | 未対応 |設計は受理されたが、規格違反である|
| `ch25/test_illegal_modport_import_named_binding_without_prototype` | 不一致 |設計は受理されたが、規格違反である|
| `ch25/test_illegal_modport_prototype_unnamed_named_binding` | 不一致 |設計は受理されたが、規格違反である|
| `ch3/test_illegal_unit_prefix_forward_reference` | 不一致 |設計は受理されたが、規格違反である|
| `ch30/test_illegal_edge_parallel_path_part_select_destination` | 未対応 |設計は受理されたが、規格違反である|
| `ch30/test_illegal_edge_parallel_path_vector_destination` | 未対応 |設計は受理されたが、規格違反である|
| `ch30/test_illegal_pulsestyle_ondetect_after_path` | 未対応 |設計は受理されたが、規格違反である|
| `ch30/test_illegal_pulsestyle_onevent_after_path` | 未対応 |設計は受理されたが、規格違反である|
| `ch30/test_illegal_showcancelled_after_path` | 未対応 |設計は受理されたが、規格違反である|
| `ch30/test_illegal_specify_edge_path_part_and_bit_select` | 未対応 |設計は受理されたが、規格違反である|
| `ch30/test_illegal_specify_edge_path_same_edge_and_condition` | 未対応 |設計は受理されたが、規格違反である|
| `ch30/test_illegal_specify_ifnone_with_unconditional_path` | 未対応 |設計は受理されたが、規格違反である|
| `ch31/test_illegal_hold_limit_negative` | 未対応 |設計は受理されたが、規格違反である|
| `ch31/test_illegal_recovery_limit_negative` | 未対応 |設計は受理されたが、規格違反である|
| `ch31/test_illegal_removal_limit_negative` | 未対応 |設計は受理されたが、規格違反である|
| `ch31/test_illegal_setup_limit_negative` | 未対応 |設計は受理されたが、規格違反である|
| `ch31/test_illegal_timing_condition_two_signals` | 未対応 |設計は受理されたが、規格違反である|
| `ch33/test_illegal_config_constant_function` | 不一致 |設計は受理されたが、規格違反である|
| `ch33/test_illegal_config_design_is_config` | 不一致 |設計は受理されたが、規格違反である|
| `ch33/test_illegal_config_generate_scope_path` | 不一致 |設計は受理されたが、規格違反である|
| `ch33/test_illegal_config_hierarchical_name_in_expression` | 不一致 |設計は受理されたが、規格違反である|
| `ch33/test_illegal_config_index_not_literal` | 不一致 |設計は受理されたが、規格違反である|
| `ch33/test_illegal_config_instance_array_path` | 不一致 |設計は受理されたが、規格違反である|
| `ch33/test_illegal_config_instance_inside_other_config` | 不一致 |設計は受理されたが、規格違反である|
| `ch33/test_illegal_config_package_binding` | 不一致 |設計は受理されたが、規格違反である|
| `ch5/test_illegal_method_implicit_variable_without_parentheses` | 不一致 |設計は受理されたが、規格違反である|
| `ch5/test_illegal_string_hex_escape_z_digit` | 不一致 |設計は受理されたが、規格違反である|
| `ch5/test_illegal_string_octal_escape_z_digit` | 不一致 |設計は受理されたが、規格違反である|
| `ch6/test_illegal_chandle_event_control` | 未対応 |設計は受理されたが、規格違反である|
| `ch6/test_illegal_initial_block_variable_initializer_no_keyword` | 不一致 |設計は受理されたが、規格違反である|
| `ch6/test_illegal_net_type_reg_in_port_declaration` | 不一致 |設計は受理されたが、規格違反である|
| `ch6/test_illegal_nettype_resolver_resizes_driver_array` | 未対応 |設計は受理されたが、規格違反である|
| `ch6/test_illegal_nettype_resolver_side_effect` | 未対応 |設計は受理されたが、規格違反である|
| `ch6/test_illegal_nettype_resolver_writes_driver_array` | 未対応 |設計は受理されたが、規格違反である|
| `ch6/test_illegal_static_task_variable_initializer_no_keyword` | 不一致 |設計は受理されたが、規格違反である|
| `ch6/test_illegal_type_operator_dynamic_array_element` | 不一致 |設計は受理されたが、規格違反である|
| `ch6/test_illegal_type_parameter_scope_prefix_in_variable` | 未対応 |設計は受理されたが、規格違反である|
| `ch7/test_illegal_dynamic_array_to_dpi_open_output` | 未対応 |設計は受理されたが、規格違反である|
| `ch7/test_illegal_integral_index_with_real` | 未対応 |設計は受理されたが、規格違反である|
| `ch7/test_illegal_integral_index_with_shortreal` | 未対応 |設計は受理されたが、規格違反である|
| `ch7/test_illegal_string_in_untagged_union` | 未対応 |設計は受理されたが、規格違反である|
| `ch7/test_illegal_union_holding_struct_member_default` | 不一致 |設計は受理されたが、規格違反である|
| `ch7/test_illegal_unique_index_without_with_struct_elements` | 未対応 |設計は受理されたが、規格違反である|
| `ch7/test_illegal_unique_without_with_struct_elements` | 未対応 |設計は受理されたが、規格違反である|
| `ch7/test_illegal_wildcard_array_find` | 未対応 |設計は受理されたが、規格違反である|
| `ch8/test_illegal_interface_method_default_not_constant` | 未対応 |設計は受理されたが、規格違反である|
| `ch8/test_illegal_interface_typedef_scope_prefix_in_variable_declaration` | 未対応 |設計は受理されたが、規格違反である|
| `ch8/test_illegal_type_parameter_scope_prefix_in_variable_declaration` | 未対応 |設計は受理されたが、規格違反である|

<a id="internal-errorscrashes-10-tests"></a>

### 内部エラー・クラッシュ（10本）

| テスト | kirimasim | Lyra の結果 |
| --- | --- | --- |
| `ch11/test_equality_class_interface_chandle_handles` | 未対応 |エラー：内部エラー：FoldIntegral：整数型の値がないにもかかわらず整数型演算wildcard_equalが構築されている…|
| `ch16/test_recursive_properties` | 未対応 |エラー：内部エラー：LowerPropertyExpr：フロントエンドが、h…ではなく不正なアサーション式を報告する|
| `ch18/test_unique_array_slice_single` | 未対応 |エラー: 内部エラー: アクセスパス: 要素とコンポーネントのみが参照で渡せます (LRM 13.5.2 ) 、 a...|
| `ch19/test_cg_cross_with_expression` | 未対応 |エラー：内部エラー：ProcessLowerer::DeclareProceduralVar：手続き変数のシンボルが既に対応付けられている（単位…|
| `ch19/test_cg_option_levels_readback` | 未対応 |エラー：内部エラー：mir verify：単位'test_cg_option_levels_readback'のクラス'cg'の'__declare_type'、as…|
| `ch29/test_udp_instance_array_delays` | 合格 |クラッシュ（シグナル11）|
| `ch29/test_udp_instance_strength_and_array_range` | 未対応 |クラッシュ（シグナル11）|
| `ch3/test_name_spaces` | 合格 |エラー: 内部エラー: hir::DesignElementOf: インスタンス化されるユニットは設計要素です（ユニット' test_na…）。|
| `ch35/test_dpi_context_scope_of_declaration` | 未対応 |エラー: 内部エラー: AST- \> HIR コール: この DPI インポートを宣言するスコープは現在のスコープスタックにありません (i...|
| `ch8/test_super_new_default` | 未対応 |クラッシュ（シグナル11）|

<a id="illegal-code-rejected-at-a-different-location-5-tests"></a>

### 規格違反のコードを別の場所で拒否（5本）

| テスト | kirimasim | Lyra の結果 |
| --- | --- | --- |
| `ch16/test_illegal_property_instance_flattened_not_legal` | 不一致 |'test_illegal_property_instance_flattened_not_legal\\.sv:30:' にマッチするエラーはありません;1つ目は../..27:5: エラー...|
| `ch16/test_illegal_recursive_property_negated` | 不一致 |'test_illegal_recursive_property_negated\\.sv:32:' にマッチするエラーはありません;1つ目は../..29:33：エラー：recursiv…|
| `ch16/test_illegal_sequence_local_output_unassigned` | 不一致 |'test_illegal_sequence_local_output_unassigned\\.sv:(29\|34):' にマッチするエラーはありません;1つ目は../..28:37 : エラー...|
| `ch25/test_illegal_modport_prototype_argument_count` | 不一致 |'test_illegal_modport_prototype_argument_count\\.sv:30:' にマッチするエラーはありません;1つ目は../..26:16：エラー：de…|
| `ch25/test_illegal_modport_prototype_type_not_matching` | 不一致 |'test_illegal_modport_prototype_type_not_matching\\.sv:31:' にマッチするエラーはありません;1つ目は../..27:32: エラー:...|
