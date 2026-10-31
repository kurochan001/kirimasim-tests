# Codexへの引き継ぎ：テスト側指摘の対応とクロス検証（2026-10-31）

外部状態の確認：2026-10-30 21:05 UTC（10-31 06:05 JST）。
この資料は`kirimasim-tests`の作業を引き継ぐためのものです。
コマンドは、断りがなければ`kirimasim-tests`リポジトリのルートで実行します。

前の担当者の資料も残っています。範囲が重なるので、両方読んでください。

- [機能間クロス検証の引き継ぎ（2026-10-30）](claude-code-handoff-20261030-cross-verification.md)：
  クロスのモデル追加手順、保存実行、insideの不一致の調査。
- [要求カバレッジの引き継ぎ（2026-10-28）](handover-20261028.md)：要求台帳と分母の考え方。
- [履歴](history.ja.md)：以前の測定値と作業記録。READMEには現時点の情報だけを書きます。

## 1. 最初に把握すること

- mainは`f0908394`で、origin/mainと一致し、作業ツリーはクリーンです。
  [Check](https://github.com/kurochan001/kirimasim-tests/actions)はicarus・verilator・readmeの3ジョブとも成功しています。
- スイートは**9,176件、生成2,739件**。機能間クロスの短時間実行は**29モデル・1,426件**です。
- 要求カバレッジは、テスト設計**89.31%（10,983/12,298）**、実行確認**50.93%（6,263/12,298）**です。
  実行確認はIcarus Verilog 13.0・Verilator 5.052・SymbiYosysの保存証跡だけで数えています。
- Ghostのランナーを変えた（`:type: formal`を除くようにした）ため、以前保存したGhostの結果は
  ランナー指紋が合わず、実行確認に数えていません。新しいGhostの実行を保存すれば戻ります。
- 計画上の網羅、Checkの成功、テストの一致数、要求カバレッジは別の指標です。混ぜないでください。

## 2. ユーザーの方針と作業上の注意

- **日本語で簡潔に進捗と結果を伝える。** 長い検証中も状況を共有する。
- mainへのcommit・pushは依頼されたときだけ行う。検証してから反映する流れで作業してきた。
- シミュレータを実行するときは、その直前に最新コミットを取得・確認し、その版をビルドする。
  古いビルドをそのまま使わない。ビルド版と上流コミットの一致を記録する。
- **kirimasimとLyraは別のシミュレータ。** kirimasimの結果をLyraの結果として報告しない。
- Icarus 13.0・Verilator 5.052は固定oracleの確認用。開発版の一致をこれら固定版のoracleへ
  読み替えない。Verilatorの確認では2状態テストをseed 1・73で別々に実行する。
- 既存テスト・期待値・oracle・過去の実行証跡を保持する。未対応を成功の期待値にしない。
  合格率のために合法な因子を削らない。
- Icarus・VerilatorなどGPL/LGPLの実装ソースを読まない。他プロジェクトの再現コードをコピーしない。
  規格、独立計算、実行結果から検証する。
- Icarus・Verilatorとの差異は上流へ報告せず、[固定版の差異一覧](simulator-differences.md)へ記録する。
- 規格本文・図表の転載、ホームの絶対パス、個人情報、非公開資料を公開ファイルへ入れない。
  Ghostは公開前のシミュレータの仮名で、実名・版・実行プロファイル・パスは公開しない。
- コメント行を`Verilator`という語で始めない（Verilatorが指令と解釈する）。
  `tools/lint_metadata.py`が`verilator-comment`として検出する。
- Icarus・Verilatorのoracleが付いていないテストの不一致は、ランナーがknownとして数え、failにしない。
- 本体（`../kirimasim`）を変更する場合は、そのリポジトリのCLAUDE.mdを読む。
  「意味は一か所で決める」「症状の形で分岐しない」「仕組みのマトリクステストを生成器で作る」
  「pushの前に`tools/local_ci.py`」などの規則がある。別セッションが作業中なので、
  チェックアウトを直接触らず、隔離した作業ツリーを作る。

## 3. 2026-10-31に完了した作業（`f0908394`）

Ghostの全件実行（別リポジトリの監査）が「テスト側の問題」と分類した432件と、
個別指摘の#36〜#39を、IEEE 1800-2023と照らして見直しました。約90件のテストを修正し、
規格どおりのテストは据え置きました。

- **直した主な類型**
  - 合法のテストに含まれる不正な構文（非ANSI引数の既定値、refを継いだリテラル実引数、
    bin添字への`binsof`、struct変数を上位スコープ名にした階層参照、変数ポートへのinterconnect、
    `buf`への3値遅延、`##1`の後のプロパティ、縮退したシーケンス、`; else`の空動作など）。
  - 規格が結果を定めない競合（UDP遅延の変化時刻と同時刻の観測、programの暗黙`$finish`が
    報告より先に来る形、時刻0の継続代入と`@(v)`の競合）。
  - 期待値の誤り（`%h`でintは8桁、ビットストリーム型のクラス、Annex Nが定める
    非正の平均への警告と0、`always a`が毎tickで試行を始めること）。
  - VPIの`vpi_get_str()`の共有バッファ（38.11）を前提にしていないCコード11件。
  - Verilator専用の期待出力しかなかった21件に、規格から導いた共通の期待出力を付与。
  - 診断の正規表現を、20.10が様式をツールに委ねる範囲へ緩和（severityと`file:line`を
    同じ行でも次の行でも、順序も問わない）。
- **oracleの取り消し**：未対応の構文で拒否しているだけの不正テスト7件から`iverilog@13.0`を外した
  （README「期待出力の決め方」の規則）。同種の問題はch8などにも残り、
  `coverage/test-matching-reviews.json`の`oracle_issue`に記録がある。
- **#22**：`tools/run_ghost.py`も`:type: formal`を除くようにし、`tools/test_runner_selection.py`と
  READMEを合わせた。
- **#29〜#35**：Ghostの未実装操作の一覧で、テストの不具合ではないため説明を付けて閉じた。
- **リアクティブ順序**：未マージだったブランチのテスト修正を当て直した（4.5。
  Icarus 13.0が5回とも再現したので`iverilog@13.0`を登録）。
- **証跡**：入力が変わった108件をIcarus 13.0、2状態101件をVerilator 5.052のseed 1・73で実行し、
  `coverage/results/issues-20261031-*.json`に保存した。oracle付きの対象はすべて一致。
- **要求の対応付け**：変更したテストに関わる全件をレビューし直した。成り立たなくなった3件
  （37.25のpacked array typespec、37.46のnet bitのload、I.3のack）を根拠から外し、
  理由を`coverage/behavior-baseline.json`に記録した。
- `tools/sva_reference/fixtures/m4_deferred.json`の指紋を1件更新（ch16のテスト改修に伴う）。

### 本体（kirimasim）側

- inside・case insideの集合要素の符号拡張の不具合を修正。11.8.1・11.8.2に従い、
  配列要素を共通型の符号で拡張するよう、`src/front/lower_expr.cpp`の一か所
  （`Lowerer::memberMatch`）に集約した。
- ブランチ`fix/inside-array-element-extension`（`e2912de7`）をpush済み。PRは作っておらず、
  mainには入れていない。基点は`745388cd`で、確認時の上流mainは`83e89bf5`なので、
  取り込む前に上流へ合わせ直す必要がある。
- 仕組みのマトリクステストを生成器（`tools/gen_inside_member_matrix.py`）で追加。
  `tools/local_ci.py`は全項目通過。
- この修正で、クロス1,426件の不一致2件が解消する（修正前1,368 pass・2 fail、
  修正後1,370 pass・0 fail、未対応56件は同じ）。**この結果はまだ保存証跡にしていない。**
  上流に入った後、最新mainをビルドして`coverage/interaction-results/cross29-kirimasim-<commit>.json`
  を新しい名前で保存してください。

## 4. 未着手の課題

### 4.1 新しい個別指摘 #40〜#44

追記：引き継ぎ後の照合と修正内容、保存した実行結果は
[Issue #40〜#44 の照合記録](issues-40-44-review-20261031.md)に記載しています。
以下は引き継ぎ時点の未検証の指摘と作業手順です。

いずれも「テスト1件の期待値や刺激が規格に反する」という指摘で、条項と該当行が示されています。
**内容は未検証です。** 指摘を事実として扱わず、条項本文とテストを自分で照合してください。

| Issue | 対象 | 指摘の要点（未検証） |
| --- | --- | --- |
| [#40](https://github.com/kurochan001/kirimasim-tests/issues/40) | `ch14/test_syntax_clocking_drive_forms` | 1ビットの`d`に2〜5を期待している（10.7の左辺幅への切り詰め） |
| [#41](https://github.com/kurochan001/kirimasim-tests/issues/41) | `ch11/test_A_extra_specparam_range` | localparamにspecparamを含む定数式を代入している（6.20.5） |
| [#42](https://github.com/kurochan001/kirimasim-tests/issues/42) | `ch14/test_clocking_default_skew` | Re-NBAでの更新前に新しい値を読む期待値（14.16）。同趣旨の`test_clocking_future_drive_in_re_nba`と両立しない |
| [#43](https://github.com/kurochan001/kirimasim-tests/issues/43) | `ch37/test_vpi_immediate_assertion_parts` | ラベルのない呼出し文を`vpiName`で特定している（37.60 detail 1はNULL） |
| [#44](https://github.com/kurochan001/kirimasim-tests/issues/44) | `ch4/test_pli_phase_chain_after_nba_and_end_write` | `cbReadWriteSynch`がNBA更新の後に起きることを要求している（38.36.2はどちらでもよい） |

進め方は#36〜#39と同じです。

1. 条項本文を`tools/requirement_source.py --show`で読み、テストとその`.expected`を読む。
2. スイート内に同じ規則を反対に解釈したテストがないか探す（#42は指摘自身が挙げている）。
   自己矛盾があれば、どちらの読み方でも同じ結果になる刺激にするか、理由を書いて片方を直す。
3. 直したら、入力が変わるので固定版を再実行し、oracleの維持／取り消しを判断する。
4. 要求の対応付け（`coverage/behaviors.json`、`coverage/test-matching-reviews.json`）の
   指紋・証拠・観測文を更新する。手順は§6.3。

### 4.2 開いたままのIssue（判断が必要）

- [#24](https://github.com/kurochan001/kirimasim-tests/issues/24)：
  `ch35/test_35_rest_noncontext_export_error`。noncontext importからexportを呼ぶ動作は
  規格が予測不能・未定義としているため、共通の期待出力・終了コード・メッセージが導けない。
  期待値は1ツールの文言のまま。**作り直すか廃止するかの判断が必要。**
- [#27](https://github.com/kurochan001/kirimasim-tests/issues/27)：
  - `ch35/test_35_rest_deprecated_dpi_diagnostic`。35.5.4は警告でもエラーでもよいとしており、
    テスト形式は「どちらでもよい」を表せない。形式かランナー規則の追加が必要。
  - 不正設計の判定が`file:line:`を1行に求める点。規格は診断の様式を定めない。
    `tools/suite_results.py`の`judge_illegal`を、`file:line`の直後が非単語文字でもよいように
    緩める案がある。影響範囲が広いので、先に方針を決めてから一括で変える。
- [#28](https://github.com/kurochan001/kirimasim-tests/issues/28)：
  - `generators/scheduling.py`の`assign_wait`系14件。時刻0の継続代入の評価と`@(v)`の開始が
    競合し、規格はどちらの順序も許す。生成器側の修正が必要（生成済みファイルは直接編集しない）。
  - 読み方が分かれるテスト：ポートの強制変換（23.3.3.1、23.3.3.7）、コンパイル単位の割り当て
    （3.12.1）、configの`use`節の形（A.1.5の文法と33.4.3の例が食い違う）、
    bin内のx/z（19.5.4と19.5.7 b)3）、チェッカー出力の空接続（17.3）、
    上書きのないparameterのparam assign、programからinterfaceへの関係（37.9と37.10 d3）、
    `$coverage_*`のスコープにinterface instanceやpackageを許すか（40.3.2.1）。

### 4.3 その他の残件

- **Ghostの結果の復帰**：新しいランナーで動いたGhostの全件結果を`coverage/results/`へ保存すれば、
  実行確認率が戻る。Nightlyの`results`ブランチの`latest/ghost.json`が使える見込み。
  取り込みの規則は[Nightlyの説明](nightly-results.md)と`coverage/README.md`を参照。
- **Ghost側に残る問題**（テスト側ではない。記録のみ）：既定モードで警告にとどまる検査、
  診断の位置を別行や`(file:line)`で出す形式、`$finish(2)`の統計やカバレッジの注記を
  標準出力に混ぜる点、未対応診断にseverity語がない点。実行プロファイルの整備で解決するものもある。
- **slang**（kirimasim・Lyra・Ghostが共有）：set expression内のcoverpoint名を
  19.5.1.2の本文に反してエラーにする。未報告。
- **slangへのストリーミングの不具合の報告案**：`../kirimasim-tests-work/slang-issue-streaming-20261028/`。
  前回出した[slang #2072](https://github.com/MikePopoloski/slang/issues/2072)が処理されてから出す。
  確認時はまだOPEN。kirimasim-testsへのリンクは付けない。
- **クロスの次の候補**：task引数の添字変更と復帰時の可視性、キュー要素の参照寿命、
  イベントORと`iff`の因子モデル化。手順は
  [考え方と実践手順](interaction-verification-method.md)§5。
  追記：イベントORと`iff`は30番目のモデルとして27件を追加済み。
  [モデルの設計と実行記録](interaction-verification.md#イベントorと項ごとのiff条件)を参照。
  キュー参照寿命も31番目のモデルとして60件を追加済み。
  [設計と実行記録](interaction-verification.md#キュー要素への参照と要素の寿命)を参照。
  task引数の添字変更と可視性は、input/ref/const refについて32番目のモデルとして36件を追加済み。
  [設計と実行記録](interaction-verification.md#引数の結合と呼出し後の添字変更)を参照。
  output/inoutの復帰先の評価時点、動的配列・連想配列の参照寿命、異なるエッジ種別のイベントORは
  引き続き候補です。規格の読み方が分かれる条件は、期待値を一方へ寄せず先に照合してください。

## 5. 実行環境

### 5.1 シミュレータ

| シミュレータ | 用途 | 場所・条件 |
| --- | --- | --- |
| Icarus Verilog 13.0 | 固定oracleの確認 | `../kirimasim-tests-work/50percent-20261023/iverilog13/bin`（版を確認する） |
| Verilator 5.052 | 固定oracleの確認 | `PATH`上。2状態テストのみ、seed 1・73 |
| kirimasim | 最新実装の検証 | `../kirimasim-tests-work/cross-20261030-latest`（確認時のビルドは`1004b8d1`。実行直前に上流を取得してビルドし直す） |
| Lyra | 比較 | x86-64 Linuxのみ。`run_lyra.py --commit`に実際のコミットを渡す |
| Ghost | 比較（公開前） | 非公開のビルドと実行プロファイルが必要。リポジトリ外に置く（README「Ghost」） |
| SymbiYosys | formalの268件 | `tools/run_sby.py`。`:formal_case:`で検証ケースを指定 |

規格資料は`../IEEE_1800-2023_SystemVerilog`です。

```sh
python3 tools/requirement_source.py --source ../IEEE_1800-2023_SystemVerilog \
  --show 11.4.13 16.12.22 A.8.6
```

### 5.2 ランナー

```sh
python3 tools/run_icarus.py --iverilog-bin DIR [-j N] [--json FILE] [TEST ...]
python3 tools/run_verilator.py --all --seed 1 [-j N] [--json FILE] [TEST ...]
python3 tools/run_kirimasim.py --kirimasim BIN [-j N] [--json FILE] [TEST ...]
python3 tools/run_ghost.py --simulator BIN --profile PRIVATE.json --include DIR [TEST ...]
python3 tools/run_sby.py --sby "$SBY_BIN" --json FILE
```

どのランナーも`:type: formal`を除きます。`--json`を付けた結果だけが証跡になります。
`zsh`では変数が空白で分かれないため、テスト一覧は`$(cat list.txt)`や配列で渡してください。

## 6. 変更後の更新・確認手順

### 6.1 検査（CIと同じ範囲）

```sh
python3 -m unittest discover -s tools -p 'test_*.py'
python3 generators/generate.py --check
python3 tools/interaction_coverage.py --check
python3 tools/chapter_cross_matrix.py --check
python3 tools/combination_gaps.py --check
python3 tools/suite_stats.py --check
python3 tools/suite_catalog.py --check
python3 tools/coverage_depth.py --check --minimum-tests 2
python3 tools/behavior_coverage.py --check --require-source-reviewed
python3 tools/requirement_matching.py --check
python3 tools/lint_metadata.py
git diff --check
```

確認時はツールの回帰テスト**335件**が通ります。`--check`に対応する更新は`--update`です
（`coverage_depth.py`は`--minimum-tests 2`、`behavior_coverage.py`は`--require-source-reviewed`を付ける）。

### 6.2 テストを直したときの順序

1. 条項を根拠に最小限の修正をする。コメントに条項と理由を自分の言葉で書く
   （規格本文の転載はしない。コメントは80桁、コードは100桁）。
2. `python3 tools/lint_metadata.py`で新規の問題が0件であることを確認する。
3. 入力が変わるので、`:oracle:`に`iverilog@13.0`や`verilator@5.052`があるテストは
   そのリリースで再実行する（Verilatorは両seed）。再現しなくなったトークンは外し、理由を書く。
   新しいトークンの追加はレビューが必要。
4. 証跡を`coverage/results/`へ新しい名前で保存する。過去のJSONを上書きしない。
5. §6.3の対応付けを更新し、§6.1の更新と検査を実行する。

### 6.3 要求の対応付けの更新

テストの入力が変わると、`coverage/behaviors.json`の`requirements[*].checks[*]`と
`coverage/test-matching-reviews.json`の`reviews[*]`が古くなります（`inputs_sha256`の不一致）。

- 古くなった記録を探す：`inputs_sha256`と`suite_results.input_digest(Path(test))`を比べる。
- 変更後のテストでも観測が成り立つなら、`inputs_sha256`・`reviewed_on`・`reviewer`を更新し、
  `evidence[*].contains`が今のファイルの部分文字列であることを確かめる（移動した行、
  書き換えた正規表現、ずれた行番号に貼り直す）。
- 観測の内容が変わったなら`observation`も書き直す。既存の記述の言語と調子に合わせる。
- 成り立たなくなった記録は、根拠から外すか保留にする。外すと
  `behavior_coverage.py --check`が「coverage regression」で止まるので、
  `--write-baseline --reason "..."`で理由を残す（理由は英語の1段落。既存の記録を参照）。
- 分担している要求（collective witness）の構成が変わった場合も基準の更新が必要。
- `coverage/combination-gaps.json`の`bindings[*].inputs_sha256`も同じ仕組みで古くなる。
  `combination_gaps.py --update`が検出する。

**注意**：指紋だけを現在値へ書き換えて済ませない。刺激・観測・期待値・条項を読み直してから更新する。

## 7. 読む資料

- [検証ガイド・保存実行の概要](interaction-verification.md)：29モデルの定義、制約、対象外、
  モデル別の確認記録。
- [考え方と実践手順](interaction-verification-method.md)：因子モデルの作り方、
  読み方が分かれる場合の扱い、追加手順。
- [クロス検証レポート](interaction-coverage.md)：計画と実行の集計（自動生成）。
- [固定版の差異一覧](simulator-differences.md)：Icarus 13.0・Verilator 5.052と規格の差。
- [補助証跡](../coverage/interaction-qualification/README.md)：最小例、故障注入、ビルド指紋。
- [要求カバレッジ集計](behavior-coverage-summary.md)・[台帳と手順](../coverage/README.md)。
- [テストカタログ](tests/README.md)・[条項一覧](tests/clauses.md)・
  [条項別テスト数](coverage-depth.md)（いずれも自動生成）。
- [FAQ](faq.md)・[用語集](glossary.md)。
- README（[日本語](../README.ja.md)／[英語](../README.md)）の「テストの形式」「メタデータ」
  「合否の判定方法」「期待出力の決め方」「変更への参加」。
- [履歴](history.ja.md)：以前の測定値。READMEの数値を履歴の値へ読み替えない。

## 8. 再開時の確認

```sh
git status --short --branch
git fetch origin
git log -5 --oneline
git rev-list --left-right --count HEAD...origin/main

git -C ../kirimasim status --short --branch
git -C ../kirimasim fetch origin
git -C ../kirimasim log -5 --oneline
git worktree list
```

本体には別セッションの作業と未pushのコミットがある場合があります。確認してから作業範囲を決め、
必要なら隔離した作業ツリーを作ってください。

## Codexへ渡す開始指示の例

```text
このリポジトリの docs/codex-handoff-20261031.md を読み、記録と現在のGit・CI・
隣接kirimasimの状態の差分を確認してください。
既存の期待値・oracle・履歴を保持し、シミュレータは実行直前に確認した最新コミットから
ビルドします。計画の網羅、実行の充足、Check/Nightly、要求カバレッジを区別してください。
この後のユーザー指示に沿って作業し、検証結果と残件を日本語で報告してください。
```
