<a id="history"></a>

# 履歴

[English](history.md) / [README](../README.ja.md)

[README](../README.ja.md)には現時点の情報だけを載せます。以前の作業の記録、以前の測定、
当時の確認結果はここへ移しました。ここにある数値はそれぞれの日付の時点の値で、現在の値ではありません。
現在の値はREADMEと、生成した集計（[要求カバレッジ集計](behavior-coverage-summary.md)、
[条項別テスト数レポート](coverage-depth.ja.md)、[テストカタログ](tests/README.ja.md)）を参照してください。

## 2026-10-21

- [拡充前の棚卸し](inventory-20261021.ja.md)に、2026-10-21の拡充作業の前の内容・計画と、
  報告後に追加したテストを記録しています。
- kirimasimでの[監査](https://github.com/kurochan001/kirimasim/blob/main/docs/review/oracle_audit.md)は、
  このリポジトリの`c983cf7`から選んだP1対象1,466本を両リリースで実行しました。
  Verilatorでは初期値用に4種類のシードを使っています。リリース名が登録された期待出力は
  すべてそのリリースで再現でき、リリースの規格違反を期待値として記録したものは見つかりませんでした。
  実行で見つかった差異も同資料にあります。

## 2026-10-22

- [拡充](coverage-strengthening-20261022.md)では、それまでテストが1本だった187条項すべてに
  異なるケースを追加しました。

## 2026-10-23

[照合の進捗と指摘](existing-test-matching-review-20261022.md)、
[暫定の要求カバレッジ（テスト設計）20%超の照合結果](existing-test-matching-20percent-20261023.md)、
[VPIレビューと10.08%到達時の記録](existing-test-matching-vpi-20261023.md)、
[コンパイラ指令のレビュー](existing-test-matching-preprocessor-20261023.md)、
[式の不足を補う11テスト](expression-gap-tests-20261023.md)、
[連想配列の不足を補う15テスト](associative-gap-tests-20261023.md)、
[ヘッダー・VPIモデルのテストと追加照合](header-vpi-tests-and-matching-20261023.md)に
記録しています。最後の更新では、附属書I・K・L・MのCヘッダーの24テストと、37章のVPIの24テストを追加しました。

## 2026-10-24

- [要求抽出](requirement-extraction.md)では、予約キーワードの要求を
  エラーケースとして整理し直し、27件の解釈上の問題を解決しました。
- [生成キーワードテスト](keyword-tests-20261024.md)では、予約語を名前に使う不正な設計496本を追加しました。
- その後の[不足を補うテスト](gap-tests-20261024.md)では、テスト未対応の要求に
  独立検証済みの594本を追加し、[第2回](gap-tests-2-20261024.md)では933本を追加しました。
- シミュレーション速度：Icarus Verilog 13.0、Verilator 5.050、nvc 1.23.0で測定しました。
  この測定はkirimasimの生データに残っています。nvcは設計を解析できず、現在は比較から外れています。

## 2026-10-25

- [台帳未登録テストの初回照合](existing-test-matching-unregistered-20261025.md)では、
  45本を99要求に対応付けました。既存テストにないテスト刺激（スティミュラス）を補う新規6本と、
  シミュレータリポジトリのCTestスイートから取り込んだ23本を含みます。
- シミュレーション速度：[保存した2026-10-25の測定](readme-records-20261101.ja.md#シミュレーション速度)では、kirimasimは最初の4設計で、
  同日の先の測定の`8a8607690aa6`より1.08〜1.14倍の時間がかかりました。
  kirimasim側では`b17234e420b6`による変化としています。

<a id="2026-10-25-and-2026-10-26"></a>

## 2026-10-25〜26

- 照合作業の残りの範囲
  （p01・p05・p07・p09・p10・p12・p13・p15、附属書と不足分、附属書Aの文法テスト）を
  検証して統合しました。K.2・I.3・N.2のヘッダーとアルゴリズム、アサーション制御、
  カバレッジ、チェッカー、1364 VPI互換性のテストも追加しました。
  規格のみの277本についてIcarus Verilog 13.0で再現できたことを記録し、
  さらに既存テストの12範囲の照合で341要求を対応付けました。

## 2026-10-26

- SVAフォーマル検証の基本セットは40モデルでした。現在の267ケースのカタログに含まれています。

## 2026-10-27

- [Nightlyのテスト修正とoracleレビュー](nightly-suite-corrections-20261027.md)に、
  それまでのテストの修正を記録しています。

## 2026-10-28

- 要求台帳を分母としてレビューし、重複21行を統合した12,298要求を
  [分母レビュー](denominator-review-20261028.md)で承認しました。
  レビューしたのはAIで、人による独立したレビュー・承認ではありません。

## 2026-10-29

- **Nightlyの再実行：** [Check](https://github.com/kurochan001/kirimasim-tests/actions/runs/40805455107)は成功し、
  [Nightly](https://github.com/kurochan001/kirimasim-tests/actions/runs/40805499579)は
  5環境すべての実行と結果公開が成功しました。対象はスイート
  [`a594d659`](https://github.com/kurochan001/kirimasim-tests/commit/a594d659b947a7321ce5e252660ea6d376d813b3)、
  [この回の公開結果](https://github.com/kurochan001/kirimasim-tests/blob/22e410125bba56d3783dd9f8a884dac332239ec7/README.md)の
  生成時刻は12:55 JST（03:55 UTC）です。
  Lyraは[`ed9515d8eec1`](https://github.com/hankhsu1996/lyra/commit/ed9515d8eec105fdf74eecbd6abf83de268c1fe9)からビルドしました。
  期待結果に一致したテスト数／結果が記録されたテスト数は次のとおりです。
  - Icarus Verilog：**4,607 / 7,476**
  - Verilator：**4,779 / 7,476**
  - kirimasim：**5,076 / 7,476**
  - Lyra：**5,501 / 7,476**
  - Ghost：**6,095 / 7,744**

  不一致・既知の差異・未対応も分母に含みます。最初の4ランナーはformalの268本を除き、
  Ghostは全テストファイルを選びます。

## 2026-10-31

- [READMEから移した記録](readme-records-20261101.ja.md)に、この日の確認済みNightly、
  日付付きの速度測定、その後のmailbox・イベント再結合の追加と引き継ぎへの参照を残しています。

- `tools/run_ghost.py`も、他のシミュレーションランナーと同じく`:type: formal`のテストを除くようにしました
  （Issue #22）。それまでのGhostの結果は、formalの268本を不一致として含みます。
  ランナーの指紋が変わったため、`coverage/results/`に保存していた以前のGhostの結果は
  要求カバレッジの実行確認に使われなくなりました。
- テストの修正（Issue #22〜#28、#36〜#39）の前の要求カバレッジ（2026-10-30時点）は、
  テスト設計が89.33%（10,986/12,298）、実行確認率が59.60%（7,330/12,298）、
  Icarus Verilog・Verilator・SymbiYosysだけで51.00%（6,272/12,298）、
  1〜40章のテスト設計が87.40%（8,272/9,465）でした。

## 2026-11-01

- 生成レポート、テストカタログ、過去の引き継ぎ資料を含むリポジトリ内のMarkdown資料を
  日英の対で管理するようにしました。[資料一覧](README.ja.md)から両言語へ移動でき、
  章間クロスのCSVにも英語版を追加しています。
- READMEの日付付きの実行記録と手書きの生成器一覧を、現在の範囲の説明と
  [過去の記録](readme-records-20261101.ja.md)・[全生成器のカタログ](generators.ja.md)への
  参照へ整理しました。
- オフラインの翻訳辞書を追加し、両言語の生成、言語切替リンク、技術的なリテラル、
  未翻訳箇所を検査するようにしました。更新手順と翻訳の来歴は
  [保守ガイド](../tools/doc_locales/README.ja.md)を参照してください。
  テスト入力・期待値・保存済みのシミュレータ実行結果は維持しています。
- Nightlyの公開処理にも、同じ保存済み実行データから日英の結果レポート・
  カバレッジ資料・グラフを生成する経路を追加しました。

- 第10章×第35章のP1、DPI/NBAモデルを追加しました。合法144通りから18件を選び、全因子対81組・重点3因子48組・必須4件を保持します。全144行とC ABIの独立照合、4故障の検出を確認しました。固定Verilatorは両seedとも14 pass・4 knownです。最新kirimasim `1144b2acab1e`の全2,373件は2,170 pass・197 unsupported・既存6 failで、従来2,355件の結果と指紋は同じです。[モデルと保存証跡](interaction-verification.md#dpi-copyback-and-nba-capture)を参照してください。

- 第8章×第18章のP1、継承制約モデルを追加しました。合法96通りから13件を選び、全因子対70組・重点3因子40組・必須4件を保持します。全96行の独立検算、2正常対照と5故障の検出を確認しました。固定Verilatorは両seedとも全13件がPASSです。最新kirimasim `1144b2acab1e`の全2,386件は2,170 pass・210 unsupported・既存6 failで、従来2,373件の結果と指紋は同じです。[モデルと証跡](interaction-verification.md#constraint-inheritance-and-failure-retention)を参照してください。

- 第14章×第16章のP1、clocking/assertionモデルを追加しました。合法288通りから18件を選び、全因子対109組・重点3因子50組・必須4件を保持します。全288行の独立検算、2正常対照と5故障の検出を確認しました。固定Verilatorは両seedとも全18件がPASSです。最新kirimasim `1144b2acab1e`の全2,404件は2,170 pass・228 unsupported・既存6 failで、従来2,386件の結果と指紋は同じです。[モデルと証跡](interaction-verification.md#clocking-inputs-and-assertion-clocks)を参照してください。

- 第7章×第35章のP1、DPI open arrayモデルを追加しました。合法168通りから30件を選び、全因子対100組・重点3因子72組・必須4件を保持します。全168行の独立検算と、実Cヘルパーとテスト専用ABIで2種類のoutput初期値を使った照合、正常対照1件・5故障の検出を確認しました。固定Verilatorは両seedとも固定配列18件がPASS、動的配列・キュー12件は既知のビルド失敗です。最新kirimasim `f2d9a1136576`の全2,434件は2,170 pass・258 unsupported・既存6 failで、従来2,404件の記録は同じです。別途の解析では新規24件が成功し、キュー6件が型照合で拒否されました。登録済みP1候補はすべて有限モデルへ移りましたが、未精査の章対は残ります。[モデルと証跡](interaction-verification.md#dpi-open-array-shape-and-copyback)を参照してください。

- 第7章×第8章のP2、クラス配列モデルを追加しました。合法240通りから18件を選び、全因子対108組・重点3因子60組・必須4件を保持します。全240行の独立したオブジェクトグラフとの照合、正常対照2件・6故障の検出を確認しました。固定Verilatorは両seedとも全18件がPASSです。最新kirimasim `f2d9a1136576`の全2,452件は2,176 pass・270 unsupported・既存6 failで、従来2,434件の記録は同じです。新規18件の解析は成功し、固定配列6件がPASS、動的配列・キュー12件が未対応です。[モデルと証跡](interaction-verification.md#class-array-storage-and-shared-elements)を参照してください。

- 第21章×第28章のP2、強度表示モデルを追加しました。合法180通りから31件を選び、全因子対87組・重点3因子78組・必須4件を保持します。全180行の独立した駆動解決表との照合、3種類のAPIの正常対照・5故障の検出を確認しました。固定Icarus Verilog 13.0は全31件がPASSです。最新kirimasim `f2d9a1136576`の全2,483件は2,176 pass・301 unsupported・既存6 failで、従来2,452件の記録は同じです。新規31件の解析は成功し、実行は`%v`未対応です。[モデルと証跡](interaction-verification.md#resolved-strength-formatting)を参照してください。

- 第8章×第25章のP2、クラスvirtual interfaceモデルを追加しました。合法192通りから13件を選び、全因子対96組・重点3因子48組・必須4件を保持します。全192行の独立した結合グラフとの照合、正常対照3件・6故障の検出を確認しました。固定Verilatorは両seedとも全13件がPASSです。最新kirimasim `80859f34f0aa`の全2,496件は2,207 pass・283 unsupported・既存6 failです。従来2,483件の入力は同じで、強度表示31件が未対応からPASSへ改善し、ほかの2,452件の結果は同じです。新規13件の解析は成功し、実行はクラス内のvirtual interface型が未対応です。章対は93対、全選択ケースPASSは47モデルです。[モデルと証跡](interaction-verification.md#class-virtual-interface-rebinding)を参照してください。

- 第9章×第14章のP2、clocking iffモデルを追加しました。合法288通りから12件を選び、全因子対109組・重点3因子44組・必須4件を保持します。全288行の独立イベントキューとの照合、正常対照3件・6故障の検出を確認しました。固定Verilatorは両seedともスカラ条件4件がPASS、元のベクタ条件8件は内部ビルドエラーです。補助対照2件だけは明示的なリダクションORを使い、元のケースの結果と区別します。最新kirimasim `80859f34f0aa`の全2,508件は2,207 pass・295 unsupported・既存6 failで、従来2,496件の記録は同じです。新規12件の解析は成功し、実行はガード付きclocking event未対応です。[モデルと証跡](interaction-verification.md#clocking-event-guards-and-held-samples)を参照してください。

## 2026-11-02

- 第7章×第20章のP2、連想配列問い合わせモデルを18件追加しました。合法216通りから全因子対93組・重点3因子54組・必須4件を保持します。全216行の独立計算と6種類のPython仕様モデル変異の識別を確認しました。これはSVへの故障注入実行ではありません。固定Verilatorは両seedとも全18件が出力不一致、固定Icarusはビルド時に拒否し、全件をspecのまま保持します。最新kirimasim `80859f34f0aa`の全2,526件は2,207 pass・313 unsupported・既存6 failで、従来2,508件の記録は同じです。新規18件は解析成功・型付き連想配列変数未対応です。章対は95対、全選択ケースPASSは47モデルです。[モデルと証跡](interaction-verification.md#associative-array-domains-and-allocation)を参照してください。

- 第7章×第18章のP2、配列リダクション制約モデルを13件追加しました。合法192通りから全因子対96組・重点3因子40組・必須4件を保持します。全192行を独立計算し、固定配列だけの補助対照4件・7故障の出力差を確認しました。補助対照は観測用の代入だけに要素型キャストを追加し、元のケースの合格や動的配列のサイズ保持の確認へ加算しません。固定Verilatorは両seedとも元の全13件が出力不一致、固定Icarusはビルド時の拒否です。最新kirimasim `80859f34f0aa`は2,207 pass・326 unsupported・既存6 failで、従来2,526件の記録は同じです。新規13件の解析は成功し、固定8件はrandomize、動的5件はクラス内配列操作が未対応です。全65モデル・2,539件・96章対、全選択ケースPASSは47モデルです。[設計と証跡](interaction-verification.md#array-reduction-constraints-and-retention)を参照してください。

- Checkの固定回帰を維持し、Nightlyへ3プロファイル・既定96ケースのモデルベースのランダム比較を追加しました。seedと実際の刺激、SV・期待値・出力、コミット・コード指紋を専用artifactへ保存し、1ケースから再現できます。最新照合ビルド`866abf4d86d1`で448サンプルと保存刺激の1ケース再現がPASSし、正常終了する誤演算子を出力差で検出しました。固定Icarus 13.0の12サンプルも一致しました。これらを固定スイートの本数・章間合格数・要求カバレッジへ加算せず、CI上での実行成功とも分けて記録します。[使い方と確認範囲](random-cross-verification.md)を参照してください。

## 2026-11-03

- 固定suiteは10,672件、うち88生成器による生成ケースは4,235件になりました。有限クロスは79モデル・2,922選択ケース・114章対です。
  仕分けはM114 / E3 / C2 / N117 / R584です。[不一致対応](cross-verification-followup.md)に、insideと承認済みラベル取消しの修正、
  変更していない期待値、当初の11→9→4 failの履歴を保持します。上流`a682e19e`では2,389 pass・529 unsupported・
  configのパラメータリセットの4 failで、全選択ケースPASSは52モデルです。
- 件数制限付きのランダム比較を13プロファイルへ拡張し、旧プロファイルの明示選択時の再現性と、既定の合計96件を維持しました。
  保存証跡を保持するreplay、任意の同一完了ジョブの投入管理、参照変更の差分記録、同じ刺激の他シミュレータ比較も維持します。
  [ランダム検証ガイド](random-cross-verification.md)に、範囲・保存manifest・コードとビルドの識別・固定回帰への引継ぎをまとめています。
  配列リダクションの参照モデルの確認で単一要素のZの扱いを修正し、元の試行で失敗した5件と別途のreplayを保持しました。
- プロファイル追加を区切り、4プロファイルを各3シード・各32ベクトル／操作で深く探索しました。
  [ローカル1,152 PASS](../coverage/interaction-qualification/random-stabilization-20261103.json)のうち、配列・packageの864件を独立解釈しています。
  残るパック書込み288件は既存の実行・参照比較です。ローカルのツール回帰901件と整合性13項目は全PASSでした。
  新しい差異は見つからず、固定回帰の追加はありません。
- suite `e8d991a9`の[Check 41649940180](https://github.com/kurochan001/kirimasim-tests/actions/runs/41649940180)と
  [Nightly 41650010801](https://github.com/kurochan001/kirimasim-tests/actions/runs/41650010801)が成功し、Nightlyの5シミュレータと公開処理も成功しました。
  結果は日本時間2026-11-04に照合しました。正式kirimasim `d73d8922dfa2`で有限クロス全2,922件の入力・状態分類が一致し、
  別枠のランダム比較もseed `41650010801`で96件すべて有効なPASSです。
  固定suite全体の結果、ビルドのハッシュ、変更されない公開スナップショットは[日時付きの確認記録](nightly-results.md#previous-verified-checkpoint)を参照してください。
  ランダム結果は固定件数・カバレッジへ加算しません。

## 2026-11-04

- suite `9926160a`の[Check 41718590448](https://github.com/kurochan001/kirimasim-tests/actions/runs/41718590448)と
  [Nightly 41743702063](https://github.com/kurochan001/kirimasim-tests/actions/runs/41743702063)が成功し、Nightlyの5シミュレータと公開処理も成功しました。
  レポートの生成は03:25 UTC（日本時間12:25）です。
- kirimasim `9113955914d8`の固定suiteは7,868 pass・2,403 unsupported・133 failです。
  第30章の通常のspecify条件テスト5件がunsupportedからPASSへ改善し、その他の状態分類と全10,404件の入力ハッシュは不変です。
  この5件は有限クロスの選択外で、選択2,922件の入力・状態分類は2,389 pass・529 unsupported・4 failのままです。
  対応付けは79モデル・114章対、全選択ケースPASSは52モデルで、章間CSVの出典も保存済みcross79のままです。
- 13プロファイルのランダム比較は新しいseed／run ID `41743702063`で96件すべて実際に実行し、別途再ビルドした本体
  `9113955914d878437074f0e3b86a8dca38438080`で有効なPASSでした。この実行の保存SVから配列14件・package 8件を独立検算しています。
  [新しい確認記録](../coverage/interaction-qualification/formal-ci-9926160a-20261104.json)にartifact・ビルドのハッシュと固定状態の観測を保持し、前回の記録は変更していません。
  文書更新時の照合は保存証跡の読取りであり、シミュレータの再実行やカバレッジの追加ではありません。

- 未精査だった第8章×第26章へ[クラスメソッド×package参照モデル](interaction-verification.md#class-method-package-lookup)を追加しました。
  合法3,264通りから全因子対244組・重点3因子110組・必須6件を保持する34件を選択しています。
  全行の独立解釈が一致し、ネイティブの正常対照4件・実際のSVへの8故障は正常終了し、全故障を出力差で検出しました。
  最新mainのkirimasim `9113955914d8`による全2,956件の単一実行で追加34件は全PASS、従来2,922件の入力・状態分類は不変です。
  合計80モデル・115章対・全選択ケースPASS 53モデル、仕分けはM115 / E3 / C2 / N117 / R583です。
  固定Verilatorのseed 1/73は各18 pass・16 known、固定Icarusは全34件のビルドを拒否します。
  4値を必要とせずVerilatorの両seedに一致した18件だけに、そのoracleを登録しています。
  suiteは10,706件、うち89生成器による生成テストは4,269件です。新規の重点確認15件を含むツール回帰916件が全PASSでした。
  本体は変更せず、新しいケースを正式CI・ランダムプロファイル・要求の対応付けとは分けて扱います。
