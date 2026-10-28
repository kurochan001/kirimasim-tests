# 既存テストの要求照合：サブルーチン（2026-10-23）

> この文書の件数・割合・保留状態は、各作業時点の記録です。
> 現在の値は[生成した集計概要](behavior-coverage-summary.md)、分母と解釈の承認経緯は
> [要求抽出の結果](requirement-extraction.md)を参照してください。

[現在のカバレッジ](behavior-coverage-summary.md) / [全テストの照合台帳](test-requirement-matching.md) / [直前の代入系の照合](existing-test-matching-review-20261023.md)

この文書はサブルーチンを照合した722本・601要求行の時点の記録です。
その後の[式と算術の続行結果](existing-test-matching-expressions-20261023.md)を参照してください。

## 今回の進捗

13章の引数、コピー時点、寿命、default、名前付き引数、定数関数、前方参照、
パラメータ化サブルーチンを中心に、提供されたIEEE 1800-2023本文と既存の刺激・期待結果を照合しました。
関連する4.9.7、6.21、8.6の観測も対応付けています。

- 対応登録済み：680本から722本（全3,912本のうち42本を追加）。
- 対応済み要求：574行から601行（27行を追加）。新しい対応根拠は59件です。
- 実行確認済み要求：509行から536行（27行を追加）。今回追加した27行にはすべて採用可能なパス結果の記録があります。
- 暫定の要求カバレッジ（テスト設計）：4.88%（601/12,319）。暫定実行確認率：4.35%（536/12,319）。
- 確定値：設計・実行とも未確定。要求単位の整理・解釈保留・分母承認は残件です。
- 少なくとも一つの要求との対応も未登録のテスト：3,190本。全件の検証内容に基づく対応付けは未完了です。

登録済み本数は、少なくとも一つの観測を対応付けた本数であり、
722本すべての観測・要求を精査し終えたという意味ではありません。
AIによる照合で、独立した人による確認済みを意味しません。

## 有効な観測と集合証拠

[test_sched_subroutine_copy_out.sv](../tests/ch4/test_sched_subroutine_copy_out.sv) は、
output/inout/refを遅延中に比較します。outputのactualは呼び出し中に旧値1を保ち、
refのactualは復帰前に33へ変わります。inoutでは呼び出し時の2から計算した12が、
外部からactualを100へ変えても復帰時にコピーアウトされます。
復帰後の最終値だけを見るテストより、コピーの時点やrefとの違いを直接確認できます。

[test_array_args_by_value_ref.sv](../tests/ch7/test_array_args_by_value_ref.sv) は、
値渡しした固定・動的・キュー・連想配列のformalを変更しても、元配列の値・サイズが保たれることを確認します。
関数内で変更した値と、呼び出し側で保たれる値を別に観測しています。

同時呼び出しでstatic formalが共有され、automatic formalは分離されること、
automatic local/outputの初期化とstatic local/outputの保持、
呼び出し側に同名変数があってもdefaultを宣言側スコープで毎回評価することも登録しました。
定数評価中の通常の$display抑止と実行時の表示、前方参照の解決、型・幅を変えた静的メソッドの結果も確認しました。

今回、ANSI／body形式のtask宣言、automaticのlocal／formal初期化、staticのlocal／formal保持、
名前付き引数の並べ替え／default省略の4要求を新たに集合証拠としました。
集合証拠を持つ要求は累計17行です。各グループは同じ実行回ですべて成功する必要があります。

## 引用を具体化した4本と再実行

刺激・期待値・要求定義は変更せず、次の`:lrm:`引用だけを追加しました。

- `ch13/test_static_task_shared_activation.sv`：13.3.1。
- `ch13/test_task_output_formal_initial_value.sv`：13.3.2。
- `ch4/test_sched_subroutine_copy_out.sv`：13.5。
- `ch7/test_array_args_by_value_ref.sv`：13.5.1。

更新後の入力でIcarus 13.0とVerilator 5.052を実行しました。
Icarusは2本成功・2本既知不一致、Verilatorは3本成功・1本既知不一致で、
4本すべてに少なくとも一方での現行入力に対応するパス結果の記録があります。既知不一致は成功に含めていません。

実行結果は`coverage/results/subroutine-citation-refinement-20261023-icarus13.json`と
`coverage/results/subroutine-citation-refinement-20261023-verilator.json`に保存しました。
最初に既定環境で実行したIcarus 14.0開発版の結果も、実際の版を記録した
`subroutine-citation-refinement-20261023-icarus.json`として分けて保持しています。
automaticのlocal／output初期化の集合証拠は、必要な2本をIcarus 13.0で同じ実行回にまとめ、2本とも成功した
`subroutine-initialization-group-20261023-icarus13.json`を採用しています。
既存の全スイート証跡を部分実行で上書き・合成していません。
今回変更していないテストは、保存済みの実行結果と現在の入力ハッシュを照合しています。

## M13：復帰後のrefの値だけでは、即時共有を確認できない

例：[test_ref_arg.sv](../tests/ch13/test_ref_arg.sv)、
[test_task_ref.sv](../tests/ch13/test_task_ref.sv)、
[test_ref_arg_edge_cases.sv](../tests/ch13/test_ref_arg_edge_cases.sv)。

これらは増加・交換・配列更新の結果を確認しますが、観測が復帰後だけです。
refをinoutのコピーイン／コピーアウトとして扱う誤実装でも同じ結果になります。
呼び出し中の観測、actualとformal間の更新、または同じ変数を複数refへ渡したaliasの観測が必要です。
今回は復帰前に別プロセスがactualを読む専用テストを、即時可視性・参照共有の要求へ登録しました。

[test_ref_const_ref_detailed.sv](../tests/ch13/test_ref_const_ref_detailed.sv) のオブジェクト操作も、
ハンドル自身の差し替えではなく`obj.value`の変更だけです。
ハンドル値をコピーして渡してもオブジェクト内容は共有されるため、actualハンドルのref更新を検証したとは扱いません。
eventの発火も、eventを値渡しして同じ同期オブジェクトを参照する場合と区別が必要です。

## M14：明示actualでdefaultを上書きしても、未使用式の非評価は証明できない

例：[test_default_argument_declaring_scope.sv](../tests/ch13/test_default_argument_declaring_scope.sv)、
[test_default_value_expressions.sv](../tests/ch13/test_default_value_expressions.sv)。

明示actualを使ってdefault値を採用しないことは確認しますが、default式には観測可能な副作用がありません。
使わない式を余分に評価しても出力は変わりません。評価回数などを変えるdefault関数を用意し、
actualを省略した場合と指定した場合で、その副作用を確認する必要があります。
default宣言や宣言側スコープの再評価の有効な観測は別要求へ登録しています。

## M15：宣言順の加算だけでは、名前付き引数の対応を確認しにくい

[test_function_call_patterns.sv](../tests/ch13/test_function_call_patterns.sv) は、
`add(.a(10), .b(20))`で30を確認します。
宣言順のまま位置で渡しても、a/bを取り違えても加算結果は同じです。

[test_function_corner.sv](../tests/ch13/test_function_corner.sv) の
`divide(.b(3), .a(10), .remainder(rem))`は、宣言と異なる順番で渡し、商3を確認するため、
位置順の解釈と区別できます。名前付きtask呼び出しでdefault入力を省略する別テストと組み合わせて登録しました。

## M16：ファイル名と、実際に宣言したサブルーチンの寿命・種類の違い

- [test_auto_task.sv](../tests/ch13/test_auto_task.sv) にtaskはなく、関数だけです。factorialも再帰ではなくループです。
- [test_task_recursion.sv](../tests/ch13/test_task_recursion.sv) も関数だけです。再帰関数の計算をtaskの入れ子として計上していません。
- [test_func_static.sv](../tests/ch13/test_func_static.sv) と[test_task_static.sv](../tests/ch13/test_task_static.sv) は、サブルーチン自体がautomaticで、localが明示staticです。

最後の2本はlocalのstatic overrideを確認できるので6.21へ登録しました。
無指定サブルーチンがstaticとなる既定規則や、staticサブルーチン内のautomatic localという逆方向の証拠とは区別しています。

## M17：未呼び出しの戻り値型と、元変数を持たない値渡しの確認

[test_func_return_2.sv](../tests/ch13/test_func_return_2.sv) はshortint/byte/enumを返す関数を宣言しますが、
呼び出さず値も検査しません。観測するのはint・16bit unsigned・real・32bit logic・stringの5種類です。
宣言された全カテゴリを動作検証済みにしていません。

[test_func_scope.sv](../tests/ch13/test_func_scope.sv) の`modify_arg(5)`はリテラルを渡すため、
formalの変更が元変数へ伝わらないかを観測できません。
同じファイルのmodule_var不変の確認は、actualとは別の変数の検査です。
値コピーの隔離には、元変数や元配列の前後を確認する必要があります。

## 保留理由と検査

今回34本・38件の範囲別判断を追加し、[レビュー判断台帳](../coverage/test-matching-reviews.json)は
累計124本・132件になりました。これはファイル全体のレビュー完了数ではなく、カバレッジへ加算もしません。
呼び出し中の観測不足、未使用定義、複合要求の一部だけの観測、引用不足を理由付きで保持しています。

要求定義12,319行と分母の識別子は変更していません。
管理ツールの74テスト、規格資料ハッシュ、対応根拠と実行証跡の整合性、生成物・メタデータの整合性を検査しています。
