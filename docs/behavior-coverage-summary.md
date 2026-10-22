# IEEE 1800-2023 動作カバレッジ集計

[全項目の詳細](behavior-coverage.md) / [管理手順](../coverage/README.md) / [解釈保留の根拠](../docs/requirement-extraction-notes.md)

## 全規格の要求台帳に対する暫定値

- テスト設計網羅率: **6.58%** (810/12319)。
- 実行確認率: **5.83%** (718/12319)。複数環境の成功の和集合。
- 分母には解釈保留と未対応も含みます。未実装・未対応を除外していません。
- 登録単位は要求の出現箇所・条件・初期の観測ケースであり、意味の重複整理前の暫定値です。
  全プログラム・全入力の組み合わせを試した割合や、単一シミュレータの規格適合率ではありません。

## 既存テストの集計状況

- 全 3938 本のうち、要求との対応を登録済みのテストは 975 本。未登録は 2963 本です。
- 上記の網羅率は、刺激と期待結果を確認して要求との対応を登録した分だけを計上しています。
  未登録の既存テストも検証に役立ちますが、その貢献はまだ割合に反映できていません。
- 登録済み本数は少なくとも一つの要求との対応がある本数で、テスト全体のレビュー完了数ではありません。

- 複数テストで分担する要求は 50 行。各グループの全テストが同じ実行回で成功した場合だけ、要求全体の実行成功に数えます。

## 確定値

- 規格全動作のテスト設計網羅率: 未確定。
- 規格全動作の実行確認率: 未確定。
- 分母の承認: 未承認。計測状態: `provisional`。
- 資料確認、保留解釈の解決、要求単位の重複整理、分母のレビューを経て確定します。

## 残件

- 新鮮な成功証跡あり: 718 行。
- 対応済み・成功証跡なし: 92 行。
- テスト対応未確認（解釈保留以外）: 11460 行。
- 解釈保留: 49 行。

未対応は、既存テストが存在しないという判定ではありません。

## シミュレータ別の実行確認率

- `icarus` / Icarus Verilog version 13.0 (stable) (v13_0-dirty): 0/12319 (0.00%)。
  計測元: 2026-10-22T22:03:58.531565+00:00 / `associative-count-refinement-20261023-icarus13.json`。
  失敗 0、既知不一致 2、未対応 0、未実行 808、古い証跡 0、違法系の判定根拠未承認 0 行。
- `verilator` / Verilator 5.052 2026-09-05 rev vUNKNOWN-built20260905: 2/12319 (0.02%)。
  計測元: 2026-10-22T22:04:02.952792+00:00 / `associative-count-refinement-20261023-verilator-seed1.json`。
  失敗 0、既知不一致 0、未対応 0、未実行 808、古い証跡 0、違法系の判定根拠未承認 0 行。
- `verilator` / Verilator 5.052 2026-09-05 rev vUNKNOWN-built20260905: 2/12319 (0.02%)。
  計測元: 2026-10-22T22:04:02.961719+00:00 / `associative-count-refinement-20261023-verilator-seed73.json`。
  失敗 0、既知不一致 0、未対応 0、未実行 808、古い証跡 0、違法系の判定根拠未承認 0 行。
- `icarus` / Icarus Verilog version 13.0 (stable) (v13_0-dirty): 0/12319 (0.00%)。
  計測元: 2026-10-22T21:57:27.232690+00:00 / `associative-gaps-20261023-icarus13.json`。
  失敗 0、既知不一致 23、未対応 0、未実行 783、古い証跡 4、違法系の判定根拠未承認 0 行。
- `verilator` / Verilator 5.052 2026-09-05 rev vUNKNOWN-built20260905: 8/12319 (0.06%)。
  計測元: 2026-10-22T21:57:41.445007+00:00 / `associative-gaps-20261023-verilator-seed1.json`。
  失敗 0、既知不一致 15、未対応 0、未実行 783、古い証跡 4、違法系の判定根拠未承認 0 行。
- `verilator` / Verilator 5.052 2026-09-05 rev vUNKNOWN-built20260905: 8/12319 (0.06%)。
  計測元: 2026-10-22T21:57:41.445004+00:00 / `associative-gaps-20261023-verilator-seed73.json`。
  失敗 0、既知不一致 15、未対応 0、未実行 783、古い証跡 4、違法系の判定根拠未承認 0 行。
- `icarus` / Icarus Verilog version 13.0 (stable) (v13_0-dirty): 0/12319 (0.00%)。
  計測元: 2026-10-22T21:44:20.971033+00:00 / `associative-matching-20261023-icarus13.json`。
  失敗 0、既知不一致 33、未対応 0、未実行 777、古い証跡 0、違法系の判定根拠未承認 0 行。
- `verilator` / Verilator 5.052 2026-09-05 rev vUNKNOWN-built20260905: 25/12319 (0.20%)。
  計測元: 2026-10-22T21:44:56.002490+00:00 / `associative-matching-20261023-verilator.json`。
  失敗 0、既知不一致 8、未対応 0、未実行 777、古い証跡 0、違法系の判定根拠未承認 0 行。
- `icarus` / Icarus Verilog version 13.0 (stable) (v13_0-dirty): 0/12319 (0.00%)。
  計測元: 2026-10-22T22:00:52.942221+00:00 / `associative-wildcard-refinement-20261023-icarus13.json`。
  失敗 0、既知不一致 2、未対応 0、未実行 808、古い証跡 0、違法系の判定根拠未承認 0 行。
- `verilator` / Verilator 5.052 2026-09-05 rev vUNKNOWN-built20260905: 2/12319 (0.02%)。
  計測元: 2026-10-22T22:00:56.310380+00:00 / `associative-wildcard-refinement-20261023-verilator-seed1.json`。
  失敗 0、既知不一致 0、未対応 0、未実行 808、古い証跡 0、違法系の判定根拠未承認 0 行。
- `verilator` / Verilator 5.052 2026-09-05 rev vUNKNOWN-built20260905: 2/12319 (0.02%)。
  計測元: 2026-10-22T22:00:56.305806+00:00 / `associative-wildcard-refinement-20261023-verilator-seed73.json`。
  失敗 0、既知不一致 0、未対応 0、未実行 808、古い証跡 0、違法系の判定根拠未承認 0 行。
- `icarus` / Icarus Verilog version 13.0 (stable) (v13_0-dirty): 11/12319 (0.09%)。
  計測元: 2026-10-22T14:29:24.878016+00:00 / `citation-refinement-icarus.json`。
  失敗 0、既知不一致 10、未対応 0、未実行 789、古い証跡 0、違法系の判定根拠未承認 0 行。
- `verilator` / Verilator 5.052 2026-09-05 rev vUNKNOWN-built20260905: 16/12319 (0.13%)。
  計測元: 2026-10-22T14:29:34.097194+00:00 / `citation-refinement-verilator.json`。
  失敗 0、既知不一致 5、未対応 0、未実行 789、古い証跡 0、違法系の判定根拠未承認 0 行。
- `icarus` / Icarus Verilog version 13.0 (stable) (v13_0-dirty): 25/12319 (0.20%)。
  計測元: 2026-10-22T16:53:43.771888+00:00 / `expression-gaps-20261023-icarus13.json`。
  失敗 0、既知不一致 9、未対応 0、未実行 776、古い証跡 0、違法系の判定根拠未承認 0 行。
- `verilator` / Verilator 5.052 2026-09-05 rev vUNKNOWN-built20260905: 33/12319 (0.27%)。
  計測元: 2026-10-22T16:53:54.690416+00:00 / `expression-gaps-20261023-verilator-seed1.json`。
  失敗 0、既知不一致 1、未対応 0、未実行 776、古い証跡 0、違法系の判定根拠未承認 0 行。
- `verilator` / Verilator 5.052 2026-09-05 rev vUNKNOWN-built20260905: 33/12319 (0.27%)。
  計測元: 2026-10-22T16:53:54.696860+00:00 / `expression-gaps-20261023-verilator-seed73.json`。
  失敗 0、既知不一致 1、未対応 0、未実行 776、古い証跡 0、違法系の判定根拠未承認 0 行。
- `icarus` / Icarus Verilog version 13.0 (stable) (v13_0-dirty): 488/12319 (3.96%)。
  計測元: 2026-10-22T13:20:44.297997+00:00 / `icarus.json`。
  失敗 0、既知不一致 246、未対応 0、未実行 53、古い証跡 23、違法系の判定根拠未承認 0 行。
- `icarus` / Icarus Verilog version 14.0 (devel) (s20260301-411-gca6b8d376): 3/12319 (0.02%)。
  計測元: 2026-10-22T16:11:50.000804+00:00 / `subroutine-citation-refinement-20261023-icarus.json`。
  失敗 0、既知不一致 7、未対応 0、未実行 800、古い証跡 0、違法系の判定根拠未承認 0 行。
- `icarus` / Icarus Verilog version 13.0 (stable) (v13_0-dirty): 3/12319 (0.02%)。
  計測元: 2026-10-22T16:20:14.156213+00:00 / `subroutine-citation-refinement-20261023-icarus13.json`。
  失敗 0、既知不一致 7、未対応 0、未実行 800、古い証跡 0、違法系の判定根拠未承認 0 行。
- `verilator` / Verilator 5.052 2026-09-05 rev vUNKNOWN-built20260905: 9/12319 (0.07%)。
  計測元: 2026-10-22T16:11:54.837539+00:00 / `subroutine-citation-refinement-20261023-verilator.json`。
  失敗 0、既知不一致 2、未対応 0、未実行 799、古い証跡 0、違法系の判定根拠未承認 0 行。
- `icarus` / Icarus Verilog version 13.0 (stable) (v13_0-dirty): 4/12319 (0.03%)。
  計測元: 2026-10-22T16:23:03.322408+00:00 / `subroutine-initialization-group-20261023-icarus13.json`。
  失敗 0、既知不一致 0、未対応 0、未実行 806、古い証跡 0、違法系の判定根拠未承認 0 行。
- `verilator` / Verilator 5.052 2026-09-05 rev vUNKNOWN-built20260905: 459/12319 (3.73%)。
  計測元: 2026-10-22T14:02:31.540002+00:00 / `verilator.json`。
  失敗 0、既知不一致 261、未対応 0、未実行 53、古い証跡 27、違法系の判定根拠未承認 10 行。
- 不採用の結果ファイル: 0 件。

## 章・附属書別（登録項目に対する割合）

- 1 Overview: 設計 対象項目なし、実行 対象項目なし、解釈保留 0 行。
- 2 Normative references: 設計 0/2 (0.00%)、実行 0/2 (0.00%)、解釈保留 0 行。
- 3 Design and verification building blocks: 設計 6/146 (4.11%)、実行 6/146 (4.11%)、解釈保留 0 行。
- 4 Scheduling semantics: 設計 12/107 (11.21%)、実行 10/107 (9.35%)、解釈保留 0 行。
- 5 Lexical conventions: 設計 4/154 (2.60%)、実行 4/154 (2.60%)、解釈保留 0 行。
- 6 Data types: 設計 96/726 (13.22%)、実行 92/726 (12.67%)、解釈保留 0 行。
- 7 Aggregate data types: 設計 120/349 (34.38%)、実行 91/349 (26.07%)、解釈保留 0 行。
- 8 Classes: 設計 36/253 (14.23%)、実行 36/253 (14.23%)、解釈保留 0 行。
- 9 Processes: 設計 42/189 (22.22%)、実行 37/189 (19.58%)、解釈保留 2 行。
- 10 Assignment statements: 設計 42/156 (26.92%)、実行 29/156 (18.59%)、解釈保留 0 行。
- 11 Operators and expressions: 設計 190/461 (41.21%)、実行 188/461 (40.78%)、解釈保留 1 行。
- 12 Procedural programming statements: 設計 27/115 (23.48%)、実行 19/115 (16.52%)、解釈保留 0 行。
- 13 Tasks and functions (subroutines): 設計 28/121 (23.14%)、実行 25/121 (20.66%)、解釈保留 0 行。
- 14 Clocking blocks: 設計 0/87 (0.00%)、実行 0/87 (0.00%)、解釈保留 0 行。
- 15 Interprocess synchronization and communication: 設計 36/88 (40.91%)、実行 27/88 (30.68%)、解釈保留 0 行。
- 16 Assertions: 設計 0/555 (0.00%)、実行 0/555 (0.00%)、解釈保留 1 行。
- 17 Checkers: 設計 0/79 (0.00%)、実行 0/79 (0.00%)、解釈保留 0 行。
- 18 Constrained random value generation: 設計 0/320 (0.00%)、実行 0/320 (0.00%)、解釈保留 0 行。
- 19 Functional coverage: 設計 0/272 (0.00%)、実行 0/272 (0.00%)、解釈保留 4 行。
- 20 Utility system tasks and system functions: 設計 66/317 (20.82%)、実行 55/317 (17.35%)、解釈保留 1 行。
- 21 Input/output system tasks and system functions: 設計 11/384 (2.86%)、実行 11/384 (2.86%)、解釈保留 1 行。
- 22 Compiler directives: 設計 30/362 (8.29%)、実行 30/362 (8.29%)、解釈保留 0 行。
- 23 Modules and hierarchy: 設計 3/260 (1.15%)、実行 2/260 (0.77%)、解釈保留 0 行。
- 24 Programs: 設計 1/29 (3.45%)、実行 0/29 (0.00%)、解釈保留 0 行。
- 25 Interfaces: 設計 0/63 (0.00%)、実行 0/63 (0.00%)、解釈保留 2 行。
- 26 Packages: 設計 2/44 (4.55%)、実行 2/44 (4.55%)、解釈保留 0 行。
- 27 Generate constructs: 設計 3/32 (9.38%)、実行 1/32 (3.12%)、解釈保留 1 行。
- 28 Gate-level and switch-level modeling: 設計 54/384 (14.06%)、実行 52/384 (13.54%)、解釈保留 1 行。
- 29 User-defined primitives: 設計 1/52 (1.92%)、実行 1/52 (1.92%)、解釈保留 0 行。
- 30 Specify blocks: 設計 0/157 (0.00%)、実行 0/157 (0.00%)、解釈保留 0 行。
- 31 Timing checks: 設計 0/180 (0.00%)、実行 0/180 (0.00%)、解釈保留 2 行。
- 32 Backannotation using the standard delay format: 設計 0/131 (0.00%)、実行 0/131 (0.00%)、解釈保留 0 行。
- 33 Configuring the contents of a design: 設計 0/63 (0.00%)、実行 0/63 (0.00%)、解釈保留 2 行。
- 34 Protected envelopes: 設計 0/215 (0.00%)、実行 0/215 (0.00%)、解釈保留 4 行。
- 35 Direct programming interface: 設計 0/142 (0.00%)、実行 0/142 (0.00%)、解釈保留 0 行。
- 36 Programming language interface (PLI/VPI) overview: 設計 0/163 (0.00%)、実行 0/163 (0.00%)、解釈保留 0 行。
- 37 VPI object model diagrams: 設計 0/1757 (0.00%)、実行 0/1757 (0.00%)、解釈保留 3 行。
- 38 VPI routine definitions: 設計 0/348 (0.00%)、実行 0/348 (0.00%)、解釈保留 4 行。
- 39 Assertion API: 設計 0/95 (0.00%)、実行 0/95 (0.00%)、解釈保留 3 行。
- 40 Code coverage control and API: 設計 0/128 (0.00%)、実行 0/128 (0.00%)、解釈保留 4 行。
- 41 Data read API: 設計 対象項目なし、実行 対象項目なし、解釈保留 0 行。
- A Formal syntax: 設計 0/811 (0.00%)、実行 0/811 (0.00%)、解釈保留 2 行。
- B Keywords: 設計 0/248 (0.00%)、実行 0/248 (0.00%)、解釈保留 0 行。
- C Deprecation: 設計 0/20 (0.00%)、実行 0/20 (0.00%)、解釈保留 0 行。
- D Optional system tasks and system functions: 設計 対象項目なし、実行 対象項目なし、解釈保留 0 行。
- E Optional compiler directives: 設計 対象項目なし、実行 対象項目なし、解釈保留 0 行。
- F Formal semantics of concurrent assertions: 設計 0/253 (0.00%)、実行 0/253 (0.00%)、解釈保留 7 行。
- G Std package: 設計 0/32 (0.00%)、実行 0/32 (0.00%)、解釈保留 0 行。
- H DPI C layer: 設計 0/223 (0.00%)、実行 0/223 (0.00%)、解釈保留 1 行。
- I svdpi.h: 設計 0/147 (0.00%)、実行 0/147 (0.00%)、解釈保留 2 行。
- J Inclusion of foreign language code: 設計 0/16 (0.00%)、実行 0/16 (0.00%)、解釈保留 0 行。
- K vpi_user.h: 設計 0/544 (0.00%)、実行 0/544 (0.00%)、解釈保留 0 行。
- L vpi_compatibility.h: 設計 0/88 (0.00%)、実行 0/88 (0.00%)、解釈保留 0 行。
- M sv_vpi_user.h: 設計 0/412 (0.00%)、実行 0/412 (0.00%)、解釈保留 0 行。
- N Algorithm for probabilistic distribution functions: 設計 0/39 (0.00%)、実行 0/39 (0.00%)、解釈保留 1 行。
- O Encryption/decryption flow: 設計 対象項目なし、実行 対象項目なし、解釈保留 0 行。
- P Glossary: 設計 対象項目なし、実行 対象項目なし、解釈保留 0 行。
- Q Bibliography: 設計 対象項目なし、実行 対象項目なし、解釈保留 0 行。

## 分母と履歴

- 分母SHA-256: `d9e94724b317c8668673f4f4883c4923bf94caad46d79ba7c79e1fd16302e6ac`。
- 計測規則の版: 3。
- 履歴には分母の識別子、暫定値と確定値、環境別の状態内訳を保存します。
  分母が異なる回の割合を、そのまま改善・悪化として比較しません。
- この集計は保存済み実行証跡から再生成されます。上記の計測元時刻が実行時刻です。
