<a id="ieee-1800-2023-要求カバレッジ集計"></a>

# IEEE 1800-2023 requirement coverage aggregation

[English](behavior-coverage-summary.en.md) / [日本語](behavior-coverage-summary.md)

[Details of all items](behavior-coverage.en.md) / [Management procedures](https://github.com/kurochan001/kirimasim-tests/blob/fcaeb425934d56b79c76332d8dc15c3a9092afa9/coverage/README.en.md) / [Interpretation and Re-examination Record](https://github.com/kurochan001/kirimasim-tests/blob/fcaeb425934d56b79c76332d8dc15c3a9092afa9/docs/requirement-extraction-notes.en.md)

The denominator counts requirement-ledger rows, not test files. See [Design, execution and PASS distinctions](https://github.com/kurochan001/kirimasim-tests/blob/fcaeb425934d56b79c76332d8dc15c3a9092afa9/docs/faq.en.md#q16-how-do-design-and-execution-coverage-differ) for concrete examples.

<a id="全規格の要求台帳に対する値"></a>

## Value for all standards in the required table

- Requirement coverage (test design): 99.04% ( 12214/12332 ).
- Execution confirmation rate without Ghost: 43.72% ( 5392/12332 ). Union of successes on Icarus Verilog, Verilator and SymbiYosys, which third parties can reproduce. Of these, 5392 rows are confirmed by a simulator and 0 rows by formal checks alone.
- The execution confirmation rate is 46.73% ( 5763/12332 ). Union of successes across environments. Of these, 5763 rows are confirmed by a simulator and 0 rows by formal checks alone.
- The denominator includes pending interpretations and items without test mappings. We do not exclude non-implemented and non-supported.
- The registration unit is the occurrence point, condition, and observation case of the requirement, and the duplication of meaning is integrated by the review of the denominator. This is neither the fraction of all program/input combinations tested nor a single simulator's standard conformance rate.

<a id="既存テストの集計状況"></a>

## Aggregation of existing tests

- 7383 of 17120 tests have a registered correspondence with the requirements. 9737 tests remain unregistered.
- The above coverage rate is calculated only for the part which registered the response to the demand by confirming the stimulus and the expected result. Existing tests that are not registered are also useful for verification, but their contribution is not yet reflected in the proportion.
- The number of registered units is the number of units that correspond to at least one requirement, not the number of completed reviews of the whole test.

- The requests that are shared by multiple tests are in the 874 row. Only if all tests in each group are successful in the same run, they count as a success for the entire request.

<a id="確定値"></a>

## Definite value

- Requirement coverage (test design): 99.04%.
- Requirement execution-confirmation rate: 43.72% without Ghost, 46.73% with Ghost and kirimasim.
- Approval of denominator: Approval. The measured state is `confirmed`.
- The method was confirmed after document verification, resolution of the reservation interpretation, duplication of the requirement unit, and review of the denominator.

<a id="残件"></a>

## Remains

- There is a record of the path result corresponding to the current input: 5763 line.
- No record of passed/passout results: 6451 line.
- Test compatibility not confirmed (except for interpretation reservation): 118 line.
- Interpretation reservation: 0 line.

Unsupported behavior does not mean that no existing test is available.

<a id="シミュレータ別の実行確認率"></a>

## Execution confirmation rate by simulator

Each row is a separate saved run. A narrow run can leave many tests unexecuted; check [how to read dates, versions and scope](https://github.com/kurochan001/kirimasim-tests/blob/fcaeb425934d56b79c76332d8dc15c3a9092afa9/docs/faq.en.md#q14-why-do-main-results-or-simulator-totals-differ) and the measurement source.

- `icarus` / `Icarus Verilog version 14.0 (devel) (s20260301-1293-g24acba16)` : 2719/12332 ( 22.05% )。 Measurement source: `2026-11-27T02:22:09.184406+00:00` / `icarus.json` 。 Failures 22; known mismatches 7661; unsupported 0; not run 655; stale evidence 0; unapproved judgment evidence for illegal-design tests 1157 rows.
- `kirimasim` / `kirimasim 0.3.0 (commit b1ad0cb96a40), built with GNU 13.3.0` : 3180/12332 ( 25.79% )。 Measurement source: `2026-11-27T02:44:27.541304+00:00` / `kirimasim.json` 。 Failures 189; known mismatches 0; unsupported 6774; not run 655; stale evidence 0; unapproved judgment evidence for illegal-design tests 1416 rows.
- `verilator` / `Verilator 5.055 devel rev v5.054-410-g43872a41` : 3853/12332 ( 31.24% )。 Measurement source: `2026-11-27T05:01:49.854477+00:00` / `verilator.json` 。 Failures 27; known mismatches 6632; unsupported 0; not run 655; stale evidence 0; unapproved judgment evidence for illegal-design tests 1047 rows.
- The result file of the rejection: 0.

<a id="章附属書別登録項目に対する割合"></a>

## By chapter and appendix (percentage of registered items)

- 1 Overview: test mapping no registered items, execution confirmed no registered items, execution confirmed without Ghost no registered items, interpretation pending 0 rows.
- 2 Normative references: test mapping 0/2 ( 0.00% ), execution confirmed 0/2 ( 0.00% ), execution confirmed without Ghost 0/2 ( 0.00% ), interpretation pending 0 rows.
- 3 Design and verification building blocks: test mapping 146/146 ( 100.00% ), execution confirmed 113/146 ( 77.40% ), execution confirmed without Ghost 110/146 ( 75.34% ), interpretation pending 0 rows.
- 4 Scheduling semantics: test mapping 95/107 ( 88.79% ), execution confirmed 75/107 ( 70.09% ), execution confirmed without Ghost 60/107 ( 56.07% ), interpretation pending 0 rows.
- 5 Lexical conventions: test mapping 155/155 ( 100.00% ), execution confirmed 125/155 ( 80.65% ), execution confirmed without Ghost 122/155 ( 78.71% ), interpretation pending 0 rows.
- 6 Data types: test mapping 720/720 ( 100.00% ), execution confirmed 484/720 ( 67.22% ), execution confirmed without Ghost 464/720 ( 64.44% ), interpretation pending 0 rows.
- 7 Aggregate data types: test mapping 345/347 ( 99.42% ), execution confirmed 188/347 ( 54.18% ), execution confirmed without Ghost 166/347 ( 47.84% ), interpretation pending 0 rows.
- 8 Classes: test mapping 249/255 ( 97.65% ), execution confirmed 127/255 ( 49.80% ), execution confirmed without Ghost 117/255 ( 45.88% ), interpretation pending 0 rows.
- 9 Processes: test mapping 191/192 ( 99.48% ), execution confirmed 140/192 ( 72.92% ), execution confirmed without Ghost 112/192 ( 58.33% ), interpretation pending 0 rows.
- 10 Assignment statements: test mapping 156/156 ( 100.00% ), execution confirmed 92/156 ( 58.97% ), execution confirmed without Ghost 68/156 ( 43.59% ), interpretation pending 0 rows.
- 11 Operators and expressions: test mapping 459/459 ( 100.00% ), execution confirmed 382/459 ( 83.22% ), execution confirmed without Ghost 351/459 ( 76.47% ), interpretation pending 0 rows.
- 12 Procedural programming statements: test mapping 115/115 ( 100.00% ), execution confirmed 70/115 ( 60.87% ), execution confirmed without Ghost 52/115 ( 45.22% ), interpretation pending 0 rows.
- 13 Tasks and functions (subroutines): test mapping 124/124 ( 100.00% ), execution confirmed 71/124 ( 57.26% ), execution confirmed without Ghost 64/124 ( 51.61% ), interpretation pending 0 rows.
- 14 Clocking blocks: test mapping 87/87 ( 100.00% ), execution confirmed 51/87 ( 58.62% ), execution confirmed without Ghost 49/87 ( 56.32% ), interpretation pending 0 rows.
- 15 Interprocess synchronization and communication: test mapping 88/88 ( 100.00% ), execution confirmed 48/88 ( 54.55% ), execution confirmed without Ghost 47/88 ( 53.41% ), interpretation pending 0 rows.
- 16 Assertions: test mapping 557/557 ( 100.00% ), execution confirmed 83/557 ( 14.90% ), execution confirmed without Ghost 70/557 ( 12.57% ), interpretation pending 0 rows.
- 17 Checkers: test mapping 77/81 ( 95.06% ), execution confirmed 9/81 ( 11.11% ), execution confirmed without Ghost 9/81 ( 11.11% ), interpretation pending 0 rows.
- 18 Constrained random value generation: test mapping 323/323 ( 100.00% ), execution confirmed 143/323 ( 44.27% ), execution confirmed without Ghost 139/323 ( 43.03% ), interpretation pending 0 rows.
- 19 Functional coverage: test mapping 275/276 ( 99.64% ), execution confirmed 36/276 ( 13.04% ), execution confirmed without Ghost 36/276 ( 13.04% ), interpretation pending 0 rows.
- 20 Utility system tasks and system functions: test mapping 320/320 ( 100.00% ), execution confirmed 154/320 ( 48.12% ), execution confirmed without Ghost 133/320 ( 41.56% ), interpretation pending 0 rows.
- 21 Input/output system tasks and system functions: test mapping 383/383 ( 100.00% ), execution confirmed 249/383 ( 65.01% ), execution confirmed without Ghost 229/383 ( 59.79% ), interpretation pending 0 rows.
- 22 Compiler directives: test mapping 363/363 ( 100.00% ), execution confirmed 76/363 ( 20.94% ), execution confirmed without Ghost 73/363 ( 20.11% ), interpretation pending 0 rows.
- 23 Modules and hierarchy: test mapping 260/260 ( 100.00% ), execution confirmed 141/260 ( 54.23% ), execution confirmed without Ghost 101/260 ( 38.85% ), interpretation pending 0 rows.
- 24 Programs: test mapping 29/29 ( 100.00% ), execution confirmed 18/29 ( 62.07% ), execution confirmed without Ghost 3/29 ( 10.34% ), interpretation pending 0 rows.
- 25 Interfaces: test mapping 62/63 ( 98.41% ), execution confirmed 23/63 ( 36.51% ), execution confirmed without Ghost 20/63 ( 31.75% ), interpretation pending 0 rows.
- 26 Packages: test mapping 44/44 ( 100.00% ), execution confirmed 25/44 ( 56.82% ), execution confirmed without Ghost 24/44 ( 54.55% ), interpretation pending 0 rows.
- 27 Generate constructs: test mapping 32/32 ( 100.00% ), execution confirmed 14/32 ( 43.75% ), execution confirmed without Ghost 11/32 ( 34.38% ), interpretation pending 0 rows.
- 28 Gate-level and switch-level modeling: test mapping 384/384 ( 100.00% ), execution confirmed 348/384 ( 90.62% ), execution confirmed without Ghost 344/384 ( 89.58% ), interpretation pending 0 rows.
- 29 User-defined primitives: test mapping 52/52 ( 100.00% ), execution confirmed 33/52 ( 63.46% ), execution confirmed without Ghost 30/52 ( 57.69% ), interpretation pending 0 rows.
- 30 Specify blocks: test mapping 151/157 ( 96.18% ), execution confirmed 111/157 ( 70.70% ), execution confirmed without Ghost 110/157 ( 70.06% ), interpretation pending 0 rows.
- 31 Timing checks: test mapping 176/180 ( 97.78% ), execution confirmed 11/180 ( 6.11% ), execution confirmed without Ghost 11/180 ( 6.11% ), interpretation pending 0 rows.
- 32 Backannotation using the standard delay format: test mapping 131/131 ( 100.00% ), execution confirmed 65/131 ( 49.62% ), execution confirmed without Ghost 65/131 ( 49.62% ), interpretation pending 0 rows.
- 33 Configuring the contents of a design: test mapping 61/63 ( 96.83% ), execution confirmed 24/63 ( 38.10% ), execution confirmed without Ghost 7/63 ( 11.11% ), interpretation pending 0 rows.
- 34 Protected envelopes: test mapping 191/214 ( 89.25% ), execution confirmed 5/214 ( 2.34% ), execution confirmed without Ghost 5/214 ( 2.34% ), interpretation pending 0 rows.
- 35 Direct programming interface: test mapping 143/143 ( 100.00% ), execution confirmed 79/143 ( 55.24% ), execution confirmed without Ghost 79/143 ( 55.24% ), interpretation pending 0 rows.
- 36 Programming language interface ( PLI / VPI ) overview: test mapping 161/163 ( 98.77% ), execution confirmed 43/163 ( 26.38% ), execution confirmed without Ghost 43/163 ( 26.38% ), interpretation pending 0 rows.
- 37 VPI object model diagrams: test mapping 1724/1757 ( 98.12% ), execution confirmed 74/1757 ( 4.21% ), execution confirmed without Ghost 74/1757 ( 4.21% ), interpretation pending 0 rows.
- 38 VPI routine definitions: test mapping 333/348 ( 95.69% ), execution confirmed 150/348 ( 43.10% ), execution confirmed without Ghost 150/348 ( 43.10% ), interpretation pending 0 rows.
- 39 Assertion API : test mapping 95/95 ( 100.00% ), execution confirmed 2/95 ( 2.11% ), execution confirmed without Ghost 2/95 ( 2.11% ), interpretation pending 0 rows.
- 40 Code coverage control and API : test mapping 127/128 ( 99.22% ), execution confirmed 34/128 ( 26.56% ), execution confirmed without Ghost 34/128 ( 26.56% ), interpretation pending 0 rows.
- 41 Data read API : test mapping no registered items, execution confirmed no registered items, execution confirmed without Ghost no registered items, interpretation pending 0 rows.
- A Formal syntax: test mapping 811/811 ( 100.00% ), execution confirmed 576/811 ( 71.02% ), execution confirmed without Ghost 537/811 ( 66.21% ), interpretation pending 0 rows.
- B Keywords: test mapping 248/248 ( 100.00% ), execution confirmed 0/248 ( 0.00% ), execution confirmed without Ghost 0/248 ( 0.00% ), interpretation pending 0 rows.
- C Deprecation: test mapping 20/20 ( 100.00% ), execution confirmed 11/20 ( 55.00% ), execution confirmed without Ghost 11/20 ( 55.00% ), interpretation pending 0 rows.
- D Optional system tasks and system functions: test mapping no registered items, execution confirmed no registered items, execution confirmed without Ghost no registered items, interpretation pending 0 rows.
- E Optional compiler directives: test mapping no registered items, execution confirmed no registered items, execution confirmed without Ghost no registered items, interpretation pending 0 rows.
- F Formal semantics of concurrent assertions: test mapping 253/253 ( 100.00% ), execution confirmed 0/253 ( 0.00% ), execution confirmed without Ghost 0/253 ( 0.00% ), interpretation pending 0 rows.
- G Std package: test mapping 32/32 ( 100.00% ), execution confirmed 20/32 ( 62.50% ), execution confirmed without Ghost 20/32 ( 62.50% ), interpretation pending 0 rows.
- H DPI C layer: test mapping 221/223 ( 99.10% ), execution confirmed 137/223 ( 61.43% ), execution confirmed without Ghost 137/223 ( 61.43% ), interpretation pending 0 rows.
- I svdpi.h : test mapping 147/147 ( 100.00% ), execution confirmed 115/147 ( 78.23% ), execution confirmed without Ghost 115/147 ( 78.23% ), interpretation pending 0 rows.
- J Inclusion of foreign language code: test mapping 16/16 ( 100.00% ), execution confirmed 1/16 ( 6.25% ), execution confirmed without Ghost 1/16 ( 6.25% ), interpretation pending 0 rows.
- K vpi_user.h : test mapping 543/544 ( 99.82% ), execution confirmed 542/544 ( 99.63% ), execution confirmed without Ghost 542/544 ( 99.63% ), interpretation pending 0 rows.
- L vpi_compatibility.h : test mapping 88/88 ( 100.00% ), execution confirmed 0/88 ( 0.00% ), execution confirmed without Ghost 0/88 ( 0.00% ), interpretation pending 0 rows.
- M sv_vpi_user.h : test mapping 412/412 ( 100.00% ), execution confirmed 408/412 ( 99.03% ), execution confirmed without Ghost 408/412 ( 99.03% ), interpretation pending 0 rows.
- N Algorithm for probabilistic distribution functions: test mapping 39/39 ( 100.00% ), execution confirmed 37/39 ( 94.87% ), execution confirmed without Ghost 37/39 ( 94.87% ), interpretation pending 0 rows.
- O Encryption/decryption flow: test mapping no registered items, execution confirmed no registered items, execution confirmed without Ghost no registered items, interpretation pending 0 rows.
- P Glossary: test mapping no registered items, execution confirmed no registered items, execution confirmed without Ghost no registered items, interpretation pending 0 rows.
- Q Bibliography: test mapping no registered items, execution confirmed no registered items, execution confirmed without Ghost no registered items, interpretation pending 0 rows.

<a id="分母と履歴"></a>

## Denominator and history

- The denominator is SHA-256 : `bae424aa6bcc0019f8e9e00914d6bcf419a5c018b4ed9e74d5a03ae70a0339ea`.
- Version of the measurement rule: 3.
- The history stores the identifier of the denominator, the provisional and definitive values, and the state summary by environment. The ratio of the rounds with different denominators is not compared as improvement or deterioration.
- This aggregation is re-generated from the saved execution trace. The above time of measurement is the time of execution.
