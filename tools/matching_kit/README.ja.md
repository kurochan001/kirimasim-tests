<a id="matching-kit"></a>

# マッチングキット

[English](README.md) / [日本語](README.ja.md)

[PDFからテストまでの手順](../../docs/requirements-to-tests-method.md)で説明している提案・独立判定・統合により、IEEE 1800-2023の要求（`coverage/behaviors.json`）をテストへ対応付けるツールです。`merge.py`が受理済みの提案を適用するまで、リポジトリは読むだけです。提案・判定・メモは、リポジトリの外の作業ディレクトリに置きます。

|ファイル|何をするのか|
| --- | --- |
| `partition.py OUT_DIR` |未対応の要求を担当範囲のファイルに分割する。`p..`（引用するテストがあるもの。先に照合する）、`g..`、`a..`、`h..`（候補なし。既存のテストをさらに調べ、必要ならテストを追加する）|
| `propose.py` |読むための`scope`、`req`、`test`。提案用の`add`、`group`、`hold`（`behavior_coverage.validate()`の条件で直ちに検査する）。検証担当用の`show`、`verdict`、`testverdict`|
| `merge.py DIR --reviewer TEXT --date YYYY-MM-DD` |再検査した後、最新判定が`accept`の提案を適用する。冪等。`--dry-run`|
| `runsim.py tests/...` |Icarus Verilog 13.0とVerilator 5.052（シード1と73）でテストを実行し、どれが一致するかを報告して`:oracle:`を決定する。固定版を5.054へ移す間は、新しいテストに`--verilator`で5.054のビルドを渡す（[移行中の固定版](../../docs/simulator-differences.ja.md#verilator-5054-interim)）。|
| `withdrawn-20261023.json` |20%の照合の最終監査で取り下げた対応。`propose.py`はこれを拒否する|
| `lifted-holds-20261115.json` |2026-11-15に外した保留32件の記録。同じ日の台帳の変更で、保留の理由に挙げた「テストが観測していない部分」が要求から外れたもの（ツールは読まない）|
| `workflows/match.js` |Claude CodeのWorkflow：区分ごとに照合担当1名と検証担当1名|
| `workflows/gap.js` |Claude CodeのWorkflow：区分ごとに作成担当1名と検証担当1名。作成担当は新規テストを作成し、`combined`モードでは先に対応付けを行う。|
| `workflows/interpretation-review.js` |Claude CodeのWorkflow：分析担当が解釈保留事項の解決案を提案し、検証担当が反証を試みる|

<a id="work-directory"></a>

## ワークディレクトリ

```text
<work>/
  assign/<label>.json                 partition.py output
  proposals/<wave>/<label>.jsonl      proposals (one JSON object per line)
  proposals/<wave>/<label>.jsonl.verdicts.jsonl
  notes/<label>-tests.txt             new tests a writer made
  notes/<label>-testverdicts.jsonl    the verifier's ok/defective per new test
  notes/<label>-simdiff.md            simulator differences a writer found
```

<a id="proposal-records"></a>

## 提案記録

照合案（`propose.py add --out FILE`、JSONは標準入力から）：

```json
{"requirement_id": "SV2023-...", "test": "tests/chN/test_x.sv",
 "observation": "the stimulus and the values the expected output compares",
 "rationale": "which wrong implementation changes which output line, and how",
 "evidence": [{"file": "tests/chN/test_x.sv", "contains": "<the line that causes the condition>"},
              {"file": "tests/chN/test_x.expected", "contains": "<the output that shows the result>"}]}
```

error種別の要求には`:should_fail_because:`を持つテストが必要です。アンカーは期待出力ではなく、その`:expected_stderr_regex:`行を含むものを1つ指定します。group（`group`）は`group_id`、`collective_observation`、`rationale`、`members`を持ち、それぞれのテストに`observation`と`evidence`を記録します。hold（`hold`）は`test`、`requirement_ids`、`disposition`（`partial_observation`、`oracle_issue`、`citation_refinement`、`compound_requirement`）、`explanation`、`evidence`を持ちます。

<a id="workflows"></a>

## ワークフロー

これらのスクリプトは、Claude CodeのWorkflowツールの入力です。指示文は日本語で、レビューの基準を含みます。典型的な引数：

```js
{repo: "<repository root>", work: "<work directory>", pdf: "<the IEEE 1800-2023 PDF>",
 iverilogBin: "<Icarus Verilog 13.0>/bin",
 // match.js
 wave: "wave1", labels: ["p01-...", "p02-..."],
 // gap.js
 parts: [{label: "p01-...", wave: "wave1", mode: "gap" | "combined" | "annexA"}],
 verifyOnly: false, resume: false,
 // interpretation-review.js
 batches: [{label: "A", issues: ["ISSUE-NAME", ...]}]}
```

検証担当が終わったら統合し、手順書の9章に従って再生成・検査します。

どのスクリプトも`runsim.py`に`--verilator`を渡しません。`gap.js`の指示文は新しいテストに`verilator@5.052`を付けるよう書いているので、固定版を5.054へ移す間は、5.054のビルドで確かめて`verilator@5.054`を付けます（[移行中の固定版](../../docs/simulator-differences.ja.md#verilator-5054-interim)）。
