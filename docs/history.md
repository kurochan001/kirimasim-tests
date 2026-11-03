<a id="履歴"></a>

# History

[日本語](history.ja.md) / [README](../README.md)

The [README](../README.md) describes the suite as it is now. Records of earlier
work, earlier measurements and the results of earlier checks have moved here.
The figures on this page are those of their dates, not current values; for
those, see the README and the generated reports (the
[behavior summary](behavior-coverage-summary.en.md), the
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

- The [extension](coverage-strengthening-20261022.en.md) adds distinct cases for
  all 187 clauses that previously had one test.

## 2026-10-23

The updates are documented in the
[matching progress and findings](existing-test-matching-review-20261022.en.md),
the [matching result exceeding 20% provisional design coverage](existing-test-matching-20percent-20261023.en.md),
the [VPI review and 10.08% milestone](existing-test-matching-vpi-20261023.en.md),
the [compiler-directive review](existing-test-matching-preprocessor-20261023.en.md),
the [11 expression gap tests](expression-gap-tests-20261023.en.md),
the [15 associative-array gap tests](associative-gap-tests-20261023.en.md) and the
[header and VPI model tests with further matching](header-vpi-tests-and-matching-20261023.en.md),
which add 24 tests of the C headers of Annexes I, K, L and M and 24 VPI tests of
clause 37.

## 2026-10-24

- The [requirement extraction](requirement-extraction.en.md) recast the
  keyword-reservation rows as error cases and resolved 27 interpretation
  issues.
- The [generated keyword tests](keyword-tests-20261024.en.md) add 496 illegal
  designs that use a reserved keyword as a name.
- The [gap tests](gap-tests-20261024.en.md) then add 594 independently verified
  tests for requirements that had none, and their
  [second run](gap-tests-2-20261024.en.md) adds 933 more.
- Simulation speed: a run with the releases Icarus Verilog 13.0 and
  Verilator 5.050, and nvc 1.23.0, which could not analyse the designs and is
  no longer compared, is kept in kirimasim's raw data.

## 2026-10-25

- The [first pass over the unregistered tests](existing-test-matching-unregistered-20261025.en.md)
  linked 45 tests to 99 requirements: six new tests written for stimuli that
  the existing tests lacked, and 23 imported from the CTest suite of the
  simulator repository.
- Simulation speed: in the [2026-10-25 archived run](readme-records-20261101.md#simulation-speed), kirimasim took
  1.08–1.14 times as long on the first four designs as at `8a8607690aa6` in a
  run earlier that day; kirimasim traces the change to `b17234e420b6`.

<a id="2026-10-2526"></a>

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

- The [Nightly test corrections and oracle review](nightly-suite-corrections-20261027.en.md)
  record the corrections made up to then.

## 2026-10-28

- The requirement ledger was reviewed as the denominator: 21 duplicate rows
  were merged into others, leaving 12,298 requirements, and the
  [denominator review](denominator-review-20261028.en.md) approved them. The
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

## 2026-10-31

- The [archived README records](readme-records-20261101.md) retain the
  verified Nightly snapshot for this date, dated speed measurements, and
  the subsequent mailbox/event-rebinding additions and handoff references.

- `tools/run_ghost.py` now leaves out `:type: formal` tests, like the other
  simulation runners (issue #22). Earlier Ghost results count the 268 formal
  tests as failures. As the runner's fingerprint changed, the Ghost results
  saved earlier in `coverage/results/` no longer count as execution evidence
  for requirement coverage.
- Before the test corrections of issues #22 to #28 and #36 to #39 (as of
  2026-10-30), design coverage was 89.33% (10,986/12,298), execution coverage
  59.60% (7,330/12,298), or 51.00% (6,272/12,298) counting only Icarus
  Verilog, Verilator and SymbiYosys, and clauses 1 to 40 were at 87.40%
  (8,272/9,465) design coverage.

## 2026-11-01

- Paired all repository Markdown documentation in English and Japanese, including
  generated reports, test catalogs and historical handoffs. The
  [documentation index](README.md) provides both language links; the chapter
  exports also have English CSV counterparts.
- Replaced the README's dated run narratives and manual generator enumeration
  with current scope and links to the [archived records](readme-records-20261101.md)
  and the complete [generated catalog](generators.md).
- Added offline translation dictionaries and checks for paired publication,
  language links, technical literals and missing translations. See the
  [maintenance guide](../tools/doc_locales/README.md) for update procedures and
  translation provenance. Test inputs, expectations and saved simulator results
  were retained.
- Extended Nightly publication to generate English/Japanese result reports,
  coverage exports and charts from the same recorded execution data.

- Added the chapter 10×35 DPI/NBA P1 model: 144 legal rows reduced to 18 cases, 81 pairs, 48 targeted triples and four anchors. All 144 reference rows and the C ABI were checked independently; four faults were detected. Fixed Verilator seeds each have 14 pass and 4 known build failures. Latest kirimasim `1144b2acab1e` has 2,170 pass, 197 unsupported and the existing 6 fail across 2,373 cases; the preceding 2,355 outcomes and fingerprints are unchanged. See the [model and saved evidence](interaction-verification.en.md#dpi-copyback-and-nba-capture).

- Added the chapter 8×18 constraint-inheritance P1 model: 96 legal rows reduced to 13 cases, retaining 70 pairs, 40 targeted triples and four anchors. Independent named-block checks cover all 96 rows, with two passing controls and five detected faults. Both fixed Verilator seeds pass all 13 tests. Latest kirimasim `1144b2acab1e` records 2,170 pass, 210 unsupported and the existing 6 fail across 2,386 cases; the preceding 2,373 outcomes/fingerprints are unchanged. See [model and evidence](interaction-verification.en.md#constraint-inheritance-and-failure-retention).

- Added the chapter 14×16 clocking/assertion P1 model: 288 legal rows reduced to 18 cases, retaining 109 pairs, 50 targeted triples and four anchors. Independent timelines cover all 288 rows; two controls pass and five faults are detected. Both fixed Verilator seeds pass all 18 tests. Latest kirimasim `1144b2acab1e` records 2,170 pass, 228 unsupported and the existing 6 fail across 2,404 cases; the preceding 2,386 outcomes/fingerprints are unchanged. See [model and evidence](interaction-verification.en.md#clocking-inputs-and-assertion-clocks).

- Added the chapter 7×35 DPI open-array P1 model: 168 legal rows reduced to 30, retaining 100 pairs, 72 targeted triples and four anchors. Independent expectations and the real C helper against a test ABI agree on all rows at two output initialization poisons; one fixed-tool control passes and five faults are detected. Both fixed Verilator seeds pass 18 static-array cases; 12 dynamic-array/queue cases have known build failures. Latest kirimasim `f2d9a1136576` records 2,170 pass, 258 unsupported and the existing 6 fail across 2,434 cases, preserving all previous 2,404 records. Separate parsing accepts 24 new cases and rejects 6 queue cases during type matching. All registered P1 candidates have moved into finite models; unreviewed pairs remain. See [model and evidence](interaction-verification.en.md#dpi-open-array-shape-and-copyback).

- Added the chapter 7×8 class-array P2 model: 240 legal rows reduced to 18, retaining 108 pairs, 60 targeted triples and four anchors. Independent object graphs agree on all rows; two controls pass and six faults are detected. Both fixed Verilator seeds pass all 18 cases. Latest kirimasim `f2d9a1136576` records 2,176 pass, 270 unsupported and the existing 6 fail across 2,452 cases, preserving all previous 2,434 records. All new cases parse successfully; 6 fixed-array cases pass and 12 dynamic-array/queue cases encounter unsupported operations. See [model and evidence](interaction-verification.en.md#class-array-storage-and-shared-elements).

- Added the chapter 21×28 strength-format P2 model: 180 legal rows reduced to 31, retaining 87 pairs, 78 targeted triples and four anchors. Independent drive-resolution tables agree on all rows; three API controls pass and five faults are detected. Fixed Icarus Verilog 13.0 passes all 31 cases. Latest kirimasim `f2d9a1136576` records 2,176 pass, 301 unsupported and the existing 6 fail across 2,483 cases, preserving all previous 2,452 records. All new cases parse successfully but encounter unsupported `%v`. See [model and evidence](interaction-verification.en.md#resolved-strength-formatting).

- Added the chapter 8×25 class/virtual-interface P2 model: 192 legal rows reduced to 13, retaining 96 pairs, 48 targeted triples and four anchors. Independent binding graphs agree on all rows; three controls pass and six faults are detected. Both fixed Verilator seeds pass all 13 cases. Latest kirimasim `80859f34f0aa` records 2,207 pass, 283 unsupported and the existing 6 fail across 2,496 cases. All preceding 2,483 inputs are unchanged; 31 strength-format cases improve from unsupported to pass and the other 2,452 outcomes are unchanged. All new cases parse but encounter unsupported class-held virtual-interface types. There are 93 chapter pairs and 47 models with their full selection PASS. See [model and evidence](interaction-verification.en.md#class-virtual-interface-rebinding).

- Added the chapter 9×14 clocking-iff P2 model: 288 legal rows reduced to 12, retaining 109 pairs, 44 targeted triples and four anchors. Independent event queues agree on all rows; three auxiliary controls pass and six faults are detected. Each fixed Verilator seed passes 4 scalar-guard cases; 8 original vector cases have internal build errors. Two auxiliary vector controls use explicit reduction OR, separate from original-case results. Latest kirimasim `80859f34f0aa` records 2,207 pass, 295 unsupported and the existing 6 fail across 2,508 cases, preserving all preceding 2,496 records. The new cases parse but encounter unsupported guarded clocking events. See [model and evidence](interaction-verification.en.md#clocking-event-guards-and-held-samples).

## 2026-11-02

- Added 18 cases in the chapter 7×20 P2 associative-query model, retaining all 93 pairs, 54 targeted triples and four anchors from 216 legal rows. Independent calculations agree on all 216 rows, and selected expectations distinguish six Python specification-model mutations; these are not executed SV faults. Both fixed Verilator seeds have output differences on all 18 cases; fixed Icarus rejects the builds. Every oracle remains spec. Latest kirimasim `80859f34f0aa` records 2,207 pass, 313 unsupported and the existing 6 fail across 2,526 cases; all 2,508 preceding records are unchanged. All new cases parse but use unsupported typed associative-array variables. There are 95 chapter pairs and 47 models passing their full selection. See [model and evidence](interaction-verification.en.md#associative-array-domains-and-allocation).

- Added 13 cases in the chapter 7×18 P2 reduction-constraint model, retaining all 96 pairs, 40 targeted triples and four anchors from 192 legal rows. Independent calculations agree on every row; four fixed-array auxiliary controls and seven output-difference faults are verified. Controls add an element-type cast only to the observation assignment, and are neither original-case passes nor dynamic-size-retention qualification. Both fixed Verilator seeds differ on all 13 original cases; fixed Icarus rejects the builds. Latest kirimasim `80859f34f0aa` records 2,207 pass, 326 unsupported and the existing 6 fail; all 2,526 preceding records are unchanged. All new cases parse: 8 fixed cases encounter unsupported randomize, and 5 dynamic cases use unsupported class-array operations. Totals are 65 models, 2,539 cases and 96 chapter pairs, with 47 models passing their full selection. See [design and evidence](interaction-verification.en.md#array-reduction-constraints-and-retention).

- Retained Check's fixed regressions and added three-profile, default-96-case model-based random comparisons to Nightly. A dedicated artifact retains seeds, actual stimuli, SV/expectations/output, commits and code fingerprints for single-case replay. Latest-verified build `866abf4d86d1` passes 448 samples and one saved-stimulus replay; an intentional wrong operator is detected by output difference after normal termination. Fixed Icarus 13.0 matches 12 samples. These do not increase fixed-suite counts, chapter pass counts or requirement coverage, and are distinct from execution success in CI. See [usage and scope](random-cross-verification.en.md).

## 2026-11-03

- Expanded the fixed suite to 10,672 tests, including 4,235 generated cases from 88 generators. Finite interactions reached
  79 models, 2,922 selected cases and 114 mapped chapter pairs. Triage was M114 / E3 / C2 / N117 / R584.
  The [follow-up record](cross-verification-followup.en.md) retains the inside and approved label-cancellation repairs,
  unchanged expectations and the original 11→9→4 failure history. On upstream `a682e19e`, 2,389 cases pass, 529 are unsupported
  and four config parameter-reset cases still fail; 52 models pass their full selection.
- Extended bounded random comparisons to thirteen profiles, preserving explicit legacy selections' reproducibility and the default 96-case budget.
  Retained immutable saved replay, optional exact-completed-job exploration admission, reference-drift reporting and same-stimulus comparisons.
  The [random guide](random-cross-verification.en.md) records the scope, saved manifests, code/build identities and failure-to-regression procedure.
  Array reduction reference qualification corrected singleton Z handling while retaining the original five prototype failures and separate replays.
- Paused profile additions and deepened four profiles across three seeds and 32 vectors/operations per case:
  [1,152 local passes](../coverage/interaction-qualification/random-stabilization-20261103.json), including 864 independently interpreted
  array/package programs. The other 288 packed-write programs used the existing execution/reference comparison.
  Local validation passed 901 tool tests and 13 consistency checks. Exploration found no new discrepancy to promote to fixed regression.
- [Check 41649940180](https://github.com/kurochan001/kirimasim-tests/actions/runs/41649940180) and
  [Nightly 41650010801](https://github.com/kurochan001/kirimasim-tests/actions/runs/41650010801) succeeded on suite `e8d991a9`,
  including all five Nightly simulator jobs and publication. Results were checked on 2026-11-04 JST.
  The formal kirimasim `d73d8922dfa2` run confirms all 2,922 finite inputs/statuses and separately records 96 valid random passes
  with seed `41650010801`. See the [dated checkpoint](nightly-results.en.md#latest-verified-checkpoint) for full fixed-suite outcomes,
  build fingerprints and the immutable published snapshot. Random results remain outside fixed counts and coverage.
