# 既存テストの要求照合：配列メソッド（2026-10-23）

> この文書の件数・割合・保留状態は、各作業時点の記録です。
> 現在の値は[生成した集計概要](behavior-coverage-summary.md)、分母と解釈の承認経緯は
> [要求抽出の結果](requirement-extraction.md)を参照してください。

[現在のカバレッジ](behavior-coverage-summary.md) / [全テストの照合台帳](test-requirement-matching.md) / [前回のクラス照合](existing-test-matching-classes-20261023.md)

## 今回の進捗

提供されたIEEE 1800-2023の7.12、7.12.1–7.12.5と、既存テストの刺激・期待出力全体を照合しました。
固定配列・dynamic array・queueの検索、代表要素、縮約、並べ替え、iterator index、mapを対象にしました。
構造体配列のkey指定やreal queueの観測も確認しています。

- 対応登録済み：858本から893本（全3,923本のうち35本追加）。
- 対応済み要求：725行から746行（21行追加）。対応根拠は119件追加しました。
- 実行確認済み要求：651行から672行（21行追加）。
- 暫定設計網羅率：**6.06%（746/12,319）**。
- 暫定実行確認率：**5.45%（672/12,319）**。
- 確定値：設計・実行とも未確定。分母の承認・重複整理・保留解釈の解決が残ります。
- 一つ以上の対応も未登録のテスト：3,030本。全件の意味上の照合は未完了です。

登録済み本数は少なくとも一つの観測を要求へ対応付けた本数で、各ファイルの全観測・全要求の精査完了数ではありません。
レビューはAIによるもので、独立した人の確認済みではありません。

今回、テスト入力・期待値・引用・ランナー・要求定義は変更していません。
全12,319行の要求定義、既存の対応根拠・集合証拠・判断記録と、以前からの未コミット変更を保持しました。

## 採用した観測と集合証拠

[test_array_find.sv](../tests/ch7/test_array_find.sv) は、findの結果をsortして25/25/30/40の全要素を確認します。
重複数も含む比較で、未規定の探索順を期待値に持ち込みません。
first/lastには、同じpredicateで返る値が25と40になる観測を採用しました。
同じ値20を複数候補から選ぶだけのfind_lastは、誤ってfirstを返しても検出できないので保留しました。

[test_array_unique_methods.sv](../tests/ch7/test_array_unique_methods.sv) は、uniqueの結果をsortして全代表値を確認します。
unique_indexでは返った添字が選ぶ元値をsortして10/20/30/40と比較します。
重複値のどの添字を代表にするかも、結果の順序も固定しません。

縮約では、通常の要素値と、withによる非identityの値変換を組み合わせました。
[test_array_reduction_with_clause.sv](../tests/ch7/test_array_reduction_with_clause.sv) の倍加sum30、平方和55、
[test_comb_queue_with_clause.sv](../tests/ch7/test_comb_queue_with_clause.sv) の`product with (item+1)`の24は、
withを無視したり、Boolean filterとして元値を選ぶだけにしたりする実装と区別できます。
[test_array_reduction_and_or_xor_with.sv](../tests/ch7/test_array_reduction_and_or_xor_with.sv) は、
and/or/xorについて通常値0/3/0とprojected値8/7/5を直接対照します。

今回、次の8要求に集合証拠を設定しました。累計32行です。
グループ内はAND、グループ間はORで、同じ実行回の全メンバーの成功を要求します。

- LOCATOR-EMPTY：非空配列のno-matchと、空配列のunique。
- LOCATOR-UNPACKED：固定unpacked array、dynamic array、queueの3種類。
- MAXIMUM：重複最大値でもsize1となる観測と、squareをkeyとして元値-10を返す観測。
- SUM／PRODUCT／AND／OR／XOR-REDUCE：with省略時と非identity projection時の観測。

これらの集合条件は保存済み`verilator.json`の同じ実行回で満たしています。
対応するIcarus側のknownは成功へ換算していません。
新規21行はすべて採用可能な成功証跡があり、実行確認にも追加しました。

今回はシミュレータを再実行していません。入力未変更のため、保存済み全3,912本のIcarus 13.0／
Verilator 5.052の実行結果を現在の入力ハッシュと照合しました。
その後の追加・引用変更に対する部分実行結果も保持し、全3,923本の一括再実行とは扱っていません。
異なる実行回の部分成功を集合証拠へ合成していません。

## M36：未規定のlocator結果順を固定するoracle

[test_array_method_index_argument.sv](../tests/ch7/test_array_method_index_argument.sv) は、
iterator/indexのrenameや、構造体のindex memberとの衝突回避を刺激します。
ただし、findの値20/40、find_indexの添字2/4、recordの値10/20をsortせず順序付きで表示し、期待出力でも固定します。

7.12.1ではlocatorの探索順は未規定です。逆順の結果でも適合するため、このwhole-file oracleを保留しました。
renameの刺激が有用でも、この結果からの対応は追加していません。
順序の正規化などによるoracle修正と、入力変更後の再実行が残件です。

## M37：size・先頭値だけでは内容や位置を確認できない

unique／unique_indexのsizeだけを検査するテストが複数あります。
同じsizeで重複・欠落・誤った代表添字を返しても通るため、全代表値を確認する別テストを採用しました。
findの件数だけを確認するケースも、返った全matching multisetを確認したことにはしていません。

[test_array_min.sv](../tests/ch7/test_array_min.sv) と[test_array_max.sv](../tests/ch7/test_array_max.sv) には、
全要素7というtieがありますが、判定はsize>0と先頭7だけです。
size==1を判定するのは別の、極値が重複しない配列です。tieの値を全部返す誤実装を検出できません。

MAXIMUMは別テストの重複最大値8に対するsize1とprojectionを集合にしました。
MINIMUMの同じtie条件は、今回確認した範囲では十分な観測がなく保留です。
同じ値20を返すfind_lastもfirstとの違いが出ず、異なる候補値を持つ別の観測を採用しました。

## M38：ソートの両端と相関したkeyだけを見る

sort／rsort後の両端だけを検査しても、middleの順序が不正な実装や、要素を失う実装を検出できません。
通常scalarの全位置を確認するテストはありますが、with-key側の全位置を確認する証拠が不足しています。

[test_comb_queue_with_clause.sv](../tests/ch7/test_comb_queue_with_clause.sv) のsquare-key sortは、
先頭3個のkey順だけを確認します。成功時に末尾2個を表示しないため、期待出力の完全一致でもその不足は埋まりません。
[test_struct_array_sort.sv](../tests/ch7/test_struct_array_sort.sv) も両端だけで、さらにvalue=id*10なので、
idとvalueを取り違えても順位が同じです。

通常sortの全位置を別ファイルで確認しても、projection側の未観測のmiddleを確認したことにはなりません。
SORT／RSORT行全体は今回のカバレッジに加えていません。

## M39：代入先の型・rangeはメソッド結果そのものではない

[test_array_map_method.sv](../tests/ch7/test_array_map_method.sv) の`$bits(big[2])`が測るのは、
明示したbit型の代入先です。mapのself-determinedな要素型を直接測るものではありません。
固定配列g[2:4]も代入先のrangeで、返却配列のrangeが変わっていても代入で隠れ得ます。

[test_map_result_to_same_array.sv](../tests/ch7/test_map_result_to_same_array.sv) は、
値、size、元配列の不変を確認しますが、非0／逆向きrange、associative key set、異なる要素型をまとめた条件は満たしません。
MAP-SHAPE／MAP-SELF-DETERMINED-TYPEは保留しました。

縮約でも、8bitの代入先やintの代入先だけではreduction式自体の型・幅を確認できません。
with内のcastで各要素を広げた場合と、広い代入先だけの場合のoverflow差を観測するケースが必要です。
RESULT-TYPE／REDUCTION-SIGNATURE／WITH-RESULT-WIDTHは今回追加していません。

## M40：shuffleの不変条件と、正常・違法を含む複合行

sum／product／sizeだけでは、同じ集計値を持つ別multisetへの変化を検出できません。
sortして全要素を比較するケースには検証価値がありますが、shuffleは元順のpermutationも許すため、
一度の呼び出しで必ず順序が変わることを求めてはいけません。

現在のSHUFFLE／REVERSE要求行は、正常な並べ替えと「withを指定した場合はcompile error」を併記しています。
全位置を確認する正常テストでも禁止形式を拒否することは未観測なので、これらの複合行全体は保留しました。
要求定義を弱めて割合を上げる変更はしていません。

## M41：未使用宣言、filterと同じ結果になるprojection、Xを見逃す判定

sum／product／and／or／xorの専用テストでは、空のarr4を宣言するだけでそのmethodを呼びません。
通常値やsingletonの結果は採用しましたが、空配列を検証したとはしていません。
[test_array_method_corner.sv](../tests/ch7/test_array_method_corner.sv) のxor_resultも、代入後に判定・表示されません。

[test_array_method_sum.sv](../tests/ch7/test_array_method_sum.sv) の`sum with (item>2?item:0)`は、
Boolean filterとしてitem>2の元値だけを足しても12になります。
projectionとfilterの違いには倍加や平方の別証拠を使います。

[test_array_and_or_xor.sv](../tests/ch7/test_array_and_or_xor.sv) は、logic型resultについて
`if (result != expected)`だけで失敗を判定し、値は表示しません。
誤実装がXを返すと比較結果もXでifがtrueにならず、PASSへ到達できます。このfileは今回の対応へ採用していません。

## M42：iteratorの値・名前scope・次元・戻り値型を区別する

`sum with (item.index)`が要素値1..5の和15ではなく添字0..4の和10を返す観測は、INDEX-QUERYへ登録しました。
ただしdimension2以上、明示dimension引数、associative index型を確認したとはしません。
普通の0基点配列のfirst/lastも、associative first()/last()や逆向きrangeの境界と同一視していません。

default itemと明示iteratorを使っても、同名outer変数によるscope境界やattribute形式まで確認したことにはなりません。
array_predicatesというファイル名でも、size/new/deleteとqueue push/popだけのテストはwith式評価の根拠にしていません。

## M43：withなしiterator指定の診断oracle

[test_illegal_iterator_argument_without_with.sv](../tests/ch7/test_illegal_iterator_argument_without_with.sv) の
`q.sum(v)`は、iteratorを指定したのにwithがない違法刺激です。
ただし期待stderr正規表現はファイル名と行番号だけで、array methodやiterator構文自体が未対応でも一致し得ます。
該当意味制約を識別する診断と対応環境での実行を残件にし、error要求には登録していません。

## 記録と検査

[判断台帳](../coverage/test-matching-reviews.json)へ39本・87件の保留判断を追記しました。
累計272本・354件で、部分観測・複合要求・oracle問題を記録しています。
これらはテスト全体のレビュー完了数でも、カバレッジへの加算対象でもありません。

開始時のスナップショットと比較し、全要求定義と従来の対応・集合証拠・判断記録の保持を確認しました。
管理ツールの単体テスト74件、本文出典・coverage・matching・catalog・stats・depth・generatorの整合性検査はすべて成功しました。
metadataは新規問題0件、既知378件です。`git diff --check`も成功しました。
