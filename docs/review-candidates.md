<a id="review-candidates"></a>

# 期待値のレビュー候補

[English](review-candidates.en.md) / [日本語](review-candidates.md)

[Nightly resultsの見方](nightly-results.md) / [シミュレータと規格の差異](simulator-differences.ja.md) / [節の引用数](coverage-depth.md)

期待値の根拠が規格の読み方にしかないテストと条項を、各シミュレータの最新の結果から自動で挙げます。
候補は誤りの指摘ではありません。規格と照らした見直しで、期待値が正しいか誤りかを判断します。

## 一覧の場所と更新

[`tools/review_candidates.py`](../tools/review_candidates.py)が、Nightlyの`publish`ジョブのたびに、resultsブランチの`latest/`から一覧を作ります。

- [英語の一覧](https://github.com/kurochan001/kirimasim-tests/blob/results/review-candidates.md) / [日本語の一覧](https://github.com/kurochan001/kirimasim-tests/blob/results/review-candidates.ja.md) / [JSON](https://github.com/kurochan001/kirimasim-tests/blob/results/review-candidates.json)
- 読むのはIcarus Verilog・Verilator・kirimasim・Lyra・Ghostの結果だけです。
- 一覧の初めに、各シミュレータの版・時刻・スイートのコミットを示します。ほかより古いコミットの結果には印を付けます。Lyraのジョブが失敗した日は、Lyraの結果が前の実行のままになるからです。
- 手元では`python3 tools/review_candidates.py --results <latestのディレクトリ> --output <出力先>`で作れます。

## 候補の種類

`:type: formal`のテストは除きます。「specのみ」は、`:oracle:`が`iverilog@13.0`も`verilator@5.052`も挙げていないテストです。

| 種類 | 条件 | 見直す理由 |
| --- | --- | --- |
| specのみで、Ghost・kirimasim・Lyraのすべてでfail | どのシミュレータでもpassせず、3つでfail（unsupportedではない） | 独立した3つの実装がそろって違う結果なので、期待値の誤りの可能性が最も高い |
| specのみで、kirimasimだけがpass | ほかのどれもpassしない | テストとkirimasimが同じ読み違いをしている可能性がある |
| specのみで、どこでもpassしないその他のテスト | 上の2つ以外 | 未実装による失敗が多いが、期待値の裏付けがない |
| 固定版のoracleがあり、GhostとLyraの両方でfail | `:oracle:`にIcarus 13.0かVerilator 5.052がある | 期待値がIcarus・Verilatorの振る舞いに引きずられた可能性がある（[`test_readmemh_address_range`の例](simulator-differences.ja.md)） |
| 引用するテストがすべてspecのみの条項 | 3〜40章の対象範囲の末端条項（`tools/clauses.txt`）で、`:lrm:`で引用するテストがすべてspecのみ | 条項全体の裏付けが規格の読み方だけ |

kirimasimとLyraはフロントエンドにslangを共有しているので、構文解析や展開についての両者の一致は独立した裏付けになりません。

## 見直しの順番

人が規格と照らす順番は、一覧の節の順です。

1. specのみで、Ghost・kirimasim・Lyraのすべてでfail
2. specのみで、kirimasimだけがpass
3. specのみで、どこでもpassしないその他のテスト
4. 固定版のoracleがあり、GhostとLyraの両方でfail
5. 引用するテストがすべてspecのみの条項（引用するテストが少ない順）

各節の中は、テストのパスの順です。

## 見直しの記録

- 見直しは、[Lyraと一致しないテストの見直し](lyra-disagreement-review-20261025.md)と同じ形で、`docs/spec-only-review-<日付>.md`と英語版に記録します。
- 期待値が正しければ、根拠の条項をテストのコメントに書き足します。
- 誤りなら期待値を直し、理由と引用した条項をテストのコメントと[履歴](history.ja.md)に残します。生成テストは生成器を直します。
- `:spec_check: ai`は、人が照合するまで変えません。

記録した見直し：まだありません。
