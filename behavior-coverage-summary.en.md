<a id="ieee-1800-2023-要求カバレッジ集計"></a>

# IEEE 1800-2023 requirement coverage aggregation

[English](behavior-coverage-summary.en.md) / [日本語](behavior-coverage-summary.md)

[Details of all items](behavior-coverage.en.md) / [Management procedures](https://github.com/kurochan001/kirimasim-tests/blob/f029182b31bfe8fded04eeb649f19517d988ca97/coverage/README.en.md) / [Interpretation and Re-examination Record](https://github.com/kurochan001/kirimasim-tests/blob/f029182b31bfe8fded04eeb649f19517d988ca97/docs/requirement-extraction-notes.en.md)

The denominator counts requirement-ledger rows, not test files. See [Design, execution and PASS distinctions](https://github.com/kurochan001/kirimasim-tests/blob/f029182b31bfe8fded04eeb649f19517d988ca97/docs/faq.en.md#q16-how-do-design-and-execution-coverage-differ) for concrete examples.

<a id="全規格の要求台帳に対する値"></a>

## Value for all standards in the required table

- Requirement coverage (test design): 95.56% ( 11784/12332 ).
- Execution confirmation rate without Ghost: 43.59% ( 5375/12332 ). Union of successes on Icarus Verilog, Verilator and SymbiYosys, which third parties can reproduce. Of these, 5375 rows are confirmed by a simulator and 0 rows by formal checks alone.
- The execution confirmation rate is 79.78% ( 9838/12332 ). Union of successes across environments. Of these, 9838 rows are confirmed by a simulator and 0 rows by formal checks alone.
- The denominator includes pending interpretations and items without test mappings. We do not exclude non-implemented and non-supported.
- The registration unit is the occurrence point, condition, and observation case of the requirement, and the duplication of meaning is integrated by the review of the denominator. This is neither the fraction of all program/input combinations tested nor a single simulator's standard conformance rate.

<a id="既存テストの集計状況"></a>

## Aggregation of existing tests

- 7140 of 16877 tests have a registered correspondence with the requirements. 9737 tests remain unregistered.
- The above coverage rate is calculated only for the part which registered the response to the demand by confirming the stimulus and the expected result. Existing tests that are not registered are also useful for verification, but their contribution is not yet reflected in the proportion.
- The number of registered units is the number of units that correspond to at least one requirement, not the number of completed reviews of the whole test.

- The requests that are shared by multiple tests are in the 847 row. Only if all tests in each group are successful in the same run, they count as a success for the entire request.

<a id="確定値"></a>

## Definite value

- Requirement coverage (test design): 95.56%.
- Requirement execution-confirmation rate: 43.59% without Ghost, 79.78% with Ghost and kirimasim.
- Approval of denominator: Approval. The measured state is `confirmed`.
- The method was confirmed after document verification, resolution of the reservation interpretation, duplication of the requirement unit, and review of the denominator.

<a id="残件"></a>

## Remains

- There is a record of the path result corresponding to the current input: 9838 line.
- No record of passed/passout results: 1946 line.
- Test compatibility not confirmed (except for interpretation reservation): 548 line.
- Interpretation reservation: 0 line.

Unsupported behavior does not mean that no existing test is available.

<a id="シミュレータ別の実行確認率"></a>

## Execution confirmation rate by simulator

Each row is a separate saved run. A narrow run can leave many tests unexecuted; check [how to read dates, versions and scope](https://github.com/kurochan001/kirimasim-tests/blob/f029182b31bfe8fded04eeb649f19517d988ca97/docs/faq.en.md#q14-why-do-main-results-or-simulator-totals-differ) and the measurement source.

- `ghost` / `private build a4db8bcf783c` : 9817/12332 ( 79.61% )。 Measurement source: `2026-11-25T03:49:07.053617+00:00` / `ghost.json` 。 Failures 128; known mismatches 0; unsupported 0; not run 292; stale evidence 0; unapproved judgment evidence for illegal-design tests 1547 rows.
- `icarus` / `Icarus Verilog version 14.0 (devel) (s20260301-1291-g3f05f92b)` : 2710/12332 ( 21.98% )。 Measurement source: `2026-11-25T03:35:31.003215+00:00` / `icarus.json` 。 Failures 22; known mismatches 7603; unsupported 0; not run 292; stale evidence 0; unapproved judgment evidence for illegal-design tests 1157 rows.
- `kirimasim` / `kirimasim 0.2.2 (commit a50ec73c37d8), built with GNU 13.3.0` : 3172/12332 ( 25.72% )。 Measurement source: `2026-11-25T03:36:17.239103+00:00` / `kirimasim.json` 。 Failures 188; known mismatches 0; unsupported 6716; not run 292; stale evidence 0; unapproved judgment evidence for illegal-design tests 1416 rows.
- `lyra` / `Lyra (commit b1666593b9f4)` : 3841/12332 ( 31.15% )。 Measurement source: `2026-11-25T05:35:42.335225+00:00` / `lyra.json` 。 Failures 867; known mismatches 0; unsupported 5379; not run 292; stale evidence 0; unapproved judgment evidence for illegal-design tests 1405 rows.
- `verilator` / `Verilator 5.055 devel rev v5.054-394-g342ca8e0` : 3838/12332 ( 31.12% )。 Measurement source: `2026-11-25T04:56:24.137771+00:00` / `verilator.json` 。 Failures 27; known mismatches 6588; unsupported 0; not run 292; stale evidence 0; unapproved judgment evidence for illegal-design tests 1039 rows.
- The result file of the rejection: 0.

<a id="章附属書別登録項目に対する割合"></a>

## By chapter and appendix (percentage of registered items)

- 1 Overview: test mapping no registered items, execution confirmed no registered items, execution confirmed without Ghost no registered items, interpretation pending 0 rows.
- 2 Normative references: test mapping 0/2 ( 0.00% ), execution confirmed 0/2 ( 0.00% ), execution confirmed without Ghost 0/2 ( 0.00% ), interpretation pending 0 rows.
- 3 Design and verification building blocks: test mapping 142/146 ( 97.26% ), execution confirmed 119/146 ( 81.51% ), execution confirmed without Ghost 110/146 ( 75.34% ), interpretation pending 0 rows.
- 4 Scheduling semantics: test mapping 93/107 ( 86.92% ), execution confirmed 91/107 ( 85.05% ), execution confirmed without Ghost 60/107 ( 56.07% ), interpretation pending 0 rows.
- 5 Lexical conventions: test mapping 148/155 ( 95.48% ), execution confirmed 130/155 ( 83.87% ), execution confirmed without Ghost 120/155 ( 77.42% ), interpretation pending 0 rows.
- 6 Data types: test mapping 715/720 ( 99.31% ), execution confirmed 581/720 ( 80.69% ), execution confirmed without Ghost 463/720 ( 64.31% ), interpretation pending 0 rows.
- 7 Aggregate data types: test mapping 343/347 ( 98.85% ), execution confirmed 273/347 ( 78.67% ), execution confirmed without Ghost 166/347 ( 47.84% ), interpretation pending 0 rows.
- 8 Classes: test mapping 243/255 ( 95.29% ), execution confirmed 153/255 ( 60.00% ), execution confirmed without Ghost 117/255 ( 45.88% ), interpretation pending 0 rows.
- 9 Processes: test mapping 185/192 ( 96.35% ), execution confirmed 161/192 ( 83.85% ), execution confirmed without Ghost 109/192 ( 56.77% ), interpretation pending 0 rows.
- 10 Assignment statements: test mapping 153/156 ( 98.08% ), execution confirmed 111/156 ( 71.15% ), execution confirmed without Ghost 68/156 ( 43.59% ), interpretation pending 0 rows.
- 11 Operators and expressions: test mapping 455/459 ( 99.13% ), execution confirmed 417/459 ( 90.85% ), execution confirmed without Ghost 351/459 ( 76.47% ), interpretation pending 0 rows.
- 12 Procedural programming statements: test mapping 110/115 ( 95.65% ), execution confirmed 95/115 ( 82.61% ), execution confirmed without Ghost 51/115 ( 44.35% ), interpretation pending 0 rows.
- 13 Tasks and functions (subroutines): test mapping 121/124 ( 97.58% ), execution confirmed 76/124 ( 61.29% ), execution confirmed without Ghost 62/124 ( 50.00% ), interpretation pending 0 rows.
- 14 Clocking blocks: test mapping 87/87 ( 100.00% ), execution confirmed 67/87 ( 77.01% ), execution confirmed without Ghost 49/87 ( 56.32% ), interpretation pending 0 rows.
- 15 Interprocess synchronization and communication: test mapping 86/88 ( 97.73% ), execution confirmed 78/88 ( 88.64% ), execution confirmed without Ghost 47/88 ( 53.41% ), interpretation pending 0 rows.
- 16 Assertions: test mapping 556/557 ( 99.82% ), execution confirmed 406/557 ( 72.89% ), execution confirmed without Ghost 68/557 ( 12.21% ), interpretation pending 0 rows.
- 17 Checkers: test mapping 70/81 ( 86.42% ), execution confirmed 44/81 ( 54.32% ), execution confirmed without Ghost 9/81 ( 11.11% ), interpretation pending 0 rows.
- 18 Constrained random value generation: test mapping 317/323 ( 98.14% ), execution confirmed 255/323 ( 78.95% ), execution confirmed without Ghost 138/323 ( 42.72% ), interpretation pending 0 rows.
- 19 Functional coverage: test mapping 271/276 ( 98.19% ), execution confirmed 213/276 ( 77.17% ), execution confirmed without Ghost 36/276 ( 13.04% ), interpretation pending 0 rows.
- 20 Utility system tasks and system functions: test mapping 314/320 ( 98.12% ), execution confirmed 296/320 ( 92.50% ), execution confirmed without Ghost 132/320 ( 41.25% ), interpretation pending 0 rows.
- 21 Input/output system tasks and system functions: test mapping 375/383 ( 97.91% ), execution confirmed 358/383 ( 93.47% ), execution confirmed without Ghost 228/383 ( 59.53% ), interpretation pending 0 rows.
- 22 Compiler directives: test mapping 357/363 ( 98.35% ), execution confirmed 78/363 ( 21.49% ), execution confirmed without Ghost 74/363 ( 20.39% ), interpretation pending 0 rows.
- 23 Modules and hierarchy: test mapping 258/260 ( 99.23% ), execution confirmed 196/260 ( 75.38% ), execution confirmed without Ghost 101/260 ( 38.85% ), interpretation pending 0 rows.
- 24 Programs: test mapping 26/29 ( 89.66% ), execution confirmed 19/29 ( 65.52% ), execution confirmed without Ghost 3/29 ( 10.34% ), interpretation pending 0 rows.
- 25 Interfaces: test mapping 62/63 ( 98.41% ), execution confirmed 33/63 ( 52.38% ), execution confirmed without Ghost 20/63 ( 31.75% ), interpretation pending 0 rows.
- 26 Packages: test mapping 44/44 ( 100.00% ), execution confirmed 26/44 ( 59.09% ), execution confirmed without Ghost 24/44 ( 54.55% ), interpretation pending 0 rows.
- 27 Generate constructs: test mapping 32/32 ( 100.00% ), execution confirmed 16/32 ( 50.00% ), execution confirmed without Ghost 11/32 ( 34.38% ), interpretation pending 0 rows.
- 28 Gate-level and switch-level modeling: test mapping 384/384 ( 100.00% ), execution confirmed 370/384 ( 96.35% ), execution confirmed without Ghost 344/384 ( 89.58% ), interpretation pending 0 rows.
- 29 User-defined primitives: test mapping 52/52 ( 100.00% ), execution confirmed 34/52 ( 65.38% ), execution confirmed without Ghost 30/52 ( 57.69% ), interpretation pending 0 rows.
- 30 Specify blocks: test mapping 151/157 ( 96.18% ), execution confirmed 139/157 ( 88.54% ), execution confirmed without Ghost 110/157 ( 70.06% ), interpretation pending 0 rows.
- 31 Timing checks: test mapping 171/180 ( 95.00% ), execution confirmed 142/180 ( 78.89% ), execution confirmed without Ghost 11/180 ( 6.11% ), interpretation pending 0 rows.
- 32 Backannotation using the standard delay format: test mapping 131/131 ( 100.00% ), execution confirmed 119/131 ( 90.84% ), execution confirmed without Ghost 65/131 ( 49.62% ), interpretation pending 0 rows.
- 33 Configuring the contents of a design: test mapping 41/63 ( 65.08% ), execution confirmed 28/63 ( 44.44% ), execution confirmed without Ghost 7/63 ( 11.11% ), interpretation pending 0 rows.
- 34 Protected envelopes: test mapping 5/214 ( 2.34% ), execution confirmed 5/214 ( 2.34% ), execution confirmed without Ghost 5/214 ( 2.34% ), interpretation pending 0 rows.
- 35 Direct programming interface: test mapping 126/143 ( 88.11% ), execution confirmed 109/143 ( 76.22% ), execution confirmed without Ghost 79/143 ( 55.24% ), interpretation pending 0 rows.
- 36 Programming language interface ( PLI / VPI ) overview: test mapping 148/163 ( 90.80% ), execution confirmed 145/163 ( 88.96% ), execution confirmed without Ghost 43/163 ( 26.38% ), interpretation pending 0 rows.
- 37 VPI object model diagrams: test mapping 1693/1757 ( 96.36% ), execution confirmed 1678/1757 ( 95.50% ), execution confirmed without Ghost 73/1757 ( 4.15% ), interpretation pending 0 rows.
- 38 VPI routine definitions: test mapping 319/348 ( 91.67% ), execution confirmed 297/348 ( 85.34% ), execution confirmed without Ghost 150/348 ( 43.10% ), interpretation pending 0 rows.
- 39 Assertion API : test mapping 95/95 ( 100.00% ), execution confirmed 90/95 ( 94.74% ), execution confirmed without Ghost 2/95 ( 2.11% ), interpretation pending 0 rows.
- 40 Code coverage control and API : test mapping 124/128 ( 96.88% ), execution confirmed 124/128 ( 96.88% ), execution confirmed without Ghost 34/128 ( 26.56% ), interpretation pending 0 rows.
- 41 Data read API : test mapping no registered items, execution confirmed no registered items, execution confirmed without Ghost no registered items, interpretation pending 0 rows.
- A Formal syntax: test mapping 804/811 ( 99.14% ), execution confirmed 801/811 ( 98.77% ), execution confirmed without Ghost 537/811 ( 66.21% ), interpretation pending 0 rows.
- B Keywords: test mapping 248/248 ( 100.00% ), execution confirmed 0/248 ( 0.00% ), execution confirmed without Ghost 0/248 ( 0.00% ), interpretation pending 0 rows.
- C Deprecation: test mapping 14/20 ( 70.00% ), execution confirmed 14/20 ( 70.00% ), execution confirmed without Ghost 9/20 ( 45.00% ), interpretation pending 0 rows.
- D Optional system tasks and system functions: test mapping no registered items, execution confirmed no registered items, execution confirmed without Ghost no registered items, interpretation pending 0 rows.
- E Optional compiler directives: test mapping no registered items, execution confirmed no registered items, execution confirmed without Ghost no registered items, interpretation pending 0 rows.
- F Formal semantics of concurrent assertions: test mapping 253/253 ( 100.00% ), execution confirmed 0/253 ( 0.00% ), execution confirmed without Ghost 0/253 ( 0.00% ), interpretation pending 0 rows.
- G Std package: test mapping 32/32 ( 100.00% ), execution confirmed 30/32 ( 93.75% ), execution confirmed without Ghost 20/32 ( 62.50% ), interpretation pending 0 rows.
- H DPI C layer: test mapping 209/223 ( 93.72% ), execution confirmed 203/223 ( 91.03% ), execution confirmed without Ghost 136/223 ( 60.99% ), interpretation pending 0 rows.
- I svdpi.h : test mapping 144/147 ( 97.96% ), execution confirmed 142/147 ( 96.60% ), execution confirmed without Ghost 115/147 ( 78.23% ), interpretation pending 0 rows.
- J Inclusion of foreign language code: test mapping 1/16 ( 6.25% ), execution confirmed 1/16 ( 6.25% ), execution confirmed without Ghost 1/16 ( 6.25% ), interpretation pending 0 rows.
- K vpi_user.h : test mapping 543/544 ( 99.82% ), execution confirmed 543/544 ( 99.82% ), execution confirmed without Ghost 542/544 ( 99.63% ), interpretation pending 0 rows.
- L vpi_compatibility.h : test mapping 86/88 ( 97.73% ), execution confirmed 86/88 ( 97.73% ), execution confirmed without Ghost 0/88 ( 0.00% ), interpretation pending 0 rows.
- M sv_vpi_user.h : test mapping 410/412 ( 99.51% ), execution confirmed 409/412 ( 99.27% ), execution confirmed without Ghost 408/412 ( 99.03% ), interpretation pending 0 rows.
- N Algorithm for probabilistic distribution functions: test mapping 37/39 ( 94.87% ), execution confirmed 37/39 ( 94.87% ), execution confirmed without Ghost 37/39 ( 94.87% ), interpretation pending 0 rows.
- O Encryption/decryption flow: test mapping no registered items, execution confirmed no registered items, execution confirmed without Ghost no registered items, interpretation pending 0 rows.
- P Glossary: test mapping no registered items, execution confirmed no registered items, execution confirmed without Ghost no registered items, interpretation pending 0 rows.
- Q Bibliography: test mapping no registered items, execution confirmed no registered items, execution confirmed without Ghost no registered items, interpretation pending 0 rows.

<a id="分母と履歴"></a>

## Denominator and history

- The denominator is SHA-256 : `a3d47f5d87302c0e374bc9c89c0ae6aba592aa34d04e7c14f3cbf4381dc4da1f`.
- Version of the measurement rule: 3.
- The history stores the identifier of the denominator, the provisional and definitive values, and the state summary by environment. The ratio of the rounds with different denominators is not compared as improvement or deterioration.
- This aggregation is re-generated from the saved execution trace. The above time of measurement is the time of execution.
