<a id="ieee-1800-2023-要求カバレッジ集計"></a>

# IEEE 1800-2023 requirement coverage aggregation

[English](behavior-coverage-summary.en.md) / [日本語](behavior-coverage-summary.md)

[Details of all items](behavior-coverage.en.md) / [Management procedures](../coverage/README.en.md) / [Interpretation and Re-examination Record](requirement-extraction-notes.en.md)

The denominator counts requirement-ledger rows, not test files. See [Design, execution and PASS distinctions](faq.en.md#q16-how-do-design-and-execution-coverage-differ) for concrete examples.

<a id="全規格の要求台帳に対する値"></a>

## Value for all standards in the required table

- Requirement coverage (test design): 90.46% ( 11125/12298 ).
- Execution confirmation rate without Ghost: 50.32% ( 6188/12298 ). Union of successes on Icarus Verilog, Verilator and SymbiYosys, which third parties can reproduce. Of these, 5898 rows are confirmed by a simulator and 290 rows by formal checks alone.
- The execution confirmation rate is 77.77% ( 9564/12298 ). Union of successes across environments. Of these, 9274 rows are confirmed by a simulator and 290 rows by formal checks alone.
- The denominator includes pending interpretations and items without test mappings. We do not exclude non-implemented and non-supported.
- The registration unit is the occurrence point, condition, and observation case of the requirement, and the duplication of meaning is integrated by the review of the denominator. This is neither the fraction of all program/input combinations tested nor a single simulator's standard conformance rate.

<a id="既存テストの集計状況"></a>

## Aggregation of existing tests

- 5452 of 12385 tests have a registered correspondence with the requirements. 6933 tests remain unregistered.
- The above coverage rate is calculated only for the part which registered the response to the demand by confirming the stimulus and the expected result. Existing tests that are not registered are also useful for verification, but their contribution is not yet reflected in the proportion.
- The number of registered units is the number of units that correspond to at least one requirement, not the number of completed reviews of the whole test.

- The requests that are shared by multiple tests are in the 679 row. Only if all tests in each group are successful in the same run, they count as a success for the entire request.

<a id="確定値"></a>

## Definite value

- Requirement coverage (test design): 90.46%.
- Requirement execution-confirmation rate: 50.32% without Ghost, 77.77% with Ghost.
- Approval of denominator: Approval. The measured state is `confirmed`.
- The method was confirmed after document verification, resolution of the reservation interpretation, duplication of the requirement unit, and review of the denominator.

<a id="残件"></a>

## Remains

- There is a record of the path result corresponding to the current input: 9564 line.
- No record of passed/passout results: 1561 line.
- Test compatibility not confirmed (except for interpretation reservation): 1173 line.
- Interpretation reservation: 0 line.

Unsupported behavior does not mean that no existing test is available.

<a id="シミュレータ別の実行確認率"></a>

## Execution confirmation rate by simulator

Each row is a separate saved run. A narrow run can leave many tests unexecuted; check [how to read dates, versions and scope](faq.en.md#q14-why-do-main-results-or-simulator-totals-differ) and the measurement source.

- `sby` / `unknown SBY version` : 290/12298 ( 2.36% )。 Measurement source: `2026-10-27T13:59:10.011684+00:00` / `formal-20261027-sby.json` 。 Failures 0; known mismatches 0; unsupported 0; not run 10835; stale evidence 0; unapproved judgment evidence for illegal-design tests 0 rows.
- `icarus` / `Icarus Verilog version 13.0 (stable) (v13_0)` : 3083/12298 ( 25.07% )。 Measurement source: `2026-11-11T16:51:00.391888+00:00` / `full-20261112-icarus13.json` 。 Failures 0; known mismatches 7333; unsupported 0; not run 329; stale evidence 200; unapproved judgment evidence for illegal-design tests 180 rows.
- `kirimasim` / `kirimasim 0.0.0 (commit 7de185f776a1), built with AppleClang 21.0.0.21000401` : 2988/12298 ( 24.30% )。 Measurement source: `2026-11-11T16:52:28.478656+00:00` / `full-20261112-kirimasim-7de185f7.json` 。 Failures 173; known mismatches 0; unsupported 6272; not run 329; stale evidence 198; unapproved judgment evidence for illegal-design tests 1165 rows.
- `verilator` / `Verilator 5.052 2026-09-05 rev vUNKNOWN-built20260905` : 3874/12298 ( 31.50% )。 Measurement source: `2026-11-11T17:39:23.398627+00:00` / `full-20261112-verilator5.052-seed1.json` 。 Failures 0; known mismatches 6084; unsupported 0; not run 329; stale evidence 221; unapproved judgment evidence for illegal-design tests 617 rows.
- `verilator` / `Verilator 5.052 2026-09-05 rev vUNKNOWN-built20260905` : 3586/12298 ( 29.16% )。 Measurement source: `2026-11-11T17:00:30.807783+00:00` / `full-20261112-verilator5.052-seed73.json` 。 Failures 0; known mismatches 0; unsupported 0; not run 7518; stale evidence 21; unapproved judgment evidence for illegal-design tests 0 rows.
- `ghost` / `private build 7ed5e63eedf9` : 7913/12298 ( 64.34% )。 Measurement source: `2026-10-31T10:33:23.126942+00:00` / `ghost-local-20261031-strict.json` 。 Failures 1356; known mismatches 0; unsupported 0; not run 376; stale evidence 308; unapproved judgment evidence for illegal-design tests 1172 rows.
- `ghost` / `private build be060962f878` : 7993/12298 ( 64.99% )。 Measurement source: `2026-10-31T13:37:26.206441+00:00` / `ghost-local-20261031-strict2.json` 。 Failures 1336; known mismatches 0; unsupported 0; not run 376; stale evidence 248; unapproved judgment evidence for illegal-design tests 1172 rows.
- `ghost` / `private build 88d08d9c3441` : 7896/12298 ( 64.21% )。 Measurement source: `2026-10-31T08:07:21.082572+00:00` / `ghost-local-20261031.json` 。 Failures 1439; known mismatches 0; unsupported 0; not run 376; stale evidence 308; unapproved judgment evidence for illegal-design tests 1106 rows.
- `icarus` / `Icarus Verilog version 13.0 (stable) (v13_0)` : 0/12298 ( 0.00% )。 Measurement source: `2026-11-11T22:25:00.780016+00:00` / `oracle-tokens-2-20261112-icarus13.json` 。 Failures 0; known mismatches 3; unsupported 0; not run 11117; stale evidence 0; unapproved judgment evidence for illegal-design tests 5 rows.
- `kirimasim` / `kirimasim 0.0.0 (commit 7de185f776a1), built with AppleClang 21.0.0.21000401` : 0/12298 ( 0.00% )。 Measurement source: `2026-11-11T22:25:00.894678+00:00` / `oracle-tokens-2-20261112-kirimasim-7de185f7.json` 。 Failures 0; known mismatches 0; unsupported 1; not run 11117; stale evidence 0; unapproved judgment evidence for illegal-design tests 7 rows.
- `verilator` / `Verilator 5.052 2026-09-05 rev vUNKNOWN-built20260905` : 2/12298 ( 0.02% )。 Measurement source: `2026-11-11T22:25:01.564353+00:00` / `oracle-tokens-2-20261112-verilator5.052-seed1.json` 。 Failures 0; known mismatches 2; unsupported 0; not run 11117; stale evidence 0; unapproved judgment evidence for illegal-design tests 4 rows.
- `verilator` / `Verilator 5.052 2026-09-05 rev vUNKNOWN-built20260905` : 2/12298 ( 0.02% )。 Measurement source: `2026-11-11T22:25:02.208022+00:00` / `oracle-tokens-2-20261112-verilator5.052-seed73.json` 。 Failures 0; known mismatches 2; unsupported 0; not run 11117; stale evidence 0; unapproved judgment evidence for illegal-design tests 4 rows.
- `icarus` / `Icarus Verilog version 13.0 (stable) (v13_0)` : 11/12298 ( 0.09% )。 Measurement source: `2026-11-11T19:14:33.552454+00:00` / `oracle-tokens-20261112-icarus13.json` 。 Failures 0; known mismatches 31; unsupported 0; not run 10936; stale evidence 0; unapproved judgment evidence for illegal-design tests 147 rows.
- `kirimasim` / `kirimasim 0.0.0 (commit 7de185f776a1), built with AppleClang 21.0.0.21000401` : 4/12298 ( 0.03% )。 Measurement source: `2026-11-11T19:14:36.020025+00:00` / `oracle-tokens-20261112-kirimasim-7de185f7.json` 。 Failures 9; known mismatches 0; unsupported 28; not run 10936; stale evidence 0; unapproved judgment evidence for illegal-design tests 148 rows.
- `verilator` / `Verilator 5.052 2026-09-05 rev vUNKNOWN-built20260905` : 4/12298 ( 0.03% )。 Measurement source: `2026-11-11T19:15:04.286693+00:00` / `oracle-tokens-20261112-verilator5.052-seed1.json` 。 Failures 0; known mismatches 113; unsupported 0; not run 10936; stale evidence 0; unapproved judgment evidence for illegal-design tests 72 rows.
- `verilator` / `Verilator 5.052 2026-09-05 rev vUNKNOWN-built20260905` : 4/12298 ( 0.03% )。 Measurement source: `2026-11-11T19:15:22.924843+00:00` / `oracle-tokens-20261112-verilator5.052-seed73.json` 。 Failures 0; known mismatches 113; unsupported 0; not run 10936; stale evidence 0; unapproved judgment evidence for illegal-design tests 72 rows.
- `icarus` / `Icarus Verilog version 13.0 (stable) (v13_0)` : 1/12298 ( 0.01% )。 Measurement source: `2026-11-11T23:13:00.161260+00:00` / `oracle-tokens-3-20261112-icarus13.json` 。 Failures 0; known mismatches 3; unsupported 0; not run 11117; stale evidence 0; unapproved judgment evidence for illegal-design tests 4 rows.
- `kirimasim` / `kirimasim 0.0.0 (commit 7de185f776a1), built with AppleClang 21.0.0.21000401` : 0/12298 ( 0.00% )。 Measurement source: `2026-11-11T23:13:04.014714+00:00` / `oracle-tokens-3-20261112-kirimasim-7de185f7.json` 。 Failures 0; known mismatches 0; unsupported 0; not run 11117; stale evidence 0; unapproved judgment evidence for illegal-design tests 8 rows.
- `verilator` / `Verilator 5.052 2026-09-05 rev vUNKNOWN-built20260905` : 1/12298 ( 0.01% )。 Measurement source: `2026-11-11T23:13:01.978891+00:00` / `oracle-tokens-3-20261112-verilator5.052-seed1.json` 。 Failures 0; known mismatches 1; unsupported 0; not run 11117; stale evidence 0; unapproved judgment evidence for illegal-design tests 6 rows.
- `verilator` / `Verilator 5.052 2026-09-05 rev vUNKNOWN-built20260905` : 1/12298 ( 0.01% )。 Measurement source: `2026-11-11T23:13:03.804411+00:00` / `oracle-tokens-3-20261112-verilator5.052-seed73.json` 。 Failures 0; known mismatches 1; unsupported 0; not run 11117; stale evidence 0; unapproved judgment evidence for illegal-design tests 6 rows.
- `icarus` / `Icarus Verilog version 13.0 (stable) (v13_0)` : 5/12298 ( 0.04% )。 Measurement source: `2026-11-14T02:14:23.703451+00:00` / `reqgap-20261114-icarus13.json` 。 Failures 0; known mismatches 25; unsupported 0; not run 11093; stale evidence 0; unapproved judgment evidence for illegal-design tests 2 rows.
- `kirimasim` / `kirimasim 0.0.0 (commit 77c27531437c), built with AppleClang 21.0.0.21000401` : 15/12298 ( 0.12% )。 Measurement source: `2026-11-14T02:15:42.861980+00:00` / `reqgap-20261114-kirimasim-77c27531.json` 。 Failures 1; known mismatches 0; unsupported 11; not run 11093; stale evidence 0; unapproved judgment evidence for illegal-design tests 5 rows.
- `verilator` / `Verilator 5.054 2026-11-01 rev vUNKNOWN-built20261101` : 12/12298 ( 0.10% )。 Measurement source: `2026-11-14T02:15:04.150898+00:00` / `reqgap-20261114-verilator5.054-seed1.json` 。 Failures 0; known mismatches 19; unsupported 0; not run 11093; stale evidence 0; unapproved judgment evidence for illegal-design tests 1 rows.
- `verilator` / `Verilator 5.054 2026-11-01 rev vUNKNOWN-built20261101` : 12/12298 ( 0.10% )。 Measurement source: `2026-11-14T02:15:42.524351+00:00` / `reqgap-20261114-verilator5.054-seed73.json` 。 Failures 0; known mismatches 19; unsupported 0; not run 11093; stale evidence 0; unapproved judgment evidence for illegal-design tests 1 rows.
- `icarus` / `Icarus Verilog version 13.0 (stable) (v13_0)` : 0/12298 ( 0.00% )。 Measurement source: `2026-11-12T01:03:42.109814+00:00` / `runtime-errors-20261112-icarus13.json` 。 Failures 0; known mismatches 8; unsupported 0; not run 11117; stale evidence 0; unapproved judgment evidence for illegal-design tests 0 rows.
- `kirimasim` / `kirimasim 0.0.0 (commit 7de185f776a1), built with AppleClang 21.0.0.21000401` : 1/12298 ( 0.01% )。 Measurement source: `2026-11-12T01:03:42.439195+00:00` / `runtime-errors-20261112-kirimasim-7de185f7.json` 。 Failures 0; known mismatches 0; unsupported 7; not run 11117; stale evidence 0; unapproved judgment evidence for illegal-design tests 0 rows.
- `verilator` / `Verilator 5.052 2026-09-05 rev vUNKNOWN-built20260905` : 1/12298 ( 0.01% )。 Measurement source: `2026-11-12T01:03:46.712402+00:00` / `runtime-errors-20261112-verilator5.052-seed1.json` 。 Failures 0; known mismatches 7; unsupported 0; not run 11117; stale evidence 0; unapproved judgment evidence for illegal-design tests 0 rows.
- `verilator` / `Verilator 5.052 2026-09-05 rev vUNKNOWN-built20260905` : 1/12298 ( 0.01% )。 Measurement source: `2026-11-12T01:03:50.809958+00:00` / `runtime-errors-20261112-verilator5.052-seed73.json` 。 Failures 0; known mismatches 7; unsupported 0; not run 11117; stale evidence 0; unapproved judgment evidence for illegal-design tests 0 rows.
- `icarus` / `Icarus Verilog version 13.0 (stable) (v13_0)` : 1/12298 ( 0.01% )。 Measurement source: `2026-11-12T21:43:20.959244+00:00` / `test-fix-20261113-icarus13.json` 。 Failures 0; known mismatches 0; unsupported 0; not run 11124; stale evidence 0; unapproved judgment evidence for illegal-design tests 0 rows.
- `kirimasim` / `kirimasim 0.0.0 (commit 7de185f776a1), built with AppleClang 21.0.0.21000401` : 0/12298 ( 0.00% )。 Measurement source: `2026-11-12T21:43:29.567975+00:00` / `test-fix-20261113-kirimasim-7de185f7.json` 。 Failures 0; known mismatches 0; unsupported 1; not run 11124; stale evidence 0; unapproved judgment evidence for illegal-design tests 0 rows.
- `verilator` / `Verilator 5.052 2026-09-05 rev vUNKNOWN-built20260905` : 1/12298 ( 0.01% )。 Measurement source: `2026-11-12T21:43:25.251767+00:00` / `test-fix-20261113-verilator5.052-seed1.json` 。 Failures 0; known mismatches 0; unsupported 0; not run 11124; stale evidence 0; unapproved judgment evidence for illegal-design tests 0 rows.
- `verilator` / `Verilator 5.052 2026-09-05 rev vUNKNOWN-built20260905` : 1/12298 ( 0.01% )。 Measurement source: `2026-11-12T21:43:29.466399+00:00` / `test-fix-20261113-verilator5.052-seed73.json` 。 Failures 0; known mismatches 0; unsupported 0; not run 11124; stale evidence 0; unapproved judgment evidence for illegal-design tests 0 rows.
- `ghost` / `private build 9ba2e0575dcb` : 73/12298 ( 0.59% )。 Measurement source: `2026-10-31T12:31:48.317872+00:00` / `test-fixes-20261031-ghost.json` 。 Failures 0; known mismatches 0; unsupported 0; not run 11051; stale evidence 1; unapproved judgment evidence for illegal-design tests 0 rows.
- `icarus` / `Icarus Verilog version 13.0 (stable) (v13_0)` : 0/12298 ( 0.00% )。 Measurement source: `2026-11-11T23:50:40.175858+00:00` / `test-fixes-20261112-icarus13.json` 。 Failures 0; known mismatches 52; unsupported 0; not run 11073; stale evidence 0; unapproved judgment evidence for illegal-design tests 0 rows.
- `kirimasim` / `kirimasim 0.0.0 (commit 7de185f776a1), built with AppleClang 21.0.0.21000401` : 0/12298 ( 0.00% )。 Measurement source: `2026-11-11T23:50:40.334300+00:00` / `test-fixes-20261112-kirimasim-7de185f7.json` 。 Failures 0; known mismatches 0; unsupported 52; not run 11073; stale evidence 0; unapproved judgment evidence for illegal-design tests 0 rows.
- `verilator` / `Verilator 5.052 2026-09-05 rev vUNKNOWN-built20260905` : 0/12298 ( 0.00% )。 Measurement source: `2026-11-11T23:50:41.819877+00:00` / `test-fixes-20261112-verilator5.052-seed1.json` 。 Failures 0; known mismatches 52; unsupported 0; not run 11073; stale evidence 0; unapproved judgment evidence for illegal-design tests 0 rows.
- `verilator` / `Verilator 5.052 2026-09-05 rev vUNKNOWN-built20260905` : 0/12298 ( 0.00% )。 Measurement source: `2026-11-11T23:50:43.072508+00:00` / `test-fixes-20261112-verilator5.052-seed73.json` 。 Failures 0; known mismatches 52; unsupported 0; not run 11073; stale evidence 0; unapproved judgment evidence for illegal-design tests 0 rows.
- The result file of the rejection: 220.

<a id="章附属書別登録項目に対する割合"></a>

## By chapter and appendix (percentage of registered items)

- 1 Overview: test mapping no registered items, execution confirmed no registered items, execution confirmed without Ghost no registered items, interpretation pending 0 rows.
- 2 Normative references: test mapping 0/2 ( 0.00% ), execution confirmed 0/2 ( 0.00% ), execution confirmed without Ghost 0/2 ( 0.00% ), interpretation pending 0 rows.
- 3 Design and verification building blocks: test mapping 124/146 ( 84.93% ), execution confirmed 119/146 ( 81.51% ), execution confirmed without Ghost 114/146 ( 78.08% ), interpretation pending 0 rows.
- 4 Scheduling semantics: test mapping 88/107 ( 82.24% ), execution confirmed 79/107 ( 73.83% ), execution confirmed without Ghost 58/107 ( 54.21% ), interpretation pending 0 rows.
- 5 Lexical conventions: test mapping 136/154 ( 88.31% ), execution confirmed 133/154 ( 86.36% ), execution confirmed without Ghost 128/154 ( 83.12% ), interpretation pending 0 rows.
- 6 Data types: test mapping 681/719 ( 94.71% ), execution confirmed 613/719 ( 85.26% ), execution confirmed without Ghost 506/719 ( 70.38% ), interpretation pending 0 rows.
- 7 Aggregate data types: test mapping 322/345 ( 93.33% ), execution confirmed 282/345 ( 81.74% ), execution confirmed without Ghost 179/345 ( 51.88% ), interpretation pending 0 rows.
- 8 Classes: test mapping 221/252 ( 87.70% ), execution confirmed 175/252 ( 69.44% ), execution confirmed without Ghost 140/252 ( 55.56% ), interpretation pending 0 rows.
- 9 Processes: test mapping 166/189 ( 87.83% ), execution confirmed 159/189 ( 84.13% ), execution confirmed without Ghost 109/189 ( 57.67% ), interpretation pending 0 rows.
- 10 Assignment statements: test mapping 136/156 ( 87.18% ), execution confirmed 117/156 ( 75.00% ), execution confirmed without Ghost 77/156 ( 49.36% ), interpretation pending 0 rows.
- 11 Operators and expressions: test mapping 434/459 ( 94.55% ), execution confirmed 394/459 ( 85.84% ), execution confirmed without Ghost 352/459 ( 76.69% ), interpretation pending 0 rows.
- 12 Procedural programming statements: test mapping 101/115 ( 87.83% ), execution confirmed 85/115 ( 73.91% ), execution confirmed without Ghost 53/115 ( 46.09% ), interpretation pending 0 rows.
- 13 Tasks and functions (subroutines): test mapping 98/119 ( 82.35% ), execution confirmed 84/119 ( 70.59% ), execution confirmed without Ghost 75/119 ( 63.03% ), interpretation pending 0 rows.
- 14 Clocking blocks: test mapping 84/87 ( 96.55% ), execution confirmed 74/87 ( 85.06% ), execution confirmed without Ghost 59/87 ( 67.82% ), interpretation pending 0 rows.
- 15 Interprocess synchronization and communication: test mapping 74/88 ( 84.09% ), execution confirmed 63/88 ( 71.59% ), execution confirmed without Ghost 44/88 ( 50.00% ), interpretation pending 0 rows.
- 16 Assertions: test mapping 539/555 ( 97.12% ), execution confirmed 303/555 ( 54.59% ), execution confirmed without Ghost 107/555 ( 19.28% ), interpretation pending 0 rows.
- 17 Checkers: test mapping 59/79 ( 74.68% ), execution confirmed 28/79 ( 35.44% ), execution confirmed without Ghost 13/79 ( 16.46% ), interpretation pending 0 rows.
- 18 Constrained random value generation: test mapping 300/320 ( 93.75% ), execution confirmed 229/320 ( 71.56% ), execution confirmed without Ghost 130/320 ( 40.62% ), interpretation pending 0 rows.
- 19 Functional coverage: test mapping 232/271 ( 85.61% ), execution confirmed 121/271 ( 44.65% ), execution confirmed without Ghost 20/271 ( 7.38% ), interpretation pending 0 rows.
- 20 Utility system tasks and system functions: test mapping 286/316 ( 90.51% ), execution confirmed 230/316 ( 72.78% ), execution confirmed without Ghost 127/316 ( 40.19% ), interpretation pending 0 rows.
- 21 Input/output system tasks and system functions: test mapping 347/383 ( 90.60% ), execution confirmed 333/383 ( 86.95% ), execution confirmed without Ghost 211/383 ( 55.09% ), interpretation pending 0 rows.
- 22 Compiler directives: test mapping 345/361 ( 95.57% ), execution confirmed 339/361 ( 93.91% ), execution confirmed without Ghost 335/361 ( 92.80% ), interpretation pending 0 rows.
- 23 Modules and hierarchy: test mapping 251/260 ( 96.54% ), execution confirmed 186/260 ( 71.54% ), execution confirmed without Ghost 127/260 ( 48.85% ), interpretation pending 0 rows.
- 24 Programs: test mapping 25/29 ( 86.21% ), execution confirmed 21/29 ( 72.41% ), execution confirmed without Ghost 5/29 ( 17.24% ), interpretation pending 0 rows.
- 25 Interfaces: test mapping 55/63 ( 87.30% ), execution confirmed 30/63 ( 47.62% ), execution confirmed without Ghost 23/63 ( 36.51% ), interpretation pending 0 rows.
- 26 Packages: test mapping 39/44 ( 88.64% ), execution confirmed 35/44 ( 79.55% ), execution confirmed without Ghost 30/44 ( 68.18% ), interpretation pending 0 rows.
- 27 Generate constructs: test mapping 27/32 ( 84.38% ), execution confirmed 24/32 ( 75.00% ), execution confirmed without Ghost 20/32 ( 62.50% ), interpretation pending 0 rows.
- 28 Gate-level and switch-level modeling: test mapping 363/384 ( 94.53% ), execution confirmed 360/384 ( 93.75% ), execution confirmed without Ghost 278/384 ( 72.40% ), interpretation pending 0 rows.
- 29 User-defined primitives: test mapping 49/52 ( 94.23% ), execution confirmed 43/52 ( 82.69% ), execution confirmed without Ghost 39/52 ( 75.00% ), interpretation pending 0 rows.
- 30 Specify blocks: test mapping 131/157 ( 83.44% ), execution confirmed 122/157 ( 77.71% ), execution confirmed without Ghost 102/157 ( 64.97% ), interpretation pending 0 rows.
- 31 Timing checks: test mapping 154/180 ( 85.56% ), execution confirmed 111/180 ( 61.67% ), execution confirmed without Ghost 18/180 ( 10.00% ), interpretation pending 0 rows.
- 32 Backannotation using the standard delay format: test mapping 119/131 ( 90.84% ), execution confirmed 78/131 ( 59.54% ), execution confirmed without Ghost 65/131 ( 49.62% ), interpretation pending 0 rows.
- 33 Configuring the contents of a design: test mapping 40/63 ( 63.49% ), execution confirmed 25/63 ( 39.68% ), execution confirmed without Ghost 7/63 ( 11.11% ), interpretation pending 0 rows.
- 34 Protected envelopes: test mapping 5/214 ( 2.34% ), execution confirmed 5/214 ( 2.34% ), execution confirmed without Ghost 5/214 ( 2.34% ), interpretation pending 0 rows.
- 35 Direct programming interface: test mapping 114/142 ( 80.28% ), execution confirmed 103/142 ( 72.54% ), execution confirmed without Ghost 75/142 ( 52.82% ), interpretation pending 0 rows.
- 36 Programming language interface ( PLI / VPI ) overview: test mapping 148/163 ( 90.80% ), execution confirmed 79/163 ( 48.47% ), execution confirmed without Ghost 46/163 ( 28.22% ), interpretation pending 0 rows.
- 37 VPI object model diagrams: test mapping 1656/1757 ( 94.25% ), execution confirmed 1332/1757 ( 75.81% ), execution confirmed without Ghost 72/1757 ( 4.10% ), interpretation pending 0 rows.
- 38 VPI routine definitions: test mapping 260/348 ( 74.71% ), execution confirmed 247/348 ( 70.98% ), execution confirmed without Ghost 145/348 ( 41.67% ), interpretation pending 0 rows.
- 39 Assertion API : test mapping 82/95 ( 86.32% ), execution confirmed 81/95 ( 85.26% ), execution confirmed without Ghost 2/95 ( 2.11% ), interpretation pending 0 rows.
- 40 Code coverage control and API : test mapping 122/128 ( 95.31% ), execution confirmed 105/128 ( 82.03% ), execution confirmed without Ghost 34/128 ( 26.56% ), interpretation pending 0 rows.
- 41 Data read API : test mapping no registered items, execution confirmed no registered items, execution confirmed without Ghost no registered items, interpretation pending 0 rows.
- A Formal syntax: test mapping 792/811 ( 97.66% ), execution confirmed 717/811 ( 88.41% ), execution confirmed without Ghost 518/811 ( 63.87% ), interpretation pending 0 rows.
- B Keywords: test mapping 248/248 ( 100.00% ), execution confirmed 248/248 ( 100.00% ), execution confirmed without Ghost 248/248 ( 100.00% ), interpretation pending 0 rows.
- C Deprecation: test mapping 9/20 ( 45.00% ), execution confirmed 9/20 ( 45.00% ), execution confirmed without Ghost 7/20 ( 35.00% ), interpretation pending 0 rows.
- D Optional system tasks and system functions: test mapping no registered items, execution confirmed no registered items, execution confirmed without Ghost no registered items, interpretation pending 0 rows.
- E Optional compiler directives: test mapping no registered items, execution confirmed no registered items, execution confirmed without Ghost no registered items, interpretation pending 0 rows.
- F Formal semantics of concurrent assertions: test mapping 253/253 ( 100.00% ), execution confirmed 253/253 ( 100.00% ), execution confirmed without Ghost 253/253 ( 100.00% ), interpretation pending 0 rows.
- G Std package: test mapping 25/32 ( 78.12% ), execution confirmed 25/32 ( 78.12% ), execution confirmed without Ghost 18/32 ( 56.25% ), interpretation pending 0 rows.
- H DPI C layer: test mapping 190/223 ( 85.20% ), execution confirmed 174/223 ( 78.03% ), execution confirmed without Ghost 126/223 ( 56.50% ), interpretation pending 0 rows.
- I svdpi.h : test mapping 133/147 ( 90.48% ), execution confirmed 130/147 ( 88.44% ), execution confirmed without Ghost 112/147 ( 76.19% ), interpretation pending 0 rows.
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

- The denominator is SHA-256 : `5bcb737c8be14b1ce421611a62965426e6e8ddbb515101217e0f3c6c14912dc0`.
- Version of the measurement rule: 3.
- The history stores the identifier of the denominator, the provisional and definitive values, and the state summary by environment. The ratio of the rounds with different denominators is not compared as improvement or deterioration.
- This aggregation is re-generated from the saved execution trace. The above time of measurement is the time of execution.
