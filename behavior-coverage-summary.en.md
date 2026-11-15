<a id="ieee-1800-2023-要求カバレッジ集計"></a>

# IEEE 1800-2023 requirement coverage aggregation

[English](behavior-coverage-summary.en.md) / [日本語](behavior-coverage-summary.md)

[Details of all items](behavior-coverage.en.md) / [Management procedures](https://github.com/kurochan001/kirimasim-tests/blob/ed5ded9a0130470fb1e36fa46a9094a3326b0ad6/coverage/README.en.md) / [Interpretation and Re-examination Record](https://github.com/kurochan001/kirimasim-tests/blob/ed5ded9a0130470fb1e36fa46a9094a3326b0ad6/docs/requirement-extraction-notes.en.md)

The denominator counts requirement-ledger rows, not test files. See [Design, execution and PASS distinctions](https://github.com/kurochan001/kirimasim-tests/blob/ed5ded9a0130470fb1e36fa46a9094a3326b0ad6/docs/faq.en.md#q16-how-do-design-and-execution-coverage-differ) for concrete examples.

<a id="全規格の要求台帳に対する値"></a>

## Value for all standards in the required table

- Requirement coverage (test design): 91.73% ( 11312/12332 ).
- Execution confirmation rate without Ghost: 42.62% ( 5256/12332 ). Union of successes on Icarus Verilog, Verilator and SymbiYosys, which third parties can reproduce. Of these, 5256 rows are confirmed by a simulator and 0 rows by formal checks alone.
- The execution confirmation rate is 50.96% ( 6284/12332 ). Union of successes across environments. Of these, 6284 rows are confirmed by a simulator and 0 rows by formal checks alone.
- The denominator includes pending interpretations and items without test mappings. We do not exclude non-implemented and non-supported.
- The registration unit is the occurrence point, condition, and observation case of the requirement, and the duplication of meaning is integrated by the review of the denominator. This is neither the fraction of all program/input combinations tested nor a single simulator's standard conformance rate.

<a id="既存テストの集計状況"></a>

## Aggregation of existing tests

- 5667 of 12630 tests have a registered correspondence with the requirements. 6963 tests remain unregistered.
- The above coverage rate is calculated only for the part which registered the response to the demand by confirming the stimulus and the expected result. Existing tests that are not registered are also useful for verification, but their contribution is not yet reflected in the proportion.
- The number of registered units is the number of units that correspond to at least one requirement, not the number of completed reviews of the whole test.

- The requests that are shared by multiple tests are in the 719 row. Only if all tests in each group are successful in the same run, they count as a success for the entire request.

<a id="確定値"></a>

## Definite value

- Requirement coverage (test design): 91.73%.
- Requirement execution-confirmation rate: 42.62% without Ghost, 50.96% with Ghost.
- Approval of denominator: Approval. The measured state is `confirmed`.
- The method was confirmed after document verification, resolution of the reservation interpretation, duplication of the requirement unit, and review of the denominator.

<a id="残件"></a>

## Remains

- There is a record of the path result corresponding to the current input: 6284 line.
- No record of passed/passout results: 5028 line.
- Test compatibility not confirmed (except for interpretation reservation): 1020 line.
- Interpretation reservation: 0 line.

Unsupported behavior does not mean that no existing test is available.

<a id="シミュレータ別の実行確認率"></a>

## Execution confirmation rate by simulator

Each row is a separate saved run. A narrow run can leave many tests unexecuted; check [how to read dates, versions and scope](https://github.com/kurochan001/kirimasim-tests/blob/ed5ded9a0130470fb1e36fa46a9094a3326b0ad6/docs/faq.en.md#q14-why-do-main-results-or-simulator-totals-differ) and the measurement source.

- `icarus` / `Icarus Verilog version 14.0 (devel) (s20260301-1037-g77bb46fb)` : 2598/12332 ( 21.07% )。 Measurement source: `2026-11-15T00:30:09.188699+00:00` / `icarus.json` 。 Failures 13; known mismatches 7330; unsupported 0; not run 290; stale evidence 0; unapproved judgment evidence for illegal-design tests 1081 rows.
- `kirimasim` / `kirimasim 0.0.0 (commit c3571569b7f9), built with GNU 13.3.0` : 3066/12332 ( 24.86% )。 Measurement source: `2026-11-15T00:42:37.166253+00:00` / `kirimasim.json` 。 Failures 161; known mismatches 0; unsupported 6466; not run 290; stale evidence 0; unapproved judgment evidence for illegal-design tests 1329 rows.
- `lyra` / `Lyra (commit 2f842a92f99c)` : 3624/12332 ( 29.39% )。 Measurement source: `2026-11-15T05:49:24.061054+00:00` / `lyra.json` 。 Failures 833; known mismatches 0; unsupported 5243; not run 290; stale evidence 0; unapproved judgment evidence for illegal-design tests 1322 rows.
- `verilator` / `Verilator 5.055 devel rev v5.054-276-g9fc843a1` : 3764/12332 ( 30.52% )。 Measurement source: `2026-11-15T01:14:15.256670+00:00` / `verilator.json` 。 Failures 27; known mismatches 6231; unsupported 0; not run 290; stale evidence 0; unapproved judgment evidence for illegal-design tests 1000 rows.
- The result file of the rejection: 0.

<a id="章附属書別登録項目に対する割合"></a>

## By chapter and appendix (percentage of registered items)

- 1 Overview: test mapping no registered items, execution confirmed no registered items, execution confirmed without Ghost no registered items, interpretation pending 0 rows.
- 2 Normative references: test mapping 0/2 ( 0.00% ), execution confirmed 0/2 ( 0.00% ), execution confirmed without Ghost 0/2 ( 0.00% ), interpretation pending 0 rows.
- 3 Design and verification building blocks: test mapping 127/146 ( 86.99% ), execution confirmed 108/146 ( 73.97% ), execution confirmed without Ghost 105/146 ( 71.92% ), interpretation pending 0 rows.
- 4 Scheduling semantics: test mapping 90/107 ( 84.11% ), execution confirmed 77/107 ( 71.96% ), execution confirmed without Ghost 59/107 ( 55.14% ), interpretation pending 0 rows.
- 5 Lexical conventions: test mapping 143/155 ( 92.26% ), execution confirmed 120/155 ( 77.42% ), execution confirmed without Ghost 117/155 ( 75.48% ), interpretation pending 0 rows.
- 6 Data types: test mapping 710/720 ( 98.61% ), execution confirmed 508/720 ( 70.56% ), execution confirmed without Ghost 462/720 ( 64.17% ), interpretation pending 0 rows.
- 7 Aggregate data types: test mapping 337/347 ( 97.12% ), execution confirmed 250/347 ( 72.05% ), execution confirmed without Ghost 154/347 ( 44.38% ), interpretation pending 0 rows.
- 8 Classes: test mapping 238/255 ( 93.33% ), execution confirmed 144/255 ( 56.47% ), execution confirmed without Ghost 116/255 ( 45.49% ), interpretation pending 0 rows.
- 9 Processes: test mapping 172/192 ( 89.58% ), execution confirmed 140/192 ( 72.92% ), execution confirmed without Ghost 102/192 ( 53.12% ), interpretation pending 0 rows.
- 10 Assignment statements: test mapping 142/156 ( 91.03% ), execution confirmed 101/156 ( 64.74% ), execution confirmed without Ghost 63/156 ( 40.38% ), interpretation pending 0 rows.
- 11 Operators and expressions: test mapping 448/459 ( 97.60% ), execution confirmed 396/459 ( 86.27% ), execution confirmed without Ghost 346/459 ( 75.38% ), interpretation pending 0 rows.
- 12 Procedural programming statements: test mapping 101/115 ( 87.83% ), execution confirmed 84/115 ( 73.04% ), execution confirmed without Ghost 48/115 ( 41.74% ), interpretation pending 0 rows.
- 13 Tasks and functions (subroutines): test mapping 104/124 ( 83.87% ), execution confirmed 67/124 ( 54.03% ), execution confirmed without Ghost 58/124 ( 46.77% ), interpretation pending 0 rows.
- 14 Clocking blocks: test mapping 84/87 ( 96.55% ), execution confirmed 54/87 ( 62.07% ), execution confirmed without Ghost 48/87 ( 55.17% ), interpretation pending 0 rows.
- 15 Interprocess synchronization and communication: test mapping 74/88 ( 84.09% ), execution confirmed 65/88 ( 73.86% ), execution confirmed without Ghost 44/88 ( 50.00% ), interpretation pending 0 rows.
- 16 Assertions: test mapping 544/557 ( 97.67% ), execution confirmed 167/557 ( 29.98% ), execution confirmed without Ghost 67/557 ( 12.03% ), interpretation pending 0 rows.
- 17 Checkers: test mapping 63/81 ( 77.78% ), execution confirmed 9/81 ( 11.11% ), execution confirmed without Ghost 9/81 ( 11.11% ), interpretation pending 0 rows.
- 18 Constrained random value generation: test mapping 304/323 ( 94.12% ), execution confirmed 163/323 ( 50.46% ), execution confirmed without Ghost 132/323 ( 40.87% ), interpretation pending 0 rows.
- 19 Functional coverage: test mapping 237/276 ( 85.87% ), execution confirmed 147/276 ( 53.26% ), execution confirmed without Ghost 34/276 ( 12.32% ), interpretation pending 0 rows.
- 20 Utility system tasks and system functions: test mapping 291/320 ( 90.94% ), execution confirmed 197/320 ( 61.56% ), execution confirmed without Ghost 128/320 ( 40.00% ), interpretation pending 0 rows.
- 21 Input/output system tasks and system functions: test mapping 355/383 ( 92.69% ), execution confirmed 265/383 ( 69.19% ), execution confirmed without Ghost 220/383 ( 57.44% ), interpretation pending 0 rows.
- 22 Compiler directives: test mapping 346/363 ( 95.32% ), execution confirmed 73/363 ( 20.11% ), execution confirmed without Ghost 70/363 ( 19.28% ), interpretation pending 0 rows.
- 23 Modules and hierarchy: test mapping 251/260 ( 96.54% ), execution confirmed 138/260 ( 53.08% ), execution confirmed without Ghost 101/260 ( 38.85% ), interpretation pending 0 rows.
- 24 Programs: test mapping 25/29 ( 86.21% ), execution confirmed 18/29 ( 62.07% ), execution confirmed without Ghost 2/29 ( 6.90% ), interpretation pending 0 rows.
- 25 Interfaces: test mapping 55/63 ( 87.30% ), execution confirmed 28/63 ( 44.44% ), execution confirmed without Ghost 19/63 ( 30.16% ), interpretation pending 0 rows.
- 26 Packages: test mapping 39/44 ( 88.64% ), execution confirmed 23/44 ( 52.27% ), execution confirmed without Ghost 22/44 ( 50.00% ), interpretation pending 0 rows.
- 27 Generate constructs: test mapping 27/32 ( 84.38% ), execution confirmed 13/32 ( 40.62% ), execution confirmed without Ghost 10/32 ( 31.25% ), interpretation pending 0 rows.
- 28 Gate-level and switch-level modeling: test mapping 363/384 ( 94.53% ), execution confirmed 336/384 ( 87.50% ), execution confirmed without Ghost 332/384 ( 86.46% ), interpretation pending 0 rows.
- 29 User-defined primitives: test mapping 49/52 ( 94.23% ), execution confirmed 33/52 ( 63.46% ), execution confirmed without Ghost 30/52 ( 57.69% ), interpretation pending 0 rows.
- 30 Specify blocks: test mapping 149/157 ( 94.90% ), execution confirmed 111/157 ( 70.70% ), execution confirmed without Ghost 110/157 ( 70.06% ), interpretation pending 0 rows.
- 31 Timing checks: test mapping 155/180 ( 86.11% ), execution confirmed 14/180 ( 7.78% ), execution confirmed without Ghost 14/180 ( 7.78% ), interpretation pending 0 rows.
- 32 Backannotation using the standard delay format: test mapping 119/131 ( 90.84% ), execution confirmed 65/131 ( 49.62% ), execution confirmed without Ghost 65/131 ( 49.62% ), interpretation pending 0 rows.
- 33 Configuring the contents of a design: test mapping 41/63 ( 65.08% ), execution confirmed 24/63 ( 38.10% ), execution confirmed without Ghost 7/63 ( 11.11% ), interpretation pending 0 rows.
- 34 Protected envelopes: test mapping 5/214 ( 2.34% ), execution confirmed 5/214 ( 2.34% ), execution confirmed without Ghost 5/214 ( 2.34% ), interpretation pending 0 rows.
- 35 Direct programming interface: test mapping 116/143 ( 81.12% ), execution confirmed 100/143 ( 69.93% ), execution confirmed without Ghost 77/143 ( 53.85% ), interpretation pending 0 rows.
- 36 Programming language interface ( PLI / VPI ) overview: test mapping 148/163 ( 90.80% ), execution confirmed 43/163 ( 26.38% ), execution confirmed without Ghost 43/163 ( 26.38% ), interpretation pending 0 rows.
- 37 VPI object model diagrams: test mapping 1662/1757 ( 94.59% ), execution confirmed 72/1757 ( 4.10% ), execution confirmed without Ghost 72/1757 ( 4.10% ), interpretation pending 0 rows.
- 38 VPI routine definitions: test mapping 280/348 ( 80.46% ), execution confirmed 146/348 ( 41.95% ), execution confirmed without Ghost 146/348 ( 41.95% ), interpretation pending 0 rows.
- 39 Assertion API : test mapping 82/95 ( 86.32% ), execution confirmed 2/95 ( 2.11% ), execution confirmed without Ghost 2/95 ( 2.11% ), interpretation pending 0 rows.
- 40 Code coverage control and API : test mapping 122/128 ( 95.31% ), execution confirmed 34/128 ( 26.56% ), execution confirmed without Ghost 34/128 ( 26.56% ), interpretation pending 0 rows.
- 41 Data read API : test mapping no registered items, execution confirmed no registered items, execution confirmed without Ghost no registered items, interpretation pending 0 rows.
- A Formal syntax: test mapping 792/811 ( 97.66% ), execution confirmed 647/811 ( 79.78% ), execution confirmed without Ghost 536/811 ( 66.09% ), interpretation pending 0 rows.
- B Keywords: test mapping 248/248 ( 100.00% ), execution confirmed 0/248 ( 0.00% ), execution confirmed without Ghost 0/248 ( 0.00% ), interpretation pending 0 rows.
- C Deprecation: test mapping 9/20 ( 45.00% ), execution confirmed 8/20 ( 40.00% ), execution confirmed without Ghost 7/20 ( 35.00% ), interpretation pending 0 rows.
- D Optional system tasks and system functions: test mapping no registered items, execution confirmed no registered items, execution confirmed without Ghost no registered items, interpretation pending 0 rows.
- E Optional compiler directives: test mapping no registered items, execution confirmed no registered items, execution confirmed without Ghost no registered items, interpretation pending 0 rows.
- F Formal semantics of concurrent assertions: test mapping 253/253 ( 100.00% ), execution confirmed 0/253 ( 0.00% ), execution confirmed without Ghost 0/253 ( 0.00% ), interpretation pending 0 rows.
- G Std package: test mapping 25/32 ( 78.12% ), execution confirmed 23/32 ( 71.88% ), execution confirmed without Ghost 18/32 ( 56.25% ), interpretation pending 0 rows.
- H DPI C layer: test mapping 192/223 ( 86.10% ), execution confirmed 159/223 ( 71.30% ), execution confirmed without Ghost 134/223 ( 60.09% ), interpretation pending 0 rows.
- I svdpi.h : test mapping 133/147 ( 90.48% ), execution confirmed 131/147 ( 89.12% ), execution confirmed without Ghost 112/147 ( 76.19% ), interpretation pending 0 rows.
- J Inclusion of foreign language code: test mapping 0/16 ( 0.00% ), execution confirmed 0/16 ( 0.00% ), execution confirmed without Ghost 0/16 ( 0.00% ), interpretation pending 0 rows.
- K vpi_user.h : test mapping 541/544 ( 99.45% ), execution confirmed 540/544 ( 99.26% ), execution confirmed without Ghost 540/544 ( 99.26% ), interpretation pending 0 rows.
- L vpi_compatibility.h : test mapping 85/88 ( 96.59% ), execution confirmed 0/88 ( 0.00% ), execution confirmed without Ghost 0/88 ( 0.00% ), interpretation pending 0 rows.
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
