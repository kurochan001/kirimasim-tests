# IEEE 1800-2023 動作カバレッジ集計

[全項目の詳細](behavior-coverage.md) / [管理手順](../coverage/README.md) / [解釈保留の根拠](../docs/requirement-extraction-notes.md)

## 全規格の要求台帳に対する暫定値

- テスト設計網羅率: **31.57%** (3889/12319)。
- 実行確認率: **19.45%** (2396/12319)。複数環境の成功の和集合。
- 分母には解釈保留と未対応も含みます。未実装・未対応を除外していません。
- 登録単位は要求の出現箇所・条件・初期の観測ケースであり、意味の重複整理前の暫定値です。
  全プログラム・全入力の組み合わせを試した割合や、単一シミュレータの規格適合率ではありません。

## 既存テストの集計状況

- 全 3986 本のうち、要求との対応を登録済みのテストは 1539 本。未登録は 2447 本です。
- 上記の網羅率は、刺激と期待結果を確認して要求との対応を登録した分だけを計上しています。
  未登録の既存テストも検証に役立ちますが、その貢献はまだ割合に反映できていません。
- 登録済み本数は少なくとも一つの要求との対応がある本数で、テスト全体のレビュー完了数ではありません。

- 複数テストで分担する要求は 147 行。各グループの全テストが同じ実行回で成功した場合だけ、要求全体の実行成功に数えます。

## 確定値

- 規格全動作のテスト設計網羅率: 未確定。
- 規格全動作の実行確認率: 未確定。
- 分母の承認: 未承認。計測状態: `provisional`。
- 資料確認、保留解釈の解決、要求単位の重複整理、分母のレビューを経て確定します。

## 残件

- 新鮮な成功証跡あり: 2396 行。
- 対応済み・成功証跡なし: 1493 行。
- テスト対応未確認（解釈保留以外）: 8409 行。
- 解釈保留: 21 行。

未対応は、既存テストが存在しないという判定ではありません。

## シミュレータ別の実行確認率

- `icarus` / Icarus Verilog version 13.0 (stable) (v13_0-dirty): 0/12319 (0.00%)。
  計測元: 2026-10-22T22:03:58.531565+00:00 / `associative-count-refinement-20261023-icarus13.json`。
  失敗 0、既知不一致 2、未対応 0、未実行 3887、古い証跡 0、違法系の判定根拠未承認 0 行。
- `verilator` / Verilator 5.052 2026-09-05 rev vUNKNOWN-built20260905: 2/12319 (0.02%)。
  計測元: 2026-10-22T22:04:02.952792+00:00 / `associative-count-refinement-20261023-verilator-seed1.json`。
  失敗 0、既知不一致 0、未対応 0、未実行 3887、古い証跡 0、違法系の判定根拠未承認 0 行。
- `verilator` / Verilator 5.052 2026-09-05 rev vUNKNOWN-built20260905: 2/12319 (0.02%)。
  計測元: 2026-10-22T22:04:02.961719+00:00 / `associative-count-refinement-20261023-verilator-seed73.json`。
  失敗 0、既知不一致 0、未対応 0、未実行 3887、古い証跡 0、違法系の判定根拠未承認 0 行。
- `icarus` / Icarus Verilog version 13.0 (stable) (v13_0-dirty): 0/12319 (0.00%)。
  計測元: 2026-10-22T21:57:27.232690+00:00 / `associative-gaps-20261023-icarus13.json`。
  失敗 0、既知不一致 23、未対応 0、未実行 3862、古い証跡 4、違法系の判定根拠未承認 0 行。
- `verilator` / Verilator 5.052 2026-09-05 rev vUNKNOWN-built20260905: 8/12319 (0.06%)。
  計測元: 2026-10-22T21:57:41.445007+00:00 / `associative-gaps-20261023-verilator-seed1.json`。
  失敗 0、既知不一致 15、未対応 0、未実行 3862、古い証跡 4、違法系の判定根拠未承認 0 行。
- `verilator` / Verilator 5.052 2026-09-05 rev vUNKNOWN-built20260905: 8/12319 (0.06%)。
  計測元: 2026-10-22T21:57:41.445004+00:00 / `associative-gaps-20261023-verilator-seed73.json`。
  失敗 0、既知不一致 15、未対応 0、未実行 3862、古い証跡 4、違法系の判定根拠未承認 0 行。
- `icarus` / Icarus Verilog version 13.0 (stable) (v13_0-dirty): 0/12319 (0.00%)。
  計測元: 2026-10-22T21:44:20.971033+00:00 / `associative-matching-20261023-icarus13.json`。
  失敗 0、既知不一致 36、未対応 0、未実行 3853、古い証跡 0、違法系の判定根拠未承認 0 行。
- `verilator` / Verilator 5.052 2026-09-05 rev vUNKNOWN-built20260905: 28/12319 (0.23%)。
  計測元: 2026-10-22T21:44:56.002490+00:00 / `associative-matching-20261023-verilator.json`。
  失敗 0、既知不一致 8、未対応 0、未実行 3853、古い証跡 0、違法系の判定根拠未承認 0 行。
- `icarus` / Icarus Verilog version 13.0 (stable) (v13_0-dirty): 0/12319 (0.00%)。
  計測元: 2026-10-22T22:00:52.942221+00:00 / `associative-wildcard-refinement-20261023-icarus13.json`。
  失敗 0、既知不一致 2、未対応 0、未実行 3887、古い証跡 0、違法系の判定根拠未承認 0 行。
- `verilator` / Verilator 5.052 2026-09-05 rev vUNKNOWN-built20260905: 2/12319 (0.02%)。
  計測元: 2026-10-22T22:00:56.310380+00:00 / `associative-wildcard-refinement-20261023-verilator-seed1.json`。
  失敗 0、既知不一致 0、未対応 0、未実行 3887、古い証跡 0、違法系の判定根拠未承認 0 行。
- `verilator` / Verilator 5.052 2026-09-05 rev vUNKNOWN-built20260905: 2/12319 (0.02%)。
  計測元: 2026-10-22T22:00:56.305806+00:00 / `associative-wildcard-refinement-20261023-verilator-seed73.json`。
  失敗 0、既知不一致 0、未対応 0、未実行 3887、古い証跡 0、違法系の判定根拠未承認 0 行。
- `icarus` / Icarus Verilog version 13.0 (stable) (v13_0-dirty): 11/12319 (0.09%)。
  計測元: 2026-10-22T14:29:24.878016+00:00 / `citation-refinement-icarus.json`。
  失敗 0、既知不一致 12、未対応 0、未実行 3866、古い証跡 0、違法系の判定根拠未承認 0 行。
- `verilator` / Verilator 5.052 2026-09-05 rev vUNKNOWN-built20260905: 18/12319 (0.15%)。
  計測元: 2026-10-22T14:29:34.097194+00:00 / `citation-refinement-verilator.json`。
  失敗 0、既知不一致 5、未対応 0、未実行 3866、古い証跡 0、違法系の判定根拠未承認 0 行。
- `icarus` / Icarus Verilog version 13.0 (stable) (v13_0-dirty): 25/12319 (0.20%)。
  計測元: 2026-10-22T16:53:43.771888+00:00 / `expression-gaps-20261023-icarus13.json`。
  失敗 0、既知不一致 10、未対応 0、未実行 3854、古い証跡 0、違法系の判定根拠未承認 0 行。
- `verilator` / Verilator 5.052 2026-09-05 rev vUNKNOWN-built20260905: 34/12319 (0.28%)。
  計測元: 2026-10-22T16:53:54.690416+00:00 / `expression-gaps-20261023-verilator-seed1.json`。
  失敗 0、既知不一致 1、未対応 0、未実行 3854、古い証跡 0、違法系の判定根拠未承認 0 行。
- `verilator` / Verilator 5.052 2026-09-05 rev vUNKNOWN-built20260905: 34/12319 (0.28%)。
  計測元: 2026-10-22T16:53:54.696860+00:00 / `expression-gaps-20261023-verilator-seed73.json`。
  失敗 0、既知不一致 1、未対応 0、未実行 3854、古い証跡 0、違法系の判定根拠未承認 0 行。
- `icarus` / Icarus Verilog version 13.0 (stable) (v13_0-dirty): 1/12319 (0.01%)。
  計測元: 2026-10-23T14:32:27.916089+00:00 / `header-vpi-tests-20261023-icarus13.json`。
  失敗 0、既知不一致 1273、未対応 0、未実行 2615、古い証跡 0、違法系の判定根拠未承認 0 行。
- `verilator` / Verilator 5.052 2026-09-05 rev vUNKNOWN-built20260905: 989/12319 (8.03%)。
  計測元: 2026-10-23T14:32:29.367284+00:00 / `header-vpi-tests-20261023-verilator-seed1.json`。
  失敗 0、既知不一致 285、未対応 0、未実行 2615、古い証跡 0、違法系の判定根拠未承認 0 行。
- `verilator` / Verilator 5.052 2026-09-05 rev vUNKNOWN-built20260905: 989/12319 (8.03%)。
  計測元: 2026-10-23T14:32:30.845293+00:00 / `header-vpi-tests-20261023-verilator-seed73.json`。
  失敗 0、既知不一致 285、未対応 0、未実行 2615、古い証跡 0、違法系の判定根拠未承認 0 行。
- `icarus` / Icarus Verilog version 13.0 (stable) (v13_0-dirty): 896/12319 (7.27%)。
  計測元: 2026-10-22T13:20:44.297997+00:00 / `icarus.json`。
  失敗 0、既知不一致 1637、未対応 0、未実行 1328、古い証跡 26、違法系の判定根拠未承認 2 行。
- `icarus` / Icarus Verilog version 14.0 (devel) (s20260301-411-gca6b8d376): 3/12319 (0.02%)。
  計測元: 2026-10-22T16:11:50.000804+00:00 / `subroutine-citation-refinement-20261023-icarus.json`。
  失敗 0、既知不一致 8、未対応 0、未実行 3878、古い証跡 0、違法系の判定根拠未承認 0 行。
- `icarus` / Icarus Verilog version 13.0 (stable) (v13_0-dirty): 3/12319 (0.02%)。
  計測元: 2026-10-22T16:20:14.156213+00:00 / `subroutine-citation-refinement-20261023-icarus13.json`。
  失敗 0、既知不一致 8、未対応 0、未実行 3878、古い証跡 0、違法系の判定根拠未承認 0 行。
- `verilator` / Verilator 5.052 2026-09-05 rev vUNKNOWN-built20260905: 10/12319 (0.08%)。
  計測元: 2026-10-22T16:11:54.837539+00:00 / `subroutine-citation-refinement-20261023-verilator.json`。
  失敗 0、既知不一致 2、未対応 0、未実行 3877、古い証跡 0、違法系の判定根拠未承認 0 行。
- `icarus` / Icarus Verilog version 13.0 (stable) (v13_0-dirty): 4/12319 (0.03%)。
  計測元: 2026-10-22T16:23:03.322408+00:00 / `subroutine-initialization-group-20261023-icarus13.json`。
  失敗 0、既知不一致 0、未対応 0、未実行 3885、古い証跡 0、違法系の判定根拠未承認 0 行。
- `verilator` / Verilator 5.052 2026-09-05 rev vUNKNOWN-built20260905: 867/12319 (7.04%)。
  計測元: 2026-10-22T14:02:31.540002+00:00 / `verilator.json`。
  失敗 0、既知不一致 1650、未対応 0、未実行 1328、古い証跡 31、違法系の判定根拠未承認 13 行。
- 不採用の結果ファイル: 0 件。

## 章・附属書別（登録項目に対する割合）

- 1 Overview: 設計 対象項目なし、実行 対象項目なし、解釈保留 0 行。
- 2 Normative references: 設計 0/2 (0.00%)、実行 0/2 (0.00%)、解釈保留 0 行。
- 3 Design and verification building blocks: 設計 13/146 (8.90%)、実行 12/146 (8.22%)、解釈保留 0 行。
- 4 Scheduling semantics: 設計 29/107 (27.10%)、実行 25/107 (23.36%)、解釈保留 0 行。
- 5 Lexical conventions: 設計 61/154 (39.61%)、実行 59/154 (38.31%)、解釈保留 0 行。
- 6 Data types: 設計 211/726 (29.06%)、実行 174/726 (23.97%)、解釈保留 0 行。
- 7 Aggregate data types: 設計 154/349 (44.13%)、実行 114/349 (32.66%)、解釈保留 0 行。
- 8 Classes: 設計 72/253 (28.46%)、実行 54/253 (21.34%)、解釈保留 0 行。
- 9 Processes: 設計 57/189 (30.16%)、実行 45/189 (23.81%)、解釈保留 2 行。
- 10 Assignment statements: 設計 46/156 (29.49%)、実行 32/156 (20.51%)、解釈保留 0 行。
- 11 Operators and expressions: 設計 235/461 (50.98%)、実行 231/461 (50.11%)、解釈保留 0 行。
- 12 Procedural programming statements: 設計 27/115 (23.48%)、実行 19/115 (16.52%)、解釈保留 0 行。
- 13 Tasks and functions (subroutines): 設計 37/121 (30.58%)、実行 33/121 (27.27%)、解釈保留 0 行。
- 14 Clocking blocks: 設計 24/87 (27.59%)、実行 18/87 (20.69%)、解釈保留 0 行。
- 15 Interprocess synchronization and communication: 設計 39/88 (44.32%)、実行 28/88 (31.82%)、解釈保留 0 行。
- 16 Assertions: 設計 80/555 (14.41%)、実行 10/555 (1.80%)、解釈保留 1 行。
- 17 Checkers: 設計 7/79 (8.86%)、実行 2/79 (2.53%)、解釈保留 0 行。
- 18 Constrained random value generation: 設計 49/320 (15.31%)、実行 32/320 (10.00%)、解釈保留 0 行。
- 19 Functional coverage: 設計 46/272 (16.91%)、実行 8/272 (2.94%)、解釈保留 2 行。
- 20 Utility system tasks and system functions: 設計 113/317 (35.65%)、実行 76/317 (23.97%)、解釈保留 1 行。
- 21 Input/output system tasks and system functions: 設計 82/384 (21.35%)、実行 67/384 (17.45%)、解釈保留 1 行。
- 22 Compiler directives: 設計 30/362 (8.29%)、実行 30/362 (8.29%)、解釈保留 0 行。
- 23 Modules and hierarchy: 設計 17/260 (6.54%)、実行 9/260 (3.46%)、解釈保留 0 行。
- 24 Programs: 設計 6/29 (20.69%)、実行 1/29 (3.45%)、解釈保留 0 行。
- 25 Interfaces: 設計 7/63 (11.11%)、実行 6/63 (9.52%)、解釈保留 2 行。
- 26 Packages: 設計 6/44 (13.64%)、実行 6/44 (13.64%)、解釈保留 0 行。
- 27 Generate constructs: 設計 5/32 (15.62%)、実行 2/32 (6.25%)、解釈保留 0 行。
- 28 Gate-level and switch-level modeling: 設計 99/384 (25.78%)、実行 92/384 (23.96%)、解釈保留 1 行。
- 29 User-defined primitives: 設計 16/52 (30.77%)、実行 15/52 (28.85%)、解釈保留 0 行。
- 30 Specify blocks: 設計 36/157 (22.93%)、実行 35/157 (22.29%)、解釈保留 0 行。
- 31 Timing checks: 設計 85/180 (47.22%)、実行 1/180 (0.56%)、解釈保留 1 行。
- 32 Backannotation using the standard delay format: 設計 22/131 (16.79%)、実行 14/131 (10.69%)、解釈保留 0 行。
- 33 Configuring the contents of a design: 設計 7/63 (11.11%)、実行 1/63 (1.59%)、解釈保留 2 行。
- 34 Protected envelopes: 設計 0/215 (0.00%)、実行 0/215 (0.00%)、解釈保留 1 行。
- 35 Direct programming interface: 設計 52/142 (36.62%)、実行 33/142 (23.24%)、解釈保留 0 行。
- 36 Programming language interface (PLI/VPI) overview: 設計 6/163 (3.68%)、実行 0/163 (0.00%)、解釈保留 0 行。
- 37 VPI object model diagrams: 設計 858/1757 (48.83%)、実行 46/1757 (2.62%)、解釈保留 1 行。
- 38 VPI routine definitions: 設計 63/348 (18.10%)、実行 37/348 (10.63%)、解釈保留 0 行。
- 39 Assertion API: 設計 46/95 (48.42%)、実行 0/95 (0.00%)、解釈保留 1 行。
- 40 Code coverage control and API: 設計 36/128 (28.12%)、実行 15/128 (11.72%)、解釈保留 0 行。
- 41 Data read API: 設計 対象項目なし、実行 対象項目なし、解釈保留 0 行。
- A Formal syntax: 設計 0/811 (0.00%)、実行 0/811 (0.00%)、解釈保留 2 行。
- B Keywords: 設計 0/248 (0.00%)、実行 0/248 (0.00%)、解釈保留 0 行。
- C Deprecation: 設計 0/20 (0.00%)、実行 0/20 (0.00%)、解釈保留 0 行。
- D Optional system tasks and system functions: 設計 対象項目なし、実行 対象項目なし、解釈保留 0 行。
- E Optional compiler directives: 設計 対象項目なし、実行 対象項目なし、解釈保留 0 行。
- F Formal semantics of concurrent assertions: 設計 0/253 (0.00%)、実行 0/253 (0.00%)、解釈保留 0 行。
- G Std package: 設計 0/32 (0.00%)、実行 0/32 (0.00%)、解釈保留 0 行。
- H DPI C layer: 設計 36/223 (16.14%)、実行 25/223 (11.21%)、解釈保留 1 行。
- I svdpi.h: 設計 77/147 (52.38%)、実行 77/147 (52.38%)、解釈保留 1 行。
- J Inclusion of foreign language code: 設計 0/16 (0.00%)、実行 0/16 (0.00%)、解釈保留 0 行。
- K vpi_user.h: 設計 508/544 (93.38%)、実行 507/544 (93.20%)、解釈保留 0 行。
- L vpi_compatibility.h: 設計 84/88 (95.45%)、実行 0/88 (0.00%)、解釈保留 0 行。
- M sv_vpi_user.h: 設計 405/412 (98.30%)、実行 405/412 (98.30%)、解釈保留 0 行。
- N Algorithm for probabilistic distribution functions: 設計 0/39 (0.00%)、実行 0/39 (0.00%)、解釈保留 1 行。
- O Encryption/decryption flow: 設計 対象項目なし、実行 対象項目なし、解釈保留 0 行。
- P Glossary: 設計 対象項目なし、実行 対象項目なし、解釈保留 0 行。
- Q Bibliography: 設計 対象項目なし、実行 対象項目なし、解釈保留 0 行。

## 分母と履歴

- 分母SHA-256: `574f40680b440c48af09b826e12eea6f459c9c16f41ae67b8a9a05fe3ab12d69`。
- 計測規則の版: 3。
- 履歴には分母の識別子、暫定値と確定値、環境別の状態内訳を保存します。
  分母が異なる回の割合を、そのまま改善・悪化として比較しません。
- この集計は保存済み実行証跡から再生成されます。上記の計測元時刻が実行時刻です。
