<a id="ieee-1800-2023-要求カバレッジ集計"></a>

# IEEE 1800-2023 requirement coverage aggregation

[English](behavior-coverage-summary.en.md) / [日本語](behavior-coverage-summary.md)

[Details of all items](behavior-coverage.en.md) / [Management procedures](https://github.com/kurochan001/kirimasim-tests/blob/a155aec8d7a87178f5abfa352286105aa5afbb58/coverage/README.en.md) / [Interpretation and Re-examination Record](https://github.com/kurochan001/kirimasim-tests/blob/a155aec8d7a87178f5abfa352286105aa5afbb58/docs/requirement-extraction-notes.en.md)

The denominator counts requirement-ledger rows, not test files. See [Design, execution and PASS distinctions](https://github.com/kurochan001/kirimasim-tests/blob/a155aec8d7a87178f5abfa352286105aa5afbb58/docs/faq.en.md#q16-how-do-design-and-execution-coverage-differ) for concrete examples.

<a id="全規格の要求台帳に対する値"></a>

## Value for all standards in the required table

- Requirement coverage (test design): 90.14% ( 11086/12298 ).
- Execution confirmation rate without Ghost: 42.21% ( 5191/12298 ). Union of successes on Icarus Verilog, Verilator and SymbiYosys, which third parties can reproduce.
- The execution confirmation rate is 73.97% ( 9097/12298 ). Union of successes across environments.
- The denominator includes pending interpretations and items without test mappings. We do not exclude non-implemented and non-supported.
- The registration unit is the occurrence point, condition, and observation case of the requirement, and the duplication of meaning is integrated by the review of the denominator. This is neither the fraction of all program/input combinations tested nor a single simulator's standard conformance rate.

<a id="既存テストの集計状況"></a>

## Aggregation of existing tests

- 12268 of 5400 tests have registered the correspondance with the requirements. 6868 tests remain unregistered.
- The above coverage rate is calculated only for the part which registered the response to the demand by confirming the stimulus and the expected result. Existing tests that are not registered are also useful for verification, but their contribution is not yet reflected in the proportion.
- The number of registered units is the number of units that correspond to at least one requirement, not the number of completed reviews of the whole test.

- The requests that are shared by multiple tests are in the 671 row. Only if all tests in each group are successful in the same run, they count as a success for the entire request.

<a id="確定値"></a>

## Definite value

- Requirement coverage (test design): 90.14%.
- Requirement execution-confirmation rate: 73.97%.
- Approval of denominator: Approval. The measured state is `confirmed`.
- The method was confirmed after document verification, resolution of the reservation interpretation, duplication of the requirement unit, and review of the denominator.

<a id="残件"></a>

## Remains

- There is a record of the path result corresponding to the current input: 9097 line.
- No record of passed/passout results: 1989 line.
- Test compatibility not confirmed (except for interpretation reservation): 1212 line.
- Interpretation reservation: 0 line.

Unsupported behavior does not mean that no existing test is available.

<a id="シミュレータ別の実行確認率"></a>

## Execution confirmation rate by simulator

Each row is a separate saved run. A narrow run can leave many tests unexecuted; check [how to read dates, versions and scope](https://github.com/kurochan001/kirimasim-tests/blob/a155aec8d7a87178f5abfa352286105aa5afbb58/docs/faq.en.md#q14-why-do-main-results-or-simulator-totals-differ) and the measurement source.

- `ghost` / `private build edda91f4108d` : 9030/12298 ( 73.43% )。 Measurement source: `2026-11-10T04:08:06.233930+00:00` / `ghost.json` 。 Failures 544; known mismatches 0; unsupported 0; not run 290; stale evidence 0; unapproved judgment evidence for illegal-design tests 1222 rows.
- `icarus` / `Icarus Verilog version 14.0 (devel) (s20260301-918-g3e2189b3)` : 2546/12298 ( 20.70% )。 Measurement source: `2026-11-10T03:50:15.606941+00:00` / `icarus.json` 。 Failures 21; known mismatches 7181; unsupported 0; not run 290; stale evidence 0; unapproved judgment evidence for illegal-design tests 1048 rows.
- `kirimasim` / `kirimasim 0.0.0 (commit 7de185f776a1), built with GNU 13.3.0` : 2992/12298 ( 24.33% )。 Measurement source: `2026-11-10T02:33:06.410048+00:00` / `kirimasim.json` 。 Failures 178; known mismatches 0; unsupported 6346; not run 290; stale evidence 0; unapproved judgment evidence for illegal-design tests 1280 rows.
- `lyra` / `Lyra (commit eaaea03805b3)` : 3488/12298 ( 28.36% )。 Measurement source: `2026-11-10T11:08:35.647817+00:00` / `lyra.json` 。 Failures 846; known mismatches 0; unsupported 5188; not run 290; stale evidence 0; unapproved judgment evidence for illegal-design tests 1274 rows.
- `verilator` / `Verilator 5.055 devel rev v5.054-182-g4ab62c3a` : 3723/12298 ( 30.27% )。 Measurement source: `2026-11-10T03:47:40.394696+00:00` / `verilator.json` 。 Failures 23; known mismatches 6076; unsupported 0; not run 290; stale evidence 0; unapproved judgment evidence for illegal-design tests 974 rows.
- The result file of the rejection: 0.

<a id="章附属書別登録項目に対する割合"></a>

## By chapter and appendix (percentage of registered items)

- 1 Overview: test mapping no registered items, execution confirmed no registered items, execution confirmed without Ghost no registered items, interpretation pending 0 rows.
- 2 Normative references: test mapping 0/2 ( 0.00% ), execution confirmed 0/2 ( 0.00% ), execution confirmed without Ghost 0/2 ( 0.00% ), interpretation pending 0 rows.
- 3 Design and verification building blocks: test mapping 118/146 ( 80.82% ), execution confirmed 102/146 ( 69.86% ), execution confirmed without Ghost 98/146 ( 67.12% ), interpretation pending 0 rows.
- 4 Scheduling semantics: test mapping 88/107 ( 82.24% ), execution confirmed 85/107 ( 79.44% ), execution confirmed without Ghost 58/107 ( 54.21% ), interpretation pending 0 rows.
- 5 Lexical conventions: test mapping 136/154 ( 88.31% ), execution confirmed 119/154 ( 77.27% ), execution confirmed without Ghost 116/154 ( 75.32% ), interpretation pending 0 rows.
- 6 Data types: test mapping 679/719 ( 94.44% ), execution confirmed 558/719 ( 77.61% ), execution confirmed without Ghost 452/719 ( 62.87% ), interpretation pending 0 rows.
- 7 Aggregate data types: test mapping 320/345 ( 92.75% ), execution confirmed 263/345 ( 76.23% ), execution confirmed without Ghost 154/345 ( 44.64% ), interpretation pending 0 rows.
- 8 Classes: test mapping 221/252 ( 87.70% ), execution confirmed 143/252 ( 56.75% ), execution confirmed without Ghost 113/252 ( 44.84% ), interpretation pending 0 rows.
- 9 Processes: test mapping 166/189 ( 87.83% ), execution confirmed 149/189 ( 78.84% ), execution confirmed without Ghost 100/189 ( 52.91% ), interpretation pending 0 rows.
- 10 Assignment statements: test mapping 130/156 ( 83.33% ), execution confirmed 94/156 ( 60.26% ), execution confirmed without Ghost 54/156 ( 34.62% ), interpretation pending 0 rows.
- 11 Operators and expressions: test mapping 433/459 ( 94.34% ), execution confirmed 398/459 ( 86.71% ), execution confirmed without Ghost 344/459 ( 74.95% ), interpretation pending 0 rows.
- 12 Procedural programming statements: test mapping 89/115 ( 77.39% ), execution confirmed 74/115 ( 64.35% ), execution confirmed without Ghost 46/115 ( 40.00% ), interpretation pending 0 rows.
- 13 Tasks and functions (subroutines): test mapping 92/119 ( 77.31% ), execution confirmed 62/119 ( 52.10% ), execution confirmed without Ghost 55/119 ( 46.22% ), interpretation pending 0 rows.
- 14 Clocking blocks: test mapping 84/87 ( 96.55% ), execution confirmed 66/87 ( 75.86% ), execution confirmed without Ghost 48/87 ( 55.17% ), interpretation pending 0 rows.
- 15 Interprocess synchronization and communication: test mapping 71/88 ( 80.68% ), execution confirmed 66/88 ( 75.00% ), execution confirmed without Ghost 44/88 ( 50.00% ), interpretation pending 0 rows.
- 16 Assertions: test mapping 539/555 ( 97.12% ), execution confirmed 389/555 ( 70.09% ), execution confirmed without Ghost 67/555 ( 12.07% ), interpretation pending 0 rows.
- 17 Checkers: test mapping 59/79 ( 74.68% ), execution confirmed 36/79 ( 45.57% ), execution confirmed without Ghost 9/79 ( 11.39% ), interpretation pending 0 rows.
- 18 Constrained random value generation: test mapping 300/320 ( 93.75% ), execution confirmed 234/320 ( 73.12% ), execution confirmed without Ghost 130/320 ( 40.62% ), interpretation pending 0 rows.
- 19 Functional coverage: test mapping 232/271 ( 85.61% ), execution confirmed 195/271 ( 71.96% ), execution confirmed without Ghost 34/271 ( 12.55% ), interpretation pending 0 rows.
- 20 Utility system tasks and system functions: test mapping 285/316 ( 90.19% ), execution confirmed 232/316 ( 73.42% ), execution confirmed without Ghost 124/316 ( 39.24% ), interpretation pending 0 rows.
- 21 Input/output system tasks and system functions: test mapping 347/383 ( 90.60% ), execution confirmed 333/383 ( 86.95% ), execution confirmed without Ghost 215/383 ( 56.14% ), interpretation pending 0 rows.
- 22 Compiler directives: test mapping 345/361 ( 95.57% ), execution confirmed 73/361 ( 20.22% ), execution confirmed without Ghost 69/361 ( 19.11% ), interpretation pending 0 rows.
- 23 Modules and hierarchy: test mapping 251/260 ( 96.54% ), execution confirmed 160/260 ( 61.54% ), execution confirmed without Ghost 105/260 ( 40.38% ), interpretation pending 0 rows.
- 24 Programs: test mapping 25/29 ( 86.21% ), execution confirmed 18/29 ( 62.07% ), execution confirmed without Ghost 2/29 ( 6.90% ), interpretation pending 0 rows.
- 25 Interfaces: test mapping 55/63 ( 87.30% ), execution confirmed 29/63 ( 46.03% ), execution confirmed without Ghost 19/63 ( 30.16% ), interpretation pending 0 rows.
- 26 Packages: test mapping 39/44 ( 88.64% ), execution confirmed 24/44 ( 54.55% ), execution confirmed without Ghost 22/44 ( 50.00% ), interpretation pending 0 rows.
- 27 Generate constructs: test mapping 27/32 ( 84.38% ), execution confirmed 14/32 ( 43.75% ), execution confirmed without Ghost 10/32 ( 31.25% ), interpretation pending 0 rows.
- 28 Gate-level and switch-level modeling: test mapping 363/384 ( 94.53% ), execution confirmed 356/384 ( 92.71% ), execution confirmed without Ghost 332/384 ( 86.46% ), interpretation pending 0 rows.
- 29 User-defined primitives: test mapping 49/52 ( 94.23% ), execution confirmed 34/52 ( 65.38% ), execution confirmed without Ghost 30/52 ( 57.69% ), interpretation pending 0 rows.
- 30 Specify blocks: test mapping 131/157 ( 83.44% ), execution confirmed 121/157 ( 77.07% ), execution confirmed without Ghost 101/157 ( 64.33% ), interpretation pending 0 rows.
- 31 Timing checks: test mapping 154/180 ( 85.56% ), execution confirmed 141/180 ( 78.33% ), execution confirmed without Ghost 14/180 ( 7.78% ), interpretation pending 0 rows.
- 32 Backannotation using the standard delay format: test mapping 119/131 ( 90.84% ), execution confirmed 119/131 ( 90.84% ), execution confirmed without Ghost 65/131 ( 49.62% ), interpretation pending 0 rows.
- 33 Configuring the contents of a design: test mapping 40/63 ( 63.49% ), execution confirmed 25/63 ( 39.68% ), execution confirmed without Ghost 7/63 ( 11.11% ), interpretation pending 0 rows.
- 34 Protected envelopes: test mapping 5/214 ( 2.34% ), execution confirmed 5/214 ( 2.34% ), execution confirmed without Ghost 5/214 ( 2.34% ), interpretation pending 0 rows.
- 35 Direct programming interface: test mapping 114/142 ( 80.28% ), execution confirmed 105/142 ( 73.94% ), execution confirmed without Ghost 73/142 ( 51.41% ), interpretation pending 0 rows.
- 36 Programming language interface ( PLI / VPI ) overview: test mapping 148/163 ( 90.80% ), execution confirmed 119/163 ( 73.01% ), execution confirmed without Ghost 43/163 ( 26.38% ), interpretation pending 0 rows.
- 37 VPI object model diagrams: test mapping 1656/1757 ( 94.25% ), execution confirmed 1502/1757 ( 85.49% ), execution confirmed without Ghost 72/1757 ( 4.10% ), interpretation pending 0 rows.
- 38 VPI routine definitions: test mapping 260/348 ( 74.71% ), execution confirmed 254/348 ( 72.99% ), execution confirmed without Ghost 145/348 ( 41.67% ), interpretation pending 0 rows.
- 39 Assertion API : test mapping 82/95 ( 86.32% ), execution confirmed 82/95 ( 86.32% ), execution confirmed without Ghost 2/95 ( 2.11% ), interpretation pending 0 rows.
- 40 Code coverage control and API : test mapping 122/128 ( 95.31% ), execution confirmed 121/128 ( 94.53% ), execution confirmed without Ghost 34/128 ( 26.56% ), interpretation pending 0 rows.
- 41 Data read API : test mapping no registered items, execution confirmed no registered items, execution confirmed without Ghost no registered items, interpretation pending 0 rows.
- A Formal syntax: test mapping 792/811 ( 97.66% ), execution confirmed 779/811 ( 96.05% ), execution confirmed without Ghost 534/811 ( 65.84% ), interpretation pending 0 rows.
- B Keywords: test mapping 248/248 ( 100.00% ), execution confirmed 0/248 ( 0.00% ), execution confirmed without Ghost 0/248 ( 0.00% ), interpretation pending 0 rows.
- C Deprecation: test mapping 9/20 ( 45.00% ), execution confirmed 9/20 ( 45.00% ), execution confirmed without Ghost 7/20 ( 35.00% ), interpretation pending 0 rows.
- D Optional system tasks and system functions: test mapping no registered items, execution confirmed no registered items, execution confirmed without Ghost no registered items, interpretation pending 0 rows.
- E Optional compiler directives: test mapping no registered items, execution confirmed no registered items, execution confirmed without Ghost no registered items, interpretation pending 0 rows.
- F Formal semantics of concurrent assertions: test mapping 253/253 ( 100.00% ), execution confirmed 0/253 ( 0.00% ), execution confirmed without Ghost 0/253 ( 0.00% ), interpretation pending 0 rows.
- G Std package: test mapping 25/32 ( 78.12% ), execution confirmed 25/32 ( 78.12% ), execution confirmed without Ghost 18/32 ( 56.25% ), interpretation pending 0 rows.
- H DPI C layer: test mapping 190/223 ( 85.20% ), execution confirmed 190/223 ( 85.20% ), execution confirmed without Ghost 133/223 ( 59.64% ), interpretation pending 0 rows.
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

- The denominator is SHA-256 : `c723d62a3ab5f7550bd4a03393e6530b2740d8f39e072a8cc04dad415789639c`.
- Version of the measurement rule: 3.
- The history stores the identifier of the denominator, the provisional and definitive values, and the state summary by environment. The ratio of the rounds with different denominators is not compared as improvement or deterioration.
- This aggregation is re-generated from the saved execution trace. The above time of measurement is the time of execution.
