<a id="ieee-1800-2023-requirement-coverage-aggregation"></a>

# IEEE 1800-2023 要求カバレッジ集計

[English](behavior-coverage-summary.en.md) / [日本語](behavior-coverage-summary.md)

[全項目の詳細](behavior-coverage.md) / [管理手順](../coverage/README.md) / [解釈・再検討記録](requirement-extraction-notes.md)

割合の分母は要求台帳の行で、テスト本数ではありません。[設計・実行・PASSの違い](faq.md#q16-how-do-design-and-execution-coverage-differ)を具体例で確認できます。

<a id="value-for-all-standards-in-the-required-table"></a>

## 全規格の要求台帳に対する値

- 要求カバレッジ（テスト設計）: **93.12%** (11483/12332)。
- Ghostを除く実行確認率: **51.22%** (6317/12332)。第三者が再現できるIcarus Verilog・Verilator・SymbiYosysの成功の和集合。うちシミュレータで確認した要求は6027行、formalだけで確認した要求は290行です。
- 実行確認率: **88.20%** (10877/12332)。複数環境の成功の和集合。うちシミュレータで確認した要求は10587行、formalだけで確認した要求は290行です。
- 分母には解釈保留と未対応も含みます。未実装・未対応を除外していません。
- 登録単位は要求の出現箇所・条件・観測ケースであり、分母のレビューで意味の重複を統合しています。 全プログラム・全入力の組み合わせを試した割合や、単一シミュレータの規格適合率ではありません。

<a id="aggregation-of-existing-tests"></a>

## 既存テストの集計状況

- 全 16340 本のうち、要求との対応を登録済みのテストは 6703 本。未登録は 9637 本です。
- 上記の網羅率は、刺激と期待結果を確認して要求との対応を登録した分だけを計上しています。 未登録の既存テストも検証に役立ちますが、その貢献はまだ割合に反映できていません。
- 登録済み本数は少なくとも一つの要求との対応がある本数で、テスト全体のレビュー完了数ではありません。

- 複数テストで分担する要求は 771 行。各グループの全テストが同じ実行回で成功した場合だけ、要求全体の実行成功に数えます。

<a id="definite-value"></a>

## 確定値

- 要求カバレッジ（テスト設計）: 93.12%。
- 規格要求の実行確認率: Ghostを除いて 51.22%、Ghostとkirimasimを含めて 88.20%。
- 分母の承認: 承認済み。計測状態: `confirmed`。
- 資料確認、保留解釈の解決、要求単位の重複整理、分母のレビューを経て確定しました。

<a id="remains"></a>

## 残件

- 現行入力に対応するパス結果の記録あり: 10877 行。
- 対応済み・パス結果の記録なし: 606 行。
- テスト対応未確認（解釈保留以外）: 849 行。
- 解釈保留: 0 行。

未対応は、既存テストが存在しないという判定ではありません。

<a id="execution-confirmation-rate-by-simulator"></a>

## シミュレータ別の実行確認率

各行は独立した保存実行です。小範囲の実行で未実行が多い場合もあるため、[日時・版・対象範囲の読み方](faq.md#q14-why-do-main-results-or-simulator-totals-differ)と計測元を確認してください。

- `icarus` / `Icarus Verilog version 13.0 (stable) (v13_0)`: 0/12332 (0.00%)。 計測元: `2026-11-19T00:40:23.690825+00:00` / `arithmetic-context-20261119e-icarus13.json`。 失敗 0、既知不一致 0、未対応 0、未実行 11483、古い証跡 0、規格違反テストの判定根拠が未承認 0 行。
- `kirimasim` / `kirimasim 0.1.1 (commit 441dddbd0fcd), built with AppleClang 21.0.0.21000401`: 0/12332 (0.00%)。 計測元: `2026-11-19T00:40:25.094367+00:00` / `arithmetic-context-20261119e-kirimasim-441dddbd0fcd-run1.json`。 失敗 0、既知不一致 0、未対応 0、未実行 11483、古い証跡 0、規格違反テストの判定根拠が未承認 0 行。
- `kirimasim` / `kirimasim 0.1.1 (commit 441dddbd0fcd), built with AppleClang 21.0.0.21000401`: 0/12332 (0.00%)。 計測元: `2026-11-19T00:40:26.453598+00:00` / `arithmetic-context-20261119e-kirimasim-441dddbd0fcd-run2.json`。 失敗 0、既知不一致 0、未対応 0、未実行 11483、古い証跡 0、規格違反テストの判定根拠が未承認 0 行。
- `kirimasim` / `kirimasim 0.1.1 (commit 441dddbd0fcd), built with AppleClang 21.0.0.21000401`: 0/12332 (0.00%)。 計測元: `2026-11-19T00:40:27.799007+00:00` / `arithmetic-context-20261119e-kirimasim-441dddbd0fcd-run3.json`。 失敗 0、既知不一致 0、未対応 0、未実行 11483、古い証跡 0、規格違反テストの判定根拠が未承認 0 行。
- `kirimasim` / `kirimasim 0.1.1 (commit 441dddbd0fcd), built with AppleClang 21.0.0.21000401`: 0/12332 (0.00%)。 計測元: `2026-11-19T00:40:29.114615+00:00` / `arithmetic-context-20261119e-kirimasim-441dddbd0fcd-run4.json`。 失敗 0、既知不一致 0、未対応 0、未実行 11483、古い証跡 0、規格違反テストの判定根拠が未承認 0 行。
- `verilator` / `Verilator 5.054 2026-11-01 rev vUNKNOWN-built20261101`: 0/12332 (0.00%)。 計測元: `2026-11-19T00:45:48.677131+00:00` / `arithmetic-context-20261119e-verilator5.054-seed1.json`。 失敗 0、既知不一致 0、未対応 0、未実行 11483、古い証跡 0、規格違反テストの判定根拠が未承認 0 行。
- `verilator` / `Verilator 5.054 2026-11-01 rev vUNKNOWN-built20261101`: 0/12332 (0.00%)。 計測元: `2026-11-19T00:50:43.545843+00:00` / `arithmetic-context-20261119e-verilator5.054-seed73.json`。 失敗 0、既知不一致 0、未対応 0、未実行 11483、古い証跡 0、規格違反テストの判定根拠が未承認 0 行。
- `icarus` / `Icarus Verilog version 13.0 (stable) (v13_0)`: 0/12332 (0.00%)。 計測元: `2026-11-18T21:42:00.646435+00:00` / `array-shape-20261119-icarus13.json`。 失敗 0、既知不一致 0、未対応 0、未実行 11483、古い証跡 0、規格違反テストの判定根拠が未承認 0 行。
- `kirimasim` / `kirimasim 0.1.1 (commit 441dddbd0fcd), built with AppleClang 21.0.0.21000401`: 0/12332 (0.00%)。 計測元: `2026-11-18T21:42:02.346874+00:00` / `array-shape-20261119-kirimasim-441dddbd0fcd-run1.json`。 失敗 0、既知不一致 0、未対応 0、未実行 11483、古い証跡 0、規格違反テストの判定根拠が未承認 0 行。
- `kirimasim` / `kirimasim 0.1.1 (commit 441dddbd0fcd), built with AppleClang 21.0.0.21000401`: 0/12332 (0.00%)。 計測元: `2026-11-18T21:42:03.990893+00:00` / `array-shape-20261119-kirimasim-441dddbd0fcd-run2.json`。 失敗 0、既知不一致 0、未対応 0、未実行 11483、古い証跡 0、規格違反テストの判定根拠が未承認 0 行。
- `kirimasim` / `kirimasim 0.1.1 (commit 441dddbd0fcd), built with AppleClang 21.0.0.21000401`: 0/12332 (0.00%)。 計測元: `2026-11-18T21:42:05.571990+00:00` / `array-shape-20261119-kirimasim-441dddbd0fcd-run3.json`。 失敗 0、既知不一致 0、未対応 0、未実行 11483、古い証跡 0、規格違反テストの判定根拠が未承認 0 行。
- `kirimasim` / `kirimasim 0.1.1 (commit 441dddbd0fcd), built with AppleClang 21.0.0.21000401`: 0/12332 (0.00%)。 計測元: `2026-11-18T21:42:07.154047+00:00` / `array-shape-20261119-kirimasim-441dddbd0fcd-run4.json`。 失敗 0、既知不一致 0、未対応 0、未実行 11483、古い証跡 0、規格違反テストの判定根拠が未承認 0 行。
- `verilator` / `Verilator 5.054 2026-11-01 rev vUNKNOWN-built20261101`: 0/12332 (0.00%)。 計測元: `2026-11-18T21:46:58.671082+00:00` / `array-shape-20261119-verilator5.054-seed1.json`。 失敗 0、既知不一致 0、未対応 0、未実行 11483、古い証跡 0、規格違反テストの判定根拠が未承認 0 行。
- `verilator` / `Verilator 5.054 2026-11-01 rev vUNKNOWN-built20261101`: 0/12332 (0.00%)。 計測元: `2026-11-18T21:52:06.760512+00:00` / `array-shape-20261119-verilator5.054-seed73.json`。 失敗 0、既知不一致 0、未対応 0、未実行 11483、古い証跡 0、規格違反テストの判定根拠が未承認 0 行。
- `icarus` / `Icarus Verilog version 13.0 (stable) (v13_0)`: 0/12332 (0.00%)。 計測元: `2026-11-15T05:50:28.045416+00:00` / `arrayfunc-20261115-icarus13.json`。 失敗 0、既知不一致 1、未対応 0、未実行 11482、古い証跡 0、規格違反テストの判定根拠が未承認 0 行。
- `kirimasim` / `kirimasim 0.0.0 (commit d1d8a1782d0a), built with AppleClang 21.0.0.21000401`: 0/12332 (0.00%)。 計測元: `2026-11-15T05:50:46.736634+00:00` / `arrayfunc-20261115-kirimasim-d1d8a178.json`。 失敗 0、既知不一致 0、未対応 1、未実行 11482、古い証跡 0、規格違反テストの判定根拠が未承認 0 行。
- `verilator` / `Verilator 5.054 2026-11-01 rev vUNKNOWN-built20261101`: 0/12332 (0.00%)。 計測元: `2026-11-15T05:50:40.662343+00:00` / `arrayfunc-20261115-verilator5.054-seed1.json`。 失敗 0、既知不一致 1、未対応 0、未実行 11482、古い証跡 0、規格違反テストの判定根拠が未承認 0 行。
- `verilator` / `Verilator 5.054 2026-11-01 rev vUNKNOWN-built20261101`: 0/12332 (0.00%)。 計測元: `2026-11-15T05:50:46.247835+00:00` / `arrayfunc-20261115-verilator5.054-seed73.json`。 失敗 0、既知不一致 1、未対応 0、未実行 11482、古い証跡 0、規格違反テストの判定根拠が未承認 0 行。
- `icarus` / `Icarus Verilog version 13.0 (stable) (v13_0)`: 0/12332 (0.00%)。 計測元: `2026-11-15T11:47:32.730294+00:00` / `arrayrefs-20261115-icarus13.json`。 失敗 0、既知不一致 0、未対応 0、未実行 11483、古い証跡 0、規格違反テストの判定根拠が未承認 0 行。
- `kirimasim` / `kirimasim 0.0.0 (commit d1d8a1782d0a), built with AppleClang 21.0.0.21000401`: 0/12332 (0.00%)。 計測元: `2026-11-15T11:48:10.984505+00:00` / `arrayrefs-20261115-kirimasim-d1d8a178.json`。 失敗 0、既知不一致 0、未対応 0、未実行 11483、古い証跡 0、規格違反テストの判定根拠が未承認 0 行。
- `verilator` / `Verilator 5.054 2026-11-01 rev vUNKNOWN-built20261101`: 0/12332 (0.00%)。 計測元: `2026-11-15T11:47:57.157440+00:00` / `arrayrefs-20261115-verilator5.054-seed1.json`。 失敗 0、既知不一致 0、未対応 0、未実行 11483、古い証跡 0、規格違反テストの判定根拠が未承認 0 行。
- `verilator` / `Verilator 5.054 2026-11-01 rev vUNKNOWN-built20261101`: 0/12332 (0.00%)。 計測元: `2026-11-15T11:48:07.884883+00:00` / `arrayrefs-20261115-verilator5.054-seed73.json`。 失敗 0、既知不一致 0、未対応 0、未実行 11483、古い証跡 0、規格違反テストの判定根拠が未承認 0 行。
- `icarus` / `Icarus Verilog version 13.0 (stable) (v13_0)`: 0/12332 (0.00%)。 計測元: `2026-11-18T16:18:16.466764+00:00` / `bitquery-20261119-icarus13.json`。 失敗 0、既知不一致 0、未対応 0、未実行 11483、古い証跡 0、規格違反テストの判定根拠が未承認 0 行。
- `kirimasim` / `kirimasim 0.1.1 (commit 441dddbd0fcd), built with AppleClang 21.0.0.21000401`: 0/12332 (0.00%)。 計測元: `2026-11-18T16:18:17.457959+00:00` / `bitquery-20261119-kirimasim-441dddbd0fcd.json`。 失敗 0、既知不一致 0、未対応 0、未実行 11483、古い証跡 0、規格違反テストの判定根拠が未承認 0 行。
- `verilator` / `Verilator 5.054 2026-11-01 rev vUNKNOWN-built20261101`: 0/12332 (0.00%)。 計測元: `2026-11-18T16:21:24.078961+00:00` / `bitquery-20261119-verilator5.054-seed1.json`。 失敗 0、既知不一致 0、未対応 0、未実行 11483、古い証跡 0、規格違反テストの判定根拠が未承認 0 行。
- `verilator` / `Verilator 5.054 2026-11-01 rev vUNKNOWN-built20261101`: 0/12332 (0.00%)。 計測元: `2026-11-18T16:23:50.600845+00:00` / `bitquery-20261119-verilator5.054-seed73.json`。 失敗 0、既知不一致 0、未対応 0、未実行 11483、古い証跡 0、規格違反テストの判定根拠が未承認 0 行。
- `icarus` / `Icarus Verilog version 13.0 (stable) (v13_0)`: 17/12332 (0.14%)。 計測元: `2026-11-14T23:56:33.360931+00:00` / `c2tests-20261115-icarus13.json`。 失敗 0、既知不一致 33、未対応 0、未実行 11422、古い証跡 0、規格違反テストの判定根拠が未承認 11 行。
- `kirimasim` / `kirimasim 0.0.0 (commit d1d8a1782d0a), built with AppleClang 21.0.0.21000401`: 19/12332 (0.15%)。 計測元: `2026-11-14T23:59:09.029234+00:00` / `c2tests-20261115-kirimasim-d1d8a178.json`。 失敗 3、既知不一致 0、未対応 17、未実行 11416、古い証跡 0、規格違反テストの判定根拠が未承認 28 行。
- `verilator` / `Verilator 5.054 2026-11-01 rev vUNKNOWN-built20261101`: 28/12332 (0.23%)。 計測元: `2026-11-14T23:57:51.528183+00:00` / `c2tests-20261115-verilator5.054-seed1.json`。 失敗 0、既知不一致 31、未対応 0、未実行 11417、古い証跡 0、規格違反テストの判定根拠が未承認 7 行。
- `verilator` / `Verilator 5.054 2026-11-01 rev vUNKNOWN-built20261101`: 28/12332 (0.23%)。 計測元: `2026-11-14T23:59:08.170486+00:00` / `c2tests-20261115-verilator5.054-seed73.json`。 失敗 0、既知不一致 31、未対応 0、未実行 11417、古い証跡 0、規格違反テストの判定根拠が未承認 7 行。
- `icarus` / `Icarus Verilog version 13.0 (stable) (v13_0)`: 0/12332 (0.00%)。 計測元: `2026-11-15T00:39:28.918241+00:00` / `ch19-tables-20261115-icarus13.json`。 失敗 0、既知不一致 2、未対応 0、未実行 11464、古い証跡 0、規格違反テストの判定根拠が未承認 17 行。
- `kirimasim` / `kirimasim 0.0.0 (commit d1d8a1782d0a), built with AppleClang 21.0.0.21000401`: 0/12332 (0.00%)。 計測元: `2026-11-15T00:40:59.725559+00:00` / `ch19-tables-20261115-kirimasim-d1d8a178.json`。 失敗 0、既知不一致 0、未対応 1、未実行 11464、古い証跡 0、規格違反テストの判定根拠が未承認 18 行。
- `verilator` / `Verilator 5.054 2026-11-01 rev vUNKNOWN-built20261101`: 1/12332 (0.01%)。 計測元: `2026-11-15T00:40:18.641708+00:00` / `ch19-tables-20261115-verilator5.054-seed1.json`。 失敗 0、既知不一致 18、未対応 0、未実行 11464、古い証跡 0、規格違反テストの判定根拠が未承認 0 行。
- `verilator` / `Verilator 5.054 2026-11-01 rev vUNKNOWN-built20261101`: 1/12332 (0.01%)。 計測元: `2026-11-15T00:40:59.498597+00:00` / `ch19-tables-20261115-verilator5.054-seed73.json`。 失敗 0、既知不一致 18、未対応 0、未実行 11464、古い証跡 0、規格違反テストの判定根拠が未承認 0 行。
- `icarus` / `Icarus Verilog version 13.0 (stable) (v13_0)`: 0/12332 (0.00%)。 計測元: `2026-11-19T03:40:42.398698+00:00` / `constant-power-20261119n-icarus13.json`。 失敗 0、既知不一致 0、未対応 0、未実行 11483、古い証跡 0、規格違反テストの判定根拠が未承認 0 行。
- `kirimasim` / `kirimasim 0.1.1 (commit a6222f0656d4), built with AppleClang 21.0.0.21000401`: 0/12332 (0.00%)。 計測元: `2026-11-19T03:40:42.654456+00:00` / `constant-power-20261119n-kirimasim-a6222f0656d4-run1.json`。 失敗 0、既知不一致 0、未対応 0、未実行 11483、古い証跡 0、規格違反テストの判定根拠が未承認 0 行。
- `kirimasim` / `kirimasim 0.1.1 (commit a6222f0656d4), built with AppleClang 21.0.0.21000401`: 0/12332 (0.00%)。 計測元: `2026-11-19T03:40:42.949106+00:00` / `constant-power-20261119n-kirimasim-a6222f0656d4-run2.json`。 失敗 0、既知不一致 0、未対応 0、未実行 11483、古い証跡 0、規格違反テストの判定根拠が未承認 0 行。
- `kirimasim` / `kirimasim 0.1.1 (commit a6222f0656d4), built with AppleClang 21.0.0.21000401`: 0/12332 (0.00%)。 計測元: `2026-11-19T03:40:43.275173+00:00` / `constant-power-20261119n-kirimasim-a6222f0656d4-run3.json`。 失敗 0、既知不一致 0、未対応 0、未実行 11483、古い証跡 0、規格違反テストの判定根拠が未承認 0 行。
- `kirimasim` / `kirimasim 0.1.1 (commit a6222f0656d4), built with AppleClang 21.0.0.21000401`: 0/12332 (0.00%)。 計測元: `2026-11-19T03:40:43.557806+00:00` / `constant-power-20261119n-kirimasim-a6222f0656d4-run4.json`。 失敗 0、既知不一致 0、未対応 0、未実行 11483、古い証跡 0、規格違反テストの判定根拠が未承認 0 行。
- `verilator` / `Verilator 5.054 2026-11-01 rev vUNKNOWN-built20261101`: 0/12332 (0.00%)。 計測元: `2026-11-19T03:41:20.257356+00:00` / `constant-power-20261119n-verilator5.054-seed1.json`。 失敗 0、既知不一致 0、未対応 0、未実行 11483、古い証跡 0、規格違反テストの判定根拠が未承認 0 行。
- `verilator` / `Verilator 5.054 2026-11-01 rev vUNKNOWN-built20261101`: 0/12332 (0.00%)。 計測元: `2026-11-19T03:41:53.991039+00:00` / `constant-power-20261119n-verilator5.054-seed73.json`。 失敗 0、既知不一致 0、未対応 0、未実行 11483、古い証跡 0、規格違反テストの判定根拠が未承認 0 行。
- `icarus` / `Icarus Verilog version 13.0 (stable) (v13_0)`: 0/12332 (0.00%)。 計測元: `2026-11-15T07:46:36.421684+00:00` / `constcall-20261115-icarus13.json`。 失敗 0、既知不一致 0、未対応 0、未実行 11483、古い証跡 0、規格違反テストの判定根拠が未承認 0 行。
- `kirimasim` / `kirimasim 0.0.0 (commit d1d8a1782d0a), built with AppleClang 21.0.0.21000401`: 0/12332 (0.00%)。 計測元: `2026-11-15T07:46:53.963163+00:00` / `constcall-20261115-kirimasim-d1d8a178.json`。 失敗 0、既知不一致 0、未対応 0、未実行 11483、古い証跡 0、規格違反テストの判定根拠が未承認 0 行。
- `verilator` / `Verilator 5.054 2026-11-01 rev vUNKNOWN-built20261101`: 0/12332 (0.00%)。 計測元: `2026-11-15T07:46:45.505234+00:00` / `constcall-20261115-verilator5.054-seed1.json`。 失敗 0、既知不一致 0、未対応 0、未実行 11483、古い証跡 0、規格違反テストの判定根拠が未承認 0 行。
- `verilator` / `Verilator 5.054 2026-11-01 rev vUNKNOWN-built20261101`: 0/12332 (0.00%)。 計測元: `2026-11-15T07:46:53.247659+00:00` / `constcall-20261115-verilator5.054-seed73.json`。 失敗 0、既知不一致 0、未対応 0、未実行 11483、古い証跡 0、規格違反テストの判定根拠が未承認 0 行。
- `icarus` / `Icarus Verilog version 13.0 (stable) (v13_0)`: 0/12332 (0.00%)。 計測元: `2026-11-18T23:42:55.291969+00:00` / `division-boundaries-20261119c-icarus13.json`。 失敗 0、既知不一致 0、未対応 0、未実行 11483、古い証跡 0、規格違反テストの判定根拠が未承認 0 行。
- `kirimasim` / `kirimasim 0.1.1 (commit 441dddbd0fcd), built with AppleClang 21.0.0.21000401`: 0/12332 (0.00%)。 計測元: `2026-11-18T23:42:56.026640+00:00` / `division-boundaries-20261119c-kirimasim-441dddbd0fcd-run1.json`。 失敗 0、既知不一致 0、未対応 0、未実行 11483、古い証跡 0、規格違反テストの判定根拠が未承認 0 行。
- `kirimasim` / `kirimasim 0.1.1 (commit 441dddbd0fcd), built with AppleClang 21.0.0.21000401`: 0/12332 (0.00%)。 計測元: `2026-11-18T23:42:56.768990+00:00` / `division-boundaries-20261119c-kirimasim-441dddbd0fcd-run2.json`。 失敗 0、既知不一致 0、未対応 0、未実行 11483、古い証跡 0、規格違反テストの判定根拠が未承認 0 行。
- `kirimasim` / `kirimasim 0.1.1 (commit 441dddbd0fcd), built with AppleClang 21.0.0.21000401`: 0/12332 (0.00%)。 計測元: `2026-11-18T23:42:57.507237+00:00` / `division-boundaries-20261119c-kirimasim-441dddbd0fcd-run3.json`。 失敗 0、既知不一致 0、未対応 0、未実行 11483、古い証跡 0、規格違反テストの判定根拠が未承認 0 行。
- `kirimasim` / `kirimasim 0.1.1 (commit 441dddbd0fcd), built with AppleClang 21.0.0.21000401`: 0/12332 (0.00%)。 計測元: `2026-11-18T23:42:58.242286+00:00` / `division-boundaries-20261119c-kirimasim-441dddbd0fcd-run4.json`。 失敗 0、既知不一致 0、未対応 0、未実行 11483、古い証跡 0、規格違反テストの判定根拠が未承認 0 行。
- `verilator` / `Verilator 5.054 2026-11-01 rev vUNKNOWN-built20261101`: 0/12332 (0.00%)。 計測元: `2026-11-18T23:45:30.445544+00:00` / `division-boundaries-20261119c-verilator5.054-seed1.json`。 失敗 0、既知不一致 0、未対応 0、未実行 11483、古い証跡 0、規格違反テストの判定根拠が未承認 0 行。
- `verilator` / `Verilator 5.054 2026-11-01 rev vUNKNOWN-built20261101`: 0/12332 (0.00%)。 計測元: `2026-11-18T23:47:58.657268+00:00` / `division-boundaries-20261119c-verilator5.054-seed73.json`。 失敗 0、既知不一致 0、未対応 0、未実行 11483、古い証跡 0、規格違反テストの判定根拠が未承認 0 行。
- `kirimasim` / `kirimasim 0.1.1 (commit a6222f0656d4), built with AppleClang 21.0.0.21000401`: 0/12332 (0.00%)。 計測元: `2026-11-19T07:57:54.833200+00:00` / `early-fixed-a622-recheck-20261119ab-run1.json`。 失敗 0、既知不一致 0、未対応 0、未実行 11483、古い証跡 0、規格違反テストの判定根拠が未承認 0 行。
- `kirimasim` / `kirimasim 0.1.1 (commit a6222f0656d4), built with AppleClang 21.0.0.21000401`: 0/12332 (0.00%)。 計測元: `2026-11-19T07:58:01.693697+00:00` / `early-fixed-a622-recheck-20261119ab-run2.json`。 失敗 0、既知不一致 0、未対応 0、未実行 11483、古い証跡 0、規格違反テストの判定根拠が未承認 0 行。
- `kirimasim` / `kirimasim 0.1.1 (commit a6222f0656d4), built with AppleClang 21.0.0.21000401`: 0/12332 (0.00%)。 計測元: `2026-11-19T07:58:08.612448+00:00` / `early-fixed-a622-recheck-20261119ab-run3.json`。 失敗 0、既知不一致 0、未対応 0、未実行 11483、古い証跡 0、規格違反テストの判定根拠が未承認 0 行。
- `kirimasim` / `kirimasim 0.1.1 (commit a6222f0656d4), built with AppleClang 21.0.0.21000401`: 0/12332 (0.00%)。 計測元: `2026-11-19T07:58:15.548142+00:00` / `early-fixed-a622-recheck-20261119ab-run4.json`。 失敗 0、既知不一致 0、未対応 0、未実行 11483、古い証跡 0、規格違反テストの判定根拠が未承認 0 行。
- `sby` / `unknown SBY version`: 290/12332 (2.35%)。 計測元: `2026-10-27T13:59:10.011684+00:00` / `formal-20261027-sby.json`。 失敗 0、既知不一致 0、未対応 0、未実行 11193、古い証跡 0、規格違反テストの判定根拠が未承認 0 行。
- `icarus` / `Icarus Verilog version 13.0 (stable) (v13_0)`: 0/12332 (0.00%)。 計測元: `2026-11-19T00:24:25.210824+00:00` / `fourstate-boundaries-20261119d-icarus13.json`。 失敗 0、既知不一致 0、未対応 0、未実行 11483、古い証跡 0、規格違反テストの判定根拠が未承認 0 行。
- `kirimasim` / `kirimasim 0.1.1 (commit 441dddbd0fcd), built with AppleClang 21.0.0.21000401`: 0/12332 (0.00%)。 計測元: `2026-11-19T00:24:25.819476+00:00` / `fourstate-boundaries-20261119d-kirimasim-441dddbd0fcd-run1.json`。 失敗 0、既知不一致 0、未対応 0、未実行 11483、古い証跡 0、規格違反テストの判定根拠が未承認 0 行。
- `kirimasim` / `kirimasim 0.1.1 (commit 441dddbd0fcd), built with AppleClang 21.0.0.21000401`: 0/12332 (0.00%)。 計測元: `2026-11-19T00:24:26.412445+00:00` / `fourstate-boundaries-20261119d-kirimasim-441dddbd0fcd-run2.json`。 失敗 0、既知不一致 0、未対応 0、未実行 11483、古い証跡 0、規格違反テストの判定根拠が未承認 0 行。
- `kirimasim` / `kirimasim 0.1.1 (commit 441dddbd0fcd), built with AppleClang 21.0.0.21000401`: 0/12332 (0.00%)。 計測元: `2026-11-19T00:24:27.012478+00:00` / `fourstate-boundaries-20261119d-kirimasim-441dddbd0fcd-run3.json`。 失敗 0、既知不一致 0、未対応 0、未実行 11483、古い証跡 0、規格違反テストの判定根拠が未承認 0 行。
- `kirimasim` / `kirimasim 0.1.1 (commit 441dddbd0fcd), built with AppleClang 21.0.0.21000401`: 0/12332 (0.00%)。 計測元: `2026-11-19T00:24:27.618699+00:00` / `fourstate-boundaries-20261119d-kirimasim-441dddbd0fcd-run4.json`。 失敗 0、既知不一致 0、未対応 0、未実行 11483、古い証跡 0、規格違反テストの判定根拠が未承認 0 行。
- `verilator` / `Verilator 5.054 2026-11-01 rev vUNKNOWN-built20261101`: 0/12332 (0.00%)。 計測元: `2026-11-19T00:26:22.013552+00:00` / `fourstate-boundaries-20261119d-verilator5.054-seed1.json`。 失敗 0、既知不一致 0、未対応 0、未実行 11483、古い証跡 0、規格違反テストの判定根拠が未承認 0 行。
- `verilator` / `Verilator 5.054 2026-11-01 rev vUNKNOWN-built20261101`: 0/12332 (0.00%)。 計測元: `2026-11-19T00:28:09.101257+00:00` / `fourstate-boundaries-20261119d-verilator5.054-seed73.json`。 失敗 0、既知不一致 0、未対応 0、未実行 11483、古い証跡 0、規格違反テストの判定根拠が未承認 0 行。
- `icarus` / `Icarus Verilog version 13.0 (stable) (v13_0)`: 3092/12332 (25.07%)。 計測元: `2026-11-11T16:51:00.391888+00:00` / `full-20261112-icarus13.json`。 失敗 0、既知不一致 7336、未対応 0、未実行 636、古い証跡 236、規格違反テストの判定根拠が未承認 183 行。
- `kirimasim` / `kirimasim 0.0.0 (commit 7de185f776a1), built with AppleClang 21.0.0.21000401`: 2997/12332 (24.30%)。 計測元: `2026-11-11T16:52:28.478656+00:00` / `full-20261112-kirimasim-7de185f7.json`。 失敗 172、既知不一致 0、未対応 6262、未実行 626、古い証跡 234、規格違反テストの判定根拠が未承認 1192 行。
- `verilator` / `Verilator 5.052 2026-09-05 rev vUNKNOWN-built20260905`: 3886/12332 (31.51%)。 計測元: `2026-11-11T17:39:23.398627+00:00` / `full-20261112-verilator5.052-seed1.json`。 失敗 0、既知不一致 6084、未対応 0、未実行 629、古い証跡 257、規格違反テストの判定根拠が未承認 627 行。
- `verilator` / `Verilator 5.052 2026-09-05 rev vUNKNOWN-built20260905`: 3597/12332 (29.17%)。 計測元: `2026-11-11T17:00:30.807783+00:00` / `full-20261112-verilator5.052-seed73.json`。 失敗 0、既知不一致 0、未対応 0、未実行 7862、古い証跡 24、規格違反テストの判定根拠が未承認 0 行。
- `ghost` / `private build d2e03e4a44d3`: 9676/12332 (78.46%)。 計測元: `2026-11-23T06:50:50.367123+00:00` / `ghost-local-20261123-strict-timeout180.json`。 失敗 0、既知不一致 0、未対応 0、未実行 290、古い証跡 0、規格違反テストの判定根拠が未承認 1517 行。
- `icarus` / `Icarus Verilog version 13.0 (stable) (v13_0)`: 1/12332 (0.01%)。 計測元: `2026-11-14T10:26:34.150974+00:00` / `intcompat-20261114-icarus13.json`。 失敗 0、既知不一致 0、未対応 0、未実行 11482、古い証跡 0、規格違反テストの判定根拠が未承認 0 行。
- `kirimasim` / `kirimasim 0.0.0 (commit d1d8a1782d0a), built with AppleClang 21.0.0.21000401`: 1/12332 (0.01%)。 計測元: `2026-11-14T10:26:46.168015+00:00` / `intcompat-20261114-kirimasim-d1d8a178.json`。 失敗 0、既知不一致 0、未対応 0、未実行 11482、古い証跡 0、規格違反テストの判定根拠が未承認 0 行。
- `verilator` / `Verilator 5.054 2026-11-01 rev vUNKNOWN-built20261101`: 0/12332 (0.00%)。 計測元: `2026-11-14T10:26:39.847047+00:00` / `intcompat-20261114-verilator5.054-seed1.json`。 失敗 0、既知不一致 1、未対応 0、未実行 11482、古い証跡 0、規格違反テストの判定根拠が未承認 0 行。
- `verilator` / `Verilator 5.054 2026-11-01 rev vUNKNOWN-built20261101`: 0/12332 (0.00%)。 計測元: `2026-11-14T10:26:46.053076+00:00` / `intcompat-20261114-verilator5.054-seed73.json`。 失敗 0、既知不一致 1、未対応 0、未実行 11482、古い証跡 0、規格違反テストの判定根拠が未承認 0 行。
- `icarus` / `Icarus Verilog version 13.0 (stable) (v13_0)`: 150/12332 (1.22%)。 計測元: `2026-11-15T02:46:05.877247+00:00` / `keywords-inherited-20261115-icarus13.json`。 失敗 0、既知不一致 0、未対応 0、未実行 11333、古い証跡 0、規格違反テストの判定根拠が未承認 0 行。
- `kirimasim` / `kirimasim 0.0.0 (commit d1d8a1782d0a), built with AppleClang 21.0.0.21000401`: 0/12332 (0.00%)。 計測元: `2026-11-15T02:46:56.224616+00:00` / `keywords-inherited-20261115-kirimasim-d1d8a178.json`。 失敗 0、既知不一致 0、未対応 0、未実行 11333、古い証跡 0、規格違反テストの判定根拠が未承認 150 行。
- `verilator` / `Verilator 5.054 2026-11-01 rev vUNKNOWN-built20261101`: 1/12332 (0.01%)。 計測元: `2026-11-15T02:46:27.050750+00:00` / `keywords-inherited-20261115-verilator5.054-seed1.json`。 失敗 0、既知不一致 3、未対応 0、未実行 11333、古い証跡 0、規格違反テストの判定根拠が未承認 146 行。
- `verilator` / `Verilator 5.054 2026-11-01 rev vUNKNOWN-built20261101`: 1/12332 (0.01%)。 計測元: `2026-11-15T02:46:49.835333+00:00` / `keywords-inherited-20261115-verilator5.054-seed73.json`。 失敗 0、既知不一致 3、未対応 0、未実行 11333、古い証跡 0、規格違反テストの判定根拠が未承認 146 行。
- `icarus` / `Icarus Verilog version 13.0 (stable) (v13_0)`: 0/12332 (0.00%)。 計測元: `2026-11-19T02:39:43.830642+00:00` / `memory-file-boundaries-20261119k-icarus13.json`。 失敗 0、既知不一致 0、未対応 0、未実行 11483、古い証跡 0、規格違反テストの判定根拠が未承認 0 行。
- `kirimasim` / `kirimasim 0.1.1 (commit a6222f0656d4), built with AppleClang 21.0.0.21000401`: 0/12332 (0.00%)。 計測元: `2026-11-19T02:39:45.516267+00:00` / `memory-file-boundaries-20261119k-kirimasim-a6222f0656d4-run1.json`。 失敗 0、既知不一致 0、未対応 0、未実行 11483、古い証跡 0、規格違反テストの判定根拠が未承認 0 行。
- `kirimasim` / `kirimasim 0.1.1 (commit a6222f0656d4), built with AppleClang 21.0.0.21000401`: 0/12332 (0.00%)。 計測元: `2026-11-19T02:39:47.250370+00:00` / `memory-file-boundaries-20261119k-kirimasim-a6222f0656d4-run2.json`。 失敗 0、既知不一致 0、未対応 0、未実行 11483、古い証跡 0、規格違反テストの判定根拠が未承認 0 行。
- `kirimasim` / `kirimasim 0.1.1 (commit a6222f0656d4), built with AppleClang 21.0.0.21000401`: 0/12332 (0.00%)。 計測元: `2026-11-19T02:39:48.976818+00:00` / `memory-file-boundaries-20261119k-kirimasim-a6222f0656d4-run3.json`。 失敗 0、既知不一致 0、未対応 0、未実行 11483、古い証跡 0、規格違反テストの判定根拠が未承認 0 行。
- `kirimasim` / `kirimasim 0.1.1 (commit a6222f0656d4), built with AppleClang 21.0.0.21000401`: 0/12332 (0.00%)。 計測元: `2026-11-19T02:39:50.878398+00:00` / `memory-file-boundaries-20261119k-kirimasim-a6222f0656d4-run4.json`。 失敗 0、既知不一致 0、未対応 0、未実行 11483、古い証跡 0、規格違反テストの判定根拠が未承認 0 行。
- `verilator` / `Verilator 5.054 2026-11-01 rev vUNKNOWN-built20261101`: 0/12332 (0.00%)。 計測元: `2026-11-19T02:43:12.104689+00:00` / `memory-file-boundaries-20261119k-verilator5.054-seed1.json`。 失敗 0、既知不一致 0、未対応 0、未実行 11483、古い証跡 0、規格違反テストの判定根拠が未承認 0 行。
- `verilator` / `Verilator 5.054 2026-11-01 rev vUNKNOWN-built20261101`: 0/12332 (0.00%)。 計測元: `2026-11-19T02:46:26.386745+00:00` / `memory-file-boundaries-20261119k-verilator5.054-seed73.json`。 失敗 0、既知不一致 0、未対応 0、未実行 11483、古い証跡 0、規格違反テストの判定根拠が未承認 0 行。
- `icarus` / `Icarus Verilog version 13.0 (stable) (v13_0)`: 0/12332 (0.00%)。 計測元: `2026-11-19T01:44:38.151064+00:00` / `nba-boundaries-20261119h-icarus13.json`。 失敗 0、既知不一致 0、未対応 0、未実行 11483、古い証跡 0、規格違反テストの判定根拠が未承認 0 行。
- `kirimasim` / `kirimasim 0.1.1 (commit 441dddbd0fcd), built with AppleClang 21.0.0.21000401`: 0/12332 (0.00%)。 計測元: `2026-11-19T01:44:40.043357+00:00` / `nba-boundaries-20261119h-kirimasim-441dddbd0fcd-run1.json`。 失敗 0、既知不一致 0、未対応 0、未実行 11483、古い証跡 0、規格違反テストの判定根拠が未承認 0 行。
- `kirimasim` / `kirimasim 0.1.1 (commit 441dddbd0fcd), built with AppleClang 21.0.0.21000401`: 0/12332 (0.00%)。 計測元: `2026-11-19T01:44:41.969708+00:00` / `nba-boundaries-20261119h-kirimasim-441dddbd0fcd-run2.json`。 失敗 0、既知不一致 0、未対応 0、未実行 11483、古い証跡 0、規格違反テストの判定根拠が未承認 0 行。
- `kirimasim` / `kirimasim 0.1.1 (commit 441dddbd0fcd), built with AppleClang 21.0.0.21000401`: 0/12332 (0.00%)。 計測元: `2026-11-19T01:44:43.909627+00:00` / `nba-boundaries-20261119h-kirimasim-441dddbd0fcd-run3.json`。 失敗 0、既知不一致 0、未対応 0、未実行 11483、古い証跡 0、規格違反テストの判定根拠が未承認 0 行。
- `kirimasim` / `kirimasim 0.1.1 (commit 441dddbd0fcd), built with AppleClang 21.0.0.21000401`: 0/12332 (0.00%)。 計測元: `2026-11-19T01:44:45.882463+00:00` / `nba-boundaries-20261119h-kirimasim-441dddbd0fcd-run4.json`。 失敗 0、既知不一致 0、未対応 0、未実行 11483、古い証跡 0、規格違反テストの判定根拠が未承認 0 行。
- `verilator` / `Verilator 5.054 2026-11-01 rev vUNKNOWN-built20261101`: 0/12332 (0.00%)。 計測元: `2026-11-19T01:54:49.097034+00:00` / `nba-boundaries-20261119h-verilator5.054-seed1.json`。 失敗 0、既知不一致 0、未対応 0、未実行 11483、古い証跡 0、規格違反テストの判定根拠が未承認 0 行。
- `verilator` / `Verilator 5.054 2026-11-01 rev vUNKNOWN-built20261101`: 0/12332 (0.00%)。 計測元: `2026-11-19T02:03:25.500540+00:00` / `nba-boundaries-20261119h-verilator5.054-seed73.json`。 失敗 0、既知不一致 0、未対応 0、未実行 11483、古い証跡 0、規格違反テストの判定根拠が未承認 0 行。
- `icarus` / `Icarus Verilog version 13.0 (stable) (v13_0)`: 0/12332 (0.00%)。 計測元: `2026-11-19T03:05:52.617864+00:00` / `negative-power-controls-20261119l-icarus13.json`。 失敗 0、既知不一致 0、未対応 0、未実行 11483、古い証跡 0、規格違反テストの判定根拠が未承認 0 行。
- `kirimasim` / `kirimasim 0.1.1 (commit a6222f0656d4), built with AppleClang 21.0.0.21000401`: 0/12332 (0.00%)。 計測元: `2026-11-19T03:05:52.842153+00:00` / `negative-power-controls-20261119l-kirimasim-a6222f0656d4-run1.json`。 失敗 0、既知不一致 0、未対応 0、未実行 11483、古い証跡 0、規格違反テストの判定根拠が未承認 0 行。
- `kirimasim` / `kirimasim 0.1.1 (commit a6222f0656d4), built with AppleClang 21.0.0.21000401`: 0/12332 (0.00%)。 計測元: `2026-11-19T03:05:53.066297+00:00` / `negative-power-controls-20261119l-kirimasim-a6222f0656d4-run2.json`。 失敗 0、既知不一致 0、未対応 0、未実行 11483、古い証跡 0、規格違反テストの判定根拠が未承認 0 行。
- `kirimasim` / `kirimasim 0.1.1 (commit a6222f0656d4), built with AppleClang 21.0.0.21000401`: 0/12332 (0.00%)。 計測元: `2026-11-19T03:05:53.302353+00:00` / `negative-power-controls-20261119l-kirimasim-a6222f0656d4-run3.json`。 失敗 0、既知不一致 0、未対応 0、未実行 11483、古い証跡 0、規格違反テストの判定根拠が未承認 0 行。
- `kirimasim` / `kirimasim 0.1.1 (commit a6222f0656d4), built with AppleClang 21.0.0.21000401`: 0/12332 (0.00%)。 計測元: `2026-11-19T03:05:53.539075+00:00` / `negative-power-controls-20261119l-kirimasim-a6222f0656d4-run4.json`。 失敗 0、既知不一致 0、未対応 0、未実行 11483、古い証跡 0、規格違反テストの判定根拠が未承認 0 行。
- `verilator` / `Verilator 5.054 2026-11-01 rev vUNKNOWN-built20261101`: 0/12332 (0.00%)。 計測元: `2026-11-19T03:06:28.618019+00:00` / `negative-power-controls-20261119l-verilator5.054-seed1.json`。 失敗 0、既知不一致 0、未対応 0、未実行 11483、古い証跡 0、規格違反テストの判定根拠が未承認 0 行。
- `verilator` / `Verilator 5.054 2026-11-01 rev vUNKNOWN-built20261101`: 0/12332 (0.00%)。 計測元: `2026-11-19T03:07:00.773137+00:00` / `negative-power-controls-20261119l-verilator5.054-seed73.json`。 失敗 0、既知不一致 0、未対応 0、未実行 11483、古い証跡 0、規格違反テストの判定根拠が未承認 0 行。
- `icarus` / `Icarus Verilog version 13.0 (stable) (v13_0)`: 0/12332 (0.00%)。 計測元: `2026-11-11T22:25:00.780016+00:00` / `oracle-tokens-2-20261112-icarus13.json`。 失敗 0、既知不一致 3、未対応 0、未実行 11474、古い証跡 0、規格違反テストの判定根拠が未承認 6 行。
- `kirimasim` / `kirimasim 0.0.0 (commit 7de185f776a1), built with AppleClang 21.0.0.21000401`: 0/12332 (0.00%)。 計測元: `2026-11-11T22:25:00.894678+00:00` / `oracle-tokens-2-20261112-kirimasim-7de185f7.json`。 失敗 0、既知不一致 0、未対応 1、未実行 11474、古い証跡 0、規格違反テストの判定根拠が未承認 8 行。
- `verilator` / `Verilator 5.052 2026-09-05 rev vUNKNOWN-built20260905`: 2/12332 (0.02%)。 計測元: `2026-11-11T22:25:01.564353+00:00` / `oracle-tokens-2-20261112-verilator5.052-seed1.json`。 失敗 0、既知不一致 3、未対応 0、未実行 11474、古い証跡 0、規格違反テストの判定根拠が未承認 4 行。
- `verilator` / `Verilator 5.052 2026-09-05 rev vUNKNOWN-built20260905`: 2/12332 (0.02%)。 計測元: `2026-11-11T22:25:02.208022+00:00` / `oracle-tokens-2-20261112-verilator5.052-seed73.json`。 失敗 0、既知不一致 3、未対応 0、未実行 11474、古い証跡 0、規格違反テストの判定根拠が未承認 4 行。
- `icarus` / `Icarus Verilog version 13.0 (stable) (v13_0)`: 4/12332 (0.03%)。 計測元: `2026-11-11T19:14:33.552454+00:00` / `oracle-tokens-20261112-icarus13.json`。 失敗 0、既知不一致 31、未対応 0、未実行 11291、古い証跡 7、規格違反テストの判定根拠が未承認 150 行。
- `kirimasim` / `kirimasim 0.0.0 (commit 7de185f776a1), built with AppleClang 21.0.0.21000401`: 0/12332 (0.00%)。 計測元: `2026-11-11T19:14:36.020025+00:00` / `oracle-tokens-20261112-kirimasim-7de185f7.json`。 失敗 8、既知不一致 0、未対応 26、未実行 11291、古い証跡 7、規格違反テストの判定根拠が未承認 151 行。
- `verilator` / `Verilator 5.052 2026-09-05 rev vUNKNOWN-built20260905`: 0/12332 (0.00%)。 計測元: `2026-11-11T19:15:04.286693+00:00` / `oracle-tokens-20261112-verilator5.052-seed1.json`。 失敗 0、既知不一致 113、未対応 0、未実行 11291、古い証跡 7、規格違反テストの判定根拠が未承認 72 行。
- `verilator` / `Verilator 5.052 2026-09-05 rev vUNKNOWN-built20260905`: 0/12332 (0.00%)。 計測元: `2026-11-11T19:15:22.924843+00:00` / `oracle-tokens-20261112-verilator5.052-seed73.json`。 失敗 0、既知不一致 113、未対応 0、未実行 11291、古い証跡 7、規格違反テストの判定根拠が未承認 72 行。
- `icarus` / `Icarus Verilog version 13.0 (stable) (v13_0)`: 1/12332 (0.01%)。 計測元: `2026-11-11T23:13:00.161260+00:00` / `oracle-tokens-3-20261112-icarus13.json`。 失敗 0、既知不一致 3、未対応 0、未実行 11475、古い証跡 0、規格違反テストの判定根拠が未承認 4 行。
- `kirimasim` / `kirimasim 0.0.0 (commit 7de185f776a1), built with AppleClang 21.0.0.21000401`: 0/12332 (0.00%)。 計測元: `2026-11-11T23:13:04.014714+00:00` / `oracle-tokens-3-20261112-kirimasim-7de185f7.json`。 失敗 0、既知不一致 0、未対応 0、未実行 11475、古い証跡 0、規格違反テストの判定根拠が未承認 8 行。
- `verilator` / `Verilator 5.052 2026-09-05 rev vUNKNOWN-built20260905`: 1/12332 (0.01%)。 計測元: `2026-11-11T23:13:01.978891+00:00` / `oracle-tokens-3-20261112-verilator5.052-seed1.json`。 失敗 0、既知不一致 1、未対応 0、未実行 11475、古い証跡 0、規格違反テストの判定根拠が未承認 6 行。
- `verilator` / `Verilator 5.052 2026-09-05 rev vUNKNOWN-built20260905`: 1/12332 (0.01%)。 計測元: `2026-11-11T23:13:03.804411+00:00` / `oracle-tokens-3-20261112-verilator5.052-seed73.json`。 失敗 0、既知不一致 1、未対応 0、未実行 11475、古い証跡 0、規格違反テストの判定根拠が未承認 6 行。
- `icarus` / `Icarus Verilog version 13.0 (stable) (v13_0)`: 0/12332 (0.00%)。 計測元: `2026-11-18T23:25:07.469975+00:00` / `packed-lanes-20261119b-icarus13.json`。 失敗 0、既知不一致 0、未対応 0、未実行 11483、古い証跡 0、規格違反テストの判定根拠が未承認 0 行。
- `kirimasim` / `kirimasim 0.1.1 (commit 441dddbd0fcd), built with AppleClang 21.0.0.21000401`: 0/12332 (0.00%)。 計測元: `2026-11-18T23:25:09.791478+00:00` / `packed-lanes-20261119b-kirimasim-441dddbd0fcd-run1.json`。 失敗 0、既知不一致 0、未対応 0、未実行 11483、古い証跡 0、規格違反テストの判定根拠が未承認 0 行。
- `kirimasim` / `kirimasim 0.1.1 (commit 441dddbd0fcd), built with AppleClang 21.0.0.21000401`: 0/12332 (0.00%)。 計測元: `2026-11-18T23:25:12.082997+00:00` / `packed-lanes-20261119b-kirimasim-441dddbd0fcd-run2.json`。 失敗 0、既知不一致 0、未対応 0、未実行 11483、古い証跡 0、規格違反テストの判定根拠が未承認 0 行。
- `kirimasim` / `kirimasim 0.1.1 (commit 441dddbd0fcd), built with AppleClang 21.0.0.21000401`: 0/12332 (0.00%)。 計測元: `2026-11-18T23:25:14.379637+00:00` / `packed-lanes-20261119b-kirimasim-441dddbd0fcd-run3.json`。 失敗 0、既知不一致 0、未対応 0、未実行 11483、古い証跡 0、規格違反テストの判定根拠が未承認 0 行。
- `kirimasim` / `kirimasim 0.1.1 (commit 441dddbd0fcd), built with AppleClang 21.0.0.21000401`: 0/12332 (0.00%)。 計測元: `2026-11-18T23:25:16.713955+00:00` / `packed-lanes-20261119b-kirimasim-441dddbd0fcd-run4.json`。 失敗 0、既知不一致 0、未対応 0、未実行 11483、古い証跡 0、規格違反テストの判定根拠が未承認 0 行。
- `verilator` / `Verilator 5.054 2026-11-01 rev vUNKNOWN-built20261101`: 0/12332 (0.00%)。 計測元: `2026-11-18T23:32:13.976957+00:00` / `packed-lanes-20261119b-verilator5.054-seed1.json`。 失敗 0、既知不一致 0、未対応 0、未実行 11483、古い証跡 0、規格違反テストの判定根拠が未承認 0 行。
- `verilator` / `Verilator 5.054 2026-11-01 rev vUNKNOWN-built20261101`: 0/12332 (0.00%)。 計測元: `2026-11-18T23:38:58.439443+00:00` / `packed-lanes-20261119b-verilator5.054-seed73.json`。 失敗 0、既知不一致 0、未対応 0、未実行 11483、古い証跡 0、規格違反テストの判定根拠が未承認 0 行。
- `kirimasim` / `kirimasim 0.1.1 (commit a6222f0656d4), built with AppleClang 21.0.0.21000401`: 0/12332 (0.00%)。 計測元: `2026-11-19T05:40:48.376240+00:00` / `packed-lanes-a622-recheck-20261119w-run1.json`。 失敗 0、既知不一致 0、未対応 0、未実行 11483、古い証跡 0、規格違反テストの判定根拠が未承認 0 行。
- `kirimasim` / `kirimasim 0.1.1 (commit a6222f0656d4), built with AppleClang 21.0.0.21000401`: 0/12332 (0.00%)。 計測元: `2026-11-19T05:40:50.520349+00:00` / `packed-lanes-a622-recheck-20261119w-run2.json`。 失敗 0、既知不一致 0、未対応 0、未実行 11483、古い証跡 0、規格違反テストの判定根拠が未承認 0 行。
- `kirimasim` / `kirimasim 0.1.1 (commit a6222f0656d4), built with AppleClang 21.0.0.21000401`: 0/12332 (0.00%)。 計測元: `2026-11-19T05:40:52.695049+00:00` / `packed-lanes-a622-recheck-20261119w-run3.json`。 失敗 0、既知不一致 0、未対応 0、未実行 11483、古い証跡 0、規格違反テストの判定根拠が未承認 0 行。
- `kirimasim` / `kirimasim 0.1.1 (commit a6222f0656d4), built with AppleClang 21.0.0.21000401`: 0/12332 (0.00%)。 計測元: `2026-11-19T05:40:54.862373+00:00` / `packed-lanes-a622-recheck-20261119w-run4.json`。 失敗 0、既知不一致 0、未対応 0、未実行 11483、古い証跡 0、規格違反テストの判定根拠が未承認 0 行。
- `icarus` / `Icarus Verilog version 13.0 (stable) (v13_0)`: 0/12332 (0.00%)。 計測元: `2026-11-19T06:26:59.765398+00:00` / `packed-read-controls-20261119w-icarus13.json`。 失敗 0、既知不一致 0、未対応 0、未実行 11483、古い証跡 0、規格違反テストの判定根拠が未承認 0 行。
- `kirimasim` / `kirimasim 0.1.1 (commit a6222f0656d4), built with AppleClang 21.0.0.21000401`: 0/12332 (0.00%)。 計測元: `2026-11-19T06:27:00.811236+00:00` / `packed-read-controls-20261119w-kirimasim-a6222f0656d4-run1.json`。 失敗 0、既知不一致 0、未対応 0、未実行 11483、古い証跡 0、規格違反テストの判定根拠が未承認 0 行。
- `kirimasim` / `kirimasim 0.1.1 (commit a6222f0656d4), built with AppleClang 21.0.0.21000401`: 0/12332 (0.00%)。 計測元: `2026-11-19T06:27:01.857170+00:00` / `packed-read-controls-20261119w-kirimasim-a6222f0656d4-run2.json`。 失敗 0、既知不一致 0、未対応 0、未実行 11483、古い証跡 0、規格違反テストの判定根拠が未承認 0 行。
- `kirimasim` / `kirimasim 0.1.1 (commit a6222f0656d4), built with AppleClang 21.0.0.21000401`: 0/12332 (0.00%)。 計測元: `2026-11-19T06:27:02.894197+00:00` / `packed-read-controls-20261119w-kirimasim-a6222f0656d4-run3.json`。 失敗 0、既知不一致 0、未対応 0、未実行 11483、古い証跡 0、規格違反テストの判定根拠が未承認 0 行。
- `kirimasim` / `kirimasim 0.1.1 (commit a6222f0656d4), built with AppleClang 21.0.0.21000401`: 0/12332 (0.00%)。 計測元: `2026-11-19T06:27:03.938723+00:00` / `packed-read-controls-20261119w-kirimasim-a6222f0656d4-run4.json`。 失敗 0、既知不一致 0、未対応 0、未実行 11483、古い証跡 0、規格違反テストの判定根拠が未承認 0 行。
- `verilator` / `Verilator 5.054 2026-11-01 rev vUNKNOWN-built20261101`: 0/12332 (0.00%)。 計測元: `2026-11-19T06:30:24.144918+00:00` / `packed-read-controls-20261119w-verilator5.054-seed1.json`。 失敗 0、既知不一致 0、未対応 0、未実行 11483、古い証跡 0、規格違反テストの判定根拠が未承認 0 行。
- `verilator` / `Verilator 5.054 2026-11-01 rev vUNKNOWN-built20261101`: 0/12332 (0.00%)。 計測元: `2026-11-19T06:33:32.423404+00:00` / `packed-read-controls-20261119w-verilator5.054-seed73.json`。 失敗 0、既知不一致 0、未対応 0、未実行 11483、古い証跡 0、規格違反テストの判定根拠が未承認 0 行。
- `icarus` / `Icarus Verilog version 13.0 (stable) (v13_0)`: 0/12332 (0.00%)。 計測元: `2026-11-19T01:05:47.851676+00:00` / `power-boundaries-20261119f-icarus13.json`。 失敗 0、既知不一致 0、未対応 0、未実行 11483、古い証跡 0、規格違反テストの判定根拠が未承認 0 行。
- `kirimasim` / `kirimasim 0.1.1 (commit 441dddbd0fcd), built with AppleClang 21.0.0.21000401`: 0/12332 (0.00%)。 計測元: `2026-11-19T01:05:48.765507+00:00` / `power-boundaries-20261119f-kirimasim-441dddbd0fcd-run1.json`。 失敗 0、既知不一致 0、未対応 0、未実行 11483、古い証跡 0、規格違反テストの判定根拠が未承認 0 行。
- `kirimasim` / `kirimasim 0.1.1 (commit 441dddbd0fcd), built with AppleClang 21.0.0.21000401`: 0/12332 (0.00%)。 計測元: `2026-11-19T01:05:49.677617+00:00` / `power-boundaries-20261119f-kirimasim-441dddbd0fcd-run2.json`。 失敗 0、既知不一致 0、未対応 0、未実行 11483、古い証跡 0、規格違反テストの判定根拠が未承認 0 行。
- `kirimasim` / `kirimasim 0.1.1 (commit 441dddbd0fcd), built with AppleClang 21.0.0.21000401`: 0/12332 (0.00%)。 計測元: `2026-11-19T01:05:50.568809+00:00` / `power-boundaries-20261119f-kirimasim-441dddbd0fcd-run3.json`。 失敗 0、既知不一致 0、未対応 0、未実行 11483、古い証跡 0、規格違反テストの判定根拠が未承認 0 行。
- `kirimasim` / `kirimasim 0.1.1 (commit 441dddbd0fcd), built with AppleClang 21.0.0.21000401`: 0/12332 (0.00%)。 計測元: `2026-11-19T01:05:51.483978+00:00` / `power-boundaries-20261119f-kirimasim-441dddbd0fcd-run4.json`。 失敗 0、既知不一致 0、未対応 0、未実行 11483、古い証跡 0、規格違反テストの判定根拠が未承認 0 行。
- `verilator` / `Verilator 5.054 2026-11-01 rev vUNKNOWN-built20261101`: 0/12332 (0.00%)。 計測元: `2026-11-19T01:09:59.513731+00:00` / `power-boundaries-20261119f-verilator5.054-seed1.json`。 失敗 0、既知不一致 0、未対応 0、未実行 11483、古い証跡 0、規格違反テストの判定根拠が未承認 0 行。
- `verilator` / `Verilator 5.054 2026-11-01 rev vUNKNOWN-built20261101`: 0/12332 (0.00%)。 計測元: `2026-11-19T01:13:51.962818+00:00` / `power-boundaries-20261119f-verilator5.054-seed73.json`。 失敗 0、既知不一致 0、未対応 0、未実行 11483、古い証跡 0、規格違反テストの判定根拠が未承認 0 行。
- `icarus` / `Icarus Verilog version 13.0 (stable) (v13_0)`: 1/12332 (0.01%)。 計測元: `2026-11-15T03:51:52.714029+00:00` / `primitives-20261115-icarus13.json`。 失敗 0、既知不一致 0、未対応 0、未実行 11482、古い証跡 0、規格違反テストの判定根拠が未承認 0 行。
- `kirimasim` / `kirimasim 0.0.0 (commit d1d8a1782d0a), built with AppleClang 21.0.0.21000401`: 1/12332 (0.01%)。 計測元: `2026-11-15T03:52:07.416509+00:00` / `primitives-20261115-kirimasim-d1d8a178.json`。 失敗 0、既知不一致 0、未対応 0、未実行 11482、古い証跡 0、規格違反テストの判定根拠が未承認 0 行。
- `verilator` / `Verilator 5.054 2026-11-01 rev vUNKNOWN-built20261101`: 0/12332 (0.00%)。 計測元: `2026-11-15T03:51:59.846146+00:00` / `primitives-20261115-verilator5.054-seed1.json`。 失敗 0、既知不一致 1、未対応 0、未実行 11482、古い証跡 0、規格違反テストの判定根拠が未承認 0 行。
- `verilator` / `Verilator 5.054 2026-11-01 rev vUNKNOWN-built20261101`: 0/12332 (0.00%)。 計測元: `2026-11-15T03:52:06.790486+00:00` / `primitives-20261115-verilator5.054-seed73.json`。 失敗 0、既知不一致 1、未対応 0、未実行 11482、古い証跡 0、規格違反テストの判定根拠が未承認 0 行。
- `ghost` / `private build e6870e43e28e`: 1/12332 (0.01%)。 計測元: `2026-11-23T09:01:38.681987+00:00` / `product-constraints-20261123-ghost-strict.json`。 失敗 0、既知不一致 0、未対応 0、未実行 11482、古い証跡 0、規格違反テストの判定根拠が未承認 0 行。
- `icarus` / `Icarus Verilog version 13.0 (stable) (v13_0)`: 0/12332 (0.00%)。 計測元: `2026-11-23T09:01:32.204965+00:00` / `product-constraints-20261123-icarus13.json`。 失敗 0、既知不一致 1、未対応 0、未実行 11482、古い証跡 0、規格違反テストの判定根拠が未承認 0 行。
- `kirimasim` / `kirimasim 0.2.0 (commit f60e41d0ba78), built with AppleClang 21.0.0.21000334`: 0/12332 (0.00%)。 計測元: `2026-11-23T09:02:12.068000+00:00` / `product-constraints-20261123-kirimasim.json`。 失敗 0、既知不一致 0、未対応 1、未実行 11482、古い証跡 0、規格違反テストの判定根拠が未承認 0 行。
- `verilator` / `Verilator 5.054 2026-11-01 rev vUNKNOWN-built20261101`: 1/12332 (0.01%)。 計測元: `2026-11-23T09:01:35.013573+00:00` / `product-constraints-20261123-verilator5.054-seed1.json`。 失敗 0、既知不一致 0、未対応 0、未実行 11482、古い証跡 0、規格違反テストの判定根拠が未承認 0 行。
- `verilator` / `Verilator 5.054 2026-11-01 rev vUNKNOWN-built20261101`: 1/12332 (0.01%)。 計測元: `2026-11-23T09:01:35.012041+00:00` / `product-constraints-20261123-verilator5.054-seed73.json`。 失敗 0、既知不一致 0、未対応 0、未実行 11482、古い証跡 0、規格違反テストの判定根拠が未承認 0 行。
- `icarus` / `Icarus Verilog version 13.0 (stable) (v13_0)`: 4/12332 (0.03%)。 計測元: `2026-11-14T02:14:23.703451+00:00` / `reqgap-20261114-icarus13.json`。 失敗 0、既知不一致 25、未対応 0、未実行 11451、古い証跡 1、規格違反テストの判定根拠が未承認 2 行。
- `kirimasim` / `kirimasim 0.0.0 (commit 77c27531437c), built with AppleClang 21.0.0.21000401`: 14/12332 (0.11%)。 計測元: `2026-11-14T02:15:42.861980+00:00` / `reqgap-20261114-kirimasim-77c27531.json`。 失敗 1、既知不一致 0、未対応 11、未実行 11451、古い証跡 1、規格違反テストの判定根拠が未承認 5 行。
- `verilator` / `Verilator 5.054 2026-11-01 rev vUNKNOWN-built20261101`: 11/12332 (0.09%)。 計測元: `2026-11-14T02:15:04.150898+00:00` / `reqgap-20261114-verilator5.054-seed1.json`。 失敗 0、既知不一致 19、未対応 0、未実行 11451、古い証跡 1、規格違反テストの判定根拠が未承認 1 行。
- `verilator` / `Verilator 5.054 2026-11-01 rev vUNKNOWN-built20261101`: 11/12332 (0.09%)。 計測元: `2026-11-14T02:15:42.524351+00:00` / `reqgap-20261114-verilator5.054-seed73.json`。 失敗 0、既知不一致 19、未対応 0、未実行 11451、古い証跡 1、規格違反テストの判定根拠が未承認 1 行。
- `icarus` / `Icarus Verilog version 13.0 (stable) (v13_0)`: 5/12332 (0.04%)。 計測元: `2026-11-14T05:44:47.296047+00:00` / `reqgap2-20261114-icarus13.json`。 失敗 0、既知不一致 33、未対応 0、未実行 11444、古い証跡 0、規格違反テストの判定根拠が未承認 1 行。
- `kirimasim` / `kirimasim 0.0.0 (commit d1d8a1782d0a), built with AppleClang 21.0.0.21000401`: 8/12332 (0.06%)。 計測元: `2026-11-14T05:45:47.127832+00:00` / `reqgap2-20261114-kirimasim-d1d8a178.json`。 失敗 4、既知不一致 0、未対応 21、未実行 11442、古い証跡 0、規格違反テストの判定根拠が未承認 8 行。
- `verilator` / `Verilator 5.054 2026-11-01 rev vUNKNOWN-built20261101`: 6/12332 (0.05%)。 計測元: `2026-11-14T05:45:18.982868+00:00` / `reqgap2-20261114-verilator5.054-seed1.json`。 失敗 0、既知不一致 30、未対応 0、未実行 11443、古い証跡 0、規格違反テストの判定根拠が未承認 4 行。
- `verilator` / `Verilator 5.054 2026-11-01 rev vUNKNOWN-built20261101`: 6/12332 (0.05%)。 計測元: `2026-11-14T05:45:46.782913+00:00` / `reqgap2-20261114-verilator5.054-seed73.json`。 失敗 0、既知不一致 30、未対応 0、未実行 11443、古い証跡 0、規格違反テストの判定根拠が未承認 4 行。
- `icarus` / `Icarus Verilog version 13.0 (stable) (v13_0)`: 4/12332 (0.03%)。 計測元: `2026-11-14T08:09:22.791456+00:00` / `reqgap3-20261114-icarus13.json`。 失敗 0、既知不一致 16、未対応 0、未実行 11451、古い証跡 0、規格違反テストの判定根拠が未承認 12 行。
- `kirimasim` / `kirimasim 0.0.0 (commit d1d8a1782d0a), built with AppleClang 21.0.0.21000401`: 5/12332 (0.04%)。 計測元: `2026-11-14T08:10:25.089652+00:00` / `reqgap3-20261114-kirimasim-d1d8a178.json`。 失敗 1、既知不一致 0、未対応 3、未実行 11451、古い証跡 0、規格違反テストの判定根拠が未承認 23 行。
- `verilator` / `Verilator 5.054 2026-11-01 rev vUNKNOWN-built20261101`: 9/12332 (0.07%)。 計測元: `2026-11-14T08:09:50.844161+00:00` / `reqgap3-20261114-verilator5.054-seed1.json`。 失敗 0、既知不一致 19、未対応 0、未実行 11453、古い証跡 0、規格違反テストの判定根拠が未承認 2 行。
- `verilator` / `Verilator 5.054 2026-11-01 rev vUNKNOWN-built20261101`: 9/12332 (0.07%)。 計測元: `2026-11-14T08:10:24.715784+00:00` / `reqgap3-20261114-verilator5.054-seed73.json`。 失敗 0、既知不一致 19、未対応 0、未実行 11453、古い証跡 0、規格違反テストの判定根拠が未承認 2 行。
- `icarus` / `Icarus Verilog version 13.0 (stable) (v13_0)`: 26/12332 (0.21%)。 計測元: `2026-11-14T14:45:27.599657+00:00` / `reqgap5-20261114-icarus13.json`。 失敗 0、既知不一致 44、未対応 0、未実行 11400、古い証跡 11、規格違反テストの判定根拠が未承認 2 行。
- `kirimasim` / `kirimasim 0.0.0 (commit d1d8a1782d0a), built with AppleClang 21.0.0.21000401`: 18/12332 (0.15%)。 計測元: `2026-11-14T14:47:44.027905+00:00` / `reqgap5-20261114-kirimasim-d1d8a178.json`。 失敗 2、既知不一致 0、未対応 44、未実行 11400、古い証跡 11、規格違反テストの判定根拠が未承認 8 行。
- `verilator` / `Verilator 5.054 2026-11-01 rev vUNKNOWN-built20261101`: 12/12332 (0.10%)。 計測元: `2026-11-14T14:46:35.374894+00:00` / `reqgap5-20261114-verilator5.054-seed1.json`。 失敗 0、既知不一致 56、未対応 0、未実行 11401、古い証跡 11、規格違反テストの判定根拠が未承認 3 行。
- `verilator` / `Verilator 5.054 2026-11-01 rev vUNKNOWN-built20261101`: 12/12332 (0.10%)。 計測元: `2026-11-14T14:47:43.190246+00:00` / `reqgap5-20261114-verilator5.054-seed73.json`。 失敗 0、既知不一致 56、未対応 0、未実行 11401、古い証跡 11、規格違反テストの判定根拠が未承認 3 行。
- `icarus` / `Icarus Verilog version 13.0 (stable) (v13_0)`: 8/12332 (0.06%)。 計測元: `2026-11-19T15:46:16.026728+00:00` / `reqgap6-20261120-icarus13.json`。 失敗 0、既知不一致 19、未対応 0、未実行 11454、古い証跡 1、規格違反テストの判定根拠が未承認 1 行。
- `kirimasim` / `kirimasim 0.1.1 (commit a6222f0656d4), built with AppleClang 21.0.0.21000401`: 9/12332 (0.07%)。 計測元: `2026-11-19T15:46:16.196256+00:00` / `reqgap6-20261120-kirimasim-a6222f06.json`。 失敗 0、既知不一致 0、未対応 16、未実行 11454、古い証跡 1、規格違反テストの判定根拠が未承認 3 行。
- `verilator` / `Verilator 5.054 2026-11-01 rev vUNKNOWN-built20261101`: 3/12332 (0.02%)。 計測元: `2026-11-19T15:46:17.221209+00:00` / `reqgap6-20261120-verilator5.054-seed1.json`。 失敗 0、既知不一致 25、未対応 0、未実行 11454、古い証跡 1、規格違反テストの判定根拠が未承認 0 行。
- `verilator` / `Verilator 5.054 2026-11-01 rev vUNKNOWN-built20261101`: 3/12332 (0.02%)。 計測元: `2026-11-19T15:46:17.959332+00:00` / `reqgap6-20261120-verilator5.054-seed73.json`。 失敗 0、既知不一致 25、未対応 0、未実行 11454、古い証跡 1、規格違反テストの判定根拠が未承認 0 行。
- `icarus` / `Icarus Verilog version 13.0 (stable) (v13_0)`: 0/12332 (0.00%)。 計測元: `2026-11-19T23:33:37.497509+00:00` / `reqgap7-20261120-icarus13.json`。 失敗 0、既知不一致 11、未対応 0、未実行 11469、古い証跡 0、規格違反テストの判定根拠が未承認 3 行。
- `kirimasim` / `kirimasim 0.1.1 (commit a6222f0656d4), built with AppleClang 21.0.0.21000401`: 0/12332 (0.00%)。 計測元: `2026-11-19T23:33:37.526094+00:00` / `reqgap7-20261120-kirimasim-a6222f06.json`。 失敗 0、既知不一致 0、未対応 14、未実行 11469、古い証跡 0、規格違反テストの判定根拠が未承認 0 行。
- `verilator` / `Verilator 5.054 2026-11-01 rev vUNKNOWN-built20261101`: 2/12332 (0.02%)。 計測元: `2026-11-19T23:33:58.371412+00:00` / `reqgap7-20261120-verilator5.054-seed1.json`。 失敗 0、既知不一致 11、未対応 0、未実行 11469、古い証跡 0、規格違反テストの判定根拠が未承認 1 行。
- `verilator` / `Verilator 5.054 2026-11-01 rev vUNKNOWN-built20261101`: 2/12332 (0.02%)。 計測元: `2026-11-19T23:33:58.371408+00:00` / `reqgap7-20261120-verilator5.054-seed73.json`。 失敗 0、既知不一致 11、未対応 0、未実行 11469、古い証跡 0、規格違反テストの判定根拠が未承認 1 行。
- `icarus` / `Icarus Verilog version 13.0 (stable) (v13_0)`: 0/12332 (0.00%)。 計測元: `2026-11-20T21:11:46.826734+00:00` / `reqgap7-20261121-icarus13.json`。 失敗 0、既知不一致 2、未対応 0、未実行 11481、古い証跡 0、規格違反テストの判定根拠が未承認 0 行。
- `kirimasim` / `kirimasim 0.1.1 (commit a6222f0656d4), built with AppleClang 21.0.0.21000401`: 0/12332 (0.00%)。 計測元: `2026-11-20T21:11:47.173114+00:00` / `reqgap7-20261121-kirimasim-a6222f06.json`。 失敗 0、既知不一致 0、未対応 1、未実行 11481、古い証跡 0、規格違反テストの判定根拠が未承認 1 行。
- `verilator` / `Verilator 5.054 2026-11-01 rev vUNKNOWN-built20261101`: 1/12332 (0.01%)。 計測元: `2026-11-20T21:12:40.545470+00:00` / `reqgap7-20261121-verilator5.054-seed1.json`。 失敗 0、既知不一致 1、未対応 0、未実行 11481、古い証跡 0、規格違反テストの判定根拠が未承認 0 行。
- `verilator` / `Verilator 5.054 2026-11-01 rev vUNKNOWN-built20261101`: 1/12332 (0.01%)。 計測元: `2026-11-20T21:13:19.508385+00:00` / `reqgap7-20261121-verilator5.054-seed73.json`。 失敗 0、既知不一致 1、未対応 0、未実行 11481、古い証跡 0、規格違反テストの判定根拠が未承認 0 行。
- `icarus` / `Icarus Verilog version 13.0 (stable) (v13_0)`: 1/12332 (0.01%)。 計測元: `2026-11-20T00:44:12.999452+00:00` / `reqgap8-20261120-icarus13.json`。 失敗 0、既知不一致 7、未対応 0、未実行 11475、古い証跡 0、規格違反テストの判定根拠が未承認 0 行。
- `kirimasim` / `kirimasim 0.1.1 (commit a6222f0656d4), built with AppleClang 21.0.0.21000401`: 0/12332 (0.00%)。 計測元: `2026-11-20T00:44:12.606501+00:00` / `reqgap8-20261120-kirimasim-a6222f06.json`。 失敗 0、既知不一致 0、未対応 8、未実行 11475、古い証跡 0、規格違反テストの判定根拠が未承認 0 行。
- `verilator` / `Verilator 5.054 2026-11-01 rev vUNKNOWN-built20261101`: 0/12332 (0.00%)。 計測元: `2026-11-20T00:44:19.746413+00:00` / `reqgap8-20261120-verilator5.054-seed1.json`。 失敗 0、既知不一致 8、未対応 0、未実行 11475、古い証跡 0、規格違反テストの判定根拠が未承認 0 行。
- `verilator` / `Verilator 5.054 2026-11-01 rev vUNKNOWN-built20261101`: 0/12332 (0.00%)。 計測元: `2026-11-20T00:44:19.746335+00:00` / `reqgap8-20261120-verilator5.054-seed73.json`。 失敗 0、既知不一致 8、未対応 0、未実行 11475、古い証跡 0、規格違反テストの判定根拠が未承認 0 行。
- `icarus` / `Icarus Verilog version 13.0 (stable) (v13_0)`: 0/12332 (0.00%)。 計測元: `2026-11-12T01:03:42.109814+00:00` / `runtime-errors-20261112-icarus13.json`。 失敗 0、既知不一致 8、未対応 0、未実行 11475、古い証跡 0、規格違反テストの判定根拠が未承認 0 行。
- `kirimasim` / `kirimasim 0.0.0 (commit 7de185f776a1), built with AppleClang 21.0.0.21000401`: 1/12332 (0.01%)。 計測元: `2026-11-12T01:03:42.439195+00:00` / `runtime-errors-20261112-kirimasim-7de185f7.json`。 失敗 0、既知不一致 0、未対応 7、未実行 11475、古い証跡 0、規格違反テストの判定根拠が未承認 0 行。
- `verilator` / `Verilator 5.052 2026-09-05 rev vUNKNOWN-built20260905`: 1/12332 (0.01%)。 計測元: `2026-11-12T01:03:46.712402+00:00` / `runtime-errors-20261112-verilator5.052-seed1.json`。 失敗 0、既知不一致 7、未対応 0、未実行 11475、古い証跡 0、規格違反テストの判定根拠が未承認 0 行。
- `verilator` / `Verilator 5.052 2026-09-05 rev vUNKNOWN-built20260905`: 1/12332 (0.01%)。 計測元: `2026-11-12T01:03:50.809958+00:00` / `runtime-errors-20261112-verilator5.052-seed73.json`。 失敗 0、既知不一致 7、未対応 0、未実行 11475、古い証跡 0、規格違反テストの判定根拠が未承認 0 行。
- `icarus` / `Icarus Verilog version 13.0 (stable) (v13_0)`: 0/12332 (0.00%)。 計測元: `2026-11-18T22:45:24.324223+00:00` / `stream-boundaries-20261119a-icarus13.json`。 失敗 0、既知不一致 0、未対応 0、未実行 11483、古い証跡 0、規格違反テストの判定根拠が未承認 0 行。
- `kirimasim` / `kirimasim 0.1.1 (commit 441dddbd0fcd), built with AppleClang 21.0.0.21000401`: 0/12332 (0.00%)。 計測元: `2026-11-18T22:45:25.317816+00:00` / `stream-boundaries-20261119a-kirimasim-441dddbd0fcd-run1.json`。 失敗 0、既知不一致 0、未対応 0、未実行 11483、古い証跡 0、規格違反テストの判定根拠が未承認 0 行。
- `kirimasim` / `kirimasim 0.1.1 (commit 441dddbd0fcd), built with AppleClang 21.0.0.21000401`: 0/12332 (0.00%)。 計測元: `2026-11-18T22:45:26.285358+00:00` / `stream-boundaries-20261119a-kirimasim-441dddbd0fcd-run2.json`。 失敗 0、既知不一致 0、未対応 0、未実行 11483、古い証跡 0、規格違反テストの判定根拠が未承認 0 行。
- `kirimasim` / `kirimasim 0.1.1 (commit 441dddbd0fcd), built with AppleClang 21.0.0.21000401`: 0/12332 (0.00%)。 計測元: `2026-11-18T22:45:27.241770+00:00` / `stream-boundaries-20261119a-kirimasim-441dddbd0fcd-run3.json`。 失敗 0、既知不一致 0、未対応 0、未実行 11483、古い証跡 0、規格違反テストの判定根拠が未承認 0 行。
- `kirimasim` / `kirimasim 0.1.1 (commit 441dddbd0fcd), built with AppleClang 21.0.0.21000401`: 0/12332 (0.00%)。 計測元: `2026-11-18T22:45:28.199451+00:00` / `stream-boundaries-20261119a-kirimasim-441dddbd0fcd-run4.json`。 失敗 0、既知不一致 0、未対応 0、未実行 11483、古い証跡 0、規格違反テストの判定根拠が未承認 0 行。
- `verilator` / `Verilator 5.054 2026-11-01 rev vUNKNOWN-built20261101`: 0/12332 (0.00%)。 計測元: `2026-11-18T22:49:28.164924+00:00` / `stream-boundaries-20261119a-verilator5.054-seed1.json`。 失敗 0、既知不一致 0、未対応 0、未実行 11483、古い証跡 0、規格違反テストの判定根拠が未承認 0 行。
- `verilator` / `Verilator 5.054 2026-11-01 rev vUNKNOWN-built20261101`: 0/12332 (0.00%)。 計測元: `2026-11-18T22:52:43.831093+00:00` / `stream-boundaries-20261119a-verilator5.054-seed73.json`。 失敗 0、既知不一致 0、未対応 0、未実行 11483、古い証跡 0、規格違反テストの判定根拠が未承認 0 行。
- `icarus` / `Icarus Verilog version 13.0 (stable) (v13_0)`: 5/12332 (0.04%)。 計測元: `2026-11-15T01:33:38.989463+00:00` / `strength-events-20261115-icarus13.json`。 失敗 0、既知不一致 1、未対応 0、未実行 11477、古い証跡 0、規格違反テストの判定根拠が未承認 0 行。
- `kirimasim` / `kirimasim 0.0.0 (commit d1d8a1782d0a), built with AppleClang 21.0.0.21000401`: 6/12332 (0.05%)。 計測元: `2026-11-15T01:33:42.310174+00:00` / `strength-events-20261115-kirimasim-d1d8a178.json`。 失敗 0、既知不一致 0、未対応 0、未実行 11477、古い証跡 0、規格違反テストの判定根拠が未承認 0 行。
- `verilator` / `Verilator 5.054 2026-11-01 rev vUNKNOWN-built20261101`: 1/12332 (0.01%)。 計測元: `2026-11-15T01:33:41.184186+00:00` / `strength-events-20261115-verilator5.054-seed1.json`。 失敗 0、既知不一致 5、未対応 0、未実行 11477、古い証跡 0、規格違反テストの判定根拠が未承認 0 行。
- `verilator` / `Verilator 5.054 2026-11-01 rev vUNKNOWN-built20261101`: 1/12332 (0.01%)。 計測元: `2026-11-15T01:33:42.187059+00:00` / `strength-events-20261115-verilator5.054-seed73.json`。 失敗 0、既知不一致 5、未対応 0、未実行 11477、古い証跡 0、規格違反テストの判定根拠が未承認 0 行。
- `icarus` / `Icarus Verilog version 13.0 (stable) (v13_0)`: 0/12332 (0.00%)。 計測元: `2026-11-20T21:24:39.791096+00:00` / `sv2023-thin-20261121-icarus13.json`。 失敗 0、既知不一致 0、未対応 0、未実行 11483、古い証跡 0、規格違反テストの判定根拠が未承認 0 行。
- `kirimasim` / `kirimasim 0.1.1 (commit a6222f0656d4), built with AppleClang 21.0.0.21000401`: 0/12332 (0.00%)。 計測元: `2026-11-20T21:24:40.094672+00:00` / `sv2023-thin-20261121-kirimasim-a6222f06.json`。 失敗 0、既知不一致 0、未対応 0、未実行 11483、古い証跡 0、規格違反テストの判定根拠が未承認 0 行。
- `verilator` / `Verilator 5.054 2026-11-01 rev vUNKNOWN-built20261101`: 0/12332 (0.00%)。 計測元: `2026-11-20T21:25:04.136848+00:00` / `sv2023-thin-20261121-verilator5.054-seed1.json`。 失敗 0、既知不一致 0、未対応 0、未実行 11483、古い証跡 0、規格違反テストの判定根拠が未承認 0 行。
- `verilator` / `Verilator 5.054 2026-11-01 rev vUNKNOWN-built20261101`: 0/12332 (0.00%)。 計測元: `2026-11-20T21:25:22.711190+00:00` / `sv2023-thin-20261121-verilator5.054-seed73.json`。 失敗 0、既知不一致 0、未対応 0、未実行 11483、古い証跡 0、規格違反テストの判定根拠が未承認 0 行。
- `icarus` / `Icarus Verilog version 13.0 (stable) (v13_0)`: 1/12332 (0.01%)。 計測元: `2026-11-12T21:43:20.959244+00:00` / `test-fix-20261113-icarus13.json`。 失敗 0、既知不一致 0、未対応 0、未実行 11482、古い証跡 0、規格違反テストの判定根拠が未承認 0 行。
- `kirimasim` / `kirimasim 0.0.0 (commit 7de185f776a1), built with AppleClang 21.0.0.21000401`: 0/12332 (0.00%)。 計測元: `2026-11-12T21:43:29.567975+00:00` / `test-fix-20261113-kirimasim-7de185f7.json`。 失敗 0、既知不一致 0、未対応 1、未実行 11482、古い証跡 0、規格違反テストの判定根拠が未承認 0 行。
- `verilator` / `Verilator 5.052 2026-09-05 rev vUNKNOWN-built20260905`: 1/12332 (0.01%)。 計測元: `2026-11-12T21:43:25.251767+00:00` / `test-fix-20261113-verilator5.052-seed1.json`。 失敗 0、既知不一致 0、未対応 0、未実行 11482、古い証跡 0、規格違反テストの判定根拠が未承認 0 行。
- `verilator` / `Verilator 5.052 2026-09-05 rev vUNKNOWN-built20260905`: 1/12332 (0.01%)。 計測元: `2026-11-12T21:43:29.466399+00:00` / `test-fix-20261113-verilator5.052-seed73.json`。 失敗 0、既知不一致 0、未対応 0、未実行 11482、古い証跡 0、規格違反テストの判定根拠が未承認 0 行。
- `icarus` / `Icarus Verilog version 13.0 (stable) (v13_0)`: 0/12332 (0.00%)。 計測元: `2026-11-11T23:50:40.175858+00:00` / `test-fixes-20261112-icarus13.json`。 失敗 0、既知不一致 49、未対応 0、未実行 11431、古い証跡 3、規格違反テストの判定根拠が未承認 0 行。
- `kirimasim` / `kirimasim 0.0.0 (commit 7de185f776a1), built with AppleClang 21.0.0.21000401`: 0/12332 (0.00%)。 計測元: `2026-11-11T23:50:40.334300+00:00` / `test-fixes-20261112-kirimasim-7de185f7.json`。 失敗 0、既知不一致 0、未対応 49、未実行 11431、古い証跡 3、規格違反テストの判定根拠が未承認 0 行。
- `verilator` / `Verilator 5.052 2026-09-05 rev vUNKNOWN-built20260905`: 0/12332 (0.00%)。 計測元: `2026-11-11T23:50:41.819877+00:00` / `test-fixes-20261112-verilator5.052-seed1.json`。 失敗 0、既知不一致 49、未対応 0、未実行 11431、古い証跡 3、規格違反テストの判定根拠が未承認 0 行。
- `verilator` / `Verilator 5.052 2026-09-05 rev vUNKNOWN-built20260905`: 0/12332 (0.00%)。 計測元: `2026-11-11T23:50:43.072508+00:00` / `test-fixes-20261112-verilator5.052-seed73.json`。 失敗 0、既知不一致 49、未対応 0、未実行 11431、古い証跡 3、規格違反テストの判定根拠が未承認 0 行。
- `verilator` / `Verilator 5.054 2026-11-01 rev v5.054`: 3/12332 (0.02%)。 計測元: `2026-11-19T21:25:34.006223+00:00` / `test-side-fixes-20261120-verilator5.054-seed1.json`。 失敗 0、既知不一致 0、未対応 0、未実行 11480、古い証跡 0、規格違反テストの判定根拠が未承認 0 行。
- `verilator` / `Verilator 5.054 2026-11-01 rev v5.054`: 3/12332 (0.02%)。 計測元: `2026-11-19T21:25:35.189349+00:00` / `test-side-fixes-20261120-verilator5.054-seed73.json`。 失敗 0、既知不一致 0、未対応 0、未実行 11480、古い証跡 0、規格違反テストの判定根拠が未承認 0 行。
- `icarus` / `Icarus Verilog version 13.0 (stable) (v13_0)`: 0/12332 (0.00%)。 計測元: `2026-11-14T02:58:01.691798+00:00` / `vifsense-20261114-icarus13.json`。 失敗 0、既知不一致 0、未対応 0、未実行 11483、古い証跡 0、規格違反テストの判定根拠が未承認 0 行。
- `kirimasim` / `kirimasim 0.0.0 (commit 77c27531437c), built with AppleClang 21.0.0.21000401`: 0/12332 (0.00%)。 計測元: `2026-11-14T02:58:21.742365+00:00` / `vifsense-20261114-kirimasim-77c27531.json`。 失敗 0、既知不一致 0、未対応 0、未実行 11483、古い証跡 0、規格違反テストの判定根拠が未承認 0 行。
- `verilator` / `Verilator 5.054 2026-11-01 rev vUNKNOWN-built20261101`: 0/12332 (0.00%)。 計測元: `2026-11-14T02:58:11.624866+00:00` / `vifsense-20261114-verilator5.054-seed1.json`。 失敗 0、既知不一致 0、未対応 0、未実行 11483、古い証跡 0、規格違反テストの判定根拠が未承認 0 行。
- `verilator` / `Verilator 5.054 2026-11-01 rev vUNKNOWN-built20261101`: 0/12332 (0.00%)。 計測元: `2026-11-14T02:58:21.644402+00:00` / `vifsense-20261114-verilator5.054-seed73.json`。 失敗 0、既知不一致 0、未対応 0、未実行 11483、古い証跡 0、規格違反テストの判定根拠が未承認 0 行。
- `icarus` / `Icarus Verilog version 13.0 (stable) (v13_0)`: 0/12332 (0.00%)。 計測元: `2026-11-19T20:48:30.198207+00:00` / `vpi-io-decl-refinement-20261120-icarus13.json`。 失敗 0、既知不一致 12、未対応 0、未実行 11471、古い証跡 0、規格違反テストの判定根拠が未承認 0 行。
- `kirimasim` / `kirimasim 0.1.1 (commit a6222f0656d4), built with AppleClang 21.0.0.21000401`: 0/12332 (0.00%)。 計測元: `2026-11-19T20:48:30.248426+00:00` / `vpi-io-decl-refinement-20261120-kirimasim-a6222f06.json`。 失敗 0、既知不一致 0、未対応 12、未実行 11471、古い証跡 0、規格違反テストの判定根拠が未承認 0 行。
- `verilator` / `Verilator 5.054 2026-11-01 rev vUNKNOWN-built20261101`: 0/12332 (0.00%)。 計測元: `2026-11-19T20:48:30.380302+00:00` / `vpi-io-decl-refinement-20261120-verilator5.054-seed1.json`。 失敗 0、既知不一致 12、未対応 0、未実行 11471、古い証跡 0、規格違反テストの判定根拠が未承認 0 行。
- `verilator` / `Verilator 5.054 2026-11-01 rev vUNKNOWN-built20261101`: 0/12332 (0.00%)。 計測元: `2026-11-19T20:48:30.513143+00:00` / `vpi-io-decl-refinement-20261120-verilator5.054-seed73.json`。 失敗 0、既知不一致 12、未対応 0、未実行 11471、古い証跡 0、規格違反テストの判定根拠が未承認 0 行。
- `icarus` / `Icarus Verilog version 13.0 (stable) (v13_0)`: 0/12332 (0.00%)。 計測元: `2026-11-14T13:04:58.367365+00:00` / `vpidpi-20261114-icarus13.json`。 失敗 0、既知不一致 30、未対応 0、未実行 11449、古い証跡 0、規格違反テストの判定根拠が未承認 4 行。
- `kirimasim` / `kirimasim 0.0.0 (commit d1d8a1782d0a), built with AppleClang 21.0.0.21000401`: 0/12332 (0.00%)。 計測元: `2026-11-14T13:06:19.523413+00:00` / `vpidpi-20261114-kirimasim-d1d8a178.json`。 失敗 0、既知不一致 0、未対応 29、未実行 11449、古い証跡 0、規格違反テストの判定根拠が未承認 5 行。
- `verilator` / `Verilator 5.054 2026-11-01 rev vUNKNOWN-built20261101`: 3/12332 (0.02%)。 計測元: `2026-11-14T13:05:38.888744+00:00` / `vpidpi-20261114-verilator5.054-seed1.json`。 失敗 0、既知不一致 28、未対応 0、未実行 11449、古い証跡 0、規格違反テストの判定根拠が未承認 3 行。
- `verilator` / `Verilator 5.054 2026-11-01 rev vUNKNOWN-built20261101`: 3/12332 (0.02%)。 計測元: `2026-11-14T13:06:19.394846+00:00` / `vpidpi-20261114-verilator5.054-seed73.json`。 失敗 0、既知不一致 28、未対応 0、未実行 11449、古い証跡 0、規格違反テストの判定根拠が未承認 3 行。
- `icarus` / `Icarus Verilog version 13.0 (stable) (v13_0)`: 0/12332 (0.00%)。 計測元: `2026-11-19T08:03:33.006792+00:00` / `wide-array-shapes-20261119ab-icarus13.json`。 失敗 0、既知不一致 0、未対応 0、未実行 11483、古い証跡 0、規格違反テストの判定根拠が未承認 0 行。
- `kirimasim` / `kirimasim 0.1.1 (commit a6222f0656d4), built with AppleClang 21.0.0.21000401`: 0/12332 (0.00%)。 計測元: `2026-11-19T08:03:33.573506+00:00` / `wide-array-shapes-20261119ab-kirimasim-a6222f0656d4-run1.json`。 失敗 0、既知不一致 0、未対応 0、未実行 11483、古い証跡 0、規格違反テストの判定根拠が未承認 0 行。
- `kirimasim` / `kirimasim 0.1.1 (commit a6222f0656d4), built with AppleClang 21.0.0.21000401`: 0/12332 (0.00%)。 計測元: `2026-11-19T08:03:34.143657+00:00` / `wide-array-shapes-20261119ab-kirimasim-a6222f0656d4-run2.json`。 失敗 0、既知不一致 0、未対応 0、未実行 11483、古い証跡 0、規格違反テストの判定根拠が未承認 0 行。
- `kirimasim` / `kirimasim 0.1.1 (commit a6222f0656d4), built with AppleClang 21.0.0.21000401`: 0/12332 (0.00%)。 計測元: `2026-11-19T08:03:34.714462+00:00` / `wide-array-shapes-20261119ab-kirimasim-a6222f0656d4-run3.json`。 失敗 0、既知不一致 0、未対応 0、未実行 11483、古い証跡 0、規格違反テストの判定根拠が未承認 0 行。
- `kirimasim` / `kirimasim 0.1.1 (commit a6222f0656d4), built with AppleClang 21.0.0.21000401`: 0/12332 (0.00%)。 計測元: `2026-11-19T08:03:35.284804+00:00` / `wide-array-shapes-20261119ab-kirimasim-a6222f0656d4-run4.json`。 失敗 0、既知不一致 0、未対応 0、未実行 11483、古い証跡 0、規格違反テストの判定根拠が未承認 0 行。
- `verilator` / `Verilator 5.054 2026-11-01 rev vUNKNOWN-built20261101`: 0/12332 (0.00%)。 計測元: `2026-11-19T08:05:11.316819+00:00` / `wide-array-shapes-20261119ab-verilator5.054-seed1.json`。 失敗 0、既知不一致 0、未対応 0、未実行 11483、古い証跡 0、規格違反テストの判定根拠が未承認 0 行。
- `verilator` / `Verilator 5.054 2026-11-01 rev vUNKNOWN-built20261101`: 0/12332 (0.00%)。 計測元: `2026-11-19T08:06:42.986548+00:00` / `wide-array-shapes-20261119ab-verilator5.054-seed73.json`。 失敗 0、既知不一致 0、未対応 0、未実行 11483、古い証跡 0、規格違反テストの判定根拠が未承認 0 行。
- `icarus` / `Icarus Verilog version 13.0 (stable) (v13_0)`: 0/12332 (0.00%)。 計測元: `2026-11-19T07:22:17.840650+00:00` / `wide-bitvector-queries-20261119z-icarus13.json`。 失敗 0、既知不一致 0、未対応 0、未実行 11483、古い証跡 0、規格違反テストの判定根拠が未承認 0 行。
- `kirimasim` / `kirimasim 0.1.1 (commit a6222f0656d4), built with AppleClang 21.0.0.21000401`: 0/12332 (0.00%)。 計測元: `2026-11-19T07:22:18.345242+00:00` / `wide-bitvector-queries-20261119z-kirimasim-a6222f0656d4-run1.json`。 失敗 0、既知不一致 0、未対応 0、未実行 11483、古い証跡 0、規格違反テストの判定根拠が未承認 0 行。
- `kirimasim` / `kirimasim 0.1.1 (commit a6222f0656d4), built with AppleClang 21.0.0.21000401`: 0/12332 (0.00%)。 計測元: `2026-11-19T07:22:18.854769+00:00` / `wide-bitvector-queries-20261119z-kirimasim-a6222f0656d4-run2.json`。 失敗 0、既知不一致 0、未対応 0、未実行 11483、古い証跡 0、規格違反テストの判定根拠が未承認 0 行。
- `kirimasim` / `kirimasim 0.1.1 (commit a6222f0656d4), built with AppleClang 21.0.0.21000401`: 0/12332 (0.00%)。 計測元: `2026-11-19T07:22:19.357406+00:00` / `wide-bitvector-queries-20261119z-kirimasim-a6222f0656d4-run3.json`。 失敗 0、既知不一致 0、未対応 0、未実行 11483、古い証跡 0、規格違反テストの判定根拠が未承認 0 行。
- `kirimasim` / `kirimasim 0.1.1 (commit a6222f0656d4), built with AppleClang 21.0.0.21000401`: 0/12332 (0.00%)。 計測元: `2026-11-19T07:22:19.873962+00:00` / `wide-bitvector-queries-20261119z-kirimasim-a6222f0656d4-run4.json`。 失敗 0、既知不一致 0、未対応 0、未実行 11483、古い証跡 0、規格違反テストの判定根拠が未承認 0 行。
- `verilator` / `Verilator 5.054 2026-11-01 rev vUNKNOWN-built20261101`: 0/12332 (0.00%)。 計測元: `2026-11-19T07:24:00.224839+00:00` / `wide-bitvector-queries-20261119z-verilator5.054-seed1.json`。 失敗 0、既知不一致 0、未対応 0、未実行 11483、古い証跡 0、規格違反テストの判定根拠が未承認 0 行。
- `verilator` / `Verilator 5.054 2026-11-01 rev vUNKNOWN-built20261101`: 0/12332 (0.00%)。 計測元: `2026-11-19T07:25:36.875457+00:00` / `wide-bitvector-queries-20261119z-verilator5.054-seed73.json`。 失敗 0、既知不一致 0、未対応 0、未実行 11483、古い証跡 0、規格違反テストの判定根拠が未承認 0 行。
- `icarus` / `Icarus Verilog version 13.0 (stable) (v13_0)`: 0/12332 (0.00%)。 計測元: `2026-11-16T14:45:49.004880+00:00` / `wide-boundaries-20261116-icarus13.json`。 失敗 0、既知不一致 0、未対応 0、未実行 11483、古い証跡 0、規格違反テストの判定根拠が未承認 0 行。
- `kirimasim` / `kirimasim 0.1.0 (commit cfa2ccd75989), built with AppleClang 21.0.0.21000401`: 0/12332 (0.00%)。 計測元: `2026-11-16T14:45:49.650424+00:00` / `wide-boundaries-20261116-kirimasim-cfa2ccd7-run1.json`。 失敗 0、既知不一致 0、未対応 0、未実行 11483、古い証跡 0、規格違反テストの判定根拠が未承認 0 行。
- `kirimasim` / `kirimasim 0.1.0 (commit cfa2ccd75989), built with AppleClang 21.0.0.21000401`: 0/12332 (0.00%)。 計測元: `2026-11-16T14:45:50.266367+00:00` / `wide-boundaries-20261116-kirimasim-cfa2ccd7-run2.json`。 失敗 0、既知不一致 0、未対応 0、未実行 11483、古い証跡 0、規格違反テストの判定根拠が未承認 0 行。
- `kirimasim` / `kirimasim 0.1.0 (commit cfa2ccd75989), built with AppleClang 21.0.0.21000401`: 0/12332 (0.00%)。 計測元: `2026-11-16T14:45:50.880873+00:00` / `wide-boundaries-20261116-kirimasim-cfa2ccd7-run3.json`。 失敗 0、既知不一致 0、未対応 0、未実行 11483、古い証跡 0、規格違反テストの判定根拠が未承認 0 行。
- `kirimasim` / `kirimasim 0.1.0 (commit cfa2ccd75989), built with AppleClang 21.0.0.21000401`: 0/12332 (0.00%)。 計測元: `2026-11-16T14:45:51.492227+00:00` / `wide-boundaries-20261116-kirimasim-cfa2ccd7-run4.json`。 失敗 0、既知不一致 0、未対応 0、未実行 11483、古い証跡 0、規格違反テストの判定根拠が未承認 0 行。
- `verilator` / `Verilator 5.054 2026-11-01 rev vUNKNOWN-built20261101`: 0/12332 (0.00%)。 計測元: `2026-11-16T14:48:32.216656+00:00` / `wide-boundaries-20261116-verilator5.054-seed1.json`。 失敗 0、既知不一致 0、未対応 0、未実行 11483、古い証跡 0、規格違反テストの判定根拠が未承認 0 行。
- `verilator` / `Verilator 5.054 2026-11-01 rev vUNKNOWN-built20261101`: 0/12332 (0.00%)。 計測元: `2026-11-16T14:45:30.994335+00:00` / `wide-boundaries-20261116-verilator5.054-seed73.json`。 失敗 0、既知不一致 0、未対応 0、未実行 11483、古い証跡 0、規格違反テストの判定根拠が未承認 0 行。
- `icarus` / `Icarus Verilog version 13.0 (stable) (v13_0)`: 0/12332 (0.00%)。 計測元: `2026-11-19T04:51:47.031795+00:00` / `wide-casts-20261119q-icarus13.json`。 失敗 0、既知不一致 0、未対応 0、未実行 11483、古い証跡 0、規格違反テストの判定根拠が未承認 0 行。
- `kirimasim` / `kirimasim 0.1.1 (commit a6222f0656d4), built with AppleClang 21.0.0.21000401`: 0/12332 (0.00%)。 計測元: `2026-11-19T04:51:48.765935+00:00` / `wide-casts-20261119q-kirimasim-a6222f0656d4-run1.json`。 失敗 0、既知不一致 0、未対応 0、未実行 11483、古い証跡 0、規格違反テストの判定根拠が未承認 0 行。
- `kirimasim` / `kirimasim 0.1.1 (commit a6222f0656d4), built with AppleClang 21.0.0.21000401`: 0/12332 (0.00%)。 計測元: `2026-11-19T04:51:50.502871+00:00` / `wide-casts-20261119q-kirimasim-a6222f0656d4-run2.json`。 失敗 0、既知不一致 0、未対応 0、未実行 11483、古い証跡 0、規格違反テストの判定根拠が未承認 0 行。
- `kirimasim` / `kirimasim 0.1.1 (commit a6222f0656d4), built with AppleClang 21.0.0.21000401`: 0/12332 (0.00%)。 計測元: `2026-11-19T04:51:52.235915+00:00` / `wide-casts-20261119q-kirimasim-a6222f0656d4-run3.json`。 失敗 0、既知不一致 0、未対応 0、未実行 11483、古い証跡 0、規格違反テストの判定根拠が未承認 0 行。
- `kirimasim` / `kirimasim 0.1.1 (commit a6222f0656d4), built with AppleClang 21.0.0.21000401`: 0/12332 (0.00%)。 計測元: `2026-11-19T04:51:53.984176+00:00` / `wide-casts-20261119q-kirimasim-a6222f0656d4-run4.json`。 失敗 0、既知不一致 0、未対応 0、未実行 11483、古い証跡 0、規格違反テストの判定根拠が未承認 0 行。
- `verilator` / `Verilator 5.054 2026-11-01 rev vUNKNOWN-built20261101`: 0/12332 (0.00%)。 計測元: `2026-11-19T04:58:05.410719+00:00` / `wide-casts-20261119q-verilator5.054-seed1.json`。 失敗 0、既知不一致 0、未対応 0、未実行 11483、古い証跡 0、規格違反テストの判定根拠が未承認 0 行。
- `verilator` / `Verilator 5.054 2026-11-01 rev vUNKNOWN-built20261101`: 0/12332 (0.00%)。 計測元: `2026-11-19T05:04:07.348920+00:00` / `wide-casts-20261119q-verilator5.054-seed73.json`。 失敗 0、既知不一致 0、未対応 0、未実行 11483、古い証跡 0、規格違反テストの判定根拠が未承認 0 行。
- `icarus` / `Icarus Verilog version 13.0 (stable) (v13_0)`: 0/12332 (0.00%)。 計測元: `2026-11-19T05:20:35.477542+00:00` / `wide-constant-calls-20261119s-icarus13.json`。 失敗 0、既知不一致 0、未対応 0、未実行 11483、古い証跡 0、規格違反テストの判定根拠が未承認 0 行。
- `kirimasim` / `kirimasim 0.1.1 (commit a6222f0656d4), built with AppleClang 21.0.0.21000401`: 0/12332 (0.00%)。 計測元: `2026-11-19T05:20:36.098428+00:00` / `wide-constant-calls-20261119s-kirimasim-a6222f0656d4-run1.json`。 失敗 0、既知不一致 0、未対応 0、未実行 11483、古い証跡 0、規格違反テストの判定根拠が未承認 0 行。
- `kirimasim` / `kirimasim 0.1.1 (commit a6222f0656d4), built with AppleClang 21.0.0.21000401`: 0/12332 (0.00%)。 計測元: `2026-11-19T05:20:36.723459+00:00` / `wide-constant-calls-20261119s-kirimasim-a6222f0656d4-run2.json`。 失敗 0、既知不一致 0、未対応 0、未実行 11483、古い証跡 0、規格違反テストの判定根拠が未承認 0 行。
- `kirimasim` / `kirimasim 0.1.1 (commit a6222f0656d4), built with AppleClang 21.0.0.21000401`: 0/12332 (0.00%)。 計測元: `2026-11-19T05:20:37.344390+00:00` / `wide-constant-calls-20261119s-kirimasim-a6222f0656d4-run3.json`。 失敗 0、既知不一致 0、未対応 0、未実行 11483、古い証跡 0、規格違反テストの判定根拠が未承認 0 行。
- `kirimasim` / `kirimasim 0.1.1 (commit a6222f0656d4), built with AppleClang 21.0.0.21000401`: 0/12332 (0.00%)。 計測元: `2026-11-19T05:20:37.952667+00:00` / `wide-constant-calls-20261119s-kirimasim-a6222f0656d4-run4.json`。 失敗 0、既知不一致 0、未対応 0、未実行 11483、古い証跡 0、規格違反テストの判定根拠が未承認 0 行。
- `verilator` / `Verilator 5.054 2026-11-01 rev vUNKNOWN-built20261101`: 0/12332 (0.00%)。 計測元: `2026-11-19T05:22:39.770875+00:00` / `wide-constant-calls-20261119s-verilator5.054-seed1.json`。 失敗 0、既知不一致 0、未対応 0、未実行 11483、古い証跡 0、規格違反テストの判定根拠が未承認 0 行。
- `verilator` / `Verilator 5.054 2026-11-01 rev vUNKNOWN-built20261101`: 0/12332 (0.00%)。 計測元: `2026-11-19T05:23:59.183594+00:00` / `wide-constant-calls-20261119s-verilator5.054-seed73.json`。 失敗 0、既知不一致 0、未対応 0、未実行 11483、古い証跡 0、規格違反テストの判定根拠が未承認 0 行。
- `icarus` / `Icarus Verilog version 13.0 (stable) (v13_0)`: 0/12332 (0.00%)。 計測元: `2026-11-19T05:09:41.265216+00:00` / `wide-forces-20261119r-icarus13.json`。 失敗 0、既知不一致 0、未対応 0、未実行 11483、古い証跡 0、規格違反テストの判定根拠が未承認 0 行。
- `kirimasim` / `kirimasim 0.1.1 (commit a6222f0656d4), built with AppleClang 21.0.0.21000401`: 0/12332 (0.00%)。 計測元: `2026-11-19T05:09:42.408924+00:00` / `wide-forces-20261119r-kirimasim-a6222f0656d4-run1.json`。 失敗 0、既知不一致 0、未対応 0、未実行 11483、古い証跡 0、規格違反テストの判定根拠が未承認 0 行。
- `kirimasim` / `kirimasim 0.1.1 (commit a6222f0656d4), built with AppleClang 21.0.0.21000401`: 0/12332 (0.00%)。 計測元: `2026-11-19T05:09:43.564585+00:00` / `wide-forces-20261119r-kirimasim-a6222f0656d4-run2.json`。 失敗 0、既知不一致 0、未対応 0、未実行 11483、古い証跡 0、規格違反テストの判定根拠が未承認 0 行。
- `kirimasim` / `kirimasim 0.1.1 (commit a6222f0656d4), built with AppleClang 21.0.0.21000401`: 0/12332 (0.00%)。 計測元: `2026-11-19T05:09:44.714239+00:00` / `wide-forces-20261119r-kirimasim-a6222f0656d4-run3.json`。 失敗 0、既知不一致 0、未対応 0、未実行 11483、古い証跡 0、規格違反テストの判定根拠が未承認 0 行。
- `kirimasim` / `kirimasim 0.1.1 (commit a6222f0656d4), built with AppleClang 21.0.0.21000401`: 0/12332 (0.00%)。 計測元: `2026-11-19T05:09:45.870040+00:00` / `wide-forces-20261119r-kirimasim-a6222f0656d4-run4.json`。 失敗 0、既知不一致 0、未対応 0、未実行 11483、古い証跡 0、規格違反テストの判定根拠が未承認 0 行。
- `verilator` / `Verilator 5.054 2026-11-01 rev vUNKNOWN-built20261101`: 0/12332 (0.00%)。 計測元: `2026-11-19T05:14:18.769051+00:00` / `wide-forces-20261119r-verilator5.054-seed1.json`。 失敗 0、既知不一致 0、未対応 0、未実行 11483、古い証跡 0、規格違反テストの判定根拠が未承認 0 行。
- `verilator` / `Verilator 5.054 2026-11-01 rev vUNKNOWN-built20261101`: 0/12332 (0.00%)。 計測元: `2026-11-19T05:17:59.731551+00:00` / `wide-forces-20261119r-verilator5.054-seed73.json`。 失敗 0、既知不一致 0、未対応 0、未実行 11483、古い証跡 0、規格違反テストの判定根拠が未承認 0 行。
- `icarus` / `Icarus Verilog version 13.0 (stable) (v13_0)`: 0/12332 (0.00%)。 計測元: `2026-11-19T07:14:00.470772+00:00` / `wide-format-fields-20261119y-icarus13.json`。 失敗 0、既知不一致 0、未対応 0、未実行 11483、古い証跡 0、規格違反テストの判定根拠が未承認 0 行。
- `kirimasim` / `kirimasim 0.1.1 (commit a6222f0656d4), built with AppleClang 21.0.0.21000401`: 0/12332 (0.00%)。 計測元: `2026-11-19T07:14:01.207377+00:00` / `wide-format-fields-20261119y-kirimasim-a6222f0656d4-run1.json`。 失敗 0、既知不一致 0、未対応 0、未実行 11483、古い証跡 0、規格違反テストの判定根拠が未承認 0 行。
- `kirimasim` / `kirimasim 0.1.1 (commit a6222f0656d4), built with AppleClang 21.0.0.21000401`: 0/12332 (0.00%)。 計測元: `2026-11-19T07:14:01.948811+00:00` / `wide-format-fields-20261119y-kirimasim-a6222f0656d4-run2.json`。 失敗 0、既知不一致 0、未対応 0、未実行 11483、古い証跡 0、規格違反テストの判定根拠が未承認 0 行。
- `kirimasim` / `kirimasim 0.1.1 (commit a6222f0656d4), built with AppleClang 21.0.0.21000401`: 0/12332 (0.00%)。 計測元: `2026-11-19T07:14:02.686562+00:00` / `wide-format-fields-20261119y-kirimasim-a6222f0656d4-run3.json`。 失敗 0、既知不一致 0、未対応 0、未実行 11483、古い証跡 0、規格違反テストの判定根拠が未承認 0 行。
- `kirimasim` / `kirimasim 0.1.1 (commit a6222f0656d4), built with AppleClang 21.0.0.21000401`: 0/12332 (0.00%)。 計測元: `2026-11-19T07:14:03.437642+00:00` / `wide-format-fields-20261119y-kirimasim-a6222f0656d4-run4.json`。 失敗 0、既知不一致 0、未対応 0、未実行 11483、古い証跡 0、規格違反テストの判定根拠が未承認 0 行。
- `verilator` / `Verilator 5.054 2026-11-01 rev vUNKNOWN-built20261101`: 0/12332 (0.00%)。 計測元: `2026-11-19T07:16:34.110160+00:00` / `wide-format-fields-20261119y-verilator5.054-seed1.json`。 失敗 0、既知不一致 0、未対応 0、未実行 11483、古い証跡 0、規格違反テストの判定根拠が未承認 0 行。
- `verilator` / `Verilator 5.054 2026-11-01 rev vUNKNOWN-built20261101`: 0/12332 (0.00%)。 計測元: `2026-11-19T07:18:54.574001+00:00` / `wide-format-fields-20261119y-verilator5.054-seed73.json`。 失敗 0、既知不一致 0、未対応 0、未実行 11483、古い証跡 0、規格違反テストの判定根拠が未承認 0 行。
- `icarus` / `Icarus Verilog version 13.0 (stable) (v13_0)`: 0/12332 (0.00%)。 計測元: `2026-11-19T06:13:35.306058+00:00` / `wide-format-roundtrips-20261119v-icarus13.json`。 失敗 0、既知不一致 0、未対応 0、未実行 11483、古い証跡 0、規格違反テストの判定根拠が未承認 0 行。
- `kirimasim` / `kirimasim 0.1.1 (commit a6222f0656d4), built with AppleClang 21.0.0.21000401`: 0/12332 (0.00%)。 計測元: `2026-11-19T06:13:35.940807+00:00` / `wide-format-roundtrips-20261119v-kirimasim-a6222f0656d4-run1.json`。 失敗 0、既知不一致 0、未対応 0、未実行 11483、古い証跡 0、規格違反テストの判定根拠が未承認 0 行。
- `kirimasim` / `kirimasim 0.1.1 (commit a6222f0656d4), built with AppleClang 21.0.0.21000401`: 0/12332 (0.00%)。 計測元: `2026-11-19T06:13:36.561807+00:00` / `wide-format-roundtrips-20261119v-kirimasim-a6222f0656d4-run2.json`。 失敗 0、既知不一致 0、未対応 0、未実行 11483、古い証跡 0、規格違反テストの判定根拠が未承認 0 行。
- `kirimasim` / `kirimasim 0.1.1 (commit a6222f0656d4), built with AppleClang 21.0.0.21000401`: 0/12332 (0.00%)。 計測元: `2026-11-19T06:13:37.179766+00:00` / `wide-format-roundtrips-20261119v-kirimasim-a6222f0656d4-run3.json`。 失敗 0、既知不一致 0、未対応 0、未実行 11483、古い証跡 0、規格違反テストの判定根拠が未承認 0 行。
- `kirimasim` / `kirimasim 0.1.1 (commit a6222f0656d4), built with AppleClang 21.0.0.21000401`: 0/12332 (0.00%)。 計測元: `2026-11-19T06:13:37.795037+00:00` / `wide-format-roundtrips-20261119v-kirimasim-a6222f0656d4-run4.json`。 失敗 0、既知不一致 0、未対応 0、未実行 11483、古い証跡 0、規格違反テストの判定根拠が未承認 0 行。
- `verilator` / `Verilator 5.054 2026-11-01 rev vUNKNOWN-built20261101`: 0/12332 (0.00%)。 計測元: `2026-11-19T06:14:58.122742+00:00` / `wide-format-roundtrips-20261119v-verilator5.054-seed1.json`。 失敗 0、既知不一致 0、未対応 0、未実行 11483、古い証跡 0、規格違反テストの判定根拠が未承認 0 行。
- `verilator` / `Verilator 5.054 2026-11-01 rev vUNKNOWN-built20261101`: 0/12332 (0.00%)。 計測元: `2026-11-19T06:16:11.426473+00:00` / `wide-format-roundtrips-20261119v-verilator5.054-seed73.json`。 失敗 0、既知不一致 0、未対応 0、未実行 11483、古い証跡 0、規格違反テストの判定根拠が未承認 0 行。
- `icarus` / `Icarus Verilog version 13.0 (stable) (v13_0)`: 0/12332 (0.00%)。 計測元: `2026-11-19T05:56:04.807629+00:00` / `wide-runtime-aliases-20261119u-icarus13.json`。 失敗 0、既知不一致 0、未対応 0、未実行 11483、古い証跡 0、規格違反テストの判定根拠が未承認 0 行。
- `kirimasim` / `kirimasim 0.1.1 (commit a6222f0656d4), built with AppleClang 21.0.0.21000401`: 0/12332 (0.00%)。 計測元: `2026-11-19T05:56:05.334558+00:00` / `wide-runtime-aliases-20261119u-kirimasim-a6222f0656d4-run1.json`。 失敗 0、既知不一致 0、未対応 0、未実行 11483、古い証跡 0、規格違反テストの判定根拠が未承認 0 行。
- `kirimasim` / `kirimasim 0.1.1 (commit a6222f0656d4), built with AppleClang 21.0.0.21000401`: 0/12332 (0.00%)。 計測元: `2026-11-19T05:56:05.858654+00:00` / `wide-runtime-aliases-20261119u-kirimasim-a6222f0656d4-run2.json`。 失敗 0、既知不一致 0、未対応 0、未実行 11483、古い証跡 0、規格違反テストの判定根拠が未承認 0 行。
- `kirimasim` / `kirimasim 0.1.1 (commit a6222f0656d4), built with AppleClang 21.0.0.21000401`: 0/12332 (0.00%)。 計測元: `2026-11-19T05:56:06.398925+00:00` / `wide-runtime-aliases-20261119u-kirimasim-a6222f0656d4-run3.json`。 失敗 0、既知不一致 0、未対応 0、未実行 11483、古い証跡 0、規格違反テストの判定根拠が未承認 0 行。
- `kirimasim` / `kirimasim 0.1.1 (commit a6222f0656d4), built with AppleClang 21.0.0.21000401`: 0/12332 (0.00%)。 計測元: `2026-11-19T05:56:06.931953+00:00` / `wide-runtime-aliases-20261119u-kirimasim-a6222f0656d4-run4.json`。 失敗 0、既知不一致 0、未対応 0、未実行 11483、古い証跡 0、規格違反テストの判定根拠が未承認 0 行。
- `verilator` / `Verilator 5.054 2026-11-01 rev vUNKNOWN-built20261101`: 0/12332 (0.00%)。 計測元: `2026-11-19T05:57:43.758970+00:00` / `wide-runtime-aliases-20261119u-verilator5.054-seed1.json`。 失敗 0、既知不一致 0、未対応 0、未実行 11483、古い証跡 0、規格違反テストの判定根拠が未承認 0 行。
- `verilator` / `Verilator 5.054 2026-11-01 rev vUNKNOWN-built20261101`: 0/12332 (0.00%)。 計測元: `2026-11-19T05:59:05.521617+00:00` / `wide-runtime-aliases-20261119u-verilator5.054-seed73.json`。 失敗 0、既知不一致 0、未対応 0、未実行 11483、古い証跡 0、規格違反テストの判定根拠が未承認 0 行。
- `icarus` / `Icarus Verilog version 13.0 (stable) (v13_0)`: 0/12332 (0.00%)。 計測元: `2026-11-19T01:27:22.963056+00:00` / `wide-scan-20261119g-icarus13.json`。 失敗 0、既知不一致 0、未対応 0、未実行 11483、古い証跡 0、規格違反テストの判定根拠が未承認 0 行。
- `kirimasim` / `kirimasim 0.1.1 (commit 441dddbd0fcd), built with AppleClang 21.0.0.21000401`: 0/12332 (0.00%)。 計測元: `2026-11-19T01:27:24.973823+00:00` / `wide-scan-20261119g-kirimasim-441dddbd0fcd-run1.json`。 失敗 0、既知不一致 0、未対応 0、未実行 11483、古い証跡 0、規格違反テストの判定根拠が未承認 0 行。
- `kirimasim` / `kirimasim 0.1.1 (commit 441dddbd0fcd), built with AppleClang 21.0.0.21000401`: 0/12332 (0.00%)。 計測元: `2026-11-19T01:27:27.017736+00:00` / `wide-scan-20261119g-kirimasim-441dddbd0fcd-run2.json`。 失敗 0、既知不一致 0、未対応 0、未実行 11483、古い証跡 0、規格違反テストの判定根拠が未承認 0 行。
- `kirimasim` / `kirimasim 0.1.1 (commit 441dddbd0fcd), built with AppleClang 21.0.0.21000401`: 0/12332 (0.00%)。 計測元: `2026-11-19T01:27:29.091620+00:00` / `wide-scan-20261119g-kirimasim-441dddbd0fcd-run3.json`。 失敗 0、既知不一致 0、未対応 0、未実行 11483、古い証跡 0、規格違反テストの判定根拠が未承認 0 行。
- `kirimasim` / `kirimasim 0.1.1 (commit 441dddbd0fcd), built with AppleClang 21.0.0.21000401`: 0/12332 (0.00%)。 計測元: `2026-11-19T01:27:31.225314+00:00` / `wide-scan-20261119g-kirimasim-441dddbd0fcd-run4.json`。 失敗 0、既知不一致 0、未対応 0、未実行 11483、古い証跡 0、規格違反テストの判定根拠が未承認 0 行。
- `verilator` / `Verilator 5.054 2026-11-01 rev vUNKNOWN-built20261101`: 0/12332 (0.00%)。 計測元: `2026-11-19T01:34:05.091232+00:00` / `wide-scan-20261119g-verilator5.054-seed1.json`。 失敗 0、既知不一致 0、未対応 0、未実行 11483、古い証跡 0、規格違反テストの判定根拠が未承認 0 行。
- `verilator` / `Verilator 5.054 2026-11-01 rev vUNKNOWN-built20261101`: 0/12332 (0.00%)。 計測元: `2026-11-19T01:40:31.496871+00:00` / `wide-scan-20261119g-verilator5.054-seed73.json`。 失敗 0、既知不一致 0、未対応 0、未実行 11483、古い証跡 0、規格違反テストの判定根拠が未承認 0 行。
- `icarus` / `Icarus Verilog version 13.0 (stable) (v13_0)`: 0/12332 (0.00%)。 計測元: `2026-11-19T04:22:06.868964+00:00` / `wide-shifts-20261119p-icarus13.json`。 失敗 0、既知不一致 0、未対応 0、未実行 11483、古い証跡 0、規格違反テストの判定根拠が未承認 0 行。
- `kirimasim` / `kirimasim 0.1.1 (commit a6222f0656d4), built with AppleClang 21.0.0.21000401`: 0/12332 (0.00%)。 計測元: `2026-11-19T04:22:08.955044+00:00` / `wide-shifts-20261119p-kirimasim-a6222f0656d4-run1.json`。 失敗 0、既知不一致 0、未対応 0、未実行 11483、古い証跡 0、規格違反テストの判定根拠が未承認 0 行。
- `kirimasim` / `kirimasim 0.1.1 (commit a6222f0656d4), built with AppleClang 21.0.0.21000401`: 0/12332 (0.00%)。 計測元: `2026-11-19T04:22:11.066499+00:00` / `wide-shifts-20261119p-kirimasim-a6222f0656d4-run2.json`。 失敗 0、既知不一致 0、未対応 0、未実行 11483、古い証跡 0、規格違反テストの判定根拠が未承認 0 行。
- `kirimasim` / `kirimasim 0.1.1 (commit a6222f0656d4), built with AppleClang 21.0.0.21000401`: 0/12332 (0.00%)。 計測元: `2026-11-19T04:22:13.228061+00:00` / `wide-shifts-20261119p-kirimasim-a6222f0656d4-run3.json`。 失敗 0、既知不一致 0、未対応 0、未実行 11483、古い証跡 0、規格違反テストの判定根拠が未承認 0 行。
- `kirimasim` / `kirimasim 0.1.1 (commit a6222f0656d4), built with AppleClang 21.0.0.21000401`: 0/12332 (0.00%)。 計測元: `2026-11-19T04:22:15.326597+00:00` / `wide-shifts-20261119p-kirimasim-a6222f0656d4-run4.json`。 失敗 0、既知不一致 0、未対応 0、未実行 11483、古い証跡 0、規格違反テストの判定根拠が未承認 0 行。
- `verilator` / `Verilator 5.054 2026-11-01 rev vUNKNOWN-built20261101`: 0/12332 (0.00%)。 計測元: `2026-11-19T04:29:41.580746+00:00` / `wide-shifts-20261119p-verilator5.054-seed1.json`。 失敗 0、既知不一致 0、未対応 0、未実行 11483、古い証跡 0、規格違反テストの判定根拠が未承認 0 行。
- `verilator` / `Verilator 5.054 2026-11-01 rev vUNKNOWN-built20261101`: 0/12332 (0.00%)。 計測元: `2026-11-19T04:36:16.959708+00:00` / `wide-shifts-20261119p-verilator5.054-seed73.json`。 失敗 0、既知不一致 0、未対応 0、未実行 11483、古い証跡 0、規格違反テストの判定根拠が未承認 0 行。
- `icarus` / `Icarus Verilog version 13.0 (stable) (v13_0)`: 0/12332 (0.00%)。 計測元: `2026-11-19T03:15:07.588812+00:00` / `wide-values-20261119m-icarus13.json`。 失敗 0、既知不一致 0、未対応 0、未実行 11483、古い証跡 0、規格違反テストの判定根拠が未承認 0 行。
- `kirimasim` / `kirimasim 0.1.1 (commit a6222f0656d4), built with AppleClang 21.0.0.21000401`: 0/12332 (0.00%)。 計測元: `2026-11-19T03:15:10.657769+00:00` / `wide-values-20261119m-kirimasim-a6222f0656d4-run1.json`。 失敗 0、既知不一致 0、未対応 0、未実行 11483、古い証跡 0、規格違反テストの判定根拠が未承認 0 行。
- `kirimasim` / `kirimasim 0.1.1 (commit a6222f0656d4), built with AppleClang 21.0.0.21000401`: 0/12332 (0.00%)。 計測元: `2026-11-19T03:15:13.670831+00:00` / `wide-values-20261119m-kirimasim-a6222f0656d4-run2.json`。 失敗 0、既知不一致 0、未対応 0、未実行 11483、古い証跡 0、規格違反テストの判定根拠が未承認 0 行。
- `kirimasim` / `kirimasim 0.1.1 (commit a6222f0656d4), built with AppleClang 21.0.0.21000401`: 0/12332 (0.00%)。 計測元: `2026-11-19T03:15:16.826123+00:00` / `wide-values-20261119m-kirimasim-a6222f0656d4-run3.json`。 失敗 0、既知不一致 0、未対応 0、未実行 11483、古い証跡 0、規格違反テストの判定根拠が未承認 0 行。
- `kirimasim` / `kirimasim 0.1.1 (commit a6222f0656d4), built with AppleClang 21.0.0.21000401`: 0/12332 (0.00%)。 計測元: `2026-11-19T03:15:20.118073+00:00` / `wide-values-20261119m-kirimasim-a6222f0656d4-run4.json`。 失敗 0、既知不一致 0、未対応 0、未実行 11483、古い証跡 0、規格違反テストの判定根拠が未承認 0 行。
- `verilator` / `Verilator 5.054 2026-11-01 rev vUNKNOWN-built20261101`: 0/12332 (0.00%)。 計測元: `2026-11-19T03:26:23.848418+00:00` / `wide-values-20261119m-verilator5.054-seed1.json`。 失敗 0、既知不一致 0、未対応 0、未実行 11483、古い証跡 0、規格違反テストの判定根拠が未承認 0 行。
- `verilator` / `Verilator 5.054 2026-11-01 rev vUNKNOWN-built20261101`: 0/12332 (0.00%)。 計測元: `2026-11-19T03:36:16.019749+00:00` / `wide-values-20261119m-verilator5.054-seed73.json`。 失敗 0、既知不一致 0、未対応 0、未実行 11483、古い証跡 0、規格違反テストの判定根拠が未承認 0 行。
- 不採用の結果ファイル: 228 件。

<a id="by-chapter-and-appendix-percentage-of-registered-items"></a>

## 章・附属書別（登録項目に対する割合）

- 1 Overview: テスト対応 対象項目なし、実行確認 対象項目なし、Ghostを除く実行確認 対象項目なし、解釈保留 0 行。
- 2 Normative references: テスト対応 0/2 (0.00%)、実行確認 0/2 (0.00%)、Ghostを除く実行確認 0/2 (0.00%)、解釈保留 0 行。
- 3 Design and verification building blocks: テスト対応 132/146 (90.41%)、実行確認 127/146 (86.99%)、Ghostを除く実行確認 120/146 (82.19%)、解釈保留 0 行。
- 4 Scheduling semantics: テスト対応 90/107 (84.11%)、実行確認 88/107 (82.24%)、Ghostを除く実行確認 59/107 (55.14%)、解釈保留 0 行。
- 5 Lexical conventions: テスト対応 146/155 (94.19%)、実行確認 143/155 (92.26%)、Ghostを除く実行確認 131/155 (84.52%)、解釈保留 0 行。
- 6 Data types: テスト対応 711/720 (98.75%)、実行確認 654/720 (90.83%)、Ghostを除く実行確認 518/720 (71.94%)、解釈保留 0 行。
- 7 Aggregate data types: テスト対応 337/347 (97.12%)、実行確認 297/347 (85.59%)、Ghostを除く実行確認 182/347 (52.45%)、解釈保留 0 行。
- 8 Classes: テスト対応 239/255 (93.73%)、実行確認 186/255 (72.94%)、Ghostを除く実行確認 146/255 (57.25%)、解釈保留 0 行。
- 9 Processes: テスト対応 183/192 (95.31%)、実行確認 173/192 (90.10%)、Ghostを除く実行確認 117/192 (60.94%)、解釈保留 0 行。
- 10 Assignment statements: テスト対応 147/156 (94.23%)、実行確認 126/156 (80.77%)、Ghostを除く実行確認 83/156 (53.21%)、解釈保留 0 行。
- 11 Operators and expressions: テスト対応 448/459 (97.60%)、実行確認 428/459 (93.25%)、Ghostを除く実行確認 355/459 (77.34%)、解釈保留 0 行。
- 12 Procedural programming statements: テスト対応 101/115 (87.83%)、実行確認 92/115 (80.00%)、Ghostを除く実行確認 53/115 (46.09%)、解釈保留 0 行。
- 13 Tasks and functions (subroutines): テスト対応 116/124 (93.55%)、実行確認 97/124 (78.23%)、Ghostを除く実行確認 81/124 (65.32%)、解釈保留 0 行。
- 14 Clocking blocks: テスト対応 86/87 (98.85%)、実行確認 79/87 (90.80%)、Ghostを除く実行確認 60/87 (68.97%)、解釈保留 0 行。
- 15 Interprocess synchronization and communication: テスト対応 84/88 (95.45%)、実行確認 77/88 (87.50%)、Ghostを除く実行確認 46/88 (52.27%)、解釈保留 0 行。
- 16 Assertions: テスト対応 549/557 (98.56%)、実行確認 447/557 (80.25%)、Ghostを除く実行確認 107/557 (19.21%)、解釈保留 0 行。
- 17 Checkers: テスト対応 69/81 (85.19%)、実行確認 48/81 (59.26%)、Ghostを除く実行確認 14/81 (17.28%)、解釈保留 0 行。
- 18 Constrained random value generation: テスト対応 315/323 (97.52%)、実行確認 272/323 (84.21%)、Ghostを除く実行確認 138/323 (42.72%)、解釈保留 0 行。
- 19 Functional coverage: テスト対応 268/276 (97.10%)、実行確認 218/276 (78.99%)、Ghostを除く実行確認 25/276 (9.06%)、解釈保留 0 行。
- 20 Utility system tasks and system functions: テスト対応 301/320 (94.06%)、実行確認 290/320 (90.62%)、Ghostを除く実行確認 133/320 (41.56%)、解釈保留 0 行。
- 21 Input/output system tasks and system functions: テスト対応 362/383 (94.52%)、実行確認 348/383 (90.86%)、Ghostを除く実行確認 218/383 (56.92%)、解釈保留 0 行。
- 22 Compiler directives: テスト対応 355/363 (97.80%)、実行確認 349/363 (96.14%)、Ghostを除く実行確認 344/363 (94.77%)、解釈保留 0 行。
- 23 Modules and hierarchy: テスト対応 254/260 (97.69%)、実行確認 226/260 (86.92%)、Ghostを除く実行確認 127/260 (48.85%)、解釈保留 0 行。
- 24 Programs: テスト対応 25/29 (86.21%)、実行確認 21/29 (72.41%)、Ghostを除く実行確認 5/29 (17.24%)、解釈保留 0 行。
- 25 Interfaces: テスト対応 58/63 (92.06%)、実行確認 38/63 (60.32%)、Ghostを除く実行確認 24/63 (38.10%)、解釈保留 0 行。
- 26 Packages: テスト対応 41/44 (93.18%)、実行確認 36/44 (81.82%)、Ghostを除く実行確認 31/44 (70.45%)、解釈保留 0 行。
- 27 Generate constructs: テスト対応 28/32 (87.50%)、実行確認 25/32 (78.12%)、Ghostを除く実行確認 21/32 (65.62%)、解釈保留 0 行。
- 28 Gate-level and switch-level modeling: テスト対応 374/384 (97.40%)、実行確認 374/384 (97.40%)、Ghostを除く実行確認 287/384 (74.74%)、解釈保留 0 行。
- 29 User-defined primitives: テスト対応 49/52 (94.23%)、実行確認 43/52 (82.69%)、Ghostを除く実行確認 39/52 (75.00%)、解釈保留 0 行。
- 30 Specify blocks: テスト対応 150/157 (95.54%)、実行確認 140/157 (89.17%)、Ghostを除く実行確認 111/157 (70.70%)、解釈保留 0 行。
- 31 Timing checks: テスト対応 155/180 (86.11%)、実行確認 146/180 (81.11%)、Ghostを除く実行確認 18/180 (10.00%)、解釈保留 0 行。
- 32 Backannotation using the standard delay format: テスト対応 119/131 (90.84%)、実行確認 119/131 (90.84%)、Ghostを除く実行確認 65/131 (49.62%)、解釈保留 0 行。
- 33 Configuring the contents of a design: テスト対応 41/63 (65.08%)、実行確認 29/63 (46.03%)、Ghostを除く実行確認 8/63 (12.70%)、解釈保留 0 行。
- 34 Protected envelopes: テスト対応 5/214 (2.34%)、実行確認 5/214 (2.34%)、Ghostを除く実行確認 5/214 (2.34%)、解釈保留 0 行。
- 35 Direct programming interface: テスト対応 122/143 (85.31%)、実行確認 113/143 (79.02%)、Ghostを除く実行確認 78/143 (54.55%)、解釈保留 0 行。
- 36 Programming language interface (PLI/VPI) overview: テスト対応 148/163 (90.80%)、実行確認 148/163 (90.80%)、Ghostを除く実行確認 46/163 (28.22%)、解釈保留 0 行。
- 37 VPI object model diagrams: テスト対応 1662/1757 (94.59%)、実行確認 1662/1757 (94.59%)、Ghostを除く実行確認 72/1757 (4.10%)、解釈保留 0 行。
- 38 VPI routine definitions: テスト対応 283/348 (81.32%)、実行確認 283/348 (81.32%)、Ghostを除く実行確認 146/348 (41.95%)、解釈保留 0 行。
- 39 Assertion API: テスト対応 82/95 (86.32%)、実行確認 82/95 (86.32%)、Ghostを除く実行確認 2/95 (2.11%)、解釈保留 0 行。
- 40 Code coverage control and API: テスト対応 122/128 (95.31%)、実行確認 122/128 (95.31%)、Ghostを除く実行確認 34/128 (26.56%)、解釈保留 0 行。
- 41 Data read API: テスト対応 対象項目なし、実行確認 対象項目なし、Ghostを除く実行確認 対象項目なし、解釈保留 0 行。
- A Formal syntax: テスト対応 796/811 (98.15%)、実行確認 796/811 (98.15%)、Ghostを除く実行確認 519/811 (64.00%)、解釈保留 0 行。
- B Keywords: テスト対応 248/248 (100.00%)、実行確認 248/248 (100.00%)、Ghostを除く実行確認 248/248 (100.00%)、解釈保留 0 行。
- C Deprecation: テスト対応 9/20 (45.00%)、実行確認 9/20 (45.00%)、Ghostを除く実行確認 7/20 (35.00%)、解釈保留 0 行。
- D Optional system tasks and system functions: テスト対応 対象項目なし、実行確認 対象項目なし、Ghostを除く実行確認 対象項目なし、解釈保留 0 行。
- E Optional compiler directives: テスト対応 対象項目なし、実行確認 対象項目なし、Ghostを除く実行確認 対象項目なし、解釈保留 0 行。
- F Formal semantics of concurrent assertions: テスト対応 253/253 (100.00%)、実行確認 253/253 (100.00%)、Ghostを除く実行確認 253/253 (100.00%)、解釈保留 0 行。
- G Std package: テスト対応 25/32 (78.12%)、実行確認 25/32 (78.12%)、Ghostを除く実行確認 18/32 (56.25%)、解釈保留 0 行。
- H DPI C layer: テスト対応 193/223 (86.55%)、実行確認 193/223 (86.55%)、Ghostを除く実行確認 128/223 (57.40%)、解釈保留 0 行。
- I svdpi.h: テスト対応 134/147 (91.16%)、実行確認 134/147 (91.16%)、Ghostを除く実行確認 113/147 (76.87%)、解釈保留 0 行。
- J Inclusion of foreign language code: テスト対応 0/16 (0.00%)、実行確認 0/16 (0.00%)、Ghostを除く実行確認 0/16 (0.00%)、解釈保留 0 行。
- K vpi_user.h: テスト対応 541/544 (99.45%)、実行確認 541/544 (99.45%)、Ghostを除く実行確認 540/544 (99.26%)、解釈保留 0 行。
- L vpi_compatibility.h: テスト対応 85/88 (96.59%)、実行確認 85/88 (96.59%)、Ghostを除く実行確認 0/88 (0.00%)、解釈保留 0 行。
- M sv_vpi_user.h: テスト対応 407/412 (98.79%)、実行確認 407/412 (98.79%)、Ghostを除く実行確認 407/412 (98.79%)、解釈保留 0 行。
- N Algorithm for probabilistic distribution functions: テスト対応 35/39 (89.74%)、実行確認 35/39 (89.74%)、Ghostを除く実行確認 35/39 (89.74%)、解釈保留 0 行。
- O Encryption/decryption flow: テスト対応 対象項目なし、実行確認 対象項目なし、Ghostを除く実行確認 対象項目なし、解釈保留 0 行。
- P Glossary: テスト対応 対象項目なし、実行確認 対象項目なし、Ghostを除く実行確認 対象項目なし、解釈保留 0 行。
- Q Bibliography: テスト対応 対象項目なし、実行確認 対象項目なし、Ghostを除く実行確認 対象項目なし、解釈保留 0 行。

<a id="denominator-and-history"></a>

## 分母と履歴

- 分母SHA-256: `3e082eb97645e56c5c07ea62dc21876b52bd54c4d28ad6ecdfa907aa459e184b`。
- 計測規則の版: 3。
- 履歴には分母の識別子、暫定値と確定値、環境別の状態内訳を保存します。 分母が異なる回の割合を、そのまま改善・悪化として比較しません。
- この集計は保存済み実行証跡から再生成されます。上記の計測元時刻が実行時刻です。
