<a id="managing-the-coverage-of-the-standard-requirements"></a>

# 規格要求のカバレッジを管理する

[English](README.en.md) / [日本語](README.md)

[現在の集計概要](../docs/behavior-coverage-summary.md)と[全項目の詳細](../docs/behavior-coverage.md)は、 節の引用数とは独立した指標です。全規格の要求台帳に対する**暫定値と確定値を併記**します。 IEEE 1800-2023 の本文1–41章と附属書A–Q、1,740見出しを調査台帳に登録しています。 **全1,740節の資料確認・要求抽出は完了し、2026-10-28に12,298要求の分母を承認しました。** 2026-11-14と2026-11-15に所有者の承認を得て計34行を2行ずつに分け、現在の分母は12,332要求です。 解釈保留は0件です。[抽出結果](../docs/requirement-extraction.md)と [分母レビュー](../docs/denominator-review-20261028.md)に整理の根拠を記録しています。 承認はAIレビューによるもので、人による独立したレビュー・承認ではありません。 初期登録の105件は規格全動作の分母ではありません。全テストについて 動作との対応確認を終えたという意味でもありません。

2026-10-29時点の対応追加と残件は[カバレッジギャップ調査](../docs/coverage-gap-recommendations-20261029.md)、それ以降の対応追加は[履歴](../docs/history.ja.md)、 章別の照合状況は[照合一覧](../docs/test-requirement-matching.md)を参照してください。 テストのない要求を1回の実行で観測できるかどうかで分けたAIの仕分けは[テストのない要求の仕分け（2026-11-20）](../docs/unmapped-requirements-20261120.md)にあります。

Issue #21の組合せ境界は[回帰取り込みレポート](../docs/p1-combination-regressions-20261030.md)と `combination-gaps.json`で管理します。候補ID、既存・新規テスト、規格根拠、観測点、 入力指紋を対応付け、`combination-results/`に実行ごとの結果を保存します。 `combination-qualification/`はビルド版と検査器の故障注入の証跡です。 この台帳への登録は、要求対応の承認や要求カバレッジへの加算ではありません。 `python3 tools/combination_gaps.py --check`は台帳と生成レポートの整合性を検査し、 未対応・不一致を合格へ読み替えません。

<a id="plans-and-evidence-for-feature-interactions"></a>

## 機能間クロスの計画と証跡

機能間クロスは、要求カバレッジとは別に次のファイルで管理します。 [保存実行の概要](../docs/interaction-verification.md#保存実行の概要)から、対象版と残件を確認できます。

- `interaction-summary.json`と[クロス検証レポート](../docs/interaction-coverage.md): 登録モデルの因子・制約・対象組合せ・必須ケースと、各実行の充足状況。
- `interaction-results/`: ランナーが保存した実行結果。入力・期待値・ランナーのハッシュ、 日時、シミュレータの版を照合します。別の実行回の部分成功を合成しません。
- `interaction-qualification/`: 確認元の選別、最小例、独立検算、故障注入、ビルドの補助証跡。 このJSONを回帰実行の成功として取り込んだり、テスト数へ加算したりはしません。

```sh
python3 tools/interaction_coverage.py --check
python3 tools/interaction_coverage.py --list-tests --model membership_container
python3 tools/interaction_coverage.py --model membership_container \
  --results coverage/interaction-results/cross27-kirimasim-latest.json --require-pass
```

`--check`は計画・生成物・集計の整合性を検査します。最後の`--require-pass`は指定した保存実行の 対象組合せと必須ケースの成功を判定します。この例の記録はランナーが変わる前のもので、全ケースが古い証跡（stale）になるため非ゼロを返します。 どちらもシミュレータを起動するコマンドではありません。 再実行は[導入・更新手順](../docs/interaction-verification-method.md)に従い、新しい証跡を保存してください。 保存時に最新コミットを確認した記録でも、その後の上流更新へ自動追従するわけではありません。

<a id="aggregation-of-main-and-aggregation-of-nightly"></a>

## mainの集計とNightlyの集計

`main`の`docs/behavior-coverage-summary.md`は、`coverage/results/`に保存した証跡を使います。 Icarus Verilog・Verilator・kirimasimについて集計に使うのは、2026-11-12にランナーを直した後の固定バージョンIcarus 13.0／Verilator 5.052の全件実行（`full-20261112-*.json`）と、それ以後の再実行・追加テストの実行です（下の[台帳と証跡](#the-logbook-and-the-evidence)に挙げます。2026-11-14から固定版を移すまでに追加したテストのVerilatorは5.054）。 それより前のこれらのシミュレータの全件実行と部分再実行も残していますが、ランナーのハッシュが違うので集計には使いません。 Ghostのローカル全件実行・再実行とSymbiYosysの結果は、ランナーが変わっていないので使います。 集計に使った実行回の一覧は、[集計概要](../docs/behavior-coverage-summary.md#シミュレータ別の実行確認率)の計測元にあります。 各実行回を分けて保持し、現在の入力ハッシュと一致する成功だけを採用します。

Nightlyは各シミュレータの開発版で実行し、`publish`が**その回の結果だけ**を使って `results`ブランチ直下の`behavior-coverage-summary.md`と関連JSON・履歴へ記録します。 Nightlyの`Match`割合はテスト出力の一致率であり、要求台帳に対する要求カバレッジ（テスト設計）・実行確認率とは別です。 対象コミット・版・実行範囲を確認してから結果を比較してください。

Nightlyの開始予定は毎日04:23 JSTです。公開は全ジョブ終了後で、結果レポートの時刻はUTCです。 [日本時間への換算と更新状況の確認方法](../docs/nightly-results.md)を参照してください。

<a id="meaning-of-measurement"></a>

## 計測の意味

[分子と分母の具体例](../docs/faq.md#q16-how-do-design-and-execution-coverage-differ)で、要求への対応、単なる実行、採用可能なPASSを区別できます。複数テストが必要な要求は[同じ実行で全て合格する条件](../docs/faq.md#q19-can-partial-successes-from-different-simulators-satisfy-an-and-group)も確認してください。

- 全規格の要求台帳ベースの暫定値: 全資料の確認が終わった場合に限り、 登録行全体を分母とし、設計対応行数／実行確認行数の割合を表示します。 解釈保留、未対応、未実装も分母に含めます。要求文の出現箇所・条件・初期観測ケースに 重複があるため、意味的に一意な要求の割合としては扱いません。
- 規格全体の確定値: 資料確認に加え、解釈保留と要求単位の重複を整理し、 `behaviors.json`の`denominator_review`を根拠付きで承認するまで確定値の割合を出しません。 親見出しの導入本文、図表、構文制約、例外、エラー、他節参照も調査対象です。 ツール依存、未実装、標準のみの期待値は、除外や成功の理由になりません。
- 登録済み動作の要求カバレッジ（テスト設計）: 観測点をレビューしたテスト対応がある動作数 ÷ 登録動作数。 テストの名前・説明・`:lrm:` 引用だけから対応を推定しません。
- 実行確認率: 現在の入力・ランナーに対応するパス結果の記録がある動作数 ÷ 登録動作数。 環境ごとの値と複数環境の和集合を分けて表示します。和集合は単一ツールの適合率ではありません。
- 資料確認率: 全出典ブロックの分類と要求への対応を終えた節数 ÷ 対象節数。 解釈を保留した要求も抽出して記録します。現在は規定部分・参考部分とも100%です。
- 解釈保留なしの割合: `complete`／`no_behavior`の規定節数 ÷ 規定節数。 全資料の確認が終わっても、解釈保留の節は`in_progress`のままです。 どちらもテストの動作網羅率とは別です。

要求カバレッジ（テスト設計）の100%は、要求台帳の全項目にレビュー済みのテスト対応がある状態です。 実行確認率の100%には、さらに全項目について採用可能な合格証跡が必要です。 資料確認率の100%は出典の確認・分類が完了した状態で、テスト対応や実行成功を意味しません。 いずれも、無限の値・幅・プログラムの全組み合わせを試した証明ではありません。 正常系、境界、エラー、条件分岐、例外は区別して登録してください。

<a id="the-logbook-and-the-evidence"></a>

## 台帳と証跡

- `standard-sections.json`: 全見出しの番号、タイトル、PDFの物理ページ番号（1始まり）、 規定／参考の区別、調査状態。`unreviewed` → `in_progress` → `complete` と進めます。 `complete` はその見出し自身の本文の要求をすべて分解した時だけです。 動作を定義しない本文は、根拠・日付を残して `no_behavior` とします。 参考附属書も台帳に残し、規範要件の分母に混ぜません。
- `behaviors.json`: 安定ID、根拠節、具体的な動作、条件の種類、合格基準、根拠メモ、 対応テスト、テスト刺激（スティミュラス）・期待値の観測箇所、レビュー担当・日付・入力SHA-256。 1件は個別の要求／条件の観測単位です。一つのテストで観測する複数の要求は別IDにします。 `checks: []` は対応未確認の要求です。既存テストに該当ケースがないとは限りません。 新規テストを追加する前に、既存テストの刺激と期待結果を照合して対応を登録します。 集計概要の「既存テストの集計状況」は、対応登録済み本数と未登録本数を表示します。 対応登録済み本数は、少なくとも一つの要求との対応を確認した本数であり、 各テスト全体のレビュー完了数やテストスイートの網羅率ではありません。 複数テストで分担する要求は `check_groups` にグループID・全メンバー・ まとめて満たす条件・レビュー担当・日付を登録します。指定した場合は全checkが いずれかのグループに属する必要があります。グループ内はAND、グループ間はORです。
- `requirement-source-index.json`: 全1,740節の自身の本文の範囲と、全15,846ブロックの 位置・SHA-256。親節の本文と子節を重複させず、ページ境界をまたぐ本文・脚注も保持します。 PDFと抽出テキストのハッシュも記録します。規格本文そのものは含みません。
- `requirement-audit.json`: 確認した各節のすべての出典ブロックについて、要求への対応、 見出し、説明、例、参照先のいずれかを理由付きで記録します。図表の確認方法と範囲も記録します。 `behaviors.json`の`source_spans`と双方向で照合します。未解決の解釈がある節は`in_progress`です。
- `behavior-baseline.json`: 見出しの集合・規定区分・規格出典、要求ID・合格基準、対応済みID、 解釈確定見出しと出典確認済み見出しの基準値。削除、対応解除、要求の緩和、 調査の差し戻し、対象縮小をCIで検出します。 複合証拠の定義と入力ハッシュも固定し、グループを削除して一部の成功で代替する変更を検出します。
- テストの期待出力は、`:expected_stdout:`（共通）と`:expected_stdout_<simulator>:`（`icarus`、 `verilator`、`kirimasim`、`lyra`）を持てます。シミュレータ別のフィールドが優先され、 共通の`:expected_stdout:`は残りのシミュレータの期待値になります。どちらも`@<file>`を参照できます。 入力SHA-256は、実際に選ばれたファイルだけでなく、テストが参照する全期待値ファイルを含みます。 そのため、シミュレータ別ファイルだけを変えた場合も、以前の実行結果はstaleになり、 その結果を使った要求の実行確認は数えません。シミュレータ別の期待値を追加してよいのは、 差分が規格に由来する場合だけです。両方の出力を記録し、規格と矛盾しないことを確かめてください。
- `test-matching.json`: 全既存テストの入力ハッシュ、引用節、対応登録済みID、未承認候補、 解釈保留、正常系／規格違反区分の相違、上位節の引用を記録する照合台帳。 [照合状況](../docs/test-requirement-matching.md)は章別の登録済み／未登録本数を表示します。 全件の候補列挙は検証内容に基づく対応付け完了ではなく、候補だけから動作網羅率は増えません。
- `human-review.json`: [人による抽き取りレビュー](../docs/review-sample.md)の判定。`tools/review_sample.py record`が、人が記入したレビュー用シートから、テスト・層・入力の指紋・判定・根拠条項・レビュー者・日付を取り込みます。テストが変わった判定は古いとして集計から外します。`:spec_check:`は変えず、動作網羅率にも使いません。
- `sv2023-features.json`: 1800-2023で加わった機能の台帳。機能ごとに、条項・要求台帳の行・規格が定める不正な形と、コードを読んでその機能を使うと確かめたテスト（規格違反かどうか）を持ちます。`tools/sv2023_features.py`が検査し、[生成資料](../docs/sv2023-features.md)を書きます。
- `interpretation-splits.json`: 規格の二つの読み方の一方に期待値が従うテストと、規格が定めないことに頼るテストの台帳。テスト・条項・二つの読み方（日英）・期待値が従う読み方・出典の見直しの記録とアンカー・状態を持ちます。`tools/interpretation_splits.py`が検査し、[生成資料](../docs/interpretation-splits.md)を書きます。テストと期待値は変えず、どの集計の分母も変えません。
- `test-matching-reviews.json`: 対応を保留した箇所の、確認範囲・要求ID・理由・刺激／期待値の 根拠・担当・日付・入力ハッシュ。部分観測、期待値／診断の問題、引用の具体化、 複合要求の整理を区別します。`requirement_matching.py`が照合台帳へ取り込み、 古い入力や存在しない根拠を拒否します。この判断記録は対応承認でも、ファイル全体の レビュー完了でもなく、動作網羅率の分子には使いません。
- `results/icarus.json`と`results/verilator.json`: 当時の全スイート3,912本の実測結果。 期待値との照合結果に加え、実行前後の入力一致、ランナーのハッシュ、実行時刻、 シミュレータの版、設定を各ランナーの `--json` が記録します。 `results/citation-refinement-*.json`は、引用メタデータを変更した7本の再実行です。 全スイートの結果を部分実行で上書き・合成せず、別の実行回として保持します。 更新前の入力ハッシュは古い証跡と判定し、複合証拠も同じ実行回の全成功だけを採用します。
- `results/expression-gaps-20261023-*.json`: 式レビュー後に追加した11本の実行結果。 Icarus 13.0とVerilator 5.052のseed 1/73をそれぞれ別の実行回として保存します。 以前の全3,912本の結果を保持し、部分実行を全件実行と扱いません。
- `results/associative-matching-20261023-*.json` : 連想配列の引用修正 7 本と集合メンバー等を含む 40 本の再実行。Verilator 5.052 は 37 pass・ 3 known、Icarus 13.0 は 40 knownである。knownは実行成功へ含めません。[照合結果](../docs/existing-test-matching-associative-arrays-20261023.md) に、対応範囲と集合証拠の不足を記録しています。
- `results/associative-gaps-20261023-*.json`: 連想配列レビュー後に追加した15本の実行結果。 その後変更したwildcard/count各1本は、`associative-wildcard-refinement-20261023-*.json`と `associative-count-refinement-20261023-*.json`へ別実行として保存しました。 保存した実行ではVerilator 5.052のseed 1/73とも8 pass・7 known、Icarus 13.0は15 knownです。 [追加内容と残件](../docs/associative-gap-tests-20261023.md)を参照してください。
- `results/header-vpi-tests-20261023-*.json` : 附属書 I /K/L/MのCヘッダを検証する 24 本と、 37 章の VPI テスト 24 本の実行結果。Icarus 13.0（v13_0 -dirty）は 1 pass・ 47 known、 Verilator 5.052 はseed 1/73とも 17 pass・ 31 knownです。[追加内容と照合結果](../docs/header-vpi-tests-and-matching-20261023.md) を参照してください。
- `results/keyword-tests-20261024-*.json` : `generators/keywords.py` が生成する予約語の規格違反テスト 496 本の実行結果。Icarus 13.0 は 496 pass、 Verilator 5.052 は seed 1/73 とも 493 pass・ 3 known です。[生成内容と対応](../docs/keyword-tests-20261024.md) を参照してください。
- `results/gap-tests-20261024-*.json` : 対応するテストがなかった要求に向けて書き、独立検証を終えた新規テスト 594 本の実行結果。Icarus 13.0 は 239 pass・ 355 known、 Verilator 5.052 は seed 1/73 とも 203 pass・ 391 known です。取り込み後に 3 本（ポート宣言 1 本、 `:lrm:` の引用 2 本）を直し、その再実行を `gap-refinement-20261024-*.json` へ別に保存しました（各 3 known）。[追加内容と照合結果](../docs/gap-tests-20261024.md) を参照してください。
- `results/gap-tests-2-20261024-*.json` : 同じ作業の 2 回目で独立検証を終えた新規テスト 933 本と、入力ハッシュが変わった `tests/ch22` の既存 4 本の実行結果。Icarus 13.0 は 529 pass・ 408 known、 Verilator 5.052 は seed 1/73 とも 504 pass・ 433 known です。[追加内容と照合結果](../docs/gap-tests-2-20261024.md) を参照してください。
- `results/gap4-20261025-*.json` : 保留していた照合案のうち、 p01 ・ p05 ・ p07 ・ p12 の 4 区間を独立検証して取り込んだ 256 本の実行結果。Icarus 13.0 は 132 pass・ 124 known、 Verilator 5.052 は seed 1/73 とも 129 pass・ 127 known です。
- `results/gap5-20261026-*.json` : 同じ照合の第 2 弾として p09 ・ p10 ・ p13 ・ p15 を検証して取り込んだ 188 本の実行結果。Icarus 13.0 は 62 pass・ 126 known、 Verilator 5.052 は seed 1/73 とも 49 pass・ 139 known です。
- `results/ch22-rehash-20261026-*.json`と`results/p10-refinement-20261026-*.json`: ch22のinclude fixture復元で入力ハッシュが変わった既存10本と、`:lrm:`から背景節を外した1本の再実行。
- `results/gap6-20261026-*.json` : wave4 の a01 〜 a05 ・ g05 ・ g08 ・ g09 ・ h01 ・ h02 を検証して取り込んだ 176 本の実行結果。Icarus 13.0 は 49 pass・ 127 known、 Verilator 5.052 は seed 1/73 とも 82 pass・ 94 known です。
- `results/ch37-depth-20261026-*.json`: 深さ検査のため37.4.2の2本目として既存VPIテストへ引用を足した再実行。
- `results/gap7-20261026-*.json` : K.2 ヘッダ 31 ・ I.3 DPI 55 ・ N.2 分布 7 の要求に向けて書いた 18 本の実行結果。Icarus 13.0 は 3 pass・ 15 known、 Verilator 5.052 は seed 1/73 とも 14 pass・ 4 known です。
- `results/gap8-20261026-*.json`: 20.11アサーション制御42・40章カバレッジ20・17章checker 29・36.12.1互換8の要求に向けて書いた30本の実行結果。 すべて `:oracle: spec` で、Icarus 13.0は0 pass・30 known、Verilator 5.052はseed 1/73とも4 pass・26 knownです。
- `results/gap9-20261026-*.json` : 附属書 A の構文要求に向けて書き、独立検証を終えた 93 本の実行結果。Icarus 13.0 は 17 pass・ 76 known、 Verilator 5.052 は seed 1/73 とも 44 pass・ 49 known です。
- `results/ch5-rehash-20261026-*.json`と`results/ch19-depth-20261026-*.json`: includeディレクトリの入力変化と、深さ検査のため背景節を外した再実行。
- `results/audit-full-20261026-icarus13.json`と`results/audit-spec-20261026-verilator-*.json`: 全6799本のIcarus実行と、spec-only 1645本のVerilator実行（seed 1/73）。
- `results/quality-20261027-verilator-*.json`: 品質監査で未実行だったリンク先68本のVerilator再実行（seed 1/73）。
- `results/quality-vpi-20261027-verilator-*.json`: 両ヘッダincludeに直したVPIヘッダ2本の再実行。
- `results/refresh-20261027-icarus13.json`: ランナー刷新後のIcarus Verilog 13.0全件実行（VPIビルド修正済み）。
- `results/refresh-20261027-verilator-seed1.json`: ランナー刷新後に未実行リンク先2,706本をVerilator 5.052 seed 1で再実行。
- `results/ch16-sim-20261028-*.json`と`results/ch16-edge-20261028-*.json`: ch16の残り16要求を検証するシミュレーションテストの実行結果。
- `results/ch6-extra-20261028-*.json`・`results/ch9-extra-20261028-*.json`・`results/ch21-extra-20261028-*.json`: 6章・9章・21章の追加シミュレーションテストの実行結果。
- `results/ch37-extra-20261028-*.json`・`results/ch38-extra-20261028-*.json`・`results/ch38-reuse-20261028-*.json`: 37章・38章VPIの追加・再利用テストの実行結果。
- `results/ch22-extra-20261028-*.json`・`results/ch23-extra-20261028-*.json`・`results/ch31-extra-20261028-*.json`: 22章・23章・31章の追加・再利用テストの実行結果。
- `results/ch19-extra-20261028-*.json`: 19章covergroupのVerilator実行とIcarusのknown記録。
- `results/chA-extra-20261028-*.json`・`results/chH-extra-20261028-*.json`・`results/ch36-extra-20261028-*.json`: 附属書A/Hと35/36章の追加・再利用テストの実行結果。
- `results/ch34-extra-20261028-*.json`・`results/ch19-rest-20261028-*.json`・`results/ch35-rest-20261028-*.json`: 34章の境界テストと19/35章の残り要求の実行結果。
- `results/formal-20261027-sby.json`: 2026-10-27のSymbiYosysによる`:type: formal`のテストの実行。268本がpassで、そのうち`ch16/test_formal_fusion`は今はスイートにありません。
- 2026-10-28のランナー選択修正: `:type: formal` をシミュレーション対象から外した。 判定処理（`run()`）は変えていないため、Icarus/Verilatorの採用中スナップショットは 状態を変えずに`runner_sha256`だけを更新した。 [記録](../docs/runner-selection-20261028.md)を参照。
- `results/issues-20261028-icarus13.json`・`results/issues-20261028-verilator.json`: Issue #6–#19のテスト側修正で変更した46本の再実行（Icarus Verilog 13.0）と、 Verilator 5.052による全7,472本の再実行。テスト側の修正と来歴更新は [記録](../docs/test-side-fixes-20261028.md)を参照。
- `results/ghost-local-20261028.json`: Ghostのローカル全件実行。対象はスイート`23b4c542`の7,629本、 ビルド識別子は`d59b7c7f8feb`で、5,823 pass・1,806 fail（76.3%一致）です。 実行時間は約3分25秒。同名の`.log`に不一致の一覧を保存しています。 実行前後の入力一致とランナーのハッシュを検証済みです。非公開の実行プロファイルや内部診断は含めません。 規格違反の検出を求める要求は従来どおり固定バージョンoracleの証跡だけを採用し、Ghostのpassでは実行確認を増やしません。
- `results/ghost-local-20261031.json`: Ghostのローカル全件実行。対象はスイート`c53a5603`の9,139本、 ビルド識別子は`88d08d9c3441`で、8,382 pass・757 fail（91.72%一致）です。 実行時間は約2分7秒。同名の`.log`に不一致の一覧を保存しています。 実行前後の入力一致とランナーのハッシュを検証済みです。非公開の実行プロファイルや内部診断は含めません。 再構成したローカルプロファイルによる実行で公式nightlyの証跡ではないため、実行確認率には採用しません。 回帰8本は非公開のIssueに記録しています。
- `results/ghost-local-20261031-strict.json`: Ghostのローカル全件実行（LRM準拠モードを有効にした非公開プロファイル）。 対象はスイート`c0f9905b`の9,211本、ビルド識別子は`7ed5e63eedf9`で、8,524 pass・687 fail（92.54%一致）です。 同名の`.log`に不一致の一覧を保存しています。実行前後の入力一致とランナーのハッシュを検証済みです。 非公開の実行プロファイルや内部診断は含めません。 既定プロファイルの同じ9,211本（8,427 pass）と比べ、規格違反の受理は223本から101本へ減りました。 残る101本はGhost側の非公開のIssueに原因ごとに分類しています。 拒否はしたものの診断の位置形式が一致しない10本も、同じく非公開のIssueに記録しています。 LRM準拠モードで新たに落ちた22本のうち20本はテスト側の非準拠（§6.21 B007の18本、§13.5.2の2本）で、 明示的な`static`/`automatic`を追加して修正しました。残る2本もGhost側で修正済みです （§6.5の独立要素ドライバの判定と、`with (...).size()`のstrictパーサ差）。 保存済みの他の実行結果との和集合で、対応済み要求の実行確認に加わります。
- `results/test-fixes-20261031-*.json`: §6.21 B007 と §13.5.2 のテスト側修正で変更した20本と、 §26.2 の集合証跡を揃えるために同時に再実行した2本の結果です。 Ghost（既定）は22/22、Icarus Verilog 13.0 と Verilator 5.052 は対応するテストのみを実行しています。 この再実行時点の実行確認率は77.47%でした。
- `results/ghost-local-20261031-strict2.json`: Ghostのローカル全件実行（LRM準拠モード）。 対象はスイート`f446a74c`の9,470本、ビルド識別子は`be060962f878`で、8,710 pass・760 fail（91.97%一致）です。 同名の`.log`に不一致の一覧を保存しています。実行前後の入力一致とランナーのハッシュを検証済みです。 非公開の実行プロファイルや内部診断は含めません。 前回のstrict実行（9,211本）から回帰1本・改善26本で、新規テスト259本のうち98本が失敗しました。 新規失敗は生成crossテストの6クラスタ（遅延付き連続代入60本、default引数8本、暗黙感度9本、import shadow 6本、ループNBA 2本、event仮引数13本でspec-only）に分類でき、Ghost側の非公開のIssueに記録しています。 回帰1本はtriregのcharge strengthです。 違法設計の受理は102本で、うち1本は既存の非公開Issueの更新対象です。 保存済みの他の実行結果との和集合で、対応済み要求の実行確認に加わります。
- `results/quality-persim-20261027-*.json`: シミュレータ別期待値のパイロット実行（19本）。
- `results/audit-oracle-20261026-icarus13.json`: spec-onlyのうちIcarus 13.0で一致した277本へ`iverilog@13.0`を追加した後の再実行（277/277 pass）。
- `results/regex-refinement-20261025-*.json` : 判定の正規表現をメッセージの書式に依存しない形に直した `ch16` の 2 本の再実行。Icarus 13.0 は 2 known、Verilator 5.052 は seed 1/73 とも 1 pass・ 1 known です。[見直しの記録](../docs/lyra-disagreement-review-20261025.md) を参照してください。
- `results/oracle-refinement-20261025-*.json`: `:oracle:`に誤って`iverilog@13.0`とあった取り込みテスト3本（`tests/imported/`）を`spec`に直した後の再実行。 Icarus 13.0とVerilator 5.052（seed 1/73）とも3 knownです。
- `results/sva-m3-corrections-20261026-*.json`: 独立SVA参照評価器で見つかった期待値・説明の誤り2本を、ユーザー承認後に修正した再実行。 Icarus 13.0とVerilator 5.052のseed 1/73とも2 knownです。参照評価器との一致は実行確認率に含めません。
- `results/nightly-suite-corrections-20261027-*.json` : Nightly の診断不一致等から修正した 28 本と既存の packed union負例 1 本の再実行。Icarus 13.0 は 9 pass・ 20 known、 Verilator 5.052 は seed 1/73 とも 8 pass・ 21 known です。ローカル kirimasim は 27 pass・ 1 unsupported・ 1 failで、規格違反テストの固定バージョンoracleとして認定していません。[修正根拠・11本のoracle取り消し・残件](../docs/nightly-suite-corrections-20261027.md) を参照してください。
- `results/full-20261112-*.json`: 2026-11-12にランナーを修正した後の全件実行。ランナーのハッシュが変わったので、それまでのIcarus Verilog・Verilator・kirimasimの結果ファイルは集計に使いません（ファイルは残します）。対象は形式検証を除く11,998本です。Icarus Verilog 13.0は6,955 pass・5,043 known、Verilator 5.052のseed 1（`--all`）は6,574 pass・5,424 known、seed 73（Verilatorで期待出力を記録した3,055本）は3,055 pass、kirimasim `7de185f776a1`は9,475 pass・2,394 unsupported・129 failです。GhostとSymbiYosysの結果は、ランナーが変わっていないのでそのまま使います。[履歴](../docs/history.ja.md)の2026-11-12の項を参照してください。
- `interaction-results/full-20261112-*.json`と`combination-results/issue21-20261112-*.json`: 同じランナーでの再実行。kirimasim `7de185f776a1`は選択した4,416ケースを1回で実行し、3,915 pass・487 unsupported・14 failです。Icarus Verilog 13.0とVerilator 5.052（seed 1/73）は、モデルの利用できる4,690ケースを実行しました。Icarusは2,768 pass・1,922 known、Verilatorはseed 1が2,102 pass・2,588 known、seed 73が2,097 pass・2,593 knownです。Issue #21の88本は、Icarusが11 pass・77 known、Verilatorがseed 1/73とも27 pass・61 known、kirimasimが68 pass・19 unsupported・1 failです。それまでのファイルは残しますが、ランナーのハッシュが違うので証跡には数えません。
- `interaction-results/full-20261112-kirimasim-7de185f7-edgedpiquery.json`と`interaction-results/edgedpiquery-20261112-*.json`: 2026-11-12に、同じ内容のケースを選ばないように二つのクロスモデルを改訂した後の実行。kirimasim `7de185f776a1`は選択した4,413ケースを1回で実行し、3,915 pass・484 unsupported・14 failです。Icarus Verilog 13.0とVerilator 5.052（seed 1/73、`--all`）は、二つのモデルの80ケースを実行しました。Icarusは64 pass・16 known、Verilatorはseed 1/73とも22 pass・58 knownです。[履歴](../docs/history.ja.md)の2026-11-12の項を参照してください。
- `results/oracle-tokens-20261112-*.json`: 不正な設計のテスト259本の`:oracle:`から、`iverilog@13.0`を254個、`verilator@5.052`を6個取り除いた後の再実行。対象は、入力のダイジェストが変わった273本（上の259本、コメントだけを直した3本、ディレクトリ全体をハッシュする`tests/ch22`の11本）と、同じ検査グループに入っている73本の、合わせて346本です。Icarus Verilog 13.0は305 pass・41 known、Verilator 5.052（`--all`）はseed 1と73のどちらも175 pass・171 known、kirimasim `7de185f776a1`は303 pass・33 unsupported・10 failです。どの状態も`full-20261112-*.json`と同じです。[記録](../docs/oracle-token-review-20261112.md)を参照してください。
- `results/oracle-tokens-2-20261112-*.json`: 同じ日の2回目の見直しで、不正な設計のテスト10本の`:oracle:`から、`iverilog@13.0`を8個、`verilator@5.052`を3個取り除いた後の再実行。対象は、入力のダイジェストが変わった10本と、同じ検査グループに入っている1本の、合わせて11本です。Icarus Verilog 13.0は9 pass・2 known、Verilator 5.052（`--all`）はseed 1と73のどちらも9 pass・2 known、kirimasim `7de185f776a1`は10 pass・1 unsupportedです。どの状態も、それまでに保存した結果と同じです。[記録](../docs/oracle-token-review-20261112.md#second-pass)を参照してください。
- `results/oracle-tokens-3-20261112-*.json`: 同じ日の3回目の見直しで、不正な設計のテスト9本の`:oracle:`から、`verilator@5.052`を9個取り除いた後の再実行。対象は、入力のダイジェストが変わった9本と、同じ検査グループに入っている4本の、合わせて13本です。Icarus Verilog 13.0は11 pass・2 known、Verilator 5.052（`--all`）はseed 1と73のどちらも12 pass・1 known、kirimasim `7de185f776a1`は12 pass・1 unsupportedです。どの状態も、それまでに保存した結果と同じです。[記録](../docs/oracle-token-review-20261112.md#third-pass)を参照してください。
- `results/test-fixes-20261112-*.json`: 2026-11-12に、どのシミュレータでも合格しないテストを見直してテスト21本を直した後の再実行。対象は、入力のダイジェストが変わった21本と、同じ検査グループに入っている1本の、合わせて22本です。Icarus Verilog 13.0は22 known、Verilator 5.052（`--all`）はseed 1と73のどちらも22 known、kirimasim `7de185f776a1`は22 unsupportedです。どの状態も、それまでに保存した結果と同じです。[記録](../docs/pass-nowhere-review-20261112.md)を参照してください。
- `results/runtime-errors-20261112-*.json`: 2026-11-12に追加した、実行時エラーの要求7件と15.4.5の宛先の要求1件のテスト10本の実行。Icarus Verilog 13.0は10 known、Verilator 5.052（`--all`）はseed 1と73のどちらも1 pass・9 known、kirimasim `7de185f776a1`は1 pass・9 unsupportedです。Verilatorで合格するのは`ch6/test_cast_task_enum_value_runtime_error`、kirimasimで合格するのは`ch7/test_dynamic_array_new_negative_size_runtime_error`です。[履歴](../docs/history.ja.md)の2026-11-12の項を参照してください。
- `interaction-results/full-20261112-kirimasim-7de185f7-dpi-array.json`と`interaction-results/dpi-array-20261112-*.json`: 同じ日に、クロスモデル`dpi_openarray_shape`の`svIncrement`の期待値を直した後の実行。kirimasim `7de185f776a1`は選択した4,413ケースを1回で実行し、3,915 pass・484 unsupported・14 failです。Icarus Verilog 13.0とVerilator 5.052（seed 1/73）は、このモデルの30ケースを実行しました。Icarusは30 known、Verilatorはseed 1/73とも18 pass・12 knownです。章間CSVは、現在は後の実行`interaction-results/full-20261114-kirimasim-77c27531-progmod.json`を使います（[章間マトリクス](../docs/chapter-cross-matrix.md)を参照）。
- `results/test-fix-20261113-*.json`: 2026-11-13に#60の`ch31/test_31_extra_fullskew_active_flag`を直した後の再実行。Icarus Verilog 13.0とVerilator 5.052（seed 1と73）は1 pass、kirimasim `7de185f776a1`は1 unsupportedで、どの状態も変わっていません。[履歴](../docs/history.ja.md)の2026-11-13の項を参照してください。
- `results/reqgap-20261114-*.json`: 2026-11-14に、テストのない要求のために追加したテスト41本と、`tests/ch3`にファイルが増えて入力ハッシュが変わった既存の1本（`ch3/test_include_text_joins_compilation_unit`）の実行。Icarus Verilog 13.0は15 pass・27 known、Verilator 5.054はseed 1と73のどちらも22 pass・20 known、kirimasim `77c27531437c`は31 pass・10 unsupported・1 failです。Verilatorは、固定版を5.054へ移す間の扱い（[移行中の固定版](../docs/simulator-differences.ja.md#verilator-5054-interim)）により5.054で実行しました。既存の1本は`verilator@5.052`のままで、5.052での確認はCheckで行います。
- `results/vifsense-20261114-*.json`: 2026-11-14に追加した、virtual interfaceの要素をalwaysとalways_ffの感度リストに置く違反テスト2本の実行。Icarus Verilog 13.0は宣言の構文エラーで2 known、Verilator 5.054はseed 1と73のどちらも設計を受理して2 known、kirimasim `77c27531437c`は2 unsupportedです。
- `results/reqgap2-20261114-*.json`: 2026-11-14に、6・7・8・9・11章のテストのない要求のために追加したテスト60本の実行。Icarus Verilog 13.0は22 pass・38 known、Verilator 5.054はseed 1と73のどちらも31 pass・29 known、kirimasim `d1d8a1782d0a`は36 pass・20 unsupported・4 failです。Verilatorは[移行中の固定版](../docs/simulator-differences.ja.md#verilator-5054-interim)により5.054で実行しました。
- `results/reqgap3-20261114-*.json`: 2026-11-14に、同じ日の見直しの前は違反する設計でしか示せなかった台帳の行（6・7・8・13章）のために追加したテスト48本の実行。Icarus Verilog 13.0は28 pass・20 known、Verilator 5.054はseed 1と73のどちらも23 pass・25 known、kirimasim `d1d8a1782d0a`は44 pass・3 unsupported・1 failです。Verilatorは[移行中の固定版](../docs/simulator-differences.ja.md#verilator-5054-interim)により5.054で実行しました。
- `results/intcompat-20261114-*.json`: 2026-11-14に、絞った行`SV2023-6.22.3-EXTRACT-INTEGRAL-COMPATIBILITY`のために追加したテスト1本の実行。Icarus Verilog 13.0とkirimasim `d1d8a1782d0a`はpass、2状態のシミュレータであるVerilator 5.054は、テストがxとzを代入するのでseed 1と73のどちらもknownです。
- `results/vpidpi-20261114-*.json`: 2026-11-14に6・35・37・38章と附属書Hのために追加したテスト31本（多くはVPIとDPIのテスト）の実行。Icarus Verilog 13.0は9 pass・22 known、Verilator 5.054はseed 1と73のどちらも7 pass・24 known、kirimasim `d1d8a1782d0a`は7 pass・24 unsupportedです。Verilatorは[移行中の固定版](../docs/simulator-differences.ja.md#verilator-5054-interim)により5.054で実行しました。
- `results/reqgap5-20261114-*.json`: 2026-11-14に3〜5・8〜13・16〜22・30・31・33章のために追加したテスト79本と、自分のディレクトリに新しいファイルが入って入力の指紋が変わった既存のテスト13本（ch22のincludeのテスト11本、`ch5/test_identifier_1024_characters`、`ch3/test_include_text_joins_compilation_unit`）の実行。Icarus Verilog 13.0は41 pass・51 known、Verilator 5.054はseed 1と73のどちらも36 pass・56 known、kirimasim `d1d8a1782d0a`は47 pass・42 unsupported・3 failです。Verilatorは[移行中の固定版](../docs/simulator-differences.ja.md#verilator-5054-interim)により5.054で実行しました。
- `results/c2tests-20261115-*.json`: 2026-11-15に同じ日に書き直した台帳の行（3〜5・8〜10・13・16〜22・30・35章）のために追加したテスト80本と、自分のディレクトリに新しいファイルが入って入力の指紋が変わった既存のテスト13本（ch22のincludeのテスト11本、`ch5/test_identifier_1024_characters`、`ch3/test_include_text_joins_compilation_unit`）の実行。Icarus Verilog 13.0は49 pass・44 known、Verilator 5.054はseed 1と73のどちらも49 pass・44 known、kirimasim `d1d8a1782d0a`は73 pass・16 unsupported・4 failです。Verilatorは[移行中の固定版](../docs/simulator-differences.ja.md#verilator-5054-interim)により5.054で実行しました。
- `results/ch19-tables-20261115-*.json`: 2026-11-15に表19-2・19-4と19.8のために追加した20本の実行。Icarus Verilog 13.0は17 pass・3 knownですが、17本の拒否はcovergroup未対応によるもので、規格違反の実行確認には数えません。Verilator 5.054はseed 1と73のどちらも2 pass・18 knownで、coverpoint・crossでの`set_inst_name`の拒否を確認します。kirimasim `d1d8a1782d0a`は19 pass・1 unsupportedです。生成した17本のoracleはspecのみで、kirimasimの拒否も実行確認には数えません。
- `results/strength-events-20261115-*.json`: 駆動強度の5本と、イベント配列の添字変更で発火しないことを確認する1本、計6本の実行。Icarus Verilog 13.0は5 pass・1 known、Verilator 5.054はseed 1と73のどちらも1 pass・5 known、kirimasim `d1d8a1782d0a`は6 passです。強度の5本はIcarus、イベントの1本はVerilator 5.054で期待値を再現しています。
- `results/keywords-inherited-20261115-*.json`: 1364-2001・1364-2001-noconfig・1800-2005・1800-2009・1800-2012の完全な予約語集合を確認する違法系949本（新規の継承語・noconfigの804本と、既存の各版の追加語145本）の実行。Icarus Verilog 13.0とkirimasim `d1d8a1782d0a`は各949 pass、Verilator 5.054はseed 1・73の両方で947 pass・2 knownとなり、2009・2012モードの`global`を識別子として受理します。新規の`include`の3本はVerilatorが未対応診断も出すため、ランナーの記録がpassでも、この版をoracleに登録しません。各完全集合の要求はANDの区画で対応付け、単一の保存実行で全メンバーが合格したときだけ実行確認に数えます。
- `results/primitives-20261115-*.json`: 4要素のゲート配列の端子幅が不正な56本、範囲とスカラ共有が合法な5本、曖昧な強度の合成20本、計81本の回帰テストの実行。Icarus Verilog 13.0とkirimasim `d1d8a1782d0a`は各81 passです。Verilator 5.054はseed 1・73で各39 pass・42 knownとなり、出力幅が不正な20本を受理し、合法22本の4値・強度の観測を再現しません。強度20本は曖昧範囲の和集合の要求に対する1つのAND区画を構成します。残る61本は対応付けを増やさず回帰テストを拡充します。
- `results/arrayfunc-20261115-*.json`: 関数呼出し結果の直接選択24本と、VPIによるprimitive配列の同一性15本、計39本の実行。Verilator 5.054はseed 1・73で各24 pass・15 known、kirimasim `d1d8a1782d0a`は24 pass・15 unsupported、Icarus Verilog 13.0は39 knownです。VPIの15本は固定版ではビルド段階で止まり、kirimasimはC helperを読み込めません。C11/C++17の標準ヘッダ検査と独立mockへの故障注入は検査器の確認であり、シミュレータの実行確認には数えません。VPIの15本は1つのAND設計対応を構成し、その実行確認は未達です。関数24本は新たな要求対応を付けず回帰テストを拡充します。
- `results/constcall-20261115-*.json`: runtimeのoutput・inout・ref引数30本と、module・package・static class内の定数呼出し30本、計60本の合法な関数の回帰テスト。Verilator 5.054はseed 1・73で各60 pass、kirimasim `d1d8a1782d0a`は60 pass、Icarus Verilog 13.0は20 pass・40 knownです。Icarusで一致したのはmodule・packageの定数呼出しで、通常関数のnoninput formalとstatic class呼出しは未対応です。定数呼出しの実引数は全てリテラルかパラメータです。新たな要求対応を付けず回帰テストを拡充するため、要求の網羅率と実行確認数は増えません。
- `results/arrayrefs-20261115-*.json`: 動的配列・連想配列の要素参照の寿命を調べる80本。幅1/8/32/33/65と符号の有無、再確保・同値の全体代入・削除と再挿入・別要素の更新を含みます。Verilator 5.054の両seedは各16 pass・64 known（34本で値の差異、30本は連想配列要素のref actualが未対応）、kirimasim `d1d8a1782d0a`は50 pass・30 unsupported、Icarus Verilog 13.0は80 knownです。Verilatorの両seedで一致した16本だけを固定版oracleとして登録し、残る64本はspecのみです。新たな要求対応はなく、網羅率と実行確認の分子は変わりません。
- `results/wide-boundaries-20261116-*.json`：255/256/257・511/512/513ビットの境界回帰42本を実行した7証跡です。Icarus Verilog 13.0は30 pass・12 known、Verilator 5.054はseed 1と73で各18 pass・24 known、kirimasim 0.1.0 `cfa2ccd75989`は4回とも42 passです。固定版ツールの成功を合わせて全42本を確認でき、4状態のケースにはVerilatorをoracle登録していません。[検査記録](qualification/wide-boundaries-20261116.json)には、実際にソースを変異させた42本について、元のテストの成功と出力差の検出を保存しました。要求との対応付けは追加せず、要求カバレッジの件数は増やしていません。
- `results/bitquery-20261119-*.json`：広幅ビット集計の新規回帰48本について、各48本を実行した4証跡です。Icarus Verilog 13.0は45 pass・3 known、Verilator 5.054はseed 1と73で各18 pass・30 known、kirimasim 0.1.1 `441dddbd0fcd`は48 passです。oracleはIcarusの45本と、2値の関数返り値を直接渡すVerilatorの3本で確認し、4値ケースへVerilatorは登録していません。[検査記録](qualification/bitquery-20261119.json)には、65ビットの対照8本の成功と、コンパイル・実行に成功した実ソース変異16件の出力差を保存しました。新しい要求対応は追加していません。
- `results/array-shape-20261119-*.json`：配列形状の回帰60本を実行した7証跡です。Icarus Verilog 13.0は60 known、Verilator 5.054はseed 1と73で各30 pass・30 known、kirimasim 0.1.1 `441dddbd0fcd`は4回とも48 pass・12 unsupportedです。一致した30本だけにVerilatorのoracleを登録し、残る30本はspecのみです。コンテナ全体の実行時`$bits`12本は形状照会から分離し、未対応を成功へ数えていません。[検査記録](qualification/array-shape-20261119.json)は対照8本の成功と、コンパイル・正常終了した実ソース変異16本の出力差を記録します。要求対応・分母・baselineは変更していません。
- `results/stream-boundaries-20261119a-*.json`：ストリーミング境界96本を実行した7証跡です。Icarus Verilog 13.0は96 known、Verilator 5.054はseed 1と73で各61 pass・35 known、kirimasim 0.1.1 `441dddbd0fcd`は4回とも96 passです。Verilatorの61本だけに固定版oracleを登録し、残る35本はspecのみです。24本の4値ケースへVerilatorは登録していません。[観測検査](qualification/stream-boundaries-20261119a.json)は成功する対照16本と、コンパイル・正常終了した32本の実ソース変異の出力差です。独立AIレビューで540期待行を照合し、新しい要求対応は加えていません。
- `results/packed-lanes-20261119b-*.json`：入れ子のパック配列192本の記録7件です。Icarus 13.0は192 known、Verilator 5.054はseed 1と73で各144 pass・48 known、kirimasim 0.1.1 `441dddbd0fcd`は4回とも50 pass・142 failです。内側添字をずらした組は2 pass・94 fail、0始まりの対照は48 pass・48 failです。2値で一致したVerilator144本だけにoracleを付け、4値には付けていません。[有限の検査](qualification/packed-lanes-20261119b.json)は、成功する65ビット・0始まり・内側降順の対照8本と、コンパイル・正常終了した変異16本の出力差です。独立AIレビューは別々に封印した二組の3,456期待行を確認しています。要求対応は変更していません。
- `results/division-boundaries-20261119c-*.json`：`+nonce=1`を記録した実行時除算・剰余72本の証跡7件です。Icarus 13.0は63 pass・9 known、Verilator 5.054はseed 1と73で各71 pass・1 known、kirimasim 0.1.1 `441dddbd0fcd`は4回とも72 passです。固定版oracleはIcarusの一致63本とVerilatorだけの一致9本です。[有限の検査](qualification/division-boundaries-20261119c.json)は、成功する符号付き・符号なし65/257ビットの対照16本と、コンパイル・正常終了した変異32本の出力差を記録しています。独立AIレビューは1,410期待行すべてを確認し、要求対応は変更していません。
- `results/fourstate-boundaries-20261119d-*.json`：4値の境界54本の記録7件です。Icarus 13.0は45 pass・9 known、Verilator 5.054はseed 1と73で各54 known、kirimasim 0.1.1 `441dddbd0fcd`は4回とも54 passです。Icarusの一致45本だけにoracleを登録し、Z/Z併合で差がある9本はspecのみです。4値ケースにVerilatorのoracleを付けていません。[有限の検査](qualification/fourstate-boundaries-20261119d.json)は、成功する65/257ビットの対照12本と、コンパイル・正常終了した変異24本の出力差です。独立AIレビューは修正済みのソースから14,651期待行を確認しています。要求対応は変更していません。
- `results/arithmetic-context-20261119e-*.json`：`+nonce=1`を使った実行時演算と文脈90本の記録7件です。Icarus 13.0、seed 1と73のVerilator 5.054、4回のkirimasim 0.1.1 `441dddbd0fcd`は各90 passです。oracleにはIcarusの一致90本を登録しています。[有限の検査](qualification/arithmetic-context-20261119e.json)は、成功する符号付き・符号なし65/257ビットの対照20本と、コンパイル・正常終了して倍幅結果や狭い語からの保存値を変える変異40本です。独立AIレビューは7,380期待行を確認し、要求対応は変更していません。
- `results/power-boundaries-20261119f-*.json`：`+nonce=1`を使った整数べき乗72本の記録7件です。Icarus 13.0は54 pass・18 known、Verilator 5.054はseed 1と73で各36 pass・36 known、kirimasim 0.1.1 `441dddbd0fcd`は4回とも72 passです。一致したIcarus54本だけにoracleを登録し、4値にはVerilatorを登録していません。[有限の検査](qualification/power-boundaries-20261119f.json)は、成功する符号付き・符号なし65/257ビットの対照16本と、コンパイル・正常終了した結果破壊32本です。独立AIレビューは3,924期待行を確認し、要求対応は変更していません。
- `results/wide-scan-20261119g-*.json`：putcと添字代入の対照を含む数値文字列180本の記録7件です。Icarus 13.0は36 pass・144 known、Verilator 5.054はseed 1と73で各20 pass・160 known、kirimasim 0.1.1 `441dddbd0fcd`は4回とも180 passです。Icarusの36本と元の2値Verilator10本にoracleを登録し、134本はspecのみです。[有限の検査](qualification/wide-scan-20261119g.json)は、符号付き65/257ビットの対照20本の成功と、コンパイル・正常終了した破壊例40本です。独立AIレビューは別々に封印した5,688期待行を確認し、要求対応は変更していません。
- `results/nba-boundaries-20261119h-*.json`：静的な代入先の広い非ブロッキング代入192本の記録7件です。Icarus 13.0は192 pass、Verilator 5.054はseed 1と73で各192 known、kirimasim 0.1.1 `441dddbd0fcd`は4回とも192 passです。全件で4値入力を観測し、Icarusだけにoracleを登録します。[有限の検査](qualification/nba-boundaries-20261119h.json)は65/513ビットの成功対照32本と、コンパイル・正常終了した予約時機・値の破壊例64本です。独立AIレビューは全5,280期待行を確認し、要求対応は変更していません。
- [`interaction-qualification/random-power-20261119/qualification.json`](interaction-qualification/random-power-20261119/qualification.json)は明示指定のランダムモデルの別証跡です。保存288プログラム・2,304ベクトルに対して、kirimasim `a6222f0656d4`は1,152 pass、Icarusは240 pass・48 known、Verilatorは2つの初期化seedで各23 pass・4値265除外です。判定2,016件と実呼出し1,486回を区別し、除外はpassにしません。封印した三組のAI導出18,432行と、成功対照16本・コンパイルした変異32本の有限の観測検査を保存します。固定本数・要求カバレッジ・既定13モデルのNightly割当てには加算しません。[方法と保存再現](../docs/random-cross-verification.md#opt-in-power-profile)。
- `results/memory-file-boundaries-20261119k-*.json`：広い型付きメモリファイル138本の記録7件です。Icarus 13.0は90 pass・48 known、Verilator 5.054はseed 1と73で各138 known、kirimasim 0.1.1 `a6222f0656d4`は4回とも138 passです。一致90本だけにIcarusのoracleを付けます。拡張側のコメント検査器をソース封印前に直し、旧v2の記録と不変の期待値を保管しています。[有限の検査](qualification/memory-file-boundaries-20261119k.json)は257/513ビットの成功対照46本と、コンパイル・正常終了する検査器・読込語の変異92本です。独立AIレビューは12,654行を確認し、有限モデル・要求対応は追加していません。
- `results/negative-power-controls-20261119l-*.json`：整数の負乗16本の記録7件です。Icarus 13.0は16 known、Verilator 5.054はseed 1・73で各12 pass・4 known、kirimasim 0.1.1 `a6222f0656d4`は4回とも16 passです。一致した既知値12本だけにVerilatorのoracleを付けます。独立AIは564行を導出し、[有限の検査](qualification/negative-power-controls-20261119l.json)は実際の`+nonce=1`を使った成功対照16本と、コンパイル・正常終了する変異32本です。要求対応・有限モデルの対応は増やしていません。
- `results/wide-values-20261119m-*.json`：広い条件演算・比較312本の記録7件です。Icarus 13.0は300 pass・12 known、Verilator 5.054はseed 1・73で各120 pass・192 known、kirimasim 0.1.1 `a6222f0656d4`は4回とも312 passです。一致したIcarus300本だけにoracleを付け、Zのマージ12本はspecのみです。独立AIは1,344行を導出し、[有限の検査](qualification/wide-values-20261119m.json)は257/513ビットの成功対照104本と、コンパイル・正常終了する結果の破壊208本です。有限モデルの行・要求対応は変えていません。
- `results/constant-power-20261119n-*.json`：定数と実行時のべき乗16本の記録7件です。Icarus 13.0は16 known、Verilator 5.054はseed1/73で各12 pass・4 known、kirimasim `a6222f0656d4`は4回とも16 passです。Icarusの全出力を追加確認し、定数の結果304箇所が一致、実行時は247差・57一致です。失敗するテスト全体にoracleは付けません。独立AIは1,172行を導出し、[有限の検査](qualification/constant-power-20261119n.json)に成功対照16本・コンパイルする定数／実行時の変異32本と、ソース・バイナリ・各観測のハッシュを記録しています。要求対応・過去の入力は不変です。
- [広い値の明示指定ランダム検証](interaction-qualification/random-wide-values-20261119/qualification.json)：保存288プログラム・2,304ベクトルで、固定本数には加えません。実際のCLI12回はkirimasim1,152pass、Icarus281pass・7known、Verilator合計266pass・26known・4値の除外284件です。既知値のワイルドカードのビルド失敗26件は除外と区別します。独立AIの導出4,608行、有限の対照32本・コンパイルする変異64本と単体検査14件を記録し、非公開の生記録はハッシュで参照します。過去の全結果を維持しています。
- `results/wide-shifts-20261119p-*.json`：広いシフト192本の記録7件です。Icarus13.0は192pass、Verilator5.054はseed1/73で各120pass・72known、kirimasim `a6222f0656d4`は4回とも192passです。192本全てにIcarusだけのトークンを加えます。独立AIは768行と実行時入力の依存を検査し、[有限の検査](qualification/wide-shifts-20261119p.json)は`+nonce=1`を使う257/513ビットの成功対照64本とコンパイルする結果ビットの変異128本です。過去の入力・有限モデルの行・要求対応は不変です。
- `results/wide-casts-20261119q-*.json`：広い明示的な型変換180本の記録7件です。Icarus13.0は180pass、Verilator5.054はseed1/73で各60pass・120known、kirimasim `a6222f0656d4`は4回とも180passです。180本全てにIcarusだけのトークンを付けます。独立AIの2通りの解釈は900行を導出し、[有限の検査](qualification/wide-casts-20261119q.json)は実際の`+nonce=1`を使う257/513ビットの成功対照60本と、途中／最終の観測を壊すコンパイルする変異120本です。過去の入力・有限モデルの対応は不変です。
- `results/wide-forces-20261119r-*.json`：広いforce/releaseの108本を7件の記録に保存しました。Icarus 13.0は96pass・12known（全てビルド失敗）、Verilator 5.054はseed1/73で各72pass・36known、kirimasim `a6222f0656d4`は4回とも108passです。oracleはIcarus96本・Verilator6本・specだけ6本です。独立AIは816行を導出し、[有限の検査](qualification/wide-forces-20261119r.json)は257/513ビットの成功対照36本と、強制値／release後のドライバ更新を壊すコンパイルする変異72本です。過去の入力と有限モデルの要求対応は不変です。
- `results/wide-constant-calls-20261119s-*.json`：既知値の定数／実行時の関数36本の記録7件です。Icarus 13.0は24pass・12known（class形式のビルド失敗）、Verilator 5.054はseed1/73で各36pass、kirimasim `a6222f0656d4`は4回とも36passです。oracleはIcarus24本・Verilator12本です。独立したソースの解釈2通りで720行を導出し、[有限の検査](qualification/wide-constant-calls-20261119s.json)は257/513ビットの成功対照12本と、定数／実行時／直接の関数／入力保持を壊すコンパイルする変異48本です。過去の入力は不変です。
- [広いシフト・型変換の明示指定ランダム検証](interaction-qualification/random-wide-bitops-20261119/qualification.json)：保存288プログラム・2,304ベクトルで、固定本数には加えません。CLI12回でkirimasim1,152pass・Icarus288pass・Verilator合計300passと4値の除外276件を残します。実行1,740回と比較先のビルド588回を分け、この組にはビルド失敗・出力不一致はありません。独立AIの導出5,760行に加え、有限の成功対照32本とコンパイルする観測の変異64本・単体検査15件を記録します。過去の入力・履歴・結果は不変です。
- `results/wide-runtime-aliases-20261119u-*.json`：合法に修正した実行時の別名参照36本の記録7件です。Icarus 13.0は36known（ビルド失敗）、Verilator 5.054はseed1/73で各36pass、kirimasim `a6222f0656d4`は4回とも36passです。36本全てにVerilatorのトークンを付けます。予約語を使った草案は却下し、独立した2通りの方法で修正後の648行を以前の知識を明記して再計算しました。[有限の検査](qualification/wide-runtime-aliases-20261119u.json)は成功対照12本とコンパイルする引数の渡し方／戻り値の変更36本です。過去の入力と台帳は不変です。
- `results/wide-format-roundtrips-20261119v-*.json`：書式化と読み取り36本の記録7件です。Icarus 13.0は24pass・16進12known（ビルド失敗）、Verilator 5.054はseed1/73で各24pass・10進12known（実行後の出力差）、kirimasim `a6222f0656d4`は4回とも36passです。oracleはIcarus24本・Verilator12本です。独立AIの導出504行と、期待値が不変の16進だけの小文字化への整理を記録します。[有限の検査](qualification/wide-format-roundtrips-20261119v.json)は成功対照12本とコンパイルする入力／値／個数の変更36本です。過去の入力と台帳は不変です。
- `results/packed-read-controls-20261119w-*.json`：新規の読取り専用96本の記録7件です。Icarus 13.0は行48pass・ビット48known（ビルド失敗）、Verilator 5.054はseed1/73で各96pass、kirimasim `a6222f0656d4`は4回とも60pass・出力差36件を維持します。oracleはIcarus48本・Verilator48本です。独立AIの導出は1,728行、[Verilatorの有限の検査](qualification/packed-read-controls-20261119w.json)は成功対照32本・コンパイルする変更64本です。別の[既存Bの再確認](qualification/packed-lanes-a622-recheck-20261119w.json)は192本を4回、各50pass・出力差142件で保存し、新規本数はゼロです。従来の入力・台帳・不合格を維持します。
- [広い数値の書式化・読み取りのランダム検証](interaction-qualification/random-format-scan-20261119/qualification.json)：保存288プログラム・2,304ベクトル・独立導出7,200行で、固定本数とは別です。kirimasim1,152pass・Icarus185passと既知のビルド失敗103件・Verilator398passと既知の出力不一致178件を残し、除外はありません。実行1,913回・比較先のビルド864回・失敗ビルド103回を区別します。単体検査15件・成功対照24本とコンパイルする変異72本を添え、過去の入力と履歴を保全します。
- `results/wide-format-fields-20261119y-*.json`：正の表示幅72本の記録7件です。Icarus24pass・2進24known（実行時の差）・16進24known（ビルド失敗）、Verilator各48pass・10進24known（実行時の差）、kirimasim4回各72passです。oracleはIcarus24本・Verilator48本です。独立AIの2手法で1,008行を導出し、[有限の検査](qualification/wide-format-fields-20261119y.json)に成功対照24本・コンパイル・正常終了する変異72本を残します。過去の入力と台帳は不変です。
- `results/wide-bitvector-queries-20261119z-*.json`：全幅の問い合わせ48本（既知値18・4値30）の記録7件です。Icarus48pass・kirimasim4回各48pass・Verilator各18passと既知のビルド失敗6件／実行時差異24件です。oracleはIcarus48本です。ソースだけの独立AI2手法で276行を導出し、その後の説明6件だけの修正でも全本体・期待値を維持します。[有限の検査](qualification/wide-bitvector-queries-20261119z.json)は対照16本・コンパイルして正常終了する変更32本で、過去の入力と台帳は不変です。
- [広いビット問い合わせのランダム検証](interaction-qualification/random-wide-queries-20261119/qualification.json)：保存288プログラム・2304ベクトル・AI導出9504行で固定本数とは別です。kirimasim1,152pass・Icarus288pass・Verilator0pass／既知のビルド失敗262件／4値の除外314件です。実行1440回・ビルド550回・失敗ビルド262回を区別し、単体検査15件・成功対照16本とコンパイルして正常終了する変異32本・保存入力の再生を記録します。過去の入力・履歴・台帳は保全します。
- `results/wide-array-shapes-20261119ab-*.json`：新しい形状60本の記録7件・420結果です。Icarusはビルド失敗12件・終了コード1の実行失敗36件・終了コード0の値の不一致12件、Verilator各30pass・30known、kirimasim4回各48pass・明示的な非対応12件です。oracleはVerilator30本・specだけ30本です。独立AIの導出714行と[有限の検査](qualification/wide-array-shapes-20261119ab.json)の対照16本・コンパイルする変異32本を残します。[別の診断](qualification/wide-array-shapes-diagnostics-20261119ab.json)はIcarus60記録・KI非対応12コマンドです。[以前の入力の再確認](qualification/early-fixed-a622-recheck-20261119ab.json)は現在の本体で4回各756pass・3,024結果で、新しい本数・要求対応・判定には加えません。過去の入力と履歴は不変です。
- `results/reqgap6-20261120-*.json`：2026-11-20に2・7・14・15・23〜29・32・39・40章と附属書A・I・L・M・Nのテストのない要求のために追加したテスト27本の実行。Icarus Verilog 13.0は8 pass・19 known、Verilator 5.054はseed 1と73のどちらも11 pass・16 known、kirimasim `a6222f0656d4`は16 pass・11 unsupportedです。Icarusのpassのうち2本は、clockingに対応しないことによる構文エラーが違反の行と重なったもので、`:oracle:`に記録せず、実行カバレッジにも数えません。Verilatorは[移行中の固定版](../docs/simulator-differences.ja.md#verilator-5054-interim)により5.054で実行しました。
- `results/sv2023-thin-20261121-*.json`：2026-11-21に1800-2023で加わった11機能のために追加したテスト28本の実行。Icarus Verilog 13.0は5 pass・23 known、Verilator 5.054はseed 1と73のどちらも13 pass・15 known、kirimasim `a6222f0656d4`は11 pass・16 unsupported・1 failです。
- `results/reqgap7-20261121-*.json`：2026-11-21にテストのない要求のために追加したテスト12本の実行。Icarus Verilog 13.0は5 pass・7 known、Verilator 5.054はseed 1と73のどちらも3 pass・9 known、kirimasim `a6222f0656d4`は9 pass・3 unsupportedです。
- `results/vpi-io-decl-refinement-20261120-*.json`：2026-11-20に、25.9に反するvirtual interfaceのポートを直した`ch37/test_vpi_io_decl_scope_typespec_ports`の実行。Icarus Verilog 13.0とVerilator 5.054（seed 1と73）はknown、kirimasim `a6222f0656d4`はunsupportedで、どれもこのテストを実行できません。
- `results/reqgap7-20261120-*.json`：言語仕様の未対応269要求の2巡目で作った20本と、入力不変の既存1本。独立検証を経て14要求に対応を追加しました。Icarus 13.0は未対応の左辺構文による見かけの違法系passが10件、knownが11件で、10件は未承認oracleの検査により実行確認率から除外されます。Verilator 5.054は両seedとも9 pass・12 knownですが、4 passは未対応構文によるもので承認oracleにはしていません。kirimasim `a6222f0656d4`は5 pass・16 unsupported・fail 0。期待値は規格から導き、既存の保留は削除していません。
- `results/reqgap8-20261120-*.json`：DPI/VPI新規7本・独立検証した8対応の、新しい4記録・28結果です。Icarus 13.0は1 pass・未対応による6 known、Verilator 5.054 seed1/73は各7 known、kirimasim固定版`a6222f0656d4`は7 unsupported。呼出し元の1本だけにIcarus oracleがあり、6本はspec-onlyです。別の[nativeトークン比較の有限検査](qualification/signed-macro-token-audit-20261120.json)により旧I.3対応1件を撤回し限定保留M130を追加しました。これはシミュレータ証跡を増やすものではなく、旧入力・旧結果・要求定義を維持します。
- `results/test-side-fixes-20261120-*.json`: 2026-11-20に直したテスト4本の再実行。Ghostは4本ともpass、Verilator 5.054は、そのうち実行した2本（`ch35/test_svdpi_h_packed_bit_and_part_select`、`ch6/test_ch6_extra_for_loop_automatic`）がseed 1と73のどちらでもpassです。
- `results/test-side-fixes-20261120b-ghost-strict.json`: 同じ日に直したテスト3本のGhostでの再実行で、3本ともpassです。
- `slang/`: 固定版slangによる[参考判定](../docs/slang-reference.md)の日付付きの記録。`tools/run_slang.py`が書きます。 どの集計にも数えず、カバレッジのツールは読みません。[レビュー候補](../docs/review-candidates.md)は`tools/review_candidates.py`がNightlyの結果から作り、`results`ブランチに置きます。
- `behavior-summary.json`: 現在の暫定値・確定値、章別の割合、分母SHA-256、 シミュレータごとの失敗・既知不一致・未対応・未実行・古い証跡などの内訳。 `--update`で概要Markdownとともに再生成し、`--check`で両方の整合性を検査します。
- `behavior-history.json`: 計測履歴。分母と計測規則の版を添えて保存します。 分母が変わった前後の割合は、そのまま改善・悪化として比較しません。 各スナップショットの`executed`一覧は最初の出現時だけ保存し、重複は`same_as_sha256`参照にします。復元方法は[方法書](../docs/requirements-to-tests-method.md#11-fixed-for-reproducibility)を参照してください。この変更を含むコミットで実行したNightlyはresults側の履歴にも同じ形式を使います。

入力ハッシュにはテスト本体、期待値、`:files:`、DPI/VPIのCソース、文字列で指定した includeとinclude検索ディレクトリ内のファイルを含めます。マクロで選ぶincludeや外部データは 必ず `:files:` に宣言してください。コンパイラのインストール全体やOSの再現性を証明する ハッシュではありません。include検索ディレクトリは保守的に全ファイルを対象にします。

`pass` だけを実行成功に数えます。`known`、`unsupported`、`fail`、古いランナー、変更前の 入力、来歴のない従来形式の結果は成功に数えません。規格違反のコードは未対応構文のエラーと誤認し得る ため、メタデータでレビュー済みの固定バージョンIcarus 13.0／Verilator 5.052の結果に限ります（`:oracle:`が`verilator@5.054`のテストは、5.054の結果に限ります）。 それでも診断の意味とエラー位置のレビューは必要です。単なる構文未対応を成功扱いしません。

対応付けと要求抽出はAIによるレビューです。独立した人の確認済みとは扱いません。 全資料の確認後、解釈保留を解決し、重複21行を統合して分母を承認しました。 登録単位は要求・条件・観測ケースです。全入力の組み合わせを網羅したという意味ではありません。 採用した解釈と、節単位の出典だけを持つ3行などの限界は [分母レビュー](../docs/denominator-review-20261028.md)と [解釈・再検討記録](../docs/requirement-extraction-notes.md)を参照してください。

<a id="daily-updates"></a>

## 日常の更新

まず対象節の本文と関連する図表・構文・参照先を読み、要求を自分の言葉で分解します。 規格本文やサンプルコードをそのまま転載しないでください。 出典の自身の本文を確認するには次を使います。資料は既定で兄弟ディレクトリの提供資料を参照します。

```sh
python3 tools/requirement_source.py --show 10.9.1 10.9.2
```

キーワードだけの抽出では、定義、表のセル、構文、例外を拾い切れません。 すべての出典ブロックを分類し、要求は`source_spans`に節とブロックIDを登録してください。 `complete`または`no_behavior`にするには全ブロックの監査記録が必要です。 解釈が未解決の要求には`interpretation_issue`を付け、節を`in_progress`のままにします。 この状態では対応テストの承認も禁止しています。推奨事項は`modality: recommendation`で、 必須事項や許可と区別します。機械検査は監査記録の整合性を検査し、意味の正しさを自動承認しません。

既存テストの候補は次のコマンドで列挙できます（列挙だけでは対応済みになりません）。

```sh
python3 tools/behavior_coverage.py --candidates 11.3.5
```

各要求の刺激と観測結果を確認し、`checks` にテストと証拠の文字列を登録します。 テストが根拠節を直接引用し、正常系では期待出力、規格違反テストでは意図した診断が照合されることを 確認してください。テスト変更後は対応付けを再レビューしてからハッシュと日付を更新します。

```sh
python3 tools/behavior_coverage.py --test-digest tests/ch11/test_short_circuit_side_effects.sv
python3 tools/run_icarus.py --json /tmp/icarus.json tests/ch11/test_short_circuit_side_effects.sv
python3 tools/behavior_coverage.py --results /tmp/icarus.json \
  --output /tmp/behavior-coverage.md --json /tmp/behavior-coverage.json
```

`--results` は保存済みの初期スナップショットを置き換えて、その引数だけを計測します。 一つのシミュレータの異なる版・異なる回の成功を、単一環境の適合率として合成しません。 `--history /tmp/behavior-history.json` を付けると分母の識別情報と計数を追記できます。 要求台帳の変更前後の割合は分母も確認して比較してください。 分母SHA-256は要求の内容と対象範囲から算出し、対応テストや実行結果の変化だけでは変わりません。 全項目のJSONでは`requirements[].status`と、各実行結果の`outcomes`から残件IDを抽出できます。 複数のレビュー済みテストが同じ要求を独立に検証する場合は、少なくとも一つの有効な成功を採用します。 複数ケースで一つの要求を分担する `check_groups` は、いずれかのグループ内の全テストが 同じシミュレータ・同じ実行回で成功した場合だけ採用します。別の版・実行回の部分成功は合成しません。 この拡張を計測規則の版3に記録しています。版2との数値比較では規則の変更も確認してください。 成功がない場合の環境別表示は、失敗、既知不一致、未対応、規格違反テストの判定根拠が未承認、古い証跡、 未実行の順で代表状態を選びます。各登録行は各環境で一つの状態に数えます。

```sh
python3 tools/behavior_coverage.py --update
python3 tools/requirement_matching.py --update
python3 tools/behavior_coverage.py --check --require-source-reviewed
python3 tools/requirement_matching.py --check
python3 -m unittest discover -s tools -p 'test_*.py'
```

計測した状態を履歴にも残す場合:

```sh
python3 tools/behavior_coverage.py --update --json /tmp/behavior-coverage.json \
  --history coverage/behavior-history.json
```

`--summary-output`と`--summary-json`で概要の出力先を指定できます。 既定の詳細レポートを更新／検査する場合は、概要Markdownと`coverage/behavior-summary.json`も対象です。 `--results`なしの再計測は保存済み証跡を使います。新たにシミュレーションを実行したことにはなりません。

チェックは未対応要求があること自体では失敗しません。記録が不正・古い、対応が後退した、 生成レポートが古い場合に失敗します。全規格の要求カバレッジ（テスト設計）と実行確認率の両方で100%を 要求する場合は次を使います。 分母未確定の場合も失敗します。現在は分母承認済みですが、未対応要求とパス結果の記録のない要求が 残るため、意図どおり非ゼロ終了します。 `--require-source-reviewed`は全資料の確認を要求し、解釈保留・テスト対応を承認するものではありません。

```sh
python3 tools/behavior_coverage.py --check --require-complete
```

根拠のある要求訂正や対象の修正で基準を変更する場合、差分をレビューし、理由を記録します。 要求・対応・調査完了の単純な追加は `--update` が基準を自動的に引き上げます。 `--check` は追加分が基準に保存されていない場合も失敗し、次回以降の削除を見逃しません。 後退や要求文の訂正は理由付きの明示更新が必要です。単にチェックを通すために 基準を下げないでください。

```sh
python3 tools/behavior_coverage.py --write-baseline --reason '具体的な規格根拠と変更理由' --update
```

<a id="rechecking-the-standard-materials"></a>

## 規格資料の再照合

資料はリポジトリに複製していません。提供資料のPDFハッシュを照合できます。 `--verify-source`は抽出テキストのハッシュも検査します。PDFから新たに`pdftotext -layout` で抽出したテキストと、提供された抽出済みテキストが一致することも初回に確認しています。

資料のディレクトリは、以下ではリポジトリの隣の`IEEE_1800-2023_SystemVerilog`としています。 `tools/requirement_source.py`の既定値も同じで、環境変数`IEEE1800_SOURCE`で変えられます。

```sh
python3 tools/behavior_coverage.py --check \
  --verify-source ../IEEE_1800-2023_SystemVerilog
python3 tools/import_standard_sections.py ../IEEE_1800-2023_SystemVerilog --check
python3 tools/requirement_source.py --index /tmp/requirement-source-index.json
```

出典索引を再生成した場合は、JSONの内容が保存済み索引と一致することを確認してください。 本文キャッシュが必要なら`--cache /tmp/requirement-source.json`を使います。 本文のリポジトリ内へのキャッシュ出力はツールが拒否します。 出典ブロックの集合は基準値のハッシュでも固定し、索引から本文を落として見かけの完了率を上げる変更を防ぎます。

索引の誤認5件と8.23節の欠落を本文・目次で補正し、本文第41章と小見出しのない附属書も 含めました。附属書Cは概要・目次では参考、本文見出しでは規定と表示されるため、保守的に 本文の規定表示を採用しています。第41章は廃止を述べる本文を確認し、根拠付きで `no_behavior` としました。従来の引用カバレッジで対象外の227節も、自動除外していません。

<a id="ciとnightly"></a>

<a id="ci-and-nightly"></a>

## CI とナイトリー

Checkは台帳・基準・ハッシュ・観測点・レポートの整合性と集計器の回帰テストを検証します。 Nightlyはその回の全ランナーのJSONから再計測し、`results` ブランチへ次を保存します。

- `behavior-coverage.md`: その回の動作別・環境別の結果。テストへのリンクは実行時のコミットを指します。
- `behavior-coverage.json`: 集計値、分母識別情報、動作IDごとの対応・実行確認状態。
- `behavior-coverage-summary.md` / `behavior-summary.json`: 暫定値・確定値と章別・環境別の集計。
- `behavior-history.json`: 各回の計数と分母・実行環境の履歴。

履歴には集計を保存し、全登録行の状態はその回の詳細JSONに保存します。 GitHub Actionsの実行概要にも暫定値・確定値と残件数を表示します。

Nightlyの測定対象は実行したスイートのコミットです。`main`の変更は、そのコミットを使った 実行と公開が完了してから結果へ反映されます。

確定分母は12,332要求です（2026-10-28に承認した12,298要求から、2026-11-14に7行、2026-11-15に27行を分けました）。現在の設計・実行の割合と証跡は [生成した集計概要](../docs/behavior-coverage-summary.md)、承認根拠は [分母レビュー](../docs/denominator-review-20261028.md)を参照してください。
