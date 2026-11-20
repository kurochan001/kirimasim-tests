<a id="ieee-1800-2023-要求カバレッジ集計"></a>

# IEEE 1800-2023 requirement coverage aggregation

[English](behavior-coverage-summary.en.md) / [日本語](behavior-coverage-summary.md)

[Details of all items](behavior-coverage.en.md) / [Management procedures](https://github.com/kurochan001/kirimasim-tests/blob/7e233e9afefc1a6e975ef85ed0ea7cffddb158de/coverage/README.en.md) / [Interpretation and Re-examination Record](https://github.com/kurochan001/kirimasim-tests/blob/7e233e9afefc1a6e975ef85ed0ea7cffddb158de/docs/requirement-extraction-notes.en.md)

The denominator counts requirement-ledger rows, not test files. See [Design, execution and PASS distinctions](https://github.com/kurochan001/kirimasim-tests/blob/7e233e9afefc1a6e975ef85ed0ea7cffddb158de/docs/faq.en.md#q16-how-do-design-and-execution-coverage-differ) for concrete examples.

<a id="全規格の要求台帳に対する値"></a>

## Value for all standards in the required table

- Requirement coverage (test design): 93.13% ( 11485/12332 ).
- Execution confirmation rate without Ghost: 30.74% ( 3791/12332 ). Union of successes on Icarus Verilog, Verilator and SymbiYosys, which third parties can reproduce. Of these, 3791 rows are confirmed by a simulator and 0 rows by formal checks alone.
- The execution confirmation rate is 78.39% ( 9667/12332 ). Union of successes across environments. Of these, 9667 rows are confirmed by a simulator and 0 rows by formal checks alone.
- The denominator includes pending interpretations and items without test mappings. We do not exclude non-implemented and non-supported.
- The registration unit is the occurrence point, condition, and observation case of the requirement, and the duplication of meaning is integrated by the review of the denominator. This is neither the fraction of all program/input combinations tested nor a single simulator's standard conformance rate.

<a id="既存テストの集計状況"></a>

## Aggregation of existing tests

- 6699 of 16298 tests have a registered correspondence with the requirements. 9599 tests remain unregistered.
- The above coverage rate is calculated only for the part which registered the response to the demand by confirming the stimulus and the expected result. Existing tests that are not registered are also useful for verification, but their contribution is not yet reflected in the proportion.
- The number of registered units is the number of units that correspond to at least one requirement, not the number of completed reviews of the whole test.

- The requests that are shared by multiple tests are in the 770 row. Only if all tests in each group are successful in the same run, they count as a success for the entire request.

<a id="確定値"></a>

## Definite value

- Requirement coverage (test design): 93.13%.
- Requirement execution-confirmation rate: 30.74% without Ghost, 78.39% with Ghost.
- Approval of denominator: Approval. The measured state is `confirmed`.
- The method was confirmed after document verification, resolution of the reservation interpretation, duplication of the requirement unit, and review of the denominator.

<a id="残件"></a>

## Remains

- There is a record of the path result corresponding to the current input: 9667 line.
- No record of passed/passout results: 1818 line.
- Test compatibility not confirmed (except for interpretation reservation): 847 line.
- Interpretation reservation: 0 line.

Unsupported behavior does not mean that no existing test is available.

<a id="シミュレータ別の実行確認率"></a>

## Execution confirmation rate by simulator

Each row is a separate saved run. A narrow run can leave many tests unexecuted; check [how to read dates, versions and scope](https://github.com/kurochan001/kirimasim-tests/blob/7e233e9afefc1a6e975ef85ed0ea7cffddb158de/docs/faq.en.md#q14-why-do-main-results-or-simulator-totals-differ) and the measurement source.

- `ghost` / `private build da2a4afe0dc9` : 9658/12332 ( 78.32% )。 Measurement source: `2026-11-20T04:57:15.544798+00:00` / `ghost.json` 。 Failures 25; known mismatches 0; unsupported 0; not run 290; stale evidence 0; unapproved judgment evidence for illegal-design tests 1512 rows.
- `kirimasim` / `kirimasim 0.1.1 (commit cb97fc93bf6b), built with GNU 13.3.0` : 3107/12332 ( 25.19% )。 Measurement source: `2026-11-20T04:52:31.092570+00:00` / `kirimasim.json` 。 Failures 162; known mismatches 0; unsupported 6533; not run 290; stale evidence 0; unapproved judgment evidence for illegal-design tests 1393 rows.
- `lyra` / `Lyra (commit 9a9813a48c8c)` : 3674/12332 ( 29.79% )。 Measurement source: `2026-11-20T06:20:11.820137+00:00` / `lyra.json` 。 Failures 847; known mismatches 0; unsupported 5288; not run 290; stale evidence 0; unapproved judgment evidence for illegal-design tests 1386 rows.
- `verilator` / `Verilator 5.055 devel rev v5.054-340-g53a72711` : 3791/12332 ( 30.74% )。 Measurement source: `2026-11-20T06:08:58.723548+00:00` / `verilator.json` 。 Failures 27; known mismatches 6346; unsupported 0; not run 290; stale evidence 0; unapproved judgment evidence for illegal-design tests 1031 rows.
- The result file of the rejection: 0.

<a id="章附属書別登録項目に対する割合"></a>

## By chapter and appendix (percentage of registered items)

- 1 Overview: test mapping no registered items, execution confirmed no registered items, execution confirmed without Ghost no registered items, interpretation pending 0 rows.
- 2 Normative references: test mapping 0/2 ( 0.00% ), execution confirmed 0/2 ( 0.00% ), execution confirmed without Ghost 0/2 ( 0.00% ), interpretation pending 0 rows.
- 3 Design and verification building blocks: test mapping 132/146 ( 90.41% ), execution confirmed 112/146 ( 76.71% ), execution confirmed without Ghost 90/146 ( 61.64% ), interpretation pending 0 rows.
- 4 Scheduling semantics: test mapping 90/107 ( 84.11% ), execution confirmed 88/107 ( 82.24% ), execution confirmed without Ghost 30/107 ( 28.04% ), interpretation pending 0 rows.
- 5 Lexical conventions: test mapping 146/155 ( 94.19% ), execution confirmed 128/155 ( 82.58% ), execution confirmed without Ghost 81/155 ( 52.26% ), interpretation pending 0 rows.
- 6 Data types: test mapping 711/720 ( 98.75% ), execution confirmed 581/720 ( 80.69% ), execution confirmed without Ghost 298/720 ( 41.39% ), interpretation pending 0 rows.
- 7 Aggregate data types: test mapping 337/347 ( 97.12% ), execution confirmed 267/347 ( 76.95% ), execution confirmed without Ghost 141/347 ( 40.63% ), interpretation pending 0 rows.
- 8 Classes: test mapping 239/255 ( 93.73% ), execution confirmed 151/255 ( 59.22% ), execution confirmed without Ghost 114/255 ( 44.71% ), interpretation pending 0 rows.
- 9 Processes: test mapping 183/192 ( 95.31% ), execution confirmed 161/192 ( 83.85% ), execution confirmed without Ghost 85/192 ( 44.27% ), interpretation pending 0 rows.
- 10 Assignment statements: test mapping 147/156 ( 94.23% ), execution confirmed 108/156 ( 69.23% ), execution confirmed without Ghost 53/156 ( 33.97% ), interpretation pending 0 rows.
- 11 Operators and expressions: test mapping 448/459 ( 97.60% ), execution confirmed 412/459 ( 89.76% ), execution confirmed without Ghost 210/459 ( 45.75% ), interpretation pending 0 rows.
- 12 Procedural programming statements: test mapping 101/115 ( 87.83% ), execution confirmed 86/115 ( 74.78% ), execution confirmed without Ghost 37/115 ( 32.17% ), interpretation pending 0 rows.
- 13 Tasks and functions (subroutines): test mapping 116/124 ( 93.55% ), execution confirmed 75/124 ( 60.48% ), execution confirmed without Ghost 52/124 ( 41.94% ), interpretation pending 0 rows.
- 14 Clocking blocks: test mapping 86/87 ( 98.85% ), execution confirmed 67/87 ( 77.01% ), execution confirmed without Ghost 49/87 ( 56.32% ), interpretation pending 0 rows.
- 15 Interprocess synchronization and communication: test mapping 84/88 ( 95.45% ), execution confirmed 77/88 ( 87.50% ), execution confirmed without Ghost 46/88 ( 52.27% ), interpretation pending 0 rows.
- 16 Assertions: test mapping 549/557 ( 98.56% ), execution confirmed 402/557 ( 72.17% ), execution confirmed without Ghost 62/557 ( 11.13% ), interpretation pending 0 rows.
- 17 Checkers: test mapping 69/81 ( 85.19% ), execution confirmed 43/81 ( 53.09% ), execution confirmed without Ghost 9/81 ( 11.11% ), interpretation pending 0 rows.
- 18 Constrained random value generation: test mapping 315/323 ( 97.52% ), execution confirmed 254/323 ( 78.64% ), execution confirmed without Ghost 136/323 ( 42.11% ), interpretation pending 0 rows.
- 19 Functional coverage: test mapping 268/276 ( 97.10% ), execution confirmed 212/276 ( 76.81% ), execution confirmed without Ghost 36/276 ( 13.04% ), interpretation pending 0 rows.
- 20 Utility system tasks and system functions: test mapping 300/320 ( 93.75% ), execution confirmed 289/320 ( 90.31% ), execution confirmed without Ghost 77/320 ( 24.06% ), interpretation pending 0 rows.
- 21 Input/output system tasks and system functions: test mapping 362/383 ( 94.52% ), execution confirmed 346/383 ( 90.34% ), execution confirmed without Ghost 89/383 ( 23.24% ), interpretation pending 0 rows.
- 22 Compiler directives: test mapping 355/363 ( 97.80% ), execution confirmed 76/363 ( 20.94% ), execution confirmed without Ghost 59/363 ( 16.25% ), interpretation pending 0 rows.
- 23 Modules and hierarchy: test mapping 254/260 ( 97.69% ), execution confirmed 194/260 ( 74.62% ), execution confirmed without Ghost 47/260 ( 18.08% ), interpretation pending 0 rows.
- 24 Programs: test mapping 25/29 ( 86.21% ), execution confirmed 18/29 ( 62.07% ), execution confirmed without Ghost 2/29 ( 6.90% ), interpretation pending 0 rows.
- 25 Interfaces: test mapping 58/63 ( 92.06% ), execution confirmed 31/63 ( 49.21% ), execution confirmed without Ghost 18/63 ( 28.57% ), interpretation pending 0 rows.
- 26 Packages: test mapping 41/44 ( 93.18% ), execution confirmed 24/44 ( 54.55% ), execution confirmed without Ghost 16/44 ( 36.36% ), interpretation pending 0 rows.
- 27 Generate constructs: test mapping 28/32 ( 87.50% ), execution confirmed 14/32 ( 43.75% ), execution confirmed without Ghost 5/32 ( 15.62% ), interpretation pending 0 rows.
- 28 Gate-level and switch-level modeling: test mapping 374/384 ( 97.40% ), execution confirmed 367/384 ( 95.57% ), execution confirmed without Ghost 59/384 ( 15.36% ), interpretation pending 0 rows.
- 29 User-defined primitives: test mapping 49/52 ( 94.23% ), execution confirmed 34/52 ( 65.38% ), execution confirmed without Ghost 8/52 ( 15.38% ), interpretation pending 0 rows.
- 30 Specify blocks: test mapping 150/157 ( 95.54% ), execution confirmed 138/157 ( 87.90% ), execution confirmed without Ghost 0/157 ( 0.00% ), interpretation pending 0 rows.
- 31 Timing checks: test mapping 155/180 ( 86.11% ), execution confirmed 142/180 ( 78.89% ), execution confirmed without Ghost 11/180 ( 6.11% ), interpretation pending 0 rows.
- 32 Backannotation using the standard delay format: test mapping 119/131 ( 90.84% ), execution confirmed 119/131 ( 90.84% ), execution confirmed without Ghost 0/131 ( 0.00% ), interpretation pending 0 rows.
- 33 Configuring the contents of a design: test mapping 41/63 ( 65.08% ), execution confirmed 28/63 ( 44.44% ), execution confirmed without Ghost 7/63 ( 11.11% ), interpretation pending 0 rows.
- 34 Protected envelopes: test mapping 5/214 ( 2.34% ), execution confirmed 5/214 ( 2.34% ), execution confirmed without Ghost 5/214 ( 2.34% ), interpretation pending 0 rows.
- 35 Direct programming interface: test mapping 121/143 ( 84.62% ), execution confirmed 106/143 ( 74.13% ), execution confirmed without Ghost 78/143 ( 54.55% ), interpretation pending 0 rows.
- 36 Programming language interface ( PLI / VPI ) overview: test mapping 148/163 ( 90.80% ), execution confirmed 145/163 ( 88.96% ), execution confirmed without Ghost 11/163 ( 6.75% ), interpretation pending 0 rows.
- 37 VPI object model diagrams: test mapping 1666/1757 ( 94.82% ), execution confirmed 1658/1757 ( 94.37% ), execution confirmed without Ghost 1/1757 ( 0.06% ), interpretation pending 0 rows.
- 38 VPI routine definitions: test mapping 283/348 ( 81.32% ), execution confirmed 281/348 ( 80.75% ), execution confirmed without Ghost 55/348 ( 15.80% ), interpretation pending 0 rows.
- 39 Assertion API : test mapping 82/95 ( 86.32% ), execution confirmed 82/95 ( 86.32% ), execution confirmed without Ghost 2/95 ( 2.11% ), interpretation pending 0 rows.
- 40 Code coverage control and API : test mapping 122/128 ( 95.31% ), execution confirmed 122/128 ( 95.31% ), execution confirmed without Ghost 34/128 ( 26.56% ), interpretation pending 0 rows.
- 41 Data read API : test mapping no registered items, execution confirmed no registered items, execution confirmed without Ghost no registered items, interpretation pending 0 rows.
- A Formal syntax: test mapping 796/811 ( 98.15% ), execution confirmed 795/811 ( 98.03% ), execution confirmed without Ghost 433/811 ( 53.39% ), interpretation pending 0 rows.
- B Keywords: test mapping 248/248 ( 100.00% ), execution confirmed 0/248 ( 0.00% ), execution confirmed without Ghost 0/248 ( 0.00% ), interpretation pending 0 rows.
- C Deprecation: test mapping 9/20 ( 45.00% ), execution confirmed 9/20 ( 45.00% ), execution confirmed without Ghost 7/20 ( 35.00% ), interpretation pending 0 rows.
- D Optional system tasks and system functions: test mapping no registered items, execution confirmed no registered items, execution confirmed without Ghost no registered items, interpretation pending 0 rows.
- E Optional compiler directives: test mapping no registered items, execution confirmed no registered items, execution confirmed without Ghost no registered items, interpretation pending 0 rows.
- F Formal semantics of concurrent assertions: test mapping 253/253 ( 100.00% ), execution confirmed 0/253 ( 0.00% ), execution confirmed without Ghost 0/253 ( 0.00% ), interpretation pending 0 rows.
- G Std package: test mapping 25/32 ( 78.12% ), execution confirmed 25/32 ( 78.12% ), execution confirmed without Ghost 18/32 ( 56.25% ), interpretation pending 0 rows.
- H DPI C layer: test mapping 193/223 ( 86.55% ), execution confirmed 193/223 ( 86.55% ), execution confirmed without Ghost 134/223 ( 60.09% ), interpretation pending 0 rows.
- I svdpi.h : test mapping 134/147 ( 91.16% ), execution confirmed 134/147 ( 91.16% ), execution confirmed without Ghost 113/147 ( 76.87% ), interpretation pending 0 rows.
- J Inclusion of foreign language code: test mapping 0/16 ( 0.00% ), execution confirmed 0/16 ( 0.00% ), execution confirmed without Ghost 0/16 ( 0.00% ), interpretation pending 0 rows.
- K vpi_user.h : test mapping 541/544 ( 99.45% ), execution confirmed 541/544 ( 99.45% ), execution confirmed without Ghost 540/544 ( 99.26% ), interpretation pending 0 rows.
- L vpi_compatibility.h : test mapping 85/88 ( 96.59% ), execution confirmed 85/88 ( 96.59% ), execution confirmed without Ghost 0/88 ( 0.00% ), interpretation pending 0 rows.
- M sv_vpi_user.h : test mapping 407/412 ( 98.79% ), execution confirmed 407/412 ( 98.79% ), execution confirmed without Ghost 407/412 ( 98.79% ), interpretation pending 0 rows.
- N Algorithm for probabilistic distribution functions: test mapping 35/39 ( 89.74% ), execution confirmed 35/39 ( 89.74% ), execution confirmed without Ghost 26/39 ( 66.67% ), interpretation pending 0 rows.
- O Encryption/decryption flow: test mapping no registered items, execution confirmed no registered items, execution confirmed without Ghost no registered items, interpretation pending 0 rows.
- P Glossary: test mapping no registered items, execution confirmed no registered items, execution confirmed without Ghost no registered items, interpretation pending 0 rows.
- Q Bibliography: test mapping no registered items, execution confirmed no registered items, execution confirmed without Ghost no registered items, interpretation pending 0 rows.

<a id="分母と履歴"></a>

## Denominator and history

- The denominator is SHA-256 : `3e082eb97645e56c5c07ea62dc21876b52bd54c4d28ad6ecdfa907aa459e184b`.
- Version of the measurement rule: 3.
- The history stores the identifier of the denominator, the provisional and definitive values, and the state summary by environment. The ratio of the rounds with different denominators is not compared as improvement or deterioration.
- This aggregation is re-generated from the saved execution trace. The above time of measurement is the time of execution.
