<a id="nightly-results-update-times-and-interpretation"></a>

# Nightly resultsの更新時刻と見方

[English](nightly-results.en.md)

[READMEのグラフ](../README.ja.md#nightly-results) / [公開結果](https://github.com/kurochan001/kirimasim-tests/tree/results#readme) / [実行一覧](https://github.com/kurochan001/kirimasim-tests/actions/workflows/nightly.yml)

<a id="latest-verified-checkpoint"></a>

## 最新の確認済み状態（2026-11-04 日本時間）

suiteのコミット`9926160a1397f514cdd09f84384392c832de2cc5`を対象とする
[Check 41718590448](https://github.com/kurochan001/kirimasim-tests/actions/runs/41718590448)と
[Nightly 41743702063](https://github.com/kurochan001/kirimasim-tests/actions/runs/41743702063)は、ともに成功しました。
Checkのreadme・固定Icarus 13.0・Verilator 5.052の各ジョブ、Nightlyの5シミュレータと`publish`の各ジョブが成功しています。
[公開スナップショット](https://github.com/kurochan001/kirimasim-tests/blob/d86edcb61af0d54b0a8cff910a8757cc67c257bf/README.ja.md)の生成時刻は、
2026-11-04 03:25 UTC（日本時間12:25）です。
この記録は当該コミット・ビルドでの確認であり、その後の変更まで成功を保証するものではありません。

- **固定suite：** 登録10,672件のうち268件はformalで、シミュレータの実行対象は10,404件です。
  kirimasim `9113955914d8`の結果は**7,868 pass・2,403 unsupported・133 fail**です。
  既存のpass→failを検出するratchetは成功しましたが、CI成功は固定テスト全件PASSを意味しません。
  前回Nightlyから、第30章の通常のspecify条件テスト5件がunsupportedからPASSへ変わりました。
  その他の状態分類と全10,404件の入力ハッシュは不変です。この5件は有限クロスの選択には含まれません。
- **有限クロスの選択：** この単一kirimasim実行に79モデルの全2,922件が含まれます。
  入力ハッシュ・状態分類とも[保存済みcross79](../coverage/interaction-results/cross79-kirimasim-a682e19e-pkgwatch.json)と一致し、
  **2,389 pass・529 unsupported・configの4 fail**、全選択ケースPASSは52モデルです。
  対応付けた章対は114組です。CSVは引き続き元の保存実行を示し、正式実行はその別途確認として扱います。
  複数実行の部分成功を合成した結果ではありません。
- **ランダム比較：** 13プロファイルの**全96件がPASS**し、証跡は有効・完了です。
  seed `41743702063`はworkflow run IDです。それと別に記録したランダム比較のビルドは、
  比較直前に再取得・再ビルドしたkirimasim `9113955914d878437074f0e3b86a8dca38438080`（GNU 13.3.0）です。
  実行バイナリのSHA-256は`b348f74d38baa8da4e0d9fdb87c40966b3f6397328408bb340aec477a47f3852`です。
  この実行では固定suiteとランダム比較の本体revisionが一致しましたが、今後も一致するとは限りません。

[確認記録](../coverage/interaction-qualification/formal-ci-9926160a-20261104.json)に、workflowの結論・artifactのハッシュ・
全選択ケースの照合・保存済みランダムSVの独立検算を記載しています。
ランダム結果は専用の`random-cross-kirimasim`に保持し、固定履歴・カバレッジへ加算しません。
プロファイルの追加はいったん13個で区切り、重点領域の追加探索・独立検算・確認済み不具合の固定回帰化を進めます。

### 現在のローカル追加（2026-11-05）

その後、クラス×packageの追加は[`fd140002`のCheck](https://github.com/kurochan001/kirimasim-tests/actions/runs/41852637183)で確認済みです。
現在の作業ツリーには[生成サブルーチンの36件](interaction-verification.md#generated-subroutine-binding)を追加し、
suiteは10,742件、有限クロスは81モデル・2,992件になっています。
最新取得・ビルドの`162222153c57`による[単一の全クロス実行](../coverage/interaction-results/cross81-kirimasim-16222215-gensub.json)は、
2,459 pass・529 unsupported・4 failで、従来2,956件の入力・状態分類は不変です。
新しい36件は正式Check・Nightlyでは未実行です。最新の正式Nightlyは上の`9926160a`で、
クラス×package・生成サブルーチンのどちらの追加も、その確認範囲より後です。

<a id="previous-verified-checkpoint"></a>

### 前回の確認（suite e8d991a9）

先行する[Check 41649940180](https://github.com/kurochan001/kirimasim-tests/actions/runs/41649940180)と
[Nightly 41650010801](https://github.com/kurochan001/kirimasim-tests/actions/runs/41650010801)も、公開処理を含め成功しました。
kirimasim `d73d8922dfa2`の固定suiteは7,863 pass・2,408 unsupported・133 fail、
有限クロスは2,389 pass・529 unsupported・4 fail、ランダム比較はseed `41650010801`で96件すべて有効なPASSでした。
[元の確認記録](../coverage/interaction-qualification/formal-ci-e8d991a9-20261104.json)と
[公開スナップショット](https://github.com/kurochan001/kirimasim-tests/blob/6722914378e3758387157e8c5f5eb31cdcd3d7cf/README.ja.md)は書き換えず保持しています。
これらは先行実行での観測であり、最新ビルドの結果として扱いません。

<a id="when-results-update-in-japan"></a>

## 日本時間ではいつ更新されるか

[Nightlyの設定](../.github/workflows/nightly.yml)は、毎日19:23 UTC、
**日本時間では翌日04:23に開始予定**です。結果の更新時刻は固定ではありません。
GitHub側の開始遅延、待機中の実行、シミュレータのビルド・テスト時間によって遅くなることがあります。

Icarus、Verilator、kirimasim、Lyra、Ghostの5ジョブが終了してから、`publish`が実行されます。
Ghostは、公開前の正体不明なシミュレータが仮名で参加する枠です。
毎晩、他の参加者と同じテストを実行し、正体やソースを伏せたまま結果を公開します。
ビルドの識別には実行ファイルのハッシュを使い、取得先・内部の診断・ビルドログは公開しません。
nvcは2026年10月24日に比較対象へ加えましたが、SystemVerilogへの対応が少ないため、10月25日に外しました。それまでのnvcの結果は`history.json`に残りますが、推移図とレポートには描きません。
Lyraは各ジョブの開始時に`main`先端のコミットを取得します。そのSHAをソース取得・キャッシュキー・結果記録で共通に使い、同じコミットのビルドだけを再利用します。未キャッシュのコミットは再ビルドします。過去のGitHubランナーでのビルドには40〜90分かかりました。
`publish`は`main`の実行だけが行います。ほかのブランチで手動実行した場合、結果はartifactとして残るだけで、公開はされません。
`publish`が結果を集計して`results`ブランチへpushすると、READMEから参照しているグラフと結果レポートが更新されます。
`main`へのpushと、Nightly結果の公開は別の処理です。


ローカル結果を公開グラフにも反映する場合は、`main`への結果保存に加え、
`tools/results_history.py update --source local`で`results`ブランチの履歴・グラフ・表を
更新してpushします。実行時刻と実際に使ったスイートのコミットを指定し、結果JSONへのリンクを付けます。
公開レポートと章別の表はシミュレータごとの最新結果を使い、それぞれの実行日時・スイート・
`nightly`／`local`を表示します。別の実行の古い結果を、今回実行したものとして扱いません。

公開レポートの`Latest run`と`Recent runs`は**UTC表示**です。
この時刻は`tools/results_history.py update`がレポートを生成した時刻で、ワークフローの開始時刻ではありません。
日本時間へ換算するには9時間を足します。日付が変わる場合もあります。
開始時刻・待機状態・終了状態は、レポートの`workflow run`リンク先で確認できます。


<a id="starting-a-new-run-on-current-main"></a>

## 最新のmainで手動実行する

再実行時もスイートとワークフローの最新版を使うには、`main`を指定して新しい実行を起動します。

```sh
gh workflow run check.yml --repo kurochan001/kirimasim-tests --ref main
gh workflow run nightly.yml --repo kurochan001/kirimasim-tests --ref main
```

GitHubの[Re-runは元の実行と同じコミット・refを使います](https://docs.github.com/en/actions/how-tos/manage-workflow-runs/re-run-workflows-and-jobs)。
`workflow_dispatch`で`main`を選ぶと、起動時の`main`先端のスイートと設定が対象になります。
Lyraはそのジョブ開始時に上流の`main`先端を取得し、実行に使ったSHAを結果へ記録します。

<a id="random-comparisons"></a>

<a id="additional-random-comparisons"></a>

## 追加のランダム比較

kirimasimジョブは固定スイートと別に、[モデルに基づくランダム比較](random-cross-verification.md)を既定96ケース実行します。
固定スイートの終了後、上流mainを再取得・ビルドしてから比較します。seedはGitHubのrun IDで、入力値と操作列も保存します。
全ケースの有効なPASSが必要で、不一致・未対応・時間切れ・証跡の変化はステップの失敗になります。

結果と再現用のmanifest・SV・期待値・出力は`random-cross-kirimasim`という専用artifactにあります。英語レポートはStep Summaryにも載ります。
このartifactは固定スイートの`results-*`から外し、公開グラフや章別の一致数、要求カバレッジへ加算しません。
ローカルでの成功と、GitHubでこのステップが実行されて成功したことは別に確認します。

<a id="publication-failure-on-2026-11-02"></a>

## 2026-11-02の公開処理失敗と対策

[実行41359514776](https://github.com/kurochan001/kirimasim-tests/actions/runs/41359514776)は、
スイート`4e9c89c4`を対象に、5つのシミュレータジョブが成功した後、`publish`の要求カバレッジ資料生成で失敗しました。
kirimasimのランダム比較も、版`2c81a591105b`、seed `41359514776`で96件すべてが有効なPASSでした。
固定スイートのジョブ成功は、全テストの一致を意味しません。

原因は、最新版Verilatorのバージョン文字列を、翻訳辞書に登録された説明文として処理していたことです。
`Verilator 5.055 devel rev v5.054-25-g1b275150`という未登録の形式で翻訳が停止しました。
同じartifactで後続の処理も確認し、附属書Bの規格違反テストが「テスト対応あり・実行未確認」になる組合せにも、翻訳の不足を確認しました。

対策では、バージョン・実行日時・条項番号・要求の種別をMarkdownのコードとして原形のまま表示し、
要求の状態を表す説明文だけを翻訳します。版・時刻・条項ごとの辞書登録を不要にし、未翻訳の説明文を検出する検査は維持します。
開発版で期待出力が一致していても、承認された固定版oracleを満たさない規格違反テストは、引き続き`unreviewed_oracle`です。
期待値・oracle・結果の判定・カバレッジ計測規則は変更していません。

失敗時の5環境の結果JSONを使い、履歴生成、要求カバレッジの日英詳細・概要、機能間クロスの日英レポートをローカルで生成して対策を確認しました。
生成結果の確認は、シミュレータの再実行やGitHubへの公開とは別です。
その後の[確認済みNightly](#latest-verified-checkpoint)では、公開処理も成功しました。
今後の変更を検証する際は、[最新mainでの手動実行](#starting-a-new-run-on-current-main)で新しいNightlyを起動します。
元の失敗実行のRe-runは、修正前のスイート・ツールを使います。

<a id="recorded-example-publication-on-2026-10-31"></a>

## 確認例：2026年10月31日の公開

2026年11月1日に、[実行41141958886](https://github.com/kurochan001/kirimasim-tests/actions/runs/41141958886)の
5シミュレータジョブと`publish`の成功、および[公開結果のスナップショット](https://github.com/kurochan001/kirimasim-tests/blob/a587ba92e91e4fe2217710c7408614c6649d84e7/README.md)を確認しました。

- スイート：[`73af6e95`](https://github.com/kurochan001/kirimasim-tests/commit/73af6e954828221c3c7447dd13cd3a271ae5bb55)、9,203本。
- レポート生成：2026年10月31日11:16 JST（02:16 UTC）。
- 各シミュレータの対象：formalの268本を除く8,935本。Ghostもこの回ではformalを除いています。
- 一致した本数：Icarus 5,701、Verilator 5,265、kirimasim 6,468、Lyra 6,933、Ghost 8,036。
- kirimasimの版：`17b7192b4f05`。Lyraの版：`e13a017966a5`。

これは対象コミットでの保存記録です。現在のスイートの本数や、別の版での保存クロス実行へ
置き換えません。その後の公開状況は[随時更新のレポート](https://github.com/kurochan001/kirimasim-tests/tree/results#readme)を確認してください。
ワークフローの成功と、全テストの期待結果への一致は別です。

<a id="recorded-example-manual-execution-on-2026-10-24"></a>

## 確認例：2026年10月24日の手動実行

比較対象を5つにした後の最初の公開です。定時の実行ではなく、`main`で手動実行しました。

- 実行：[実行40084390631](https://github.com/kurochan001/kirimasim-tests/actions/runs/40084390631)（`workflow_dispatch`）。
- 開始：2026年10月24日19:03:26 JST（10:03:26 UTC）。
- レポート生成：2026年10月24日21:44:13 JST（12:44:13 UTC）。Lyraを初めてビルドしたため、約2時間40分かかりました。
- レポート表示：`Latest run: 2026-10-24 12:44 UTC`。
- 対象：[suite commit `0073c69`](https://github.com/kurochan001/kirimasim-tests/commit/0073c6947bc210d7b928d0d651ef34d5095b5999)、6,009本。
- 公開：[resultsの更新コミット](https://github.com/kurochan001/kirimasim-tests/commit/71908d7e3482f16c25dfad95ff52478faa6f040d)。
- 一致した本数：Icarus 4,018、Verilator 4,023、kirimasim 4,235、nvc 1,611、Lyra 4,607。

<a id="recorded-example-update-on-2026-10-22"></a>

## 確認例：2026年10月22日の更新

2026年10月23日07:17 JSTに、GitHub Actionsと公開履歴を確認しました。
その時点の最新公開結果は[実行39686633157](https://github.com/kurochan001/kirimasim-tests/actions/runs/39686633157)です。

- 実際の開始：2026年10月22日07:27:34 JST（10月21日22:27:34 UTC）。
- レポート生成：2026年10月22日07:46:03 JST（10月21日22:46:03 UTC）。
- レポート表示：`Latest run: 2026-10-21 22:46 UTC`。
- 対象：[suite commit `4752cea`](https://github.com/kurochan001/kirimasim-tests/commit/4752cea52e9dc0d24ef58240eddee11ef055c673)、3,719本。
- 公開：[resultsの更新コミット](https://github.com/kurochan001/kirimasim-tests/commit/2a5c1cf9af6e55b8b42c4887aa7fda80206e3dc5)。

07:27という開始時刻は結果READMEには表示されません。
07:46という更新時刻は、前日のUTC日付で表示されています。
これは上記の確認時点の記録です。現在の最新結果は公開レポートと実行一覧を確認してください。

<a id="historical-duration-estimates"></a>

## 所要時間の目安

2026年10月24日に、ブランチで手動実行して確認した所要時間です（6,009本）。

| ジョブ | 所要時間 |
| --- | --- |
| Icarus | 1〜3分 |
| kirimasim | 7〜8分 |
| Verilator | 約14分（ccacheが効いている場合） |
| Lyra | テスト35〜70分（キャッシュあり）。未キャッシュのコミットでは、ビルド42〜89分が加わる |

この6,009本での測定では、全体の時間はLyraのジョブで決まり、40分〜1時間15分ほどでした。
現在のテスト数・上流コミット・キャッシュ条件での所要時間を保証する値ではありません。
mainでLyraを初めてビルドした10月24日の実行では、Lyraのジョブが約2時間40分（ビルド89分、テスト70分）かかりました。
変更前（10月23日、4ジョブ）は約42分でした。

Verilatorのジョブでは、各プロセスのアドレス空間を6GBに制限しています（`ulimit -v`）。
名前付きシーケンスが互いを参照する規格違反のコード（`tests/ch16/test_illegal_sequence_cycle_through_bodies.sv`）で、Verilatorが再帰を止めずにランナーのメモリ（16GB）を使い切り、GitHubがジョブを止めたためです。
制限の下では、そのテストだけが失敗します。

<a id="when-current-and-nightly-test-counts-differ"></a>

## 現在のテスト数とNightlyの本数が違う場合

現在の本数は[READMEの自動集計](../README.ja.md#contents)と[テストカタログ](tests/README.ja.md)、
実行した本数は公開レポートの`tests`と`suite commit`を確認してください。
上記の10月31日の9,203本、10月24日の6,009本、10月22日の3,719本は、それぞれ異なるコミットの記録です。
また、スイート全体の本数と各ランナーの対象本数は、formalなどの選択条件により異なります。
新しく追加したテストのNightly結果は、その変更を含むコミットで次の実行・公開が完了してから反映されます。

レポートの`Match`の割合は、そのシミュレータで期待結果と一致したテストの割合です。
IEEE 1800-2023の全動作に対する網羅率とは別の指標です。
後者は刺激・期待結果と要求台帳の対応を確認したうえで計測します。

<a id="where-to-find-requirement-coverage"></a>

## 要求カバレッジを確認する場所

- [mainの集計概要](behavior-coverage-summary.md)：`coverage/results/`の保存済み実行証跡を使った集計。
  最新の値・分母・対象テスト数は、リンク先の生成済み概要で確認してください。
  固定した版と現在の入力に対応するパス結果の記録を使い、Nightlyの一致率とは分けて集計します。
  経過：10月24日の[未対応要求への新規テストの2回目](gap-tests-2-20261024.md)の後は59.59%（7,341）、10月25日に保留中の照合案4区間（p01・p05・p07・p12）を取り込んで63.21%（7,787、テスト6,294本）でした。
  10月26日に残りの区間（p09・p10・p13・p15、附属書とgapの範囲、附属書Aの構文テスト）と追加のテストを取り込み、Icarus 13.0で再現できた規格のみのテスト277本に`:oracle:`を記録し、既存テストの照合で341要求を追加しました。
  2026年10月28日に解釈保留を解決し、重複21行を統合した12,298要求の分母を承認しました。
  現在は設計・実行とも確定値を表示します。承認はAIレビューで、人による独立したレビュー・承認ではありません。
- Nightlyの集計概要：現行の`publish`ジョブが、その回の実行結果だけで生成します。
  出力先は`results`ブランチ直下の`behavior-coverage-summary.md`で、[resultsブランチ](https://github.com/kurochan001/kirimasim-tests/tree/results)から参照できます。
  2026年10月24日からは、Lyraの結果も集計の対象です（規格違反の検出を求める要求は、`:oracle:`に固定バージョンのトークンがあるIcarusとVerilatorの結果だけを数えます）。
- [管理手順](../coverage/README.md)：分母、暫定値と確定値、入力ハッシュ、複数テストの集合証拠の扱い。
- [照合一覧](test-requirement-matching.md)と[ギャップ調査](coverage-gap-recommendations-20261029.md)：現在の照合状況と追加テスト候補。

機能間クロスは要求カバレッジとは別に、`publish`がその回の実行結果から
`interaction-coverage.md`と`interaction-coverage.json`を`results`ブランチへ書き出します。
登録したモデルの2因子・指定した3因子の組合せと、必須ケースの合格をシミュレータ別に確認します。
未対応・既知の差異・未実行のケースを合格に含めず、別々の実行の部分成功も合成しません。
[mainの保存済み集計](interaction-coverage.md)と[導入手順](interaction-verification.md)を参照してください。

公開処理は`README.md`を英語、`README.ja.md`を日本語で生成し、グラフも日英を揃えます。
3種類のカバレッジMarkdownは日本語の`.md`と英語の`.en.md`を生成し、相互リンクで切り替えます。
両言語は同じ保存結果を使い、公開処理でシミュレータを再実行したり、生のJSONを変更したりはしません。
公開ブランチへの追加ファイルの反映は、更新後のツールを使った公開処理が完了してからです。

mainの保存済み証跡には固定バージョンの実行、部分再実行、Ghostのローカル全件実行があり、
Nightlyは各シミュレータの開発版で実行します。
対象コミット・実行範囲・版が異なるため、両者の割合を同一条件の結果として比較しないでください。
集合証拠は同じ実行回の全メンバーの成功を必要とし、別実行の部分成功は合成しません。

<a id="troubleshooting-missing-updates"></a>

## 更新されていないときの確認順

1. 実行一覧で開始済みか、待機中かを確認します。04:23を過ぎても開始遅延の場合があります。
2. 開始済みなら5つのシミュレータジョブと`publish`の状態を確認します。
3. `publish`が成功したら、公開レポートの時刻・`suite commit`・本数を確認します。
4. グラフだけが古く見える場合は、公開レポートと`results`ブランチの更新履歴も確認します。

シミュレータが結果を出す前に失敗した場合、その環境は当該回から欠けることがあります。
`known`・`unsupported`・ビルド失敗を成功に含めたり、過去の結果を当該回へ補ったりしません。
`latest/<simulator>.json`は各環境の最後の結果なので、環境によって更新元の実行回が異なる場合があります。

推移図と結果レポートには、このリポジトリにランナー（`tools/run_<simulator>.py`）があるシミュレータだけを描きます。
2026年10月25日に比較対象から外したnvcなどの過去の結果は、`history.json`と`latest/`に残っていますが、描きません。

<a id="investigating-differ-as-a-defect"></a>

## Differをバグとして調べるとき

Differは失敗したテストの本数で、出力差分・コンパイル失敗・規格違反のコードの受理・診断や終了コードの不一致を含みます。
原因の判断には個別ログ、テストの規格適合性、期待値の規格根拠、診断位置と内容の確認が必要です。
同じ実装上の問題が複数テストに現れる場合や、テスト側に誤りがある場合もあります。
[2026年10月27日の修正](nightly-suite-corrections-20261027.md)では、kirimasimの174 Differから、診断位置の不一致27本とpacked unionの正常系1本を見直しました。

<a id="comparing-saved-cross-runs"></a>

## 保存クロス実行との比較

[機能間クロスの保存実行](interaction-verification.md#保存実行の概要)は、登録モデルから選んだ
テストの結果です。Nightlyの各ランナーの全件結果とは実行範囲が異なります。
同じ日付でも、スイートのコミット、シミュレータのコミットや固定リリース、実行対象を確認して
比較してください。固定版のoracle確認を、Nightlyの開発版への確認済みと読み替えません。

CheckやNightlyのジョブ成功、テストの一致率、クロスの実行充足は別の判定です。
クロスの対象組合せと必須ケースの成功は、入力・期待値・ランナーのハッシュが一致する
個々の記録から判定します。補助的な故障注入や最小例の件数を足したり、別の実行回の
部分成功を合成したりはしません。[証跡の管理](../coverage/README.md#機能間クロスの計画と証跡)を
参照してください。
