# OpenCode への引き継ぎ

[English](HANDOFF.md) / [日本語](HANDOFF.ja.md)

## 目標と現在地

IEEE 1800-2023 の要求台帳12,332件すべてに、原典に照らして妥当なテストを対応づけます。2026-11-25時点のテスト対応率は **98.98%（12,206／12,332件）** で、未対応は126件です。実行確認は全ツール合計11,192件で、うち公開ツールで再現できるものは6,455件です。最新値は集計JSONを確認してください。[集計JSON](coverage/behavior-summary.json) · [集計の読み方](docs/behavior-coverage-summary.md)

## 作業の再開

リポジトリのルートを OpenCode で開き、このファイルを参照させます。`git status --short --branch` と `git log -1 --oneline` でブランチと作業ツリーを確認します。

```sh
python3 - <<'PY'
import json
from pathlib import Path

ledger = json.loads(Path('coverage/behaviors.json').read_text())
for row in ledger['requirements']:
    if not row['checks']:
        print(row['id'], row['acceptance'])
PY
```

対象要件の `source_spans` から規格本文の節とブロックを特定し、手元の IEEE 1800-2023 本文と `tests/chNN/` を確認します。テスト追加後は該当ランナーで再実行し、入力のフィンガープリント、照合条件、実測差分を記録してから台帳に対応を追加します。規格が複数の結果を許す場合は、必要な事前条件や対照の成立を確認して観測を残します。[要求台帳](coverage/behaviors.json) · [原典索引](coverage/requirement-source-index.json) · [対応づけの手順](docs/requirements-to-tests-method.md)

## 検証コマンド

```sh
python3 tools/lint_metadata.py tests/chNN/test_example.sv
python3 tools/behavior_coverage.py --check --require-source-reviewed
python3 tools/requirement_matching.py --check
python3 tools/suite_catalog.py --check
python3 tools/suite_stats.py --check
python3 tools/coverage_depth.py --check --minimum-tests 2
python3 tools/documentation_languages.py --check
python3 -m unittest discover -s tools -p 'test_*.py'
```

テスト追加時は、対応する生成コマンドを `--update` で実行します。手書きの日英文書を更新した場合は `python3 tools/documentation_languages.py --record` で記録を更新します。Ghostの再実行にはアクセス可能な実行ファイルと strict プロファイルが必要です。公開ツールだけで再現できる範囲は各記録に記載しています。[検証記録と再実行手順](coverage/README.md) · [CIの定義](.github/workflows/check.yml)

## 直近の結果と未対応候補

- §4.3の参照スケジューラは、通常系と競合する書き込みを持つ2条件の全てで、Icarus、Ghost、Verilator、kirimasimの実測が許容トレースに一致しました。[検証記録](coverage/qualification/scheduler-reference-20261125.json)
- §11.4.14.1の循環クラスのストリーミングでは、Ghostで通常系が値 `35` を返し、自己参照を確認した別実行はシグナル11で終了しました。循環時の結果は規格上未定義です。[検証記録](coverage/qualification/class-stream-cycle-20261125.json)
- §36.12.3では、Verilog-1995の区画にあるメモリを旧互換VPIアプリケーションで読み取るケースを追加しました。IcarusとGhostで値 `29` と `61` を確認しました。[検証記録](coverage/qualification/vpi-legacy-partition-memory-20261125.json)
- 未対応が多いのは第34章の保護ディレクティブと、第37・38章のVPIです。§25.9の仮想インターフェイスは、Ghost strictの予備実行で `initial` とタスクのイベント制御が動作し、明示感度リストと連続代入は拒否されました。`always_comb` は受理されたため、台帳の受け入れ条件のうち暗黙の感度に関する検証が残っています。[条項別の対応状況](docs/behavior-coverage.md)
