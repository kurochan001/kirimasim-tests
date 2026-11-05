# Cross-verification failures and follow-up priorities

[English](cross-verification-followup.en.md) / [日本語](cross-verification-followup.md)

Updated on 2026-11-06 JST, retaining the repair records from 2026-11-03. Preserve fixed regressions, formal Nightly, existing expectations
and selected models while addressing known failures, inventorying unsupported mechanisms
and reviewing unexamined chapter pairs, in that order.

The current [complete local selection](../coverage/interaction-results/cross88-kirimasim-6f5c6984-pkgquery.json) has 88 models and 3,244 cases:
2,711 pass, 529 unsupported and four config failures. All 36 package-query additions pass; all preceding 3,208 inputs and statuses are unchanged.
The new 36 cases have not run in formal Check/Nightly.

[Check on baseline 9c39d865](https://github.com/kurochan001/kirimasim-tests/actions/runs/42051092628) passed pinned-release comparisons and static checks for the preceding 86-model suite.
The [verified formal Nightly](nightly-results.en.md#latest-verified-checkpoint) covers 82 models on 19cd790a; the new 36 cases have not run in either Check or Nightly.
The historical uncommitted builds below explain the repair process; they do not describe the current upstream state.
One successful kirimasim-tests Nightly is separate from the core repository's seven-consecutive-Nightly condition.

The 2026-11-04 fixed-suite checkpoint recorded five ordinary Chapter 30 specify-condition tests improving from unsupported to pass.
They are outside this finite selection; its 12 state-dependent specify-path and six SDF-annotation unsupported cases retain their statuses.
The [current verification record](../coverage/interaction-qualification/formal-ci-9926160a-20261104.json) lists the five test identities and confirms unchanged fixed inputs.

<a id="triage-of-the-eleven-failures"></a>
<a id="不一致11件の切り分け"></a>

## Triage of the original eleven failures

- **Two inside comparisons: integrated repair and confirmed PASS.** The existing kirimasim
  branch commit `b16163c7` already contained the fix and mechanism matrix. They were applied
  to the then-current main working tree in the 2026-11-03 integration snapshot. Array members extend by the common comparison type's sign,
  rather than their own. `Lowerer::memberMatch` and `Lowerer::propagate` implement the rule;
  ordinary inside, array members and case inside share that path. No separate new algorithm was created.
- **Five deferred assertions: approved and repaired.** The maintainer approved the contract
  on 2026-11-03. The core now shares one statement identity across its action wrappers and cancels
  only still-pending reports. Sibling reports, evaluated side effects and settled history remain.
  Core `docs/notes/deferred-label-cancellation.md` documents implementation and scope.
- **Four config cases: localized to pinned slang.** Parameter queries without front, SIR or VM
  disagree on the same four of 41 inputs. A separate diagnostic dependency patch makes all 41 queries
  match. It is not applied to the production dependency or kirimasim. See core
  `docs/notes/config-reset-dependency-gap.md`.

The [original full selection](../coverage/interaction-results/cross75-kirimasim-f3ea0379.json)
records 2,245 pass, 529 unsupported and 11 fail.
The [selection after the inside repair](../coverage/interaction-results/cross75-kirimasim-26a3e5a3-insidefix.json)
records **2,247 pass, 529 unsupported and 9 fail**. All 2,785 input fingerprints are unchanged;
the only status transitions are those two fail→pass cases.
[Complete-output replays of the eleven inputs](../coverage/interaction-qualification/cross-failures-20261103.json) are retained.

The recorded inside-repair binary used local main `26a3e5a3` plus uncommitted changes, not an upstream-main release.
Consult the [revision, reused fix, source and binary record](../coverage/interaction-qualification/insidefix-build.json).
The mechanism matrix compares 120 output lines in each of four initial/task/always/fork inputs;
12 related checks pass. Full core local CI also passes. This does not update formal Nightly
or the required seven consecutive Nightly runs.

The subsequent approved-label implementation uses upstream main `7654825d` plus local changes
and the updated unmodified slang pin `d02b7cda`. Its [full selection](../coverage/interaction-results/cross75-kirimasim-7654825d-labelcancel-final.json)
records **2,252 pass, 529 unsupported and four fail**. Only the five label failures change
relative to the inside-repair snapshot; all inputs remain identical. All 31 deferred-disable
cases pass. The [build record](../coverage/interaction-qualification/labelcancel-build.json)
and [five complete-output replays](../coverage/interaction-qualification/labelcancel-replays.json)
identify the actual implementation and binary. Twenty new core suite inputs and focused
37 checks pass; full core local CI passes all 21 steps (11,827 tests each in dev/ASan/UBSan; 11,828 in release). Formal Nightly remains separate.

## Inventory of the 529 unsupported cases

The [fingerprinted inventory of all cases and 19 mechanisms](../coverage/interaction-qualification/unsupported-triage-20261103.json)
classifies one snapshot. It is neither a new skip list nor a PASS count. Main families are:

- Concurrent assertions: 99; checkers: 27.
- Randomize: 52; covergroups: 33.
- DPI runner prechecks: 67, distinguished from actual runtime unsupported diagnostics.
- Event values: 45; mailboxes: 36.
- Set array members: 26; tolerance ranges: 16; side effects in set members: 8.
- Clocking zero skew: 18; guards: 12; virtual interfaces: 19.
- Typed associative arrays: 18.
- Class array properties: 11; property references: 6; ref actuals: 18.
- State-dependent specify paths: 12; SDF annotation: 6.

SDF annotation is the first candidate for a detailed contract review. It includes three cases
with registered fixed Icarus oracles; [the new Icarus 13.0 run](../coverage/interaction-results/cross-followup-sdf-icarus13.json)
also matches those three. The other three increment cases remain known differences; their oracles
and expectations are unchanged. The current core specify contract explicitly excludes SDF,
so establish the standard scope and specification amendment first. Case counts and simulator
majorities alone determine neither implementation priority, correctness nor P1 completion.

## Unexamined pairs and future test additions

At the initial review, two R pairs were reviewed and 590 remained unassessed.

- **Chapters 13×16: E at review, now M.** An existing deferred-action argument test observes registration-time
  pass-by-value and post-NBA reference values in the same stimulus and expectation. Source and
  expectation were reviewed and [re-executed on the latest local build](../coverage/interaction-results/cross-followup-subroutine-kirimasim-26a3e5a3-insidefix.json).
  That individual replay added no finite-model chapter mapping or complete label-cancellation PASS claim.
  The subsequent [deferred-argument model](interaction-verification.en.md#deferred-argument-capture)
  explicitly crosses width, signedness, passing, formal width, routine, report queue and update mode in 29 new cases.
  All 29 passed in the single 2,814-case snapshot at that addition, moving Chapters 13×16 to M.
- **Chapters 11×33: C.** Configuration expression width and signedness versus generated shape
  is a candidate. Retain the existing model's name-resolution and precedence checks; consider
  word boundaries, expression types, signedness, operators and conditional expressions as future
  independent factors. First establish legal expressions and positive dimensions and repair the
  known config reset difference.

The current triage is M131, E3, C2, N117 and R567. See the
[pair rationales and fingerprints](chapter-cross-triage.en.md). Reuse existing regression matrices
and extend confirmed mechanisms with boundaries, operation sequences and fault controls.
No parallel-purpose runner or addition of random outcomes to fixed requirement coverage was introduced.

The subsequent [enum/generate model](interaction-verification.en.md#generated-enum-navigation) reviews the previously unassessed Chapters 6×27 pair and registers it as M. All 36 additions pass in the single complete 2,850-case run on upstream `7554bb47`; the remaining four config failures and 529 unsupported cases are unchanged. That addition left 589 R pairs. Earlier counts in this record describe their dated review checkpoints.

The subsequent [package-NBA model](interaction-verification.en.md#package-nba-capture) moves previously unassessed Chapters 10×26, 4×26 and 7×26 to M. All 36 additions pass in one 2,886-case run on upstream `7554bb47`; existing config failures and unsupported cases are unchanged. The array mapping uses 24 cases and the full-model PASS still requires all 36. That checkpoint left 586 R pairs.

The subsequent [package-observer model](interaction-verification.en.md#package-change-observers) moves previously unassessed Chapters 9×26 and 11×26 to M. The former maps all 36 cases; the latter maps the 12 logic X/Z cases. It also adds observations to existing Chapters 4×26 and 7×26 mappings. All 36 additions pass in the single complete 2,922-case run on upstream `a682e19e3238`; all preceding 2,886 inputs and statuses are unchanged. That checkpoint left 584 R pairs; it did not claim verification of every remaining pair.

The [class method/package model](interaction-verification.en.md#class-method-package-lookup) on 2026-11-04 moves the previously unassessed Chapters 8×26 pair to M.
All 34 additions pass in one complete 2,956-case run on upstream `9113955914d8`; all preceding 2,922 inputs and statuses are unchanged.
At that addition there were 80 models, 115 chapter pairs and 53 full-selection-pass models, with 2,423 pass, 529 unsupported and four config failures.
That checkpoint left 583 R pairs. This local result is separate from formal Check/Nightly and does not establish complete class/package coverage.

The 2026-11-05 [generated-subroutine model](interaction-verification.en.md#generated-subroutine-binding) moves Chapters 13×27 and 7×27 from R to M and strengthens existing 7×13.
All 36 additions pass in one complete 2,992-case run on upstream `162222153c57`; all preceding 2,956 input fingerprints and statuses are unchanged.
There are 81 models, 117 chapter pairs and 54 full-selection-pass models; 581 pairs remain R. Pinned Icarus matches all 36,
while pinned Verilator seeds 1/73 each record 11 pass and 25 known. Preserve the signed task-copy-out difference and its function control;
this comparison does not change expectations, the regression ratchet, random profiles or requirement bindings.

The next 2026-11-05 [class-selection model](interaction-verification.en.md#class-conditional-return) moves 8×11 and 8×12 from R to M.
All 36 additions pass in one complete 3,028-case run on upstream `162222153c57`; all preceding 2,992 inputs/statuses are unchanged.
There are 82 models, 119 chapter pairs and 55 full-selection-pass models, with 2,495 pass / 529 unsupported / four existing config failures.
Triage now leaves 579 R pairs. All 1,296 legal programs agree under independent interpretation; five native controls and nine source faults validate the observations.
Pinned Verilator seeds 1/73 each give 12 pass / 24 known; pinned Icarus rejects all 36 class-handle comparisons.
The unchanged X/Z expectations and [full known-outcome replays](../coverage/interaction-qualification/classsel-known-replays.json) remain separate from native passes and four-state oracle claims.

The generated-loop addition reviews 12×27 and 9×27 and strengthens 7×27. Its 36 cases preserve 293 pairs, 160 targeted triples and six anchors from 6,912 legal rows.
Freshly built `50a897dee62a` passes all 36 in one full 3,064-case run; the preceding 3,028 fingerprints/statuses are unchanged.
Totals are 83 models / 121 pairs / 56 full-selection-pass models; triage is M121 / E3 / C2 / N117 / R577.
Icarus matches 31 inputs; five repeat-count-one cases retain build rejections and independently interpreted count-three controls.
All 6,912 source interpretations agree; five native controls and nine real source faults validate observations.
Baseline 19cd790a now has successful formal Check/Nightly and 96 valid random passes; the new finite cases remain local evidence.
See [design and complete records](interaction-verification.en.md#generated-process-loop-transfer).

## Interface query-driven walks (2026-11-05)

Added the [7×25, 20×25 and 13×20 model](interaction-verification.en.md#interface-array-query-walk).
Select 36 of 4,608 legal combinations; independently interpret every row and validate five normal controls and nine executable SV faults.
Freshly fetched/built `50a897dee62a` runs all 3,100 cases together: all 36 additions parse/pass, and preceding 3,064 inputs/statuses are unchanged.
Pinned Icarus matches all 36 including X/Z; both Verilator seeds match the twelve known-input cases. Incidental two-state matches do not validate four-state behavior or obtain oracles.
Requirement bindings, thirteen random profiles, existing regressions and core source are unchanged.

- Added [formatted scanning/partial writes](interaction-verification.en.md#formatted-scan-partial-write) for 11×21 and 20×21.
  Select 36 of 5,760 legal representatives, retaining 292 pairs, 142 targeted triples and six anchors. Validate independent interpretation, six normal controls and nine real SV faults.
- One full 3,172-case run on freshly fetched/built `6f5c69841228` records 2,639 pass / 529 unsupported / four existing config failures.
  All additions parse/pass and preceding 3,136 inputs/statuses are unchanged. Totals: 86 models / 128 chapter pairs / 59 full-selection-pass models;
  triage M128 / E3 / C2 / N117 / R570.
- Pinned Icarus gives 17 pass / 19 known; both Verilator seeds give 3 pass / 33 known. Retain original differences and separate same-stimulus literal controls without weakening expectations/classification.
  Map 24 part-select cases to 11×21 and twelve runtime-format cases to 20×21; full-model success requires all 36 together.
- Suite totals: 10,922 tests, including 4,485 generated cases from 95 generators. Requirement bindings, existing regressions, core code and thirteen random profiles are unchanged.
  The new 36 cases have not run in formal Check/Nightly.
