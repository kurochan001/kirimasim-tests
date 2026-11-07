<a id="ieee-1800-2023-requirement-coverage-aggregation"></a>

# IEEE 1800-2023 要求カバレッジ集計

[English](behavior-coverage-summary.en.md) / [日本語](behavior-coverage-summary.md)

[全項目の詳細](behavior-coverage.md) / [管理手順](https://github.com/kurochan001/kirimasim-tests/blob/3c3a5ab8cdb179aaa9d38d97990803dbc44f5cd6/coverage/README.md) / [解釈・再検討記録](https://github.com/kurochan001/kirimasim-tests/blob/3c3a5ab8cdb179aaa9d38d97990803dbc44f5cd6/docs/requirement-extraction-notes.md)

割合の分母は要求台帳の行で、テスト本数ではありません。[設計・実行・PASSの違い](https://github.com/kurochan001/kirimasim-tests/blob/3c3a5ab8cdb179aaa9d38d97990803dbc44f5cd6/docs/faq.md#q16-how-do-design-and-execution-coverage-differ)を具体例で確認できます。

<a id="value-for-all-standards-in-the-required-table"></a>

## 全規格の要求台帳に対する値

- 要求カバレッジ（テスト設計）: **89.28%** (10980/12298)。
- 実行確認率: **69.74%** (8577/12298)。複数環境の成功の和集合。
- 分母には解釈保留と未対応も含みます。未実装・未対応を除外していません。
- 登録単位は要求の出現箇所・条件・観測ケースであり、分母のレビューで意味の重複を統合しています。 全プログラム・全入力の組み合わせを試した割合や、単一シミュレータの規格適合率ではありません。

<a id="aggregation-of-existing-tests"></a>

## 既存テストの集計状況

- 全 11028 本のうち、要求との対応を登録済みのテストは 5309 本。未登録は 5719 本です。
- 上記の網羅率は、刺激と期待結果を確認して要求との対応を登録した分だけを計上しています。 未登録の既存テストも検証に役立ちますが、その貢献はまだ割合に反映できていません。
- 登録済み本数は少なくとも一つの要求との対応がある本数で、テスト全体のレビュー完了数ではありません。

- 複数テストで分担する要求は 652 行。各グループの全テストが同じ実行回で成功した場合だけ、要求全体の実行成功に数えます。

<a id="definite-value"></a>

## 確定値

- 要求カバレッジ（テスト設計）: 89.28%。
- 規格要求の実行確認率: 69.74%。
- 分母の承認: 承認済み。計測状態: `confirmed`。
- 資料確認、保留解釈の解決、要求単位の重複整理、分母のレビューを経て確定しました。

<a id="remains"></a>

## 残件

- 現行入力に対応するパス結果の記録あり: 8577 行。
- 対応済み・パス結果の記録なし: 2403 行。
- テスト対応未確認（解釈保留以外）: 1318 行。
- 解釈保留: 0 行。

未対応は、既存テストが存在しないという判定ではありません。

<a id="execution-confirmation-rate-by-simulator"></a>

## シミュレータ別の実行確認率

各行は独立した保存実行です。小範囲の実行で未実行が多い場合もあるため、[日時・版・対象範囲の読み方](https://github.com/kurochan001/kirimasim-tests/blob/3c3a5ab8cdb179aaa9d38d97990803dbc44f5cd6/docs/faq.md#q14-why-do-main-results-or-simulator-totals-differ)と計測元を確認してください。

- `ghost` / `private build 56cfd9e560f1`: 8212/12298 (66.78%)。 計測元: `2026-11-07T00:03:43.039120+00:00` / `ghost.json`。 失敗 1277、既知不一致 0、未対応 0、未実行 290、古い証跡 0、規格違反テストの判定根拠が未承認 1201 行。
- `icarus` / `Icarus Verilog version 14.0 (devel) (s20260301-854-g257f08d2)`: 2532/12298 (20.59%)。 計測元: `2026-11-06T23:49:59.502379+00:00` / `icarus.json`。 失敗 19、既知不一致 7104、未対応 0、未実行 290、古い証跡 0、規格違反テストの判定根拠が未承認 1035 行。
- `kirimasim` / `kirimasim 0.0.0 (commit b279f56275cd), built with GNU 13.3.0`: 2940/12298 (23.91%)。 計測元: `2026-11-06T23:58:08.485899+00:00` / `kirimasim.json`。 失敗 217、既知不一致 0、未対応 6274、未実行 290、古い証跡 0、規格違反テストの判定根拠が未承認 1259 行。
- `verilator` / `Verilator 5.055 devel rev v5.054-93-g9d9dd1c8`: 3697/12298 (30.06%)。 計測元: `2026-11-07T01:39:01.323364+00:00` / `verilator.json`。 失敗 19、既知不一致 6015、未対応 0、未実行 290、古い証跡 0、規格違反テストの判定根拠が未承認 959 行。
- 不採用の結果ファイル: 0 件。

<a id="by-chapter-and-appendix-percentage-of-registered-items"></a>

## 章・附属書別（登録項目に対する割合）

- 1 Overview: テスト対応 対象項目なし、実行確認 対象項目なし、解釈保留 0 行。
- 2 Normative references: テスト対応 0/2 (0.00%)、実行確認 0/2 (0.00%)、解釈保留 0 行。
- 3 Design and verification building blocks: テスト対応 118/146 (80.82%)、実行確認 101/146 (69.18%)、解釈保留 0 行。
- 4 Scheduling semantics: テスト対応 80/107 (74.77%)、実行確認 76/107 (71.03%)、解釈保留 0 行。
- 5 Lexical conventions: テスト対応 136/154 (88.31%)、実行確認 119/154 (77.27%)、解釈保留 0 行。
- 6 Data types: テスト対応 680/719 (94.58%)、実行確認 544/719 (75.66%)、解釈保留 0 行。
- 7 Aggregate data types: テスト対応 320/345 (92.75%)、実行確認 261/345 (75.65%)、解釈保留 0 行。
- 8 Classes: テスト対応 221/252 (87.70%)、実行確認 143/252 (56.75%)、解釈保留 0 行。
- 9 Processes: テスト対応 166/189 (87.83%)、実行確認 149/189 (78.84%)、解釈保留 0 行。
- 10 Assignment statements: テスト対応 130/156 (83.33%)、実行確認 94/156 (60.26%)、解釈保留 0 行。
- 11 Operators and expressions: テスト対応 433/459 (94.34%)、実行確認 382/459 (83.22%)、解釈保留 0 行。
- 12 Procedural programming statements: テスト対応 89/115 (77.39%)、実行確認 69/115 (60.00%)、解釈保留 0 行。
- 13 Tasks and functions (subroutines): テスト対応 92/119 (77.31%)、実行確認 62/119 (52.10%)、解釈保留 0 行。
- 14 Clocking blocks: テスト対応 59/87 (67.82%)、実行確認 53/87 (60.92%)、解釈保留 0 行。
- 15 Interprocess synchronization and communication: テスト対応 68/88 (77.27%)、実行確認 63/88 (71.59%)、解釈保留 0 行。
- 16 Assertions: テスト対応 539/555 (97.12%)、実行確認 372/555 (67.03%)、解釈保留 0 行。
- 17 Checkers: テスト対応 59/79 (74.68%)、実行確認 23/79 (29.11%)、解釈保留 0 行。
- 18 Constrained random value generation: テスト対応 300/320 (93.75%)、実行確認 230/320 (71.88%)、解釈保留 0 行。
- 19 Functional coverage: テスト対応 232/271 (85.61%)、実行確認 173/271 (63.84%)、解釈保留 0 行。
- 20 Utility system tasks and system functions: テスト対応 285/316 (90.19%)、実行確認 229/316 (72.47%)、解釈保留 0 行。
- 21 Input/output system tasks and system functions: テスト対応 347/383 (90.60%)、実行確認 333/383 (86.95%)、解釈保留 0 行。
- 22 Compiler directives: テスト対応 345/361 (95.57%)、実行確認 73/361 (20.22%)、解釈保留 0 行。
- 23 Modules and hierarchy: テスト対応 251/260 (96.54%)、実行確認 154/260 (59.23%)、解釈保留 0 行。
- 24 Programs: テスト対応 16/29 (55.17%)、実行確認 13/29 (44.83%)、解釈保留 0 行。
- 25 Interfaces: テスト対応 43/63 (68.25%)、実行確認 19/63 (30.16%)、解釈保留 0 行。
- 26 Packages: テスト対応 39/44 (88.64%)、実行確認 24/44 (54.55%)、解釈保留 0 行。
- 27 Generate constructs: テスト対応 27/32 (84.38%)、実行確認 14/32 (43.75%)、解釈保留 0 行。
- 28 Gate-level and switch-level modeling: テスト対応 363/384 (94.53%)、実行確認 353/384 (91.93%)、解釈保留 0 行。
- 29 User-defined primitives: テスト対応 49/52 (94.23%)、実行確認 34/52 (65.38%)、解釈保留 0 行。
- 30 Specify blocks: テスト対応 131/157 (83.44%)、実行確認 121/157 (77.07%)、解釈保留 0 行。
- 31 Timing checks: テスト対応 154/180 (85.56%)、実行確認 138/180 (76.67%)、解釈保留 0 行。
- 32 Backannotation using the standard delay format: テスト対応 119/131 (90.84%)、実行確認 80/131 (61.07%)、解釈保留 0 行。
- 33 Configuring the contents of a design: テスト対応 30/63 (47.62%)、実行確認 19/63 (30.16%)、解釈保留 0 行。
- 34 Protected envelopes: テスト対応 5/214 (2.34%)、実行確認 5/214 (2.34%)、解釈保留 0 行。
- 35 Direct programming interface: テスト対応 114/142 (80.28%)、実行確認 100/142 (70.42%)、解釈保留 0 行。
- 36 Programming language interface (PLI/VPI) overview: テスト対応 148/163 (90.80%)、実行確認 75/163 (46.01%)、解釈保留 0 行。
- 37 VPI object model diagrams: テスト対応 1656/1757 (94.25%)、実行確認 1436/1757 (81.73%)、解釈保留 0 行。
- 38 VPI routine definitions: テスト対応 260/348 (74.71%)、実行確認 253/348 (72.70%)、解釈保留 0 行。
- 39 Assertion API: テスト対応 82/95 (86.32%)、実行確認 81/95 (85.26%)、解釈保留 0 行。
- 40 Code coverage control and API: テスト対応 82/128 (64.06%)、実行確認 79/128 (61.72%)、解釈保留 0 行。
- 41 Data read API: テスト対応 対象項目なし、実行確認 対象項目なし、解釈保留 0 行。
- A Formal syntax: テスト対応 792/811 (97.66%)、実行確認 729/811 (89.89%)、解釈保留 0 行。
- B Keywords: テスト対応 248/248 (100.00%)、実行確認 0/248 (0.00%)、解釈保留 0 行。
- C Deprecation: テスト対応 9/20 (45.00%)、実行確認 9/20 (45.00%)、解釈保留 0 行。
- D Optional system tasks and system functions: テスト対応 対象項目なし、実行確認 対象項目なし、解釈保留 0 行。
- E Optional compiler directives: テスト対応 対象項目なし、実行確認 対象項目なし、解釈保留 0 行。
- F Formal semantics of concurrent assertions: テスト対応 253/253 (100.00%)、実行確認 0/253 (0.00%)、解釈保留 0 行。
- G Std package: テスト対応 25/32 (78.12%)、実行確認 25/32 (78.12%)、解釈保留 0 行。
- H DPI C layer: テスト対応 190/223 (85.20%)、実行確認 176/223 (78.92%)、解釈保留 0 行。
- I svdpi.h: テスト対応 133/147 (90.48%)、実行確認 115/147 (78.23%)、解釈保留 0 行。
- J Inclusion of foreign language code: テスト対応 0/16 (0.00%)、実行確認 0/16 (0.00%)、解釈保留 0 行。
- K vpi_user.h: テスト対応 541/544 (99.45%)、実行確認 540/544 (99.26%)、解釈保留 0 行。
- L vpi_compatibility.h: テスト対応 85/88 (96.59%)、実行確認 0/88 (0.00%)、解釈保留 0 行。
- M sv_vpi_user.h: テスト対応 407/412 (98.79%)、実行確認 407/412 (98.79%)、解釈保留 0 行。
- N Algorithm for probabilistic distribution functions: テスト対応 29/39 (74.36%)、実行確認 29/39 (74.36%)、解釈保留 0 行。
- O Encryption/decryption flow: テスト対応 対象項目なし、実行確認 対象項目なし、解釈保留 0 行。
- P Glossary: テスト対応 対象項目なし、実行確認 対象項目なし、解釈保留 0 行。
- Q Bibliography: テスト対応 対象項目なし、実行確認 対象項目なし、解釈保留 0 行。

<a id="denominator-and-history"></a>

## 分母と履歴

- 分母SHA-256: `8a8f350dfea82366808f80d1fa1f6cb8d6b488d7a9b3edf3092b79e1fc57e1da`。
- 計測規則の版: 3。
- 履歴には分母の識別子、暫定値と確定値、環境別の状態内訳を保存します。 分母が異なる回の割合を、そのまま改善・悪化として比較しません。
- この集計は保存済み実行証跡から再生成されます。上記の計測元時刻が実行時刻です。
