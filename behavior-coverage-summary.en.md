<a id="ieee-1800-2023-要求カバレッジ集計"></a>

# IEEE 1800-2023 requirement coverage aggregation

[English](behavior-coverage-summary.en.md) / [日本語](behavior-coverage-summary.md)

[Details of all items](behavior-coverage.en.md) / [Management procedures](https://github.com/kurochan001/kirimasim-tests/blob/9eab9bf2f4316112651e9637bcb03fe555016b95/coverage/README.en.md) / [Interpretation and Re-examination Record](https://github.com/kurochan001/kirimasim-tests/blob/9eab9bf2f4316112651e9637bcb03fe555016b95/docs/requirement-extraction-notes.en.md)

The denominator counts requirement-ledger rows, not test files. See [Design, execution and PASS distinctions](https://github.com/kurochan001/kirimasim-tests/blob/9eab9bf2f4316112651e9637bcb03fe555016b95/docs/faq.en.md#q16-how-do-design-and-execution-coverage-differ) for concrete examples.

<a id="全規格の要求台帳に対する値"></a>

## Value for all standards in the required table

- Requirement coverage (test design): 89.27% ( 10979/12298 ).
- The execution confirmation rate is 72.74% ( 8946/12298 ). Union of successes across environments.
- Execution confirmation rate without Ghost: 42.01% ( 5166/12298 ). Union of successes on Icarus Verilog, Verilator and SymbiYosys, which third parties can reproduce.
- The denominator includes pending interpretations and items without test mappings. We do not exclude non-implemented and non-supported.
- The registration unit is the occurrence point, condition, and observation case of the requirement, and the duplication of meaning is integrated by the review of the denominator. This is neither the fraction of all program/input combinations tested nor a single simulator's standard conformance rate.

<a id="既存テストの集計状況"></a>

## Aggregation of existing tests

- 12165 of 5308 tests have registered the correspondance with the requirements. 6857 tests remain unregistered.
- The above coverage rate is calculated only for the part which registered the response to the demand by confirming the stimulus and the expected result. Existing tests that are not registered are also useful for verification, but their contribution is not yet reflected in the proportion.
- The number of registered units is the number of units that correspond to at least one requirement, not the number of completed reviews of the whole test.

- The requests that are shared by multiple tests are in the 652 row. Only if all tests in each group are successful in the same run, they count as a success for the entire request.

<a id="確定値"></a>

## Definite value

- Requirement coverage (test design): 89.27%.
- Requirement execution-confirmation rate: 72.74%.
- Approval of denominator: Approval. The measured state is `confirmed`.
- The method was confirmed after document verification, resolution of the reservation interpretation, duplication of the requirement unit, and review of the denominator.

<a id="残件"></a>

## Remains

- There is a record of the path result corresponding to the current input: 8946 line.
- No record of passed/passout results: 2033 line.
- Test compatibility not confirmed (except for interpretation reservation): 1319 line.
- Interpretation reservation: 0 line.

Unsupported behavior does not mean that no existing test is available.

<a id="シミュレータ別の実行確認率"></a>

## Execution confirmation rate by simulator

Each row is a separate saved run. A narrow run can leave many tests unexecuted; check [how to read dates, versions and scope](https://github.com/kurochan001/kirimasim-tests/blob/9eab9bf2f4316112651e9637bcb03fe555016b95/docs/faq.en.md#q14-why-do-main-results-or-simulator-totals-differ) and the measurement source.

- `ghost` / `private build b0ba803c6b49` : 8877/12298 ( 72.18% )。 Measurement source: `2026-11-09T01:43:03.440369+00:00` / `ghost.json` 。 Failures 613; known mismatches 0; unsupported 0; not run 290; stale evidence 0; unapproved judgment evidence for illegal-design tests 1199 rows.
- `icarus` / `Icarus Verilog version 14.0 (devel) (s20260301-918-g3e2189b3)` : 2541/12298 ( 20.66% )。 Measurement source: `2026-11-09T01:49:08.172785+00:00` / `icarus.json` 。 Failures 21; known mismatches 7093; unsupported 0; not run 290; stale evidence 0; unapproved judgment evidence for illegal-design tests 1034 rows.
- `kirimasim` / `kirimasim 0.0.0 (commit 82b3003771e4), built with GNU 13.3.0` : 2968/12298 ( 24.13% )。 Measurement source: `2026-11-09T02:49:28.800560+00:00` / `kirimasim.json` 。 Failures 196; known mismatches 0; unsupported 6267; not run 290; stale evidence 0; unapproved judgment evidence for illegal-design tests 1258 rows.
- `verilator` / `Verilator 5.055 devel rev v5.054-158-g448e1ab6` : 3701/12298 ( 30.09% )。 Measurement source: `2026-11-09T03:22:56.654769+00:00` / `verilator.json` 。 Failures 23; known mismatches 6006; unsupported 0; not run 290; stale evidence 0; unapproved judgment evidence for illegal-design tests 959 rows.
- The result file of the rejection: 0.

<a id="章附属書別登録項目に対する割合"></a>

## By chapter and appendix (percentage of registered items)

- 1 Overview: test mapping no registered items, execution confirmed no registered items, execution confirmed without Ghost no registered items, interpretation pending 0 rows.
- 2 Normative references: test mapping 0/2 ( 0.00% ), execution confirmed 0/2 ( 0.00% ), execution confirmed without Ghost 0/2 ( 0.00% ), interpretation pending 0 rows.
- 3 Design and verification building blocks: test mapping 118/146 ( 80.82% ), execution confirmed 102/146 ( 69.86% ), execution confirmed without Ghost 98/146 ( 67.12% ), interpretation pending 0 rows.
- 4 Scheduling semantics: test mapping 80/107 ( 74.77% ), execution confirmed 80/107 ( 74.77% ), execution confirmed without Ghost 55/107 ( 51.40% ), interpretation pending 0 rows.
- 5 Lexical conventions: test mapping 136/154 ( 88.31% ), execution confirmed 119/154 ( 77.27% ), execution confirmed without Ghost 116/154 ( 75.32% ), interpretation pending 0 rows.
- 6 Data types: test mapping 679/719 ( 94.44% ), execution confirmed 540/719 ( 75.10% ), execution confirmed without Ghost 452/719 ( 62.87% ), interpretation pending 0 rows.
- 7 Aggregate data types: test mapping 320/345 ( 92.75% ), execution confirmed 261/345 ( 75.65% ), execution confirmed without Ghost 154/345 ( 44.64% ), interpretation pending 0 rows.
- 8 Classes: test mapping 221/252 ( 87.70% ), execution confirmed 143/252 ( 56.75% ), execution confirmed without Ghost 113/252 ( 44.84% ), interpretation pending 0 rows.
- 9 Processes: test mapping 166/189 ( 87.83% ), execution confirmed 149/189 ( 78.84% ), execution confirmed without Ghost 100/189 ( 52.91% ), interpretation pending 0 rows.
- 10 Assignment statements: test mapping 130/156 ( 83.33% ), execution confirmed 94/156 ( 60.26% ), execution confirmed without Ghost 54/156 ( 34.62% ), interpretation pending 0 rows.
- 11 Operators and expressions: test mapping 433/459 ( 94.34% ), execution confirmed 398/459 ( 86.71% ), execution confirmed without Ghost 344/459 ( 74.95% ), interpretation pending 0 rows.
- 12 Procedural programming statements: test mapping 89/115 ( 77.39% ), execution confirmed 74/115 ( 64.35% ), execution confirmed without Ghost 46/115 ( 40.00% ), interpretation pending 0 rows.
- 13 Tasks and functions (subroutines): test mapping 92/119 ( 77.31% ), execution confirmed 62/119 ( 52.10% ), execution confirmed without Ghost 55/119 ( 46.22% ), interpretation pending 0 rows.
- 14 Clocking blocks: test mapping 59/87 ( 67.82% ), execution confirmed 53/87 ( 60.92% ), execution confirmed without Ghost 39/87 ( 44.83% ), interpretation pending 0 rows.
- 15 Interprocess synchronization and communication: test mapping 68/88 ( 77.27% ), execution confirmed 63/88 ( 71.59% ), execution confirmed without Ghost 44/88 ( 50.00% ), interpretation pending 0 rows.
- 16 Assertions: test mapping 539/555 ( 97.12% ), execution confirmed 382/555 ( 68.83% ), execution confirmed without Ghost 67/555 ( 12.07% ), interpretation pending 0 rows.
- 17 Checkers: test mapping 59/79 ( 74.68% ), execution confirmed 36/79 ( 45.57% ), execution confirmed without Ghost 9/79 ( 11.39% ), interpretation pending 0 rows.
- 18 Constrained random value generation: test mapping 300/320 ( 93.75% ), execution confirmed 232/320 ( 72.50% ), execution confirmed without Ghost 127/320 ( 39.69% ), interpretation pending 0 rows.
- 19 Functional coverage: test mapping 232/271 ( 85.61% ), execution confirmed 183/271 ( 67.53% ), execution confirmed without Ghost 34/271 ( 12.55% ), interpretation pending 0 rows.
- 20 Utility system tasks and system functions: test mapping 285/316 ( 90.19% ), execution confirmed 229/316 ( 72.47% ), execution confirmed without Ghost 124/316 ( 39.24% ), interpretation pending 0 rows.
- 21 Input/output system tasks and system functions: test mapping 347/383 ( 90.60% ), execution confirmed 333/383 ( 86.95% ), execution confirmed without Ghost 215/383 ( 56.14% ), interpretation pending 0 rows.
- 22 Compiler directives: test mapping 345/361 ( 95.57% ), execution confirmed 73/361 ( 20.22% ), execution confirmed without Ghost 69/361 ( 19.11% ), interpretation pending 0 rows.
- 23 Modules and hierarchy: test mapping 251/260 ( 96.54% ), execution confirmed 159/260 ( 61.15% ), execution confirmed without Ghost 105/260 ( 40.38% ), interpretation pending 0 rows.
- 24 Programs: test mapping 16/29 ( 55.17% ), execution confirmed 13/29 ( 44.83% ), execution confirmed without Ghost 1/29 ( 3.45% ), interpretation pending 0 rows.
- 25 Interfaces: test mapping 43/63 ( 68.25% ), execution confirmed 21/63 ( 33.33% ), execution confirmed without Ghost 17/63 ( 26.98% ), interpretation pending 0 rows.
- 26 Packages: test mapping 39/44 ( 88.64% ), execution confirmed 24/44 ( 54.55% ), execution confirmed without Ghost 22/44 ( 50.00% ), interpretation pending 0 rows.
- 27 Generate constructs: test mapping 27/32 ( 84.38% ), execution confirmed 14/32 ( 43.75% ), execution confirmed without Ghost 10/32 ( 31.25% ), interpretation pending 0 rows.
- 28 Gate-level and switch-level modeling: test mapping 363/384 ( 94.53% ), execution confirmed 356/384 ( 92.71% ), execution confirmed without Ghost 332/384 ( 86.46% ), interpretation pending 0 rows.
- 29 User-defined primitives: test mapping 49/52 ( 94.23% ), execution confirmed 34/52 ( 65.38% ), execution confirmed without Ghost 30/52 ( 57.69% ), interpretation pending 0 rows.
- 30 Specify blocks: test mapping 131/157 ( 83.44% ), execution confirmed 121/157 ( 77.07% ), execution confirmed without Ghost 101/157 ( 64.33% ), interpretation pending 0 rows.
- 31 Timing checks: test mapping 154/180 ( 85.56% ), execution confirmed 141/180 ( 78.33% ), execution confirmed without Ghost 14/180 ( 7.78% ), interpretation pending 0 rows.
- 32 Backannotation using the standard delay format: test mapping 119/131 ( 90.84% ), execution confirmed 119/131 ( 90.84% ), execution confirmed without Ghost 65/131 ( 49.62% ), interpretation pending 0 rows.
- 33 Configuring the contents of a design: test mapping 30/63 ( 47.62% ), execution confirmed 19/63 ( 30.16% ), execution confirmed without Ghost 6/63 ( 9.52% ), interpretation pending 0 rows.
- 34 Protected envelopes: test mapping 5/214 ( 2.34% ), execution confirmed 5/214 ( 2.34% ), execution confirmed without Ghost 5/214 ( 2.34% ), interpretation pending 0 rows.
- 35 Direct programming interface: test mapping 114/142 ( 80.28% ), execution confirmed 104/142 ( 73.24% ), execution confirmed without Ghost 73/142 ( 51.41% ), interpretation pending 0 rows.
- 36 Programming language interface ( PLI / VPI ) overview: test mapping 148/163 ( 90.80% ), execution confirmed 119/163 ( 73.01% ), execution confirmed without Ghost 43/163 ( 26.38% ), interpretation pending 0 rows.
- 37 VPI object model diagrams: test mapping 1656/1757 ( 94.25% ), execution confirmed 1502/1757 ( 85.49% ), execution confirmed without Ghost 72/1757 ( 4.10% ), interpretation pending 0 rows.
- 38 VPI routine definitions: test mapping 260/348 ( 74.71% ), execution confirmed 253/348 ( 72.70% ), execution confirmed without Ghost 145/348 ( 41.67% ), interpretation pending 0 rows.
- 39 Assertion API : test mapping 82/95 ( 86.32% ), execution confirmed 81/95 ( 85.26% ), execution confirmed without Ghost 2/95 ( 2.11% ), interpretation pending 0 rows.
- 40 Code coverage control and API : test mapping 82/128 ( 64.06% ), execution confirmed 79/128 ( 61.72% ), execution confirmed without Ghost 34/128 ( 26.56% ), interpretation pending 0 rows.
- 41 Data read API : test mapping no registered items, execution confirmed no registered items, execution confirmed without Ghost no registered items, interpretation pending 0 rows.
- A Formal syntax: test mapping 792/811 ( 97.66% ), execution confirmed 759/811 ( 93.59% ), execution confirmed without Ghost 528/811 ( 65.10% ), interpretation pending 0 rows.
- B Keywords: test mapping 248/248 ( 100.00% ), execution confirmed 0/248 ( 0.00% ), execution confirmed without Ghost 0/248 ( 0.00% ), interpretation pending 0 rows.
- C Deprecation: test mapping 9/20 ( 45.00% ), execution confirmed 9/20 ( 45.00% ), execution confirmed without Ghost 7/20 ( 35.00% ), interpretation pending 0 rows.
- D Optional system tasks and system functions: test mapping no registered items, execution confirmed no registered items, execution confirmed without Ghost no registered items, interpretation pending 0 rows.
- E Optional compiler directives: test mapping no registered items, execution confirmed no registered items, execution confirmed without Ghost no registered items, interpretation pending 0 rows.
- F Formal semantics of concurrent assertions: test mapping 253/253 ( 100.00% ), execution confirmed 0/253 ( 0.00% ), execution confirmed without Ghost 0/253 ( 0.00% ), interpretation pending 0 rows.
- G Std package: test mapping 25/32 ( 78.12% ), execution confirmed 25/32 ( 78.12% ), execution confirmed without Ghost 18/32 ( 56.25% ), interpretation pending 0 rows.
- H DPI C layer: test mapping 190/223 ( 85.20% ), execution confirmed 189/223 ( 84.75% ), execution confirmed without Ghost 133/223 ( 59.64% ), interpretation pending 0 rows.
- I svdpi.h : test mapping 133/147 ( 90.48% ), execution confirmed 133/147 ( 90.48% ), execution confirmed without Ghost 112/147 ( 76.19% ), interpretation pending 0 rows.
- J Inclusion of foreign language code: test mapping 0/16 ( 0.00% ), execution confirmed 0/16 ( 0.00% ), execution confirmed without Ghost 0/16 ( 0.00% ), interpretation pending 0 rows.
- K vpi_user.h : test mapping 541/544 ( 99.45% ), execution confirmed 541/544 ( 99.45% ), execution confirmed without Ghost 540/544 ( 99.26% ), interpretation pending 0 rows.
- L vpi_compatibility.h : test mapping 85/88 ( 96.59% ), execution confirmed 84/88 ( 95.45% ), execution confirmed without Ghost 0/88 ( 0.00% ), interpretation pending 0 rows.
- M sv_vpi_user.h : test mapping 407/412 ( 98.79% ), execution confirmed 407/412 ( 98.79% ), execution confirmed without Ghost 407/412 ( 98.79% ), interpretation pending 0 rows.
- N Algorithm for probabilistic distribution functions: test mapping 29/39 ( 74.36% ), execution confirmed 29/39 ( 74.36% ), execution confirmed without Ghost 29/39 ( 74.36% ), interpretation pending 0 rows.
- O Encryption/decryption flow: test mapping no registered items, execution confirmed no registered items, execution confirmed without Ghost no registered items, interpretation pending 0 rows.
- P Glossary: test mapping no registered items, execution confirmed no registered items, execution confirmed without Ghost no registered items, interpretation pending 0 rows.
- Q Bibliography: test mapping no registered items, execution confirmed no registered items, execution confirmed without Ghost no registered items, interpretation pending 0 rows.

<a id="分母と履歴"></a>

## Denominator and history

- The denominator is SHA-256 : `8a8f350dfea82366808f80d1fa1f6cb8d6b488d7a9b3edf3092b79e1fc57e1da`.
- Version of the measurement rule: 3.
- The history stores the identifier of the denominator, the provisional and definitive values, and the state summary by environment. The ratio of the rounds with different denominators is not compared as improvement or deterioration.
- This aggregation is re-generated from the saved execution trace. The above time of measurement is the time of execution.
