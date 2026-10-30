# kirimasim-tests

[English](README.md)

[![Check](https://github.com/kurochan001/kirimasim-tests/actions/workflows/check.yml/badge.svg)](https://github.com/kurochan001/kirimasim-tests/actions/workflows/check.yml)
[![Nightly](https://github.com/kurochan001/kirimasim-tests/actions/workflows/nightly.yml/badge.svg)](https://github.com/kurochan001/kirimasim-tests/actions/workflows/nightly.yml)
[![License: Apache-2.0 WITH LLVM-exception](https://img.shields.io/badge/license-Apache--2.0%20WITH%20LLVM--exception-blue)](LICENSE)

IEEE 1800-2023 SystemVerilogのシミュレーションの意味論を確認する適合性テストスイートです。

用語やよくある質問は、[用語集](docs/glossary.md)と[FAQ](docs/faq.md)を参照してください。
期待値、結果の分類、Nightly、網羅率、SVA・フォーマル検証について説明しています。

各シミュレーションテストは、期待結果を持つ小さな独立した設計です。規格上正しいコードは、正規化した標準出力が
期待出力に一致し、指定された終了コード・診断の検査にも通れば合格です。
不正な設計は、必要な診断を出して拒否されれば合格です
（[合否の判定方法](#合否の判定方法)を参照）。
このスイートは[kirimasim](https://github.com/kurochan001/kirimasim)向けに作っています。
Icarus Verilog、Verilator、kirimasim、
[Lyra](https://github.com/hankhsu1996/lyra)用の実行スクリプトがあります。
当面は公開前のゲスト**Ghost**も仮名で参加します。メタデータは
[sv-tests](https://github.com/chipsalliance/sv-tests)の形式に従っています。

通常のシミュレーションの期待値は、シミュレータに依存しない規格の規則に基づきます。
実装依存の形式を確認するテストでは前提を明記します。
[FST波形テスト](docs/fst-tests-20261029.md)はkirimasimの予定するFSTバックエンド向けで、
すべてのシミュレータにFST形式を要求するものではありません。

このスイートには、次の特徴があります。

- **すべてのテストが規格の条項を示します。** `:lrm:`に確認対象のIEEE 1800-2023の
  条項番号を記録し、テスト冒頭のコメントで何を確かめるかを自分たちの言葉で説明します。
- **期待出力の根拠を記録します。** `:oracle:`には、規格との照合と、どのシミュレータで
  再現できたかを記録します。可能な場合はIcarus Verilog 13.0で確認し、コンパイルできない、
  または規格と異なる場合はVerilator 5.052で確認します。どちらも規格どおりに動かない場合は、
  規格から期待出力を決めます。
- **規格が定める結果だけを出力します。** 規格が決めていないイベント順、乱数そのもの、
  既定の時間単位、シミュレータの診断文の正確な言い回しには依存しません。

> **開発の初期段階です。** すべてのテストをAIモデルが規格と照合していますが、
> 人による照合はまだありません（`:spec_check: ai`）。期待値の誤りの報告を歓迎します。

## 収録内容

<!-- suite-stats:begin -->
スイートには38章にわたり**9049本のテスト**があります。 うち2613本は自動生成です（`tests/gen/`。「自動生成テスト」を参照）：`combination_aggregates`が18本、`combination_events`が9本、`combination_io`が13本、`combination_monitors`が18本、`combination_nba`が16本、`interaction_array`が36本、`interaction_case`が36本、`interaction_cast`が32本、`interaction_compare`が100本、`interaction_compound`が40本、`interaction_concat`が72本、`interaction_cond`が32本、`interaction_divide`が72本、`interaction_edge`が64本、`interaction_expr`が51本、`interaction_index`が44本、`interaction_logic`が70本、`interaction_method`が72本、`interaction_nba`が36本、`interaction_port`が36本、`interaction_query`が60本、`interaction_queue`が48本、`interaction_resize`が38本、`interaction_select`が36本、`interaction_shift`が56本、`interaction_shortcircuit`が92本、`interaction_stream`が36本、`interaction_struct`が36本、`interaction_task`が36本、`keywords`が496本、`scheduling`が325本、`strength`が136本、`wide_paths`が49本、`width_sign`が144本、`xz_propagation`が158本。

| 期待結果の確認元 | テスト数 |
| --- | ---: |
| Icarus Verilog 13.0（`:oracle:`に`iverilog@13.0`） | 5170 |
| Verilator 5.052（Icarus Verilog 13.0のoracle登録なし） | 1585 |
| 規格のみ（固定リリースのシミュレータのoracle登録なし） | 2294 |

1721本はx/z値に依存します（`:fourstate: yes`）。618本にはCコードがあり、内訳はDPIが123本（`:dpi_c:`）、VPIが495本（`:vpi_c:`）です。1932本はシミュレータが拒否すべき不正な設計です（`:should_fail_because:`）。35本はシミュレーションの終了コードを確認します（`:expected_exit:`）。実行条件の指定は、複数ソースファイル23本（`:files:`）、マクロ定義4本（`:defines:`）、インクルードディレクトリ指定7本（`:incdirs:`）、トップレベルのモジュールまたは構成指定39本（`:top_module:`）、実行時引数13本（`:args:`）です。すべてのテストをAIモデルが規格と照合しました（`:spec_check: ai`）。人による照合はまだありません。

| 章 | 題名 | テスト数 | Icarus | Verilator | 規格のみ |
| ---: | --- | ---: | ---: | ---: | ---: |
| 3 | 設計と検証の構成要素 | 88 | 66 | 12 | 10 |
| 4 | スケジューリングの意味論 | 412 | 391 | 5 | 16 |
| 5 | 字句規則 | 346 | 325 | 14 | 7 |
| 6 | データ型 | 645 | 396 | 144 | 105 |
| 7 | 集合データ型 | 712 | 291 | 262 | 159 |
| 8 | クラス | 321 | 67 | 182 | 72 |
| 9 | プロセス | 284 | 217 | 38 | 29 |
| 10 | 代入文 | 254 | 169 | 45 | 40 |
| 11 | 演算子と式 | 1551 | 1262 | 119 | 170 |
| 12 | 手続き型プログラミング文 | 217 | 169 | 29 | 19 |
| 13 | タスクと関数（サブルーチン） | 244 | 137 | 89 | 18 |
| 14 | クロッキングブロック | 78 | 4 | 61 | 13 |
| 15 | プロセス間の同期と通信 | 59 | 2 | 36 | 21 |
| 16 | アサーション | 661 | 104 | 75 | 482 |
| 17 | チェッカー | 81 |  | 22 | 59 |
| 18 | 制約付き乱数値の生成 | 200 | 26 | 95 | 79 |
| 19 | 機能カバレッジ | 157 | 2 | 29 | 126 |
| 20 | ユーティリティ用システムタスク・関数 | 330 | 239 | 26 | 65 |
| 21 | 入出力用システムタスク・関数 | 236 | 145 | 15 | 76 |
| 22 | コンパイラ指令 | 358 | 335 | 13 | 10 |
| 23 | モジュールと階層 | 292 | 177 | 45 | 70 |
| 24 | プログラム | 43 | 21 | 5 | 17 |
| 25 | インターフェース | 119 | 31 | 57 | 31 |
| 26 | パッケージ | 83 | 53 | 16 | 14 |
| 27 | generate構文 | 103 | 93 | 8 | 2 |
| 28 | ゲートレベル・スイッチレベルのモデリング | 245 | 194 | 3 | 48 |
| 29 | ユーザー定義プリミティブ | 81 | 58 | 11 | 12 |
| 30 | specifyブロック | 60 | 35 | 1 | 24 |
| 31 | タイミング検査 | 66 | 17 | 1 | 48 |
| 32 | 標準遅延形式によるバックアノテーション | 50 | 16 |  | 34 |
| 33 | 設計内容の構成指定 | 43 | 12 | 9 | 22 |
| 34 | 保護エンベロープ | 4 | 2 | 2 |  |
| 35 | 直接プログラミングインターフェース（DPI） | 131 | 5 | 84 | 42 |
| 36 | プログラミング言語インターフェース（PLI/VPI）の概要 | 89 | 34 | 19 | 36 |
| 37 | VPIオブジェクトモデル図 | 227 | 18 | 1 | 208 |
| 38 | VPIルーチンの定義 | 109 | 56 | 9 | 44 |
| 39 | アサーションAPI | 39 |  | 1 | 38 |
| 40 | コードカバレッジの制御とAPI | 31 | 1 | 2 | 28 |
<!-- suite-stats:end -->

総数には`:type: formal`の268本を含みます。これらはシミュレータの標準出力を比較せず、
`:formal_case:`を使ってSymbiYosysで検査します。[実行方法](#symbiyosys)を参照してください。

SVAの追加検証は、上のoracle別の件数とは別に記録しています。
参照評価器は**45本のテスト出力**を再現しました。2026-10-29の再実行では、現行の全267ケースについて
**267件のBMC、44件のPDR証明、267件のcover**が成功し、意図的な誤り5件も反例を生成しました。
2026-10-26の基本40モデルは、この現行カタログに含まれます。
別の境界値の組合せ検査では、**111ケースすべてでBMC・PDRが成功**し、
28本のテストの91指令に含まれる**127個のシーケンス部分式**と対応付けています。
二つのセットには重複があるので、異なるモデルの数として足し合わせません。
267・111というモデル数を収録済みのテスト本数へ別途加算したり、上の表のoracle分類を変更したりはしません。
この2セットの保存済み証跡は2026-10-29に再生成し、現行ソースとの対応と必要ジョブの整合性検査も成功しました。実行・証跡の整合性検査の手順は下記ガイドを参照してください。
範囲・証跡・再実行方法は、[SVA参照評価器とフォーマル検証](docs/sva-reference-formal-verification.md)と
[境界値の拡張結果](docs/sva-formal-expansion-20261026.md)を参照してください。

[テストカタログ](docs/tests/README.md)は、各テストが何を確かめ、どの条項を引用するかを
章ごとに示します。[条項一覧](docs/tests/clauses.md)では、各章のどの条項をテストが引用しているかを
確認できます。[条項別テスト数レポート](docs/coverage-depth.md)は、条項ごとのテスト数と、
規格のみから決めた期待出力を持つ1本のテストしかない条項を示します。
3〜40章の対象範囲内の末端条項には、それぞれ2本以上の直接引用するテストがあります。
対象外の条項とその理由も同じページに記載しています（`tools/clauses.txt`のタグ）：
一般的な説明、34章、ツールに委ねられた動作、VCDファイルの内容です。
ただしVCDのうち、`test_vcd_dump_readback`が読み返す部分
（21.7.2.1〜21.7.2.3、21.7.5）は対象に含めています。

これは条項の引用網羅率であり、IEEE 1800-2023のすべての要求や組合せを検査した証明ではありません。
条項別テスト数の範囲は`tools/clauses.txt`が選ぶ3〜40章の末端条項で、現在の件数と除外理由は
[条項別テスト数レポート](docs/coverage-depth.md)に記載しています。
附属書や明示的な除外条項を、規格全体を網羅したという主張に暗黙に含めることはしません。
[2026-10-22の拡充](docs/coverage-strengthening-20261022.md)では、それまでテストが1本だった
187条項すべてに異なるケースを追加しました。CIは
`tools/coverage_depth.py --check --minimum-tests 2`で2本以上を必須にします。
親条項の引用だけでは、その子条項の本数を満たしません。

[要求カバレッジの要約](docs/behavior-coverage-summary.md)と
[詳細レポート](docs/behavior-coverage.md)では、明示的にレビューした要求と、
テストで観測する結果を測定します。[台帳と作業手順](coverage/README.md)は、
1〜41章と附属書A〜Qを、親条項の導入や従来の対象外部分も含めて棚卸しします。
原文レビューは全1,740節を対象にしています。暫定率の分母には、解釈を保留している行や
テスト未対応の行も含め、登録済みの要求・条件・観測の全行を使います。
規格要求カバレッジの確定値には、解釈と重複する要求単位を整理して承認した分母を使います。
要求カバレッジ（テスト設計）、実行証拠、シミュレータ別の結果、原文レビューの進捗は分けて報告します。
CIは台帳と生成した要約を検査します。Nightlyは、率、残件、シミュレータ別の結果、
分母の識別情報を`results`ブランチに記録します。
既存テストは、入力と期待される観測を要求に対応付けた後にのみ計上します。
要約には、少なくとも一つレビュー済みの対応があるテストファイル数も示します。
未対応のテストが、まだ計上していない要求を検査している可能性はあります。
未対応の要求に新しいテストを書く前に、既存テストを確認してください。
[既存テストの要求照合一覧](docs/test-requirement-matching.md)に、章ごとの進捗と、
候補の全作業リスト・内容の指摘へのリンクがあります。
複数テストを一組の証拠とする場合は、同じシミュレータの同じ実行スナップショットで
すべて合格する必要があります。別々の実行の部分的な成功を合わせて要求の成功にはしません。

[機能間クロス検証](docs/interaction-verification.md)は、制約付きの2因子網羅を基本に、
指定した3因子群と必須の境界ケースを併用します。短時間実行用の1,300件は、
スケジューリング、NBA、演算コンテキスト、パック配列の部分選択、条件演算、シフト、
キャスト、タスク引数、パック構造体、case、ポート接続、アンパック配列のコピー、
ビットベクタの集計・判定関数、ストリーミング演算、比較演算、配列リダクション、
可変ビット選択、キュー操作と容量制限、除算・剰余のコンテキスト、動的配列の
サイズ変更、連結した左辺への代入、パックベクタの論理・リダクション演算、
短絡評価と副作用、イベント式のエッジ判定、キュー・動的配列のファイル監視と登録元の
記述位置、複合シフト代入と左辺選択の26モデルを対象にします。複合シフト代入は
7,560通りから40件を選び、全因子対308組・3因子90組・必須ケース4件を保持します。
ファイル監視のモデルは36通りから18件を選び、
全因子対40組と必須ケース3件を保持します。短絡評価とエッジ判定の2モデルは、
制約を満たす6,184通りから156件を選びます。
通常の全件実行では既存テストをすべて保持します。[クロス検証レポート](docs/interaction-coverage.md)は
計画上の網羅と、入力ハッシュが一致した実行の合格を分けて集計します。規格要求の分母は変更しません。
設計思想、モデルの選び方、追加・再実行手順、他プロジェクトやLSIへの適用方法は、
[機能間クロス検証の考え方と実践手順](docs/interaction-verification-method.md)にまとめています。

[Issue #21の回帰取り込みレポート](docs/p1-combination-regressions-20261030.md)と
[確認済みの照合台帳](coverage/combination-gaps.json)には、既存テストの再利用と、
新規74件（イベント9件、NBA16件、複合型18件、I/O13件、ファイル監視18件）を記載しています。
このうち有限のクロスモデルへ登録するのはファイル監視の18件です。残る56件は機構の境界条件を
確認する回帰テストとして扱い、t-wayの達成率へ混ぜません。規格解釈の保留、
別のネイティブAPI試験で確認する範囲、保存した実行ごとの結果もレポートから確認できます。
`python3 tools/combination_gaps.py --check`で台帳とレポートの整合性を、
`python3 tools/combination_gaps.py --list-tests`で再利用分を含む回帰対象の全パスを確認します。
この整合性検査は、シミュレータの全件合格を要求するものではありません。

[規格PDFからテストに至る方法](docs/requirements-to-tests-method.md)は、要求の抽出、
既存テストとの照合と追加テストの作成、独立したレビュー、統合と測定までを順に説明します。
作業には[照合キット](tools/matching_kit/README.md)を使います。

2026-10-23の更新は、[照合の進捗と指摘](docs/existing-test-matching-review-20261022.md)、
[暫定の要求カバレッジ（テスト設計）20%超の照合結果](docs/existing-test-matching-20percent-20261023.md)、
[VPIレビューと10.08%到達時の記録](docs/existing-test-matching-vpi-20261023.md)、
[コンパイラ指令のレビュー](docs/existing-test-matching-preprocessor-20261023.md)、
[式の不足を補う11テスト](docs/expression-gap-tests-20261023.md)、
[連想配列の不足を補う15テスト](docs/associative-gap-tests-20261023.md)、
[ヘッダー・VPIモデルのテストと追加照合](docs/header-vpi-tests-and-matching-20261023.md)に
記録しています。最後の更新では、附属書I・K・L・MのCヘッダーの24テストと、37章のVPIの24テストを追加しました。
2026-10-24の[要求抽出](docs/requirement-extraction.md)では、予約キーワードの要求を
エラーケースとして整理し直し、27件の解釈上の問題を解決しました。
[生成キーワードテスト](docs/keyword-tests-20261024.md)では、予約語を名前に使う不正な設計496本を追加しました。
その後の[不足を補うテスト](docs/gap-tests-20261024.md)では、テスト未対応の要求に
独立検証済みの594本を追加し、[第2回](docs/gap-tests-2-20261024.md)では933本を追加しました。
2026-10-25の[台帳未登録テストの初回照合](docs/existing-test-matching-unregistered-20261025.md)では、
45本を99要求に対応付けました。既存テストにないテスト刺激（スティミュラス）を補う新規6本と、
シミュレータリポジトリのCTestスイートから取り込んだ23本を含みます。
2026-10-25〜26には、その作業の残りの範囲
（p01・p05・p07・p09・p10・p12・p13・p15、附属書と不足分、附属書Aの文法テスト）を
検証して統合しました。K.2・I.3・N.2のヘッダーとアルゴリズム、アサーション制御、
カバレッジ、チェッカー、1364 VPI互換性のテストも追加しました。
規格のみの277本についてIcarus Verilog 13.0で再現できたことを記録し、
さらに既存テストの12範囲の照合で341要求を対応付けました。
2026-10-28に要求台帳を分母としてレビューし、重複21行を統合した12,298要求を
[分母レビュー](docs/denominator-review-20261028.md)で承認しました。
レビューしたのはAIで、人による独立したレビュー・承認ではありません。
2026-10-29時点の要求カバレッジ（テスト設計）は**89.33%（10,986/12,298）**、
`coverage/results/`の保存済み証跡による実行確認率は
**59.60%（7,330/12,298）**です。
Icarus Verilog・Verilator・SymbiYosysだけで数えると実行確認率は51.00%（6,272/12,298）です。
測定入力と分母は[生成した要求カバレッジ集計](docs/behavior-coverage-summary.md)、
以前の修正は[Nightlyのテスト修正とoracleレビュー](docs/nightly-suite-corrections-20261027.md)を参照してください。
1〜40章だけの要求カバレッジ（テスト設計）は87.40%（8,272/9,465）です。
既存テスト全体の検証内容のレビューはまだ完了していません。
追加報告には、観測、規格から決めた期待値、シミュレータとの差、意図的な誤りを入れる検査、
実行証拠を記録しています。

テストの配置先は、`:lrm:`の先頭の条項が属するIEEE 1800-2023の章に対応するディレクトリです。
表のIcarus・Verilator・規格のみの列は、最初の表と同じく、期待結果の確認元別の件数です。
1・2章には検査対象の動作がありません。34章（保護エンベロープ）のテストは、
エンベロープの構文と、Verilatorがdata_blockをソースから外すことを確かめる4本だけです。
Icarus VerilogもVerilatorもエンベロープを復号しないためで、監査当時の理由は
[保護エンベロープの境界](docs/protected-envelope-boundary.md)にあります。
分母レビュー後は34章の214要求中209要求が未対応です。設計のどこにコードカバレッジを持つかは
ツールとオプションに依存するので、40章のテストは、許される値やカバレッジ関数の結果同士の
関係など、すべての結果に共通して成り立つことだけを出力します。

## Nightlyの結果

<!-- workflow-verification:begin -->
**2026-10-29の再実行：** [Check](https://github.com/kurochan001/kirimasim-tests/actions/runs/40805455107)は成功し、[Nightly](https://github.com/kurochan001/kirimasim-tests/actions/runs/40805499579)は
5環境すべての実行と結果公開が成功しました。対象はスイート[`a594d659`](https://github.com/kurochan001/kirimasim-tests/commit/a594d659b947a7321ce5e252660ea6d376d813b3)、
[この回の公開結果](https://github.com/kurochan001/kirimasim-tests/blob/22e410125bba56d3783dd9f8a884dac332239ec7/README.md)の生成時刻は12:55 JST（03:55 UTC）です。
Lyraは[`ed9515d8eec1`](https://github.com/hankhsu1996/lyra/commit/ed9515d8eec105fdf74eecbd6abf83de268c1fe9)からビルドしました。
期待結果に一致したテスト数／結果が記録されたテスト数は次のとおりです。

- Icarus Verilog：**4,607 / 7,476**
- Verilator：**4,779 / 7,476**
- kirimasim：**5,076 / 7,476**
- Lyra：**5,501 / 7,476**
- Ghost：**6,095 / 7,744**

不一致・既知の差異・未対応も分母に含みます。最初の4ランナーはformalの268本を除き、
Ghostは全テストファイルを選びます。SymbiYosysの検証結果は上記の別集計です。
<!-- workflow-verification:end -->

毎晩、[GitHub Actionsワークフロー](.github/workflows/nightly.yml)が、各シミュレータで
`main`の各ランナーの対象テストを実行します。Icarus VerilogとVerilatorは`master`、kirimasimは`main`の
最新開発版を使います。Lyraもジョブ開始時に`main`先端のコミットを取得し、
同じコミットのビルドだけをキャッシュから再利用します。
Ghostは非公開のビルドで参加します。
結果は[`results`](https://github.com/kurochan001/kirimasim-tests/tree/results)ブランチの履歴に追加します。
下のグラフは実行ごとに更新します。
[同ブランチのレポート](https://github.com/kurochan001/kirimasim-tests/tree/results#readme)には、
一致率、章別の結果、シミュレータごとの推移、前夜から結果が変わったテストも載せています。

**Ghost**は、公開前の正体不明なシミュレータです。毎晩のテストに姿を現し、
今は結果だけを残していきます。正体・ソース・ビルドログは、まだ幕の向こう側です。
他の参加者と同じテストを、同じ規格に基づく期待結果で判定します。

開始予定は毎日**日本時間04:23（JST、UTC+09:00）**、UTCでは前日の19:23です。
結果はシミュレータのジョブが終わってから公開します。GitHubのスケジュール遅延やビルド時間で、
更新が数時間遅れることがあります。結果レポートの`Latest run`と`Recent runs`は**UTC**で、
ワークフローの開始時刻ではなくレポートを生成した時刻です。日本時間にするには9時間を足します。
実際の開始時刻と待機中の実行は[GitHub Actions](https://github.com/kurochan001/kirimasim-tests/actions/workflows/nightly.yml)で確認できます。
詳細は[更新時刻とレポートの版について](docs/nightly-results.md)を参照してください。

グラフが示すのは、レポートに記載されたスイートのコミットとテスト数での結果です。
`main`にテストを追加するとカタログと集計は変わりますが、Nightlyの結果は、そのコミットを
後続のワークフローが実行して公開するまで変わりません。現在のスイートと比較するときは、
`suite commit`とテスト数を確認してください。

![期待結果に一致するテスト数](https://raw.githubusercontent.com/kurochan001/kirimasim-tests/results/charts/overview.svg?v=nightly-40805499579)

シミュレータごとに、Icarus Verilogは丸、Verilatorは四角、kirimasimはひし形、
Lyraは下向き三角、Ghostはオレンジの上向き三角を使います。
一致数が同じ、または近い場合も見えるように、マーカーは互いに重ねて収まる輪郭で描きます。
凡例には、最新の実行の件数も示します。

### 章別の結果

各セルは**一致したテスト数 / 結果が記録されたテスト数**と、その章・シミュレータの一致率です。
既知の差異と未対応のテストは、実行前にスキップしたものも含めて分母に残します。
表はNightlyのグラフとともに更新し、上部に日付とシミュレータの版を表示します。
クリックすると原寸の画像を開けます。

[![章別の一致テスト数](https://raw.githubusercontent.com/kurochan001/kirimasim-tests/results/charts/chapters.svg?v=nightly-40805499579)](https://raw.githubusercontent.com/kurochan001/kirimasim-tests/results/charts/chapters.svg?v=nightly-40805499579)

### 結果の分類

各テストの結果は、次のいずれかになります。

| 結果 | 意味 |
| --- | --- |
| match（一致） | 出力と、指定された終了コード・実行時診断の検査が一致した、または不正な設計が必要な診断付きで拒否された |
| differ（不一致） | 結果が一致しない、必要な診断がない、不正な設計が受理された、または他の分類に当たらないビルド・実行の失敗 |
| known difference（既知の差異） | IcarusまたはVerilatorで一致せず、その固定リリースのoracleトークンもない。または、kirimasimで使える共通・専用の期待出力がなく、他ツール専用の期待出力だけがある |
| unsupported（未対応） | 使用した構文などが未対応と診断された、またはその種類のテストを実行できない。kirimasimはDPI/VPI、LyraはVPIのCコードをまだ読み込めない |

Icarus VerilogとVerilatorのNightlyでのdifferは、固定リリースのoracleが付いたテストが、
選択した開発版で一致しない場合です。oracleのないテストが一致するようになった場合は、
拒否の理由も含めてレビューする候補になります。結果だけで修正を認定したり、oracleを追加したりはしません。

Nightlyでは結果を報告し、不一致だけでは原則としてワークフローを失敗にしません。
例外はkirimasimで、前夜に一致したテストが今回は不一致になったときにジョブを失敗させます
（後述の「ワークフロー」のratchet）。新規テストや未対応のテストでは失敗させません。
Icarus Verilog 13.0とVerilator 5.052で記録した期待結果は、テストやツールの変更時に
[別のワークフロー](.github/workflows/check.yml)で同じリリースを使って確認します。

## シミュレーション速度

このスイートが確かめるのは計算結果です。速度の参考として、kirimasimリポジトリには
独自の小さな設計による[ベンチマーク](https://github.com/kurochan001/kirimasim/tree/main/bench)があります。
2026-10-25にWSL2上のLinux（AMD Ryzen 9 7950X）で行った実行では、
各シミュレータの最新開発コミットと11設計を使い、次の時間になりました。
最初の4列は、示す回数での5回の中央値から、`+n=1`での5回の中央値を引いた値です。
Ghost列は同じマシンで2026-10-28に測ったもので、フル実行は非常に長いため、
注記のとおり外挿しています。

| 設計 | `+n=` | kirimasim | Icarus Verilog 14.0 devel | Verilator 5.053 devel | Lyra（LLVMバックエンド） | Ghost* |
| --- | :---: | :---: | :---: | :---: | :---: | :---: |
| `comb_chain` | 3,000,000 | 9.249 s | 9.796 s | 0.223 s | 2.878 s | 1,153 s* |
| `nba_shift` | 1,000,000 | 25.486 s | 26.585 s | 0.196 s | 5.900 s | 2,707 s* |
| `proc_wait` | 1,000,000 | 6.786 s | 5.688 s | 2.283 s | 6.164 s | 1,816 s* |
| `fork_join` | 4,000,000 | 4.837 s | 5.023 s | 1.190 s | 4.860 s | 909 s* |
| `wide_arith` | 1,500,000 | 4.944 s | 2.036 s | 0.086 s | 0.380 s | 131.4 s |
| `mem_rw` | 4,000,000 | 4.937 s | 3.645 s | 0.696 s | 2.705 s | 1,258 s* |
| `func_call` | 1,500,000 | 4.917 s | 7.511 s | 0.005 s | 0.395 s | 291 s* |
| `string_fmt` | 500,000 | 5.003 s | 8.080 s | 0.135 s | 0.279 s | 477 s* |
| `dyn_queue` | 4,000,000 | 4.112 s | 6.686 s | 0.083 s | 0.412 s | 400 s* |
| `gate_udp` | 400,000 | 5.378 s | 3.517 s | 0.046 s | 未対応 | 835 s* |
| `casez_struct` | 5,000,000 | 3.976 s | 4.117 s | 0.018 s | 0.466 s | 525 s* |

`*` `wide_arith` はフルカウント、それ以外は縮小カウントからの外挿値です。

- kirimasimは`b66834254c65`、Icarus Verilogは14.0 develの`2b8d42dc088f`、
  Verilatorは5.053 develの`1838b6ed035c`、Lyraは`63922502ff0a`です。
  Lyraは`bazel build -c opt`でビルドしました。ベンチマークはこれらのコミットでの測定で、
  Nightlyは毎回上流の最新コミットを取得します。Lyra列はLLVMバックエンド、`-O 0`での測定です。
  当該測定では`--backend`省略時にC++バックエンドを使用し、この設計群ではLLVMより3.3〜67倍遅くなりました。
  その時間も下記のベンチマーク詳細にあります。測定できたすべての実行で結果は期待どおりでした。
  LyraはゲートとUDPが未対応なので、`gate_udp`の実行プログラムは生成していません。
  時間には設計のビルド（VerilatorのC++、Lyraのプログラム）は含めません。
- Ghostは`a2420294`で、同じWSL2/Ryzen 9 7950X上で2026-10-28に測定しました。
  フルカウントの1回は2〜45分かかるため、Ghost列の大部分は、示す回数より小さい2つの
  カウント（2つ目は1つ目の2倍。10,000/20,000、2,000/4,000、1,000/2,000）で3回ずつ測り、
  2倍で1.97〜2.09倍になることを確認して、傾きをフルカウントへ適用した外挿値です。
  `wide_arith`のフルカウント（131.4 s）は外挿値と約2%以内で一致し、結果行も確認しました。
  他の列は2026-10-25の中央値です。
- Ghostはこれらの設計でkirimasimより27〜268倍遅く（最小は`wide_arith`、最大は`proc_wait`）、
  Icarus Verilogより39〜345倍遅い結果です。Releaseビルドの既定実行オプションによるもので、
  機能差ではなく性能差を示します。
- 最初の4設計は、`always_comb`の連鎖、ノンブロッキング代入、待機プロセス、`fork`/`join`を使います。
  残り7設計は、256ビット演算（`wide_arith`）、1024ワードメモリ（`mem_rw`）、
  タスク・再帰関数呼び出し（`func_call`）、`$sformatf`（`string_fmt`）、
  キュー・動的配列（`dyn_queue`）、ゲート・UDP（`gate_udp`）、
  パック構造体への`casez`（`casez_struct`）です。
- kirimasimはIcarus Verilogに比べ、`proc_wait`、`wide_arith`（2.4倍）、`mem_rw`、`gate_udp`で遅く、
  `func_call`、`string_fmt`、`dyn_queue`で明確に速く、残り4設計では約6%以内でした。
  `dyn_queue`ではピークメモリが回数とともに増えます（4,000,000回で547 MiB）。
- 最初の4設計では、同日の先の測定の`8a8607690aa6`より1.08〜1.14倍の時間がかかりました。
  kirimasim側では`b17234e420b6`による変化としています。
  2026-10-24のIcarus Verilog 13.0、Verilator 5.050、nvc 1.23.0の測定も生データに残しています。
  nvcは設計を解析できず、現在は比較から外れています。
- 1台のマシンの小さな設計は、実際の設計の速度を代表しません。ビルド時間、起動時間、メモリ、
  再現コマンドは[kirimasimのベンチマーク詳細](https://github.com/kurochan001/kirimasim/blob/main/docs/BENCHMARKS.md#development-versions-on-linux-wsl2-2026-10-25)を参照してください。

## ディレクトリ構成

```text
tests/chNN/<name>.sv            メタデータ付きのテスト
tests/chNN/<name>.expected      期待する標準出力
tests/chNN/<name>.c             DPIまたはVPIテストのCコード
tests/chNN/<other>.sv, .svh     :files:で指定するソース・インクルードファイル
tests/chNN/<dir>/               :incdirs:で指定するインクルードディレクトリ
tests/gen/chNN/<name>.sv        自動生成テスト（直接編集しない）
generators/<generator>.py       テスト生成器と参照モデル
generators/generate.py          tests/gen/の生成、--checkによる検査
generators/oracles.txt          各生成テストの期待出力を再現したリリース
docs/simulator-differences.md   Icarus Verilog 13.0・Verilator 5.052と規格との差
docs/inventory-20261021.md      2026-10-21の拡充前の内容・計画・報告後の追加テスト
docs/tests/                     章ごとのテストカタログ
docs/tests/clauses.md           テストが引用する規格の条項
docs/glossary.md               このスイートの用語・略語
docs/faq.md                    期待値・結果・網羅率・検証のFAQ
docs/coverage-depth.md          条項ごとの本数と優先して補う不足
docs/behavior-coverage-summary.md 章別・シミュレータ別の要求カバレッジの集計
docs/interaction-verification.md 機能間クロスのモデル・短時間実行・証跡の扱い
docs/interaction-coverage.md     登録したクロスモデルの計画と実行確認
docs/p1-combination-regressions-20261030.md Issue #21の境界条件と実行証跡
coverage/combination-gaps.json   Issue #21の候補と回帰テストの確認済み対応
docs/requirements-to-tests-method.md 規格PDFから要求・テスト・網羅率に至る方法
coverage/behavior-summary.json  現在の要求カバレッジの集計結果と分母の識別情報
coverage/behavior-history.json  分母の識別情報を含む測定履歴
tools/run_icarus.py             Icarus Verilogでの実行
tools/run_verilator.py          Verilatorでの実行
tools/run_kirimasim.py          kirimasimでの実行
tools/run_lyra.py               Lyraでの実行
tools/run_ghost.py              公開前のゲストを仮名で実行
tools/normalize_output.py       比較前の出力正規化
tools/suite_results.py          実行結果のJSON形式（--json）
tools/results_history.py        Nightlyの履歴とグラフ生成
tools/results_ratchet.py        前回一致して今回不一致のテストの一覧
tools/suite_stats.py            テスト集計と両言語のREADMEの表の更新
tools/suite_catalog.py          docs/tests/のカタログ生成
tools/coverage_depth.py         docs/coverage-depth.mdの生成
tools/interaction_coverage.py   クロス検証の実行対象選択と充足の集計
tools/combination_gaps.py       Issue #21の回帰対象一覧と台帳・レポートの整合性検査
tools/clauses.txt               docs/tests/clauses.md用の条項番号
tools/lint_metadata.py          メタデータとテストの形式の検査
tools/lint_baseline.txt         既存テストの既知の問題
tools/new_test.py               新規テストのひな型生成
tools/matching_kit/             要求とテストの対応の提案・検査・判定・統合
.github/workflows/check.yml     固定リリースでの期待結果の検査
.github/workflows/nightly.yml   Nightly実行
```

`results`ブランチには、`history.json`（1実行1エントリ）、
`latest/<simulator>.json`（各シミュレータの最新の全テスト結果）、`charts/*.svg`、
レポートの`README.md`があります。グラフとレポートには`tools/`に実行スクリプトがある
シミュレータだけを表示します。実行スクリプトがなくなったものも履歴には残しますが、描画しません。
publishジョブは、その実行の要求カバレッジとして`behavior-coverage-summary.md`、
`behavior-coverage.md`、`behavior-summary.json`、`behavior-coverage.json`、`behavior-history.json`も
書き出します。機能間クロスのシミュレータ別の実行確認は`interaction-coverage.md`と
`interaction-coverage.json`に書き出します。`main`の保存済み証跡との違いは
[Nightlyの説明](docs/nightly-results.md)を参照してください。
通常はNightlyのpublishジョブが更新します。ローカル結果を取り込む場合も、
実行日時・スイートのコミットと`--source local`を指定して履歴へ追加します。

## テストの形式

一つのテストは一つのSystemVerilogファイルです。一部は隣にCコード、別のソース、
インクルードファイルも持ちます（`:dpi_c:`、`:vpi_c:`、`:files:`、`:incdirs:`）。
冒頭のメタデータコメント、何を確認するかの説明コメント、設計本体の順に書きます。
次は説明用の例で、スイート内のテストではありません。

```systemverilog
/*
:name: test_nonblocking_swap
:description: two nonblocking assignments that read each other's target exchange their values
:tags: ch10
:type: simulation
:lrm: 1800-2023 10.4.2
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_nonblocking_swap.expected
*/
// IEEE 1800-2023 §10.4.2: the right-hand sides of nonblocking assignments are
// evaluated before any of their targets is updated, so a <= b and b <= a
// exchange the values of a and b.

module test_nonblocking_swap;
  int a = 1, b = 2;

  initial begin
    a <= b;
    b <= a;
    #1 $display("a=%0d b=%0d", a, b);
  end
endmodule
```

`test_nonblocking_swap.expected`には`a=2 b=1`の1行を置きます。

### メタデータ

メタデータコメントはsv-testsと互換で、sv-testsが知らないフィールドは無視されます。

| フィールド | 意味 |
| --- | --- |
| `:name:` | スイート内で一意のテスト名。ファイル名と同じ |
| `:description:` | テストが確認すること |
| `:tags:` | ディレクトリの`chNN`。`:lrm:`の先頭条項の章 |
| `:type:` | シミュレーションは`simulation`、拒否すべき不正な設計は`elaboration`、SymbiYosysによるモデル検査は`formal` |
| `:formal_case:` | `:type: formal`の検証対象。`tools/sva_reference/formal_cases.py`のケース名を指定し、`tools/run_sby.py`で検査する。期待する標準出力は不要 |
| `:lrm:` | 確認対象のIEEE 1800-2023の条項。例：`1800-2023 11.4.3` |
| `:oracle:` | 期待出力の根拠。`spec`は引用条項と照合済み（担当は`:spec_check:`）、`iverilog@13.0`はIcarus Verilog 13.0で再現、`verilator@5.052`はVerilator 5.052で再現 |
| `:spec_check:` | `spec`の期待値を規格と照合した担当。`ai`はAIモデル（人による照合はまだなし）、`human`は人 |
| `:fourstate:` | x/zに依存するか（`yes` / `no`）。x/zリテラル、`$isunknown`、`casex`/`casez`、三状態・強度構文、期待出力のx/zなど |
| `:nondeterministic:` | 規格が決めていない実行順に結果が依存し得るか |
| `:expected_stdout:` | 期待する標準出力、または隣のファイルを示す`@<file>`。シミュレータ別のフィールドがない場合の共通の期待値 |
| `:expected_stdout_<simulator>:` | シミュレータ別の期待する標準出力。`<simulator>`は`icarus`、`verilator`、`kirimasim`、`lyra`。`:expected_stdout:`より優先し、`:expected_stdout:`は他のシミュレータ用の共通値として残せる。差分が規格に由来する場合（規格がツールに委ねた表示形式など）だけ追加し、理由をテストのコメントに書く。参照する全期待値ファイルは入力ハッシュに含めるので、どれを変えても保存済みの実行証跡は無効になる |
| `:dpi_c:` | 隣のCコード`@<file>`。DPIインポートを実装し、エクスポートを呼び出す（35章） |
| `:vpi_c:` | 隣のVPIアプリケーション`@<file>`。`vlog_startup_routines`からシステムタスク・関数とコールバックを登録する（36〜40章） |
| `:should_fail_because:` | 不正な設計である理由。シミュレータは拒否する必要がある。`:type: elaboration`とし、期待出力（`:expected_stdout:`またはシミュレータ別フィールド）は置かず、`:expected_stderr_regex:`でエラー箇所を指定する |
| `:expected_exit:` | 終了コード。`0`、`nonzero`（0より大きい）、または数値。規格は`$fatal`がエラーコードで終了することだけを定めるので、`nonzero`を使う（20.10） |
| `:expected_stderr_regex:` | 実行スクリプトが渡す診断テキストに対するPython正規表現（後述の「合否の判定方法」）。不正な設計では、レビューした位置（例：`test_x\.sv:12:`）と必要な診断の概念をエラー行が満たす必要がある。妥当な別位置も許容できるが、未対応構文の診断は意図した違反の証拠にしない。他のテストでは実行時のメッセージがパターンを満たすことを確認する。診断全文の言い回しは固定しない |
| `:args:` | 空白区切りの実行時引数。例：`+count=3` |
| `:generator:` | `<generator>@<version>`。`generators/<generator>.py`が生成したテスト |
| `:interaction_model:` | `<model>@<version>`。生成したクロステストが属するモデル |
| `:interaction_values:` | モデルの`因子=値`の組。集計時は生成器と実行結果の入力ハッシュも検査する |
| `:files:` | 隣の追加ソース（`.sv`、`.v`。指定順にテストより先にコンパイル）とインクルードファイル（そのディレクトリを検索先に追加）。名前は`test_`で始めない。コンパイル単位が一つか複数かはツールに委ね、テストは依存しない（3.12.1） |
| `:defines:` | 最初のソースより前に定義するマクロ。空白区切りの`NAME`または`NAME=VALUE`。ツールの`-D`や`+define+`を使い、`` `ifdef ``やマクロ参照から`` `define ``と同様に見えるようにする（22.5.1）。オプション自体は規格の範囲外 |
| `:incdirs:` | テストのディレクトリを基準としたインクルードディレクトリ。空白区切り。`` `include "<file>" ``が作業ディレクトリの後に探す場所（22.4）。`:files:`のインクルードファイルのディレクトリより後に渡す |
| `:top_module:` | エラボレーション対象のトップレベルモジュールまたは構成。未指定なら、他からインスタンス化されないすべてのモジュールがトップレベル（23.3.1）。モジュールはその階層、構成は宣言した設計とバインド規則を選ぶ（33.4、33.5.3） |

### 合否の判定方法

標準出力から空行とシミュレータ自身のバナーを取り除き、期待出力と完全一致すれば合格です
（`tools/normalize_output.py`と各実行スクリプト）。空でない行の空白は保持します。
`$info`・`$warning`・`$error`・`$fatal`のメッセージは、形式がツールに委ねられ（20.10）、
Icarus VerilogとVerilatorが標準出力に出すため、取り除きます。
終了コードや実行時のメッセージは、`:expected_exit:`や`:expected_stderr_regex:`で
要求された場合だけ確認します。実行時診断の正規表現は、Icarus・Verilator・Lyraでは
除去前の標準出力と標準エラーの両方、kirimasimでは標準エラーだけを対象にします。
連想配列の診断テストは、正規化後の出力が一致していても、警告の欠落や余計な警告を検出できます。
警告の重大度を示す印を使い、全文の言い回しやソース位置を固定しません。
[追加報告](docs/associative-gap-tests-20261023.md)を参照してください。

不正な設計（`:should_fail_because:`）は、指定した箇所のエラーで拒否されれば合格し、
受理されたり別の箇所でエラーが出たりすると不合格です。kirimasimで未対応の構文などに
よるエラーの場合は、他のテストと同じく未対応に分類します。

時間単位や精度に結果が依存するテスト（`%t`の非ゼロ時刻、`$timeformat`、`$printtimescale`、
小数の遅延、単位付き遅延）は、最初の設計要素より前に`` `timescale ``を置きます。
既定の時間単位・精度は実装依存です（IEEE 1800-2023 3.14.2.3）。

ファイル入出力（21.3〜21.5）と、読み込むSDFファイルを自分で書くSDFアノテーション（32章）の
テストは、作業ディレクトリにテスト名由来のファイルを作ります。`$coverage_save`（40.3.2.5）も
同じ場所にデータを保存できます。各実行スクリプトは、テストごとに一時ディレクトリで実行します。

### Cコードを伴うテスト

`:dpi_c:`や`:vpi_c:`を持つテストは、SystemVerilogと同名のCファイルが一組です。
Cコードがインクルードするのは標準の`svdpi.h`（附属書I）、`vpi_user.h`（附属書K）、
`sv_vpi_user.h`（附属書M）とCライブラリのヘッダーだけです。定義を`extern "C"`で囲み、
CとしてもC++としてもコンパイルできるようにします（VerilatorはC++としてコンパイルします）。
`extern "C"`の開始・終了は`#ifdef __cplusplus`で囲み、C++の場合だけ有効にします。
可能なら結果をSystemVerilogに返して`$display`で出力します。C側から出力するときは
`vpi_printf`、または`printf`の後に`fflush(stdout)`を使います。
VPIが登録するシステムタスク・関数は、組み込みの上書きテストを除き、`$vt_...`という名前にします。
sv-testsの実行スクリプトはこれらのフィールドを知らず、SystemVerilogだけをコンパイルするため、
こうしたテストはsv-testsでは失敗します。

### 期待出力の決め方

まず引用条項から期待出力を決め、その後にIcarus Verilog 13.0で実行します。

1. Icarus Verilogが期待出力を再現すれば、`:oracle:`の`spec`に`iverilog@13.0`を加えます。
2. コンパイルできない、または規格どおりでない場合は、Verilator 5.052で初期値用の乱数シードを
   2種類変えて実行します。両方で再現すれば`verilator@5.052`を記録します。
   Verilatorは2値シミュレータなので、そのテストは`:fourstate: no`です。
   両リリースで実行し、両方で再現できた場合は両方を記録します。
3. どちらも規格どおりに動かない場合は`:oracle: spec`だけとし、規格の要求をコメントに書きます。

1本のテストは、`:expected_stdout_icarus:`・`:expected_stdout_verilator:`・
`:expected_stdout_kirimasim:`・`:expected_stdout_lyra:`でシミュレータ別の期待出力を持てます。
シミュレータ別のキーは`:expected_stdout:`より優先し、共通キーは残りのシミュレータの
期待値になります。追加してよいのは、両方の出力が規格に適合し、`%p`の空白のように
規格がツールに委ねた形式だけが異なる場合です。理由はテストのコメントに書きます。
これらのキーが参照する全期待値ファイルは入力ハッシュに含まれ、別のシミュレータが使う
ファイルを変えた場合も保存済みの実行結果は無効になります。

不正な設計では、指定箇所のエラーで拒否されることが期待結果です。
`:oracle:`の`iverilog@13.0`や`verilator@5.052`は、そのリリースがそこで拒否したことを表します。
未対応構文など別の理由で拒否するツールは数えません。そのエラーが指定行に出る場合は
実行スクリプトでは区別できないので、テストのコメントにその事情を記載します。
`tools/run_icarus.py`が`NOW MATCHES`と表示しても、`iverilog@13.0`を登録しているとは限りません。

シミュレータと期待出力が異なる場合に、出力をコピーして解決することはしません。判断基準は条項です。
見つかったIcarus Verilog 13.0・Verilator 5.052と規格との差は
[差異一覧](docs/simulator-differences.md)に記録しています。

kirimasimでの[監査](https://github.com/kurochan001/kirimasim/blob/main/docs/review/oracle_audit.md)
（2026-10-21）は、このリポジトリの`c983cf7`から選んだP1対象1,466本を両リリースで実行しました。
Verilatorでは初期値用に4種類のシードを使っています。リリース名が登録された期待出力は
すべてそのリリースで再現でき、リリースの規格違反を期待値として記録したものは見つかりませんでした。
実行で見つかった差異も同資料にあります。

### SVAの独立確認とフォーマルモデル

[SVA参照評価器](tools/sva_reference/README.md)は、サンプル済みの入力トレースから、
選択した45本のテスト出力を独立に再現します。任意で実行するYosys/SymbiYosysの検査は、
入力を固定せず、別に書いたRTLモデルと計算規則を比較します。
2026-10-29の現行カタログの再実行は267件のBMCと、入力長の上限を置かない44件のPDR証明に成功しました。
後続の[境界値の拡張](docs/sva-formal-expansion-20261026.md)は全111ケースでBMC・PDRに成功し、
28本のテストの127個のシーケンス部分式と対応付けています。セット同士には重複があります。
対応付けが対象とするのは0／1のシーケンス計算で、アサーション全体やシミュレータの動作ではありません。
両セットは到達例と、意図的な誤りに対する反例も含みます。
oracleメタデータやシミュレータ実行確認率は変更しません。
[日本語ガイド](docs/sva-reference-formal-verification.md)に範囲・結果・再実行方法、
[技術報告](tools/sva_reference/FORMAL_REVIEW.md)に保存済み証跡へのリンクがあります。

### 自動生成テスト

`tests/gen/`は`generators/`の生成器が作ります。各生成器には、シミュレータを使わず
規格からPythonで書いた参照モデルがあり、期待出力を計算して、一つの種類の小さな変形を多数作ります。

| 生成器 | 章 | 変えるもの |
| --- | ---: | --- |
| `scheduling` | 4 | 書き込み（ブロッキング・ノンブロッキング・代入内遅延付きノンブロッキング・継続代入経由・`force`）、読み取り（同一プロセス・待機中の別プロセス・`$strobe`・`$monitor`）、場所（initial・always・タスク・関数・fork分岐・インターフェース・generateブロック）、遅延（なし・`#0`・`#1`）。規格が結果を決める組合せだけ |
| `interaction_nba` | 10 | 幅（1・32・33・64・65・129）、bit/logic、既知値/X/Z、スカラ/固定長アンパック配列、添字方向、initial/automaticタスク、遅延なし/遅延付きNBAの制約付き2因子網羅。指定した3因子群と境界ケースも保持し、値・添字の変更とタスク復帰前にNBAの値と代入先が確定することを確認 |
| `interaction_expr` | 11 | 両オペランドの幅と符号、代入先の幅、加減乗算。選択した51件で各4組の入力を使い、コンテキストによる拡張・桁上がり・切り捨てを確認 |
| `interaction_select` | 11 | パックベクタの幅と添字方向、`+:`/`-:`、選択幅と位置、bit/logic、既知値/X/Z。選択した36件で読み書きと非選択ビットの保持を確認 |
| `interaction_cond` | 11 | 両分岐の符号、条件0/1/X/Z、既知値・X/Zの分岐パターン、代入先の幅とbit/logic。選択した32件で分岐選択・ビットごとの結合・変換を確認 |
| `interaction_shift` | 11 | 演算子・シフト量・符号、元の幅と代入先幅、既知値/X/Z、bit/logic。選択した56件で幅の拡張、境界シフト、X/Z符号の複製、未知のシフト量を確認 |
| `interaction_compound` | 11 | 幅・状態型・符号、スカラ/配列要素/部分選択、3種の複合シフト、signedな8/65ビットのシフト量をクロス。40件で左辺の1回評価、全格納先と非選択ビット、読出し時の拡張を確認 |
| `interaction_cast` | 6 | 元の符号と値、サイズ・符号・型のキャスト、キャスト幅、後続加算、代入先の状態。選択した32件で中間変換と最終変換の違いを確認 |
| `interaction_task` | 13 | 幅・状態・値、input/output/inout/ref、スカラ/配列要素の実引数、遅延なし/遅延付き復帰。選択した36件でコピーイン・コピーアウト・参照先の即時更新・隣接要素の保持を確認 |
| `interaction_struct` | 7 | メンバ順序、全体とメンバの符号、幅・状態・値、メンバ/全体の書き込み、ブロッキング/NBA。選択した36件でタグの保持、配置、独立した符号拡張を確認 |
| `interaction_case` | 12 | セレクタと項目の幅・符号、case/casez/casex、X/Zと項目パターン。選択した36件で完全一致・ワイルドカード・重複項目の優先・フォールバック分岐を確認 |
| `interaction_port` | 23 | 元の幅・符号・値、input/output、接続先幅、名前/位置指定、ANSI/非ANSI、サンプル型。選択した36件で階層を通過する値と最終サンプル変換を確認 |
| `interaction_array` | 7 | 同じ要素型の配列について、幅・符号・状態型、コピー元/先の添字方向、値、全体/スライス代入をクロス。36件で宣言順の対応、コピー後の独立性、非選択要素の保持を確認 |
| `interaction_query` | 20 | 幅・状態型・引数の形・値と位置・countbitsの制御集合をクロス。60件でビット集計、one-hot/未知値の判定、制御ビットの重複除去を確認 |
| `interaction_stream` | 11 | 幅・方向・スライス幅・タグ・pack/unpack・格納先の状態型・値をクロス。36件で端数ブロックとunpackの逆変換を確認 |
| `interaction_compare` | 11 | 両オペランドの幅・符号、10種の比較演算子、既知値/X/Zをクロス。100件で拡張、右辺だけのワイルドカード、1ビットの比較結果を広いlogic/bitへ代入する変換を確認 |
| `interaction_method` | 7 | 要素の幅・状態型・符号、固定長配列/動的配列/キュー、5種の集計、変換方法4種をクロス。72件で集計前の型変換、オーバーフロー、戻り値の拡張を確認 |
| `interaction_index` | 11 | 幅、添字範囲の始点・向き、bit/logic、インデックスの符号と値、書き込み値をクロス。44件で可変ビット選択の読み書き、無効アクセスの既定値、非選択ビットの保持を確認 |
| `interaction_queue` | 7 | 要素の幅・状態型・符号、容量、初期サイズ、6種の操作、値をクロス。48件で要素順、容量超過時の警告と破棄、空キューの既定値、コピー後の独立性を確認 |
| `interaction_divide` | 11 | 両オペランドの幅・符号、代入先の幅・状態型、除算/剰余、ゼロ/X/Zをクロス。72件で商の0方向への丸め、剰余の符号、演算前の拡張と演算後の変換を確認 |
| `interaction_resize` | 7 | 要素の幅・状態型・符号・値、変更前後のサイズ、別配列コピー/自己リサイズ/初期化式なしの再生成をクロス。38件で先頭要素の保持、型別既定値、切り詰め、コピーの独立性を確認 |
| `interaction_concat` | 11 | 連結全体と分割位置・右辺の幅、右辺と各項の符号、bit/logicの混在、ブロッキング/NBA、既知値/X/Zをクロス。72件で分割前の幅変換、各項の状態変換、値の確定、各項と連結の符号の違いを確認 |
| `interaction_logic` | 11 | 幅、入力と結果の状態型、式の形、値と位置をクロス。70件それぞれで6種のリダクションと論理否定を実行し、支配値、状態変換の順序、unsignedの1ビット結果の拡張を確認 |
| `interaction_shortcircuit` | 11 | 左右の幅・状態型・真偽値の分類、結果の状態型をクロス。92件それぞれで4種の二項論理演算を実行し、呼出し回数、独立した副作用、X/Zの真偽変換、状態変換の順序を確認 |
| `interaction_edge` | 9 | 幅・状態型、イベント式、変更位置、遷移前後の値、ブロッキング/NBAをクロス。64件それぞれで背景0/1を使い、初期設定が収束した後の3種のイベント回数を確認 |
| `combination_events` | 6, 9, 15 | 境界条件9件。自動変数のeventの寿命、戻り値・条件式で選択したevent、計算したイベント制御、`iff`、遅延トリガ、名前付きforkの終了処理を確認 |
| `combination_nba` | 10, 13 | 境界条件16件。`ref static`経由の遅延・イベント制御付きNBA、値と添字の確定、文字列の文字要素、配列スライスのコピーアウトを確認 |
| `combination_aggregates` | 6, 11, 13 | 境界条件18件。アンパック構造体の参照渡しと寿命、配列のinputコピー、ネストしたパック選択、文字列やネストした代入先へのストリーミングを確認 |
| `combination_io` | 9, 10, 21 | 境界条件13件。`$fread`の格納先とバイト順、キュー・動的配列の暗黙感度、SV内で読み戻したVCDの内容を確認 |
| `combination_monitors` | 21 | `heap_file_monitor_context@1`の18件。登録元の記述位置×キュー/動的配列×MCD/FDをクロスし、ファイルの読み戻しでPostponedの最終値、選択添字、サイズ、コンテナ置換、`$monitoroff`との非干渉、close後の出力停止を確認 |
| `width_sign` | 11 | 63〜1000ビットの符号付き・符号なしのオペランドと代入先。11.6〜11.8が結果の幅と符号を決める演算子 |
| `xz_propagation` | 11 | 11.4でx/zの規則が定まる各演算子について、x/zを含むオペランド |
| `strength` | 28 | 異なる強度と値を持つ二つのドライバ。wire・tri・wand・triand・wor・trior・tri0・tri1とbufifゲートを通し、`%v`で表示 |
| `wide_paths` | 6, 7, 11, 13 | 63・64・65・127・128・129・200ビット、2値・4値、64ビットより上のx/z、符号の有無。広い・狭い・2値の代入先、パック配列の部分選択・スライスと書き込み、連結・反復連結、幅を超えるシフト、比較、x条件の`?:`、`$bits`、関数結果、タスク入力、output・ref引数。`%h`・`%b`・`%0d`で表示 |
| `keywords` | 5, 22 | 不正な設計。附属書Bの各予約語を``begin_keywords "1800-2023"``の下で変数名として宣言し、22.14で各版が追加する予約語もその版の``begin_keywords``の下で宣言する。ツールは拒否する必要がある |

各生成器のdocstringに、従う規則と、規格が結果を定めないため除いた組合せを記載しています。
変更するのは生成器であり、生成済みファイルを直接編集しません。

```sh
python3 generators/generate.py            # tests/gen/を生成
python3 generators/generate.py --check    # 生成内容が最新か検査
```

その後は通常のテスト追加と同じく、両言語のREADMEの表とカタログを更新します（「変更への参加」を参照）。
他のテストと同様にIcarus Verilog 13.0とVerilator 5.052で期待出力を確認し、
`generators/record_oracles.py`が再現できたリリースを`generators/oracles.txt`に記録します。
そこから`:oracle:`を書き出します。どちらも再現しないものはモデルだけが根拠の`:oracle: spec`です。
モデルとシミュレータが異なる場合は、ここでも条項で判断します。

## スイートの実行

シミュレーションランナーにはPython 3.10以降が必要です。共通のオプションは次のとおりです。

| オプション | 意味 |
| --- | --- |
| `TEST ...` | 指定したテストだけを実行。Icarus・Verilator・kirimasim・Lyraは明示指定でも`:type: formal`を除外する。Verilatorの既定は自分のoracleがあるテスト、`--all`はformal以外の全テスト。Icarus・kirimasim・Lyraの既定もformal以外の全テスト。Ghostは全テストファイルを選ぶ |
| `-j N`、`--jobs N` | 同時にN本を実行（既定：1） |
| `--json FILE` | 各テストの結果をFILEにも保存（`tools/suite_results.py`） |

実行条件のメタデータは、各シミュレータが受け取る形式で渡します。

| フィールド | Icarus Verilog | Verilator | kirimasim | Lyra |
| --- | --- | --- | --- | --- |
| `:files:`（ソース） | テストより先 | テストより先 | テストより先 | テストより先 |
| `:files:`（インクルード）と`:incdirs:` | `-I` | `-I` | `+incdir+` | `-I` |
| `:defines:` | `-D` | `-D` | `+define+` | `-D` |
| `:top_module:` | `-s` | `--top-module` | `--top=` | `--top` |
| `:args:` | `vvp`へ | 実行モデルへ | テストの後 | `--`の後 |

不一致のテストごとに1行（`FAIL`、既知の差異は`KNOWN`、kirimasimとLyraの未対応は
`UNSUPPORTED`）を表示します。`tools/run_icarus.py`は、一致するようになった既知の差異も
`NOW MATCHES`と表示します。最後に要約を出し、集計対象に不一致があれば終了コード1になります。

IcarusとVerilatorの端末の要約が数えるのは、その固定リリースのoracleが付いたテストだけです。
JSONには、oracleなしでも一致したテストを`pass`として記録します。
Nightlyは記録された全結果を読むので、端末の要約とは分母や一致数が異なることがあります。
oracleメタデータは自動では変わりません。

### Icarus Verilog

```sh
python3 tools/run_icarus.py -j 8
python3 tools/run_icarus.py --iverilog-bin /path/to/icarus-13.0/bin
```

`iverilog -g2012 -gspecify -ginterconnect`でコンパイルします。`-gspecify`なしでは
specifyブロックを無視し、`-ginterconnect`はSDFの相互接続遅延のアノテーションを有効にします。
`:vpi_c:`は`iverilog-vpi`でビルドして`vvp -m`で実行時に読み込みます。
Icarus Verilogはユーザー定義システム関数の戻り値の型をコンパイル時に`.sft`から読みますが、
この実行スクリプトはそれを渡しません。手続き内の呼び出しは32ビットの結果になり、
継続代入での呼び出しはコンパイルできません。DPIはなく、`:dpi_c:`は既知の差異です。
期待出力は13.0で確認しているため、`PATH`上が別の版なら`--iverilog-bin`で13.0のディレクトリを指定します。

13.0が規格に従わない箇所でも期待出力は規格に従い、`:oracle:`に`iverilog@13.0`を付けません。
そのテストは既知の差異として報告し、失敗に数えません（一致すれば`NOW MATCHES`）。
コンパイルできないテストも同様で、Verilator 5.052で確認できたものは`verilator@5.052`、
どちらの固定リリースも未登録なら`spec`だけを記録します。

### Verilator

```sh
python3 tools/run_verilator.py -j 8
python3 tools/run_verilator.py --seed 7
python3 tools/run_verilator.py --all -j 8
```

既定では`:oracle:`に`verilator@5.052`があるテストだけを実行します。
`--all`はformal以外の全件を実行し、Verilatorが未登録のテストが一致しなければ既知の差異に数えます。
`verilator --binary --timing --coverage-user`でビルドし、乱数初期値で実行します
（`--seed`で指定）。`--coverage-user`なしではcover文が動きません。
比較前に、標準出力に出るバナーや実行時の`%Warning-...`などを除去します。
例えば`randomize()`の制約を満たせない場合の警告も対象です。
モデルは`+verilator+error+limit+1000000`で実行します。既定では最初の`$error`で止まりますが、
規格はエラーを報告して続けることを求めます（20.10）。
乱数を使うテストでも、すべての制約を満たしたかなど、規格が定めることだけを出力します。
`:dpi_c:`のCコードはモデルに組み込みます。`:vpi_c:`では`--vpi`と`--public-flat-rw`も
付けますが、VPIテストが使うユーザー定義システムタスクはVerilatorが未対応です。
`randomize()`の制約にはSMTソルバー（既定は`z3`）が必要で、`PATH`になければ乱数テストは一致しません。

時間の多くは、各テストで共通のVerilatorランタイムライブラリのコンパイルに使います。
環境変数`OBJCACHE=ccache`で各モデルのmakefileが[ccache](https://ccache.dev)を使い、
ライブラリのコンパイルを一度にできます。後の実行では、変更のないテストのC++も再利用します。
両ワークフローでこれを使います。

### kirimasim

```sh
python3 tools/run_kirimasim.py --kirimasim /path/to/kirimasim -j 8
```

一時ディレクトリで`kirimasim <test>.sv`を実行します。標準出力には設計の出力だけが出るので、
シミュレータ自身の行を除去する必要はありません。未対応の構文など
（終了コード2と`error: unsupported:`メッセージ）は未対応として報告します。
Cコードをまだ読み込めないため、Cコード付きのテストも未対応です。
kirimasimを根拠に記録したoracleはなく、formal以外を実行対象にします。
使える共通・kirimasim専用の期待出力がなく、他ツール専用の期待出力だけがある場合は、
`known`として端末の一致率の分母から除きます。JSONにはその結果も記録します。

### Lyra

```sh
python3 tools/run_lyra.py --lyra /path/to/lyra --commit SHA -j 8
```

[Lyra](https://github.com/hankhsu1996/lyra)はslangとLLVMを通して設計を実行プログラムに変換します。
x86-64 Linuxだけでビルドでき、リリースがないため、`--commit`でビルドしたコミットを指定し、
結果に版として記録します。一時ディレクトリで`lyra run`を実行します。
`:top_module:`がなければ、slangが他からインスタンス化されない全モジュールを選びます。
`:dpi_c:`は`--dpi-link`、`:args:`は`--`の後に渡します。
ビルド結果は共通のキャッシュディレクトリ（`--cache-dir`、または一時ディレクトリ）に保存し、
各テストを`-j 1`でビルドします。
Lyraは標準エラーに診断を出し、未対応の機能を"is not yet supported"と示すので、未対応に分類します。
標準出力のうち、Lyra自身が出す位置情報で始まる行（cover文の回数など）を除去し、
テストが出した行を残して比較します。不正な設計は`lyra check`で確認します。
VPIがないため`:vpi_c:`は未対応です。Lyraを根拠に記録した期待出力はなく、全テストを集計対象にします。

### Ghost

```sh
python3 tools/run_ghost.py --simulator /path/to/private/simulator \
  --profile /path/to/private-profile.json --include /path/to/include -j 8 \
  --json out/ghost.json
```

Ghostは、公開前のシミュレータが当面使う仮名です。非公開の実行プロファイルに
`arguments`、`environment`、`include_subdirs`、`trailer`、`banner_pattern`、
`severity_pattern`を指定し、このリポジトリの外に置きます。
共通の`:expected_stdout:`を使い、終了コードと必要な診断も確認します。
DPI/VPIのCコードは共有ライブラリにビルドします。全テストを集計対象とし、既知の差異として除外しません。
プロファイルに従ってツール自身のバナーとseverityメッセージを除き、テストの出力は残します。
公開結果に含めるのは、一般化した不一致理由と、実行ファイルを識別するハッシュです。
実行ファイルの版表示と内部の診断は公開しません。実行中に実行ファイルやプロファイルが変わった場合、結果は破棄します。

NightlyはリポジトリのSecretsから`GHOST_REPOSITORY`、`GHOST_DEPLOY_KEY`、
`GHOST_PARSER_REPOSITORY`、`GHOST_PARSER_REF`、`GHOST_PARSER_PATH`、
`GHOST_BUILD_TARGET`、`GHOST_EXECUTABLE`（非公開チェックアウト内の相対パス）、
`GHOST_PROFILE`を読みます。このジョブは本リポジトリだけで動き、forkでは公開シミュレータを実行できます。
ゲスト参加を終えるときは、ジョブと`publish.needs`の項目、実行スクリプトを外します。
過去の履歴は、他の比較対象を外した場合と同じ仕組みで残ります。

### SymbiYosys

スイートには`:type: formal`のテストが268本あります。`:formal_case:`に検証ケース名を
指定し、`tools/run_sby.py`が参照評価器と独立したRTLモデルを比較します。
Icarus・Verilator・kirimasim・Lyraのランナーはこれらを除外します。
Ghostの現行ランナーは全テストファイルを選びますが、formalファイルの実行結果は
SymbiYosysの証明証跡にはなりません。

```sh
python3 tools/run_sby.py --sby "$SBY_BIN" --json /tmp/sby.json
```

Python 3.10以上と、動作するSymbiYosys・Yosys・ソルバーの環境が必要です。
ケースは逐次実行します。`--no-prove`はPDR証明を省略する指定で、BMCに加え、
登録されたcoverと意図的な誤りの検出も実行します。`--timeout N`は各フォーマルジョブへ渡す制限時間です。
[ランナーの選択規則](docs/runner-selection-20261028.md)と
[フォーマル検証のガイド](docs/sva-reference-formal-verification.md)も参照してください。

### 他のシミュレータ

別のシミュレータの実行スクリプトは、テストごとに次を行います。
空の一時ディレクトリを用意し、メタデータのソース、マクロ、検索先、トップレベル、引数を渡して実行し、
シミュレータ自身の標準出力の行を除去し、残りを`tools/normalize_output.py`で正規化して期待出力と比較します。
既存の短い実行スクリプトをひな型にできます。`--json`と`tools/suite_results.py`を使えば、
新しい実行スクリプトの結果もNightly履歴に追加できます。

### ローカルでの結果記録とグラフ生成

Nightlyと同じ履歴をローカル実行からも作れます。例えば`my-results/`に保存する場合です。

```sh
python3 tools/run_icarus.py -j 8 --json out/icarus.json
python3 tools/run_kirimasim.py --kirimasim /path/to/kirimasim -j 8 --json out/kirimasim.json
python3 tools/results_history.py update --history my-results --source local out/*.json
```

`update`は同じ履歴内の各シミュレータの前回と比較して`my-results/history.json`に追加し、
`my-results/charts/*.svg`と`my-results/README.md`を生成します。
既定では実行日時に現在時刻、スイートのコミットに`HEAD`を使います。過去の結果を取り込む場合は、
`--time`、`--suite-commit`、`--run-url`で実際の実行日時・コミット・結果の参照先を指定します。
`tools/`から実行スクリプトがなくなったシミュレータも履歴には残しますが、描画しません。
`python3 tools/results_history.py render --history my-results`で履歴だけから再生成できます。

## ワークフロー

`.github/workflows/check.yml`は、`tests/`、`tools/`、`generators/`、`docs/tests/`、
英語版または日本語版README、`coverage/`、`docs/behavior-coverage.md`、
`docs/coverage-depth.md`、`docs/interaction-*.md`、またはワークフロー自身を変更するmainへのpushとプルリクエストで動きます。
Actionsタブから手動実行もできます（`workflow_dispatch`）。スイートに問題がある場合に失敗します。

- **icarus**：Icarus Verilog 13.0を`v13_0`タグからビルドし、Actionsのキャッシュに保存してformal以外の全件を実行します。
  `:oracle:`に`iverilog@13.0`があるテストはすべて一致する必要があり、残りは既知の差異です。
- **verilator**：Verilator 5.052を`v5.052`タグからビルドしてキャッシュし、`randomize()`用の`z3`と
  ccacheを導入します。ccacheも次回用に保存します。`verilator@5.052`があるテストを実行し、すべての一致を求めます。
- **readme**：両言語のREADMEの表（`tools/suite_stats.py --check`）、生成テスト
  （`generators/generate.py --check`）、カタログ（`tools/suite_catalog.py --check`）、
  条項別テスト数レポートと対象の末端条項の直接テスト2本以上
  （`tools/coverage_depth.py --check --minimum-tests 2`）を確認します。
  `tools/lint_metadata.py`が確認できるメタデータ・参加ルール違反が、
  `tools/lint_baseline.txt`の既知の問題以外にないことも検査します。
  ツールの単体テスト、原文レビュー必須での要求カバレッジとベースラインの検査、
  要求照合一覧の更新状況の確認も行います。クロスのモデル・選択ケース・保存済み実行集計は
  `tools/interaction_coverage.py --check`で検査します。

`.github/workflows/nightly.yml`は毎日19:23 UTC（翌日の04:23 JST）に予定され、手動実行もできます。
最新のスイートと設定で再実行するときは、
[`main`を指定して新しい実行を起動](docs/nightly-results.md#最新のmainで手動実行する)します。
GitHubが混雑していると数時間遅れることがあります。実行は重複せず、実行中に始まったものは待機し、
さらに新しいものが来ると待機中の古いものを置き換えます。kirimasimのratchetを除いて結果の報告のみです。
次の6ジョブがあります。

- **icarus**：最新の`master`をビルドし、コミット別にキャッシュしてformal以外の全件を実行します。
- **verilator**：最新の`master`をビルドしてコミット別にキャッシュし、`z3`とccacheを使って
  `--all`でformal以外の全件を実行します。各プロセスのアドレス空間を最大6 GBに制限します（`ulimit -v`）。
  Verilatorが無限再帰する設計でランナーのメモリを使い尽くし、ジョブが止まるのを防ぐためです。
- **kirimasim**：最新の`main`を`release`プリセットでビルドしてformal以外の全件を実行します。
  `tools/results_ratchet.py`で、`results`ブランチの`latest/kirimasim.json`にある前夜の結果と比較し、
  前回一致したテストが今回不一致なら失敗にします。新規・未対応や前回結果がない場合は数えません。
  結果は先にアップロードするので、ジョブの成否によらずその晩の履歴に含められます。
- **lyra**：ジョブ開始時に`main`の最新コミットを取得し、そのSHAを`LYRA_COMMIT`に設定します。
  ソースの取得・ビルドキャッシュ・結果に記録するコミットには、同じSHAを使います。
  未キャッシュのコミットはBazelでLLVMを含めてビルドします。過去のホストランナーでは42〜89分かかりました。
  実行ファイルとrunfilesをBazelのツリーからコピーし、場所に依存するrunfilesマニフェストを除いて保存します。
  formal以外の全テストを実行します。過去のテスト実行時間は35〜70分でした。
- **ghost**：公開前のゲストを非公開でビルドし、全テストを実行します。
  取得先と実行プロファイルはSecretsから読みます。公開するのは仮名・ビルドのハッシュ・テスト結果で、
  ソースやビルド出力はランナー内に留めます。
- **publish**：完了したジョブの`--json`結果を集め、`tools/results_history.py update`で
  `results`ブランチの履歴に追加し、その実行の結果ファイルだけで要求カバレッジを測定してpushします。
  実行の要約には、各シミュレータの件数、結果が変わったテスト、要求カバレッジを載せます。
  失敗したものも含めて5シミュレータすべての完了を待ち、publish成功時にグラフとレポートが更新されます。
  公開するのは`main`の実行だけです。別ブランチでの手動実行は、シミュレータを動かして結果を
  アップロードしますが、公開はしません。

結果を作る前にNightlyジョブが失敗したシミュレータは、その晩の履歴から除きます。
次の実行では最後に保存できた結果と比較します。

## 変更への参加

既存の期待結果を変更・削除・緩和するときは、理由とIEEE 1800-2023の条項を示してください。
規格の本文・図・サンプルコードはコピーせず、自分たちの言葉で動作を説明し、条項番号を引用します。

`tools/new_test.py`は、メタデータと空の`.expected`を持つひな型を作ります。
説明、コメント、設計、期待出力が必要な箇所にはTODOが残ります。

```sh
python3 tools/new_test.py ch16 test_sequence_and --lrm "16.9.5"
python3 tools/new_test.py ch9 test_illegal_always_comb_delay --lrm "9.2.2.2" --illegal
```

新しいテストは、次を満たすようにします。

- 名前は`test_<確認内容>.sv`とし、`:lrm:`の先頭条項の章に対応する`tests/chNN/`に置きます。
- メタデータコメントと、引用条項の要求とその観測方法を説明するコメントで始めます。
  コメントは1行80桁、コードは100桁までです。コメント行の先頭を`Verilator`にしません。
  Verilatorが指令と解釈し、BADVLTPRAGMAで止まるためです。
- 規格が定める結果だけを出力し、`$finish`かイベントの終了で終わります。
  信号と、その信号から計算した値（継続代入の出力など）の両方を待つイベント制御は、
  同じ時間ステップに1回または2回起動し得るので、そのような値は固定時刻に出力します。
- 不正な設計の意図した一つの誤りを除き、規格上正しいコードにします。特にANSI形式の入力ポートで、
  2値型や仮想インターフェースなどネットにできない型を使うなら、`var`を付けます（`input var int d`）。
  ポート種別を省略した入力はネットであり、ネットの型は4値の整数型か、その配列・構造体です（23.2.2.3、6.7.1）。
- 不正な設計は`:should_fail_because:`に理由、`:expected_stderr_regex:`にエラーのファイルと行を
  指定します。妥当な報告位置が複数あればすべてを許容し、他の誤りを含めません。
  リリースが未対応の構文だけを理由にその行で拒否する場合は、コメントに明記します。
- 「期待出力の決め方」に従って規格から期待値を決め、可能ならIcarus Verilog 13.0かVerilator 5.052で
  確認します。規格と異なる箇所は[差異一覧](docs/simulator-differences.md)とテストのコメントに記録します。

新しくレビューした要求ごとに、境界値・不正ケースも含め、要求と観測を
[`coverage/behaviors.json`](coverage/behaviors.json)に記録します。
条項の引用から要求カバレッジを推測せず、未レビューの要求は未レビューのまま見えるようにします。

テスト追加後は、両言語のREADMEの表、カタログ、引用条項のページを更新し、メタデータを確認します。
チェック用ワークフローと同じ手順です。

```sh
python3 tools/suite_stats.py --update
python3 tools/suite_catalog.py --update
python3 tools/coverage_depth.py --update
python3 tools/behavior_coverage.py --update
python3 tools/requirement_matching.py --update
python3 tools/interaction_coverage.py --update
python3 tools/lint_metadata.py
```

`tools/lint_metadata.py`は、上のルールのうちスクリプトで確認できるものを報告します。
フィールドと値、`:lrm:`とディレクトリ、`:fourstate: no`でのx/zリテラル、期待出力、
不正な設計のフィールド、指定ファイル、行長、`Verilator`で始まるコメント、
時刻を出力する場合の`` `timescale ``、ひな型のTODO残りなどです。ルールの一覧はdocstringにあります。

このリポジトリの資料の多くはAI（Claude Code、OpenCode）の支援で作りました。
期待結果を規格と照合する責任は人にあります。

## ライセンス

Apache License 2.0 with LLVM Exceptions（`Apache-2.0 WITH LLVM-exception`）。
[LICENSE](LICENSE)を参照してください。
