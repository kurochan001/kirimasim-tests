<a id="ieee-1800-2023-要求カバレッジ集計"></a>

# IEEE 1800-2023 requirement coverage aggregation

[English](behavior-coverage-summary.en.md) / [日本語](behavior-coverage-summary.md)

[Details of all items](behavior-coverage.en.md) / [Management procedures](https://github.com/kurochan001/kirimasim-tests/blob/68ce2bc2a458f118cae0e4e65f1e042c3b90aa6e/coverage/README.en.md) / [Interpretation and Re-examination Record](https://github.com/kurochan001/kirimasim-tests/blob/68ce2bc2a458f118cae0e4e65f1e042c3b90aa6e/docs/requirement-extraction-notes.en.md)

The denominator counts requirement-ledger rows, not test files. See [Design, execution and PASS distinctions](https://github.com/kurochan001/kirimasim-tests/blob/68ce2bc2a458f118cae0e4e65f1e042c3b90aa6e/docs/faq.en.md#q16-how-do-design-and-execution-coverage-differ) for concrete examples.

<a id="全規格の要求台帳に対する値"></a>

## Value for all standards in the required table

- Requirement coverage (test design): 92.67% ( 11428/12332 ).
- Execution confirmation rate without Ghost: 42.98% ( 5300/12332 ). Union of successes on Icarus Verilog, Verilator and SymbiYosys, which third parties can reproduce. Of these, 5300 rows are confirmed by a simulator and 0 rows by formal checks alone.
- The execution confirmation rate is 77.55% ( 9563/12332 ). Union of successes across environments. Of these, 9563 rows are confirmed by a simulator and 0 rows by formal checks alone.
- The denominator includes pending interpretations and items without test mappings. We do not exclude non-implemented and non-supported.
- The registration unit is the occurrence point, condition, and observation case of the requirement, and the duplication of meaning is integrated by the review of the denominator. This is neither the fraction of all program/input combinations tested nor a single simulator's standard conformance rate.

<a id="既存テストの集計状況"></a>

## Aggregation of existing tests

- 6644 of 16244 tests have a registered correspondence with the requirements. 9600 tests remain unregistered.
- The above coverage rate is calculated only for the part which registered the response to the demand by confirming the stimulus and the expected result. Existing tests that are not registered are also useful for verification, but their contribution is not yet reflected in the proportion.
- The number of registered units is the number of units that correspond to at least one requirement, not the number of completed reviews of the whole test.

- The requests that are shared by multiple tests are in the 760 row. Only if all tests in each group are successful in the same run, they count as a success for the entire request.

<a id="確定値"></a>

## Definite value

- Requirement coverage (test design): 92.67%.
- Requirement execution-confirmation rate: 42.98% without Ghost, 77.55% with Ghost.
- Approval of denominator: Approval. The measured state is `confirmed`.
- The method was confirmed after document verification, resolution of the reservation interpretation, duplication of the requirement unit, and review of the denominator.

<a id="残件"></a>

## Remains

- There is a record of the path result corresponding to the current input: 9563 line.
- No record of passed/passout results: 1865 line.
- Test compatibility not confirmed (except for interpretation reservation): 904 line.
- Interpretation reservation: 0 line.

Unsupported behavior does not mean that no existing test is available.

<a id="シミュレータ別の実行確認率"></a>

## Execution confirmation rate by simulator

Each row is a separate saved run. A narrow run can leave many tests unexecuted; check [how to read dates, versions and scope](https://github.com/kurochan001/kirimasim-tests/blob/68ce2bc2a458f118cae0e4e65f1e042c3b90aa6e/docs/faq.en.md#q14-why-do-main-results-or-simulator-totals-differ) and the measurement source.

- `ghost` / `private build 0b90acaa7ed6` : 9553/12332 ( 77.47% )。 Measurement source: `2026-11-19T14:41:07.238216+00:00` / `ghost.json` 。 Failures 78; known mismatches 0; unsupported 0; not run 290; stale evidence 0; unapproved judgment evidence for illegal-design tests 1507 rows.
- `icarus` / `Icarus Verilog version 14.0 (devel) (s20260301-1208-g65504129)` : 2659/12332 ( 21.56% )。 Measurement source: `2026-11-19T14:15:11.265977+00:00` / `icarus.json` 。 Failures 15; known mismatches 7324; unsupported 0; not run 290; stale evidence 0; unapproved judgment evidence for illegal-design tests 1140 rows.
- `kirimasim` / `kirimasim 0.1.1 (commit bd81035d9809), built with GNU 13.3.0` : 3091/12332 ( 25.06% )。 Measurement source: `2026-11-19T14:20:57.576141+00:00` / `kirimasim.json` 。 Failures 166; known mismatches 0; unsupported 6493; not run 290; stale evidence 0; unapproved judgment evidence for illegal-design tests 1388 rows.
- `verilator` / `Verilator 5.055 devel rev v5.054-325-g464643f7` : 3786/12332 ( 30.70% )。 Measurement source: `2026-11-19T15:38:01.573168+00:00` / `verilator.json` 。 Failures 27; known mismatches 6298; unsupported 0; not run 290; stale evidence 0; unapproved judgment evidence for illegal-design tests 1027 rows.
- The result file of the rejection: 0.

<a id="章附属書別登録項目に対する割合"></a>

## By chapter and appendix (percentage of registered items)

- 1 Overview: test mapping no registered items, execution confirmed no registered items, execution confirmed without Ghost no registered items, interpretation pending 0 rows.
- 2 Normative references: test mapping 0/2 ( 0.00% ), execution confirmed 0/2 ( 0.00% ), execution confirmed without Ghost 0/2 ( 0.00% ), interpretation pending 0 rows.
- 3 Design and verification building blocks: test mapping 131/146 ( 89.73% ), execution confirmed 111/146 ( 76.03% ), execution confirmed without Ghost 107/146 ( 73.29% ), interpretation pending 0 rows.
- 4 Scheduling semantics: test mapping 90/107 ( 84.11% ), execution confirmed 88/107 ( 82.24% ), execution confirmed without Ghost 59/107 ( 55.14% ), interpretation pending 0 rows.
- 5 Lexical conventions: test mapping 146/155 ( 94.19% ), execution confirmed 128/155 ( 82.58% ), execution confirmed without Ghost 118/155 ( 76.13% ), interpretation pending 0 rows.
- 6 Data types: test mapping 710/720 ( 98.61% ), execution confirmed 580/720 ( 80.56% ), execution confirmed without Ghost 463/720 ( 64.31% ), interpretation pending 0 rows.
- 7 Aggregate data types: test mapping 337/347 ( 97.12% ), execution confirmed 260/347 ( 74.93% ), execution confirmed without Ghost 165/347 ( 47.55% ), interpretation pending 0 rows.
- 8 Classes: test mapping 239/255 ( 93.73% ), execution confirmed 151/255 ( 59.22% ), execution confirmed without Ghost 116/255 ( 45.49% ), interpretation pending 0 rows.
- 9 Processes: test mapping 183/192 ( 95.31% ), execution confirmed 161/192 ( 83.85% ), execution confirmed without Ghost 107/192 ( 55.73% ), interpretation pending 0 rows.
- 10 Assignment statements: test mapping 144/156 ( 92.31% ), execution confirmed 108/156 ( 69.23% ), execution confirmed without Ghost 65/156 ( 41.67% ), interpretation pending 0 rows.
- 11 Operators and expressions: test mapping 448/459 ( 97.60% ), execution confirmed 412/459 ( 89.76% ), execution confirmed without Ghost 346/459 ( 75.38% ), interpretation pending 0 rows.
- 12 Procedural programming statements: test mapping 101/115 ( 87.83% ), execution confirmed 86/115 ( 74.78% ), execution confirmed without Ghost 48/115 ( 41.74% ), interpretation pending 0 rows.
- 13 Tasks and functions (subroutines): test mapping 116/124 ( 93.55% ), execution confirmed 75/124 ( 60.48% ), execution confirmed without Ghost 61/124 ( 49.19% ), interpretation pending 0 rows.
- 14 Clocking blocks: test mapping 84/87 ( 96.55% ), execution confirmed 66/87 ( 75.86% ), execution confirmed without Ghost 48/87 ( 55.17% ), interpretation pending 0 rows.
- 15 Interprocess synchronization and communication: test mapping 75/88 ( 85.23% ), execution confirmed 69/88 ( 78.41% ), execution confirmed without Ghost 45/88 ( 51.14% ), interpretation pending 0 rows.
- 16 Assertions: test mapping 548/557 ( 98.38% ), execution confirmed 402/557 ( 72.17% ), execution confirmed without Ghost 67/557 ( 12.03% ), interpretation pending 0 rows.
- 17 Checkers: test mapping 68/81 ( 83.95% ), execution confirmed 42/81 ( 51.85% ), execution confirmed without Ghost 9/81 ( 11.11% ), interpretation pending 0 rows.
- 18 Constrained random value generation: test mapping 314/323 ( 97.21% ), execution confirmed 252/323 ( 78.02% ), execution confirmed without Ghost 135/323 ( 41.80% ), interpretation pending 0 rows.
- 19 Functional coverage: test mapping 267/276 ( 96.74% ), execution confirmed 205/276 ( 74.28% ), execution confirmed without Ghost 36/276 ( 13.04% ), interpretation pending 0 rows.
- 20 Utility system tasks and system functions: test mapping 299/320 ( 93.44% ), execution confirmed 285/320 ( 89.06% ), execution confirmed without Ghost 130/320 ( 40.62% ), interpretation pending 0 rows.
- 21 Input/output system tasks and system functions: test mapping 358/383 ( 93.47% ), execution confirmed 342/383 ( 89.30% ), execution confirmed without Ghost 221/383 ( 57.70% ), interpretation pending 0 rows.
- 22 Compiler directives: test mapping 355/363 ( 97.80% ), execution confirmed 76/363 ( 20.94% ), execution confirmed without Ghost 72/363 ( 19.83% ), interpretation pending 0 rows.
- 23 Modules and hierarchy: test mapping 251/260 ( 96.54% ), execution confirmed 191/260 ( 73.46% ), execution confirmed without Ghost 101/260 ( 38.85% ), interpretation pending 0 rows.
- 24 Programs: test mapping 25/29 ( 86.21% ), execution confirmed 18/29 ( 62.07% ), execution confirmed without Ghost 2/29 ( 6.90% ), interpretation pending 0 rows.
- 25 Interfaces: test mapping 55/63 ( 87.30% ), execution confirmed 29/63 ( 46.03% ), execution confirmed without Ghost 19/63 ( 30.16% ), interpretation pending 0 rows.
- 26 Packages: test mapping 39/44 ( 88.64% ), execution confirmed 24/44 ( 54.55% ), execution confirmed without Ghost 22/44 ( 50.00% ), interpretation pending 0 rows.
- 27 Generate constructs: test mapping 27/32 ( 84.38% ), execution confirmed 14/32 ( 43.75% ), execution confirmed without Ghost 10/32 ( 31.25% ), interpretation pending 0 rows.
- 28 Gate-level and switch-level modeling: test mapping 370/384 ( 96.35% ), execution confirmed 363/384 ( 94.53% ), execution confirmed without Ghost 338/384 ( 88.02% ), interpretation pending 0 rows.
- 29 User-defined primitives: test mapping 49/52 ( 94.23% ), execution confirmed 34/52 ( 65.38% ), execution confirmed without Ghost 30/52 ( 57.69% ), interpretation pending 0 rows.
- 30 Specify blocks: test mapping 150/157 ( 95.54% ), execution confirmed 138/157 ( 87.90% ), execution confirmed without Ghost 110/157 ( 70.06% ), interpretation pending 0 rows.
- 31 Timing checks: test mapping 155/180 ( 86.11% ), execution confirmed 142/180 ( 78.89% ), execution confirmed without Ghost 14/180 ( 7.78% ), interpretation pending 0 rows.
- 32 Backannotation using the standard delay format: test mapping 119/131 ( 90.84% ), execution confirmed 111/131 ( 84.73% ), execution confirmed without Ghost 65/131 ( 49.62% ), interpretation pending 0 rows.
- 33 Configuring the contents of a design: test mapping 41/63 ( 65.08% ), execution confirmed 28/63 ( 44.44% ), execution confirmed without Ghost 7/63 ( 11.11% ), interpretation pending 0 rows.
- 34 Protected envelopes: test mapping 5/214 ( 2.34% ), execution confirmed 5/214 ( 2.34% ), execution confirmed without Ghost 5/214 ( 2.34% ), interpretation pending 0 rows.
- 35 Direct programming interface: test mapping 121/143 ( 84.62% ), execution confirmed 106/143 ( 74.13% ), execution confirmed without Ghost 78/143 ( 54.55% ), interpretation pending 0 rows.
- 36 Programming language interface ( PLI / VPI ) overview: test mapping 148/163 ( 90.80% ), execution confirmed 145/163 ( 88.96% ), execution confirmed without Ghost 43/163 ( 26.38% ), interpretation pending 0 rows.
- 37 VPI object model diagrams: test mapping 1662/1757 ( 94.59% ), execution confirmed 1637/1757 ( 93.17% ), execution confirmed without Ghost 73/1757 ( 4.15% ), interpretation pending 0 rows.
- 38 VPI routine definitions: test mapping 280/348 ( 80.46% ), execution confirmed 280/348 ( 80.46% ), execution confirmed without Ghost 146/348 ( 41.95% ), interpretation pending 0 rows.
- 39 Assertion API : test mapping 82/95 ( 86.32% ), execution confirmed 79/95 ( 83.16% ), execution confirmed without Ghost 2/95 ( 2.11% ), interpretation pending 0 rows.
- 40 Code coverage control and API : test mapping 122/128 ( 95.31% ), execution confirmed 122/128 ( 95.31% ), execution confirmed without Ghost 34/128 ( 26.56% ), interpretation pending 0 rows.
- 41 Data read API : test mapping no registered items, execution confirmed no registered items, execution confirmed without Ghost no registered items, interpretation pending 0 rows.
- A Formal syntax: test mapping 792/811 ( 97.66% ), execution confirmed 777/811 ( 95.81% ), execution confirmed without Ghost 536/811 ( 66.09% ), interpretation pending 0 rows.
- B Keywords: test mapping 248/248 ( 100.00% ), execution confirmed 0/248 ( 0.00% ), execution confirmed without Ghost 0/248 ( 0.00% ), interpretation pending 0 rows.
- C Deprecation: test mapping 9/20 ( 45.00% ), execution confirmed 9/20 ( 45.00% ), execution confirmed without Ghost 7/20 ( 35.00% ), interpretation pending 0 rows.
- D Optional system tasks and system functions: test mapping no registered items, execution confirmed no registered items, execution confirmed without Ghost no registered items, interpretation pending 0 rows.
- E Optional compiler directives: test mapping no registered items, execution confirmed no registered items, execution confirmed without Ghost no registered items, interpretation pending 0 rows.
- F Formal semantics of concurrent assertions: test mapping 253/253 ( 100.00% ), execution confirmed 0/253 ( 0.00% ), execution confirmed without Ghost 0/253 ( 0.00% ), interpretation pending 0 rows.
- G Std package: test mapping 25/32 ( 78.12% ), execution confirmed 25/32 ( 78.12% ), execution confirmed without Ghost 18/32 ( 56.25% ), interpretation pending 0 rows.
- H DPI C layer: test mapping 192/223 ( 86.10% ), execution confirmed 192/223 ( 86.10% ), execution confirmed without Ghost 134/223 ( 60.09% ), interpretation pending 0 rows.
- I svdpi.h : test mapping 133/147 ( 90.48% ), execution confirmed 133/147 ( 90.48% ), execution confirmed without Ghost 112/147 ( 76.19% ), interpretation pending 0 rows.
- J Inclusion of foreign language code: test mapping 0/16 ( 0.00% ), execution confirmed 0/16 ( 0.00% ), execution confirmed without Ghost 0/16 ( 0.00% ), interpretation pending 0 rows.
- K vpi_user.h : test mapping 541/544 ( 99.45% ), execution confirmed 541/544 ( 99.45% ), execution confirmed without Ghost 540/544 ( 99.26% ), interpretation pending 0 rows.
- L vpi_compatibility.h : test mapping 85/88 ( 96.59% ), execution confirmed 85/88 ( 96.59% ), execution confirmed without Ghost 0/88 ( 0.00% ), interpretation pending 0 rows.
- M sv_vpi_user.h : test mapping 407/412 ( 98.79% ), execution confirmed 407/412 ( 98.79% ), execution confirmed without Ghost 407/412 ( 98.79% ), interpretation pending 0 rows.
- N Algorithm for probabilistic distribution functions: test mapping 29/39 ( 74.36% ), execution confirmed 29/39 ( 74.36% ), execution confirmed without Ghost 29/39 ( 74.36% ), interpretation pending 0 rows.
- O Encryption/decryption flow: test mapping no registered items, execution confirmed no registered items, execution confirmed without Ghost no registered items, interpretation pending 0 rows.
- P Glossary: test mapping no registered items, execution confirmed no registered items, execution confirmed without Ghost no registered items, interpretation pending 0 rows.
- Q Bibliography: test mapping no registered items, execution confirmed no registered items, execution confirmed without Ghost no registered items, interpretation pending 0 rows.

<a id="分母と履歴"></a>

## Denominator and history

- The denominator is SHA-256 : `3e082eb97645e56c5c07ea62dc21876b52bd54c4d28ad6ecdfa907aa459e184b`.
- Version of the measurement rule: 3.
- The history stores the identifier of the denominator, the provisional and definitive values, and the state summary by environment. The ratio of the rounds with different denominators is not compared as improvement or deterioration.
- This aggregation is re-generated from the saved execution trace. The above time of measurement is the time of execution.
