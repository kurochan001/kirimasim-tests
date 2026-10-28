# 既存テストの要求照合：連想配列（2026-10-23）

> この文書の件数・割合・保留状態は、各作業時点の記録です。
> 現在の値は[生成した集計概要](behavior-coverage-summary.md)、分母と解釈の承認経緯は
> [要求抽出の結果](requirement-extraction.md)を参照してください。

[現在のカバレッジ](behavior-coverage-summary.md) / [全テストの照合台帳](test-requirement-matching.md) / [前回の配列メソッド照合](existing-test-matching-array-methods-20261023.md)

以下は既存テスト照合直後の記録です。その後の[不足した観測への15本のテスト追加](associative-gap-tests-20261023.md)に、
追加内容・実行結果・更新後の割合を記録しています。

## 今回の進捗

提供されたIEEE 1800-2023の7.8、7.8.1–7.8.7、7.9、7.9.1–7.9.11を確認し、
キー、割当て、既定値、個数、削除、走査、全体代入、値渡しについて刺激・期待出力を照合しました。

- 対応登録済み：893本から928本（全3,923本のうち35本追加）。
- 対応済み要求：746行から768行（22行追加）。38本から74件の対応根拠を追加しました。
- 実行確認済み要求：672行から688行（16行追加）。
- 暫定の要求カバレッジ（テスト設計）：**6.23%（768/12,319）**。
- 暫定実行確認率：**5.58%（688/12,319）**。
- 確定値：設計・実行とも未確定。分母承認・重複整理・解釈保留の解決が残ります。
- 一つ以上の対応も未登録のテスト：2,995本。全件の検証内容に基づく対応付けは未完了です。

登録済み本数は少なくとも一つの観測を対応付けた本数で、各ファイル全体の精査完了数ではありません。
レビューはAIによるもので、独立した人の確認済みではありません。
全12,319行の要求定義、従来の対応・集合証拠・判断と、以前からの未コミット変更を保持しました。

## 採用した観測と集合証拠

[test_assoc_array_iterate.sv](../tests/ch7/test_assoc_array_iterate.sv) は、string keyのforward/reverseを走査し、
forwardでは全keyと値も表示します。期待出力全体との比較で、回数だけでは分からない順序・lookupを確認できます。
[test_associative_array_corner.sv](../tests/ch7/test_associative_array_corner.sv) のintegral keyの全順・値と合わせ、
一般のlookup・値の保持・key順を分担する集合証拠にしました。

[test_assoc_array_methods.sv](../tests/ch7/test_assoc_array_methods.sv) は、existsをint変数へ受け、
presentの1とmissingの0を明示比較します。Booleanだけで判定する多くの専用テストより強い観測です。
[test_assoc_class_null_and_alias_keys.sv](../tests/ch7/test_assoc_class_null_and_alias_keys.sv) では、
null key、base/derived object、aliasによる同一entryの上書きを区別します。

[test_assoc_array_iter_minimal.sv](../tests/ch7/test_assoc_array_iter_minimal.sv) は、最後のkey cからnextを呼び、
戻り値0とkeyがcのままの両方を検査します。失敗statusだけのテストとは分けて採用しました。

今回、12要求行に集合証拠を設定し、累計44行になりました。

- 一般のlookup/orderとentry保持/orderの2行：string/integralの全順・値を含む共通メンバーと、各テストのlookup・更新保持。
- num/sizeの2行：非空の絶対個数とempty時の0。
- read/modify/write初期化：type defaultとuser-specified default。
- first/lastの2行：通常のstatus1と、narrow引数の切り詰め/status-1。
- nextのstrict successorと成功時更新の2行：存在するinput、未存在input、narrow例外。
- narrow traversal：first/last/next/prevの4メソッド。
- defaultがmethodへ影響しない規則：missing read後の走査・個数とcopy/exists。
- literal mapping：index:value/defaultによる全置換と、個別entry書込み。

グループ内はAND、グループ間はORです。全メンバーが同じ実行回で成功した場合だけ、行全体を実行確認へ数えます。

## 引用修正と再実行

次の7本は`:lrm:`だけを変更しました。刺激・期待値・oracle・ランナーは変更していません。

- `ch7/test_assoc_array_methods.sv`：実際に呼ぶ個別節7.9.1–7.9.7を追加。
- `ch7/test_assoc_array_edge.sv`：size/numの7.9.1を追加。
- `ch7/test_assoc_next.sv`：lastの7.9.5から、実際に使うfirst/nextの7.9.4/7.9.6へ訂正。
- `ch7/test_assoc_prev.sv`：nextの7.9.6から、実際に使うlast/prevの7.9.5/7.9.7へ訂正。
- `ch7/test_assoc_narrow_prev_next_overflow.sv`：7.9.8にnext/prevの7.9.6/7.9.7を追加。
- `ch7/test_assoc_allocate_on_write.sv`：割当規則の親本文7.8を追加。
- `ch6/test_edge_assoc_array_keys.sv`：wildcardの7.8.1からstring indexの7.8.2へ訂正。

修正後の入力と集合メンバーを含む40本を、両ランナーでコンパイル・実行判定しました。

- [Verilator 5.052の結果](../coverage/results/associative-matching-20261023-verilator.json)：**37 pass、3 known**。
- [Icarus 13.0の結果](../coverage/results/associative-matching-20261023-icarus13.json)：**0 pass、40 known**。コンパイル未対応等を含みます。

Verilatorの3 knownは、default付き連想配列elementをref actualにする構文と、narrow traversal引数の未対応です。
knownは成功へ換算していません。新規22行のうち次の6行は、必要な集合のパス結果の記録が不足するため設計対応だけです。

- 7.8.7 INITIALIZE-BEFORE-READ-MODIFY。
- 7.9.4／7.9.5 INDEX-RESULT。
- 7.9.6 STRICT-SUCCESSOR／SUCCESS-UPDATE。
- 7.9.8 NARROW-INDEX-TRUNCATION。

40本の部分実行で、保存済み全3,912本のスナップショットを上書きしていません。
全3,923本の一括再実行と扱わず、異なる実行回の部分成功を集合証拠へ合成していません。
既存のnarrow next/prevの2件の対応は維持し、引用変更後の入力hashへ更新しました。

## M44：実際の操作と引用節のずれ

nextをlastの節、prevをnextの節、string indexをwildcardの節へ対応させる引用があり、上記のとおり修正しました。
親の7.9だけを引用するファイルも多く、個別の7.9.xに有効な観測があっても、自動的に対応承認にはしていません。
今回は強い観測を持つ一部を具体化し、残りは引用具体化を含む残件にしました。

引用を直しただけでも、未観測の条件が埋まるわけではありません。
next/prevの単純な専用テストは、戻り値や失敗後のkeyが不足するため、今回まだ対応登録していません。

## M45：Boolean判定・固定表示では戻り値1を確認できない

`if (aa.exists(key))`では、誤った2や-1もtrueです。
「=1」と固定文字列を表示しても、methodが実際に1を返した証拠にはなりません。
missingの0だけを検査するケースも、presentの正確な1は補えません。

first/lastにも同じ問題があり、keyが正しく更新されてもstatusをBooleanとしてしか見ないテストは保留しました。
通常の1とnarrow時の-1を観測する集合に分けています。
int変数へ代入するだけではmethod式自体の型・幅も測れないため、signatureの行は別途保留です。

## M46：走査の終端status・key保持・未存在inputを区別する

[test_assoc_next_2.sv](../tests/ch7/test_assoc_next_2.sv) は、終端でresult==0を確認しますが、失敗後のkeyを見ません。
失敗時にkeyを壊す実装も通るので、key cを同時に検査するiter_minimalを採用しました。
prevの専用テストにも、終端statusだけでkeyを確認しないケースがあります。

inputが必ず存在するkeyのテストだけでは、未存在inputからの探索を確認できません。
未存在0から600を選ぶnarrowテストを設計根拠へ採用しましたが、実行はknownなので、
通常のstatus1だけの成功を行全体の成功へ昇格していません。

## M47：ref actualによる呼出時点の確保が見えない

[test_assoc_allocate_on_write.sv](../tests/ch7/test_assoc_allocate_on_write.sv) の
`set_to(hits["new"],42)`は、calleeが直ちにref formalへ書き込みます。
callee entryでnum/existsを観測しないので、ref actualとして渡す時点で確保せず、最初の書込みで遅延確保する実装との差が出ません。
書込みをしないref渡しや、callee entryでの存在確認が必要です。

[test_assoc_allocate_on_write_types.sv](../tests/ch7/test_assoc_allocate_on_write_types.sv) の`set(a,12,9)`は、
missing elementではなく連想配列全体をrefで渡します。callee内のm[k]=vは通常のassignment targetへの確保です。
これをmissing elementのref渡しの証拠とはしていません。

read/modify/writeの既定値は、user default10から15となる結果と、type/struct defaultからの結果を集合にしました。
前者がknownのため、後者だけの成功で全体を実行済みとはしていません。

## M48：値とwarningの有無は別の観測

invalid indexの書込みが無視されること、missing readが既定値を返すことには有効なstdout観測があります。
ただし必要なwarningの発生や、user default時のwarning不発生は検査していません。
stderrへ余計なwarningを出す／必要なwarningを出さない実装も同じstdoutを作れます。

delete(missing-key)を呼んでいても、size0やexists falseだけでは「warningを出さない」を確認できません。
warningを含む要求行は保留し、delete()による全削除などの独立した観測だけを採用しました。

## M49：キーの規格上正しい例だけでは変換・正規化・順序は確認できない

wildcardにintとstring literalを入れてsize2とするだけでは、leading zeroを除く正規化や、
等幅bit vectorとのalias、signed値のunsigned扱いは確認できません。
7.8.1を引用しながらwildcard自体を使わないファイルもあります。

負keyへのlookupも、そのkeyを含む順序を調べなければsigned順の証拠にはなりません。
既存の-3/0/2の専用観測は保持しましたが、unsignedの上位bitとの対照を含む広い行は保留しました。
class keyの順は任意なので、object id/addressの順を期待せず、同じkey集合での反復走査を比較する必要があります。

struct keyのforeachでcountとsumだけを見るケースも、順序や同一実行中の安定性を確認しません。
empty/nullを含む複合keyの刺激も別途必要です。

## M50：値コピーと全entryコピー、再帰的なdeep copyを区別する

[test_assoc_array_edge_cases_3.sv](../tests/ch7/test_assoc_array_edge_cases_3.sv) の「deep copy」はint elementの独立性の観測です。
class handle elementのreferentまで複製する意味にはしていません。

全体代入の専用テストにも、old key消失・size・一つのcopy先の値を検査しながら、
もう一方のsource entryの値をcopy先で読まないケースがあります。
個数だけ合わせて一方の値を失う誤実装を検出できないので、CLEAR-AND-COPY行全体は保留しました。
既存のreplace-not-merge/value-copyの個別観測は維持しています。
一方、input formalをdelete/置換してもcallerが変わらない値渡しの観測は、対応する別要求へ追加しました。

## M51：走査回数・未使用宣言からの推定を避ける

走査回数だけでは別順や重複訪問を検出できません。
cornerテストのforward側はkey/valueも表示するため期待全文で順を確認できますが、reverse側はcountだけです。
実際の表示と分岐を確認し、観測できた方向に限定しました。

wildcard配列を宣言するだけのファイルから任意幅keyの動作を推定していません。
nested existsをbitへ変換して返す関数も、元methodの正確なint戻り値まで観測したとはしていません。

## 記録と検査

[判断台帳](../coverage/test-matching-reviews.json)へ40本・65件を追記しました。累計312本・419件です。
判断件数は全ファイルのレビュー完了数でも、カバレッジの加算対象でもありません。
開始時との比較で、全要求定義・既存の対応・集合証拠・判断の保持を確認しました。
7本の変更が`:lrm:`だけであることも確認し、catalog・stats・depth・集計を再生成しました。

管理ツールの単体テスト74件、本文出典・coverage・matching・catalog・stats・depth・generatorの整合性検査はすべて成功しました。
metadataは新規問題0件、既知378件です。`git diff --check`も成功しました。
