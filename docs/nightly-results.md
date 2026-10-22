# Nightly resultsの更新時刻と見方

[READMEのグラフ](../README.md#nightly-results) / [公開結果](https://github.com/kurochan001/kirimasim-tests/tree/results#readme) / [実行一覧](https://github.com/kurochan001/kirimasim-tests/actions/workflows/nightly.yml)

## 日本時間ではいつ更新されるか

[Nightlyの設定](../.github/workflows/nightly.yml)は、毎日19:23 UTC、
**日本時間では翌日04:23に開始予定**です。結果の更新時刻は固定ではありません。
GitHub側の開始遅延、待機中の実行、シミュレータのビルド・テスト時間によって遅くなることがあります。

Icarus、Verilator、kirimasim、sukimasimの4ジョブが終了してから、`publish`が実行されます。
`publish`が結果を集計して`results`ブランチへpushすると、READMEから参照しているグラフと結果レポートが更新されます。
`main`へのpushと、Nightly結果の公開は別の処理です。

公開レポートの`Latest run`と`Recent runs`は**UTC表示**です。
この時刻は`tools/results_history.py update`がレポートを生成した時刻で、ワークフローの開始時刻ではありません。
日本時間へ換算するには9時間を足します。日付が変わる場合もあります。
開始時刻・待機状態・終了状態は、レポートの`workflow run`リンク先で確認できます。

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

## 現在のテスト数とNightlyの本数が違う場合

2026年10月23日の`main`には3,938本あります。上記Nightlyの3,719本との差は、
対象コミットが異なるためです。現在の本数は[READMEの自動集計](../README.md#contents)と
[テストカタログ](tests/README.md)、実行した本数は公開レポートの`tests`を確認してください。
新しく追加したテストのNightly結果は、その変更を含むコミットで次の実行・公開が完了してから反映されます。

レポートの`Match`の割合は、そのシミュレータで期待結果と一致したテストの割合です。
IEEE 1800-2023の全動作に対する網羅率とは別の指標です。
後者は刺激・期待結果と要求台帳の対応を確認したうえで計測します。

## 動作カバレッジを確認する場所

- [mainの集計概要](behavior-coverage-summary.md)：`coverage/results/`の保存済み実行証跡を使った集計。
  2026年10月23日時点では、全3,938本のうち943本に要求との対応があり、
  暫定設計網羅率6.43%（792/12,319）、暫定実行確認率5.68%（700/12,319）です。
  確定値は設計・実行とも未確定です。
- Nightlyの集計概要：現行の`publish`ジョブが、その回の実行結果だけで生成します。
  出力先は`results`ブランチ直下の`behavior-coverage-summary.md`です。
  2026年10月23日07:17 JST時点では、この処理を含むNightlyの公開前で、ファイルはまだありません。
  公開後は[resultsブランチ](https://github.com/kurochan001/kirimasim-tests/tree/results)から参照できます。
- [管理手順](../coverage/README.md)：分母、暫定値と確定値、入力ハッシュ、複数テストの集合証拠の扱い。
- [照合の進捗と指摘](existing-test-matching-review-20261022.md)：現在までの照合と追加テストへの入口。

mainの保存済み証跡には固定版の実行と部分再実行があり、Nightlyは各シミュレータの開発版で実行します。
対象コミット・実行範囲・版が異なるため、両者の割合を同一条件の結果として比較しないでください。
集合証拠は同じ実行回の全メンバーの成功を必要とし、別実行の部分成功は合成しません。

## 更新されていないときの確認順

1. 実行一覧で開始済みか、待機中かを確認します。04:23を過ぎても開始遅延の場合があります。
2. 開始済みなら4つのシミュレータジョブと`publish`の状態を確認します。
3. `publish`が成功したら、公開レポートの時刻・`suite commit`・本数を確認します。
4. グラフだけが古く見える場合は、公開レポートと`results`ブランチの更新履歴も確認します。

シミュレータが結果を出す前に失敗した場合、その環境は当該回から欠けることがあります。
`known`・`unsupported`・ビルド失敗を成功に含めたり、過去の結果を当該回へ補ったりしません。
`latest/<simulator>.json`は各環境の最後の結果なので、環境によって更新元の実行回が異なる場合があります。
