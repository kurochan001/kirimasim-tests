# Claude Codeへのハンドオフ：50%到達作業（2026-10-23開始、2026-10-24に50%到達）

> **現在の値（2026-10-25 更新）**
> 本文は各時点の記録です。現在の正本は
> [`coverage/behavior-summary.json`](../coverage/behavior-summary.json) で、値は次のとおりです。
>
> - 要求対応：**10,562 / 12,319（85.74%）**、実行成功：**5,800（47.08%）**
> - 未対応：1,757、解釈保留：21行、分母：未承認（`provisional`）
> - テスト：7,407本（対応登録済み4,992本、未登録2,415本）
> - 75%＝9,240要求まで、75%を**達成**（9,240以上）

## nightly とシミュレータの変更（2026-10-24）

- 比較対象を Icarus・Verilator・kirimasim・Lyra（`LYRA_COMMIT` で固定）の4つにした（nvc は10月24日に加え、対応が少ないため10月25日に外した）。以前のもう1つのシミュレータは名前ごと削除した（新しいファイルやコミットメッセージに名前を出さない）。
- 推移図とレポートは、`tools/run_<id>.py` があるシミュレータだけを描く。
- 新規テストを統合したら、最初の nightly で全ジョブが最後まで走ったかを確かめる。1回目で入れた `ch16/test_illegal_sequence_cycle_through_bodies` で Verilator が暴走し、ランナーが止まったことがある（いまは `ulimit -v` で制限）。
- 規格PDFの置き場所は `../IEEE_1800-2023_SystemVerilog`（手元では元の場所へのシンボリックリンク）、または `$IEEE1800_SOURCE`。Workflow の `pdf` 引数も、このパスで渡せる。
- 期待値が規格と食い違う疑いのあるテスト（除外の候補）は `docs/simulator-differences.md` の最後の節にある。

## 75%を目指す再開（2026-10-24、1回目まで統合）

- 目標：75%超過 ＝ 9,240要求。**1回目を統合して7,341要求（59.590876%）**、あと1,899要求。記録は[gap-tests-2-20261024.md](gap-tests-2-20261024.md)。
- その後も照合が進み、2026-10-26時点で**10,562要求（85.737479%）**、75%を達成。
- 統合分はコミット`1a2c833`として`main`へpush済み（2026-10-24）。
- 1回目（Run ID `wf_71865177-920`、約861万トークン、週間上限は59%→約70%）：g01、g02、g03、g04、g06、g07、p08、p25。照合案は採用928・却下102、テストは合格936・欠陥26。
- 合格936本のうち933本を取り込んだ（一覧`usable3b-tests.txt`）。12.2、12.3、12.4.2.1、12.5.3.1を1本だけで引用する3本は、2本目のテストが要るので外した（`parked3/`に退避）。
- 未検証の区間のテストは`parked3/`（一覧`parked3-files.txt`、テスト679本）。続けるときは`rsync -a <作業dir>/parked3/tests/ tests/`で戻す。欠陥と判定済みのテストは`notes/*-testverdicts.jsonl`の最後の判定で見分ける。
- ユーザーの判断で、2回目以降は週間上限に余裕が戻ってから行う。
  - 2回目の予定：p01、p05、p07、p09、p10、p12、p13、p15
  - 3回目の予定：a01〜a05、g05、g08、g09、h01、h02（照合案は2回目と合わせて1,388件、未対応の1,356要求）
- `tools/matching_kit/workflows/gap.js`の指示文に、欠陥とされた理由の一覧を足した（`` `line ``と同じ行のコメント、仮想インターフェースの入力ポートを含む）。
- `tests/ch22`に新しいテストを足すと、`tests/ch22`をインクルード検索ディレクトリにする既存4本の入力ハッシュが変わる。統合時に一緒に再実行し、台帳と保留の入力ハッシュを付け直すこと。

### 1回目までの準備の記録

- 目標：75%超過 ＝ 9,240要求（`b13204c`時点の6,430から、あと2,810）。
- `parked2/`のテストを、欠陥と判定済みの32本を除いて`tests/`へ戻した（1,832ファイル。除いたものは作業ディレクトリの`restored3-skipped.txt`）。いま`tests/`には未検証のテストがある。生成物の再生成やコミットは、統合の手順まで行わない。
- `tools/matching_kit/workflows/gap.js`の指示文に、前回の検証で欠陥とされた理由の一覧を足した（未コミット）。
- 進め方：作成の再開（`resume: true`）と独立検証を、8区間ずつ回す。
  - 1回目（Run ID `wf_71865177-920`）：g01、g02、g03、g04、g06、g07、p08、p25
  - 2回目の予定：p01、p05、p07、p09、p10、p12、p13、p15（1回目の後、ユーザーが週間上限の増え方（開始時59%）を見て、続けるかを決める）
  - 3回目の予定：a01〜a05、g05、g08、g09、h01、h02
  - 足りなければ、検証済みの区間（p02〜p24）の残りの未対応要求で作成を続ける。
- Workflowが止まった場合は、同じ`scriptPath`と引数で`resumeFromRunId`を付けて再開する。

## 2026-10-24の再開後の状態

- **50%に到達**：13区間（p02、p03、p04、p06、p11、p16〜p19、p21〜p24）の独立検証を終え、新規テスト594本と照合案を取り込んだ。
  **6,430 / 12,319要求（52.195795%）**、暫定実行確認率30.310902%（3,734）、本文（1〜40章）だけで53.47%（5,072/9,486）。
- 記録：[gap-tests-20261024.md](gap-tests-20261024.md)（集計、章別、検証結果、欠陥30本の内訳、`input int`の指摘、残り）。
- コミット：取り込み分はコミット`0ab9e18`として`main`へpush済み（2026-10-24）。
- 取り込んだテストの一覧：作業ディレクトリの`usable2-tests.txt`（594本）。実行証跡は`coverage/results/gap-tests-20261024-*.json`と、取り込み後に直した3本の`gap-refinement-20261024-*.json`。
- 未検証のテストは作業ディレクトリの`parked2/`（1,893ファイル、うちテスト1,117本。欠陥とされた30本も含む。一覧`parked2-files.txt`）。
  再開時は`rsync -a <作業dir>/parked2/tests/ tests/`で戻す。欠陥の30本は`notes/*-testverdicts.jsonl`の最後の判定が`defective`のもの。
- 未検証の照合案（1,752件）：

| wave | 区間（未判定の案の数） |
| --- | --- |
| wave1 | p12-gap（110） |
| wave2 | p01-gap（107）、p05-gap（110）、p07-gap（75） |
| wave3 | p08（95）、p09（100）、p10（124）、p13（111）、p15（138）、p25（95） |
| wave4 | a01〜a05（288、附属書Aの構文）、g01〜g09（305）、h01〜h02（94） |

- 続けるなら、`tools/matching_kit/workflows/gap.js`の`verifyOnly: true`で上の区間を検証し、前回と同じ手順で統合する。`merge.py`は保留判断の重複を防ぐよう修正済み。
- 統合前に確かめること（今回分かったこと）：
  - ANSI形式で種類を省いた2状態型の入力（`input int`）はネットになり違法（23.2.2.3、6.7.1）。`input var int`にする。
  - 新規テストが、これまで引用のない節を1本だけで引用すると`coverage_depth.py --check --minimum-tests 2`が落ちる。背景の節なら`:lrm:`から外す。
  - 取り込み後にテストを直したら、再実行を別名の結果ファイルに保存し、台帳の`inputs_sha256`を更新して`--write-baseline --reason`で記録する。`--history`は最後に1回だけ。

以下は、2026-10-24の再開前の記録です。

## 中断時の記録（2026-10-23）

### 最初に把握すること

「暫定設計網羅率を50%まで進める」作業を、トークン消費が大きいため途中で中断しました。
中断後、**独立検証を終えた分だけを台帳へ取り込みました**（附属書ヘッダテスト24本、37章VPIテスト24本、既存テストの照合）。
取り込み後の値は3,889 / 12,319要求、暫定設計網羅率31.569121%、暫定実行確認率19.449631%（2,396）です。
取り込み分はコミット`ba54eb3`として`main`へpush済みです（2026-10-24）。
検証前の新規テスト約1,711本はリポジトリの外へ退避しています。再開時は作業ディレクトリから戻してから始めてください。

- リポジトリ：kirimasim-tests（`main`、HEAD `af50ecf`＝10%・20%到達分。push済み）
- 正本の値：`ba54eb3`で3,889要求（31.57%）。その後の台帳見直し（`721db37`）と予約語の生成テスト（`1f9efc5`、2026-10-24）で **4,386 / 12,319 要求、35.60%**
- 目標：50%超過 ＝ 6,160 要求（`1f9efc5`時点であと1,774）
- 取り込みの記録：[header-vpi-tests-and-matching-20261023.md](header-vpi-tests-and-matching-20261023.md)
- 作業ディレクトリ（リポジトリ外、再開に必須）：
  リポジトリの隣の`kirimasim-tests-work/50percent-20261023/`
- 前回の引き継ぎ（照合の判断基準など）は [claude-code-handoff-20261023.md](claude-code-handoff-20261023.md) を参照。基準はそのまま有効です。

## 中断時点の数値

| 段階 | 要求数 | 暫定設計網羅率 |
| --- | ---: | ---: |
| コミット済み | 2,465 | 20.01% |
| ＋独立検証で採用済み（未統合） | 3,889 | 31.57% |
| ＋検証待ちの対応案がすべて採用された場合 | 7,847 | 63.70% |

- 採用済み1,424要求の内訳：附属書K/M/L/Iのヘッダテスト1,081、既存テストの照合153、新規テスト約190（p20）。
- 検証待ち：3,958要求分の対応案（3,967件）。これまでの検証では2〜4割が却下されている。50%には、このうち2,271要求（57%）の採用が必要。
- 採用は附属書ヘッダ（定数1個＝1要求行）に偏っている。本文（1〜40章、分母9,486）だけで数えると、コミット済み25.6% → 採用済み込み29.3%。最終報告では全体値と本文のみの値・章別内訳を併記する予定。

## 取り込み前（中断直後）の作業ツリーの状態

以下は中断直後の記録です。その後の取り込みで、検証済みの48本（`usable-tests.txt`）だけを`tests/`に残し、
それ以外の未追跡のテストファイル3,069個を作業ディレクトリの`parked/`へパスを保ったまま移しました（一覧`parked-files.txt`）。
再開時は、リポジトリルートで`rsync -a <作業dir>/parked/tests/ tests/`を実行して戻します。
p20で欠陥ありとされた2本と、lint違反の13本も`parked/`に入っています。


- 未追跡の新規テスト：**1,759本**（`tests/` 以下、`.sv`/`.expected`/`.c` 等、計3,214ファイル）。
  一覧：作業ディレクトリの `new-tests.txt`、全未追跡ファイルの一覧 `untracked-files.txt`、
  バックアップ `untracked-worktree.tgz`（`tar xzf <tgz>` をリポジトリルートで実行すると復元）。
- うち24本は私（Claude）が書いた附属書ヘッダテスト（検証済み、下記）。残りは担当エージェントが書いたもので、**p20の26本（合格24・欠陥2）以外は未検証**。
- lint違反13本（書きかけ）：作業ディレクトリの `new-tests-lint.txt`。TODO残り・期待出力が空/なし・行長。
- 変更済みtracked：`coverage/test-matching.json`、`docs/test-requirement-matching.md`（新規テストを含めて再生成しただけ。最終統合時にもう一度再生成する）。
- このハンドオフ資料自体も未追跡。

## 作業ディレクトリの中身

| パス | 内容 |
| --- | --- |
| `kit/propose.py` | 照合案の照会・登録・判定のCLI。`req`/`test`/`scope`/`add`/`group`/`hold`/`show`/`verdict`/`testverdict`。登録時に`validate()`相当（節の引用、正負の種別、anchorの実在、入力ファイル、既存の保留・20%監査の取り下げ・BLOCKED）を検査する。新規テストはファイルシステムから自動で認識する。 |
| `kit/merge.py` | 最新の判定がacceptの案だけを`behaviors.json`と`test-matching-reviews.json`へ統合（`--dry-run`あり）。統合時に再検査し、入力digestを計算する。reviewerは`Claude Opus 5.5 (AI); not an independent human review`。 |
| `kit/runsim.py` | Icarus 13.0とVerilator 5.052（seed 1/73）で実行し一致を表示（ccache使用）。 |
| `iverilog13/` | Icarus Verilog 13.0（`v13_0-dirty`、保存済み証跡と同じ版表記）。移動しても動く。再ビルドは`iverilog13-source.txt`のタグ`v13_0`に`iverilog13-macos.patch`を当て、`PATH=/opt/homebrew/opt/bison/bin:$PATH`で`sh autoconf.sh && ./configure --prefix=... && make && make install`。 |
| `assign/*.json` | 担当範囲（要求IDの一覧）。`p01`〜`p25`：引用テストのある要求、`g01`〜`g09`：引用テストのない本文の要求、`a01`〜`a05`：附属書A、`h01`〜`h02`：附属書C/G/H/J/N。 |
| `proposals/<wave>/<label>.jsonl` | 照合案。`.verdicts.jsonl`が判定（同じキーは最後の判定が有効）。`-gap`は照合後に書いた新規テストの案。`annex/`は附属書ヘッダテスト。 |
| `notes/<label>-tests.txt` | 各担当が作った新規テストの一覧（中断時の孤立テスト111本も区間へ振り分け済み）。`-testverdicts.jsonl`がテストの合否、`-simdiff.md`がシミュレータの規格差異メモ。`annex-simdiff.md`は附属書テストの差異の下書き。 |
| `wf-gap.js` | Workflowスクリプト（作成→検証のpipeline）。`args = {sp, parts:[{label,wave,mode}], verifyOnly?, resume?}`。modeは`gap`（照合後の新規テスト）/`combined`（照合と新規テスト）/`annexA`（構文テスト）。 |
| `wf-match.js` | 既存テスト照合だけのWorkflow（wave1/2で使用）。 |
| `parts.json` | 再開用の全区間（label/wave/mode/中断時の未判定案数）。 |
| `status-table.md` | 区間ごとの採用/却下/未判定と、テストの一覧数/合格/欠陥。 |
| `annex/` | 附属書ヘッダテストの生成スクリプト（`gen_constants.py`、`gen_decls.py`、`gen_decls2.py`、`gen_compat.py`）、規格本文から復元した参照ヘッダ`refhdr/`、自己確認`selfcheck.py`。 |
| `start/` | 作業開始時の`behaviors.json`等のコピー。 |
| `verifier-artifacts/` | 検証担当が規格本文から再構成したヘッダと変異試験の作業物。 |

**2026-10-24以降は、リポジトリに取り込んだ`tools/matching_kit/`を使います**（作業ディレクトリの`kit/`と`wf-*.js`は中断時点の古い版）。
違いは次のとおりです。照合案と判定のファイル形式は同じで、そのまま使えます。
- `merge.py`は`--reviewer`と`--date`が必須。
- `runsim.py`は`--iverilog-bin <作業dir>/iverilog13/bin`を指定する。
- Workflowは`tools/matching_kit/workflows/gap.js`を使い、`args = {repo, work: "<作業dir>", pdf, iverilogBin, parts, verifyOnly?, resume?}`を渡す。

## この作業で決めたこと・判明したこと

- `validate()`は対応テストが要求の節を`:lrm:`で引用していることを必須にしている（`tools/behavior_coverage.py:113`）。引用していない既存テストは対応付けできない（照合担当が「引用を足せば対応できる」例を多数報告しているが、テスト入力が変わり証跡が古くなるため今回は見送った）。
- 既存テストの照合は採用率が低い（9区間で153要求）。主因は、必要な刺激を持つ既存テストが無いこと。新規テストの作成に切り替えた。
- 附属書B（予約語248）と22.14.xの版別キーワード行は、2026-10-24の台帳見直しで違法系（`kind=error`、`begin_keywords`で版を明示）に組み替えた。予約語ごとの違法系テストを作れば対応付けできる（生成スクリプト化が安い）。F（形式意味論）と34章（保護エンベロープ）は見送り。p14（22.14.2〜22.14.6）は未着手。解釈保留は27論点を解消し、19論点・21行が残る（[requirement-extraction.md](requirement-extraction.md)）。
- 附属書ヘッダテスト（`tests/ch36/test_vpi_user_h_*`、`test_sv_vpi_user_h_*`、`test_vpi_compatibility_h_*`、`tests/ch35/test_svdpi_h_*`の24本）は独立検証を3回経て、1,081要求が採用。却下・見送りは、使い方の規則や値の意味を含む行（DELAY-FIELD、VALUE/ARRAYのメンバー、STEP-STRUCT、L.1 INCLUSION、SIZE-TYPES、TIME、VECTOR、STRENGTH、SYSTFなど）、I.3 SCALARS（`#if`の穴、テストは修正済みだが未再検証）、I.3 UNSIGNED（未定義動作でコンパイラ依存、コーディネータ判断で却下）、I.3 MASK（観測できない条件を含む）。
- Icarus 13.0のヘッダはK.2/M.2の855定数のうち218個だけを定義（値はすべて正しい）。両シミュレータとも`vpi_compatibility.h`を持たない。Verilator 5.052の`svdpi.h`は`SV_MASK`を`~(0xffffffffU << (N))`（unsigned）にしている。`notes/annex-simdiff.md`に`docs/simulator-differences.md`向けの下書きあり。
- 規格ヘッダの所見（検証担当報告）：K.2/I.3の非Linux分岐は`<sys/types.h>`だけでmacOSでは`uint64_t`等が無い。L.2の`1800v2017`/`1800v2023`は`VPI_COMPATIBILITY_VERSION_1800v2012`を空で定義し、後の`#elif`がエラーになる。

## 再開手順

1. 取り込み分がコミット済みかを`git log`で確認する。`parked/`のテストを`tests/`へ戻す（`rsync -a <作業dir>/parked/tests/ tests/`）。作業ディレクトリが残っていることも確認する。
   附属書（`proposals/annex`）、wave1/wave2の照合、p20の新規テストは取り込み済みなので、検証も統合もやり直さない（`merge.py`は統合済みの案をスキップする）。
2. **安い順に進める。まず検証だけ。** 検証待ちの案（3,967件）と新規テストを、`wf-gap.js`の`verifyOnly`で検証する。
   `Workflow({scriptPath: "tools/matching_kit/workflows/gap.js", args: {repo, work: "<作業dir>", pdf, iverilogBin: "<作業dir>/iverilog13/bin", verifyOnly: true, parts: [...]}})`。
   `parts`は`parts.json`の`pending_proposals > 0`の区間から、1回あたり8区間程度を選ぶ。
   p20は検証と取り込みまで完了、p04は作成済みで未検証。
   要求単位の採用率が57%以上なら、検証だけで50%を超える。
3. 50%に届かなければ、`resume: true`（verifyOnlyなし）で作成担当を再開する。中断時の作成担当は、全区間とも書きかけの状態で止まっている。
4. 統合（全検証の後）：
   1. `testverdict`がdefectiveのテストと、判定の無いテストを削除する（未追跡ファイルのみ。`.expected`/`.c`/補助ファイルも）。lint違反の13本も同様に扱う。
   2. 残った新規テストを`run_icarus.py --iverilog-bin <作業dir>/iverilog13/bin`と`run_verilator.py --all --seed 1/73`（`OBJCACHE=ccache`）で実行し、`:oracle:`の記載と結果を突き合わせる。食い違いは`:oracle:`を直す（入力が変わるので直した後に再実行）。
   3. 記録用の本実行を`coverage/results/<名前>-20261023-icarus13.json`、`-verilator-seed1.json`、`-verilator-seed73.json`として保存する（既存の全件結果は上書きしない）。
   4. `python3 tools/matching_kit/merge.py <作業dir>/proposals/<wave> --reviewer '<モデル名> (AI); not an independent human review' --date YYYY-MM-DD`を各ディレクトリについて実行する（`annex`を含む）。統合は「未対応の要求」だけを受け付けるので、同じ要求の2件目以降はSKIPと表示されるが問題ない。
   5. `requirement_matching.py --update`、`behavior_coverage.py --update --require-source-reviewed --history coverage/behavior-history.json`、`suite_stats.py --update`、`suite_catalog.py --update`、`coverage_depth.py --update`を実行する。
   6. 文書を更新する：`docs/simulator-differences.md`（`notes/*-simdiff.md`を確認のうえ）、README、`coverage/README.md`の結果ファイル一覧、結果報告（新規）、`docs/nightly-results.md`のmain集計欄。
   7. 前回の引き継ぎにある全検査を通してからコミットする。

## 費用の目安

照合担当1体と検証担当1体の組で、約30万〜60万トークン（出力ベースの`subagent_tokens`）。検証担当1体（案200件規模）で約15万〜40万トークン。附属書の再検証は1回あたり約30万〜50万トークンでした。並列にすると短時間で消費するので、区間数を絞って起動してください。
