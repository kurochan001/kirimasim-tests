# 履歴

[English](history.md) / [README](../README.ja.md)

[README](../README.ja.md)には現時点の情報だけを載せます。以前の作業の記録、以前の測定、
当時の確認結果はここへ移しました。ここにある数値はそれぞれの日付の時点の値で、現在の値ではありません。
現在の値はREADMEと、生成した集計（[要求カバレッジ集計](behavior-coverage-summary.md)、
[条項別テスト数レポート](coverage-depth.md)、[テストカタログ](tests/README.md)）を参照してください。

## 2026-10-21

- [拡充前の棚卸し](inventory-20261021.md)に、2026-10-21の拡充作業の前の内容・計画と、
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
- シミュレーション速度：READMEの表にある2026-10-25の測定では、kirimasimは最初の4設計で、
  同日の先の測定の`8a8607690aa6`より1.08〜1.14倍の時間がかかりました。
  kirimasim側では`b17234e420b6`による変化としています。

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

- `tools/run_ghost.py`も、他のシミュレーションランナーと同じく`:type: formal`のテストを除くようにしました
  （Issue #22）。それまでのGhostの結果は、formalの268本を不一致として含みます。
  ランナーの指紋が変わったため、`coverage/results/`に保存していた以前のGhostの結果は
  要求カバレッジの実行確認に使われなくなりました。
- テストの修正（Issue #22〜#28、#36〜#39）の前の要求カバレッジ（2026-10-30時点）は、
  テスト設計が89.33%（10,986/12,298）、実行確認率が59.60%（7,330/12,298）、
  Icarus Verilog・Verilator・SymbiYosysだけで51.00%（6,272/12,298）、
  1〜40章のテスト設計が87.40%（8,272/9,465）でした。
