# Claude Codeへの引き継ぎ：機能間クロス検証（2026-10-30）

外部状態の確認：2026-10-30 09:31:59 UTC（18:31:59 JST）。
この資料は`kirimasim-tests`の作業を引き継ぐためのものです。
以下のコマンドは、通常の`kirimasim-tests`リポジトリのルートで実行します。

## 1. 最初に把握すること

- 本書作成前のmainは`f25ebecdc07c00e790a297d745cdfda874980672`で、origin/mainと一致し、作業ツリーはクリーンでした。
- 直近の実装・テスト・資料更新はすべてmainへcommit・push済みです。本書と案内リンクの追加は、その後の文書コミットです。再開時のHEADは`git log`で確認してください。
- 現在の継続テーマは、機能間クロスを全直積にせず、規格に基づく期待値と観測を備えた有限モデルとして追加することです。
- スイートは**9,095件、生成2,659件**。クロスの短時間実行は**27モデル・1,346件**です。
- クロスの計画が網羅できても、シミュレータの実装がすべて合格したことにはなりません。
- 最新の保存クロス実行はkirimasim **`74fb2340925a`**。本体の現在の上流mainはその後に進んでいます。保存結果を新しい本体の結果へ読み替えないでください。

まず[保存実行の概要](interaction-verification.md#保存実行の概要)、
[設計思想・追加手順](interaction-verification-method.md)、本書を読んでください。

## 2. ユーザーの方針と作業上の注意

- 日本語で簡潔に進捗と結果を伝える。長い検証中も状況を共有する。
- mainへのcommit・pushを繰り返し依頼されており、検証後に反映する流れで作業してきた。
- シミュレータを実行するときは、その直前に最新コミットを取得・確認し、その版をビルドする。古いビルドをそのまま使わない。
- **kirimasimとLyraは別のシミュレータ**。それぞれ`tools/run_kirimasim.py`と`tools/run_lyra.py`を使う。kirimasimの結果をLyraの結果として報告しない。
- Icarus 13.0・Verilator 5.052は固定oracleの確認用。開発版の一致を、これら固定版のoracleへ読み替えない。Verilatorの確認では2状態テストをseed 1・73で別々に実行する。
- 既存テスト・期待値・oracle・過去の実行証跡を保持する。未対応を成功の期待値にせず、合格率のために合法な因子を削らない。
- Icarus・VerilatorなどGPL/LGPLの実装ソースを読まず、他プロジェクトの再現コードをコピーしない。規格、独立計算、実行結果から検証する。
- 規格本文・図表の転載、ホームの絶対パス、個人情報、非公開資料を公開ファイルへ入れない。
- 過去にサブエージェントの活用と6名程度までの利用希望があった。現在の環境・指示の利用条件に従う。
- この会話では`@RTK.md`の参照が指定されている。確認時、当リポジトリのルートにAGENTS.md・CLAUDE.md・RTK.mdの実ファイルはなかった。再開時の環境にある指示を確認する。
- 本体を変更する場合は、隣接`kirimasim`のCLAUDE.md・AGENTS.mdを読む。仕様変更、期待値変更、依存追加、ローカルCIの規則は、その作業範囲に適用する。
- コミットは英語の短い件名、GitHub noreplyの作者情報、実際の支援モデルを記すトレーラーを使用してきた。次の担当者は対象リポジトリの規約に従う。

## 3. 直近に完了した変更

- **`93853a48`：Issue #21の回帰取り込み**
  - 20候補へ新規74件と既存14件を対応付けた。
  - `generators/combination_events.py`、`combination_nba.py`、`combination_aggregates.py`、`combination_io.py`、`combination_monitors.py`を追加。
  - file monitorは36通りから18件、40ペアと3必須条件。`heap_file_monitor_context@1`として登録。
  - `tools/combination_gaps.py`で候補ID、規格、観測点、入力ハッシュと実行証跡の整合性を検査する。
- **`f1ed9eda`：複合シフト代入と左辺選択**
  - `generators/interaction_compound.py`、`compound_shift_target@1`を追加。
  - 7,560通りから40件。308ペア・90の3因子組合せ・4必須条件。
  - スカラ・配列要素・部分選択、符号、X/Z、シフト量、添字関数の1回評価、隣接領域の保持を観測。
- **`af21eff0`：insideによる集合所属判定**
  - `generators/interaction_inside.py`、`membership_container@1`を追加。
  - 5,984通りから46件。305ペア・174の3因子組合せ・5必須条件。
  - 個別列挙・固定配列・動的配列・キュー、幅・符号・状態型・空集合・X/Z・逆順列挙を確認。
- **`f25ebecd`：関連11文書の更新**
  - README両言語、検証ガイド、手法資料、FAQ、用語集、固定版の差異一覧、Nightly・証跡管理の説明を更新。
  - 新しい保存実行の概要、Checkと実行充足の違い、補助証跡の扱いを整理した。

[Issue #21](https://github.com/kurochan001/kirimasim-tests/issues/21)はclosed。
完了したのは回帰取り込み・合法性の分類・証跡整備で、本体の全未対応機能の実装完了ではありません。
[対応表](p1-combination-regressions-20261030.md)と[照合台帳](../coverage/combination-gaps.json)を参照してください。

## 4. 検証済みの状態と残件

### 最新の保存クロス実行

`coverage/interaction-results/cross27-kirimasim-latest.json`：

- 本体`74fb2340925a`、1,346件中**1,313 pass・32 unsupported・1 fail**。
- 複合シフト代入：**40件すべてpass**。
- 集合所属判定：**19 pass・26 unsupported・1 fail**。
- 集合所属判定の実行で確認できた対象は、305ペア中208組、3因子174組中84組。必須5件は1 pass・3 unsupported・1 failで、`complete`はfalse。
- 32件のunsupportedは、従来の配列スライス代入6件と、集合として動的配列・キューを読む26件。

この本体コミットより新しい実装の結果は、このセッションでは確認していません。
次の実行では新しい結果名を使い、古いJSONを上書きしないでください。

### 不一致1件の再現箇所

[固定配列の幅・符号・RHS Xのケース](../tests/gen/ch11/test_gen_cross_inside_w33_w_us_l_fixed_n3_rhs_x.sv)。
34ビットunsignedの全1を33ビットsignedの要素と比較すると、配列形式は1、同じ要素の個別列挙は0。
11.4.13・11.4.6・11.8.2に従う共通unsigned型への0拡張では、期待値は0です。

[切り分けJSON](../coverage/interaction-qualification/20261030-inside.json)に、
2/3ビットの既知値だけの最小例、bit/logicと同符号の対照条件、実測値とビルド指紋を保存しています。
最小例でも配列=1・個別列挙=0・直接の`==?`=0を確認しました。
正常な個別列挙に「先頭の要素しか比較しない」故障を入れた場合は、不一致を検出しています。

### 固定参照版

- `cross27-icarus-13.json`：全1,346件では1,006 pass・340 known。新規inside 46件はすべてknownで、Icarus oracleの追加なし。
- `cross27-verilator-5.052-seed1.json`と`seed73.json`：各492件中427 pass・65 known。新規insideの2状態11件は各6 pass・5 known、4状態35件は対象外。
- insideの新規6件だけへVerilator oracleを登録し、残る40件は規格の期待値を保持。
- 複合シフトの新規40件はIcarusで33 pass・7 known。Verilatorは2状態9件中7 pass・2 known（両seed）。Icarusで一致した33件だけへIcarus oracleを登録。
- ビット関数には以前から変動を記録したoracle未登録ケースがある。全体の実測pass数の変化だけで、期待値やoracleを付け替えない。

具体例と根拠は[固定版の差異一覧](simulator-differences.md)、
[補助証跡の説明](../coverage/interaction-qualification/README.md)を参照してください。

### Check・Nightly・ローカル検査

- `f25ebecd`の[Check](https://github.com/kurochan001/kirimasim-tests/actions/runs/41031980130)はcompleted / success。
- `af21eff0`の[Check](https://github.com/kurochan001/kirimasim-tests/actions/runs/41029889297)もsuccess。
- 直近のコード変更後、ローカルのツール回帰**324件がPASS**。生成物・集計・メタデータ・要求照合・workflow構文検査も成功。
- `f25ebecd`の文書更新時は、追加39ローカルリンク・アンカー、記載数値、モデルのソース指紋、生成表の整合性を確認した。
- 確認できた[Nightly](https://github.com/kurochan001/kirimasim-tests/actions/runs/40972765631)はsuccessだが、対象スイートは**`360ef70c`**。現在のmain全件のNightly成功という意味ではない。
- 本書を追加したコミットのCheck結果は、別途そのコミットで確認する。

Checkの成功、テストの一致数、クロスの対象網羅、要求カバレッジは別の指標です。
`interaction_coverage.py --check`は整合性検査。
`--require-pass`は指定した保存実行の全対象組合せと必須ケースの成功を判定し、現在の集合所属判定では非ゼロを返します。

## 5. 隣接リポジトリとローカル作業場所

### kirimasim本体

確認時の`../kirimasim`はmain **`fb79248e46f65cd344ad1c7b875adbd035bee2a2`**でorigin/mainと一致。
最新の3コミットは次のとおりです。

- `9b5a065d`：portの未対応となる形を追加検証。
- `a376a2fd`：遅延なしNBAのselected static ref対応。
- `fb79248e`：ref NBA選択の確認後の測定値更新。

本体には未追跡の`docs/CLAUDE_CODE_HANDOFF_2026-10-30.md`がありました。
その冒頭の基準は`74fb2340`だったため、実際のGit状態と内容を照合してください。
隣接リポジトリや既存worktreeの作業を、このテストリポジトリの変更と混ぜないでください。

### 作業用ディレクトリ

- 最近のテスト側worktree：`../kirimasim-tests-work/issue21-20261030`、`cross26-20261030`、`cross27-20261030`、`docs-cross-20261030-af21`。
- 本体の隔離ビルド：`../kirimasim-tests-work/cross-20261030-latest`。保存実行で使ったHEADは`74fb2340`で、現在の上流より古い。再利用するなら取得・再構成・ビルド・版の一致確認が必要。
- Icarus 13.0の既存キャッシュ例：`../kirimasim-tests-work/50percent-20261023/iverilog13/bin`。存在と版を確認する。
- ほかにも古いworktreeがある。`git worktree list`で確認し、由来を調べてから利用する。
- 一時ログや調査スクリプトは継続の前提にしない。正式な入力・結果・最小例はGit内の資料とJSONを使う。
- LSIへの一般化提案は`../lsi-verification-method/docs/feature-interaction-coverage-proposal.md`。同リポジトリには`docs/method/feature-interaction-verification.md`と`docs/templates/interaction-coverage-plan.md`もある。

## 6. 再開時の確認と実行

```sh
git status --short --branch
git fetch origin
git log -5 --oneline
git rev-list --left-right --count HEAD...origin/main
git worktree list

git -C ../kirimasim status --short --branch
git -C ../kirimasim fetch origin
git -C ../kirimasim log -5 --oneline
git -C ../kirimasim rev-parse HEAD origin/main
```

未保存・未push・並行作業を確認してから検証対象を選び、必要なら隔離worktreeを作ります。
本体のbuild手順はそのリポジトリの指示に従い、CMakeの再構成後にビルドしてください。
`kirimasim --version`のコミットを、選んだ最新ソースのコミットと一致させます。

規格資料の既存配置は`../IEEE_1800-2023_SystemVerilog`です。

```sh
python3 tools/requirement_source.py --source ../IEEE_1800-2023_SystemVerilog \
  --show 11.4.13 11.4.6 11.8.2
python3 tools/interaction_coverage.py --list-tests --model membership_container
```

新しいkirimasimビルドを`KIRIMASIM_BIN`、未使用の保存先を`CROSS_RESULT_JSON`へ設定した後の実行例：

```python
import os
from pathlib import Path
import subprocess
import sys

paths = subprocess.check_output([
    sys.executable, "tools/interaction_coverage.py", "--list-tests"
], text=True).splitlines()
binary = Path(os.environ["KIRIMASIM_BIN"]).resolve()
result = Path(os.environ["CROSS_RESULT_JSON"])
if result.exists():
    raise SystemExit("保存先を変え、過去の実行JSONを保持してください")
run = subprocess.run([
    sys.executable, "tools/run_kirimasim.py", "--kirimasim", str(binary),
    "-j", "8", "--json", str(result), *paths
], check=False)
print("runner exit:", run.returncode)
```

保存先は`coverage/interaction-results/`内で、版や再確認回を識別できる新しい名前にします。
不一致や未対応が残ればランナーは非ゼロになり得ます。結果の区分とJSONを確認してください。
Icarusは`--iverilog-bin`、Verilatorは`--verilator --all --seed`で実行します。
Verilatorへ渡すパスは、ヘッダの`fourstate`が`no`のものだけに絞ってください。
Lyraは最新のmainを取得してビルドし、`run_lyra.py --commit`に実際のコミットを渡します。

## 7. 変更後の更新・確認コマンド

```sh
python3 generators/generate.py
python3 tools/interaction_coverage.py --update
python3 tools/suite_stats.py --update
python3 tools/suite_catalog.py --update
python3 tools/coverage_depth.py --update --minimum-tests 2
python3 tools/behavior_coverage.py --update --require-source-reviewed
python3 tools/requirement_matching.py --update

python3 -m unittest discover -s tools -p 'test_*.py'
python3 generators/generate.py --check
python3 tools/interaction_coverage.py --check
python3 tools/combination_gaps.py --check
python3 tools/suite_stats.py --check
python3 tools/suite_catalog.py --check
python3 tools/coverage_depth.py --check --minimum-tests 2
python3 tools/behavior_coverage.py --check --require-source-reviewed
python3 tools/requirement_matching.py --check
python3 tools/lint_metadata.py
git diff --check
```

変更したテストの再実行を保存してから、対応する集計を更新します。
資料だけの変更では、入力・期待値・証跡を不要に更新しません。
集計や共通回帰には時間がかかる場合があるため、処理の重複起動を避け、進捗を共有してください。

## 8. 新しいクロスを追加する際の要点

- `generators/interaction_cover.py`のModelを使う。直積は10,000行以内に分割し、制約・高次因子群・必須ケースを明記する。
- 同じ構文を並べるだけでなく、何が相互作用し、どの値・時刻・領域・隣接領域で誤りを区別するかを決める。
- 既存モデルの因子・制約・高次群・必須条件を変えると選択集合も変わる。再生成で旧テストが削除されていないか`git diff --name-status`を確認し、既存テストと履歴を保持する。
- `generators/generate.py`と`generators/interaction_models.py`へ登録し、`interaction_model`・`interaction_values`を生成メタデータへ付ける。
- 意味上の境界を、実装とは別の計算方法でも検算する。選択の決定性・対象射影・必須ケースは共通回帰でも検査する。
- `inside`は比較ごとの4状態結果をORする。`X inside {0,1}`はXであり、左辺の全2値具体化が集合に入ることを理由に1へまとめない。
- 部分結果を`generators/record_oracles.py`へ渡して既存oracle全体を上書きしない。新規分だけを確認し、既存登録を保持する。
- oracleタグなどのヘッダを変えると入力ハッシュも変わる。再生成後に実行し直し、古いJSONのハッシュを書き換えて成功を引き継がない。
- 新しいクロスを要求カバレッジへ自動加算しない。要求との対応登録には別の内容レビューが必要。
- README両言語、検証ガイド、固定版の差異一覧、補助証跡の説明を更新する。
- `combination_gap`はIssue #21の20候補の台帳と結び付く。別の新規モデルへ形式的に付けない。

Issue #21で分離した`fread`のrealメンバー表現、再帰VCDのprogram/interface範囲、
automatic strobeの解釈、ネイティブcallback再入・実GC回収量の未確認範囲は、
[照合台帳](../coverage/combination-gaps.json)の根拠を読まずに合格・違法へ読み替えないでください。

## 9. 次の担当者への推奨順序

1. main、隣接本体、CIの現在地を再確認する。次のユーザー指示に沿って実施範囲を決める。
2. 保存版と現在の本体版に差があるため、必要な範囲を最新ビルドで再実行する。
3. 本体の修正を進める場合は、まずinsideの幅・符号の不一致を最小例で再確認する。その後、動的配列・キューの集合26件、従来の配列スライス6件を区別して進める。
4. クロス追加を続ける場合は、既存ガイドの対象外から選ぶ。候補はinsideの範囲指定、task引数の添字変更と復帰時の可視性、キュー要素の参照寿命など。合法性と未規定の順序を先に確認する。
5. 最新mainの全件確認が目的なら、そのコミットでNightlyを実行し、全ジョブとpublishを確認する。古いNightly成功を新しいスイートへ読み替えない。

## 10. 読む資料とコード

- [検証ガイド・保存実行の概要](interaction-verification.md)
- [考え方・追加手順・他プロジェクトへの適用](interaction-verification-method.md)
- [生成したクロス計画・実行レポート](interaction-coverage.md)
- [FAQ](faq.md#7-機能間クロス検証)・[用語集](glossary.md#8-機能間クロス検証)
- [固定版の差異一覧](simulator-differences.md)
- [証跡の管理](../coverage/README.md#機能間クロスの計画と証跡)
- [補助証跡](../coverage/interaction-qualification/README.md)
- [inside生成器](../generators/interaction_inside.py)・[独立検算](../tools/test_interaction_inside.py)
- [複合シフト生成器](../generators/interaction_compound.py)・[独立検算](../tools/test_interaction_compound.py)
- [選択器](../generators/interaction_cover.py)・[モデル登録](../generators/interaction_models.py)・[集計ツール](../tools/interaction_coverage.py)
- [要求カバレッジ集計](behavior-coverage-summary.md)：12,298要求、設計対応10,986（89.33%）、実行確認7,330（59.60%、複数環境の和集合）。テスト追加とこの割合の増加は別。
- [過去の引き継ぎ](handover-20261028.md)：2026-10-29時点の要求台帳・残件。古いテスト本数を現在値にしない。

## Claude Codeへ渡す開始指示の例

```text
このリポジトリの docs/claude-code-handoff-20261030-cross-verification.md を読み、
記録と現在のGit・CI・隣接kirimasimの状態の差分を確認してください。
既存の期待値・oracle・履歴を保持し、シミュレータは実行直前に確認した最新コミットからビルドします。
計画の網羅、実行の充足、Check/Nightly、要求カバレッジを区別してください。
この後のユーザー指示に沿って作業し、検証結果と残件を日本語で報告してください。
```
