<a id="ieee-1800-2023-要求カバレッジ集計"></a>

# IEEE 1800-2023 requirement coverage aggregation

[English](behavior-coverage-summary.en.md) / [日本語](behavior-coverage-summary.md)

[Details of all items](behavior-coverage.en.md) / [Management procedures](https://github.com/kurochan001/kirimasim-tests/blob/19cd790a5f639348ad67fd63959dce9811d3ab56/coverage/README.en.md) / [Interpretation and Re-examination Record](https://github.com/kurochan001/kirimasim-tests/blob/19cd790a5f639348ad67fd63959dce9811d3ab56/docs/requirement-extraction-notes.en.md)

The denominator counts requirement-ledger rows, not test files. See [Design, execution and PASS distinctions](https://github.com/kurochan001/kirimasim-tests/blob/19cd790a5f639348ad67fd63959dce9811d3ab56/docs/faq.en.md#q16-how-do-design-and-execution-coverage-differ) for concrete examples.

<a id="全規格の要求台帳に対する値"></a>

## Value for all standards in the required table

- Requirement coverage (test design): 89.31% ( 10983/12298 ).
- The execution confirmation rate is 70.20% ( 8633/12298 ). Union of successes across environments.
- The denominator includes pending interpretations and items without test mappings. We do not exclude non-implemented and non-supported.
- The registration unit is the occurrence point, condition, and observation case of the requirement, and the duplication of meaning is integrated by the review of the denominator. This is neither the fraction of all program/input combinations tested nor a single simulator's standard conformance rate.

<a id="既存テストの集計状況"></a>

## Aggregation of existing tests

- 10778 of 5310 tests have registered the correspondance with the requirements. 5468 tests remain unregistered.
- The above coverage rate is calculated only for the part which registered the response to the demand by confirming the stimulus and the expected result. Existing tests that are not registered are also useful for verification, but their contribution is not yet reflected in the proportion.
- The number of registered units is the number of units that correspond to at least one requirement, not the number of completed reviews of the whole test.

- The requests that are shared by multiple tests are in the 652 row. Only if all tests in each group are successful in the same run, they count as a success for the entire request.

<a id="確定値"></a>

## Definite value

- Requirement coverage (test design): 89.31%.
- Requirement execution-confirmation rate: 70.20%.
- Approval of denominator: Approval. The measured state is `confirmed`.
- The method was confirmed after document verification, resolution of the reservation interpretation, duplication of the requirement unit, and review of the denominator.

<a id="残件"></a>

## Remains

- There is a record of the path result corresponding to the current input: 8633 line.
- No record of passed/passout results: 2350 line.
- Test compatibility not confirmed (except for interpretation reservation): 1315 line.
- Interpretation reservation: 0 line.

Unsupported behavior does not mean that no existing test is available.

<a id="シミュレータ別の実行確認率"></a>

## Execution confirmation rate by simulator

Each row is a separate saved run. A narrow run can leave many tests unexecuted; check [how to read dates, versions and scope](https://github.com/kurochan001/kirimasim-tests/blob/19cd790a5f639348ad67fd63959dce9811d3ab56/docs/faq.en.md#q14-why-do-main-results-or-simulator-totals-differ) and the measurement source.

- `ghost` / `private build 3314f9902a64` : 8187/12298 ( 66.57% )。 Measurement source: `2026-11-05T03:38:28.956402+00:00` / `ghost.json` 。 Failures 1305; known mismatches 0; unsupported 0; not run 290; stale evidence 0; unapproved judgment evidence for illegal-design tests 1201 rows.
- `icarus` / `Icarus Verilog version 14.0 (devel) (s20260301-812-g9f260501)` : 2526/12298 ( 20.54% )。 Measurement source: `2026-11-05T00:38:16.069296+00:00` / `icarus.json` 。 Failures 16; known mismatches 7109; unsupported 0; not run 290; stale evidence 0; unapproved judgment evidence for illegal-design tests 1042 rows.
- `kirimasim` / `kirimasim 0.0.0 (commit 50a897dee62a), built with GNU 13.3.0` : 2939/12298 ( 23.90% )。 Measurement source: `2026-11-05T03:26:40.741180+00:00` / `kirimasim.json` 。 Failures 221; known mismatches 0; unsupported 6274; not run 290; stale evidence 0; unapproved judgment evidence for illegal-design tests 1259 rows.
- `lyra` / `Lyra (commit ccfc8aa4fbd9)` : 3243/12298 ( 26.37% )。 Measurement source: `2026-11-05T04:44:28.598954+00:00` / `lyra.json` 。 Failures 1031; known mismatches 0; unsupported 5164; not run 290; stale evidence 0; unapproved judgment evidence for illegal-design tests 1255 rows.
- `verilator` / `Verilator 5.055 devel rev v5.054-63-g57bbb293` : 3696/12298 ( 30.05% )。 Measurement source: `2026-11-05T02:39:00.207229+00:00` / `verilator.json` 。 Failures 18; known mismatches 6019; unsupported 0; not run 290; stale evidence 0; unapproved judgment evidence for illegal-design tests 960 rows.
- The result file of the rejection: 0.

<a id="章附属書別登録項目に対する割合"></a>

## By chapter and appendix (percentage of registered items)

- 1 Overview: Testing support No object items, execution confirmation No object items, interpretation reserved 0 line.
- 2 Normative references: test compatible 0/2 ( 0.00% ), execution confirmation 0/2 ( 0.00% ), interpretation reserve 0.
- 3 Design and verification building blocks: test-ready 119/146 ( 81.51% ), execution-verification 102/146 ( 69.86% ), interpretation-retention 0 rows.
- 4 Scheduling semantics: test-ready 80/107 ( 74.77% ), execution-confirm 76/107 ( 71.03% ), interpretation-reserved 0 rows.
- 5 Lexical conventions: test compatible 136/154 ( 88.31% ), execution confirmation 119/154 ( 77.27% ), interpretation reserve 0 lines.
- 6 Data types: test-ready 680/719 ( 94.58% ), execution-confirm 554/719 ( 77.05% ), interpretation-reserved 0 rows.
- 7 Aggregate data types: test-ready 320/345 ( 92.75% ), execution-confirm 263/345 ( 76.23% ), interpretation-reserved 0 rows.
- 8 Classes: Test-compatible 221/252 ( 87.70% ), execution-confirm 143/252 ( 56.75% ), interpretation-reserved 0 rows.
- 9 Processes: Test-ready 166/189 ( 87.83% ), execution-confirm 149/189 ( 78.84% ), interpretation-reserved 0 rows.
- 10 Assignment statements: test-compliant 130/156 ( 83.33% ), execution-confirm 94/156 ( 60.26% ), interpretation-reserved 0 lines.
- 11 Operators and expressions: Test-compatible 433/459 ( 94.34% ), execution-confirm 392/459 ( 85.40% ), interpretation-reserved 0 rows.
- 12 Procedural programming statements: test-responsive 89/115 ( 77.39% ), execution-confirm 73/115 ( 63.48% ), interpretation-reserved 0 lines.
- 13 Tasks and functions (subroutines): Test support 92/119 ( 77.31% ), execution confirmation 62/119 ( 52.10% ), interpretation reserve 0.
- 14 Clocking blocks: test-ready 59/87 ( 67.82% ), execution-confirm 53/87 ( 60.92% ), interpretation-reserved 0 rows.
- 15 Interprocess synchronization and communication: test support 68/88 ( 77.27% ), execution confirmation 63/88 ( 71.59% ), interpretation reserve 0.
- 16 Assertions: Test-compliant 539/555 ( 97.12% ), execution-confirming 365/555 ( 65.77% ), interpretation-reserved 0 rows.
- 17 Checkers: Test-ready 59/79 ( 74.68% ), execution-ready 23/79 ( 29.11% ), interpretation-reserved 0 lines.
- 18 Constrained random value generation: test compatible 300/320 ( 93.75% ), execution confirmation 232/320 ( 72.50% ), interpretation reserve 0 rows.
- 19 Functional coverage: test compatible 232/271 ( 85.61% ), execution confirmation 180/271 ( 66.42% ), interpretation reserve 0 rows.
- 20 Utility system tasks and system functions: test support 285/316 ( 90.19% ), execution confirmation 232/316 ( 73.42% ), interpretation reserve 0.
- 21 Input/output system tasks and system functions: test support 347/383 ( 90.60% ), execution confirmation 333/383 ( 86.95% ), interpretation reserve 0.
- 22 Compiler directives: Test-ready 345/361 ( 95.57% ), execution-confirm 73/361 ( 20.22% ), interpretation-reserved 0 lines.
- 23 Modules and hierarchy: Test-ready 251/260 ( 96.54% ), execution-confirm 154/260 ( 59.23% ), interpretation-reserved 0 rows.
- 24 Programs: Test-ready 16/29 ( 55.17% ), execution-confirm 13/29 ( 44.83% ), interpretation-reserved 0 lines.
- 25 Interfaces: Test-ready 43/63 ( 68.25% ), execution-confirm 19/63 ( 30.16% ), interpretation-reserved 0 lines.
- 26 Packages: Test-ready 39/44 ( 88.64% ), execution-confirm 24/44 ( 54.55% ), interpretation-reserved 0 lines.
- 27 Generate constructs: test-compatible 27/32 ( 84.38% ), execution-confirm 14/32 ( 43.75% ), and interpret-reserve 0 rows.
- 28 Gate-level and switch-level modeling: test-ready 363/384 ( 94.53% ), execution-confirm 353/384 ( 91.93% ), interpretation-reserved 0 lines.
- 29 User-defined primitives: test-ready 49/52 ( 94.23% ), execution-confirm 34/52 ( 65.38% ), interpretation-reserved 0 rows.
- 30 Specify blocks: test-compatible 131/157 ( 83.44% ), execution-confirm 121/157 ( 77.07% ), interpretation-reserved 0 rows.
- 31 Timing checks: test-ready 154/180 ( 85.56% ), execution-confirm 138/180 ( 76.67% ), interpretation-reserved 0 lines.
- 32 Backannotation using the standard delay format: test-ready 119/131 ( 90.84% ), execution-confirm 80/131 ( 61.07% ), interpretation-reserved 0 lines.
- 33 Configuring the contents of a design: test-ready 30/63 ( 47.62% ), execution-confirm 19/63 ( 30.16% ), interpretation-reserved 0 lines.
- 34 Protected envelopes: test-ready 5/214 ( 2.34% ), execution-confirm 5/214 ( 2.34% ), interpretation-reserved 0 rows.
- 35 Direct programming interface: test compatible 115/142 ( 80.99% ), execution confirmation 104/142 ( 73.24% ), interpretation reserve 0 lines.
- 36 Programming language interface ( PLI / VPI ) overview: Test-ready 148/163 ( 90.80% ), execution-confirm 75/163 ( 46.01% ), interpretation-reserved 0 lines.
- 37 VPI object model diagrams: test-ready 1656/1757 ( 94.25% ), execution-confirm 1436/1757 ( 81.73% ), interpretation-reserved 0 rows.
- 38 VPI routine definitions: test-compatible 260/348 ( 74.71% ), execution-confirm 253/348 ( 72.70% ), interpretation-reserved 0 lines.
- 39 Assertion API: Test compatible 82/95 ( 86.32% ), execution confirmation 81/95 ( 85.26% ), interpretation reserve 0 rows.
- 40 Code coverage control and API: test support 82/128 ( 64.06% ), execution confirmation 79/128 ( 61.72% ), interpretation reserve 0.
- 41 Data read API : Test compatible No object items, execution confirmed No object items, interpretation reserved 0 line.
- A Formal syntax: test support 793/811 ( 97.78% ), execution confirmation 733/811 ( 90.38% ), interpretation reserve 0 lines.
- B Keywords: Test compatible 248/248 ( 100.00% ), execution confirmation 0/248 ( 0.00% ), interpretation reserve 0.
- C Deprecation: Test-compatible 9/20 ( 45.00% ), execution-confirm 9/20 ( 45.00% ), interpretation-reserved 0 lines.
- D Optional system tasks and system functions: Test support No object items, execution verification No object items, interpretation reserved 0 line.
- E Optional compiler directives: Test support No object items, execution verification No object items, interpretation reserved 0 line.
- F Formal semantics of concurrent assertions: test compatible 253/253 ( 100.00% ), execution confirmation 0/253 ( 0.00% ), interpretation reserve 0 rows.
- G Std package: test compatible 25/32 ( 78.12% ), execution confirmation 25/32 ( 78.12% ), interpretation reserve 0 lines.
- H DPI C layer: test compatible 190/223 ( 85.20% ), execution confirmation 177/223 ( 79.37% ), interpretation reserve 0 rows.
- I svdpi.h: test mappings 133/147 (90.48%), execution verification 130/147 (88.44%), interpretation on hold for 0 rows.
- J Inclusion of foreign language code: test compatible 0/16 ( 0.00% ), execution confirmation 0/16 ( 0.00% ), interpretation reserve 0 lines.
- K vpi_user.h: test mappings 541/544 (99.45%), execution verification 540/544 (99.26%), interpretation on hold for 0 rows.
- L vpi_compatibility.h: test mappings 85/88 (96.59%), execution verification 0/88 (0.00%), interpretation on hold for 0 rows.
- M sv_vpi_user.h: test mappings 407/412 (98.79%), execution verification 407/412 (98.79%), interpretation on hold for 0 rows.
- N Algorithm for probabilistic distribution functions: test compatible 29/39 ( 74.36% ), execution confirmation 29/39 ( 74.36% ), interpretation reserve 0 rows.
- O Encryption/decryption flow: Test support No object items, execution confirmation No object items, interpretation reserved 0 line.
- P Glossary: Testing support No object items, execution confirmation No object items, interpretation reserved 0 line.
- Q Bibliography: Test compatible No object items, execution confirmation No object items, interpretation reserved 0 line.

<a id="分母と履歴"></a>

## Denominator and history

- The denominator is SHA-256 : `8a8f350dfea82366808f80d1fa1f6cb8d6b488d7a9b3edf3092b79e1fc57e1da`.
- Version of the measurement rule: 3.
- The history stores the identifier of the denominator, the provisional and definitive values, and the state summary by environment. The ratio of the rounds with different denominators is not compared as improvement or deterioration.
- This aggregation is re-generated from the saved execution trace. The above time of measurement is the time of execution.
