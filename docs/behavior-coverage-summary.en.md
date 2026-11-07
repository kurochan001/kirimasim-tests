<a id="ieee-1800-2023-要求カバレッジ集計"></a>

# IEEE 1800-2023 requirement coverage aggregation

[English](behavior-coverage-summary.en.md) / [日本語](behavior-coverage-summary.md)

[Details of all items](behavior-coverage.en.md) / [Management procedures](../coverage/README.en.md) / [Interpretation and Re-examination Record](requirement-extraction-notes.en.md)

The denominator counts requirement-ledger rows, not test files. See [Design, execution and PASS distinctions](faq.en.md#q16-how-do-design-and-execution-coverage-differ) for concrete examples.

<a id="全規格の要求台帳に対する値"></a>

## Value for all standards in the required table

- Requirement coverage (test design): 89.28% ( 10980/12298 ).
- The execution confirmation rate is 77.55% ( 9537/12298 ). Union of successes across environments.
- The denominator includes pending interpretations and items without test mappings. We do not exclude non-implemented and non-supported.
- The registration unit is the occurrence point, condition, and observation case of the requirement, and the duplication of meaning is integrated by the review of the denominator. This is neither the fraction of all program/input combinations tested nor a single simulator's standard conformance rate.

<a id="既存テストの集計状況"></a>

## Aggregation of existing tests

- 11773 of 5309 tests have registered the correspondance with the requirements. 6464 tests remain unregistered.
- The above coverage rate is calculated only for the part which registered the response to the demand by confirming the stimulus and the expected result. Existing tests that are not registered are also useful for verification, but their contribution is not yet reflected in the proportion.
- The number of registered units is the number of units that correspond to at least one requirement, not the number of completed reviews of the whole test.

- The requests that are shared by multiple tests are in the 652 row. Only if all tests in each group are successful in the same run, they count as a success for the entire request.

<a id="確定値"></a>

## Definite value

- Requirement coverage (test design): 89.28%.
- Requirement execution-confirmation rate: 77.55%.
- Approval of denominator: Approval. The measured state is `confirmed`.
- The method was confirmed after document verification, resolution of the reservation interpretation, duplication of the requirement unit, and review of the denominator.

<a id="残件"></a>

## Remains

- There is a record of the path result corresponding to the current input: 9537 line.
- No record of passed/passout results: 1443 line.
- Test compatibility not confirmed (except for interpretation reservation): 1318 line.
- Interpretation reservation: 0 line.

Unsupported behavior does not mean that no existing test is available.

<a id="シミュレータ別の実行確認率"></a>

## Execution confirmation rate by simulator

Each row is a separate saved run. A narrow run can leave many tests unexecuted; check [how to read dates, versions and scope](faq.en.md#q14-why-do-main-results-or-simulator-totals-differ) and the measurement source.

- `icarus` / `Icarus Verilog version 13.0 (stable) (v13_0)` : 2/12298 ( 0.02% )。 Measurement source: `2026-11-06T16:22:35.529949+00:00` / `block-namespace-20261107-icarus13.json` 。 Failures 0; known mismatches 0; unsupported 0; not run 10978; stale evidence 0; unapproved judgment evidence for illegal-design tests 0 rows.
- `kirimasim` / `kirimasim 0.0.0 (commit 1e840ea322cc), built with AppleClang 21.0.0.21000334` : 2/12298 ( 0.02% )。 Measurement source: `2026-11-06T16:22:35.395353+00:00` / `block-namespace-20261107-kirimasim-1e840ea3.json` 。 Failures 0; known mismatches 0; unsupported 0; not run 10978; stale evidence 0; unapproved judgment evidence for illegal-design tests 0 rows.
- `verilator` / `Verilator 5.052 2026-09-05 rev vUNKNOWN-built20260905` : 2/12298 ( 0.02% )。 Measurement source: `2026-11-06T16:22:41.394923+00:00` / `block-namespace-20261107-verilator5.052-seed1.json` 。 Failures 0; known mismatches 0; unsupported 0; not run 10978; stale evidence 0; unapproved judgment evidence for illegal-design tests 0 rows.
- `verilator` / `Verilator 5.052 2026-09-05 rev vUNKNOWN-built20260905` : 2/12298 ( 0.02% )。 Measurement source: `2026-11-06T16:22:47.095107+00:00` / `block-namespace-20261107-verilator5.052-seed73.json` 。 Failures 0; known mismatches 0; unsupported 0; not run 10978; stale evidence 0; unapproved judgment evidence for illegal-design tests 0 rows.
- `icarus` / `Icarus Verilog version 13.0 (stable) (v13_0)` : 0/12298 ( 0.00% )。 Measurement source: `2026-10-27T15:43:04.210115+00:00` / `ch16-edge-20261028-icarus13.json` 。 Failures 0; known mismatches 1; unsupported 0; not run 10979; stale evidence 0; unapproved judgment evidence for illegal-design tests 0 rows.
- `verilator` / `Verilator 5.052 2026-09-05 rev vUNKNOWN-built20260905` : 1/12298 ( 0.01% )。 Measurement source: `2026-10-27T15:43:15.726452+00:00` / `ch16-edge-20261028-verilator.json` 。 Failures 0; known mismatches 0; unsupported 0; not run 10979; stale evidence 0; unapproved judgment evidence for illegal-design tests 0 rows.
- `icarus` / `Icarus Verilog version 13.0 (stable) (v13_0)` : 0/12298 ( 0.00% )。 Measurement source: `2026-10-27T15:42:14.965527+00:00` / `ch16-sim-20261028-icarus13.json` 。 Failures 0; known mismatches 3; unsupported 0; not run 10965; stale evidence 12; unapproved judgment evidence for illegal-design tests 0 rows.
- `verilator` / `Verilator 5.052 2026-09-05 rev vUNKNOWN-built20260905` : 0/12298 ( 0.00% )。 Measurement source: `2026-10-27T15:43:04.031900+00:00` / `ch16-sim-20261028-verilator.json` 。 Failures 0; known mismatches 3; unsupported 0; not run 10965; stale evidence 12; unapproved judgment evidence for illegal-design tests 0 rows.
- `icarus` / `Icarus Verilog version 13.0 (stable) (v13_0)` : 0/12298 ( 0.00% )。 Measurement source: `2026-10-27T21:20:25.211852+00:00` / `ch19-extra-20261028-icarus13.json` 。 Failures 0; known mismatches 0; unsupported 0; not run 10972; stale evidence 7; unapproved judgment evidence for illegal-design tests 1 rows.
- `verilator` / `Verilator 5.052 2026-09-05 rev vUNKNOWN-built20260905` : 1/12298 ( 0.01% )。 Measurement source: `2026-10-27T21:20:35.736196+00:00` / `ch19-extra-20261028-verilator.json` 。 Failures 0; known mismatches 0; unsupported 0; not run 10972; stale evidence 7; unapproved judgment evidence for illegal-design tests 0 rows.
- `verilator` / `Verilator 5.052 2026-09-05 rev vUNKNOWN-built20260905` : 0/12298 ( 0.00% )。 Measurement source: `2026-10-27T22:55:13.337642+00:00` / `ch19-rest-20261028-verilator.json` 。 Failures 0; known mismatches 0; unsupported 0; not run 10979; stale evidence 1; unapproved judgment evidence for illegal-design tests 0 rows.
- `verilator` / `Verilator 5.052 2026-09-05 rev vUNKNOWN-built20260905` : 0/12298 ( 0.00% )。 Measurement source: `2026-10-27T22:51:40.361212+00:00` / `ch19-rest-reuse-20261028-verilator.json` 。 Failures 0; known mismatches 43; unsupported 0; not run 10936; stale evidence 1; unapproved judgment evidence for illegal-design tests 0 rows.
- `icarus` / `Icarus Verilog version 13.0 (stable) (v13_0)` : 1/12298 ( 0.01% )。 Measurement source: `2026-10-27T16:30:07.226181+00:00` / `ch21-extra-20261028-icarus13.json` 。 Failures 0; known mismatches 1; unsupported 0; not run 10978; stale evidence 0; unapproved judgment evidence for illegal-design tests 0 rows.
- `verilator` / `Verilator 5.052 2026-09-05 rev vUNKNOWN-built20260905` : 2/12298 ( 0.02% )。 Measurement source: `2026-10-27T16:30:10.339072+00:00` / `ch21-extra-20261028-verilator.json` 。 Failures 0; known mismatches 0; unsupported 0; not run 10978; stale evidence 0; unapproved judgment evidence for illegal-design tests 0 rows.
- `icarus` / `Icarus Verilog version 13.0 (stable) (v13_0)` : 13/12298 ( 0.11% )。 Measurement source: `2026-10-27T18:08:32.360779+00:00` / `ch22-extra-20261028-icarus13.json` 。 Failures 0; known mismatches 1; unsupported 0; not run 10965; stale evidence 1; unapproved judgment evidence for illegal-design tests 0 rows.
- `verilator` / `Verilator 5.052 2026-09-05 rev vUNKNOWN-built20260905` : 14/12298 ( 0.11% )。 Measurement source: `2026-10-27T18:08:36.769544+00:00` / `ch22-extra-20261028-verilator.json` 。 Failures 0; known mismatches 0; unsupported 0; not run 10965; stale evidence 1; unapproved judgment evidence for illegal-design tests 0 rows.
- `icarus` / `Icarus Verilog version 13.0 (stable) (v13_0)` : 5/12298 ( 0.04% )。 Measurement source: `2026-10-27T18:10:02.321608+00:00` / `ch23-extra-20261028-icarus13.json` 。 Failures 0; known mismatches 9; unsupported 0; not run 10963; stale evidence 0; unapproved judgment evidence for illegal-design tests 3 rows.
- `verilator` / `Verilator 5.052 2026-09-05 rev vUNKNOWN-built20260905` : 10/12298 ( 0.08% )。 Measurement source: `2026-10-27T18:10:14.224099+00:00` / `ch23-extra-20261028-verilator.json` 。 Failures 0; known mismatches 4; unsupported 0; not run 10963; stale evidence 0; unapproved judgment evidence for illegal-design tests 3 rows.
- `icarus` / `Icarus Verilog version 13.0 (stable) (v13_0)` : 10/12298 ( 0.08% )。 Measurement source: `2026-10-27T18:05:22.468557+00:00` / `ch31-extra-20261028-icarus13.json` 。 Failures 0; known mismatches 0; unsupported 0; not run 10970; stale evidence 0; unapproved judgment evidence for illegal-design tests 0 rows.
- `verilator` / `Verilator 5.052 2026-09-05 rev vUNKNOWN-built20260905` : 7/12298 ( 0.06% )。 Measurement source: `2026-10-27T18:05:39.429957+00:00` / `ch31-extra-20261028-verilator.json` 。 Failures 0; known mismatches 3; unsupported 0; not run 10970; stale evidence 0; unapproved judgment evidence for illegal-design tests 0 rows.
- `icarus` / `Icarus Verilog version 13.0 (stable) (v13_0)` : 3/12298 ( 0.02% )。 Measurement source: `2026-10-27T23:01:55.389805+00:00` / `ch34-extra-20261028-icarus13.json` 。 Failures 0; known mismatches 2; unsupported 0; not run 10975; stale evidence 0; unapproved judgment evidence for illegal-design tests 0 rows.
- `verilator` / `Verilator 5.052 2026-09-05 rev vUNKNOWN-built20260905` : 5/12298 ( 0.04% )。 Measurement source: `2026-10-27T23:02:01.862164+00:00` / `ch34-extra-20261028-verilator.json` 。 Failures 0; known mismatches 0; unsupported 0; not run 10975; stale evidence 0; unapproved judgment evidence for illegal-design tests 0 rows.
- `verilator` / `Verilator 5.052 2026-09-05 rev vUNKNOWN-built20260905` : 1/12298 ( 0.01% )。 Measurement source: `2026-10-27T22:51:49.121474+00:00` / `ch35-rest-20261028-verilator.json` 。 Failures 0; known mismatches 0; unsupported 0; not run 10979; stale evidence 0; unapproved judgment evidence for illegal-design tests 0 rows.
- `icarus` / `Icarus Verilog version 13.0 (stable) (v13_0)` : 55/12298 ( 0.45% )。 Measurement source: `2026-10-27T21:59:06.732473+00:00` / `ch36-extra-20261028-icarus13.json` 。 Failures 0; known mismatches 1151; unsupported 0; not run 9774; stale evidence 0; unapproved judgment evidence for illegal-design tests 0 rows.
- `verilator` / `Verilator 5.052 2026-09-05 rev vUNKNOWN-built20260905` : 1/12298 ( 0.01% )。 Measurement source: `2026-10-27T21:59:09.623661+00:00` / `ch36-extra-20261028-verilator.json` 。 Failures 0; known mismatches 1; unsupported 0; not run 10975; stale evidence 0; unapproved judgment evidence for illegal-design tests 3 rows.
- `icarus` / `Icarus Verilog version 13.0 (stable) (v13_0)` : 1/12298 ( 0.01% )。 Measurement source: `2026-10-27T17:11:52.776966+00:00` / `ch37-extra-20261028-icarus13.json` 。 Failures 0; known mismatches 0; unsupported 0; not run 10979; stale evidence 0; unapproved judgment evidence for illegal-design tests 0 rows.
- `icarus` / `Icarus Verilog version 13.0 (stable) (v13_0)` : 2/12298 ( 0.02% )。 Measurement source: `2026-10-27T17:20:48.267440+00:00` / `ch38-extra-20261028-icarus13.json` 。 Failures 0; known mismatches 0; unsupported 0; not run 10977; stale evidence 1; unapproved judgment evidence for illegal-design tests 0 rows.
- `icarus` / `Icarus Verilog version 13.0 (stable) (v13_0)` : 40/12298 ( 0.33% )。 Measurement source: `2026-10-27T17:00:25.077411+00:00` / `ch38-reuse-20261028-icarus13.json` 。 Failures 0; known mismatches 0; unsupported 0; not run 10940; stale evidence 0; unapproved judgment evidence for illegal-design tests 0 rows.
- `icarus` / `Icarus Verilog version 13.0 (stable) (v13_0)` : 1/12298 ( 0.01% )。 Measurement source: `2026-10-27T16:33:35.549914+00:00` / `ch6-extra-20261028-icarus13.json` 。 Failures 0; known mismatches 2; unsupported 0; not run 10977; stale evidence 0; unapproved judgment evidence for illegal-design tests 0 rows.
- `verilator` / `Verilator 5.052 2026-09-05 rev vUNKNOWN-built20260905` : 3/12298 ( 0.02% )。 Measurement source: `2026-10-27T16:33:40.336655+00:00` / `ch6-extra-20261028-verilator.json` 。 Failures 0; known mismatches 0; unsupported 0; not run 10977; stale evidence 0; unapproved judgment evidence for illegal-design tests 0 rows.
- `verilator` / `Verilator 5.052 2026-09-05 rev vUNKNOWN-built20260905` : 0/12298 ( 0.00% )。 Measurement source: `2026-10-28T01:09:01.904537+00:00` / `ch6-union-note-20261028-verilator.json` 。 Failures 0; known mismatches 0; unsupported 0; not run 10977; stale evidence 3; unapproved judgment evidence for illegal-design tests 0 rows.
- `icarus` / `Icarus Verilog version 13.0 (stable) (v13_0)` : 6/12298 ( 0.05% )。 Measurement source: `2026-10-27T16:32:44.231306+00:00` / `ch9-extra-20261028-icarus13.json` 。 Failures 0; known mismatches 0; unsupported 0; not run 10974; stale evidence 0; unapproved judgment evidence for illegal-design tests 0 rows.
- `verilator` / `Verilator 5.052 2026-09-05 rev vUNKNOWN-built20260905` : 6/12298 ( 0.05% )。 Measurement source: `2026-10-27T16:32:53.445594+00:00` / `ch9-extra-20261028-verilator.json` 。 Failures 0; known mismatches 0; unsupported 0; not run 10974; stale evidence 0; unapproved judgment evidence for illegal-design tests 0 rows.
- `icarus` / `Icarus Verilog version 13.0 (stable) (v13_0)` : 22/12298 ( 0.18% )。 Measurement source: `2026-10-27T22:16:15.354614+00:00` / `chA-extra-20261028-icarus13.json` 。 Failures 0; known mismatches 21; unsupported 0; not run 10934; stale evidence 3; unapproved judgment evidence for illegal-design tests 0 rows.
- `verilator` / `Verilator 5.052 2026-09-05 rev vUNKNOWN-built20260905` : 42/12298 ( 0.34% )。 Measurement source: `2026-10-27T22:16:45.126049+00:00` / `chA-extra-20261028-verilator.json` 。 Failures 0; known mismatches 2; unsupported 0; not run 10933; stale evidence 3; unapproved judgment evidence for illegal-design tests 0 rows.
- `verilator` / `Verilator 5.052 2026-09-05 rev vUNKNOWN-built20260905` : 181/12298 ( 1.47% )。 Measurement source: `2026-10-27T22:00:40.482405+00:00` / `chH-extra-20261028-verilator.json` 。 Failures 0; known mismatches 0; unsupported 0; not run 10792; stale evidence 7; unapproved judgment evidence for illegal-design tests 0 rows.
- `icarus` / `Icarus Verilog version 13.0 (stable) (v13_0-dirty)` : 2/12298 ( 0.02% )。 Measurement source: `2026-10-28T22:47:59.529525+00:00` / `coverage-tests-20261029-icarus13.json` 。 Failures 0; known mismatches 0; unsupported 0; not run 10977; stale evidence 1; unapproved judgment evidence for illegal-design tests 0 rows.
- `verilator` / `Verilator 5.052 2026-09-05 rev vUNKNOWN-built20260905` : 2/12298 ( 0.02% )。 Measurement source: `2026-10-28T22:46:15.799172+00:00` / `coverage-tests-20261029-verilator.json` 。 Failures 0; known mismatches 0; unsupported 0; not run 10978; stale evidence 0; unapproved judgment evidence for illegal-design tests 0 rows.
- `sby` / `unknown SBY version` : 290/12298 ( 2.36% )。 Measurement source: `2026-10-27T13:59:10.011684+00:00` / `formal-20261027-sby.json` 。 Failures 0; known mismatches 0; unsupported 0; not run 10690; stale evidence 0; unapproved judgment evidence for illegal-design tests 0 rows.
- `ghost` / `private build 7ed5e63eedf9` : 7882/12298 ( 64.09% )。 Measurement source: `2026-10-31T10:33:23.126942+00:00` / `ghost-local-20261031-strict.json` 。 Failures 1454; known mismatches 0; unsupported 0; not run 290; stale evidence 80; unapproved judgment evidence for illegal-design tests 1274 rows.
- `ghost` / `private build be060962f878` : 7961/12298 ( 64.73% )。 Measurement source: `2026-10-31T13:37:26.206441+00:00` / `ghost-local-20261031-strict2.json` 。 Failures 1434; known mismatches 0; unsupported 0; not run 290; stale evidence 21; unapproved judgment evidence for illegal-design tests 1274 rows.
- `ghost` / `private build 88d08d9c3441` : 7865/12298 ( 63.95% )。 Measurement source: `2026-10-31T08:07:21.082572+00:00` / `ghost-local-20261031.json` 。 Failures 1552; known mismatches 0; unsupported 0; not run 290; stale evidence 80; unapproved judgment evidence for illegal-design tests 1193 rows.
- `icarus` / `Icarus Verilog version 13.0 (stable) (v13_0-dirty)` : 2/12298 ( 0.02% )。 Measurement source: `2026-10-28T13:33:20.979624+00:00` / `issues-20261028-icarus13.json` 。 Failures 0; known mismatches 75; unsupported 0; not run 10891; stale evidence 12; unapproved judgment evidence for illegal-design tests 0 rows.
- `verilator` / `Verilator 5.052 2026-09-05 rev vUNKNOWN-built20260905` : 3793/12298 ( 30.84% )。 Measurement source: `2026-10-28T13:45:50.335531+00:00` / `issues-20261028-verilator.json` 。 Failures 0; known mismatches 5955; unsupported 0; not run 292; stale evidence 272; unapproved judgment evidence for illegal-design tests 668 rows.
- `icarus` / `Icarus Verilog version 13.0 (stable) (v13_0-dirty)` : 13/12298 ( 0.11% )。 Measurement source: `2026-10-30T20:31:55.476769+00:00` / `issues-20261031-icarus13.json` 。 Failures 0; known mismatches 162; unsupported 0; not run 10776; stale evidence 19; unapproved judgment evidence for illegal-design tests 10 rows.
- `verilator` / `Verilator 5.052 2026-09-05 rev vUNKNOWN-built20260905` : 42/12298 ( 0.34% )。 Measurement source: `2026-10-30T20:31:59.218896+00:00` / `issues-20261031-verilator-seed1.json` 。 Failures 0; known mismatches 122; unsupported 0; not run 10789; stale evidence 19; unapproved judgment evidence for illegal-design tests 8 rows.
- `verilator` / `Verilator 5.052 2026-09-05 rev vUNKNOWN-built20260905` : 42/12298 ( 0.34% )。 Measurement source: `2026-10-30T20:32:01.484680+00:00` / `issues-20261031-verilator-seed73.json` 。 Failures 0; known mismatches 122; unsupported 0; not run 10789; stale evidence 19; unapproved judgment evidence for illegal-design tests 8 rows.
- `icarus` / `Icarus Verilog version 13.0 (stable) (v13_0)` : 2/12298 ( 0.02% )。 Measurement source: `2026-11-06T20:30:05.355039+00:00` / `issues-24-27-28-20261107-icarus13.json` 。 Failures 0; known mismatches 5; unsupported 0; not run 10973; stale evidence 0; unapproved judgment evidence for illegal-design tests 0 rows.
- `kirimasim` / `kirimasim 0.0.0 (commit 1e840ea322cc), built with AppleClang 21.0.0.21000334` : 2/12298 ( 0.02% )。 Measurement source: `2026-11-06T20:30:04.957845+00:00` / `issues-24-27-28-20261107-kirimasim-1e840ea3.json` 。 Failures 0; known mismatches 0; unsupported 5; not run 10973; stale evidence 0; unapproved judgment evidence for illegal-design tests 0 rows.
- `verilator` / `Verilator 5.052 2026-09-05 rev vUNKNOWN-built20260905` : 2/12298 ( 0.02% )。 Measurement source: `2026-11-06T20:30:39.532545+00:00` / `issues-24-27-28-20261107-verilator5.052-seed1.json` 。 Failures 0; known mismatches 5; unsupported 0; not run 10973; stale evidence 0; unapproved judgment evidence for illegal-design tests 0 rows.
- `verilator` / `Verilator 5.052 2026-09-05 rev vUNKNOWN-built20260905` : 2/12298 ( 0.02% )。 Measurement source: `2026-11-06T20:31:04.344863+00:00` / `issues-24-27-28-20261107-verilator5.052-seed73.json` 。 Failures 0; known mismatches 5; unsupported 0; not run 10973; stale evidence 0; unapproved judgment evidence for illegal-design tests 0 rows.
- `icarus` / `Icarus Verilog version 13.0 (stable) (v13_0-dirty)` : 0/12298 ( 0.00% )。 Measurement source: `2026-10-30T21:21:15.292779+00:00` / `issues-40-44-20261031-icarus13.json` 。 Failures 0; known mismatches 17; unsupported 0; not run 10963; stale evidence 0; unapproved judgment evidence for illegal-design tests 0 rows.
- `kirimasim` / `kirimasim 0.0.0 (commit 83e89bf5e833), built with AppleClang 21.0.0.21000334` : 0/12298 ( 0.00% )。 Measurement source: `2026-10-30T21:21:54.084687+00:00` / `issues-40-44-20261031-kirimasim-83e89bf5.json` 。 Failures 0; known mismatches 0; unsupported 17; not run 10963; stale evidence 0; unapproved judgment evidence for illegal-design tests 0 rows.
- `verilator` / `Verilator 5.052 2026-09-05 rev vUNKNOWN-built20260905` : 3/12298 ( 0.02% )。 Measurement source: `2026-10-30T21:21:16.188504+00:00` / `issues-40-44-20261031-verilator5.052-seed1.json` 。 Failures 0; known mismatches 14; unsupported 0; not run 10963; stale evidence 0; unapproved judgment evidence for illegal-design tests 0 rows.
- `verilator` / `Verilator 5.052 2026-09-05 rev vUNKNOWN-built20260905` : 3/12298 ( 0.02% )。 Measurement source: `2026-10-30T21:21:16.245370+00:00` / `issues-40-44-20261031-verilator5.052-seed73.json` 。 Failures 0; known mismatches 14; unsupported 0; not run 10963; stale evidence 0; unapproved judgment evidence for illegal-design tests 0 rows.
- `icarus` / `Icarus Verilog version 13.0 (stable) (v13_0)` : 0/12298 ( 0.00% )。 Measurement source: `2026-11-06T15:47:52.171237+00:00` / `issues-45-47-20261107-icarus13.json` 。 Failures 0; known mismatches 3; unsupported 0; not run 10977; stale evidence 0; unapproved judgment evidence for illegal-design tests 0 rows.
- `kirimasim` / `kirimasim 0.0.0 (commit 1e840ea322cc), built with AppleClang 21.0.0.21000334` : 2/12298 ( 0.02% )。 Measurement source: `2026-11-06T15:47:52.084505+00:00` / `issues-45-47-20261107-kirimasim-1e840ea3.json` 。 Failures 0; known mismatches 0; unsupported 1; not run 10977; stale evidence 0; unapproved judgment evidence for illegal-design tests 0 rows.
- `verilator` / `Verilator 5.052 2026-09-05 rev vUNKNOWN-built20260905` : 0/12298 ( 0.00% )。 Measurement source: `2026-11-06T15:47:55.538904+00:00` / `issues-45-47-20261107-verilator5.052-seed1.json` 。 Failures 0; known mismatches 3; unsupported 0; not run 10977; stale evidence 0; unapproved judgment evidence for illegal-design tests 0 rows.
- `verilator` / `Verilator 5.052 2026-09-05 rev vUNKNOWN-built20260905` : 0/12298 ( 0.00% )。 Measurement source: `2026-11-06T15:47:58.713949+00:00` / `issues-45-47-20261107-verilator5.052-seed73.json` 。 Failures 0; known mismatches 3; unsupported 0; not run 10977; stale evidence 0; unapproved judgment evidence for illegal-design tests 0 rows.
- `icarus` / `Icarus Verilog version 13.0 (stable) (v13_0)` : 5/12298 ( 0.04% )。 Measurement source: `2026-11-07T05:02:50.753452+00:00` / `issues-48-57-20261107-icarus13.json` 。 Failures 0; known mismatches 8; unsupported 0; not run 10966; stale evidence 0; unapproved judgment evidence for illegal-design tests 1 rows.
- `kirimasim` / `kirimasim 0.0.0 (commit 60c26d7c8113), built with AppleClang 21.0.0.21000401` : 1/12298 ( 0.01% )。 Measurement source: `2026-11-07T05:02:50.566184+00:00` / `issues-48-57-20261107-kirimasim-60c26d7c.json` 。 Failures 0; known mismatches 0; unsupported 8; not run 10966; stale evidence 0; unapproved judgment evidence for illegal-design tests 5 rows.
- `verilator` / `Verilator 5.052 2026-09-05 rev vUNKNOWN-built20260905` : 2/12298 ( 0.02% )。 Measurement source: `2026-11-07T05:02:55.425886+00:00` / `issues-48-57-20261107-verilator5.052-seed1.json` 。 Failures 0; known mismatches 12; unsupported 0; not run 10966; stale evidence 0; unapproved judgment evidence for illegal-design tests 0 rows.
- `verilator` / `Verilator 5.052 2026-09-05 rev vUNKNOWN-built20260905` : 2/12298 ( 0.02% )。 Measurement source: `2026-11-07T05:02:59.962760+00:00` / `issues-48-57-20261107-verilator5.052-seed73.json` 。 Failures 0; known mismatches 12; unsupported 0; not run 10966; stale evidence 0; unapproved judgment evidence for illegal-design tests 0 rows.
- `icarus` / `Icarus Verilog version 14.0 (devel) (s20260301-411-gca6b8d376)` : 21/12298 ( 0.17% )。 Measurement source: `2026-10-27T13:37:34.824763+00:00` / `quality-persim-20261027-icarus14.json` 。 Failures 0; known mismatches 35; unsupported 0; not run 10923; stale evidence 1; unapproved judgment evidence for illegal-design tests 0 rows.
- `verilator` / `Verilator 5.052 2026-09-05 rev vUNKNOWN-built20260905` : 19/12298 ( 0.15% )。 Measurement source: `2026-10-27T13:37:34.897897+00:00` / `quality-persim-20261027-verilator-seed1.json` 。 Failures 0; known mismatches 32; unsupported 0; not run 10927; stale evidence 2; unapproved judgment evidence for illegal-design tests 0 rows.
- `verilator` / `Verilator 5.052 2026-09-05 rev vUNKNOWN-built20260905` : 19/12298 ( 0.15% )。 Measurement source: `2026-10-27T13:37:34.973472+00:00` / `quality-persim-20261027-verilator-seed73.json` 。 Failures 0; known mismatches 32; unsupported 0; not run 10927; stale evidence 2; unapproved judgment evidence for illegal-design tests 0 rows.
- `icarus` / `Icarus Verilog version 13.0 (stable) (v13_0)` : 3118/12298 ( 25.35% )。 Measurement source: `2026-10-27T14:45:42.063155+00:00` / `refresh-20261027-icarus13.json` 。 Failures 0; known mismatches 7096; unsupported 0; not run 119; stale evidence 489; unapproved judgment evidence for illegal-design tests 158 rows.
- `verilator` / `Verilator 5.052 2026-09-05 rev vUNKNOWN-built20260905` : 2636/12298 ( 21.43% )。 Measurement source: `2026-10-27T14:43:38.130423+00:00` / `refresh-20261027-verilator-seed1.json` 。 Failures 0; known mismatches 4676; unsupported 0; not run 3130; stale evidence 454; unapproved judgment evidence for illegal-design tests 84 rows.
- `ghost` / `private build 9ba2e0575dcb` : 72/12298 ( 0.59% )。 Measurement source: `2026-10-31T12:31:48.317872+00:00` / `test-fixes-20261031-ghost.json` 。 Failures 0; known mismatches 0; unsupported 0; not run 10907; stale evidence 1; unapproved judgment evidence for illegal-design tests 0 rows.
- `icarus` / `Icarus Verilog version 13.0 (stable) (v13_0-25-g07dd50d37)` : 0/12298 ( 0.00% )。 Measurement source: `2026-10-31T12:25:03.867848+00:00` / `test-fixes-20261031-icarus-include.json` 。 Failures 0; known mismatches 0; unsupported 0; not run 10979; stale evidence 1; unapproved judgment evidence for illegal-design tests 0 rows.
- `icarus` / `Icarus Verilog version 13.0 (stable) (v13_0-25-g07dd50d37)` : 4/12298 ( 0.03% )。 Measurement source: `2026-10-31T12:23:47.414500+00:00` / `test-fixes-20261031-icarus13.json` 。 Failures 0; known mismatches 55; unsupported 0; not run 10920; stale evidence 1; unapproved judgment evidence for illegal-design tests 0 rows.
- `verilator` / `Verilator 5.050 2026-07-01 rev v5.050-60-g3d2421f3b` : 0/12298 ( 0.00% )。 Measurement source: `2026-10-31T12:25:05.281874+00:00` / `test-fixes-20261031-verilator-include.json` 。 Failures 0; known mismatches 0; unsupported 0; not run 10979; stale evidence 1; unapproved judgment evidence for illegal-design tests 0 rows.
- `verilator` / `Verilator 5.050 2026-07-01 rev v5.050-60-g3d2421f3b` : 17/12298 ( 0.14% )。 Measurement source: `2026-10-31T12:23:57.441797+00:00` / `test-fixes-20261031-verilator-seed1.json` 。 Failures 1; known mismatches 44; unsupported 0; not run 10917; stale evidence 1; unapproved judgment evidence for illegal-design tests 0 rows.
- `verilator` / `Verilator 5.050 2026-07-01 rev v5.050-60-g3d2421f3b` : 17/12298 ( 0.14% )。 Measurement source: `2026-10-31T12:24:09.320850+00:00` / `test-fixes-20261031-verilator-seed73.json` 。 Failures 1; known mismatches 44; unsupported 0; not run 10917; stale evidence 1; unapproved judgment evidence for illegal-design tests 0 rows.
- The result file of the rejection: 137.

<a id="章附属書別登録項目に対する割合"></a>

## By chapter and appendix (percentage of registered items)

- 1 Overview: Testing support No object items, execution confirmation No object items, interpretation reserved 0 line.
- 2 Normative references: test compatible 0/2 ( 0.00% ), execution confirmation 0/2 ( 0.00% ), interpretation reserve 0.
- 3 Design and verification building blocks: test-ready 118/146 ( 80.82% ), execution-verification 115/146 ( 78.77% ), interpretation-retention 0 rows.
- 4 Scheduling semantics: test-ready 80/107 ( 74.77% ), execution-confirm 76/107 ( 71.03% ), interpretation-reserved 0 rows.
- 5 Lexical conventions: test compatible 136/154 ( 88.31% ), execution confirmation 133/154 ( 86.36% ), interpretation reserve 0 lines.
- 6 Data types: test-ready 680/719 ( 94.58% ), execution-confirm 628/719 ( 87.34% ), interpretation-reserved 0 rows.
- 7 Aggregate data types: test-ready 320/345 ( 92.75% ), execution-confirm 290/345 ( 84.06% ), interpretation-reserved 0 rows.
- 8 Classes: Test-compatible 221/252 ( 87.70% ), execution-confirm 181/252 ( 71.83% ), interpretation-reserved 0 rows.
- 9 Processes: Test-ready 166/189 ( 87.83% ), execution-confirm 145/189 ( 76.72% ), interpretation-reserved 0 rows.
- 10 Assignment statements: test-compliant 130/156 ( 83.33% ), execution-confirm 119/156 ( 76.28% ), interpretation-reserved 0 lines.
- 11 Operators and expressions: Test-compatible 433/459 ( 94.34% ), execution-confirm 394/459 ( 85.84% ), interpretation-reserved 0 rows.
- 12 Procedural programming statements: test-responsive 89/115 ( 77.39% ), execution-confirm 83/115 ( 72.17% ), interpretation-reserved 0 lines.
- 13 Tasks and functions (subroutines): Test support 92/119 ( 77.31% ), execution confirmation 83/119 ( 69.75% ), interpretation reserve 0.
- 14 Clocking blocks: test-ready 59/87 ( 67.82% ), execution-confirm 58/87 ( 66.67% ), interpretation-reserved 0 rows.
- 15 Interprocess synchronization and communication: test support 68/88 ( 77.27% ), execution confirmation 63/88 ( 71.59% ), interpretation reserve 0.
- 16 Assertions: Test-compliant 539/555 ( 97.12% ), execution-confirming 340/555 ( 61.26% ), interpretation-reserved 0 rows.
- 17 Checkers: Test-ready 59/79 ( 74.68% ), execution-ready 28/79 ( 35.44% ), interpretation-reserved 0 lines.
- 18 Constrained random value generation: test compatible 300/320 ( 93.75% ), execution confirmation 239/320 ( 74.69% ), interpretation reserve 0 rows.
- 19 Functional coverage: test compatible 232/271 ( 85.61% ), execution confirmation 121/271 ( 44.65% ), interpretation reserve 0 rows.
- 20 Utility system tasks and system functions: test support 285/316 ( 90.19% ), execution confirmation 229/316 ( 72.47% ), interpretation reserve 0.
- 21 Input/output system tasks and system functions: test support 347/383 ( 90.60% ), execution confirmation 333/383 ( 86.95% ), interpretation reserve 0.
- 22 Compiler directives: Test-ready 345/361 ( 95.57% ), execution-confirm 339/361 ( 93.91% ), interpretation-reserved 0 lines.
- 23 Modules and hierarchy: Test-ready 251/260 ( 96.54% ), execution-confirm 162/260 ( 62.31% ), interpretation-reserved 0 rows.
- 24 Programs: Test-ready 16/29 ( 55.17% ), execution-confirm 15/29 ( 51.72% ), interpretation-reserved 0 lines.
- 25 Interfaces: Test-ready 43/63 ( 68.25% ), execution-confirm 31/63 ( 49.21% ), interpretation-reserved 0 lines.
- 26 Packages: Test-ready 39/44 ( 88.64% ), execution-confirm 35/44 ( 79.55% ), interpretation-reserved 0 lines.
- 27 Generate constructs: test-compatible 27/32 ( 84.38% ), execution-confirm 24/32 ( 75.00% ), and interpret-reserve 0 rows.
- 28 Gate-level and switch-level modeling: test-ready 363/384 ( 94.53% ), execution-confirm 358/384 ( 93.23% ), interpretation-reserved 0 lines.
- 29 User-defined primitives: test-ready 49/52 ( 94.23% ), execution-confirm 44/52 ( 84.62% ), interpretation-reserved 0 rows.
- 30 Specify blocks: test-compatible 131/157 ( 83.44% ), execution-confirm 122/157 ( 77.71% ), interpretation-reserved 0 rows.
- 31 Timing checks: test-ready 154/180 ( 85.56% ), execution-confirm 111/180 ( 61.67% ), interpretation-reserved 0 lines.
- 32 Backannotation using the standard delay format: test-ready 119/131 ( 90.84% ), execution-confirm 78/131 ( 59.54% ), interpretation-reserved 0 lines.
- 33 Configuring the contents of a design: test-ready 30/63 ( 47.62% ), execution-confirm 21/63 ( 33.33% ), interpretation-reserved 0 lines.
- 34 Protected envelopes: test-ready 5/214 ( 2.34% ), execution-confirm 5/214 ( 2.34% ), interpretation-reserved 0 rows.
- 35 Direct programming interface: test compatible 114/142 ( 80.28% ), execution confirmation 105/142 ( 73.94% ), interpretation reserve 0 lines.
- 36 Programming language interface ( PLI / VPI ) overview: Test-ready 148/163 ( 90.80% ), execution-confirm 79/163 ( 48.47% ), interpretation-reserved 0 lines.
- 37 VPI object model diagrams: test-ready 1656/1757 ( 94.25% ), execution-confirm 1334/1757 ( 75.92% ), interpretation-reserved 0 rows.
- 38 VPI routine definitions: test-compatible 260/348 ( 74.71% ), execution-confirm 247/348 ( 70.98% ), interpretation-reserved 0 lines.
- 39 Assertion API: Test compatible 82/95 ( 86.32% ), execution confirmation 81/95 ( 85.26% ), interpretation reserve 0 rows.
- 40 Code coverage control and API: test support 82/128 ( 64.06% ), execution confirmation 79/128 ( 61.72% ), interpretation reserve 0.
- 41 Data read API : Test compatible No object items, execution confirmed No object items, interpretation reserved 0 line.
- A Formal syntax: test support 792/811 ( 97.66% ), execution confirmation 709/811 ( 87.42% ), interpretation reserve 0 lines.
- B Keywords: Test compatible 248/248 ( 100.00% ), execution confirmation 248/248 ( 100.00% ), interpretation reserve 0.
- C Deprecation: Test-compatible 9/20 ( 45.00% ), execution-confirm 9/20 ( 45.00% ), interpretation-reserved 0 lines.
- D Optional system tasks and system functions: Test support No object items, execution verification No object items, interpretation reserved 0 line.
- E Optional compiler directives: Test support No object items, execution verification No object items, interpretation reserved 0 line.
- F Formal semantics of concurrent assertions: test compatible 253/253 ( 100.00% ), execution confirmation 253/253 ( 100.00% ), interpretation reserve 0 rows.
- G Std package: test compatible 25/32 ( 78.12% ), execution confirmation 25/32 ( 78.12% ), interpretation reserve 0 lines.
- H DPI C layer: test compatible 190/223 ( 85.20% ), execution confirmation 174/223 ( 78.03% ), interpretation reserve 0 rows.
- I svdpi.h: test mappings 133/147 (90.48%), execution verification 130/147 (88.44%), interpretation on hold for 0 rows.
- J Inclusion of foreign language code: test compatible 0/16 ( 0.00% ), execution confirmation 0/16 ( 0.00% ), interpretation reserve 0 lines.
- K vpi_user.h: test mappings 541/544 (99.45%), execution verification 541/544 (99.45%), interpretation on hold for 0 rows.
- L vpi_compatibility.h: test mappings 85/88 (96.59%), execution verification 84/88 (95.45%), interpretation on hold for 0 rows.
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
