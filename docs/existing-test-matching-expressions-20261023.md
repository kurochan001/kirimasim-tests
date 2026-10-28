# 既存テストの要求照合：式・幅・符号・算術（2026-10-23）

> この文書の件数・割合・保留状態は、各作業時点の記録です。
> 現在の値は[生成した集計概要](behavior-coverage-summary.md)、分母と解釈の承認経緯は
> [要求抽出の結果](requirement-extraction.md)を参照してください。

[現在のカバレッジ](behavior-coverage-summary.md) / [全テストの照合台帳](test-requirement-matching.md) / [直前のサブルーチン照合](existing-test-matching-subroutines-20261023.md)

この文書は式の照合が751本・643要求行の時点の記録です。
その後の[不足した観測へのテスト追加](expression-gap-tests-20261023.md)を参照してください。

## 今回の進捗

提供されたIEEE 1800-2023の11.3.1–11.3.6、11.4.3、11.4.3.1、11.4.10、
11.6–11.8.4の本文と、既存の刺激・期待出力を照合しました。
名前や宣言の存在ではなく、式の幅・値・副作用を実際に区別できる観測を登録しています。

- 対応登録済みテスト：722本から751本（全3,912本のうち29本を追加）。
- 対応済み要求：601行から643行（42行を追加）。新しい対応根拠は84件です。
- 実行確認済み要求：536行から577行（41行を追加）。
- 暫定の要求カバレッジ（テスト設計）：5.22%（643/12,319）。暫定実行確認率：4.68%（577/12,319）。
- 確定値：設計・実行とも未確定。要求単位の整理、解釈保留、分母承認が残っています。
- 少なくとも一つの対応も未登録のテスト：3,161本。全件の検証内容に基づく対応付けは未完了です。

登録済み本数は、一つ以上の観測を要求と対応付けた本数です。
751本すべての観測や要求を精査し終えたという意味ではありません。
AIによる照合で、独立した人による確認済みを意味しません。

今回、テスト入力・期待値・引用・要求定義・ランナーは変更していません。
12,319行の要求定義、既存の対応根拠・集合証拠、分母の識別子を保っていることを確認しました。
前回までの未コミット変更も保持しています。

## 採用した観測と実行証跡

[test_propagated_operand_sign.sv](../tests/ch11/test_propagated_operand_sign.sv) は、
符号付き・符号なしの8bit同士の加算を16bitへ受け、510を確認します。
同じ演算を符号の異なる代入先でも比較し、代入先の符号で演算の符号を決める誤りを区別できます。
32bit unsignedとintの加算を64bitで受けた結果4294967296、signed castの対照例も登録しました。

[test_assignment_extension_steps.sv](../tests/ch11/test_assignment_extension_steps.sv) は、
同じ8bit unsigned代入先へsigned値、unsigned値、$unsigned、符号混在の加算を入れます。
符号拡張・ゼロ拡張が右辺の型に従うことを、異なるビット列で確認できます。
[test_signed_extend_xz_sign_bit.sv](../tests/ch11/test_signed_extend_xz_sign_bit.sv) では、
X/Zの符号ビットを広いsigned値へ拡張する結果と、signed加算の全X化を直接表示します。

[test_multiplier_edge_cases.sv](../tests/ch11/test_multiplier_edge_cases.sv) の8bit FF同士の積FE01や、
[test_expression_width.sv](../tests/ch11/test_expression_width.sv) の8bit 10同士の積0100は、
16bitの代入文脈が演算前に適用されなければ上位ビットを失います。
生成済みのcarry_03/07/08も全ケースの刺激と出力を読み、
`(a+b)>>1`の加算へ広い文脈を伝える規則に対応付けました。

[test_two_state_operations.sv](../tests/ch11/test_two_state_operations.sv) は、
2状態のint同士でもゼロ除算の式自体はXを生成し、その後intへ代入すると0へ変換されることを確認します。
式の$isunknownと、int／integerそれぞれの代入結果が区別されています。

べき乗では、負の指数について底を0、1、-1、正負の絶対値2以上に分け、
-1の奇数／偶数指数、ゼロ指数、正の指数も観測のある要求行だけへ登録しました。
符号と幅の両方を含む要求は、signed底の対照例を持つ
[test_power_signed_base.sv](../tests/ch11/test_power_signed_base.sv) と、
96bitの結果でbit 70を保つ
[test_arithmetic_wider_than_64_bits.sv](../tests/ch11/test_arithmetic_wider_than_64_bits.sv) の集合証拠としました。
両方が同じ実行回で成功する条件で、保存済みIcarus 13.0とVerilator 5.052の各全スイート結果が条件を満たします。
集合証拠を持つ要求は累計18行です。

今回の入力は未変更なので、保存済みの実行結果と現在の入力ハッシュを照合しています。
今回シミュレータを再実行したという報告ではありません。
スナップショットの合成、部分実行による全スイート結果の上書き、既知不一致の成功への換算はしていません。
新規対応42行のうち、realの論理・関係・insideの1bit結果をまとめた要求1行は、
[test_real_operand_result_types.sv](../tests/ch11/test_real_operand_result_types.sv) に採用可能なパス結果の記録がなく、設計対応のみです。

## M18：優先順位や結合順を取り違えても同じ結果となる入力

[test_operator_precedence.sv](../tests/ch11/test_operator_precedence.sv) の
`0 || 1 && 1`は、`(0 || 1) && 1`としても1です。
隣の括弧付きテストも同じ値なので、&&と||の順位を逆転させても通ります。
例えば`1 || 0 && 0`のように、異なる解釈で結果が変わる値が必要です。

`-3 * 2`も`(-3)*2`と`-(3*2)`で-6となり、unary minusの優先順位を判別できません。
「Bitwise before comparison」の表示が付く式は`(a & b) == 0`で、括弧で順序を指定しています。
規格の表では比較の方がbitwise &より高く、この表示を一般の順位の証拠にはしていません。

[test_expression_precedence_basic.sv](../tests/ch11/test_expression_precedence_basic.sv) の
`a+b+5`も、加算の結合性により左右どちらの結合でも同じ結果です。
一方、`20/4/2`で2を得る左結合や、括弧で加算を乗算より先にする観測には検証価値があります。
右結合の条件／implication／equivalenceや表全体の同順位条件までは、これらだけで承認していません。

## M19：代入後の下位値だけでは中間の演算幅を確認できない

[test_expression_width.sv](../tests/ch11/test_expression_width.sv) のTest 2は、
`a16 = a8 + 1`で0100を確認します。しかしunsized整数1は少なくとも32bitなので、
16bit LHSから幅を伝えなくてもこの値になります。
LHS文脈の証拠には、8bit同士の乗算を16bitへ受けるTest 3を採用しました。

[test_minimal_width_ops.sv](../tests/ch11/test_minimal_width_ops.sv)、
[test_arithmetic_overflow.sv](../tests/ch11/test_arithmetic_overflow.sv)、
[test_overflow_arith.sv](../tests/ch11/test_overflow_arith.sv)、
[test_add_expr.sv](../tests/ch11/test_add_expr.sv) の最終的な狭い値は、
途中を広く計算して最後に切り詰めても一致する場合があります。
算術の結果検査と、self-determinedな式の幅そのものの検査を区別しています。

carry_01/02/04/05/06はLHSが元のoperandより狭く、
最大幅で生じる最上位carryを右へ1bit移しても表示範囲外となります。
この観測だけを最大幅のcarryの保持／損失の証拠とせず、
LHSが広く、途中の幅の違いが出力へ現れるcarry_03/07/08を優先しました。
前者の各下位値を他の演算要求へ詳しく照合する作業は残件です。

## M20：$signed／$unsignedの値と、返却幅の検査の違い

例：[test_system_signed.sv](../tests/ch11/test_system_signed.sv)、
[test_cast_unsigned.sv](../tests/ch11/test_cast_unsigned.sv)、
[test_signed_unsign.sv](../tests/ch11/test_signed_unsign.sv)。

符号変換後の値や拡張の検査には役立ちますが、返却式自体の幅を$bitsや連結で区別していません。
同じ幅へ受ける$unsignedの例には、単なるidentityでも一致するものがあります。
また返却幅を誤って変えても、その後の符号拡張／切り詰めで同じ値になる場合があります。
入力と同じビット数のpacked値を返すという11.7の要求全体は保留しました。

## M21：名前だけのサイズcastと、自己反転しても変わらない最小値

[test_size_cast.sv](../tests/ch11/test_size_cast.sv) は、
名前と見出しがSize Castingですが、サイズ指定castの`N'(expr)`を使用しません。
part-selectと連結の結果だけでcastの中間サイズ文脈を確認したとは扱いません。

[test_signed_overflow.sv](../tests/ch11/test_signed_overflow.sv) の
8bit最小値-128のunary minusは、同じ幅で-128へ戻ります。
この入力だけならnegationを省略しても通ります。
加算overflowの観測は登録し、unary minusの要求には別テストの5からFBを得る観測を採用しました。

## M22：複合要求の一部だけを観測する場合

[test_real_operand_result_types.sv](../tests/ch11/test_real_operand_result_types.sv) は
shortreal+intの幅32を直接確認しますが、shortrealを条件だけに使うと型を昇格させない例がありません。
実数条件の例はreal型です。条件operandの例外まで含むshortrealの行全体は保留しています。

[test_short_circuit_side_effects.sv](../tests/ch11/test_short_circuit_side_effects.sv) は、
短絡で副作用が起きないことと、bitwise演算で必要な副作用が残ることを確認できます。
ただし評価すると実行時エラーになるoperandは刺激しないため、
エラー抑止も含む受入条件全体の証拠にはしていません。

## 保留判断と検査

[レビュー判断台帳](../coverage/test-matching-reviews.json)へ32本・35件を追加し、累計156本・167件としました。
範囲を限定した判断の件数であり、ファイル全体のレビュー完了数ではなく、カバレッジにも加算しません。

管理ツールの74テスト、規格資料ハッシュ、対応根拠と実行証跡の整合性、
生成物・メタデータの整合性を検査しました。
