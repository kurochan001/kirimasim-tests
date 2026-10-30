# カバレッジギャップ調査と追加テスト候補（2026-10-29）

対象: スイート **7,744本**、分母 **12,298行**。Issue #6–#19 の修正、本調査に基づく2本の追加テスト、FSTテスト2本の追加後、2026-10-29 時点の集計です。
FSTの2本は要求との対応を未登録のため、要求対応・実行確認の件数は変わりません。[追加範囲](fst-tests-20261029.md)を参照してください。
以降の件数とツール対応は、この調査時点の記録です。現在の値は[集計概要](behavior-coverage-summary.md)と[条項別テスト数](coverage-depth.md)を参照してください。

## 結論

- 条項別テスト数の集計対象である **1,010末端節** は、すべて2本以上のテストに直接引用されています。本文3〜40章の対象節に対する本数の下限を満たしたという意味で、対象外の節・附属書や各節の全要求を網羅したという意味ではありません。
- 優先順位は、**未対応行のうちテスト可能なクラスタ**、**対応済みだがパス結果の記録がない行**、**標準のみの期待値しかない節への別ツール・参照モデルによる裏付け**の順です。
- 新規テストの前に `behavior_coverage.py --candidates <clause>` で既存テストを確認するのが最も費用対効果が高いです。当初の6候補のうち5つは既存テストが観測済みだったため、新規作成ではなくリンクで対応しました。
- 実際に新規追加したのは、既存テストで観測していなかった attribute namespace と combined-file compilation unit の2本です。

## 1. 現在の指標

| 指標 | 値 |
|---|---:|
| 登録行（分母） | 12,298 |
| 要求対応 | 10,986 |
| 未対応 | 1,312 |
| 実行確認 | 7,330 |
| 対応済み・パス結果の記録なし | 3,656 |
| 標準のみのテストしかない節 | 201 |
| テスト2本以下の節 | 120 |
| テスト1本だけの節 | 0 |
| 既存テストの未登録 | 2,434 / 7,744 |

## 2. 章別の内訳

| 章 | 合計 | 対応 | 未対応 | 対応済み・証跡なし | 実行確認 |
|---:|---:|---:|---:|---:|---:|
| 2 Normative references | 2 | 0 | 2 | 0 | 0 |
| 3 Design and verification building blocks | 146 | 119 | 27 | 7 | 112 |
| 4 Scheduling semantics | 107 | 80 | 27 | 16 | 64 |
| 5 Lexical conventions | 154 | 136 | 18 | 8 | 128 |
| 6 Data types | 719 | 680 | 39 | 91 | 589 |
| 7 Aggregate data types | 345 | 320 | 25 | 91 | 229 |
| 8 Classes | 252 | 221 | 31 | 49 | 172 |
| 9 Processes | 189 | 166 | 23 | 42 | 124 |
| 10 Assignment statements | 156 | 130 | 26 | 20 | 110 |
| 11 Operators and expressions | 459 | 433 | 26 | 64 | 369 |
| 12 Procedural programming statements | 115 | 89 | 26 | 14 | 75 |
| 13 Tasks and functions (subroutines) | 119 | 92 | 27 | 15 | 77 |
| 14 Clocking blocks | 87 | 59 | 28 | 11 | 48 |
| 15 Interprocess synchronization and communication | 88 | 68 | 20 | 16 | 52 |
| 16 Assertions | 555 | 539 | 16 | 325 | 214 |
| 17 Checkers | 79 | 59 | 20 | 38 | 21 |
| 18 Constrained random value generation | 320 | 300 | 20 | 134 | 166 |
| 19 Functional coverage | 271 | 232 | 39 | 185 | 47 |
| 20 Utility system tasks and system functions | 316 | 285 | 31 | 94 | 191 |
| 21 Input/output system tasks and system functions | 383 | 347 | 36 | 109 | 238 |
| 22 Compiler directives | 361 | 345 | 16 | 9 | 336 |
| 23 Modules and hierarchy | 260 | 251 | 9 | 98 | 153 |
| 24 Programs | 29 | 16 | 13 | 4 | 12 |
| 25 Interfaces | 63 | 43 | 20 | 15 | 28 |
| 26 Packages | 44 | 39 | 5 | 5 | 34 |
| 27 Generate constructs | 32 | 27 | 5 | 4 | 23 |
| 28 Gate-level and switch-level modeling | 384 | 363 | 21 | 75 | 288 |
| 29 User-defined primitives | 52 | 49 | 3 | 6 | 43 |
| 30 Specify blocks | 157 | 131 | 26 | 23 | 108 |
| 31 Timing checks | 180 | 154 | 26 | 67 | 87 |
| 32 Backannotation using the standard delay format | 131 | 119 | 12 | 46 | 73 |
| 33 Configuring the contents of a design | 63 | 30 | 33 | 11 | 19 |
| 34 Protected envelopes | 214 | 5 | 209 | 0 | 5 |
| 35 Direct programming interface | 142 | 115 | 27 | 22 | 93 |
| 36 Programming language interface (PLI/VPI) overview | 163 | 148 | 15 | 96 | 52 |
| 37 VPI object model diagrams | 1,757 | 1,658 | 99 | 1,385 | 273 |
| 38 VPI routine definitions | 348 | 260 | 88 | 107 | 153 |
| 39 Assertion API | 95 | 82 | 13 | 25 | 57 |
| 40 Code coverage control and API | 128 | 82 | 46 | 5 | 77 |
| A Formal syntax | 811 | 793 | 18 | 178 | 615 |
| B Keywords | 248 | 248 | 0 | 0 | 248 |
| C Deprecation | 20 | 9 | 11 | 1 | 8 |
| F Formal semantics of concurrent assertions | 253 | 253 | 0 | 0 | 253 |
| G Std package | 32 | 25 | 7 | 2 | 23 |
| H DPI C layer | 223 | 190 | 33 | 35 | 155 |
| I svdpi.h | 147 | 134 | 13 | 22 | 112 |
| J Inclusion of foreign language code | 16 | 0 | 16 | 0 | 0 |
| K vpi_user.h | 544 | 541 | 3 | 1 | 540 |
| L vpi_compatibility.h | 88 | 85 | 3 | 85 | 0 |
| M sv_vpi_user.h | 412 | 407 | 5 | 0 | 407 |
| N Algorithm for probabilistic distribution functions | 39 | 29 | 10 | 0 | 29 |
| **合計** | **12,298** | **10,986** | **1,312** | **3,656** | **7,330** |

## 3. 対応済みだがパス結果の記録がない節（上位25）

| 節 | 合計 | 対応 | 証跡なし | 実行 |
|---|---:|---:|---:|---:|
| 37.16 Nets | 119 | 113 | 108 | 5 |
| L.2 Source code | 87 | 85 | 85 | 0 |
| 20.11 Assertion control system tasks | 92 | 92 | 74 | 18 |
| 37.85 Generates | 79 | 77 | 73 | 4 |
| 37.17 Variables | 115 | 110 | 69 | 41 |
| 37.25 Typespec | 75 | 74 | 66 | 8 |
| 23.3.3.7 Port connections with dissimilar net types (net and port collapsing) | 85 | 85 | 59 | 26 |
| 37.10 Instance | 83 | 75 | 59 | 16 |
| 37.12 Scope | 63 | 62 | 56 | 6 |
| 36.12.1 VPI Incompatibilities with other standard versions | 59 | 52 | 52 | 0 |
| 37.83 Attribute | 53 | 43 | 43 | 0 |
| 37.52 Property specification | 42 | 41 | 40 | 1 |
| 18.5.12 Constraint guards | 46 | 46 | 38 | 8 |
| 28.7 MOS switches | 37 | 37 | 34 | 3 |
| 37.42 Task and function call | 40 | 39 | 34 | 5 |
| 37.59 Expressions | 35 | 34 | 34 | 0 |
| 16.14.8 Nonvacuous evaluations | 36 | 36 | 33 | 3 |
| 37.32 Class typespec | 36 | 34 | 33 | 1 |
| 37.5 Module | 44 | 44 | 31 | 13 |
| 37.60 Atomic statement | 30 | 30 | 30 | 0 |
| 19.7 Specifying coverage options | 50 | 39 | 29 | 10 |
| 37.35 Primitive, prim term | 29 | 28 | 28 | 0 |
| A.2.11 Covergroup declarations | 29 | 29 | 28 | 1 |
| 37.28 Parameter, spec param, def param, param assign | 34 | 34 | 27 | 7 |
| 37.41 Task and function declaration | 29 | 27 | 27 | 0 |

## 4. 未対応の多い節（上位25）

| 節 | 合計 | 対応 | 未対応 | 実行 |
|---|---:|---:|---:|---:|
| 34.4 Protect pragma directives | 36 | 1 | 35 | 1 |
| 34.5.11.2 Description | 21 | 0 | 21 | 0 |
| 38.36.1 Simulation event callbacks | 40 | 23 | 17 | 9 |
| I.3 Source code | 145 | 132 | 13 | 110 |
| H.14.2 svdpi.h definitions for SV3.1a-style packed data processing | 16 | 4 | 12 | 4 |
| 19.7 Specifying coverage options | 50 | 39 | 11 | 10 |
| 34.5.9.2 Description | 11 | 0 | 11 | 0 |
| 31.9.1 Requirements for accurate simulation | 10 | 0 | 10 | 0 |
| 37.45 Delay terminals | 10 | 0 | 10 | 0 |
| 37.83 Attribute | 53 | 43 | 10 | 0 |
| J.4 Object code inclusion | 9 | 0 | 9 | 0 |
| 19.7.1 Covergroup type options | 32 | 24 | 8 | 5 |
| 32.4.4 SDF annotation of interconnect delays | 13 | 5 | 8 | 1 |
| 33.3.1 Specifying libraries—the library map file | 9 | 1 | 8 | 1 |
| 34.5.21.2 Description | 8 | 0 | 8 | 0 |
| 37.10 Instance | 83 | 75 | 8 | 16 |
| N.2 Source code | 30 | 22 | 8 | 22 |
| 12.4.2.1 Violation reports generated by unique-if, unique0-if, and priority-if constructs | 7 | 0 | 7 | 0 |
| 13.4 Functions | 13 | 6 | 7 | 6 |
| 17.7.2 Checker variable randomization with assumptions | 14 | 7 | 7 | 1 |
| 20.10.1 Elaboration severity system tasks | 7 | 0 | 7 | 0 |
| 21.7.2.3 Description of keyword commands | 20 | 13 | 7 | 12 |
| 36.12.1 VPI Incompatibilities with other standard versions | 59 | 52 | 7 | 0 |
| 38.16 vpi_get_value_array() | 19 | 12 | 7 | 10 |
| 3.12.1 Compilation units | 21 | 15 | 6 | 14 |

## 5. 当初の追加候補と照合結果

| 候補 | 節 | 当初の狙い | 結果 |
|---|---:|---|---|
| `ch20/test_assertion_control_tasks.sv` | 20.11 | control type 0–11、mask、counter | 既存の `test_assertcontrol_*` が多数あり、counter 不変は `test_assertcontrol_callbacks_system` が観測済み。**リンクで対応** |
| `ch23/test_port_net_collapsing.sv` | 23.3.3.7 | tri0/tri1/supply の collapsing | 既存の `test_port_collapse_internal_tri0_tri1` / `..._supply` が同じ型の4セルを観測済み。**リンクで対応** |
| `ch28/test_bufif_notif_truth_tables.sv` | 28.6 | bufif/notif の真理値表 | 未対応行は0。既存テストが観測済みで、不足は実行証跡。**新規テスト不要** |
| `ch28/test_mos_switch_strengths.sv` | 28.7 | MOS の真理値表・strength | 未対応行は0。既存テストが観測済みで、不足は実行証跡。**新規テスト不要** |
| `ch18/test_constraint_guards.sv` | 18.5.12 | guard の 0/1/E/R 論理 | 未対応行は0。既存テストが観測済みで、不足は実行証跡。**新規テスト不要** |
| `ch19/test_coverage_option_levels.sv` | 19.7 / 19.7.1 | option / type_option の許可レベル | 未対応行の多くは「禁止レベル」で、正常系テストでは観測できない。台帳の kind も normal のため、illegal へ再分類するか解釈保留にするかの判断が必要。**保留** |

### 5.1 既存テストへのリンク

- `test_port_collapse_internal_tri0_tri1.sv` → `COLLAPSE-4-4`（tri0/tri0）、`COLLAPSE-5-5`（tri1/tri1）
- `test_port_collapse_internal_supply.sv` → `COLLAPSE-7-7`（supply0/supply0）、`COLLAPSE-8-8`（supply1/supply1）
- `test_assertcontrol_callbacks_system.sv` → `COUNTERS-UNAFFECTED`

### 5.2 新規に追加したテスト

| テスト | 節 | 内容 | 検証 |
|---|---:|---|---|
| `tests/ch3/test_attribute_namespace.sv` | 3.13 | 同じ属性名 marker を module / variable / net に付け、名前衝突せず `x=2` になることを確認 | Icarus 13.0 / Verilator 5.052 ともに pass |
| `tests/ch3/test_compilation_unit_shared_across_files.sv` | 3.12.1 | 2ファイルを同じコマンドラインでコンパイルし、一方の `$unit` 変数と関数が他方から見えて `unit=42` になることを確認 | Icarus 13.0 / Verilator 5.052 ともに pass |

| 指標 | 追加前 | 追加後 |
|---|---:|---:|
| 要求対応 | 10,984 | **10,986** |
| 未対応 | 1,314 | **1,312** |
| 実行確認 | 7,328 | **7,330** |
| テスト対応率 | 89.32% | **89.33%** |
| 実行確認率 | 59.59% | **59.60%** |

追加した2本は `coverage/results/coverage-tests-20261029-icarus13.json` と `...-verilator.json` に実行証跡を記録しています。

## 6. 次に新規テストを追加するなら

未対応行が残り、かつ正常系のシミュレーションで観測できそうな節です。3.12.1 / 3.13 は2本追加済みで、残りは namespace の他の規則です。

| 節 | 未対応 | 追加するテストの例 | 想定ツール |
|---|---:|---|---|
| 3.12.1 / 3.13 | 12 | 残る namespace 規則、PLI unit iterator | Icarus / Verilator（PLI は要確認） |
| 13.4 / 13.4.1 | 12 | void / implicit call、return type range、未使用戻り値 | Icarus / Verilator |
| N.2 | 8 | `$dist_*` の seed 更新、範囲、引数検証 | 要確認 |
| 32.4.4 | 8 | SDF interconnect annotation | Icarus |
| 33.3.1 | 8 | library map file、path 解決 | 要確認 |
| 12.4.2.1 | 7 | unique / priority の violation report と flush | Icarus / Verilator |
| 20.10.1 | 7 | elaboration severity、generate 条件 | Icarus / Verilator |
| 14.16 / 14.14 | 11 | synchronous drive、global clocking | 要確認 |
| 10.8 | 6 | assignment-like context の伝播 | Icarus / Verilator |
| 8.29 | 5 | class object の new/delete、weak reference | Verilator |

## 7. 新規テストより証跡を優先するクラスタ

| 章 | 対応済み・証跡なし | 対応方針 |
|---|---:|---|
| 37 VPI object model diagrams | 1,385 | 既存テストを章単位でレビューし、pinned simulator の期待値を記録 |
| 16 Assertions | 325 | 既存テストを章単位でレビューし、pinned simulator の期待値を記録 |
| 19 Functional coverage | 185 | 既存テストを章単位でレビューし、pinned simulator の期待値を記録 |
| A Formal syntax | 178 | 既存テストを章単位でレビューし、pinned simulator の期待値を記録 |
| 38 VPI routine definitions | 107 | 既存テストを章単位でレビューし、pinned simulator の期待値を記録 |
| 21 Input/output system tasks and system functions | 109 | 既存テストを章単位でレビューし、pinned simulator の期待値を記録 |
| 23 Modules and hierarchy | 98 | 既存テストを章単位でレビューし、pinned simulator の期待値を記録 |
| 36 Programming language interface (PLI/VPI) overview | 96 | 既存テストを章単位でレビューし、pinned simulator の期待値を記録 |
| 20 Utility system tasks and system functions | 94 | 既存テストを章単位でレビューし、pinned simulator の期待値を記録 |
| 6 Data types | 91 | 既存テストを章単位でレビューし、pinned simulator の期待値を記録 |
| 7 Aggregate data types | 91 | 既存テストを章単位でレビューし、pinned simulator の期待値を記録 |
| 31 Timing checks | 67 | 既存テストを章単位でレビューし、pinned simulator の期待値を記録 |
| 11 Operators and expressions | 64 | 既存テストを章単位でレビューし、pinned simulator の期待値を記録 |
| 8 Classes | 49 | 既存テストを章単位でレビューし、pinned simulator の期待値を記録 |
| 32 Backannotation using the standard delay format | 46 | 既存テストを章単位でレビューし、pinned simulator の期待値を記録 |
| 9 Processes | 42 | 既存テストを章単位でレビューし、pinned simulator の期待値を記録 |
| 17 Checkers | 38 | 既存テストを章単位でレビューし、pinned simulator の期待値を記録 |
| H DPI C layer | 35 | 既存テストを章単位でレビューし、pinned simulator の期待値を記録 |

## 8. 追加しない方がよい領域

| 領域 | 未対応/証跡なし | 理由 |
|---|---:|---|
| 34章 保護エンベロープ | 209 未対応 | Icarus は pragma を無視、Verilator は base64 を読み捨てる |
| 40章 coverage API | 46 未対応 | 対象ツールの実装・観測機能に制約がある。章全体の未実装を意味しない |
| 37/38章 VPI | 187 未対応 | Icarus のオブジェクトモデルが狭い |
| H/35章 DPI | 60 前後 | `svdpi_src.h` 不在、deprecated DPI 未実装 |
| 31章 timing check | 26 未対応 | Icarus 非対応、Verilator は specify を無視 |
| 19章 covergroup | 39 未対応 | Icarus は構文エラー。Verilator 5.052にはビン・オプション・カバレッジ計算の規格との差異が残る（[差異一覧](simulator-differences.md#verilator-5052)） |

## 9. 再現

```sh
python3 tools/behavior_coverage.py --check --require-source-reviewed
python3 tools/behavior_coverage.py --candidates 20.11
python3 tools/behavior_coverage.py --candidates 23.3.3.7
python3 tools/requirement_matching.py --check
python3 tools/suite_stats.py --check
python3 tools/coverage_depth.py --check --minimum-tests 2
```

## 10. 限界

- 数値は 2026-10-29 時点の保存済み証跡に基づきます。Ghost の証跡は変更したテストについて一部 stale です。
- 「未対応」はテストが存在しないという意味ではなく、要求との対応が未登録という意味です。
- 対象ツールでは実行確認が難しい領域（34/40/37/38/31/Hなど）は、未対応機能と観測上の制約を明記します。これは仕様上の検証不能を意味しません。対応ツールや独立した参照モデルが利用できる場合は、検証方法を再検討します。
- 追加候補の simulator 対応は、実行して `unsupported` かどうかを確認してから確定してください。

