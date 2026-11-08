<a id="review-of-spec-only-tests-2026-11-09"></a>

# 「規格のみ」のテストの見直し（2026-11-09）

[English](spec-only-review-20261109.en.md) / [日本語](spec-only-review-20261109.md)

[期待値のレビュー候補](review-candidates.md) / [シミュレータと規格の差異](simulator-differences.ja.md) / [Lyraと一致しないテストの見直し](lyra-disagreement-review-20261025.md)

外部レビューの依頼を受けて、[レビュー候補](review-candidates.md)の最初の2種類を規格の本文と照らしました。

- specのみで、Ghost・kirimasim・Lyraのすべてでfailの30本
- specのみで、kirimasimだけがpassの21本

候補は、2026-11-08の手動Nightly（[実行42477954992](https://github.com/kurochan001/kirimasim-tests/actions/runs/42477954992)、スイートのコミット`36ba5dd1`）の最初の記録（resultsブランチ`32fb7b7f`）から求めました。
このときのLyraの結果は2026-11-06の`3ee7454c`のものです。
見直しはAI（Claude）が行いました。人による独立した照合ではないので、`:spec_check: ai`は変えていません。
kirimasimとLyraはフロントエンドにslangを共有しているので、構文解析や展開についての両者の一致は独立した裏付けになりません。

<a id="summary"></a>

## まとめ

| 分類 | 本数 | 見直しの結果 |
| --- | ---: | --- |
| specのみで、Ghost・kirimasim・Lyraのすべてでfail | 30 | 期待値の誤り4本、規格が食い違う箇所を含むもの2本を直しました。ほかの24本は期待値が正しく、シミュレータ側の未実装や誤りです |
| specのみで、kirimasimだけがpass | 21 | 21本とも期待値が正しいと確かめました。このうち6本は、Lyraの`ed6c62dc`でもpassします |

<a id="fixed-tests"></a>

## 直したテスト

| テスト | 根拠 | 誤りと直し方 |
| --- | --- | --- |
| `ch10/test_syntax_assignment_pattern_forms` | 10.9、6.21 | 代入パターンには自身の型がなく、もう一方の辺に型があるときだけ代入の一辺になれます。左辺のパターンに型のないパターンを代入する2か所は規格違反でした。右辺を型付きのパターン`nib2_t'{...}`にしました。`initial`ブロックで初期値付きで宣言する`tr`には`static`を付けました。期待出力は変わりません |
| `ch16/test_deferred_flush_points` | 9.2.2.2.1、9.2.2.3、16.4.2 | always_latchの暗黙の感度は、ブロック自身が書く`lq`を含みません。そのため`lq`の更新ではブロックが再開せず、t=15の失敗はflushされません。ブロックが`lq`の連続代入の写し`lqc`を読むようにし、再開によるflushを確かめる形にしました。期待出力は変わりません |
| `ch16/test_syntax_deferred_immediate_assertions` | 16.4 | 遅延アサーションの式と、動作に値渡しする引数は、文に達したときに評価されます。遅れるのは報告と動作だけです。テストは逆の読み方をしていました。各検査が到達時に真で、直後の代入で偽になる形に書き直し、到達時の値を表示するようにしました |
| `ch23/test_syntax_port_expression_and_explicit_ports` | 10.3.2、6.5、23.3.3、21.2.1.3 | 入力ポートが連続代入で駆動する変数`w`に宣言時の初期値があり、規格違反でした。初期値を外しました。また、8ビットの`hi`と`lo`を`%h`で表示すると2桁になるので、期待出力を`hi=0a lo=05`に直しました |
| `ch20/test_array_query_types_and_invalid` | 20.7、6.16 | 規格が食い違う箇所です。20.7はstring型の`$dimensions`を1とする一方で、動的な大きさの型の識別子に直接使うことをエラーとし、6.16は文字列を動的と呼びます。文字列変数に対する問い合わせに変え、[差異](simulator-differences.ja.md#dimensions-of-string-type)に記録しました |
| `ch33/test_config_declaration_grammar_forms` | 33.4.1（Syntax 33-4）、A.1.5、33.4.3 | 規格が食い違う箇所です。use節のパラメータ指定は、構文規則では`#`なし、33.4.3の例では`#(...)`です。use節でのパラメータ指定をやめて既定値を期待するようにし、[差異](simulator-differences.ja.md#config-use-parameter-form)に記録しました |

直したテストのうち3本は、kirimasim `33cee3fa`で期待どおりになりました（`ch16`の2本と`ch33`）。
`ch10`と`ch23`は、それぞれ代入パターンの左辺とrefポートが未実装でunsupportedになります。
`ch20`は、範囲外の定数の次元に`'x`を返す規則（20.7）をslangがエラーにするので、引き続きfailします。
台帳では、これらのテストを根拠にする28件の対応で、引用の文字列・観測・入力のハッシュを付け直しました。

<a id="rules-checked-against-the-standard"></a>

## 規格で確かめた規則

次のテストは期待値が規格どおりだと確かめました。

| テスト | 根拠 | 判断 |
| --- | --- | --- |
| `ch10/test_illegal_force_mixed_driven_variable` | 10.6.2、6.5 | 連続代入と手続き代入が混ざる変数へのforceは規格違反 |
| `ch11/test_stream_unpack_consumes_left_converts_state_keeps_objects` | 11.4.14.1、11.4.14.3 | クラスハンドルのストリーミングとnullの扱いは規格にある。kirimasimとLyraの「bit-stream型でない」は未対応 |
| `ch13/test_illegal_constant_function_call_in_constant_context` | 13.4.3 | 定数式を要する文脈で定数関数を呼ぶ関数は定数関数でない |
| `ch16/test_illegal_final_deferred_postponed_call` | 16.4、4.4.2.9 | finalの動作はPostponed領域で呼べるサブルーチンに限られ、変数を書くタスクは呼べない |
| `ch20/test_illegal_bits_function_dynamic_return` | 20.6.2 | 動的な大きさの型を返す関数を`$bits`で囲むのはエラー |
| `ch20/test_illegal_isunbounded_variable` | 20.6.3 | 引数はパラメータ名でなければならない |
| `ch20/test_illegal_timeformat_unit_out_of_range` | 20.4.3、表20-2 | 単位と精度は2から-15まで |
| `ch22/test_illegal_begin_keywords_without_end` | 22.14 | `` `begin_keywords ``と`` `end_keywords ``は対で使う |
| `ch22/test_illegal_line_directive_trailing_comment` | 22.12 | `` `line ``の行にはコメントを置けない |
| `ch23/test_23_extra_uwire_dominates`ほかuwireの4本 | 23.3.3.7（表23-1）、23.3.3.6、6.6.2 | uwireを禁じるのは双方向のパススイッチの端子だけで、inoutポートは禁じていない。値は表23-1に従う |
| `ch23/test_port_collapse_supply_cells`、`ch23/test_port_collapse_value_external_cells` | 23.3.3.7（表23-1の凡例） | 外側の型を使い、警告を出す |
| `ch25/test_illegal_modport_import_*`の3本 | 25.7、13.5.4 | 既定値や名前による引数の結合を使うときは、modportに完全なプロトタイプが要る |
| `ch5`の2本と`ch6`の3本（括弧・エスケープ・chandle・静的変数） | 5.13、13.4.1、5.9.1、6.14、6.21 | 括弧なしの組込みメソッドに続く選択、8進エスケープの後のz、chandleのイベント制御、キーワードなしの初期値付き静的変数は、いずれも規格違反 |
| `ch6/test_user_nettype_resolution_forms` | 6.6.7、6.7.2、6.7.3、10.3.2 | nettypeの配列の要素は一つのネットで、全体を駆動できる。別名のnettypeは解決関数を引き継ぐ |
| `ch6/test_illegal_type_parameter_scope_prefix_in_variable`、`ch8/test_illegal_type_parameter_scope_prefix_in_variable_declaration` | 6.20.3、8.23 | 型パラメータを前置した型の選択で変数を宣言するのは規格違反 |
| `ch7/test_illegal_union_holding_struct_member_default` | 7.2.2 | 共用体を含む非パック構造体のメンバーに既定値は付けられない |
| `ch8/test_illegal_interface_method_default_not_constant` | 8.26.8 | インタフェースクラスのメソッドの既定値は定数式 |
| `gen/ch10/test_gen_cross_force_pca_const_source_blocking_monitor_hier` | 10.6.1、10.6.2 | releaseで手続き的連続代入が戻る |
| `gen/ch28/test_gen_cross_gatearray_*`の9本 | 28.3.6、28.4〜28.7、28.16（表28-9） | ゲートの配列への接続の分け方、真理値表、遅延の選び方が生成器と一致する |
| `gen/ch13/test_gen_cross_litarg_fillx_bit8_default_plain` | 13.5.3、6.11 | 既定値`'x`はbitの引数で0になる |
| `gen/ch3/test_gen_cross_timescope_nested_interface_*`の2本 | 3.14、20.3、20.4.3 | 入れ子のinterfaceは外側の時間単位を受け継ぐ |
| `gen/ch4/test_gen_cross_sense_*_unread_*`の3本 | 9.2.2.2.1、9.2.2.3、11.5.3 | 暗黙の感度は読む最長静的接頭辞で、構造体の別のメンバーへの書き込みでは起きない |

<a id="points-left-as-they-are"></a>

## 変えずに残した注意点

次の点は、規格の読み方に幅がありますが、いまどのシミュレータとも食い違っていないので、テストは変えていません。

- `ch8/test_illegal_type_parameter_scope_prefix_in_variable_declaration`の35行目`holder_c #(T::nib_t)`：8.23の「型パラメータの代入」が特殊化の`#(...)`を含むかは、構文規則からははっきりしません。
- `ch25/test_illegal_modport_prototype_unnamed_named_binding`：規則はプロトタイプについて書かれているので、呼出しではなくmodportの行で報告する実装もありえます。
- `ch16/test_illegal_final_deferred_postponed_call`：kirimasimは実行時に検出します。`initial`ブロックと`always @(a)`の時刻0の順序によっては、実行時の検査に届かない実装もありえます。
- uwireとsupplyのポートの5本：23.3.3.7はネットの統合を「してよい」とするので、値は統合する実装について定まります。
- `ch22/test_illegal_begin_keywords_without_end`：22.14は対で使うことを求めますが、「エラーとする」とは書いていません。
