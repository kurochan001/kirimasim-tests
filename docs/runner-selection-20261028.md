# シミュレーションランナーの選択と分類（2026-10-28）

Issue #13「Simulation runners run :type: formal tests」と Issue #14
「run_kirimasim.py checks no-expected-output before unsupported」の修正記録です。
対象はスイート `b83d0ffd`（7,740本）です。

## 1. 変更内容

- `run_kirimasim.py`、`run_icarus.py`、`run_verilator.py`、`run_lyra.py` の
  既定のテスト選択から `:type: formal` を除外しました。テストを明示した場合も
  除外します。formal テストは `:formal_case:` を持ち、`tools/run_sby.py` だけが
  実行します。`:type: elaboration` は従来どおりシミュレーションで実行します。
- `run_kirimasim.py` は `error: unsupported:` を「期待値なし」より先に判定します。
  期待値が他のシミュレータ専用（例: `:expected_stdout_verilator:` だけ）の場合は
  `known`（既知不一致）とし、失敗にも一致にも数えません。
- `run_ghost.py`、`run_sby.py`、`suite_results.py` は変更していません。

## 2. 再分類される件数

| 分類 | 件数 |
|---|---:|
| シミュレーション対象から外れる formal テスト | 268 |
| 期待値なしのまま `unsupported` になるテスト | 16 |
| 他シミュレータ専用の期待値を持つ `known` テスト | 2 |

2026-10-28 の kirimasim 実行では fail 462 本でした。このうち 286 本が
`no :expected_stdout:` で、内訳は 268 formal、16 unsupported、2 テスト整備です。
修正後は、この 286 本がシミュレーションの失敗から外れます。残る fail 176 本のうち
テスト側の 40 本は `docs/test-failure-triage-20261028.md` に記録しています。

## 3. 実行証跡の扱い

`tools/suite_results.py` の `runner_digest()` は `run_<simulator>.py` を
ハッシュに含めるため、ランナーのファイルを変更すると保存済みの実行証跡が
stale になります。今回の Icarus/Verilator の変更は `main()` のテスト選択だけで、
`run()` の判定処理（出力比較、規格違反のコードの判定、終了コード、診断）は変えていません。

そこで、`coverage/behavior-summary.json` が採用している Icarus/Verilator の
37 スナップショットについて、`runner_sha256` だけを新しい値へ更新しました。
状態、`inputs_sha256`、シミュレータの版、実行時刻は変更していません。

- Ghost: 実行ファイルのハッシュが変わらないため、証跡をそのまま採用します。
- SymbiYosys: `run_sby.py` と `suite_results.py` を変更していないため、証跡をそのまま採用します。
- kirimasim / Lyra: 公式の実行証跡には採用中のスナップショットがありません。

## 4. 再現・検証

```sh
python3 -m unittest discover -s tools -p 'test_*.py'
python3 -m unittest discover -s tools -p 'test_runner_selection.py'
python3 tools/behavior_coverage.py --check --require-source-reviewed
python3 tools/requirement_matching.py --check
python3 tools/suite_stats.py --check
python3 tools/suite_catalog.py --check
python3 tools/coverage_depth.py --check --minimum-tests 2
python3 generators/generate.py --check
python3 tools/lint_metadata.py
git diff --check
```
