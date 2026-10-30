# History

[日本語](history.ja.md) / [README](../README.md)

The [README](../README.md) describes the suite as it is now. Records of earlier
work, earlier measurements and the results of earlier checks have moved here.
The figures on this page are those of their dates, not current values; for
those, see the README and the generated reports (the
[behavior summary](behavior-coverage-summary.md), the
[depth report](coverage-depth.md) and the [catalog](tests/README.md)).

## 2026-10-21

- The [inventory](inventory-20261021.md) records what the suite had before
  the extension work of 2026-10-21, its plan, and the tests added after its
  report.
- An [audit](https://github.com/kurochan001/kirimasim/blob/main/docs/review/oracle_audit.md)
  in kirimasim ran the 1466 tests of its P1 population, taken from this
  repository at `c983cf7`, with both releases, Verilator with four random
  seeds for the initial values. Every expected output that lists a release was
  reproduced by that release, and none was found to record a deviation of a
  release from the standard; the deviations that the runs showed are in that
  file.

## 2026-10-22

- The [extension](coverage-strengthening-20261022.md) adds distinct cases for
  all 187 clauses that previously had one test.

## 2026-10-23

The updates are documented in the
[matching progress and findings](existing-test-matching-review-20261022.md),
the [matching result exceeding 20% provisional design coverage](existing-test-matching-20percent-20261023.md),
the [VPI review and 10.08% milestone](existing-test-matching-vpi-20261023.md),
the [compiler-directive review](existing-test-matching-preprocessor-20261023.md),
the [11 expression gap tests](expression-gap-tests-20261023.md),
the [15 associative-array gap tests](associative-gap-tests-20261023.md) and the
[header and VPI model tests with further matching](header-vpi-tests-and-matching-20261023.md),
which add 24 tests of the C headers of Annexes I, K, L and M and 24 VPI tests of
clause 37.

## 2026-10-24

- The [requirement extraction](requirement-extraction.md) recast the
  keyword-reservation rows as error cases and resolved 27 interpretation
  issues.
- The [generated keyword tests](keyword-tests-20261024.md) add 496 illegal
  designs that use a reserved keyword as a name.
- The [gap tests](gap-tests-20261024.md) then add 594 independently verified
  tests for requirements that had none, and their
  [second run](gap-tests-2-20261024.md) adds 933 more.
- Simulation speed: a run with the releases Icarus Verilog 13.0 and
  Verilator 5.050, and nvc 1.23.0, which could not analyse the designs and is
  no longer compared, is kept in kirimasim's raw data.

## 2026-10-25

- The [first pass over the unregistered tests](existing-test-matching-unregistered-20261025.md)
  linked 45 tests to 99 requirements: six new tests written for stimuli that
  the existing tests lacked, and 23 imported from the CTest suite of the
  simulator repository.
- Simulation speed: in the 2026-10-25 run shown in the README, kirimasim took
  1.08–1.14 times as long on the first four designs as at `8a8607690aa6` in a
  run earlier that day; kirimasim traces the change to `b17234e420b6`.

## 2026-10-25 and 2026-10-26

- The remaining ranges of that work were verified and merged (p01, p05, p07,
  p09, p10, p12, p13 and p15, the annex and gap ranges, and the grammar tests
  of Annex A), tests were added for the K.2, I.3 and N.2 headers and
  algorithms, assertion control, coverage, checkers and 1364 VPI
  compatibility, Icarus Verilog 13.0 was recorded as the oracle of 277
  standard-only tests that it reproduces, and a further pass over the existing
  tests in twelve ranges linked 341 more requirements.

## 2026-10-26

- The basic SVA formal set had 40 models. It is included in the current
  267-case catalogue.

## 2026-10-27

- The [Nightly test corrections and oracle review](nightly-suite-corrections-20261027.md)
  record the corrections made up to then.

## 2026-10-28

- The requirement ledger was reviewed as the denominator: 21 duplicate rows
  were merged into others, leaving 12,298 requirements, and the
  [denominator review](denominator-review-20261028.md) approved them. The
  reviewer was an AI, not an independent human.

## 2026-10-29

- **Manual verification:** [Check](https://github.com/kurochan001/kirimasim-tests/actions/runs/40805455107)
  succeeded, and [Nightly](https://github.com/kurochan001/kirimasim-tests/actions/runs/40805499579)
  completed all five simulator jobs and published the
  [results snapshot](https://github.com/kurochan001/kirimasim-tests/blob/22e410125bba56d3783dd9f8a884dac332239ec7/README.md)
  for suite [`a594d659`](https://github.com/kurochan001/kirimasim-tests/commit/a594d659b947a7321ce5e252660ea6d376d813b3)
  at 12:55 JST (03:55 UTC). Lyra was built from
  [`ed9515d8eec1`](https://github.com/hankhsu1996/lyra/commit/ed9515d8eec105fdf74eecbd6abf83de268c1fe9).
  Matching tests / recorded results:
  - Icarus Verilog: **4,607 / 7,476**.
  - Verilator: **4,779 / 7,476**.
  - kirimasim: **5,076 / 7,476**.
  - Lyra: **5,501 / 7,476**.
  - Ghost: **6,095 / 7,744**.

  `differ`, `known difference` and `unsupported` results remain in the
  denominator. The first four runners exclude the 268 formal tests; Ghost
  selects the full catalogue.
