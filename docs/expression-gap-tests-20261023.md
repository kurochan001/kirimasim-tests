# 式のレビューで不足していた観測へのテスト追加（2026-10-23）

> この文書の件数・割合・保留状態は、各作業時点の記録です。
> 現在の値は[生成した集計概要](behavior-coverage-summary.md)、分母と解釈の承認経緯は
> [要求抽出の結果](requirement-extraction.md)を参照してください。

[元のレビューとM18–M22](existing-test-matching-expressions-20261023.md) / [現在のカバレッジ](behavior-coverage-summary.md)

この文書は11本の追加直後の762本・672要求行の時点の記録です。
その後の[制御文・ループの照合結果](existing-test-matching-control-flow-20261023.md)を参照してください。

## 追加した内容

レビューで判別力が不足していた箇所へ、11本のテストと規格から決めた期待出力を追加しました。
既存テストの刺激・期待値は変更していません。

- M18：優先順位と結合順を取り違えると値が変わる入力。
  [test_precedence_distinguishing_values.sv](../tests/ch11/test_precedence_distinguishing_values.sv) は、
  論理、unaryと加算、比較とbitwise、加減乗除剰余、条件、implication/equivalenceを
  異なる括弧付きの式と比較します。例えば`1 || 0 && 0`は1、`(1 || 0) && 0`は0です。
- M19：代入後の値に隠れない、式自身の幅。
  [test_self_determined_operator_widths.sv](../tests/ch11/test_self_determined_operator_widths.sv) は、
  二項10演算と単項3演算を$bitsで確認し、連結内の加算と64bit文脈の加算を区別します。
  [test_logical_reduction_expression_widths.sv](../tests/ch11/test_logical_reduction_expression_widths.sv) は、
  1bit結果へoperandまで誤って縮めると真偽が変わる入力を使います。
- M19：シフト・べき乗・連結・条件・比較の幅の例外。
  [test_shift_power_self_determined_count.sv](../tests/ch11/test_shift_power_self_determined_count.sv) は、
  4bitの左辺operandと64bitの右辺operand、signedの負指数／シフト量を区別します。
  [test_concat_replication_conditional_widths.sv](../tests/ch11/test_concat_replication_conditional_widths.sv) は、
  連結と反復の幅、self-determinedな項目、条件の幅と枝の幅、signed元値からのunsignedな選択結果を検査します。
  [test_comparison_operand_context_width.sv](../tests/ch11/test_comparison_operand_context_width.sv) は、
  比較の共通幅と1bit結果、および外側64bit代入文脈を比較operandへ伝えない規則を区別します。
- M20：$signed/$unsignedの返却値そのものの形と符号。
  [test_signed_system_cast_shape_and_value.sv](../tests/ch11/test_signed_system_cast_shape_and_value.sv) は、
  8bit／65bitの幅、単一packed次元と範囲、ビット列、符号、拡張をそれぞれ観測します。
- M21：実際のサイズ指定castによる中間文脈。
  [test_size_cast_intermediate_context.sv](../tests/ch6/test_size_cast_intermediate_context.sv) は、
  同じ8bit同士の和が16bit文脈では0100、8bitの中間castでは0000となることを確認します。
  縮小、拡大、signedness維持、packed範囲の検査も含みます。
- M22：shortrealの昇格と、条件operandの例外。
  [test_shortreal_result_and_condition_types.sv](../tests/ch11/test_shortreal_result_and_condition_types.sv) は、
  shortrealの32bitとrealの64bitを区別します。
  shortrealを条件だけに使う場合は4bitの枝を用い、誤って32bit shortrealへ昇格すると検出できます。
- M22：短絡による副作用と実行時エラーの抑止。
  [test_short_circuit_suppresses_fatal_operand.sv](../tests/ch11/test_short_circuit_suppresses_fatal_operand.sv) は、
  評価するとカウンタを増やし$fatalを実行する関数を、&&、||、->と条件演算の非選択枝へ置きます。
  最後まで継続して呼び出し回数0を出力することが期待結果です。
- M22：shortrealの対応状況から独立したrealの1bit結果。
  [test_real_boolean_results_without_shortreal.sv](../tests/ch11/test_real_boolean_results_without_shortreal.sv) は、
  realの論理・関係・insideの式幅と値を検査します。

これはM18–M22の不足した観測を補う追加であり、規格全機能のテスト追加完了を意味しません。
優先順位表の全operator・全組み合わせや、残る複合要求のすべてを網羅したという扱いにはしていません。

## 規格との対応と割合

34件の対応根拠を追加しました。要求定義12,319行と分母の識別子は変更していません。

- 全テスト：3,912本から3,923本。
- 一つ以上の要求との対応登録済み：751本から762本。未登録は3,161本です。
- 対応済み要求：643行から672行（29行追加）。
- 実行確認済み要求：577行から606行（29行追加）。
- 暫定の要求カバレッジ（テスト設計）：5.22%から**5.45%（672/12,319）**。
- 暫定実行確認率：4.68%から**4.92%（606/12,319）**。
- 確定値：設計・実行とも未確定。分母承認・重複整理・解釈保留は残件です。

新規対応29行のうち28行にパス結果の記録があり、shortrealの1行は設計対応のみです。
以前は設計対応だけだったrealの1bit結果の1行も、新しく分離したテストで実行確認できたため、
実行確認済みの増分は合計29行となります。
対応登録済み本数は、各ファイルの全観測・全要求をレビュー済みという意味ではありません。
規格との照合はAIによるもので、独立した人による確認済みではありません。

## 実行結果とシミュレータ差

更新後の11本を、固定バージョンIcarus 13.0とVerilator 5.052で実行しました。
Verilatorは初期値のseed 1と73の両方で確認しています。

- Icarus 13.0：6本成功、5本既知不一致・コンパイル不可。
- Verilator 5.052：両seedとも10本成功、1本既知不一致。
- 少なくとも一方の成功：10本。shortrealの1本は両方に差があり、規格由来の期待値を保持しています。

Icarusはcast式への配列queryでコンパイラが停止し、短絡テストでは非選択関数の$fatalを実行します。
query部分を外した一時的な対照例がコンパイルできることも確認しました。
shortrealの式幅はIcarusが1bit、Verilatorが64bitとするため、どちらもoracleへ登録していません。
これらの差は[シミュレータ差の記録](simulator-differences.md#cases-added-after-the-2026-10-23-expression-review)へ追記しました。

実行時の入力SHA-256とランナーハッシュ、版・seedを含む結果は次に保存しています。

- [expression-gaps-20261023-icarus13.json](../coverage/results/expression-gaps-20261023-icarus13.json)
- [expression-gaps-20261023-verilator-seed1.json](../coverage/results/expression-gaps-20261023-verilator-seed1.json)
- [expression-gaps-20261023-verilator-seed73.json](../coverage/results/expression-gaps-20261023-verilator-seed73.json)

以前の全3,912本の実行結果へ部分実行を合成・上書きしていません。
成功は現在の入力に一致する実測passだけを採用し、knownやコンパイル失敗を成功に換算していません。

## 判別力と管理ファイルの検査

一時ファイルで19種類の誤った振る舞いを注入し、変更後のコードがコンパイルできたうえで、
元の期待結果との比較がすべて失敗することを確認しました。

- 優先順位・結合順の取り違え：9種類。
- self-determinedな境界の除去、論理operandの縮小、シフト量の縮小、シフト結果の誤った符号化、
  連結項目への文脈漏れ、条件の縮小、比較内部への外側文脈漏れ：7種類。
- system castの幅の拡大、size castの中間幅の拡大、短絡枝の強制評価：3種類。

前の16種類はIcarus 13.0、後の3種類はVerilator 5.052で確認しました。
一時的な変種は通常のテストへ追加せず、元テストや期待出力も変更していません。
これは代表的な誤りに対する判別力の確認であり、全誤実装の検出を保証するものではありません。

管理ツールの74テスト、規格資料ハッシュ、入力・対応根拠・実行証跡の整合性、
カタログ・統計・depth・生成物・メタデータの整合性を検査しました。
既存の要求定義、対応根拠、集合証拠、保留判断と、前回までの未コミット変更は保持しています。
