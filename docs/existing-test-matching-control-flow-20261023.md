# 既存テストの要求照合：制御文・ループ（2026-10-23）

> この文書の件数・割合・保留状態は、各作業時点の記録です。
> 現在の値は[生成した集計概要](behavior-coverage-summary.md)、分母と解釈の承認経緯は
> [要求抽出の結果](requirement-extraction.md)を参照してください。

[現在のカバレッジ](behavior-coverage-summary.md) / [全テストの照合台帳](test-requirement-matching.md) / [直前のテスト追加](expression-gap-tests-20261023.md)

## 今回の進捗

提供されたIEEE 1800-2023の12章の関連節と9.3.5を確認し、条件分岐、case、パターン、
ループ、jump、文ラベルについて、既存の刺激・期待出力を照合しました。
関連する13.4.1の関数戻り値の観測も対応付けています。

- 一つ以上の要求との対応登録済み：762本から813本（全3,923本のうち51本を追加）。
- 対応済み要求：672行から698行（26行追加）。新しい対応根拠は72件です。
- 実行確認済み要求：606行から624行（18行追加）。
- 暫定の要求カバレッジ（テスト設計）：**5.67%（698/12,319）**。
- 暫定実行確認率：**5.07%（624/12,319）**。
- 確定値：設計・実行とも未確定。分母承認・重複整理・解釈保留は残件です。
- 一つ以上の対応も未登録のテスト：3,110本。全件の検証内容に基づく対応付けは未完了です。

登録済み本数は、一つ以上の観測を要求へ対応付けた本数であり、813本すべての観測・要求を
精査し終えたという意味ではありません。照合はAIによるもので、独立した人の確認済みではありません。

今回、テスト入力・期待値・引用・ランナー・要求定義は変更していません。
12,319行の要求定義、既存の対応根拠・集合証拠・保留判断、分母識別子を保持しています。
前回までの未コミット変更も保持しています。

## 採用した観測と集合証拠

[test_case_exact_xz_match.sv](../tests/ch12/test_case_exact_xz_match.sv) は、ordinary caseで
同じX/Zビットが一致し、Xを持つ値が既知の異なる値とは一致しないことを確認します。
変数をcontrollerとitemの両方に使う形式も観測できます。

[test_comb_foreach_3d_break.sv](../tests/ch12/test_comb_foreach_3d_break.sv) は、
3次元foreachの最初の行のk=2でbreakし、合計1だけを残します。
内側次元だけの脱出では後の行・面が加算されるため、foreach全体からの脱出を区別できます。
値3を初めて見つける位置[1][2]は、次元順を逆にした[2][1]とも区別でき、走査順の証拠にも採用しました。

whileは初期条件がfalseのとき0回、do-whileは同じ場合も1回実行する対照例を採用しました。
continueは本体の残りを飛ばし、forのstepを経て次の反復へ進むことを、和・回数と終了の両方で確認します。
末尾に余分なFAIL行を出しても、期待出力の完全一致で不合格になります。

今回、次の3要求を新たに集合証拠にしました。集合証拠を持つ要求は累計21行です。
一つのグループの全メンバーが、同じ実行回で成功することを必要とします。

- casez/casexの違い：selector／itemのX/Z wildcardを確認するテストと、casezがXをwildcardにしない対照例。
  保存済み`icarus.json`の同じ回ですべて成功しています。
- returnの形式：値を返す関数、後続の変更を飛ばすtaskのbare return、void関数のbare return。
  `ch13/test_return_stmt.sv`と`ch13/test_stmt_return_2.sv`が、`verilator.json`の同じ回で成功しています。
- jumpの構文：return expression／bare returnと、break／continueの組み合わせ。
  `ch13/test_return_stmt.sv`と`ch12/test_control_flow_2.sv`が、両方の全スイート実行回で成功しています。

パターンの8要求は、構造体・tagged union・定数・wildcard・binding・filterの観測を設計対応として登録しましたが、
採用可能なパス結果の記録がないため実行確認には含めません。

今回はシミュレータを再実行していません。保存済み全3,912本のIcarus 13.0／Verilator 5.052の結果と、
その後に追加・引用変更したテストの別実行結果を保持し、現在の入力ハッシュと照合しました。
部分実行を全3,923本の一括再実行と扱ったり、異なる実行回の部分成功を集合証拠として合成したりしていません。
累積レビュー入口にあった「全3,923本を再実行」という誤記も、この実際の実行範囲へ訂正しました。

## M23：2値のintでselectorのX/Zが失われる

例：[test_control_flow.sv](../tests/ch12/test_control_flow.sv)、
[test_control_flow_4.sv](../tests/ch12/test_control_flow_4.sv)、[test_stmt_ext.sv](../tests/ch12/test_stmt_ext.sv)。

X/Zリテラルをintへ代入してからcase比較しており、controllerにX/Zが残っていません。
item側の?やXのwildcardには検証価値があるため適切な規則へ登録しましたが、
selector側のX/Zを扱ったことにはしていません。後者にはlogicを保持するテストを採用しました。

また、[test_x_z_propagation.sv](../tests/ch11/test_x_z_propagation.sv) の
「casez handles X as wildcard match」という表示は規則の説明として不適切です。
実際はselector x1に対して01が一致せず、?1がitem側のZでその位置を隠すためresult=2となります。
casezがselectorのXをwildcardにしないことの対照例として登録しました。表示・期待値は変更していません。

## M24：全要素の和と対称なcontinue条件では順序を区別できない

[test_ct_foreach_nd.sv](../tests/ch12/test_ct_foreach_nd.sv) などの全要素の合計・訪問数や、
添字から設定した最終配列は、次元の入れ子順を逆にしても一致します。
走査順の証拠には、途中終了の位置が変わる前述の専用テストを採用しました。

その専用テストのT2にも注意が必要です。continue条件がj==1だけなので、該当jの全kを常に除外します。
正しい各tupleのcontinueと、誤って残りのkを一括して飛ばす実装で合計484が一致します。
このケースをforeachのcontinue境界の要求全体へ対応付けていません。

[test_foreach_loop_2.sv](../tests/ch12/test_foreach_loop_2.sv) の最後のbreakも、判定がsum>=6だけです。
breakを無視して全要素の和15まで処理しても通ります。

## M25：unique/priorityの分岐結果だけでは違反報告を確認できない

例：[test_unique_case_edge_cases.sv](../tests/ch12/test_unique_case_edge_cases.sv)、
[test_unique_priority_unique0_basic.sv](../tests/ch12/test_unique_priority_unique0_basic.sv)。

分岐後の値を確認しても、複数一致やdefaultなし不一致の違反報告を捕捉したことにはなりません。
unique0のno-matchで変数が不変でも、不要な警告の有無までは判別できません。
値比較、報告の発生／不発生、報告タイミングを別の観測として扱う必要があります。

else-if／priority-ifの条件が純粋な比較だけの場合も、最初のtrue以降の条件を余分に評価しても出力は変わりません。
チェーン構文を許す規則へは登録しましたが、評価順・探索停止の要求全体は保留しました。

## M26：repeat回数の入力が変わらない

例：[test_repeat_loop.sv](../tests/ch12/test_repeat_loop.sv)、
[test_statement_repeat.sv](../tests/ch12/test_statement_repeat.sv)、[test_repeat_loop_3.sv](../tests/ch12/test_repeat_loop_3.sv)。

repeat(count)やrepeat(count*2)の入力を本体中に変えず、count関数の呼び出し回数も観測しません。
同じ値を毎回再評価する誤実装でも同じ出力となり、開始時に一度だけ評価する規則の証拠としては不足です。
repeat(0)だけの境界確認も、負数／X／Zの回数まで含む要求行全体の承認には使っていません。

## M27：未観測の制御変数・省略形・寿命

[test_for_loop_adv_edge_cases.sv](../tests/ch12/test_for_loop_adv_edge_cases.sv) のmultiple initは、
bodyがcounter++だけでjを読みません。jのinit/stepを無視しても成功します。
一方、[test_for_loop_3.sv](../tests/ch12/test_for_loop_3.sv) はi+jとi<jを使うため両変数に有効な観測がありますが、
要求行が含むfunction callのstepは未検証です。省略init/test/stepの複合行も保留しています。

[test_foreach_index_shadows_outer.sv](../tests/ch12/test_foreach_index_shadows_outer.sv) の外部変数不変はscopeの強い観測ですが、
同時activationでのautomatic storage分離や、labelでimplicit scopeを名付ける形式までは確認しません。
[test_array_loops_and_strings.sv](../tests/ch7/test_array_loops_and_strings.sv) も、名前にstringsがあっても
foreachの対象は固定配列だけで、文字列の走査は行いません。

## M28：case insideとパターンの特殊条件

[test_case_inside.sv](../tests/ch12/test_case_inside.sv) の既知の定数集合は、通常caseでも同じ結果になります。
非対称wildcard、insideがXを返す不一致、controller/itemの評価回数・順序を検査したとは扱いません。

パターンのbindingやfilter成功／失敗には有効観測がありますが、X/Zを含む結果のknown性、
failed &&&節以降の短絡、false枝へのscope漏れ、曖昧なBoolean filterは未観測です。
case内binding/filterの観測を登録し、それらの別要求を埋めたことにはしていません。

## 保留判断と検査

[レビュー判断台帳](../coverage/test-matching-reviews.json)に38本・47件を追加し、累計194本・214件となりました。
これは範囲を限定した判断の件数で、ファイル全体のレビュー完了数ではなく、カバレッジにも加算しません。

管理ツールの74テスト、規格資料ハッシュ、対応根拠と実行証跡の整合性、生成物・メタデータの整合性を検査しました。
