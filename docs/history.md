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
