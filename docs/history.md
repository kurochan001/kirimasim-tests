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
  with seed `41650010801`. See the [dated checkpoint](nightly-results.en.md#previous-verified-checkpoint) for full fixed-suite outcomes,
  build fingerprints and the immutable published snapshot. Random results remain outside fixed counts and coverage.

## 2026-11-04

- [Check 41718590448](https://github.com/kurochan001/kirimasim-tests/actions/runs/41718590448) and
  [Nightly 41743702063](https://github.com/kurochan001/kirimasim-tests/actions/runs/41743702063) succeeded on suite `9926160a`;
  all five Nightly simulator jobs and publication succeeded. The report was generated at 03:25 UTC (12:25 JST).
- On kirimasim `9113955914d8`, the fixed suite recorded 7,868 pass, 2,403 unsupported and 133 fail.
  Five ordinary Chapter 30 specify-condition tests improved from unsupported to pass; the other statuses and all 10,404 input fingerprints were unchanged.
  Those five tests are outside the finite selection, whose 2,922 inputs and statuses remain 2,389 pass, 529 unsupported and four fail.
  The mapping remains 79 models / 114 chapter pairs, with 52 full-selection-pass models; the chapter CSV source remains the saved cross79 run.
- Thirteen-profile random comparisons actually executed 96 cases with new seed/run ID `41743702063`, all valid passes on separately rebuilt core
  `9113955914d878437074f0e3b86a8dca38438080`. Saved-SV independent checks cover 14 array and eight package programs from this run.
  The [new verification record](../coverage/interaction-qualification/formal-ci-9926160a-20261104.json) retains artifact/build fingerprints and fixed status observations;
  the previous record is unchanged. These documentation checks read saved evidence without executing a simulator again or adding coverage.

- Added the previously unassessed Chapters 8×26 [class method/package lookup model](interaction-verification.en.md#class-method-package-lookup):
  34 cases preserve 244 pairs, 110 targeted triples and six anchors from 3,264 legal rows. Independent interpretation agrees on all rows;
  four native controls and eight actual SV faults terminate normally, and every fault is detected by output difference.
  Latest-main kirimasim `9113955914d8` passes all 34 additions in one full 2,956-case run, with no changes to the preceding 2,922 inputs/statuses.
  Totals are 80 models, 115 chapter pairs and 53 full-selection-pass models; triage is M115 / E3 / C2 / N117 / R583.
  Fixed Verilator seeds 1/73 each record 18 pass and 16 known; fixed Icarus rejects all 34 builds. Only the 18 two-seed non-fourstate matches gain Verilator oracles.
  The suite now has 10,706 tests, including 4,269 generated by 89 generators. All 916 tool tests pass, including 15 new focused tests.
  The core is unchanged; new cases remain separate from formal CI, random profiles and requirement bindings.

## 2026-11-05

- Added the [generated-subroutine/array model](interaction-verification.en.md#generated-subroutine-binding) for previously unassessed Chapters 13×27 and 7×27,
  also strengthening 7×13. All 2,304 rows are legal; 36 selected tests retain 228 pairs, 112 targeted triples and six anchors.
  Independent elaboration/interpretation agrees on all rows; four native controls and nine real SV faults exit normally, with every fault detected by output difference.
- A fresh upstream-main fetch/configure/build on kirimasim `162222153c57` passes all 36 additions in one full 2,992-case cross run.
  All preceding 2,956 input fingerprints and statuses are unchanged. Totals are 81 models / 117 chapter pairs / 54 full-selection-pass models;
  native outcomes are 2,459 pass, 529 unsupported and four existing config failures. Triage is M117 / E3 / C2 / N117 / R581.
- Pinned Icarus 13.0 matches all 36 and supplies their oracles. Pinned Verilator seeds 1/73 each record 11 pass and 25 known,
  including one known-value signed task-copy-out difference. Full-output original and function-control replays preserve the same expectation;
  both tools match the function counterpart. No simulator source was inspected or expectation weakened.
- The suite has 10,742 tests, including 4,305 generated cases from 90 generators. All 932 tool tests pass, including 16 new focused tests.
  Check on baseline `fd140002` passed before this addition; the new cases remain outside formal Check/Nightly.
  Random profiles, requirement bindings and core source are unchanged.

- Added the [class conditional-return model](interaction-verification.en.md#class-conditional-return) for unreviewed 8×11 and 8×12.
  All 1,296 rows are legal; 36 cases retain 183 pair targets, 135 targeted triples and six anchors. Independent SV interpretation agrees on all rows;
  five normal native controls and nine real source faults validate the observations. The 8×12 mapping uses only 24 if/case cases.
- A fresh upstream `162222153c57` build passes all 36 in one complete 3,028-case run. The preceding 2,992 input fingerprints/statuses are unchanged.
  Totals are 82 models / 119 mapped pairs / 55 full-selection-pass models; 2,495 pass, 529 unsupported and four existing config failures.
  Triage is M119 / E3 / C2 / N117 / R579. Suite totals are 10,778 tests and 4,341 generated cases from 91 generators.
- Fixed Verilator seeds 1/73 each give 12 pass and 24 known; only the known-input passes receive oracles. Icarus rejects all 36 class-handle comparisons.
  Representative full X outputs, Z diagnostics and unchanged expectations are preserved. External four-state verification of the X/Z inputs is unconfirmed.
  Random profiles, requirement bindings, old tests and core source remain unchanged; formal Check/Nightly for the new cases have not run.

- Added generated-process loop transfers for previously unreviewed 12×27 and 9×27, strengthening 7×27.
  All 6,912 rows are legal; 36 retain 293 pairs, 160 targeted triples and six anchors. Independent actual-SV interpretation agrees on all rows;
  five native controls and nine source faults exit normally and every fault is detected by output difference.
- A fresh main `50a897dee62a` build records 2,531 pass / 529 unsupported / four existing config failures in one 3,064-case run.
  All 36 additions parse/pass, and preceding 3,028 inputs/statuses are unchanged. Totals: 83 models / 121 pairs / 56 full-selection-pass models;
  M121 / E3 / C2 / N117 / R577. Suite: 10,814 tests, including 4,377 generated tests from 92 generators.
- Fixed Icarus matches 31, including 19 X/Z cases; five repeat-count-one inputs retain build rejections. Both independently interpreted count-three controls match.
  Verilator seeds 1/73 each give 12 pass / 24 known. Register 31 Icarus oracles and retain 12 matching known-input Verilator oracles.
- Verified formal Check/Nightly/publish on baseline 19cd790a: fixed 7,975 pass / 2,402 unsupported / 133 fail; all preceding 3,028 finite outcomes match cross82;
  all 96 random cases are valid passes on separately refreshed core 50a897dee62a. New loop cases have not run in formal CI.
  Core source, existing tests/expectations, requirement bindings and thirteen random profiles remain unchanged.
  All 964 tool tests pass, including 16 new focused tests.

- Added the [interface array-query model](interaction-verification.en.md#interface-array-query-walk) for unreviewed 7×25, 20×25 and 13×20.
  All 4,608 rows are legal; 36 retain 274 pairs, 96 targeted triples and six anchors. Independently interpret every row;
  five normal controls and nine real source faults exit normally, with every fault detected by output difference.
- Freshly fetched/configured/built main `50a897dee62a` executes one full 3,100-case snapshot: 2,567 pass / 529 unsupported / four existing config failures.
  All 36 additions parse/pass, and preceding 3,064 inputs/statuses are unchanged. Totals: 84 models / 124 chapter pairs / 57 full-selection-pass models;
  triage M124 / E3 / C2 / N117 / R574.
- Pinned Icarus matches all 36, including X/Z, and supplies their oracles. Both Verilator seeds match the twelve known-input cases.
  Overall, seed 1 records 12 pass / 24 known and seed 73 13 pass / 23 known. The incidental extra bit/X match does not validate four-state behavior or obtain a Verilator oracle.
- Suite totals are 10,850 tests, including 4,413 generated cases from 93 generators. Existing regressions/expectations, requirement bindings, core code and thirteen random profiles are unchanged.
  Verified formal Check/Nightly baseline remains 19cd790a; the combined 72 generated-loop/interface-query cases have not run in formal CI.
  All 980 tool tests pass, including sixteen new focused tests.

- Added the [typed-constant/generate model](interaction-verification.en.md#generated-constant-expression-shape) for unreviewed 11×27 and 20×27.
  All 6,912 rows are legal; 36 retain 297 pairs, 132 targeted triples and six anchors. All independent interpretations agree;
  five normal controls and nine actual SV faults exit normally and every fault is detected by output difference.
- Freshly fetched/configured/built main `92001039e896` executes one full 3,136-case snapshot: 2,603 pass / 529 unsupported / four existing config failures.
  All 36 additions parse/pass; preceding 3,100 inputs/statuses are unchanged. Totals: 85 models / 126 chapter pairs / 58 full-selection-pass models;
  triage M126 / E3 / C2 / N117 / R572.
- Pinned Icarus matches all 36 including X/Z and supplies their oracles. Verilator seeds 1/73 each give 12 pass / 24 known; only twelve known-input cases obtain its oracles.
- Suite totals are 10,886 tests, including 4,449 generated cases from 94 generators. Existing inputs/expectations, requirement bindings, core code and thirteen random profiles are unchanged.
  Verified successful Check on baseline 8df0dde9. Formal Nightly remains 19cd790a; the new 36 cases have not run in Check/Nightly.
  All 997 tool tests pass, including seventeen new focused tests.

- Added [formatted scanning/partial writes](interaction-verification.en.md#formatted-scan-partial-write) for 11×21 and 20×21.
  Select 36 of 5,760 legal representatives, retaining 292 pairs, 142 targeted triples and six anchors. Validate independent interpretation, six normal controls and nine real SV faults.
- One full 3,172-case run on freshly fetched/built `6f5c69841228` records 2,639 pass / 529 unsupported / four existing config failures.
  All additions parse/pass and preceding 3,136 inputs/statuses are unchanged. Totals: 86 models / 128 chapter pairs / 59 full-selection-pass models;
  triage M128 / E3 / C2 / N117 / R570.
- Pinned Icarus gives 17 pass / 19 known; both Verilator seeds give 3 pass / 33 known. Retain original differences and separate same-stimulus literal controls without weakening expectations/classification.
  Map 24 part-select cases to 11×21 and twelve runtime-format cases to 20×21; full-model success requires all 36 together.
- Suite totals: 10,922 tests, including 4,485 generated cases from 95 generators. Requirement bindings, existing regressions, core code and thirteen random profiles are unchanged.
  The new 36 cases have not run in formal Check/Nightly.
  All 1,014 tool tests pass, including seventeen new focused tests.
  Verified successful Check on baseline d98d6e4c; the new 36 cases are outside that run.

### 2026-11-06

- Added 36 program-termination/automatic-task cases, independently interpreting all 3,456 actual SV programs and executing six normal controls plus nine source faults.
- One complete 3,208-case run on freshly fetched/built `6f5c69841228` records 2,675 pass / 529 unsupported / four existing config failures.
  Preceding 3,172 inputs/statuses are unchanged. Totals: 87 models / 130 chapter pairs / 60 full-selection-pass models; triage M130/E3/C2/N117/R568.
- Pinned Icarus records 6 pass / 30 known; Verilator records 36 known at both seeds. Only six matching Icarus cases obtain its oracle.
  Prior evidence/expectations/requirement bindings and thirteen random profiles are unchanged. Suite totals: 10,958, including 4,521 generated cases from 96 generators.
- Verified successful Check on baseline 9c39d865, covering the preceding 86-model suite's pinned comparisons/static checks.
  The new 36 cases have not run in formal Check/Nightly. See [design and evidence](interaction-verification.en.md#program-task-frame-lifetime).

### 2026-11-06 (package-query addition)

- Added 36 Chapter 20×26 cases, independently interpreting all 3,456 legal SV programs and executing six normal controls plus nine source faults.
- One complete 3,244-case run on freshly fetched/built `6f5c69841228` records 2,711 pass / 529 unsupported / four existing config failures.
  Preceding 3,208 inputs/statuses are unchanged. Totals: 88 models / 131 chapter pairs / 61 full-selection-pass models; triage M131/E3/C2/N117/R567.
- Pinned Icarus records 36 known; Verilator seed 1 records 12 pass / 24 known and seed 73 records 13 pass / 23 known.
  Only twelve known-input matches at both seeds obtain its oracle; accidental bit/X agreement does not qualify four-state behavior.
- Suite totals: 10,994, including 4,557 generated cases from 97 generators. Existing inputs/expectations/evidence/requirement bindings and thirteen random profiles are unchanged.
  These 36 cases have not run in formal Check/Nightly. See [design and evidence](interaction-verification.en.md#package-array-query-scope).

### 2026-11-06 (event-loop addition)

- Added Chapter 12×15, selecting 36 of 2,016 legal representative rows and independently interpreting saved SV with six normal controls and nine source faults.
- One complete 3,280-case run on `6f5c69841228` records 2,747 pass / 529 unsupported / four existing config failures. All additions pass; preceding 3,244 inputs/statuses are unchanged.
- Totals: 89 models / 132 pairs / 62 full-selection-pass models; triage M132/E3/C2/N117/R566.
  Pinned Icarus records 36 known; Verilator records 8 pass / 28 known at both seeds. Separate blocking-control matches do not count as original NBA passes.
- Suite totals: 11,030, including 4,593 generated cases from 98 generators. Requirement coverage and thirteen random profiles are unchanged; 1,068 tool tests pass.
  These additions have not run in formal Check/Nightly. See [design and evidence](interaction-verification.en.md#named-event-loop-transfer).

### 2026-11-07 (time-scope, literal and gate-array addition)

- Added the first models whose primary chapters are 3 and 5, and a gate-array model for chapter 28. 165 cases come from 19,080 legal rows, and 19 chapter pairs moved from R to M.
- One complete 3,445-case run on `60c26d7c8113`, built from the latest main, records 2,912 pass / 529 unsupported / four existing config failures. All 165 additions pass; preceding 3,280 inputs/statuses are unchanged.
- Totals: 92 models, 151 chapter pairs, 65 full-selection-pass models; triage M151/E3/C2/N117/R547.
  Pinned Icarus has 144 pass / 21 known and Verilator 38 pass / 127 known at both seeds.
- The literal expectation was wrong once; a run of all legal rows revealed it and it was corrected from the clause. The method now includes the all-row run.
- The suite has 11,193 tests, 4,758 generated from 101 generators. Requirement coverage and thirteen random profiles are unchanged.
  This addition has not run in formal Check/Nightly. See the [design and evidence](interaction-verification.en.md#time-scope-delay).

### 2026-11-07 (Issues #48 to #57)

- Five of the ten issues were mistakes in the tests and were fixed; the other five change no test. A script search found the mistake of #56 in seven more illegal-design tests.
- Design coverage stays at 10,980/12,298 and execution at 9,537/12,298. One requirement left the execution count until Ghost runs its changed test, and the time-format requirement joined it. The suite stays at 11,193 tests.
  These fixes have not yet run in Nightly. See the [decisions](issues-48-57-review-20261107.en.md).

### 2026-11-07 (macro, force/release and implicit-sensitivity addition)

- Added models for macro expansion, force and release, and implicit sensitivity. 247 cases come from 10,469 legal rows, and 17 chapter pairs moved from R to M.
- One complete 3,692-case run on `97d5b0001e7c`, built from the latest main, records 3,159 pass / 529 unsupported / four existing config failures. All 247 additions pass; preceding 3,445 inputs/statuses are unchanged.
- Totals: 95 models, 168 chapter pairs, 68 full-selection-pass models; triage M168/E3/C2/N117/R530.
  Pinned Icarus has 192 pass / 55 known and Verilator 179 pass / 68 known at both seeds.
- The suite has 11,440 tests, 5,005 generated from 104 generators. Requirement coverage and thirteen random profiles are unchanged.
  This addition has not run in formal Check/Nightly. See the [design and evidence](interaction-verification.en.md#macro-expansion-context).

### 2026-11-07 (interface-expression, loop-control and literal-format addition)

- Added models for interface members, loop control and scheduling regions, and literal forms and display formats. 195 cases come from 4,883 legal rows, and five chapter pairs moved from R to M.
- One complete 3,887-case run on `6e32b04ed6ec`, built from the latest main, records 3,404 pass / 479 unsupported / four existing config failures. All 195 additions pass; preceding 3,692 inputs are unchanged, and 50 cases moved from unsupported to pass.
- Totals: 98 models, 173 chapter pairs, 74 full-selection-pass models; triage M173/E3/C2/N117/R525.
  Pinned Icarus has 134 pass / 61 known and Verilator 188 pass / 7 known at both seeds.
- The suite has 11,635 tests, 5,200 generated from 107 generators. Requirement coverage and thirteen random profiles are unchanged.
  This addition has not run in formal Check/Nightly. See the [design and evidence](interaction-verification.en.md#interface-member-expression).

### 2026-11-07 (parameter-override, assertion-query and literal-argument addition)

- Added models for parameter overrides and types, bit vector functions in assertions, and literal arguments and conversion. 136 cases come from 1,174 legal rows, and four chapter pairs moved from R to M.
- One complete 4,023-case run on `eee8cd16ba1d`, built from the latest main, records 3,536 pass / 479 unsupported / eight fail. Of the 136 additions, the four where `defparam` gets the type and range wrong fail; preceding 3,887 inputs and statuses are unchanged.
- Totals: 101 models, 177 chapter pairs, 76 full-selection-pass models; triage M177/E3/C2/N117/R521.
  Pinned Icarus has 111 pass / 25 known and Verilator 111 pass / 25 known at both seeds.
- The suite has 11,771 tests, 5,336 generated from 110 generators. Requirement coverage and thirteen random profiles are unchanged.
  Concurrent assertions were added to the [candidates waiting for kirimasim](cross-verification-followup.en.md#models-waiting-for-kirimasim). This addition has not run in formal Check/Nightly. See the [design and evidence](interaction-verification.en.md#parameter-override-type).

### 2026-11-08 (hierarchical-process-control, %m and array-query-loop addition)

- Added models for process control through hierarchical names, hierarchical names printed by %m, and array query functions and loops. 147 cases come from 869 legal rows, and four chapter pairs moved from R to M.
- One complete 4,170-case run on `28c6c1a1cb83`, built from the latest main, records 3,683 pass / 479 unsupported / eight fail. All 147 additions pass; preceding 4,023 inputs and statuses are unchanged.
- Totals: 104 models, 181 chapter pairs, 79 full-selection-pass models; triage M181/E3/C2/N117/R517.
  Pinned Icarus has 95 pass / 52 known and Verilator 136 pass / 11 known at both seeds.
- The suite has 11,920 tests, 5,483 generated from 113 generators. Requirement coverage and thirteen random profiles are unchanged.
  The four [candidates waiting for kirimasim](cross-verification-followup.en.md#models-waiting-for-kirimasim) are still unimplemented. This addition has not run in formal Check/Nightly. See the [design and evidence](interaction-verification.en.md#hierarchical-process-control).

### 2026-11-08 (delay-value, package-lookup and escaped-name addition)

- Added models for how a delay value is written, package name lookup and escaped identifier binding. 126 cases come from 496 legal rows, and four chapter pairs moved from R to M.
- One complete 4,296-case run on `28c6c1a1cb83` records 3,809 pass / 479 unsupported / eight fail. All 126 additions pass; preceding 4,170 inputs and statuses are unchanged.
- Totals: 107 models, 185 chapter pairs, 82 full-selection-pass models; triage M185/E3/C2/N117/R513.
  Pinned Icarus has 126 pass; Verilator has 112 pass / 14 known at seed 1 and 109 pass / 17 known at seed 73.
- The suite has 12,046 tests, 5,609 generated from 116 generators. Requirement coverage and thirteen random profiles are unchanged.
  This addition has not run in formal Check/Nightly. See the [design and evidence](interaction-verification.en.md#delay-value-form).

### 2026-11-08 (scoped-class, case-literal and structure-literal addition)

- Added models for classes declared in modules and generate blocks, case item literal digits and structure literal keys. 120 cases come from 744 legal rows, and four chapter pairs moved from R to M.
- One complete 4,416-case run on `f029ddd0eee1`, built from the latest main, records 3,915 pass / 487 unsupported / 14 fail. 106 of the 120 additions pass, six fail on a kirimasim internal error and eight are unsupported; preceding 4,296 inputs and statuses are unchanged.
- Totals: 110 models, 189 chapter pairs, 83 full-selection-pass models; triage M189/E3/C2/N117/R509.
  Pinned Icarus has 29 pass / 91 known; Verilator has 63 pass / 57 known at both seeds 1 and 73.
- The suite has 12,166 tests, 5,729 generated from 119 generators. Requirement coverage and thirteen random profiles are unchanged.
  Cycle delays with synchronous drives, and clocking inputs bound to expressions, were added to the candidates waiting for kirimasim.
  This addition has not run in formal Check/Nightly. See the [design and evidence](interaction-verification.en.md#scoped-class-declaration).

<a id="2026-11-08-lyra-host-compiler"></a>

### 2026-11-08 (Lyra host compiler)

- The Lyra job of the Nightly runs on [2026-11-07](https://github.com/kurochan001/kirimasim-tests/actions/runs/42313961551) and [2026-11-08](https://github.com/kurochan001/kirimasim-tests/actions/runs/42422374691) reached the 6-hour limit. Since Lyra `4872d420`, almost every test failed with "compiling 'sv_esc_std.cpp' failed", and each test built the std package again. Lyra's own CI passed at those commits, and the run of 2026-11-06 on `3ee7454c` had no such failure.
- A [first diagnosis](https://github.com/kurochan001/kirimasim-tests/actions/runs/42461858263) on the cached builds found the C++ compiler's error: Lyra's runtime uses `std::expected`, which the runner's clang 18 does not find in libstdc++ 13. The 6 GB address-space limit of the job made no difference (peak memory about 380 MB).
- A [second diagnosis](https://github.com/kurochan001/kirimasim-tests/actions/runs/42462621481) ran the 200 tests of chapter 10 on `b9c9a061` with the runner's GCC 13.3 and with clang 20, the release Lyra's own CI installs. Both gave 185 matches, six failures and nine unsupported, the same tests as on 2026-11-06.
- The Nightly job now gives `--cxx c++` to `tools/run_lyra.py`, which passes it on to `lyra run` and records the compiler and its version in the results. When Lyra cannot compile what it generated, the reason of the failure also gives the first error of the C++ compiler. The diagnosis workflow was removed.

### 2026-11-08 (string replication operand)

- kirimasim `8ed1c0d5` reads 11.4.12.2 as converting an int operand of a string replication to string and accepts `{2{s, k}}`, which Table 6-9 in 6.16 makes an error; Icarus 13.0 and Verilator 5.052 accept it too.
  A test cannot accept both a compile error and a pass, so `ch6/test_illegal_string_replication_int_operand`, which tested this rule alone, was removed and the disagreement recorded in the [simulator differences](simulator-differences.md#string-replication-int-operand).
- `SV2023-6.16-EXTRACT-REPLICATION-OPERANDS` lost its only witness and its mapping was withdrawn. Design coverage becomes 10,979/12,298 (89.27%), and clauses 1 to 40 8,267/9,465 (87.34%).
  Execution coverage is 9,535/12,298 (77.53%); the README had kept 9,537 since 89df6e9b, which had already changed it.
- The suite has 12,165 tests and 1,929 illegal designs.

### 2026-11-08 (slang regression on program subroutine calls)

- kirimasim `f029ddd0` updates slang from `d02b7cda` to `6fbb158f`, and since then accepts a module that calls a program task, which 24.5 makes an error; `33b93822` still reports it. `ch24/test_illegal_module_calls_program_task` keeps its expectation, and the regression is recorded in the [simulator differences](simulator-differences.md#slang-program-subroutine-call).

### 2026-11-08 (Nightly run after the Lyra fix)

- A [manual Nightly](https://github.com/kurochan001/kirimasim-tests/actions/runs/42477954992) ran on `36ba5dd1`. kirimasim `33cee3fa2f0d`, built with GCC 13.3, matches 9,417 of 11,897 tests. The six scoped-class cases end with exit code 3 there too, as they do on macOS ([details](interaction-verification.en.md#scoped-class-declaration)).
- The first attempt of the Lyra job found no cached build of Lyra `ed6c62dc` and stopped when Bazel timed out downloading `bazel-lib` from GitHub. The re-run of that job built Lyra in 85 minutes and ran the suite with GCC 13.3 in 4 hours 20 minutes, using 5 hours 47 minutes of the job's 6-hour limit.
- Lyra matches 9,674 of 11,897 tests, with 1,600 unsupported and 623 failures. Of the 10,723 tests also run on 2026-11-06 (`3ee7454c`), every test that passed then passes now, and 143 more pass (135 unsupported and 8 failing before).
- Because the Lyra job was re-run, the publish job ran twice, and the results history lists this run twice; the second row includes Lyra.

### 2026-11-09 (execution coverage without Ghost)

- An external review found that 3,271 of the 9,535 executed requirements rest on Ghost's results alone. Ghost is a private build, so third parties cannot reproduce them.
- `tools/behavior_coverage.py` now also counts the requirements that pass on Icarus Verilog, Verilator or SymbiYosys, as a whole and by chapter: 6,264/12,298 (50.94%). The summary, the detailed report, the README and the FAQ show it beside the union over every environment. Which figure leads is still to be decided, so the existing figures stay as they are.

### 2026-11-09 (review candidates for expected results)

- The same review asked for a list of the tests whose expectations rest only on the reading of the standard. `tools/review_candidates.py` reads the latest results of Icarus Verilog, Verilator, kirimasim, Lyra and Ghost and lists spec-only tests failing on Ghost, kirimasim and Lyra; spec-only tests passing on kirimasim alone; other spec-only tests passing nowhere; tests with a release oracle failing on both Ghost and Lyra; and clauses whose citing tests are all spec only.
- The publish job of the Nightly writes the list to the results branch. [Review candidates](review-candidates.en.md) explains it, the order of review and how reviews are recorded. On the results of 2026-11-08 the five counts are 30, 21, 92, 41 and 196 (with Lyra's re-run, 30, 15, 92, 75 and 196).

### 2026-11-09 (results of a simulator without a runner)

- The results branch still held the results of a simulator that is no longer compared and whose results are not to be published: one file in `latest/`, its entries in six runs of `history.json`, and two execution snapshots in `behavior-history.json`.
- `tools/results_history.py` now keeps only the simulators that have a runner and those in `RETIRED` (nvc): `update` and `render` drop any other from `history.json` and `latest/`. `tools/behavior_coverage.py` drops their execution snapshots from the behavior history and records how many in the run's `dropped_snapshots`, leaving its counts as they were measured.
- A commit of the results branch removed the existing records. The branch's earlier commits were not rewritten.

### 2026-11-09 (review of spec-only tests)

- The 30 spec-only tests failing on Ghost, kirimasim and Lyra and the 21 spec-only tests passing on kirimasim alone were checked against the standard; the [review](spec-only-review-20261109.en.md) records each finding. 45 expectations are right. Six tests were fixed:
  - `ch10/test_syntax_assignment_pattern_forms`: 10.9 allows an assignment pattern on one side of an assignment only when the other side has a self-determined type, so the right sides of its two lvalue patterns are now typed; 6.21 needs `static` on `tr`. The expected output is unchanged.
  - `ch16/test_deferred_flush_points`: by 9.2.2.2.1 and 9.2.2.3 an always_latch does not resume on its own write of `lq`, so its check now reads a continuous copy of `lq` and the block resumes and flushes (16.4.2). The expected output is unchanged.
  - `ch16/test_syntax_deferred_immediate_assertions`: by 16.4 a deferred assertion evaluates its expression and by-value action arguments when it is reached; the test assumed later evaluation and was rewritten.
  - `ch23/test_syntax_port_expression_and_explicit_ports`: a variable driven through an input port cannot have an initializer (10.3.2, 6.5), and `%h` of an 8-bit value prints two digits (21.2.1.3), so the expected line is now `explicit: hi=0a lo=05 low=3`.
  - `ch20/test_array_query_types_and_invalid` and `ch33/test_config_declaration_grammar_forms`: the standard disagrees with itself on `$dimensions(string)` (20.7, 6.16) and on parameter assignments in a use clause (Syntax 33-4 and A.1.5 against the examples of 33.4.3). Both constructs were left out and recorded in the [simulator differences](simulator-differences.md#dimensions-of-string-type).
- The 28 requirement mappings that rest on these tests have new quoted strings, observations and input digests. The requirement coverage figures do not change.

### 2026-11-09 (requirement mappings of chapters 4, 14, 24, 25, 33 and 40)

- The external review asked to finish mapping existing tests for chapters 4, 14, 24 and 25 (scheduling, clocking blocks, programs, interfaces), which UVM builds on, to add tests for what remains, and to sort out chapters 33 and 40.
- 52 requirements were mapped to existing tests, and 50 more to 56 new tests (33 legal, 23 illegal) in chapters 4, 14, 15, 24, 25, 33 and 40. Design coverage rises from 89.27% to 90.10% (11,081/12,298), execution coverage from 77.53% to 78.00% (9,592/12,298), and execution coverage without Ghost from 50.94% to 51.11% (6,285/12,298). By chapter, design coverage is now 82.2% for chapter 4 (was 74.8%), 96.6% for 14 (67.8%), 86.2% for 24 (55.2%), 84.1% for 25 (68.3%), 63.5% for 33 (47.6%) and 95.3% for 40 (64.1%).
- AI reviews independent of the authors found one wrong new test, seven contested and one doubtful. The wrong one and three contested ones were fixed and the other five left out. The new and changed tests ran on Icarus Verilog 13.0, Verilator 5.052 (seeds 1 and 73) and kirimasim `33cee3fa`: `coverage/results/weak-chapters-20261109-*.json`.
- Six existing ch14 tests were fixed. The four illegal tests of clocking block placement never declared `clk`, so an undeclared-identifier error fell on the expected line. `test_clocking_input_skew_fractional` used the real number 2.5 as a skew, which 14.3 does not allow; it is now `2.5ns`. `test_clocking_input_step_skew` described 1step as sampling in the Observed region and could not tell the two apart; 1step takes the value at the end of the previous time step, and `d` now also changes in the time step of the edge.
- Left for later: requirements that existing tests observe but whose clause they do not cite (citing it changes their inputs, which would make Ghost's saved results stale), and five run-time errors (put, get and try_get with a negative count, a missing extern forkjoin definition, a null virtual interface). Their new tests are in the suite, but their requirement rows are of the error kind, which maps only to illegal-design tests.
- The three new chapter 4 tests of region order use `$sampled` outside the single-clock static model of the SVA reference evaluator, so its M4 inventory defers them with a reason.
- [Clauses 33 and 40](clauses-33-40-testability-20261109.en.md) records what the standard fixes and what it leaves to tools, and which requirements this suite's format can test.
- kirimasim `33cee3fa` differs from the standard in two new tests: slang gives a nested module no default clocking from its enclosing module (14.12), and a call through a modport import uses the definition's default argument instead of the prototype's (25.7).

### 2026-11-09 (tests for IEEE 1800-2023 additions)

- The external review counted few tests for some additions of IEEE 1800-2023. 47 tests were added, 23 legal and 24 illegal: triple-quoted strings in macros (2 legal, 2 illegal), `$stacktrace` (2, 1), restricted type parameters (2, 2), `map()` (2, 2), `ref static` (4, 4), `solve ... before` with an array's size (2, 3), `disable soft` with an array's size (2, 2), `rand real` (2, 2), tolerance ranges (3, 3) and `covergroup extends` (2, 3). Each of these additions now has at least three legal tests and two illegal tests.
- The expectations come from the standard, and a second AI review, independent of the author, found all 47 right. Verilator 5.052 reproduces 7 of them with seeds 1 and 73, which now list `verilator@5.052`; the results are `coverage/results/additions2023-20261109-*.json`.
- kirimasim `33cee3fa` matches 29, does not support 15 and fails 3: it prints the stack for `void'($stacktrace)`, rejects a member of a static unpacked structure as a `ref static` actual, and stops with an internal error (exit code 3) on a range in a `unique` list.
- The four new tests in `tests/ch22` change the input digest of the include tests there, whose digest covers the include directory. The eleven mapped ones were rerun on Icarus Verilog 13.0 and Verilator 5.052 (`coverage/results/ch22-rehash-20261109-*.json`), which also adds two requirements to the execution coverage without Ghost: 6,287/12,298 (51.12%).

<a id="2026-11-09-lyra-build-job"></a>

### 2026-11-09 (Lyra build job)

- In the [Nightly of 2026-11-09](https://github.com/kurochan001/kirimasim-tests/actions/runs/42532762726) on `9eab9bf2`, the Lyra job found no cached build of Lyra `927308a2` and built it in 1 hour 32 minutes. The fixed tests then took 1 hour 50 minutes, and the job reached its 6-hour limit while running the generated tests of `tests/gen/ch8`. That run has no Lyra results; Icarus, Verilator, kirimasim and Ghost were recorded.
- The build now has a job of its own, `lyra-build`, which resolves Lyra's main, builds an uncached commit and saves it in the cache. The `lyra` job restores that build and runs the tests with the same SHA, so they keep the whole 6-hour limit. How results are collected and recorded does not change.

### 2026-11-09 (Verilator differences of the new tests)

- The tests added on 2026-11-09 were checked against Verilator 5.052 with seeds 1 and 73. 18 of them show a departure from the standard and are listed in the [simulator differences](simulator-differences.md#tests-added-20261109): ten whose results differ and eight illegal designs that it accepts.
- Four others were left out: the two illegal `map()` designs of chapter 7 and the null virtual interface of chapter 25 report their error in a place or form that the standard leaves to tools, and `ch14/test_illegal_clocking_clockvar_continuous_assign` passes.

### 2026-11-09 (report of the listed differences)

- `tools/differences_status.py` paired backticks one by one, so a code span such as `` `define `` made it miss the test names after it on the same line. It now reads code spans as Markdown does. Twelve tests that the list names now count: `ch22/test_undefineall`, nine other chapter 22 tests of compiler directives and two chapter 6 tests of implicit nets. They now appear in the [report on master](https://github.com/kurochan001/kirimasim-tests/blob/results/differences-on-master.md); none drops out.

### 2026-11-09 (execution coverage without Ghost first)

- The README, the FAQ (Q16) and the generated behavior summary now lead with the execution coverage from the tools anyone can reproduce (Icarus Verilog, Verilator and SymbiYosys), 51.12% (6,287/12,298), and give the union with Ghost, 78.00% (9,592/12,298), beside it. The figures and how they are counted do not change.

### 2026-11-09 (run-time error requirements)

- Five requirements whose errors are reported while the design runs had the error kind, which maps only to illegal designs with `:should_fail_because:`: a negative key count of a semaphore's put, get and try_get (15.3.2, 15.3.3, 15.3.4), a call of an extern forkjoin task with no definition (25.7.4), and a reference through a null virtual interface (25.9). They are now normal requirements, like 6.24.2, 8.16 and 19.5.6, whose run-time errors are tested with `:expected_stderr_regex:`.
- Each is now mapped to its test added and reviewed on 2026-11-09. The baseline of `coverage/behaviors.json` was written again with this reason, as the kind is part of each requirement's contract, so the denominator digest changes; the 12,298 rows do not.
- Design coverage rises from 90.10% to 90.14% (11,086/12,298), and 88.47% (8,374/9,465) for clauses 1 to 40. Execution coverage does not change: no saved run of a pinned release passes these tests yet.

<a id="2026-11-09-slang-reference"></a>

### 2026-11-09 (slang reference)

- `tools/run_slang.py` runs the slang driver on the tests of the suite. The driver is built from the commit that kirimasim pins, `6fbb158f` for kirimasim `2b05349e`. Its verdicts help to diagnose and are not counted anywhere: kirimasim and Lyra share slang, so it is not an oracle. See the [slang reference](slang-reference.en.md).
- The record of 2026-11-09 is `coverage/slang/slang-6fbb158f-20261109.json`. slang rejects 1,833 of the 1,976 illegal tests at the marked line and accepts 143. It rejects 53 of the 9,525 legal tests without `:vpi_c:`, and 351 of the 499 with it, mostly at a system task that their C code registers.
- On the illegal tests, kirimasim `2b05349e` exits with code 3 on two that slang rejects at the line, rejects seven that slang accepts with checks of its own, and accepts 48 that slang accepts.
- The 53 legal tests were checked against the standard. One test is wrong: `ch3/test_compilation_unit_shared_across_files` takes a tool-specific choice of 3.12.1 as a rule. slang is stricter than the standard for 48, and 4 are unclear. No test was changed.

### 2026-11-11 (use model of the compilation-unit test)

- `ch3/test_compilation_unit_shared_across_files` took "all files of one command line form one compilation unit" as a rule. 3.12.1 leaves the choice to the tool and requires both use models: a) one unit for all files of a command line, b) one unit for each file. The test now says `:compilation_unit: single`: it holds when use model a) is chosen. Its expected output does not change.
- `:compilation_unit:` is a new optional metadata field; `tools/lint_metadata.py` accepts only `single`. Icarus Verilog and Verilator take use model a) by default. `tools/run_slang.py` gives slang `--single-unit` for such a test. The runners of kirimasim, Lyra and Ghost are not changed and pass no option for it.
- The change makes the saved results of this test stale, and those of `ch3/test_include_text_joins_compilation_unit`, whose inputs include the files of `tests/ch3`. Both were run again on Icarus Verilog 13.0 and Verilator 5.052 (seeds 1 and 73) and pass; the results are `coverage/results/compilation-unit-20261111-*.json`. kirimasim, Ghost and slang were not run again.
- The figures do not change: design coverage 90.14% (11,086/12,298), execution coverage 51.12% (6,287/12,298), and 78.00% (9,592/12,298) with Ghost.

### 2026-11-11 (repository review: documents and report tools)

- A review of the repository found statements that later changes had made untrue, and they were corrected in both languages. The Nightly has seven jobs. The results history keeps only what `RETIRED` in `tools/results_history.py` names. The README lists `tools/run_slang.py`, `tools/review_candidates.py`, their documents, `coverage/slang/` and the metadata fields `:issue:` and `:combination_gap:`. The chapter CSVs come from the cross110 run, not cross89.
- Dated statements left the README and the head of the Nightly results page, which hold current information only. They said: the checkpoint checked on 2026-11-06 was the [Check](https://github.com/kurochan001/kirimasim-tests/actions/runs/42120289584) and the [Nightly](https://github.com/kurochan001/kirimasim-tests/actions/runs/42136599265) on `67321079`, with the preceding 88-model suite and its record `coverage/interaction-qualification/handoff-ci-67321079-20261106.json` covering workflow and job conclusions only; and the latest verified Nightly of the random comparisons recorded 96 valid passes on kirimasim `50a897dee62a` with seed `41941310616`.
- The generated behavior summary gave one confirmed value with Ghost only; it now gives 51.12% without Ghost first and 78.00% with Ghost beside it. One English sentence had its two numbers swapped ("12268 of 5400 tests") and is corrected.
- Tools: `tools/differences_status.py` reads a runner's `--json` file, which has `generated_at` instead of `time`. The upper bound of the test-count chart follows the data (it was fixed at 12,000 for 12,268 tests). The generators fail on a test name that two of them produce. `tools/lint_metadata.py` reports an empty field, an `:expected_stderr_regex:` that does not compile and a `:name:` used twice; the seven existing pairs of equal names are recorded as known. The expected-output file `tests/ch17/test_checker_declaration_scopes.expected`, which never had a test, was removed. Two links that pointed outside the repository are plain text.

### 2026-11-11 (repository review: Nightly workflow)

- The Ghost job fetched its private sources with the checkout action, which masks the secret values but printed what it derived from them to the public log: the commit, the default branch and the number of files. Both fetches are now git commands whose output stays in a file on the runner.
- The test step of the Lyra job stops after 345 minutes and fails, so that the partial log is still uploaded; a job that reaches its own 360-minute limit is cancelled and uploads nothing.
- A simulator's job fails when its runner ends with a status above 1 or without its results file; before, `|| true` hid this and the publish job left the simulator out silently. A test that does not match still does not fail a job.
- The kirimasim job treats a failed `apt-get update` as a warning like the other jobs, the Icarus Verilog and Verilator jobs check the commit they resolve, and an unused variable is gone.
- The Ghost fetches and the step limit cannot be tried outside the workflow; the first Nightly after this change shows whether they work.

### 2026-11-11 (duplicate tests)

- A review found tests that differ from another test in the name and the header only. Three of them were removed: the suite has 12,265 tests (it had 12,268), 5,728 of them generated (5,729). Design coverage stays at 90.14% (11,086/12,298), and execution coverage at 51.12% without Ghost and 78.00% with it, because no removed test was mapped to a requirement.
- `tests/ch8/test_illegal_weak_reference_non_class.sv` was removed and `test_illegal_weak_reference_scalar_type.sv` kept. The kept test is the one mapped to the requirement of 8.30.1, and its `:oracle:` is `spec`; the removed test listed Icarus Verilog 13.0, although its own comment said that the error of that release does not count. The record in `coverage/test-matching-reviews.json` that withheld a mapping from the removed test for this reason went with it.
- `tests/ch16/test_formal_fusion.sv` was removed and `test_formal_f5_fusion.sv` kept. Both ran the formal case `fusion`; the kept test is the one mapped to the requirement of F.5.2.
- The `strength` generator drew the same bufif0 gate with the same two strengths twice, so `test_gen_strength_bufif0_05` equalled `test_gen_strength_bufif0_03`. The generator now leaves out a repeated draw. Only that test went away; the names and contents of the other generated tests did not change.
- Six pairs of generated cross tests stay. For width 1 the `lsb` and `msb` expressions of the model `edge_event_expression` select the same bit (five pairs), and for rank 3 with single-element dimensions the `down` and `mixed` bounds of `sv_dpi_array_queries` give the same ranges (one pair). All twelve tests are selected cases. Removing one needs a change of the model, which changes the selection (17 of the 64 cases of the edge model) and then needs a new complete kirimasim run of the selection.
- `tests/ch6/test_illegal_variable_referenced_before_declaration.sv` and `test_illegal_variable_used_before_declaration.sv` have the same code but cite different clauses and expect different messages; both stay.

### 2026-11-12 (runner fixes and re-saved evidence)

- The runners of Icarus Verilog, Verilator, kirimasim and Lyra changed. A run that a signal ends fails, even when it printed the expected output. On Icarus Verilog and Verilator, a compiler that a signal ends fails an illegal test; before, it counted as a rejection. An empty error output with a non-zero exit no longer raises an exception, and an error of a runner fails only the test it happened in. The VPI build and the compilation of Icarus Verilog have a limit of 300 seconds, and the build of Verilator 900 seconds.
- The reasons in the result files name no directory of the machine. A file of the repository is named relative to it; the temporary directory, the directory of the simulator and the home directory appear as `<tmp>`, `<icarus>` (or `<verilator>`, `<kirimasim>`, `<lyra>`) and `<home>`; a directory name that a simulator cut short appears as `<path>`. The runners of Ghost and SymbiYosys, `tools/suite_results.py` and `tools/normalize_output.py` did not change, so their saved results stay valid.
- Absolute paths were replaced in the strings of 43 tracked JSON files under `coverage/` (5,151 places on 5,050 lines): 31 in `results`, 3 in `interaction-results` and 9 in `interaction-qualification`. Statuses, hashes, versions and times did not change. Twelve files were left as they are, because other records hold their SHA-256: `interaction-results/cross25` to `cross29` for Verilator (10 files) and `interaction-qualification/formal-ci-*.json` (2 files). They name only a temporary directory or the checkout of the CI runner, no user name.
- The runner hashes changed, so all earlier results of Icarus Verilog, Verilator and kirimasim became stale. They were saved again on 2026-11-12: `coverage/results/full-20261112-*.json` (11,998 tests), `coverage/interaction-results/full-20261112-*.json` (4,416 selected cases on kirimasim `7de185f776a1`; 4,690 available cases on Icarus Verilog 13.0 and Verilator 5.052 seeds 1 and 73) and `coverage/combination-results/issue21-20261112-*.json` (88 tests). The earlier files stay and count nowhere. The chapter CSVs now come from the kirimasim run `full-20261112-kirimasim-7de185f7.json`.
- Compared with the latest earlier result of each test on the same simulator, no test changed from pass to fail. No test that passed before ends by a signal; the reasons "crashed" and "timed out" appear only on tests that were already known differences (38 on Icarus Verilog, 4 on Verilator seed 1). On Icarus Verilog, four tests `gen/ch20/test_gen_cross_query_*` changed from known to pass: their output on Icarus Verilog differs from run to run, and their `:oracle:` does not list it. On Verilator, `ch18/test_rand_uniform_full_range` changed from fail to pass (the earlier record was made with 5.050), and two tests changed from known to pass because the tests had changed since their last run. On kirimasim, 40 tests changed from unsupported to pass and 4 from fail to pass; the earlier records were made with older builds. The 4,416 selected cases have the same statuses as in the run on `f029ddd0eee1`.
- On macOS, `OBJCACHE=ccache` made one Verilator build fail: a cached precompiled header named the temporary directory of another build. The local runs therefore passed only Verilator's own runtime library through ccache, in a cache of their own. On a sample of 196 tests the results equal those of a run without ccache.
- Design coverage stays at 90.14% (11,086/12,298). Execution coverage is 51.29% (6,308/12,298) without Ghost; it was 51.12% (6,287). With every environment it is 78.68% (9,676/12,298); it was 78.00% (9,592). No requirement lost its execution evidence. Without Ghost, 21 requirements gained it: 8 from the Icarus Verilog run and 13 from the Verilator runs. For most of them the tests had changed after their last run, or the tests of one requirement had passed only in different files; a full run holds them together. The requirement of 18.4.1 had failed with Verilator 5.050, and one test of 24.3.1 had no result in `coverage/results`. With every environment, 84 requirements gained evidence; 67 of them rest only on the full kirimasim run, which is new in `coverage/results`.

### 2026-11-12 (oracle tokens of illegal tests)

- An illegal test may list `iverilog@13.0` or `verilator@5.052` in `:oracle:` only when that release rejects the design at the marked line for the reason the test means. Many illegal tests listed Icarus Verilog 13.0 although it fails there only on syntax it does not know. Every illegal test that listed a fixed release ran on that release, and legal counterparts were tried where the message did not settle the question. The [record](oracle-token-review-20261112.en.md) has the details.
- 254 `iverilog@13.0` tokens and 6 `verilator@5.052` tokens were removed from 259 tests. Of the 253 reviewed tokens of Icarus Verilog, 249 were removed, 3 stay and one test no longer exists; 5 more tokens of Icarus Verilog and the 6 of Verilator were found outside the reviewed set. No test changed its code or its expected result. Comments were reworded in 12 tests: 9 now say what the release reports and why it does not count, and the 3 kept tests say that Icarus Verilog diagnoses the rule. The comment of `ch17/test_illegal_checker_in_function` no longer says that a checker cannot be instantiated in procedural code, which contradicted 17.3.
- 6,397 tests now list `iverilog@13.0` (6,651 before), 2,243 list `verilator@5.052` without it (2,246) and 3,625 have `spec` alone (3,368).
- The input digests of 273 tests changed. They and 73 tests that share a check group with one of them ran again on Icarus Verilog 13.0, Verilator 5.052 (seeds 1 and 73) and kirimasim `7de185f776a1`: `coverage/results/oracle-tokens-20261112-*.json`. No status changed. The digests of 263 checks in `coverage/behaviors.json` and of 31 records in `coverage/test-matching-reviews.json` were refreshed, and the baseline was written again because 99 of the requirements have check groups.
- Design coverage stays at 90.14% (11,086/12,298). Execution coverage is 50.27% (6,182/12,298) without Ghost; it was 51.29% (6,308). With the results of Ghost and of kirimasim added it is 77.65% (9,550/12,298); it was 78.68% (9,676). 126 requirements lost their execution evidence, all of the kind error: 43 in chapter 16, 17 in 6, 10 in 18, 9 in 7, 8 each in 10 and 12, 6 each in 8 and 25, 5 in 11, 3 each in 23 and 33, 2 each in 9 and 22, and 1 each in 13, 14, 20 and 35.
- Not checked yet: 296 illegal tests that list `iverilog@13.0` and whose error on the marked line is not a syntax error, and 4 doubtful tokens (three config tests of chapter 33 on Icarus Verilog and `ch35/test_35_rest_dpi_class_formal` on Verilator).

### 2026-11-12 (cross models without duplicate cases)

- Two cross models took rows as different that give the same design, so each selected equal tests: five pairs in `edge_event_expression` and one pair in `sv_dpi_array_queries` (entry of 2026-11-11, duplicate tests). Both models are now version 2 and make such rows illegal. No expected output of a remaining row changed.
- `edge_event_expression`: at width 1 the expression `msb` is illegal, because `source[0]` is both the least and the most significant bit. The model has 4,032 legal rows (4,096 before) and 259 factor pairs (260); the 152 targeted triples stay. It still selects 64 cases; 17 were removed and 17 added.
- `sv_dpi_array_queries`: a value of `bounds` is legal only when no other value declares the same ranges. With one-element dimensions and a normalized packed range only `down` is legal. With one-element dimensions and an offset packed range `mixed` is illegal, and so it is with one unpacked dimension and a normalized packed range. The model has 832 legal rows (1,152 before), 176 factor pairs (177) and 63 targeted triples (66). It selects 16 cases (19 before); 10 were removed and 7 added. One mandatory case changed its name from `1_mixed_pos_one_4_open_normal_same_literal` to `1_down_pos_one_4_open_normal_same_literal`; its design is the same.
- The suite has 12,262 tests (12,265 before), 5,725 of them generated (5,728). No test outside the two models changed. The headers of all 80 tests of the two models name version 2, so the input digests of the 56 kept tests changed too. No generated test now equals another one in its body and expected output, and no two legal rows of either model give the same design.
- Every legal row of both models ran once, outside the suite; the record is `coverage/interaction-qualification/edgedpiquery-all-rows.json`. kirimasim `7de185f776a1` and Icarus Verilog 13.0 match all 4,032 rows of the edge model. The kirimasim runner does not load C code and Icarus Verilog 13.0 rejects every row of the array-query model, so its 832 rows also ran on Verilator 5.052 (seed 1): 176 rows match, 240 rows with an offset packed range differ at C dimension 0, and 416 rows with an open packed formal are rejected. Both differences were known for version 1. The independent check of this model was repeated for the 832 rows (`coverage/interaction-qualification/dpiquery-v2.json`).
- The selected cases ran again. kirimasim `7de185f776a1` ran all 4,413 selected cases in one run (`coverage/interaction-results/full-20261112-kirimasim-7de185f7-edgedpiquery.json`): 3,915 pass, 484 unsupported and 14 fail. It was 3,915, 487 and 14 for 4,416 cases; the three cases less are unsupported array-query cases. The statuses of the 4,333 cases of the other models did not change. The 80 cases of the two models ran on Icarus Verilog 13.0 and Verilator 5.052, seeds 1 and 73 (`coverage/interaction-results/edgedpiquery-20261112-*.json`). Edge model: 64 pass on kirimasim and on Icarus Verilog; 16 pass and 48 known on Verilator with both seeds. Array-query model: 16 unsupported on kirimasim, 16 known on Icarus Verilog, 6 pass and 10 known on Verilator with both seeds.
- `generators/oracles.txt` follows these runs. The 17 new edge cases list `iverilog@13.0`, as the 17 removed ones did. Six array-query cases list `verilator@5.052` (11 before). In the suite 2,238 tests list `verilator@5.052` without `iverilog@13.0` (2,243 before) and 3,627 have `spec` alone (3,625).
- The totals are 110 models, 4,413 selected cases, 189 chapter pairs and 83 models whose whole selection passes. Only the number of selected cases changed. The triage of the chapter pairs did not change: 189 registered, 3 with existing tests, 2 candidates, 117 out of scope and 509 for later review.
- The figures did not change: design coverage 90.14% (11,086/12,298), execution coverage 50.27% (6,182/12,298) without Ghost and 77.65% (9,550/12,298) with Ghost and kirimasim. No requirement is mapped to a test of the two models, so `coverage/behaviors.json` did not change and no requirement moved. The saved results of the tests of the two models in `coverage/results` are stale and were not replaced: those of the full runs of 2026-11-12, and those of Ghost's run of 2026-10-31, which holds the edge model only. No figure uses them.
- The README named the run `cross110-kirimasim-f029ddd0-scopecaselit.json` on kirimasim `f029ddd0eee1` as the latest complete cross run (3,915 pass, 487 unsupported and 14 fail for 4,416 cases; 106 of the 120 additions of 2026-11-08 passed). It now names the run of this entry.

### 2026-11-12 (observations of Icarus Verilog)

- The [list of differences](simulator-differences.md#observations-20261112) has a new section for observations that are not differences of a release. Its test names are in code blocks, so the report of the listed differences on master does not count them.
- Development version: in the Nightly of 2026-11-11 (`s20260301-948-gbd5af291`), `ch23/test_vpi_ansi_port_inheritance` stopped matching. VPI reports a port declared with `var` as a net. Six other tests fail only on master and match on Icarus Verilog 13.0. These are observations of nightly runs, not reproduced locally.
- Icarus Verilog 13.0: for eight illegal tests the compiler reports the right error at the marked line and then crashes, six with a segmentation fault and two on a failed internal assertion. The driver exits with an ordinary failure status, so the runner sees a rejection. The tokens stay.
- `gen/ch20/test_gen_cross_query_*`: 2,250 runs on Icarus Verilog 13.0 on macOS arm64 showed no varying output. The 21 cases without an Icarus oracle stay as they are, because the saved log from Ubuntu shows the difference.

### 2026-11-12 (oracle tokens of illegal tests, second pass)

- A second pass checked the tokens that the first pass of the same day had left. The [record](oracle-token-review-20261112.en.md#second-pass) has the details.
- Icarus Verilog 13.0: all 918 illegal tests with `iverilog@13.0` are checked now. These are 299 tests whose error is not a syntax error, 120 hand-written tests with a syntax error (each with a legal counterpart), all 496 generated keyword tests and the three config tests of chapter 33. The tokens of the three config tests are right. Nothing remains unchecked on this side.
- Verilator 5.052: the 422 tokens whose error is neither a syntax error nor marked as unsupported were checked. For 18 of them a legal counterpart was run. The other 404 were judged from the text of the message alone.
- 11 tokens were removed from 10 tests: 8 `iverilog@13.0` and 3 `verilator@5.052`. In each case the release reports the same rejection for a legal use. No test changed its code or its expected result. Eight tests got a short comment and two had a comment reworded.
- 6,389 tests now list `iverilog@13.0` (6,397 before), 2,241 list `verilator@5.052` without it (2,238) and 3,632 have `spec` alone (3,627).
- The 10 tests and one test that shares a check group with one of them ran again on Icarus Verilog 13.0, Verilator 5.052 (seeds 1 and 73) and kirimasim `7de185f776a1`: `coverage/results/oracle-tokens-2-20261112-*.json`. No status changed. The digests of 9 checks of 7 requirements were refreshed, and the baseline was written again because 2 of the requirements have check groups.
- Design coverage stays at 90.14% (11,086/12,298). Execution coverage is 50.24% (6,178/12,298) without Ghost; it was 50.27% (6,182). With the results of Ghost and of kirimasim added it is 77.62% (9,546/12,298); it was 77.65% (9,550). Four requirements of the kind error lost their execution evidence, one each in 10.9, 21.4, 23.11 and 35.5.4.

### 2026-11-12 (report and lint tools)

- `tools/lint_metadata.py`: the baseline was keyed by test and rule, so a new problem of a rule was hidden in a test that already had a known problem of that rule. `tools/lint_baseline.txt` now holds the number of known problems for each test and rule, and more than that number is reported. The file was migrated with the counts of this date: 409 entries, 179 of them with more than one problem. `--update-baseline` with TEST arguments is refused, because it would drop the entries of the other tests.
- `tools/results_history.py`: `update --time` with an earlier time appended the run at the end, so it became the latest run, replaced `latest/<simulator>.json` and was compared with a newer run. The history is now kept in time order and such a run is neither compared nor made the latest. A `--time` that is not a time is refused, and one without a UTC offset is read as UTC. The history of the results branch (34 runs, already in time order) renders to the same report and charts as before.
- Text files are read and written as UTF-8 in the tools whose source is not part of saved evidence. With `LC_ALL=C` and Python's UTF-8 mode off, `behavior_coverage.py --check`, `coverage_depth.py --check` and `requirement_matching.py --check` stopped on a decoding error before and pass now. The runners, `suite_results.py`, `normalize_output.py`, `interaction_coverage.py`, `run_slang.py`, `run_random_cross.py`, `random_cross_*.py`, `qualify_*.py`, `sva_formal_*.py` and `tools/sva_reference/` were not changed, because saved evidence records their digests.
- `tools/behavior_coverage.py`: several `check_groups` of one requirement are alternatives, so one group whose members all pass is sufficient, as the FAQ (Q19) and the glossary say. A comment and a unit test now state this; the counting did not change. 17 requirements have more than one group.
- `tools/run_fst.py`: a simulator that exits with a code above 0 now fails unless `:expected_exit:` allows it, a failing normalizer fails the test, and `--json` records the fingerprints. No test uses this runner yet and no evidence of it is saved.
- The runners and `suite_results.py` were examined and not changed. No figure moved: design coverage 11,086/12,298, execution coverage 6,178 without Ghost and 9,546 with Ghost and kirimasim.

### 2026-11-12 (oracle tokens of illegal tests, third pass)

- A third pass ran a legal counterpart for every illegal test that still listed `verilator@5.052`. The [record](oracle-token-review-20261112.en.md#third-pass) has the details.
- All 541 tests ran on Verilator 5.052 with a legal counterpart. For 421 the marked line was edited into a legal form. For 111 the marked line was removed, because a legal form stays in the file; 36 of these were kept on the writing pattern of the suite, and their files were not read one by one. The second pass had judged 404 tokens from the text of the message alone; that no longer holds.
- 9 `verilator@5.052` tokens were removed from 9 tests. In three tests the legal form gets the same message. In three tests every legal form of the construct is reported as unsupported. In two tests the legal form ends in an internal error, so the rejection cannot be told apart, and in one test the message is about another rule. No test changed its code or its expected result. Eight tests got a short comment and one had a comment reworded.
- 6,389 tests list `iverilog@13.0` as before, 2,234 list `verilator@5.052` without it (2,241 before) and 3,639 have `spec` alone (3,632).
- The 9 tests and 4 tests that share a check group with one of them ran again on Icarus Verilog 13.0, Verilator 5.052 (seeds 1 and 73) and kirimasim `7de185f776a1`: `coverage/results/oracle-tokens-3-20261112-*.json`. No status changed. The digests of 8 checks of 7 requirements were refreshed, and the baseline was written again because 3 of the requirements have check groups.
- Design coverage stays at 90.14% (11,086/12,298). Execution coverage is 50.20% (6,174/12,298) without Ghost; it was 50.24% (6,178). With the results of Ghost and of kirimasim added it is 77.59% (9,542/12,298); it was 77.62% (9,546). Four requirements of the kind error lost their execution evidence, one each in 16.10, 16.12, 25.7 and 29.3.4. The test of 29.3.4 still lists `iverilog@13.0`, but the other test of its check group lists only `verilator@5.052`, so no single release confirms both.

### 2026-11-12 (tests that no simulator passes)

- Two reviews compared with IEEE 1800-2023 the 148 tests that pass on no simulator. The [record](pass-nowhere-review-20261112.en.md) has the verdicts, every correction with its clause, and what waits for a decision. Verdicts: 91 right, 9 wrong, 10 flawed, 17 contested, 21 cannot run anywhere. Both reviews were made by an AI.
- 21 tests changed: 17 of the 19 wrong or flawed tests, and 4 tests outside the 148 that have the same fault. Five tests have a new expected output (`ch16/test_ch16_sim_multiclock_init`, `ch17/test_checker_assertion_placement`, `ch19/test_covergroup_bins_and_range_forms`, `ch35/test_a2_5_dpi_open_array_packed_dimension` and `ch37/test_vpi_struct_and_tagged_patterns`), and so have four generated cases and `ch38/test_vpi_put_value_udp_array_errors`. The others changed their design, their C code or their message pattern and keep the expected output.
- `ch18/test_illegal_constraint_function_cycle` is now the run-time test `ch18/test_constraint_function_cycle_runtime_error`. The suite has 12,262 tests as before; 1,974 are illegal designs (1,975 before).
- The cross model `dpi_openarray_shape` expected `svIncrement` 1 for a dynamic array or queue of one element; 20.7 and H.12.2 give -1. The generator and the independent check were corrected. 32 of the 168 legal rows and four of the 30 selected cases changed their expected output. The rows, the selection and the designs did not change, so the model stays version 1 and no other generated test changed.
- Every legal row of the model ran once (`coverage/interaction-qualification/dpi-array-all-rows-20261112.json`): Verilator 5.052 matches the 72 rows with a fixed-size actual and cannot build the other 96; kirimasim and Icarus Verilog 13.0 execute none. The independent check was repeated (`coverage/interaction-qualification/dpi-array-20261112.json`). kirimasim `7de185f776a1` ran all 4,413 selected cases in one run (`coverage/interaction-results/full-20261112-kirimasim-7de185f7-dpi-array.json`): 3,915 pass, 484 unsupported and 14 fail, as before. The 30 cases of the model ran on Icarus Verilog 13.0 (30 known) and Verilator 5.052 with seeds 1 and 73 (18 pass and 12 known each), as before (`coverage/interaction-results/dpi-array-20261112-*.json`). `generators/oracles.txt` did not change.
- The 21 tests and one test that shares a check group with one of them ran again on Icarus Verilog 13.0, Verilator 5.052 (seeds 1 and 73) and kirimasim `7de185f776a1`: `coverage/results/test-fixes-20261112-*.json`. No status changed: 22 known on each pinned release and 22 unsupported on kirimasim. All 21 tests list `spec` alone, so no `:oracle:` token changed: 6,389 tests list `iverilog@13.0`, 2,234 list `verilator@5.052` without it and 3,639 have `spec` alone.
- The ledger has new input digests for the checks of 51 requirements; 15 of them have a rewritten observation, and so has one check group. The baseline was written again.
- Design coverage is 90.14% (11,085/12,298); it was 11,086. The requirement of 18.5.11 has the kind error, and the ledger accepts only an illegal-design test for such a row, so its mapping was withdrawn when its test became a run-time test. The reason is in `coverage/test-matching-reviews.json`. Clauses 1 to 40 alone are at 88.46% (8,373/9,465); they were at 88.47% (8,374).
- Execution coverage without Ghost stays at 50.20% (6,174/12,298). With the results of Ghost and of kirimasim added it is 77.57% (9,540/12,298); it was 77.59% (9,542). Two requirements of 37.16 lost their evidence: their test `ch37/test_vpi_net_bits_constant_select` passed in Ghost's saved runs, and its C code changed. Ghost's saved results were not replaced.
- Two differences of the pinned releases were recorded in the [list](simulator-differences.md#icarus-increment-dynamic-20261112): Icarus Verilog 13.0 gives 0 for `$increment` of a one-element dynamic array, and Verilator 5.052 reports no error for the cycle of 18.5.11.
- Not changed, waiting for a decision: `ch4/test_illegal_final_deferred_action_schedules_event`, `ch18/test_illegal_randsequence_negative_weight` and the 17 contested tests.
- The README named the run `full-20261112-kirimasim-7de185f7-edgedpiquery.json` as the latest complete cross run. It now names the run of this entry.

### 2026-11-12 (run-time error requirement of 18.5.11)

- The requirement of 18.5.11 that a circular dependency of the implicit function-argument ordering is an error had the error kind, which maps only to illegal designs with `:should_fail_because:`. The ordering exists among the constraints that are active when `randomize()` is called, so the error may be reported while the design runs. With the owner's approval it is now a normal requirement, like the five run-time error requirements of 2026-11-09, whose errors are tested with `:expected_stderr_regex:`.
- It is mapped to `ch18/test_constraint_function_cycle_runtime_error`, reviewed on 2026-11-12 by an AI. The record of the withdrawn mapping was removed from `coverage/test-matching-reviews.json`. The baseline of `coverage/behaviors.json` was written again with this reason, as the kind is part of the requirement's contract, so the denominator digest changes; the 12,298 rows do not.
- Design coverage returns to 90.14% (11,086/12,298), and to 88.47% (8,374/9,465) for clauses 1 to 40. Execution coverage does not change: 50.20% (6,174/12,298) without Ghost and 77.57% (9,540/12,298) with Ghost and kirimasim. No saved run passes the test: both pinned releases have a known mismatch and kirimasim does not support it.

### 2026-11-12 (run-time error requirements, second set)

- Ten requirements of the error kind that had no mapped test were read against the standard again. Seven of them are errors that only the run can find, because the value, size, tag or message type comes from a variable: an invalid `$cast` called as a task (6.24.2), a size mismatch of a bit-stream cast with a dynamically sized type (6.24.3), a negative size of `new[]` (7.5.1), a dynamic array or queue copied to a fixed-size array of another size (7.6), a tagged union member read or assigned against the current tag (11.9), and `get` and `peek` on a typeless mailbox with a variable of another type (15.4.5, 15.4.7). Like the requirements of 2026-11-09 and the one of 18.5.11, they are now normal requirements, tested with `:expected_stderr_regex:`. Their behaviour and acceptance text did not change.
- Ten tests were added: nine run-time tests and the illegal test `ch15/test_illegal_mailbox_get_unpacked_array`. The requirements of 7.6 and 11.9 each have a check group of two tests, one for each source kind (dynamic array, queue) and one for each access (read, assignment). The requirement of 15.4.5 that the destination of `get` is a singular left-hand expression is a rule of the source text: it keeps the error kind and is mapped to the illegal test, which checks only that the destination is singular.
- An author and an independent reviewer worked separately, both AI. The author wrote the tests and the proposals for the ledger from the standard. The reviewer derived each expectation from the standard again, and found all ten derivable. The edits the reviewer asked for were comments only: three tests now say that their last expected line assumes that the run goes on after the run-time error, which the standard does not state in so many words (it fixes the state: destination unchanged, no operation), and the test of 6.24.2 says that it follows the example of the clause, which calls a value outside the enumeration an invalid cast, while the defining sentence speaks of cast-compatible types.
- Two rows were left as they are: 20.14.2 (the arguments of the distribution functions shall be greater than 0) and 7.8.4 (an index with x or z is invalid). The standard states no error for either: Annex N gives a warning and the value 0, and 7.8.6 gives a warning. Whether these rows should have the error kind is a question for the denominator, not for this change.
- The ten tests ran on Icarus Verilog 13.0, Verilator 5.052 (seeds 1 and 73) and kirimasim `7de185f776a1`: `coverage/results/runtime-errors-20261112-*.json`. Icarus has 10 known, Verilator 1 pass and 9 known on both seeds, kirimasim 1 pass and 9 unsupported. `ch6/test_cast_task_enum_value_runtime_error` matches on Verilator 5.052 and lists `verilator@5.052`; the other nine list `spec` alone. `ch7/test_dynamic_array_new_negative_size_runtime_error` matches on kirimasim. No simulator runs the tests of 7.6, 11.9, 15.4.5 and 15.4.7 to the error, and none passes the test of 6.24.3.
- Three differences of the pinned releases were recorded in the [list](simulator-differences.md#negative-new-size-20261112): Verilator 5.052 reports no error for `new[n]` with a negative `n`, Icarus Verilog 13.0 ends that run abnormally without a message of its own, and Icarus Verilog 13.0 reports the size mismatch of the bit-stream cast and then does not end the run.
- The baseline of `coverage/behaviors.json` was written again, as the kind is part of a requirement's contract, so the denominator digest changes; the 12,298 rows do not. The suite has 12,272 tests: 6,389 list `iverilog@13.0`, 2,235 list `verilator@5.052` without it and 3,648 have `spec` alone.
- Design coverage is 90.21% (11,094/12,298); it was 90.14% (11,086). For clauses 1 to 40 it is 88.56% (8,382/9,465); it was 8,374. Execution coverage without Ghost is 50.21% (6,175/12,298); it was 6,174: the requirement of 6.24.2 is executed through Verilator 5.052. With the results of Ghost and of kirimasim added it is 77.59% (9,542/12,298); it was 9,540: the requirement of 7.5.1 is executed through kirimasim only.

### 2026-11-12 (external review: the formal share, and document fixes)

- An external review of `5705c9b8` counted the tests, the syntax kinds and the distribution of supporting results again with its own scripts. Its counts and its classification agree with a recalculation here from the same Nightly results.
- The README gave 268 tests with `:type: formal`; it is 267 now. The number had stayed after one test was removed as a duplicate.
- The fixed Japanese text of the test catalog, the clause list and the coverage depth page is corrected: 131 entries of `tools/doc_locales/ja.json`. Chapter titles and notes were mistranslated or were still machine-translation drafts. The translations of the test descriptions (`:description:`) are not part of this change.
- The review suggested that the rules for functions in 16.6 and 18.5.11 might be recommendations (should). The standard says "shall" in both. The three tests and the ledger row are unchanged.
- A formal check runs no simulator. The summary and the README now say how many of the executed rows are confirmed by a simulator and how many by formal checks alone. Of the 6,175 rows without Ghost, 5,885 are from simulators and 290 from formal checks alone. Of the 9,542 rows with Ghost and kirimasim, 9,252 are from simulators and 290 from formal checks alone. The denominator and the percentages so far do not change.
- The review counted 54 illegal tests that neither the public tools nor slang reject. All 54 were matched against the earlier verdicts: 20 were found right in the [review of the tests that no simulator passes](pass-nowhere-review-20261112.en.md), 21 are recorded as deviations of kirimasim in an issue or in the list of differences, six are contested, one is flawed, and one was reviewed independently when it was added. The other five are rejected by Ghost alone and were read against the standard now: 14.16.2, 16.8, 21.3.4.3 (two tests) and 7.8.1 each state the rule with "shall", so the expectations are right. No test was changed.

### 2026-11-13 (check of the test-side issues #58 to #72)

- The 15 open test-side issues were compared with the current tests. Eleven of them (#58, #59, #61 to #64, #66 to #69 and #72) had already been fixed by the reviews of 2026-11-09 and 2026-11-12.
- `ch31/test_31_extra_fullskew_active_flag` of #60 is corrected. `clkn` started at 0, so the input net of the cell went from x to 0 at time zero. 31.5 names that change as a negedge, and the result depended on whether it counts as a data event. `clkn` now starts at 1, and only `clkn` changes at 10. By 31.4.3 the window that the posedge of `clk` starts at 5 ends in a violation at 7, and the window that the negedge of `clkn` starts at 10 ends in a violation at 13. By Table 31-13 of 31.6 each notifier changes twice, so the expected output stays `t=20 n=00`. The old comment gave as the reason that the pinned releases do not run the check. It now explains the result from the clauses.
- A simulator that does not run the check also prints `00`. What this test confirms is that a design with a constant expression as the flag builds and runs.
- This test ran again on Icarus Verilog 13.0, Verilator 5.052 (seeds 1 and 73) and kirimasim `7de185f776a1`: `coverage/results/test-fix-20261113-*.json`. No status changed. Both pinned releases pass, and kirimasim does not support it. Ghost's saved result for this test is now stale. The saved result was a mismatch. Design coverage and execution coverage are unchanged.
- `ch37/test_vpi_attribute_ports_params` of #65 is unchanged. Detail 4 of 37.28 says that `vpiLhs` of a param assign is the overridden parameter. But the diagram of 37.83 lists param assign, and not parameter, among the objects that have attributes, and detail 3 of 37.32 speaks of the param assign of a parameter without an explicit value. Whether a parameter that the instance does not override has a param assign can be read both ways.
- The 15 tests of #71 are unchanged. The rule that an error line must carry `file:line:` stays, as decided for #27. #70 is about the settings used to run Ghost and is not a change to a test.

### 2026-11-13 (review of the tests that only Ghost passes: Clause 37)

- In the Nightly of 2026-11-12, 756 tests match their expectation on Ghost alone. Two reviews, independent of each other, compared the 193 tests of Clause 37 with the standard. Where the verdicts differ, or depend on the arrows of a diagram, the diagrams of the standard decided. The record is the [review of the tests that only Ghost passes: Clause 37](ghost-only-review-ch37-20261113.en.md).
- The verdicts: 142 expectations are right, 4 are wrong, 26 tests are flawed, 4 depend on a gap in the standard and 17 rest on a contested reading.
- The four wrong tests expect the type `vpiBitSelect` for a bit of a net or of a variable. By 37.16 and 37.17 these are a net bit and a var bit.
- The gap in the standard: the header of Annex M has no constant for the tag `vpiNetTypedef` that 37.10 and 37.85 show.
- No test was changed. The 30 wrong or flawed tests will be corrected when Ghost's results are saved again. The coverage figures are unchanged.

### 2026-11-13 (review of the tests that only Ghost passes: Clause 16)

- The 90 tests of Clause 16 that match their expectation on Ghost alone were compared with the standard by two reviews, independent of each other, with the method used for Clause 37. The record is the [review of the tests that only Ghost passes: Clause 16](ghost-only-review-ch16-20261113.en.md).
- The verdicts: 85 expectations are right and 5 rest on a contested reading. None is wrong or flawed.
- Three of the five ask whether a sequence without a match can be written in a `cover sequence` (16.12.22 and 16.14.3). One is about the number of calls written inside `first_match` (16.9.8 and 16.11), and one about writing back an assignment to a `local input` formal (16.8.1 and 16.8.2).
- No test was changed. The coverage figures are unchanged.

### 2026-11-13 (review of the tests that only Ghost passes: Clauses 36, 38, 39 and 40)

- The 141 tests of Clauses 36, 38, 39 and 40 that match their expectation on Ghost alone were compared with the standard by the same method. The record is the [review of the tests that only Ghost passes: Clauses 36, 38, 39 and 40](ghost-only-review-vpi-20261113.en.md).
- The verdicts: 108 expectations are right, 3 are wrong, 19 tests are flawed and 11 rest on a contested reading.
- One wrong test expects `cbAssertionKill` for `$assertkill` with arguments. Table 20-8 of 20.11 gives `cbAssertionReset` and `cbAssertionDisable`. The other two pass the path of an instance as a string for the coverage scope. By the NOTE of Table 40-2 in 40.3.2.1 a string is a definition name.
- Ten of the 19 flawed tests use, from the startup routine, a routine or a callback reason that 36.10.2 does not allow.
- No test was changed. The coverage figures are unchanged.
- So far 424 of the 756 tests that pass on Ghost alone are reviewed (193 of Clause 37, 90 of Clause 16, 141 of Clauses 36, 38, 39 and 40). Seven are wrong, 45 are flawed, 4 depend on a gap in the standard and 33 rest on a contested reading.

### 2026-11-13 (review of the tests that only Ghost passes: the remaining clauses)

- The remaining 332 tests that match their expectation on Ghost alone were compared with the standard. To limit the usage, each test was read by one review. For every verdict other than "right", the text, the syntax or the figure of the standard that it rests on was checked again. The record is the [review of the tests that only Ghost passes: the remaining clauses](ghost-only-review-rest-20261113.en.md).
- The verdicts: 289 expectations are right, 19 tests are flawed and 24 rest on a contested reading. No expectation is wrong.
- Among the 19 flawed tests, five designs are not legal, three print a different set of lines depending on a change at time 0 or on the order of updates in one time step, two check statistics, and two generated tests use `$fread` in a way the standard does not define.
- Five of the 24 contested tests come from the conflict about `#( )` in a use clause of a config, which is already recorded.
- No test was changed. The coverage figures are unchanged.
- All 756 tests that pass on Ghost alone are now reviewed. 624 expectations are right, 7 are wrong, 64 tests are flawed, 4 depend on a gap in the standard and 57 rest on a contested reading.
