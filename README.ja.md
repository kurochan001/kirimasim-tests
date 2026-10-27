# kirimasim-tests

[English](README.md)

[![Check](https://github.com/kurochan001/kirimasim-tests/actions/workflows/check.yml/badge.svg)](https://github.com/kurochan001/kirimasim-tests/actions/workflows/check.yml)
[![Nightly](https://github.com/kurochan001/kirimasim-tests/actions/workflows/nightly.yml/badge.svg)](https://github.com/kurochan001/kirimasim-tests/actions/workflows/nightly.yml)

IEEE 1800-2023 SystemVerilogのシミュレーションの意味論を確認する適合性テストスイートです。

用語やよくある質問は、[用語集](docs/glossary.md)と[FAQ](docs/faq.md)を参照してください。
期待値、結果の分類、Nightly、網羅率、SVA・フォーマル検証について説明しています。

各テストは、期待結果を持つ小さな独立した設計です。合法な設計は、正規化した標準出力が
期待出力に一致し、指定された終了コード・診断の検査にも通れば合格です。
不正な設計は、必要な診断を出して拒否されれば合格です
（[合否の判定方法](#合否の判定方法)を参照）。
このスイートは[kirimasim](https://github.com/kurochan001/kirimasim)向けに作っていますが、
テスト自体は特定のシミュレータに依存しません。Icarus Verilog、Verilator、kirimasim、
[Lyra](https://github.com/hankhsu1996/lyra)用の実行スクリプトがあり、メタデータは
[sv-tests](https://github.com/chipsalliance/sv-tests)の形式に従っています。

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
スイートには37章にわたり**7444本のテスト**があります。 うち1308本は自動生成です（`tests/gen/`。「自動生成テスト」を参照）：`keywords`が496本、`scheduling`が325本、`strength`が136本、`wide_paths`が49本、`width_sign`が144本、`xz_propagation`が158本。

| 期待結果の確認元 | テスト数 |
| --- | ---: |
| Icarus Verilog 13.0（`:oracle:`に`iverilog@13.0`） | 4169 |
| Verilator 5.052（Icarus Verilog 13.0のoracle登録なし） | 1453 |
| 規格のみ（固定リリースのシミュレータのoracle登録なし） | 1822 |

893本はx/z値に依存します（`:fourstate: yes`）。603本にはCコードがあり、内訳はDPIが118本（`:dpi_c:`）、VPIが485本（`:vpi_c:`）です。1893本はシミュレータが拒否すべき不正な設計です（`:should_fail_because:`）。33本はシミュレーションの終了コードを確認します（`:expected_exit:`）。実行条件の指定は、複数ソースファイル21本（`:files:`）、マクロ定義4本（`:defines:`）、インクルードディレクトリ指定5本（`:incdirs:`）、トップレベルのモジュールまたは構成指定21本（`:top_module:`）、実行時引数13本（`:args:`）です。すべてのテストをAIモデルが規格と照合しました（`:spec_check: ai`）。人による照合はまだありません。

| 章 | 題名 | テスト数 | Icarus | Verilator | 規格のみ |
| ---: | --- | ---: | ---: | ---: | ---: |
| 3 | 設計と検証の構成要素 | 86 | 64 | 12 | 10 |
| 4 | スケジューリングの意味論 | 412 | 391 | 5 | 16 |
| 5 | 字句規則 | 345 | 324 | 14 | 7 |
| 6 | データ型 | 594 | 356 | 135 | 103 |
| 7 | 集合データ型 | 482 | 179 | 234 | 69 |
| 8 | クラス | 321 | 67 | 182 | 72 |
| 9 | プロセス | 202 | 144 | 31 | 27 |
| 10 | 代入文 | 204 | 133 | 43 | 28 |
| 11 | 演算子と式 | 835 | 704 | 92 | 39 |
| 12 | 手続き型プログラミング文 | 181 | 133 | 29 | 19 |
| 13 | タスクと関数（サブルーチン） | 197 | 106 | 78 | 13 |
| 14 | クロッキングブロック | 78 | 4 | 61 | 13 |
| 15 | プロセス間の同期と通信 | 56 | 2 | 36 | 18 |
| 16 | アサーション | 473 | 104 | 62 | 307 |
| 17 | チェッカー | 81 |  | 22 | 59 |
| 18 | 制約付き乱数値の生成 | 200 | 26 | 95 | 79 |
| 19 | 機能カバレッジ | 145 | 2 | 17 | 126 |
| 20 | ユーティリティ用システムタスク・関数 | 270 | 200 | 24 | 46 |
| 21 | 入出力用システムタスク・関数 | 207 | 141 | 14 | 52 |
| 22 | コンパイラ指令 | 348 | 327 | 11 | 10 |
| 23 | モジュールと階層 | 237 | 137 | 38 | 62 |
| 24 | プログラム | 43 | 21 | 5 | 17 |
| 25 | インターフェース | 119 | 31 | 57 | 31 |
| 26 | パッケージ | 83 | 53 | 16 | 14 |
| 27 | generate構文 | 103 | 93 | 8 | 2 |
| 28 | ゲートレベル・スイッチレベルのモデリング | 245 | 194 | 3 | 48 |
| 29 | ユーザー定義プリミティブ | 81 | 58 | 11 | 12 |
| 30 | specifyブロック | 59 | 34 | 1 | 24 |
| 31 | タイミング検査 | 58 | 10 |  | 48 |
| 32 | 標準遅延形式によるバックアノテーション | 50 | 16 |  | 34 |
| 33 | 設計内容の構成指定 | 42 | 11 | 9 | 22 |
| 34 | 保護エンベロープ | — | | | |
| 35 | 直接プログラミングインターフェース（DPI） | 123 | 5 | 76 | 42 |
| 36 | プログラミング言語インターフェース（PLI/VPI）の概要 | 84 | 29 | 19 | 36 |
| 37 | VPIオブジェクトモデル図 | 224 | 15 | 1 | 208 |
| 38 | VPIルーチンの定義 | 106 | 54 | 9 | 43 |
| 39 | アサーションAPI | 39 |  | 1 | 38 |
| 40 | コードカバレッジの制御とAPI | 31 | 1 | 2 | 28 |
<!-- suite-stats:end -->

SVAについての追加検証は、上のoracle別の件数とは別に記録しています。
参照評価器は**45本のテスト出力**を再現します。基本フォーマルセットでは
**40件のBMC検査**が成功し、そのうち**22モデルは入力長の上限を置かないPDR証明にも成功**しました。
別の境界値の組合せ検査では、**111ケースすべてでBMC・PDRが成功**し、
28本のテストの91指令に含まれる**127個の系列部分式**と対応付けています。
二つのセットには重複があるので、異なるモデルの数として足し合わせません。
フォーマルモデルをテスト本数に加えたり、上の表のoracle分類を変更したりもしません。
範囲・証跡・再実行方法は、[SVA参照評価器とフォーマル検証](docs/sva-reference-formal-verification.md)と
[境界値の拡張結果](docs/sva-formal-expansion-20261026.md)を参照してください。

[テストカタログ](docs/tests/README.md)は、各テストが何を確かめ、どの条項を引用するかを
章ごとに示します。[条項一覧](docs/tests/clauses.md)では、各章のどの条項をテストが引用しているかを
確認できます。[深度レポート](docs/coverage-depth.md)は、条項ごとのテスト数と、
規格のみから決めた期待出力を持つ1本のテストしかない条項を示します。
3〜40章の対象範囲内の末端条項には、それぞれ2本以上の直接引用するテストがあります。
対象外の条項とその理由も同じページに記載しています（`tools/clauses.txt`のタグ）：
一般的な説明、34章、ツールに委ねられた動作、VCDファイルの内容です。
ただしVCDのうち、`test_vcd_dump_readback`が読み返す部分
（21.7.2.1〜21.7.2.3、21.7.5）は対象に含めています。

これは条項の引用網羅率であり、IEEE 1800-2023のすべての要求や組合せを検査した証明ではありません。
引用深度の範囲は`tools/clauses.txt`が選ぶ3〜40章の末端条項で、現在の件数と除外理由は
[深度レポート](docs/coverage-depth.md)に記載しています。
附属書や明示的な除外条項を、規格全体を網羅したという主張に暗黙に含めることはしません。
[2026-10-22の拡充](docs/coverage-strengthening-20261022.md)では、それまでテストが1本だった
187条項すべてに異なるケースを追加しました。CIは
`tools/coverage_depth.py --check --minimum-tests 2`で2本以上を必須にします。
親条項の引用だけでは、その子条項の本数を満たしません。

[振る舞い網羅率の要約](docs/behavior-coverage-summary.md)と
[詳細レポート](docs/behavior-coverage.md)では、明示的にレビューした要求と、
テストで観測する結果を測定します。[台帳と作業手順](coverage/README.md)は、
1〜41章と附属書A〜Qを、親条項の導入や従来の対象外部分も含めて棚卸しします。
原文レビューは全1,740節を対象にしています。暫定率の分母には、解釈を保留している行や
テスト未対応の行も含め、登録済みの要求・条件・観測の全行を使います。
解釈と重複する要求単位を整理し、分母を承認するまでは、規格全体の確定率を定義しません。
設計網羅率、実行証拠、シミュレータ別の結果、原文レビューの進捗は分けて報告します。
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

[規格PDFからテストに至る方法](docs/requirements-to-tests-method.md)は、要求の抽出、
既存テストとの照合と追加テストの作成、独立したレビュー、統合と測定までを順に説明します。
作業には[照合キット](tools/matching_kit/README.md)を使います。

2026-10-23の更新は、[照合の進捗と指摘](docs/existing-test-matching-review-20261022.md)、
[暫定設計網羅率20%超の照合結果](docs/existing-test-matching-20percent-20261023.md)、
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
45本を99要求に対応付けました。既存テストにない刺激を補う新規6本と、
シミュレータリポジトリのCTestスイートから取り込んだ23本を含みます。
2026-10-25〜26には、その作業の残りの範囲
（p01・p05・p07・p09・p10・p12・p13・p15、附属書と不足分、附属書Aの文法テスト）を
検証して統合しました。K.2・I.3・N.2のヘッダーとアルゴリズム、アサーション制御、
カバレッジ、チェッカー、1364 VPI互換性のテストも追加しました。
規格のみの277本についてIcarus Verilog 13.0で再現できたことを記録し、
さらに既存テストの12範囲の照合で341要求を対応付けました。
暫定設計網羅率は**85.023135%（10,474/12,319）**、
暫定実行網羅率は**46.545986%（5,734/12,319）**です。
測定入力と分母は[生成した振る舞い要約](docs/behavior-coverage-summary.md)、
以前の修正は[Nightlyのテスト修正とoracleレビュー](docs/nightly-suite-corrections-20261027.md)を参照してください。
1〜40章だけの設計網羅率は84.95%（8,058/9,486）です。
確定率は未定義で、既存テスト全体の意味のレビューもまだ完了していません。
追加報告には、観測、規格から決めた期待値、シミュレータとの差、意図的な誤りを入れる検査、
実行証拠を記録しています。

テストの配置先は、`:lrm:`の先頭の条項が属するIEEE 1800-2023の章に対応するディレクトリです。
表のIcarus・Verilator・規格のみの列は、最初の表と同じく、期待結果の確認元別の件数です。
1・2章には検査対象の動作がありません。34章（保護エンベロープ）は、内容が各ツールの
暗号化方式に依存するためテストがありません。設計のどこにコードカバレッジを持つかは
ツールとオプションに依存するので、40章のテストは、許される値やカバレッジ関数の結果同士の
関係など、すべての結果に共通して成り立つことだけを出力します。

## Nightlyの結果

毎晩、[GitHub Actionsワークフロー](.github/workflows/nightly.yml)が、各シミュレータで
`main`の全テストを実行します。Icarus VerilogとVerilatorは`master`、kirimasimは`main`の
最新開発版をその晩にビルドし、リリースのないLyraはワークフローで固定したコミットを使います。
結果は[`results`](https://github.com/kurochan001/kirimasim-tests/tree/results)ブランチの履歴に追加します。
下のグラフは実行ごとに更新します。
[同ブランチのレポート](https://github.com/kurochan001/kirimasim-tests/tree/results#readme)には、
一致率、章別の結果、シミュレータごとの推移、前夜から結果が変わったテストも載せています。

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

![期待結果に一致するテスト数](https://raw.githubusercontent.com/kurochan001/kirimasim-tests/results/charts/overview.svg)

シミュレータごとに、Icarus Verilogは丸、Verilatorは四角、kirimasimはひし形、Lyraは下向き三角を使います。
一致数が同じ、または近い場合も見えるように、マーカーは互いに重ねて収まる輪郭で描きます。
凡例には、最新の実行の件数も示します。

### 章別の結果

各セルは**一致したテスト数 / 結果が記録されたテスト数**と、その章・シミュレータの一致率です。
既知の差異と未対応のテストは、実行前にスキップしたものも含めて分母に残します。
表はNightlyのグラフとともに更新し、上部に日付とシミュレータの版を表示します。
クリックすると原寸の画像を開けます。

[![章別の一致テスト数](https://raw.githubusercontent.com/kurochan001/kirimasim-tests/results/charts/chapters.svg)](https://raw.githubusercontent.com/kurochan001/kirimasim-tests/results/charts/chapters.svg)

### 結果の分類

各テストの結果は、次のいずれかになります。

| 結果 | 意味 |
| --- | --- |
| match（一致） | 出力と、指定された終了コード・実行時診断の検査が一致した、または不正な設計が必要な診断付きで拒否された |
| differ（不一致） | 結果が一致しない、必要な診断がない、不正な設計が受理された、または他の分類に当たらないビルド・実行の失敗 |
| known difference（既知の差異） | IcarusまたはVerilatorで一致せず、その固定リリースのoracleトークンもない（`:oracle:`を参照） |
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
示す回数での5回の中央値から、`+n=1`での5回の中央値を引いた値です。

| 設計 | `+n=` | kirimasim | Icarus Verilog 14.0 devel | Verilator 5.053 devel | Lyra（LLVMバックエンド） |
| --- | :---: | :---: | :---: | :---: | :---: |
| `comb_chain` | 3,000,000 | 9.249 s | 9.796 s | 0.223 s | 2.878 s |
| `nba_shift` | 1,000,000 | 25.486 s | 26.585 s | 0.196 s | 5.900 s |
| `proc_wait` | 1,000,000 | 6.786 s | 5.688 s | 2.283 s | 6.164 s |
| `fork_join` | 4,000,000 | 4.837 s | 5.023 s | 1.190 s | 4.860 s |
| `wide_arith` | 1,500,000 | 4.944 s | 2.036 s | 0.086 s | 0.380 s |
| `mem_rw` | 4,000,000 | 4.937 s | 3.645 s | 0.696 s | 2.705 s |
| `func_call` | 1,500,000 | 4.917 s | 7.511 s | 0.005 s | 0.395 s |
| `string_fmt` | 500,000 | 5.003 s | 8.080 s | 0.135 s | 0.279 s |
| `dyn_queue` | 4,000,000 | 4.112 s | 6.686 s | 0.083 s | 0.412 s |
| `gate_udp` | 400,000 | 5.378 s | 3.517 s | 0.046 s | 未対応 |
| `casez_struct` | 5,000,000 | 3.976 s | 4.117 s | 0.018 s | 0.466 s |

- kirimasimは`b66834254c65`、Icarus Verilogは14.0 develの`2b8d42dc088f`、
  Verilatorは5.053 develの`1838b6ed035c`、Lyraは`63922502ff0a`です。
  Lyraは`bazel build -c opt`でビルドし、Nightlyが固定するコミットとは異なります。
  Lyra列は、同プロジェクトのREADMEが主な実装とするLLVMバックエンドで、既定の`-O 0`です。
  `--backend`を指定しない場合の既定はC++バックエンドで、この設計群ではLLVMより3.3〜67倍遅くなりました。
  その時間も下記のベンチマーク詳細にあります。測定できたすべての実行で結果は期待どおりでした。
  LyraはゲートとUDPが未対応なので、`gate_udp`の実行プログラムは生成していません。
  時間には設計のビルド（VerilatorのC++、Lyraのプログラム）は含めません。
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
docs/behavior-coverage-summary.md 章別・シミュレータ別の暫定・確定振る舞い網羅率
docs/requirements-to-tests-method.md 規格PDFから要求・テスト・網羅率に至る方法
coverage/behavior-summary.json  現在の振る舞い測定と分母の識別情報
coverage/behavior-history.json  分母の識別情報を含む測定履歴
tools/run_icarus.py             Icarus Verilogでの実行
tools/run_verilator.py          Verilatorでの実行
tools/run_kirimasim.py          kirimasimでの実行
tools/run_lyra.py               Lyraでの実行
tools/normalize_output.py       比較前の出力正規化
tools/suite_results.py          実行結果のJSON形式（--json）
tools/results_history.py        Nightlyの履歴とグラフ生成
tools/results_ratchet.py        前回一致して今回不一致のテストの一覧
tools/suite_stats.py            テスト集計と両言語のREADMEの表の更新
tools/suite_catalog.py          docs/tests/のカタログ生成
tools/coverage_depth.py         docs/coverage-depth.mdの生成
tools/clauses.txt               docs/tests/clauses.md用の条項番号
tools/lint_metadata.py          メタデータとテストの形式の検査
tools/lint_baseline.txt         既存テストの既知の問題
tools/new_test.py               新規テストのひな型生成
tools/matching_kit/             要求とテストの対応の提案・検査・判定・統合
.github/workflows/check.yml     固定リリースでの期待結果の検査
.github/workflows/nightly.yml   Nightly実行
```

Nightlyだけが書き込む`results`ブランチには、`history.json`（1実行1エントリ）、
`latest/<simulator>.json`（各シミュレータの最新の全テスト結果）、`charts/*.svg`、
レポートの`README.md`があります。グラフとレポートには`tools/`に実行スクリプトがある
シミュレータだけを表示します。実行スクリプトがなくなったものも履歴には残しますが、描画しません。
publishジョブは、その実行の振る舞い網羅率として`behavior-coverage-summary.md`、
`behavior-coverage.md`、`behavior-summary.json`、`behavior-coverage.json`、`behavior-history.json`も
書き出します。`main`の保存済み証跡との違いは[Nightlyの説明](docs/nightly-results.md)を参照してください。

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
| `:type:` | 実行するテストは`simulation` |
| `:lrm:` | 確認対象のIEEE 1800-2023の条項。例：`1800-2023 11.4.3` |
| `:oracle:` | 期待出力の根拠。`spec`は引用条項と照合済み（担当は`:spec_check:`）、`iverilog@13.0`はIcarus Verilog 13.0で再現、`verilator@5.052`はVerilator 5.052で再現 |
| `:spec_check:` | `spec`の期待値を規格と照合した担当。`ai`はAIモデル（人による照合はまだなし）、`human`は人 |
| `:fourstate:` | x/zに依存するか（`yes` / `no`）。x/zリテラル、`$isunknown`、`casex`/`casez`、三状態・強度構文、期待出力のx/zなど |
| `:nondeterministic:` | 規格が決めていない実行順に結果が依存し得るか |
| `:expected_stdout:` | 期待する標準出力、または隣のファイルを示す`@<file>` |
| `:dpi_c:` | 隣のCコード`@<file>`。DPIインポートを実装し、エクスポートを呼び出す（35章） |
| `:vpi_c:` | 隣のVPIアプリケーション`@<file>`。`vlog_startup_routines`からシステムタスク・関数とコールバックを登録する（36〜40章） |
| `:should_fail_because:` | 不正な設計である理由。シミュレータは拒否する必要がある。`:type: elaboration`とし、`:expected_stdout:`は置かず、`:expected_stderr_regex:`でエラー箇所を指定する |
| `:expected_exit:` | 終了コード。`0`、`nonzero`（0より大きい）、または数値。規格は`$fatal`がエラーコードで終了することだけを定めるので、`nonzero`を使う（20.10） |
| `:expected_stderr_regex:` | 実行スクリプトが渡す診断テキストに対するPython正規表現（後述の「合否の判定方法」）。不正な設計では、レビューした位置（例：`test_x\.sv:12:`）と必要な診断の概念をエラー行が満たす必要がある。妥当な別位置も許容できるが、未対応構文の診断は意図した違反の証拠にしない。他のテストでは実行時のメッセージがパターンを満たすことを確認する。診断全文の言い回しは固定しない |
| `:args:` | 空白区切りの実行時引数。例：`+count=3` |
| `:generator:` | `<generator>@<version>`。`generators/<generator>.py`が生成したテスト |
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
基本セットは40件のBMCと、入力長の上限を置かない22件のPDR証明に成功しました。
後続の[境界値の拡張](docs/sva-formal-expansion-20261026.md)は全111ケースでBMC・PDRに成功し、
28本のテストの127個の系列部分式と対応付けています。セット同士には重複があります。
対応付けが対象とするのは0／1の系列計算で、アサーション全体やシミュレータの動作ではありません。
両セットは到達例と、意図的な誤りに対する反例も含みます。
oracleメタデータやシミュレータ実行網羅率は変更しません。
[日本語ガイド](docs/sva-reference-formal-verification.md)に範囲・結果・再実行方法、
[技術報告](tools/sva_reference/FORMAL_REVIEW.md)に保存済み証跡へのリンクがあります。

### 自動生成テスト

`tests/gen/`は`generators/`の生成器が作ります。各生成器には、シミュレータを使わず
規格からPythonで書いた参照モデルがあり、期待出力を計算して、一つの種類の小さな変形を多数作ります。

| 生成器 | 章 | 変えるもの |
| --- | ---: | --- |
| `scheduling` | 4 | 書き込み（ブロッキング・ノンブロッキング・代入内遅延付きノンブロッキング・継続代入経由・`force`）、読み取り（同一プロセス・待機中の別プロセス・`$strobe`・`$monitor`）、場所（initial・always・タスク・関数・fork分岐・インターフェース・generateブロック）、遅延（なし・`#0`・`#1`）。規格が結果を決める組合せだけ |
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

すべての実行スクリプトにはPython 3.10以降が必要です。共通のオプションは次のとおりです。

| オプション | 意味 |
| --- | --- |
| `TEST ...` | 指定したテストだけを実行。既定ではVerilatorは自分のoracleがあるテスト、他は`tests/**/test_*.sv`の全テストを選ぶ。Verilatorも`--all`なら全テスト |
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
Icarus Verilogはユーザー定義システム関数の戻り型をコンパイル時に`.sft`から読みますが、
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
`--all`は全件を実行し、Verilatorが未登録のテストが一致しなければ既知の差異に数えます。
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
kirimasimを根拠に記録した期待出力はなく、全テストを集計対象にします。

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
python3 tools/results_history.py update --history my-results out/*.json
```

`update`は同じ履歴内の各シミュレータの前回と比較して`my-results/history.json`に追加し、
`my-results/charts/*.svg`と`my-results/README.md`を生成します。
`tools/`から実行スクリプトがなくなったシミュレータも履歴には残しますが、描画しません。
`python3 tools/results_history.py render --history my-results`で履歴だけから再生成できます。

## ワークフロー

`.github/workflows/check.yml`は、`tests/`、`tools/`、`generators/`、`docs/tests/`、
英語版または日本語版README、`coverage/`、`docs/behavior-coverage.md`、
`docs/coverage-depth.md`、またはワークフロー自身を変更するmainへのpushとプルリクエストで動きます。
Actionsタブから手動実行もできます（`workflow_dispatch`）。スイートに問題がある場合に失敗します。

- **icarus**：Icarus Verilog 13.0を`v13_0`タグからビルドし、Actionsのキャッシュに保存して全件を実行します。
  `:oracle:`に`iverilog@13.0`があるテストはすべて一致する必要があり、残りは既知の差異です。
- **verilator**：Verilator 5.052を`v5.052`タグからビルドしてキャッシュし、`randomize()`用の`z3`と
  ccacheを導入します。ccacheも次回用に保存します。`verilator@5.052`があるテストを実行し、すべての一致を求めます。
- **readme**：両言語のREADMEの表（`tools/suite_stats.py --check`）、生成テスト
  （`generators/generate.py --check`）、カタログ（`tools/suite_catalog.py --check`）、
  深度レポートと対象の末端条項の直接テスト2本以上
  （`tools/coverage_depth.py --check --minimum-tests 2`）を確認します。
  `tools/lint_metadata.py`が確認できるメタデータ・参加ルール違反が、
  `tools/lint_baseline.txt`の既知の問題以外にないことも検査します。
  ツールの単体テスト、原文レビュー必須での振る舞い網羅率とベースラインの検査、
  要求照合一覧の鮮度確認も行います。

`.github/workflows/nightly.yml`は毎日19:23 UTC（翌日の04:23 JST）に予定され、手動実行もできます。
GitHubが混雑していると数時間遅れることがあります。実行は重複せず、実行中に始まったものは待機し、
さらに新しいものが来ると待機中の古いものを置き換えます。kirimasimのratchetを除いて結果の報告のみです。
次の5ジョブがあります。

- **icarus**：最新の`master`をビルドし、コミット別にキャッシュして全件を実行します。
- **verilator**：最新の`master`をビルドしてコミット別にキャッシュし、`z3`とccacheを使って
  `--all`で全件を実行します。各プロセスのアドレス空間を最大6 GBに制限します（`ulimit -v`）。
  Verilatorが無限再帰する設計でランナーのメモリを使い尽くし、ジョブが止まるのを防ぐためです。
- **kirimasim**：最新の`main`を`release`プリセットでビルドして全件を実行します。
  `tools/results_ratchet.py`で、`results`ブランチの`latest/kirimasim.json`にある前夜の結果と比較し、
  前回一致したテストが今回不一致なら失敗にします。新規・未対応や前回結果がない場合は数えません。
  結果は先にアップロードするので、ジョブの成否によらずその晩の履歴に含められます。
- **lyra**：ワークフロー内の唯一の指定箇所`LYRA_COMMIT`が固定するコミットをビルドします。
  BazelでLLVMをソースからビルドするため、ホストランナーでは42〜89分かかりました。
  実行ファイルとrunfilesをBazelのツリーからコピーし、そのツリーのパスを指すrunfilesマニフェストを
  除いてコミット別にキャッシュします。固定コミットを変えた場合だけ再ビルドします。
  全テストの実行には35〜70分かかり、Nightlyで最長のジョブです。結果にはコミットを記録します。
- **publish**：完了したジョブの`--json`結果を集め、`tools/results_history.py update`で
  `results`ブランチの履歴に追加し、その実行の結果ファイルだけで振る舞い網羅率を測定してpushします。
  実行の要約には、各シミュレータの件数、結果が変わったテスト、振る舞い網羅率を載せます。
  失敗したものも含めて4シミュレータすべての完了を待ち、publish成功時にグラフとレポートが更新されます。
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
- 不正な設計の意図した一つの誤りを除き、合法な設計にします。特にANSI形式の入力ポートで、
  2値型や仮想インターフェースなどネットにできない型を使うなら、`var`を付けます（`input var int d`）。
  ポート種別を省略した入力はネットであり、ネットの型は4値の整数型か、その配列・構造体です（23.2.2.3、6.7.1）。
- 不正な設計は`:should_fail_because:`に理由、`:expected_stderr_regex:`にエラーのファイルと行を
  指定します。妥当な報告位置が複数あればすべてを許容し、他の誤りを含めません。
  リリースが未対応の構文だけを理由にその行で拒否する場合は、コメントに明記します。
- 「期待出力の決め方」に従って規格から期待値を決め、可能ならIcarus Verilog 13.0かVerilator 5.052で
  確認します。規格と異なる箇所は[差異一覧](docs/simulator-differences.md)とテストのコメントに記録します。

新しくレビューした振る舞いごとに、境界値・不正ケースも含め、要求と観測を
[`coverage/behaviors.json`](coverage/behaviors.json)に記録します。
条項の引用から振る舞い網羅率を推測せず、未レビューの要求は未レビューのまま見えるようにします。

テスト追加後は、両言語のREADMEの表、カタログ、引用条項のページを更新し、メタデータを確認します。
チェック用ワークフローと同じ手順です。

```sh
python3 tools/suite_stats.py --update
python3 tools/suite_catalog.py --update
python3 tools/coverage_depth.py --update
python3 tools/behavior_coverage.py --update
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
