# 人による抽き取りレビュー

[English](review-sample.en.md) / [日本語](review-sample.md)

スイートの期待値はすべてAIが規格と照らしたもので（`:spec_check: ai`）、人が照合したテストはまだありません。全件を人が読むのは現実的でないので、`tools/review_sample.py`で層ごとに無作為にテストを選び、人が規格から期待値を導き直した結果を記録して、層ごとの誤り率の上限を見積もります。

このツールはテストのファイルも`:spec_check:`も変えません。判定は別の台帳`coverage/human-review.json`に置きます。

## 層

固定版のoracle（`:oracle:`の`iverilog@13.0`、`verilator@5.052`、`verilator@5.054`）がなく、formalでないテストを、Nightlyの最新の結果（`results`ブランチの`latest/<シミュレータ>.json`）で分けます。

| 層 | 内容 |
| --- | --- |
| `pass_nowhere` | どのシミュレータでも一致しない |
| `ghost_only` | Ghostだけが一致する |
| `kirimasim_ghost` | kirimasimとGhostだけが一致する |
| `reference_pass` | 最新のIcarus Verilog・Verilator・Lyraのどれかが一致する |

- 結果は、その実行が記録した入力の指紋が、いまのテストの指紋と同じときだけ使います。実行の後でテストが変わっていれば、その実行の結果では分けません。
- resultsブランチの`latest/<シミュレータ>.json`のように、テストごとの指紋を持たない結果は、その実行の`suite_commit`の後でテストの入力ファイルがgitで変わっていないときだけ使います。gitで調べられないとき（浅いクローンなど）は警告を出し、そのまま使います。
- kirimasimだけが一致するテストのように、どの層にも入らないテストは、本数だけを出して選びません。
- 層は章でも絞れます（`--chapter`、繰り返し指定できます）。絞った範囲は標本に記録されます。

## 標本を選ぶ

```sh
git fetch origin refs/heads/results:refs/remotes/origin/results
mkdir -p results/latest
for s in icarus verilator kirimasim lyra ghost; do
  git show origin/results:latest/$s.json > results/latest/$s.json
done
python3 tools/review_sample.py sample --results results/latest --output review-sheet \
  --seed 20261120 --count pass_nowhere=8 --count ghost_only=32 --count kirimasim_ghost=20
```

- 層ごとに、シードと層の名前から作った乱数で、名前順に並べたテストから選びます。同じシード・同じ入力からは同じ標本になります。ある層の本数を変えても、ほかの層の標本は変わりません。
- 出力は`review-sample.json`（記入用）と`review-sample.md`（読む用、`--language en`で英語）です。1本ごとに、パス、引用条項、説明、期待出力（規格違反のテストでは理由とエラーの位置）、各シミュレータの結果、入力の指紋と、空の記入欄を持ちます。

## 判定を記入する

`review-sample.json`の各テストに、次の4つを書きます。

| 欄 | 書くこと |
| --- | --- |
| `verdict` | `correct`（正しい）、`expectation_wrong`（期待値が誤り）、`test_defect`（テストに欠陥）、`contested`（読み方が割れる） |
| `basis_clauses` | 判断の根拠にした条項番号（例：`13.4.4, 4.7`） |
| `reviewer` | レビューした人の名前 |
| `date` | `YYYY-MM-DD` |

`notes`は自由に書けます。判定のないテストは取り込まれません。

```sh
python3 tools/review_sample.py record review-sheet/review-sample.json
```

- 標本を選んだ後でテストが変わっていたら、その判定は取り込まず、選び直しを求めます。
- 不明な判定、空のレビュー者・日付・根拠、`(AI)`のようにAIと書いたレビュー者は拒否します。この台帳は人のレビューだけを記録します。AIのレビューは、これまでどおり日付付きの資料に書きます。
- 1つでも拒否があると、何も書き込みません。同じ人が同じ入力のテストを記録し直すと、前の記録を置き換えます。

## 誤り率の上限

```sh
python3 tools/review_sample.py report [--chapter 37] [--json report.json]
```

層ごとに、いまも有効な判定のあるテストの本数n、誤りのテストの本数k（`expectation_wrong`と`test_defect`）、`contested`のテストの本数、古くなった判定の数と、誤り率の片側95%上限を出します。

- 1本のテストは、何人がレビューしても1本と数えます。だれか1人でも誤りとしたテストは誤り、誤りとした人がなく`contested`とした人がいるテストは`contested`、それ以外は正しいとします。
- 標本を選んだ範囲ごとに分けて数えます。`--chapter`を付けないと全章から選んだ標本だけを、`--chapter 37`を付けると37章から選んだ標本だけを数えます。範囲の違う標本は、同じ母集団からの無作為抽出ではないので、混ぜません。

- k = 0のときは3/n（3の法則）です。60本で5%、300本で1%になります。
- k > 0のときはClopper–Pearsonの片側95%上限です。二項分布の累積確率P(X ≤ k)が5%になる誤り率を求めます。nがごく小さいとき（3本以下）にこれが3/nより小さくなる場合は3/nを使い、誤りが見つかって上限が下がることのないようにします。
- `contested`のテストは誤りに数えず、nにも入れずに、別に数えます。正しいとも誤りとも言えないためです。読み方が割れるテストをどう扱うかは所有者が決めます。
- 記録した後でテストが変わった判定は古いとして、nに入れません。期待値を直したテストは、選び直して読み直します。

`python3 tools/review_sample.py check`は台帳の書式を検査し、Checkのreadmeジョブで実行されます。テストの改名や削除で消えたテストの判定は、誤りにせず、古い判定として数えます。

## レビュー候補との違い

[レビュー候補](review-candidates.md)は、期待値の根拠が規格の読みだけにあるテストを全部挙げます。このツールは、その中から無作為に選んだ一部を人が読むことで、層全体の誤り率に上限を付けます。
