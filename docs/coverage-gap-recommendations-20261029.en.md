<a id="カバレッジギャップ調査と追加テスト候補2026-10-29"></a>

# Coverage gap investigation and additional test candidate (2026-10-29)

[English](coverage-gap-recommendations-20261029.en.md) / [日本語](coverage-gap-recommendations-20261029.md)

Scope: Suite: 7,744 tests; denominator: 12,298 rows. Counts are as of 2026-10-29, after fixes for Issues #6–#19, 2 tests added from this investigation, and 2 FST tests. The 2 tests in FST have no registered requirement mappings, so requirement-mapping and verified-execution counts are unchanged. See [Added scope](fst-tests-20261029.md). Subsequent counts and tool-support descriptions record the state at this investigation. For current values, see [Summary of the aggregate](behavior-coverage-summary.en.md) and [Tests per clause](coverage-depth.md).

See [Introduction Guide](interaction-verification.en.md) and [Saved-run summary](interaction-verification.en.md#保存実行の概要) for subsequent cross-feature additions. Unmapped requirements in this investigation and unsupported interaction-run cases have different denominators and meanings.

<a id="結論"></a>

## Conclusion

- Every one of the 1,010 leaf clauses counted in per-clause test statistics is directly cited by at least 2 tests. This means the minimum test count was met for the target main-text clauses in Chapters 3–40; it does not mean all requirements in every clause, excluded clauses, or annexes are covered.
- Priority is given to clusters of unmatched rows that can be tested, rows that have been matched but have no record of the pass result, and rows that have only standard expected values and are validated by other tools or reference models.
- Checking existing tests with `behavior_coverage.py --candidates <clause>` before adding new ones is the most cost-effective approach. Of the original 6 candidates, 5 were already observed by existing tests, so mapped them through links rather than creating new tests.
- Actually added 2 new tests for attribute namespaces and combined-file compilation units, which existing tests did not observe.

<a id="1-現在の指標"></a>

## 1. Current metrics

|Metric|Value|
|---|---:|
|Register line (denominator)| 12,298 |
|Requirement mappings| 10,986 |
|Unsupported| 1,312 |
|Execution verification| 7,330 |
|Mapped, no recorded passes| 3,656 |
|Clauses with only standard-only tests| 201 |
|Clauses with at most 2 tests| 120 |
|Clauses with only 1 tests| 0 |
|Unregistered existing tests| 2,434 / 7,744 |

<a id="2-章別の内訳"></a>

## 2. Per-chapter breakdown

|Chapter|Total|Mapping|Unsupported|Mapped, no evidence|Execution verification|
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
|Total| **12,298** | **10,986** | **1,312** | **3,656** | **7,330** |

<a id="3-対応済みだがパス結果の記録がない節上位25"></a>

## 3. Section has been handled but no record of pass result (top 25)

|Clause|Total|Mapping|No evidence|Execution|
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

<a id="4-未対応の多い節上位25"></a>

## 4. Many unmatched sections (top 25).

|Clause|Total|Mapping|Unsupported|Execution|
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

<a id="5-当初の追加候補と照合結果"></a>

## 5. Initial candidates and matching results

|Candidate|Clause|Original objective|Result|
|---|---:|---|---|
| `ch20/test_assertion_control_tasks.sv` | 20.11 | control type 0–11、mask、counter |Many existing `test_assertcontrol_*` tests exist; `test_assertcontrol_callbacks_system` already observes unchanged counters. Mapped through links|
| `ch23/test_port_net_collapsing.sv` | 23.3.3.7 |tri0 / tri1 /supply collapsing|The existing `test_port_collapse_internal_tri0_tri1` / `..._supply` has already been observed in 4 cells of the same type. Mapped through links|
| `ch28/test_bufif_notif_truth_tables.sv` | 28.6 |bufif/notif truth tables|Unmapped rows: 0. Existing tests already observe the behavior; execution evidence is missing. No new test needed|
| `ch28/test_mos_switch_strengths.sv` | 28.7 |MOS truth table and strengths|Unmapped rows: 0. Existing tests already observe the behavior; execution evidence is missing. No new test needed|
| `ch18/test_constraint_guards.sv` | 18.5.12 |Guard 0/1/E/R logic|Unmapped rows: 0. Existing tests already observe the behavior; execution evidence is missing. No new test needed|
| `ch19/test_coverage_option_levels.sv` | 19.7 / 19.7.1 |option / type_option permission level|Many unmapped rows concern prohibitions and cannot be observed by positive tests. The ledger kind is also normal, so a decision is needed between reclassifying as illegal and leaving the interpretation pending. Pending|

<a id="51-既存テストへのリンク"></a>

### 5.1 Link to existing test

- `test_port_collapse_internal_tri0_tri1.sv` → `COLLAPSE-4-4`（tri0/tri0）、`COLLAPSE-5-5`（tri1/tri1）
- `test_port_collapse_internal_supply.sv` → `COLLAPSE-7-7`（supply0/supply0）、`COLLAPSE-8-8`（supply1/supply1）
- `test_assertcontrol_callbacks_system.sv` → `COUNTERS-UNAFFECTED`

<a id="52-新規に追加したテスト"></a>

### 5.2 newly added tests

|Test|Clause|Content|Verification|
|---|---:|---|---|
| `tests/ch3/test_attribute_namespace.sv` | 3.13 |Apply the same attribute name marker to a module, variable, and net; verify `x=2` without name conflicts|Both Icarus 13.0 and Verilator 5.052 pass|
| `tests/ch3/test_compilation_unit_shared_across_files.sv` | 3.12.1 |Compile 2 files on the same command line and verify that one file's `$unit` variable and function are visible from the other, producing `unit=42`|Both Icarus 13.0 and Verilator 5.052 pass|

|Metric|Before Adding|After addition|
|---|---:|---:|
|Requirement mappings| 10,984 | **10,986** |
|Unsupported| 1,314 | **1,312** |
|Execution verification| 7,328 | **7,330** |
|Test mapping rate| 89.32% | **89.33%** |
|Execution verification coverage| 59.59% | **59.60%** |

Execution evidence for the 2 added tests is recorded in `coverage/results/coverage-tests-20261029-icarus13.json` and `...-verilator.json`.

<a id="6-次に新規テストを追加するなら"></a>

## 6. Where to add new tests next

These clauses have remaining unsupported rows and appear observable in positive simulations. 2 tests for 3.12.1 / 3.13 have been added; the remaining scope concerns other namespace rules.

|Clause|Unsupported|Examples of tests to add|Intended tools|
|---|---:|---|---|
| 3.12.1 / 3.13 | 12 |Remaining namespace rules, PLI unit iterator|Icarus / Verilator (PLI requires confirmation)|
| 13.4 / 13.4.1 | 12 |void / implicit call, return type range, unused return value| Icarus / Verilator |
| N.2 | 8 |`$dist_*` seed updates, ranges, and argument validation|Needs confirmation|
| 32.4.4 | 8 | SDF interconnect annotation | Icarus |
| 33.3.1 | 8 |Library map files and path resolution|Needs confirmation|
| 12.4.2.1 | 7 |unique / priority violation reporting and flushing| Icarus / Verilator |
| 20.10.1 | 7 |Elaboration severity and generate conditions| Icarus / Verilator |
| 14.16 / 14.14 | 11 | synchronous drive、global clocking |Needs confirmation|
| 10.8 | 6 |Propagation of assignment-like context| Icarus / Verilator |
| 8.29 | 5 |Class-object new/delete and weak references| Verilator |

<a id="7-新規テストより証跡を優先するクラスタ"></a>

## 7. Cluster that prioritizes evidence over new tests

|Chapter|Mapped, no evidence|Mapping policy|
|---|---:|---|
| 37 VPI object model diagrams | 1,385 |Review existing tests by chapter and record expected values for pinned simulators|
| 16 Assertions | 325 |Review existing tests by chapter and record expected values for pinned simulators|
| 19 Functional coverage | 185 |Review existing tests by chapter and record expected values for pinned simulators|
| A Formal syntax | 178 |Review existing tests by chapter and record expected values for pinned simulators|
| 38 VPI routine definitions | 107 |Review existing tests by chapter and record expected values for pinned simulators|
| 21 Input/output system tasks and system functions | 109 |Review existing tests by chapter and record expected values for pinned simulators|
| 23 Modules and hierarchy | 98 |Review existing tests by chapter and record expected values for pinned simulators|
| 36 Programming language interface (PLI/VPI) overview | 96 |Review existing tests by chapter and record expected values for pinned simulators|
| 20 Utility system tasks and system functions | 94 |Review existing tests by chapter and record expected values for pinned simulators|
| 6 Data types | 91 |Review existing tests by chapter and record expected values for pinned simulators|
| 7 Aggregate data types | 91 |Review existing tests by chapter and record expected values for pinned simulators|
| 31 Timing checks | 67 |Review existing tests by chapter and record expected values for pinned simulators|
| 11 Operators and expressions | 64 |Review existing tests by chapter and record expected values for pinned simulators|
| 8 Classes | 49 |Review existing tests by chapter and record expected values for pinned simulators|
| 32 Backannotation using the standard delay format | 46 |Review existing tests by chapter and record expected values for pinned simulators|
| 9 Processes | 42 |Review existing tests by chapter and record expected values for pinned simulators|
| 17 Checkers | 38 |Review existing tests by chapter and record expected values for pinned simulators|
| H DPI C layer | 35 |Review existing tests by chapter and record expected values for pinned simulators|

<a id="8-追加しない方がよい領域"></a>

## 8. Areas where additions are not recommended

|Domain|Unmapped / no evidence|Reason|
|---|---:|---|
|Clause 34: protected envelopes|209 Not supported|Icarus ignores pragma, Verilator discards base64|
|Chapter 40 coverage API|46 Not supported|Target tools have implementation/observation limitations. Does not mean the entire chapter is unimplemented|
|Chapter 37/38 VPI|187 Not supported|Icarus exposes a limited object model|
|H / Chapter 35 DPI|Before/after 60|`svdpi_src.h` absent; deprecated DPI unimplemented|
|Chapter 31 timing checks|26 Not supported|Icarus unsupported; Verilator ignores specify|
|Chapter 19 covergroup|39 Not supported|Icarus is a syntax error. Verilator 5.052 retains differences from the standard in bins, options, and coverage calculation ([Simulator differences](simulator-differences.md#verilator-5052))|

<a id="9-再現"></a>

## 9. Reproduction

```sh
python3 tools/behavior_coverage.py --check --require-source-reviewed
python3 tools/behavior_coverage.py --candidates 20.11
python3 tools/behavior_coverage.py --candidates 23.3.3.7
python3 tools/requirement_matching.py --check
python3 tools/suite_stats.py --check
python3 tools/coverage_depth.py --check --minimum-tests 2
```

<a id="10-限界"></a>

## 10. Limits

- Figures are based on saved evidence as of 2026-10-29. Some Ghost evidence is stale for modified tests.
- “Unmapped” means no registered requirement mapping, not absence of tests.
- For areas difficult to verify by execution on target tools (such as 34/40/37/38/31/H), state unsupported features and observation limits explicitly. This does not mean verification is impossible under the specification. If a corresponding tool or independent reference model is available, the verification method is reconsidered.
- Confirm simulator support for additions by executing them and checking for `unsupported` before finalizing.
