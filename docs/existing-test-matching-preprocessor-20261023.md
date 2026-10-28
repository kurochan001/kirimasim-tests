# 既存テストの要求照合：コンパイラ指令（2026-10-23）

> この文書の件数・割合・保留状態は、各作業時点の記録です。
> 現在の値は[生成した集計概要](behavior-coverage-summary.md)、分母と解釈の承認経緯は
> [要求抽出の結果](requirement-extraction.md)を参照してください。

[現在のカバレッジ](behavior-coverage-summary.md) / [全テストの照合台帳](test-requirement-matching.md) / [照合の進捗と指摘](existing-test-matching-review-20261022.md)

提供されたIEEE 1800-2023の22.2–22.14.9と、関連する3.14.2.1–3.14.2.3、5.6.4を確認しました。
22章の48本と、時刻設定・マクロ・cell taggingに関する他章の7本を対象に、刺激と期待結果を読みました。
include先の宣言・マクロ、およびcell状態を読む2本のVPI用Cソースも確認しています。
以下は確認した観測の範囲の記録であり、55本の全機能の精査完了という扱いではありません。

## 今回の進捗

- 対応登録済み：943本から975本（32本追加、全3,938本）。
- 対応済み要求：792行から810行（18行追加）。38本から85件の対応根拠を追加しました。
- 実行確認済み要求：700行から718行（18行追加）。
- 暫定設計網羅率：**6.58%（810/12,319）**。
- 暫定実行確認率：**5.83%（718/12,319）**。
- 確定値：設計・実行とも未確定。分母承認・重複整理・解釈保留の解決が残ります。
- 要求との対応も未登録のテスト：2,963本。全件の意味上の照合は未完了です。

要求定義12,319行、分母の識別子、規格資料の監査結果は変更していません。
従来の対応・集合証拠・保留判断も保持しています。
既存テストの刺激・期待値・メタデータ、ランナーは変更していません。新しいテストの追加もありません。
対応付けはAIによるもので、独立した人の確認済みではありません。

## 採用した観測

[test_include_file_declarations.sv](../tests/ch22/test_include_file_declarations.sv)は、
include内のtypedefとfunctionをmoduleへ挿入し、memberの3/10と関数結果13を観測します。
[test_include_from_incdirs.sv](../tests/ch22/test_include_from_incdirs.sv)は、
runnerへ渡す検索ディレクトリから解決したファイルの値12と文字列を確認します。
名前やinclude文の存在だけから内容の置換を推定していません。

[test_directive_effect_from_read_point.sv](../tests/ch5/test_directive_effect_from_read_point.sv)は、
最初のmodule内で定義したLEVELを次のmoduleでも使用します。
値3の維持、再定義後の5、undef後の未定義を、同じ実行で3/5/0として観測します。
一方、別々のcompilation unitへmacroが漏れないことまで確認した根拠にはしていません。

[test_macro_concat.sv](../tests/ch22/test_macro_concat.sv)では、呼び出すDECLARE_SIGNALの複数行展開を採用しました。
定義だけのMAKE_NAMEを、識別子連結の検証として登録していません。
[test_macro_args.sv](../tests/ch22/test_macro_args.sv)では、SCALE(5)のdefaultとSCALE(5,3)の明示値を区別します。

[test_vpi_celldefine.sv](../tests/ch22/test_vpi_celldefine.sv)と
[C helper](../tests/ch22/test_vpi_celldefine.c)は、
vpiCellInstanceを読み、2回のcell有効化とendcelldefine/resetallによる解除を1/0/1/0で確認します。
信号の論理値だけからcell tagを推定していません。

[test_begin_keywords_versions.sv](../tests/ch22/test_begin_keywords_versions.sv)は、
noconfigでconfig/cell/designをidentifierにする3つの許可を、個別の要求へ登録しました。
全keyword集合や入れ子からの復元の検証としては扱っていません。

## 追加した集合証拠

5要求行に集合証拠を追加し、累計50行になりました。
全メンバーが同じシミュレータ・同じ実行回で成功した場合だけ、行全体の実行成功に数えます。

- 空macro：`test_ieee_ch22_directives_edge`のdefined状態と、`test_directive_corner_cases`の実際の空展開。
  undefined macroを警告付きで空にする実装でも後者だけは通り得るため、両方を要求します。
- conditionalの配置：`test_define_selects_included_file`のmodule外include、
  `test_compiler_directives`の宣言領域、`test_ifdef_nested`の手続き文。
- undefineall：`test_undefineall`のmodule内と、`test_undefineall_clears_nested_macro_expansion`のmodule外。
- timescale：`test_timescale_child_units_in_parent`のunitの相対尺度、
  `test_timescale_delay_rounded_to_precision`の丸め、`test_timescale_replaced_by_next`の置換、
  `test_timeunit_with_precision`の明示local設定の優先。
- unconnected_driveのoptional pairing：`test_unconnected_drive`の明示pairと、
  `test_unconnected_drive_instances_restore`のpull1からpull0への直接切替。

## 実行証跡と対照確認

元テストの全スイートを今回は再実行していません。
[Icarus 13.0の保存済み実測結果](../coverage/results/icarus.json)と
[Verilator 5.052の保存済み実測結果](../coverage/results/verilator.json)、および登録済みの部分実行へ、
現在の入力SHA-256とランナーの識別子を照合しました。
新規18行すべてに有効な成功証跡があります。
known・未対応・古い証跡は成功に含めず、別実行回の部分成功も集合証拠へ合成していません。

観測の判別力を確認するため、元ファイルを変えず、一時的なsource変種5種類をコンパイル・実行しました。

- MULTI_LINE呼出しの削除、literal内の`Vを同じ長さの22へ変更、
  kw_2001_afterだけを1364-1995へ変更する3種類は、Verilatorで元の全期待出力と一致しました。
  それぞれ未観測の複数行処理、長さだけの比較、keyword復元先の識別不足を裏付けます。
- SCALEのdefault2を3へ変えると、VerilatorでFAIL行が出ました。
- conditionalの最初の加算10を00へ変えると、Icarus 13.0・Verilator 5.052の両runnerで最後のPASSが消えました。
  当該assertによる検査が、この2環境では判別に働くことを確認しました。

3種類の変種が通ることはテストの観測不足であり、シミュレータの規格違反ではありません。
一時変種の結果はカバレッジの実行証跡へ登録していません。

## M52：ラベルと定義だけでは機能を確認できない

`test_compiler_directives_comprehensive`のREG_NAME/STRINGIFY、
`test_macro_args`のCONCAT、`test_ieee_ch22_directives_edge`のSTR_MACRO/CONCAT_MACROは未使用です。
`test_directive_corner_cases`のtoken concatenation conceptはvar1を直接読んでいます。
再帰防止もrecursive macroを使わず固定PASSを表示します。
timescaleはendmoduleより後にあり、遅延の観測もありません。
該当ラベルを対応根拠へ転用していません。

## M53：値・内容を確認しない成功表示

`test_directive_corner_cases`のMULTI_LINEは、local tempへ書くだけです。
__FILE__/__LINE__も非空・正値しか確認しません。
`test_macro_redefine_string_literal`はliteralの長さ14だけを確認します。
上記の対照確認を踏まえ、複数行、正確な位置、ordinary literal内の非置換という各要求は保留しました。
同じファイルで実際に識別できる通常macro展開は、別の観測として採用しています。

## M54：直後の再定義がundefの欠落を隠す

`test_compiler_directives_comprehensive`はundef直後にDATA_WIDTHを16へ定義します。
undefを無視しても最新defineが16へ上書きするため、この部分はundef単体の検査ではありません。
undef後・再定義前にifdefで未定義を観測する専用テストの既存対応は保持しています。

## M55：単純な入れ子では展開時期や再置換を区別できない

INNERを定義した後でOUTERを定義し、再定義せずに読む例では、定義時の早期展開でも同じ値になります。
数値定数だけを使う入れ子ADDも、内側から導入された同名formalの誤った再置換を区別しません。
STRINGIFY(hello_world)はformalのquoteへの置換を確認しますが、quote内のembedded macroの展開は確認しません。
これらを含む広い要求行へは、そのまま対応付けていません。

## M56：正常系と違法系が混在する要求単位

default_nettypeの既定wire/resetとnoneによる拒否、unconnected_driveの正常動作と配置禁止、
keyword集合の正常系とreserved identifierの拒否などで、要求行のkindとテストのkindが一致しない箇所があります。
禁止条件を確認する有効な違法系テストでも、同じ行の他の条件へ成功を転用していません。
resetallの一般則も、cell解除やimplicit wireだけでは、macro等の維持まで確認した根拠になりません。
要求定義・kindを変更して対応件数を増やすことはせず、整理の残件を記録しました。

## M57：部分的な境界・復元を全条件へ広げない

2階層includeは最低15階層の保証を検査しません。
helper/mainで同じincludeを使える設計は、両者が同一unitでも別unitでも通るため、unit分離の検査にはなりません。
lineの500/501表示は有効ですが、includeを出入りした位置のsave/restoreやresetall後の維持まで確認していません。
nounconnected_driveによる復帰をresetallの効果へ数えることも避けています。

## M58：keywordの復元先を区別する入力が必要

`test_begin_keywords_versions`のkw_2001_afterはlogic/uwireをidentifierとして使います。
両語とも1364-1995/2001の双方で非keywordなので、誤って1995へ戻しても同じ出力になります。
また、実際の指定に1800-2012/2017はなく、2023部分は固定done表示です。
全9指定・全keyword集合・stack復元の完了としていません。
noconfigで除外するconfig/cell/designの3つは、値を実際に表示するため個別に採用しました。

## 保留台帳と管理ツールの検査

[範囲別の判断台帳](../coverage/test-matching-reviews.json)へ41件の判断を追加しました。
台帳の対象は317本から345本、判断は424件から465件になりました。
既存の判断を保持し、同じファイルの追加判断には今回の日付・担当も付けています。
この件数はファイル全体のレビュー完了数でも、動作カバレッジの分子でもありません。

管理ツールの74テスト、規格資料ハッシュ、要求対応・判断・実行証跡の鮮度、
カタログ・統計・depth・生成物・メタデータの整合性を検査しました。
既存の要求定義・対応・集合証拠・保留判断とテスト入力を保持したことも機械的に確認しています。
