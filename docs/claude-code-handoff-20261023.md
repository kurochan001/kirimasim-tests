# Claude Codeへのハンドオフ（2026-10-23）

> **現在の値（2026-10-25 更新）**
> 本文は20%到達時点（2026-10-23）の記録です。現在の正本は
> [`coverage/behavior-summary.json`](../coverage/behavior-summary.json) で、値は次のとおりです。
>
> - 要求対応：**10,853 / 12,319（88.10%）**、実行成功：**7,223（58.63%、Ghost含む）**
> - 未対応：1,466、解釈保留：21行、分母：未承認（`provisional`）
> - テスト：7,661本（対応登録済み5,233本、未登録2,428本）
> - 75%＝9,240要求まで、75%を**達成**（9,240以上）

## 最初に把握すること

この資料は、IEEE 1800-2023に対する既存テストの要求照合と動作カバレッジ管理の引き継ぎです。
20%到達時点の記録で、その後の50%到達作業と追加の照合は
[50%到達作業のハンドオフ](claude-code-handoff-20261023-50percent.md)にあります。
現在の値は上の枠と[`coverage/behavior-summary.json`](../coverage/behavior-summary.json)を正とし、
本文中の数値は各時点の履歴として読んでください。

10%到達分と20%到達分はその後コミット・push済みです（本資料も `a30cddb` で追加）。
作業ツリーを保持する必要はありません。

- 作業場所：このリポジトリのルート
- ブランチ：`main`
- 資料作成時のHEAD：`f9436fadc025540e5aedf113d5bee96a2b9b23e5`（`Match compiler directive tests to IEEE requirements`）
- origin：`https://github.com/kurochan001/kirimasim-tests.git`
- 日時の基準：Asia/Tokyo。以下の数値は資料作成時のローカル作業ツリーの値です。
- ユーザー指定の指示は`AGENTS.md`相当の`@RTK.md`です。現在のworkspaceには実ファイルがなく、
  `~/.claude/CLAUDE.md`の`@RTK.md`と、同ディレクトリの`RTK.md`を確認しました。
  RTKの通常コマンド書換えはClaude Codeのhookが担当する設定です。

## ユーザーの目的と完了範囲

ユーザーは当初、未コミット分だけでなく全テストをレビューし、問題をMarkdownへ残すことを希望しました。
その後、規格の全要求の洗い出し、既存テストとの照合、不足テストの追加、
規格全動作の網羅率の計測・管理を依頼しています。暫定値と確定値は併記する方針です。

全1,740節・15,846出典ブロックの資料調査・要求抽出は台帳上完了しています。
ただし要求の意味上の重複や解釈保留があり、分母は未承認です。
**資料確認100%は、動作テストの網羅率100%でも、全テストの意味上のレビュー完了でもありません。**
担当はCodex（AI）で、独立した人による承認とは扱っていません。

20%到達作業では既存テストの刺激・期待値を照合し、対応根拠と保留判断を登録しました。
SystemVerilog/Cテストの新規追加・入力変更・再実行は行わず、保存済みの実行証跡を照合しています。

## 20%到達時点の計測値（2026-10-23、履歴）

正本は[`coverage/behavior-summary.json`](../coverage/behavior-summary.json)です。
以下の数値は20%到達時点のもので、現在値は冒頭の枠を参照してください。

- 固定分母：12,319要求行。
- 対応済み：2,465要求。暫定設計網羅率 **20.009741050409936%**（通常表示20.01%）。
- 有効な成功証跡あり：1,292要求。暫定実行確認率 **10.487864274697621%**（通常表示10.49%）。
- 確定値：設計・実行とも`null`／未確定。`denominator_reviewed`は`false`。
- 全テスト：3,938本。少なくとも一つの対応あり1,386本、未登録2,552本。
- AND集合証拠：126要求。
- 保留判断台帳：406テスト・546判断。
- 解釈保留：49要求行・46 issue・42節。分母から除外していません。
- 計測規則：`metric_policy_version = 3`。

20%到達作業の開始値は1,242/12,319（10.081987%）、成功証跡754要求でした。
418本から1,296件の根拠を追加し、対応要求は1,223増加、成功証跡は538要求増加しています。
保留判断は42件追加しています。対応済みテスト本数は、ファイル全体のレビュー完了数ではありません。

分母SHA-256：
`d9e94724b317c8668673f4f4883c4923bf94caad46d79ba7c79e1fd16302e6ac`

資料索引SHA-256（summaryの`source_audit.source_index_sha256`）：
`15a9aed7738bec626841dbdf20c4c8da3488bbd80b07f0d0328b9492026f5eaa`

12,319を分母とすると、20%超過に必要なのは2,464要求です。
現在はそこから1要求上にあります。対応を取り下げる必要が判明したら、数値維持より正しい集計を優先してください。

## 読む順序と正本

1. [20%到達結果・M65–M97・最終監査](existing-test-matching-20percent-20261023.md)
2. [全体の集計概要](behavior-coverage-summary.md)
3. [既存テストの対応状況](test-requirement-matching.md)
4. [累積の問題・保留理由（M01以降）](existing-test-matching-review-20261022.md)
5. [10%到達時のVPI照合結果](existing-test-matching-vpi-20261023.md)
6. [計測規則と更新手順](../coverage/README.md)
7. [要求抽出の結果](requirement-extraction.md)と[解釈・抽出上の注意](requirement-extraction-notes.md)

台帳の役割は次のとおりです。

- `coverage/behaviors.json`：要求定義と承認した`checks`／`check_groups`。`checks: []`は未対応。
- `coverage/test-matching-reviews.json`：見送った対応の対象ID・理由・根拠・入力ハッシュ。
- `coverage/test-matching.json`：全テストの引用・対応済みID・未承認候補・保留判断を統合した生成物。
- `coverage/standard-sections.json`、`requirement-source-index.json`、`requirement-audit.json`：出典と抽出監査。
- `coverage/behavior-baseline.json`：要求・対応・AND集合等の後退を検出する基準。
- `coverage/behavior-history.json`：計測時点ごとの履歴。途中の値も履歴として残ります。
- `coverage/results/*.json`：全件実行と部分再実行の証跡。各実行回を分けて保持しています。
- `docs/behavior-coverage.md`：要求別の巨大な生成レポート。まず対象節を絞って読んでください。

## 規格資料

ユーザー提供資料はリポジトリの外にあります。

- ディレクトリ：リポジトリの隣の`IEEE_1800-2023_SystemVerilog`（`tools/requirement_source.py`は環境変数`IEEE1800_SOURCE`でも指定できます）
- PDF：`IEEE_Std_1800-2023_SystemVerilog.pdf`
- 抽出テキスト：`out/lrm_pdftotext_layout.txt`

出典の自身の本文を読むには、リポジトリルートで実行します。

```sh
python3 tools/requirement_source.py --show 6.20.4 6.21 11.5.1
python3 tools/behavior_coverage.py --candidates 11.5.1
```

必要ならリポジトリ外へ本文キャッシュを再生成できます。
PDFの図表は必要に応じて視覚確認してください。規格本文・PDF・本文キャッシュをGitへ追加しません。

```sh
python3 tools/requirement_source.py --cache /tmp/claude-requirement-source.json
```

## 当時の未コミットの変更（履歴）

ハンドオフ作成直前、以下の12 trackedファイルが変更されていました。
これらはその後にコミット・push済みです。

```text
README.md
coverage/behavior-baseline.json
coverage/behavior-history.json
coverage/behavior-summary.json
coverage/behaviors.json
coverage/test-matching-reviews.json
coverage/test-matching.json
docs/behavior-coverage-summary.md
docs/behavior-coverage.md
docs/existing-test-matching-review-20261022.md
docs/nightly-results.md
docs/test-requirement-matching.md
```

未追跡の資料は以下の2本で、このハンドオフを加えて3本です。

```text
docs/existing-test-matching-vpi-20261023.md
docs/existing-test-matching-20percent-20261023.md
docs/claude-code-handoff-20261023.md
```

HEADとの差分には、20%作業開始前からの10%到達分も含まれています。
開始時の変更を消すためにHEADからファイルを復元しないでください。
20%作業では、開始時の要求定義・既存checks/AND集合・保留判断・履歴を保持したことを照合しました。
`tests/`、`tools/`、`generators/`、`.github/`、規格索引・要求定義の変更はこの作業の対象外でした。

## 対応を登録するときの判断基準

1. 要求の`behavior`・`acceptance`・`source_spans`と、該当節の本文・図表を読む。
2. SV本体、VPI/DPIのC helper、include・入力データ、期待stdout／stderrまで読む。
3. 「この動作を誤実装したら期待出力が変わるか」を具体的な値・時刻・型・対象で確認する。
4. 同じテスト・要求に既存の保留判断がないか確認し、file全体の合法性・oracle問題も確認する。
5. 独立した複数条件の一部だけなら保留する。全条件を別テストで分担できる場合はAND集合にする。
6. 入力digest、刺激・期待結果の文字列anchor、観測内容、日付、担当を`checks`へ残す。

引用節やテスト名、APIが呼ばれた事実だけでは登録しません。
非NULLだけの対象関係、常に0でも通るcoverage、真になる入力しかないrelational operator、
別型へ代入したため元の戻り型を区別できない確認も、要求全体の証拠にはしません。

`check_groups`はグループ内AND・グループ間ORです。設定した要求では全checkをグループへ所属させます。
実行成功は同じシミュレータ・同じsnapshotでグループ全員が成功した場合だけで、別実行回の部分成功は合成しません。
単独で要求全体を満たすcheckを複数置く場合のORと、部分観測の寄せ集めを混同しないでください。

成功の計上は入力・runnerの鮮度が一致する`pass`のみです。
`known`、`unsupported`、`fail`、古い入力、古いrunnerは成功に含めません。
違法系の未対応構文エラーを、意図した規格違反の検出と読み替えないでください。

## 最終監査で取り下げた対応と再登録時の注意

20%到達直前の監査で、既存保留の理由が残る仮対応20件・16要求を取り下げました。
別の既存テストで20件・17要求を追加した最終値が2,465です。
途中集計の2,464を最終結果として扱わないでください。

- `ch6/test_string_putc`の6.16.2 `NO-RESIZE`：有効indexだけでは範囲外・zero書込みの無効果を確認しない。
- `ch6/test_string_getc_is_byte`の6.16.3 `SIGNATURE`：返値幅・符号は観測するが、index formalのint型は未確認。
- 7.12.2 `SORT`／`RSORT`：plain sortの全要素比較と、with sortの端点・先頭だけの比較では、projected keyで全要素が整列する証拠にならない（M38）。
- 8.7 `PROPERTY-INITIALIZATION`：new後のdefault値だけではconstructor body前の初期化時点を証明しない。
- 8.14 `VIRTUAL-OVERRIDE-DISPATCH`：virtual側だけでは非virtualのstatic bindingとの対照を確認しない（M33）。
- `ch26/test_std_package_access`：try_get成功を1に固定するoracle問題（M04）。このfile由来の新規対応5件は除外した。
- 37.29 `VIRTUAL-INITIALIZER`、37.30 `INTERFACE-TYPE-PARENT`：helperの`none`はNULL handleと非NULL handleのNULL nameを区別しない。
- 37.58 `VECTOR-USES`：kind別件数だけでは、誤った同kindの対象や重複を排除しない（M60）。
- `ch37/test_vpi_case_loop_force_stmts`の37.72 `DIAGRAM-002/003`：helperが別statementにも不適切なLhs queryを行う既存問題（M64）。
- `ch7/test_tagged_union_packed`：3-memberのtag符号化00/01/10の規格上の根拠が未解決（M84）。幅・配置を含めこのfileからの新規対応を見送った。

保留台帳との重複が残る13.3.1 `TASK-LOCAL-LIFETIME-OVERRIDE`は、
`ch13/test_task_static`のautomatic task内static localと、
`ch6/test_automatic_variable_in_static_subroutine`のstatic task内automatic localをANDで確認しています。
元テスト単独の不足を指摘したM16は保持しています。

最後のformat対応（21.2.1.1）は具体的な変換の観測です。大文字aliasを別途刺激したという主張ではありません。
要求行の粒度を今後厳密化する際は、alias・複合条件の扱いも再監査候補です。
機械検査の成功は意味上の妥当性を自動承認するものではありません。

## 続行する場合の候補と既知の不足

以下は探索開始点であり、対応承認ではありません。既に保留した理由を再度無視して登録しないでください。

- 6.20.2：aggregate parameterの型・member read、integral select、signed/rangeを含むtype推論。
  `ch6/test_param_value_2`、`test_parameters_edge_cases`、`test_parameter_override_types`等を本文・oracleから確認する。
- 6.20.4：port localparamとlocalparam keywordの継続、generate/package/class/unitでのlocal context。
  間接依存は`test_localparam_from_parameters`で登録済み。
- 6.21：automatic block/subroutine、static default、階層参照、forkとenclosing scopeのlifetime。
  `test_program_automatic_lifetime`、`test_vpi_lifetime_properties`、`test_static_initializer_runs_once`等が候補。
  明示automatic localは登録済み。
- 11.5.1：上向き宣言range、非0始まりのindex label、無効part-selectのreadとwrite両方、base式のself-determined評価。
  普通のdescending rangeや一部がxになるだけの比較で複合行全体を埋めない。
- 21章：I/O・format・scanの未対応行が残る。具体的な入力と文字列／byte／戻り値を比較するtestを優先する。
- 9.7：awaitは自己awaitのerrorまで含む行が未対応。resume/suspendの時点・状態別規則、killの子孫全体も不足。
- 20.15.5：既存q_examは主にcode 1/3で、code 2/4/5/6の証拠にはならない。
- 10.9のassignment pattern：既存のnamed field/defaultだけではtype keyの優先順位まで確認しない。
- 6.19.5.2：enumの3/1/6は非単調でもlast=最大値なので、lastを最大値で返す誤実装は区別しない（M95）。
- VPI：NULL検査、正しい対象の同一性・値、callbackと副作用の前後関係を確認する。count/typeだけの検査と区別する。

ユーザーが不足テストの追加を改めて指示した場合は、これらの保留理由を刺激・oracleの設計条件に使えます。
シミュレータが受理するだけで期待値を決めず、規格と独立した観測から導いてください。

## 更新・検証の再開手順

まず`git status --short`と正本の値を確認し、現在の未コミット状態を保存してから編集してください。
下記はリポジトリルートから実行します。

対応追加後の生成物更新：

```sh
python3 tools/behavior_coverage.py --update --require-source-reviewed
python3 tools/requirement_matching.py --update
```

要求・対応・調査完了の単純追加は`--update`がbaselineへ反映します。
正当な対応撤回・要求訂正でbaseline更新が必要なら、差分と規格根拠を記録して
`--write-baseline --reason '具体的な理由'`を使います。チェックを通す目的で古いbaselineへ戻しません。
履歴の既存部分は保持してください。

最後の20%到達状態で、以下の検査はすべて成功しました。

```sh
python3 -m unittest discover -s tools -p 'test_*.py'
python3 tools/behavior_coverage.py --check --require-source-reviewed \
  --verify-source ../IEEE_1800-2023_SystemVerilog
python3 tools/requirement_matching.py --check
python3 tools/suite_stats.py --check
python3 tools/suite_catalog.py --check
python3 tools/coverage_depth.py --check --minimum-tests 2
python3 generators/generate.py --check
python3 tools/lint_metadata.py
git diff --check
```

unit testは74件成功。metadata lintは3,938本、new problem 0、known 378です。
`--verify-source`にはPDFファイル単体ではなく資料ディレクトリを渡します。
`--require-complete`は現在未対応要求・分母未承認があるため、成功を要求する通常検査には使いません。
元のSV/C全件をこの引き継ぎのために再実行する必要はありません。

生成物に加え、README、最新結果資料、累積進捗、nightly-resultsのmain集計欄も更新対象です。
Nightlyの過去時点の記述を現在の値で書き換えないでください。
mainの保存済み結果と、resultsブランチへNightlyが出すその回の結果は別です。
このハンドオフではGitHubの最新実行状況を照会していません。

## 一時ファイルについて

元の作業環境には以下が残っていますが、引き継ぎに必須ではありません。
規格本文以外の正本はリポジトリ内に揃っています。

- `/tmp/kirimasim-twentypercent-start-20261023.json`：20%作業開始時の未コミット状態の比較用snapshot。
- `/tmp/kirimasim-twenty-final-audit.py`／`.json`：開始時との保存比較と最終計数。
- `/tmp/kirimasim-twenty-withdrawn-conflicts.json`：最終監査で取り下げた20仮対応。
- `/tmp/kirimasim-twenty-helper.py`等：このセッション限りの編集補助。登録済みbatchを再実行しない。

これらはGit未管理で消える可能性があります。final-auditは20%目標や当時のファイル集合を仮定する
セッション専用検査なので、将来の変更へそのまま適用しません。以後は新しい開始状態を記録してください。

## Claude Codeへ渡す開始メッセージ

```text
このリポジトリのルートで、
docs/claude-code-handoff-20261023.md と
docs/claude-code-handoff-20261023-50percent.md を読み、状況を把握してください。
現在は要求対応10,853/12,319（88.10%）、実行成功7,223（58.63%、Ghost含む。Ghostを除くIcarus/Verilator/formalのみでは6,163/50.03%）です。
75%（9,240要求）は達成済みです。
正本は coverage/behavior-summary.json、保留判断・AND集合証拠・資料の確認手順を引き継いでください。
次の具体的な作業指示は別途伝えます。
```
