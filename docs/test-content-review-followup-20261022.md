# 修正後の再レビュー（2026-10-22）

> 以下は記載した対象コミットに対するレビュー結果です。
> 後続の修正と残件は[Nightly由来の修正](nightly-suite-corrections-20261027.md)、[テスト側の修正](test-side-fixes-20261028.md)を参照してください。

## 結果

対象: `5859a575f0801c0a658a8851b37c2619f648ce02`。
修正コミット`5c1104e`を、前回レビュー対象の`c118d54`と比較した。

**前回F01〜F11で指摘した誤りへの修正を確認した。F12は部分的な解消で、
以下の3点が残る。** テスト本体には変更を加えていない。

一次資料は前回同様、指定されたIEEE Std 1800-2023のPDFと抽出テキスト。
この再レビューは修正差分と関連箇所が対象で、全3,801件の手作業レビューや
両シミュレータの全件実行を再度行ったものではない。

## 残る指摘

### R01: clocking出力の駆動前観測を削除したため、output skewを検証できなくなった

対象:

- [test_program_clocking_output.sv:26](../tests/ch24/test_program_clocking_output.sv#L26)
- [test_program_clocking_default_skew.sv:30](../tests/ch24/test_program_clocking_default_skew.sv#L30)

受け側の初期化を除いたことで、前回F03の禁止された駆動方式の混在は解消した。
一方、初期値を駆動元で与える代わりに、駆動前の`q`の観測を削除している。
どちらも最初に`q`を見るのが時刻8になり、時刻5のclocking eventから
output skew #2を経て時刻7に駆動されたことを確認できない。

**再現:** それぞれのソースを一時コピーし、`output #2 q`を`output #0 q`、
または`default input #1 output #2`を`default input #1 output #0`に置換した。
元の期待出力を変更せずVerilator 5.052の既存ランナーで実行すると、**両方とも合格**した。
出力遅延を無視する実装でも、これらのテストは合格してしまう。

根拠: **14.3、14.16** のoutput skewの動作。両テストのdescriptionもこの遅延を
検証対象としている。default skewのテストには入力サンプリングの検証は残っているが、
出力の遅延の検証は残っていない。

**修正案:** program側の出力変数を規格上正しい方法で0に初期化し、
時刻6では0、時刻8では1という観測を復元する。
受け側の変数の宣言時初期化は復元しない。
駆動元の初期化を避けるなら、観測開始前に既知の出力値を作る別の刺激を用意する。

### R02: coverageが利用できない適合ケースを、不合格にしてしまう

対象: [test_coverage_definition_control.sv:91](../tests/ch40/test_coverage_definition_control.sv#L91)、同94行。

修正後は`start_u1 == SV_COV_OK && max_u1 > 0`などを必須にしている。
しかし **40.3.2.1、Table 40-1（p.1158）** は、STARTがNOCOVまたはPARTIALを
返す場合を規定している。**40.3.2.2、40.3.2.3** も、coverageが利用できない場合の
照会結果0を認めている。これらはERRORとは異なる。
このテストにはtoggle coverageを有効にしてから実行するための前提指定がなく、
ソース23〜25行の説明でもcoverageがない処理系を許すとしている。

**再現:** 一時コピーでSTOP/RESETをOK、STARTをNOCOV、全照会を0に置換した。
これはTable 40-1と照会APIの許容する「coverageなし」の戻り値の組合せである。
Icarus 13.0で残りの刺激と判定を実行すると、最初の2行は1、
最後の2行は **0** になり、期待出力と一致しなかった。

**修正案:** CHECKやSTARTの戻り値で利用可能性を判定し、
NOCOV/PARTIALをERRORと区別する。収集可能な構成では実際の変化を必須にし、
収集できない構成では動作検証を未実施として区別する。
常にtoggle coverageを必須にする設計なら、その有効化と実行前提を
ランナーに定義し、ソースの説明も合わせる必要がある。

### R03: u2のcoverage照会が常にERRORでも、依然として全判定が合格する

対象: [test_coverage_definition_control.sv:63](../tests/ch40/test_coverage_definition_control.sv#L63)、
同69・81・94行。

操作の戻り値をOKと比較する修正により、前回の「全APIがERRORでも合格」は解消した。
しかし照会値がERRORでないことを検査していないため、u2の前後比較には
`-1 == -1`による偽陽性が残る。

**再現:** 一時コピーでcontrolをすべてOK、get_maxを8にし、
u1の6回の照会を順に`1, 0, 0, 0, 0, 1`、u2の全照会を
`SV_COV_ERROR`（-1）に置き換えた。
Icarus 13.0で実行すると、**元の期待出力4行がすべて1のまま一致**した。
u2についてはcoverage値を一度も正しく取得できていないのに、
「resetでu2は変わらない」「定義のstop中は両方変わらない」
「u1のstart後もu2は停止したまま」が合格になる。

根拠: **40.3.2.2、40.3.2.3** では-1は数値として比較できるcoverage値ではなく、
照会エラーを示す。R02のNOCOV/PARTIALとは別の扱いが必要。

**修正案:** 比較前に全照会のエラー値を検査する。
特にc2/c2_after、u2_before/u2_after、x2_before/x2_afterの
両方が有効な値であることを前提にしてから不変性を検査する。
start_all/stop_allの戻り値も取得するだけでなく確認する。

## 前回指摘の対応確認

- F01: part-selectへのprocedural assignをch10の負例へ移動。
  25行の拒否要求とpyslangの診断位置が一致する。
- F02: export元で必要な名前を明示的にimport。両シミュレータで一致。
- F03: output接続先の初期化を除去。禁止された混在は解消。ただしR01の検出力低下あり。
- F04: programに観測時刻より長く生存するinitialを追加。
- F05: 予約語beforeをvalue_beforeに変更。
- F06: expectに明示クロックを追加。clockなしの診断は解消。
- F07: fast_okの復帰を51へ移動し、42の失敗と整合。
  軽微な点として、末尾の`#20 $finish`のコメントは60のままだが実際の終了時刻は71。
- F08: 9個のCファイルで、次のvpi_get_str呼出しより先に文字列をコピー。
  module bindingの共有バッファ再現も期待する3行すべて1になった。
- F09: sv_wait_levelをautomaticに変更。
- F10: setup notifierの報告時刻を10へ変更。
- F11: recrem/removalのイベント順とSDF注釈対象、期待値を修正。
- F12: controlの全ERRORに対する偽陽性は解消。R02・R03が残る。

## 確認結果と限界

- 修正されたオラクル対象を実行: **Icarus 13.0は3/3、Verilator 5.052は6/6一致**。
- suite_stats、生成テスト、suite_catalog、coverage_depthの各checkは成功。
- メタデータ検査: **3,801件、新規0、既知378、解消0**。
- 変更されたSV 15件をpyslang 12.0.0で解析。
  負例の期待する診断を確認。checker package contextの既知のclock推論診断は、
  前回同様、この解析器の診断だけを理由に指摘していない。
- C全208ファイルの構文検査はエラー0、既存の未使用変数警告1件。
- R01〜R03の再現は一時コピーで行い、リポジトリのテストは変更していない。
- 規格のみをオラクルとする高度なchecker、coverage API、SDF timing check等は、
  修正後も既存2シミュレータによる独立した実行確認ができたことを意味しない。
