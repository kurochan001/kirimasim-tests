# リポジトリのレビュー（2026-11-21）

[English](repo-review-20261121.en.md) / [日本語](repo-review-20261121.md)

`82b5713f`の時点のリポジトリを、5つのAIのレビュー担当が範囲を分けて読みました。範囲は、判定とランナー、集計と台帳と照合キット、生成器とランダム比較、CIとリポジトリの衛生、テスト全体の機械的な走査です。各担当は、ファイルと行、再現の手順を自分で確かめた指摘だけを返しました。

- 保存済みの結果や公開の数値を誤らせる問題は、ツールにはありませんでした。テストには1本あります（[既存のテストの修正](#tests)の最初の行）。
- 保存済みの結果を無効にしない修正は、このレビューで直しました（[直したもの](#fixed)）。
- ランナー・正規化・既存のテストを変える修正は、変えるとGhostの保存済みの結果が古くなります。Ghostの結果は手元で取り直せないので、ここでは直さずに一覧にし、Ghostの結果を保存し直すとき、または次にランナーを変えるときにまとめて直します。
- このレビューで、要求カバレッジの数値は変わりません（設計93.15%、Ghostを除く実行51.22%、Ghostとkirimasimを含む実行78.71%）。

<a id="fixed"></a>

## 直したもの

| 場所 | 何が起きていたか | 直し方 |
| --- | --- | --- |
| `tools/review_sample.py` | resultsブランチの`latest/<シミュレータ>.json`はテストごとの入力の指紋を持たないので、Nightlyの後に変わったテストも古い結果で層に分けていた。同じテストを複数の人が見ると、その人数をnに数えていた。`contested`もnに入っていた。章で絞った標本と全章の標本を混ぜて数えていた。nが3以下で、誤りが見つかると上限が下がることがあった。改名・削除したテストの判定で`check`が失敗した。 | 指紋のない結果は、その実行の`suite_commit`の後でテストの入力ファイルがgitで変わっていないときだけ使う。1本のテストは1本と数え、`contested`だけのテストはnから除き、標本を選んだ範囲ごとに数える。上限は3/nを下回らないようにする。消えたテストの判定は古い判定として数える。 |
| `tools/sv2023_features.py`、`coverage/sv2023-features.json` | 違法系の印を片方向にしか検査せず、`ch18/test_illegal_unique_real_and_int`を正常系として数えていた。 | 印と`:should_fail_because:`の両方向を検査する。台帳を直し、表を作り直した（rand realの正常系5・違法系5を4・6に）。 |
| `tools/behavior_coverage.py`の生成資料 | 「Ghostを含めて」の値は、kirimasimだけが確かめた90行も含む。 | 「Ghostとkirimasimを含めて」と書く。数値は同じ。 |
| `coverage/README.md` | `ghost-local-20261031.json`を「採用しません」と書いていたが、集計は和集合に含めていた。 | 実際の扱いを書く。この実行だけで確かめた行は0行。 |
| `tools/matching_kit/` | `merge.py`：同じ要求に単独のcheckとANDのグループを同時に入れると、単独で足りるはずのテストがグループの中にしか残らなかった。`propose.py`：シミュレータ別の期待値ファイルへのアンカーを受け入れ、統合の最後の検査で止まった。`runsim.py`：使った版を表示しなかった。`partition.py`：保存済みの一覧だけを読み、新しいテストを候補に入れなかった。 | 単独のテストにはグループがあっても単独のグループを残す。アンカーは共通の`:expected_stdout:`のファイルに限る。各実行の版を最初に表示する。`propose.py`と同じく新しいテストを補う。 |
| `tools/run_lyra.py` | クラッシュしたときも、「not yet supported」の行があれば未対応と記録した。 | シグナルで終わった実行は先に「crashed」とする。Lyraの保存済みの結果はないので、無効になる結果はない。 |
| `tools/lint_metadata.py` | 違法系の`:expected_stderr_regex:`がエラーの場所を指すか、同じ項目を2回書いていないか、`:lrm:`の節が規格にあるかを見ていなかった。 | 規則`stderr-location`、`duplicate-field`、`lrm-clause`を足す。いまのテストで当たるのは`lrm-clause`の3本だけで、既知の問題として記録した（[既存のテストの修正](#tests)）。 |
| `README.md`、`README.ja.md` | `:fourstate:`の定義が、`$isunknown`や`casex`/`casez`を使うだけで`yes`になるように読めた。 | 結果がx/zに依存するかで決めると書き、lintが見るのはx/zリテラルだけだと書く。 |
| `tools/results_history.py`、`tools/behavior_coverage.py`、Nightly | Nightlyの失敗したジョブを再実行すると、同じ実行が履歴に2回入った。2回目は1回目と比べるので、変化が0に見えた。kirimasimのジョブを再実行すると、回帰の比較の相手が同じ実行の1回目になった。resultsブランチを取れなかった夜は、黙って比較を飛ばした。 | 同じ`--run-url`の記録は置き換え、最初の試行の前の実行を`latest/previous/`に残して、それと比べる。要求カバレッジの履歴も同じ実行の記録を置き換える。回帰の比較は、再実行のときは`latest/previous/`と比べ、取得に失敗したら警告を出す。 |
| Nightly、`check.yml`、`benchmark.yml`、`.gitignore` | 非公開のパーサの置き場所に、公開する`results/`なども指定できた。`nightly.yml`だけを変えるコミットでCheckが動かなかった。ベンチマークの`apt-get update`に失敗時の逃げ道がなく、アクションの版のコメントが誤っていた。READMEが出力先に勧める`out/`が無視されていなかった。 | 置き場所から実行が使う・公開するディレクトリを除く。Checkの起動条件に`nightly.yml`と`parser-checkout.yml`を足す。ほかのワークフローと同じ逃げ道を足し、コメントをv7.0.2に直す。`/out/`を無視する。 |
| `generators/record_oracles.py` | 文書どおりに実行すると、Icarusの正しい全結果でも`oracles.txt`の1,041行を壊した（両方の固定版の印の1,007行からVerilatorの印が消える、生成器が登録しないとしたケースに印が付く、コメント行が消える）。 | 渡したシミュレータの印だけを、その結果にあるテストについて付け外しする。両方で再現すれば両方を残す。Verilatorの印は結果の版から決める。生成器が証拠にしないとしたケース（`Case.unregistered`）には付けない。コメントと並びを残す。別のシミュレータや版の結果、実行後に変わったテストの結果は拒否する。いまのIcarusの全結果で試すと、変わる行は0行。 |
| `generators/generate.py` | `oracles.txt`の、どのケースにも当たらない名前、重複、x/zに依存するケースのVerilatorの印を見ていなかった。 | 検査して止める。いまは0件。 |
| `generators/wide_scan.py`、`generators/interaction_litfmt.py` | 16進・8進の最上位の端数の桁で、x/zの大文字・小文字を誤った（`14'bx01010`の`%h`は、規格21.2.1.3の例では`xxXa`）。 | 最上位の桁は、実際にあるビットだけで決める。いまのテストで当たるものは0本で、生成テストは変わらない。 |

<a id="tests"></a>

## Ghostの結果を保存し直すときに直すもの（既存のテスト）

テストの`.sv`を変えると入力の指紋が変わり、Ghostの保存済みの結果が古くなります。次の修正は、Ghostの結果を保存し直すときにまとめます。テストの一覧は[記録](measurements/2026-11-21/repo-review-deferred.json)にあります。

| 種類 | 本数 | 例 | 直し方 |
| --- | ---: | --- | --- |
| 種類を省いたANSI形式の`input`に、ネットにできない型（2状態型、real、string、2状態型の構造体）を使う。種類を省いた`input`はネットになり（23.2.2.3）、ネットはそれらの型を持てない（6.7.1）。どのシミュレータもslangも変数として受理するので、出力は`var`を付けた場合と同じ。 | 正常系24本（うち生成テスト9本）、補助ファイル1本 | `ch23/test_port_data_types_and_ref_share`、生成器`interaction_assertion.py`の`input bit clk` | `input var <型>`にする。lintに同じ検査を足す。 |
| 上の種類のうち、期待値が規格から導けないもの。23.2.2.3の4行は、このテストだけが根拠で、Ghostのpassが「Ghostとkirimasimを含む実行」に入っている。 | 1本 | `ch23/test_vpi_port_kind_defaults`（`input int in_int`、期待値は`int net`） | 4値の型を明示し、期待値を37.16から導き直す。保存し直すまで、その4行の実行確認は最大4行下がる。 |
| 未サイズの値の幅を32として出力する。5.7.1は「少なくとも32ビット」としか決めていない。 | 6本 | `ch11/test_real_operator_result_and_condition`の`$bits(r ? 1 : 2)` | `>= 32`の比較にするか、サイズを付ける。 |
| 違法系に別の違反が重なるか、正規表現が規格上正しい行も受け入れる。 | 5本 | `ch17/test_illegal_checker_enclosing_references`の29行、`ch23/test_illegal_mixed_positional_named_connections`の30〜31行 | 違反を1つに絞り、正規表現の行を直す。ch23の2本はoracleを確かめ直す。 |
| 強度やxを出力するのに`:fourstate: no`。 | 7本 | `ch28/test_wired_logic_strength`（%v） | `:fourstate: yes`にする。 |
| `:lrm:`に規格にない節（6.12.2、6.3.3）がある。lintの既知の問題として記録した。 | 3本 | `ch6/test_cast_shortreal_round_vs_bit_pattern` | 6.12.1、6.9.2に直す。 |
| `verilator@5.052`を持つが、いまの入力では5.054の結果しかない。違法系の2本はIcarusのpassで数えているので、数値は変わらない。 | 8本 | `ch22/test_22_extra_include_syntax` | 5.054への移行のときに直すか、5.052で実行し直して保存する。 |

このほか、`spec`だけの生成テスト29本は、Verilator 5.054が2つのseedの両方で期待出力を出します。5.054へ移るときに`verilator@5.054`を付ける候補です。

<a id="runners"></a>

## 次にランナーを変えるときに直すもの

`tools/suite_results.py`、`tools/normalize_output.py`と各`tools/run_<シミュレータ>.py`は、そのシミュレータの保存済みの結果の指紋に入ります。次の修正は、2026-11-12のレビューで残した4件とあわせて、次にランナーを変えるときにまとめます。

- `:files:`で`.svh`を指すテストは、ディレクトリ全体を入力の指紋に入れる（19本）。たとえば`ch22/test_include_nested`の入力は228ファイルで、ch22のどのテストを変えても古くなる。`` `include ``の名前の候補のパスだけを指紋に入れる。
- Icarusのコンパイルと、Verilatorのビルドが、一時フォルダでなく呼んだ場所で動く。iverilogは相対の`` `include ``をまずそこで探す。
- リポジトリのパスに空白があると、`$finish`や重大度のタスクの行を消す正規表現（`\S+`）が効かない。
- kirimasimのランナーが、`:compilation_unit: single`のテストに`--single-unit`を渡さない。
- 空白だけの行も消す（READMEは空の行と書く）。Icarus、Verilator、Lyra、Ghostが`\f`と`\v`でも行を分ける。
- FSTのランナー：`:fst_expected:`のファイルが入力の指紋に入らず、版と理由に機械のパスが入りうる（このランナーを使うテストはまだない）。
- Ghost、SymbiYosys、slang、FSTのランナーには、1本のテストのエラーをそのテストの失敗にとどめる処理がない。
- Ghostのランナーは、`:dpi_c:`と`:vpi_c:`の両方を持つテストでDPIのファイルだけをビルドする（いまの該当2本の`_vpi.c`は空）。

<a id="decisions"></a>

## 所有者の判断を待つもの

- kirimasimの回帰の比較は、passからunsupportedへの変化を回帰に数えない（`tools/results_ratchet.py`の説明どおり）。kirimasimが以前通った構文に新しく未対応を出しても、ジョブは失敗しない。おすすめは回帰に数えること。
- 履歴のJSONが大きくなり続けている。mainの`coverage/behavior-history.json`は29.9 MB（1日に約1.9 MB）、resultsブランチの`behavior-history.json`は30.9 MB、`coverage/interaction-summary.json`は51.3 MB、`coverage/test-matching.json`は45.6 MB。GitHubは50 MiBで警告し、100 MiBを超えるファイルのpushを拒む。いまの増え方なら、mainの履歴は12月末ごろに100 MiBに届く（推定）。おすすめは、古い回の実行一覧を別のファイルに分けるか捨てること、大きいファイルを分けること、Checkでサイズを検査すること。
- resultsブランチの履歴には、同じ実行の記録が2組ある（実行44656954132と42477954992）。今回の修正は新しい重複を防ぐだけで、既存の2組はそのまま。
- `coverage/interaction-results/cross25`〜`cross29`の10本に、手元のmacOSの一時フォルダのパスが残っている（ホームのパスや個人名ではない）。置き換えると、それらのSHA-256を記録した`coverage/interaction-qualification/*-prior-digests.json`も書き換えることになる。
- Actionsのキャッシュが10 GBの上限を超えている（111件）。Nightlyが毎回約930 MBのccacheを新しいキーで保存しているため。Lyraの4分割はキャッシュがないと失敗するので、Lyraのキャッシュが消されるとその夜のLyraが欠けうる。
- Checkは参照のシミュレータをタグから作り、タグの指すコミットを確かめない（いまのタグの指す先は正しい）。
- `generate.py --check`は、期待値を決める手書きのCファイル（`tests/ch35`の3つ、`tests/ch28`の1つ）の変更を見ない。

<a id="checked"></a>

## 確かめて問題がなかったもの

- 違法系3,060本をIcarusとkirimasimで、`verilator@5.054`の907本をVerilator 5.054で実行した。警告や未対応の行で合格したものはなく、正規表現が指さない行番号を受け入れるものもなかった。
- `:expected_exit:`か実行時の`:expected_stderr_regex:`を持つ160本を、3つの手元のシミュレータで実行した。食い違いは、2026-11-12に保留にしたch23のuwireとch33の5本だけ。
- 生成は決定的（`PYTHONHASHSEED`を変えても9,351本が同じ）。固定版の印を持つ生成テスト6,222本はIcarusで一致した。ランダム比較の22プロファイルは、新しいseedでkirimasimが220本すべて一致した。
- 集計：違法系の固定版の印は、版の文字列と印がそろうときだけ数える。`check_groups`はグループ内がAND、グループ間がOR。ランナーの指紋は、ランナーが読むファイルをすべて含む。
- `tools/metamorphic.py`の変換で意味を変えるものは見つからなかった。
- 秘密情報：Ghostの公開のログ・成果物・resultsブランチに、非公開の名前・パス・診断は出ていない。アクションはすべてSHAで固定され、タグと一致する。
