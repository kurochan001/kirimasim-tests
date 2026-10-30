# Claude Codeへの引き継ぎ：機能間クロス検証（2026-10-30）

外部状態の確認：2026-10-30 13:42 UTC（22:42 JST）。
初版は同日09:31:59 UTCの状態で書き、その後のクロス再実行、insideの再確認、範囲指定のモデルの追加を反映しました。
この資料は`kirimasim-tests`の作業を引き継ぐためのものです。
以下のコマンドは、通常の`kirimasim-tests`リポジトリのルートで実行します。

## 1. 最初に把握すること

- 範囲指定のモデルを追加する前のmainは`e1be859f90d23836983ee2e2cac7435415edcf7e`で、origin/mainと一致していました。
- 本書の今回の更新は、範囲指定のモデルと同じコミットです。再開時のHEADとpushの有無は`git log`と`git status`で確認してください。
- 現在の継続テーマは、機能間クロスを全直積にせず、規格に基づく期待値と観測を備えた有限モデルとして追加することです。
- スイートは**9,142件、生成2,705件**（初版から手書き1件と範囲指定の生成46件を追加）。クロスの短時間実行は**28モデル・1,392件**です。
- クロスの計画が網羅できても、シミュレータの実装がすべて合格したことにはなりません。
- 最新の保存クロス実行はkirimasim **`f303becad9ca`**（確認時の上流main）で、1,392件中1,343 pass・48 unsupported・1 failです。保存結果を新しい本体の結果へ読み替えないでください。
- insideの不一致1件は`fc4cc356`で再確認し、配列集合の符号付き要素を0拡張せず符号拡張する形だと絞り込みました。本体は変更していません。`f303beca`のクロス実行でも同じ1件が不一致です。

まず[保存実行の概要](interaction-verification.md#保存実行の概要)、
[設計思想・追加手順](interaction-verification-method.md)、本書を読んでください。

## 2. ユーザーの方針と作業上の注意

- 日本語で簡潔に進捗と結果を伝える。長い検証中も状況を共有する。英語で報告して言い直しを求められたことがあるので、報告は必ず日本語にする。
- mainへのcommit・pushを繰り返し依頼されており、検証後に反映する流れで作業してきた。
- シミュレータを実行するときは、その直前に最新コミットを取得・確認し、その版をビルドする。古いビルドをそのまま使わない。
- **kirimasimとLyraは別のシミュレータ**。それぞれ`tools/run_kirimasim.py`と`tools/run_lyra.py`を使う。kirimasimの結果をLyraの結果として報告しない。
- Icarus 13.0・Verilator 5.052は固定oracleの確認用。開発版の一致を、これら固定版のoracleへ読み替えない。Verilatorの確認では2状態テストをseed 1・73で別々に実行する。
- 既存テスト・期待値・oracle・過去の実行証跡を保持する。未対応を成功の期待値にせず、合格率のために合法な因子を削らない。
- Icarus・VerilatorなどGPL/LGPLの実装ソースを読まず、他プロジェクトの再現コードをコピーしない。規格、独立計算、実行結果から検証する。
- Icarus・Verilatorとの差異は上流へ報告せず、[固定版の差異一覧](simulator-differences.md)へ記録する。テストのコメントに他のシミュレータの出力を書くときは、実行して確かめてから書く。
- コメント行を`Verilator`という語で始めない。Verilatorが指示として読むため、`tools/lint_metadata.py`が`verilator-comment`として検出する。
- Icarus・Verilatorのoracleが付いていないテストの不一致は、ランナーがknownとして数え、failにしない。
- 規格本文・図表の転載、ホームの絶対パス、個人情報、非公開資料を公開ファイルへ入れない。
- 過去にサブエージェントの活用と6名程度までの利用希望があった。現在の環境・指示の利用条件に従う。
- この会話では`@RTK.md`の参照が指定されている。確認時、当リポジトリのルートにAGENTS.md・CLAUDE.md・RTK.mdの実ファイルはなかった。再開時の環境にある指示を確認する。
- 本体を変更する場合は、隣接`kirimasim`のCLAUDE.md・AGENTS.mdを読む。仕様変更、期待値変更、依存追加、ローカルCIの規則は、その作業範囲に適用する。
- コミットは英語の短い件名、GitHub noreplyの作者情報、実際の支援モデルを記すトレーラーを使用してきた。次の担当者は対象リポジトリの規約に従う。

## 3. 直近に完了した変更

### 初版の後（2026-10-30）

- **範囲指定のモデル（本書の今回の更新と同じコミット）**
  - `generators/interaction_range.py`、`membership_range@1`、独立検算`tools/test_interaction_range.py`を追加。
  - 閉区間・逆順・`$`端点・絶対/相対許容差、端点の幅・符号・bit/logic、X/Z、値との混在をクロス。5,680通りから46件、303ペア・178の3因子組合せ・6必須条件。
  - 規格本文の読み方が分かれる組合せ（端点X/Zの範囲、X/Zを含む空の範囲、許容差の桁あふれ）は、どの読み方でも同じ結果になる入力と制約で避けた。
  - kirimasim `f303beca`は30 pass・16 unsupported（許容差の範囲）。Verilator 5.052は両seedで2状態16件中7件一致で、この7件だけoracle登録。`$`端点の結果の差異を差異一覧へ記録。Icarus 13.0は46件すべてknown。
  - 28モデル・1,392件を`cross28-*.json`として、kirimasim・Icarus・Verilator両seedで保存。証跡は`coverage/interaction-qualification/20261030-range.json`（`$`端点の小さな例、故障注入7種）。
- **`e1be859f`**：READMEの履歴を`docs/history.md`・`docs/history.ja.md`へ移した。
- **`6dccebdd`**：本書の初版。
- **`b52cebd4`：最新kirimasimでのクロス再実行**
  - 実行直前に確認した上流main `fb79248e46f6`でビルドし、全1,346件を`cross27-kirimasim-fb79248e.json`へ保存した。
  - 1,313 pass・32 unsupported・1 failで、`74fb2340`の保存実行から区分が変わったケースはない。入力ハッシュも同じ。
- **`4469ee37`：insideの不一致の再確認**
  - 上流main `fc4cc356`で再ビルドし、保存済みの最小例2件（bit・logic）が前回と同じ出力で再現した。
  - 左辺の値を変えた最小例で、kirimasimが配列集合の符号付き要素を符号拡張して比較していることがわかった。0拡張が正しい。localparamの定数として評価すると正しい結果になる。
  - 2状態だけの手書きテスト`tests/ch11/test_inside_array_set_mixed_sign_width.sv`を追加した（`:oracle: spec`）。要求との対応は登録しておらず、カバー率は変わらない。
  - Verilator 5.052の新しい逸脱を[固定版の差異一覧](simulator-differences.md)へ記録した。
  - 証跡は`coverage/interaction-qualification/20261030-inside-fc4cc356.json`。

### 初版の時点で完了していたもの

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

`coverage/interaction-results/cross28-kirimasim-f303beca.json`：

- 本体`f303becad9ca`、1,392件中**1,343 pass・48 unsupported・1 fail**。従来の1,346件の状態は`fb79248e`と同じ。
- 範囲指定：**30 pass・16 unsupported**（許容差の範囲）。303ペア中252組、3因子178組中117組、必須6件中4件。
- 27モデルの`cross27-kirimasim-fb79248e.json`（`fb79248e46f6`）と`cross27-kirimasim-latest.json`（`74fb2340925a`）は、どちらも1,313 pass・32 unsupported・1 fail。すべて保持する。
- 複合シフト代入：**40件すべてpass**。
- 集合所属判定：**19 pass・26 unsupported・1 fail**。
- 集合所属判定の実行で確認できた対象は、305ペア中208組、3因子174組中84組。必須5件は1 pass・3 unsupported・1 failで、`complete`はfalse。
- 48件のunsupportedは、従来の配列スライス代入6件、集合として動的配列・キューを読む26件、許容差の範囲16件。

`f303beca`より新しい版では、クロス全体を実行していません。手書きテスト`test_inside_array_set_mixed_sign_width`はクロスの対象外で、最後に実行したのは`fc4cc356`です。
次の実行では新しい結果名を使い、古いJSONを上書きしないでください。

### 不一致1件の再現箇所

[固定配列の幅・符号・RHS Xのケース](../tests/gen/ch11/test_gen_cross_inside_w33_w_us_l_fixed_n3_rhs_x.sv)。
34ビットunsignedの全1を33ビットsignedの要素と比較すると、配列形式は1、同じ要素の個別列挙は0。
11.4.13・11.4.6・11.8.2に従う共通unsigned型への0拡張では、期待値は0です。

[切り分けJSON](../coverage/interaction-qualification/20261030-inside.json)に、
2/3ビットの既知値だけの最小例、bit/logicと同符号の対照条件、実測値とビルド指紋を保存しています。
最小例でも配列=1・個別列挙=0・直接の`==?`=0を確認しました。
正常な個別列挙に「先頭の要素しか比較しない」故障を入れた場合は、不一致を検出しています。

`fc4cc356`での再確認（[証跡](../coverage/interaction-qualification/20261030-inside-fc4cc356.json)）：

- 保存済みの最小例2件は、前回の記録と同じ出力で再現した。
- 3ビットunsignedの左辺と、2ビットsigned要素`11`の配列集合を比べた。左辺`111`では配列=1（期待値0）、`011`では配列=0（期待値1）で、ずれる向きが逆になる。要素を`011`でなく`111`として比較していると読める。
- 2要素の`{01, 11}`でも、左辺`111`で配列=1。同じ比較をlocalparamの定数にすると配列=0で正しい。
- 個別列挙の形は、すべて期待値どおり。
- 手書きテストでkirimasimが期待値と異なるのは、1〜3行目の配列形式だけ（1/0/1、期待値は0/1/0）。signedの左辺を使う4・5行目は正しい。

### 固定参照版

- `cross28-icarus-13.json`：全1,392件で1,008 pass・384 known。範囲指定46件はすべてknown。以前から変動を記録しているビット関数の2件がknownからpassに変わったが、oracleは変えていない。
- `cross28-verilator-5.052-seed1.json`と`seed73.json`：各508件中434 pass・74 known。範囲指定の2状態16件は各7 pass・9 known（許容差の構文4件、変数の4状態RHSの`==?`3件、`$`端点の結果2件）。
- `cross27-icarus-13.json`：全1,346件では1,006 pass・340 known。新規inside 46件はすべてknownで、Icarus oracleの追加なし。
- `cross27-verilator-5.052-seed1.json`と`seed73.json`：各492件中427 pass・65 known。新規insideの2状態11件は各6 pass・5 known、4状態35件は対象外。
- insideの新規6件だけへVerilator oracleを登録し、残る40件は規格の期待値を保持。
- 複合シフトの新規40件はIcarusで33 pass・7 known。Verilatorは2状態9件中7 pass・2 known（両seed）。Icarusで一致した33件だけへIcarus oracleを登録。
- 手書きテスト`test_inside_array_set_mixed_sign_width`：Icarus 13.0は`inside`が未対応。Verilator 5.052は両seedで同じ出力。1・3行目は配列形式が1で、個別列挙は正しい0。4行目は配列・個別列挙とも1で、signedの左辺を幅の広いunsignedの要素に対して符号拡張している。どちらのoracleも付けていない。
- ビット関数には以前から変動を記録したoracle未登録ケースがある。全体の実測pass数の変化だけで、期待値やoracleを付け替えない。

具体例と根拠は[固定版の差異一覧](simulator-differences.md)、
[補助証跡の説明](../coverage/interaction-qualification/README.md)を参照してください。

### Check・Nightly・ローカル検査

- `4469ee37`の[Check](https://github.com/kurochan001/kirimasim-tests/actions/runs/41041450032)はcompleted / success。
- `b52cebd4`の[Check](https://github.com/kurochan001/kirimasim-tests/actions/runs/41038897723)、`6dccebdd`の[Check](https://github.com/kurochan001/kirimasim-tests/actions/runs/41035144950)もsuccess。
- `4469ee37`の状態で、ローカルのツール回帰**324件がPASS**。生成物・集計・メタデータ・要求照合の検査も成功。
- 確認できた最新の[Nightly](https://github.com/kurochan001/kirimasim-tests/actions/runs/40972765631)はsuccessだが、対象スイートは**`360ef70c`**。現在のmain全件のNightly成功という意味ではない。
- 本書を更新したコミットのCheck結果は、別途そのコミットで確認する。

Checkの成功、テストの一致数、クロスの対象網羅、要求カバレッジは別の指標です。
`interaction_coverage.py --check`は整合性検査。
`--require-pass`は指定した保存実行の全対象組合せと必須ケースの成功を判定し、現在の集合所属判定では非ゼロを返します。

## 5. 隣接リポジトリとローカル作業場所

### kirimasim本体

確認時の`../kirimasim`はmain **`f303becad9cafcb96221bcfd4321a92341bab4ff`**でorigin/mainと一致し、未pushのコミットはありませんでした。
本体側の作業は続いていて、本書の初版の後に次の5コミットが入りました。

- `b64f3781`：文字列の文字へのNBA。
- `fc4cc356`：その測定値の更新。insideの再確認に使った版。
- `a7ee20a4`・`a8566e8b`：NBAアリーナを解放する時期。
- `f303beca`：その測定値の更新。

本体には未追跡の`docs/CLAUDE_CODE_HANDOFF_2026-10-30.md`が残っています。
その冒頭の基準は`74fb2340`だったため、実際のGit状態と内容を照合してください。
隣接リポジトリや既存worktreeの作業を、このテストリポジトリの変更と混ぜないでください。

### 作業用ディレクトリ

- 最近のテスト側worktree：`../kirimasim-tests-work/issue21-20261030`、`cross26-20261030`、`cross27-20261030`、`docs-cross-20261030-af21`。
- 本体の隔離ビルド：`../kirimasim-tests-work/cross-20261030-latest`。HEADは`fc4cc356`（detached）で、ビルド済みの`kirimasim --version`も`fc4cc3569fd6`。現在の上流より古いので、再利用するなら取得・再構成・ビルド・版の一致確認が必要。
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
  --show 11.4.13 11.4.6 11.8.1 11.8.2
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
- README両言語、検証ガイド、固定版の差異一覧、補助証跡の説明を更新する。READMEには現時点の情報だけを書き、置き換えた以前の記録や測定は[履歴](history.ja.md)（英語版は`docs/history.md`）へ移す。
- `combination_gap`はIssue #21の20候補の台帳と結び付く。別の新規モデルへ形式的に付けない。

Issue #21で分離した`fread`のrealメンバー表現、再帰VCDのprogram/interface範囲、
automatic strobeの解釈、ネイティブcallback再入・実GC回収量の未確認範囲は、
[照合台帳](../coverage/combination-gaps.json)の根拠を読まずに合格・違法へ読み替えないでください。

## 9. 次の担当者への推奨順序

1. main、隣接本体、CIの現在地を再確認する。次のユーザー指示に沿って実施範囲を決める。
2. 本体のinsideを直す場合は、最新ビルドで手書きテスト`test_inside_array_set_mixed_sign_width`と`test_gen_cross_inside_w33_w_us_l_fixed_n3_rhs_x`を先に実行し、再現を確かめる。直す箇所は配列集合を比較する経路での符号付き要素の拡張。本体の規約に従い、本体側で続いている作業と混ぜない。
3. その後、動的配列・キューの集合26件と、従来の配列スライス6件を区別して進める。
4. 保存版と現在の本体版に差があるため、必要な範囲を最新ビルドで再実行し、新しい結果名で保存する。
5. クロス追加を続ける場合は、既存ガイドの対象外から選ぶ。候補は`case ... inside`（12.5.4。一致の優先順位、Xの比較を不一致として後続の項目へ進むこと、項目の評価回数）、task引数の添字変更と復帰時の可視性、キュー要素の参照寿命など。合法性と未規定の順序を先に確認する。既存の`ch12/test_case_inside_evaluation_order_by_qualifier`との重複も確認する。
6. 最新mainの全件確認が目的なら、そのコミットでNightlyを実行し、全ジョブとpublishを確認する。古いNightly成功を新しいスイートへ読み替えない。

ユーザーの判断を待っているもの：

- 未マージのブランチ`fix/p1-conditional-reactive-tests`（2コミット）。ch4の`test_reactive_region_set_order`の期待値を変える。
- このリポジトリのopen issue #22〜#36。#36（ch21の`"\60x"`が5.9.1で違法なエスケープになる）は2026-10-30に作成された。
- slangへのストリーミングの不具合の報告案。`../kirimasim-tests-work/slang-issue-streaming-20261028/`にあり、ユーザーの以前の報告slang #2072（確認時はOPEN）が処理されてから提出する。kirimasim-testsへのリンクは付けない。

## 10. 読む資料とコード

- [検証ガイド・保存実行の概要](interaction-verification.md)
- [考え方・追加手順・他プロジェクトへの適用](interaction-verification-method.md)
- [生成したクロス計画・実行レポート](interaction-coverage.md)
- [FAQ](faq.md#7-機能間クロス検証)・[用語集](glossary.md#8-機能間クロス検証)
- [固定版の差異一覧](simulator-differences.md)
- [証跡の管理](../coverage/README.md#機能間クロスの計画と証跡)
- [補助証跡](../coverage/interaction-qualification/README.md)・[insideの再確認](../coverage/interaction-qualification/20261030-inside-fc4cc356.json)
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
