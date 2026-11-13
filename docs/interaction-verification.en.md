<a id="機能間クロス検証の導入"></a>

# Introducing cross-feature verification

[English](interaction-verification.en.md) / [日本語](interaction-verification.md)

Instead of executing the full Cartesian product of all features, use small models with semantic interactions, based on constrained 2-factor coverage. Specify 3-factor coverage for interactions that must not be missed, retaining critical cases such as width boundaries individually. Aggregate generation plans and execution verification separately in [Interaction verification report](interaction-coverage.en.md).

See [Principles and practical procedure](interaction-verification-method.en.md) for design principles, selection algorithms, model-addition procedures, and application to other projects or LSI. [Glossary](glossary.en.md#8-機能間クロス検証) and [FAQ](faq.en.md#7-機能間クロス検証) explain the cross-chapter table, execution satisfaction, controls / fault injection, and how to read saved records. The boundary-condition regression tests added in Issue #21, pending interpretations, and the scope of separate API work are summarized in [Regression incorporation report](p1-combination-regressions-20261030.en.md) and [Mapping registry](../coverage/combination-gaps.json).

Before reading model counts, see [a three-way condition missing from 100% pairwise coverage](faq.en.md#q28-why-not-simply-cross-every-feature) and [planned coverage versus passing execution](faq.en.md#q29-can-a-complete-plan-still-have-unsupported-or-failing-execution).

<a id="保存実行の概要"></a>

## Saved-run summary

The 2026-11-14 addition for where the run is ended and how it ends brings totals to **111 models / 4,455 cases / 191 chapter pairs**.
The [single run](../coverage/interaction-results/full-20261114-kirimasim-afc7733c.json) on kirimasim `afc7733c8167`, built from the latest main, records
**3,967 pass / 484 unsupported / 4 fail**: only the four existing config failures.
All 42 additions pass. The four `defparam` type and range cases and the six class cases in generate blocks, which failed before, now pass. The preceding 4,413 inputs are unchanged. 86 models pass their entire selection.
See [where the run is ended and how it ends](#simulation-end-sources) for the independent check and the pinned comparisons.

The 2026-11-08 additions for classes declared in modules and generate blocks, case item literal digits and structure literal keys bring totals to **110 models / 4,416 cases / 189 chapter pairs**.
The [single run](../coverage/interaction-results/cross110-kirimasim-f029ddd0-scopecaselit.json) on kirimasim `f029ddd0eee1`, built from the latest main, records
**3,915 pass / 487 unsupported / 14 fail**: the four existing config failures, the four `defparam` failures and six of the new class cases.
106 of the 120 additions pass; six stop on a kirimasim internal error for a class in a conditional generate block, and eight use a structure localparam that kirimasim has not implemented.
Preceding 4,296 inputs and statuses are unchanged. 83 models pass their entire selection.
See [classes declared in a module or a generate block](#scoped-class-declaration), [case item literal digits](#case-literal-wildcard) and [structure literal keys](#aggregate-literal-key) for the independent checks and pinned comparisons.
The 120 additions passed the pinned comparisons in [Check on `a9c8a8eb`](https://github.com/kurochan001/kirimasim-tests/actions/runs/42461618429); they have not run in Nightly.

On 2026-11-12 the models [`edge_event_expression`](#event-expression-edge-classification-xz-transitions-and-update-timing) and [`sv_dpi_array_queries`](#sv-dpi-array-queries) were revised so that they select no equal cases. The totals are now **110 models / 4,413 cases / 189 chapter pairs**.
The [single run](../coverage/interaction-results/full-20261112-kirimasim-7de185f7-edgedpiquery.json) on kirimasim `7de185f776a1` records **3,915 pass / 484 unsupported / 14 fail**, with the same 14 failures. 83 models pass their entire selection.

On 2026-11-12 one expected value of the model [`dpi_openarray_shape`](#dpi-open-array-shape-and-copyback) was corrected: `svIncrement` of a dynamic array or queue of one element is -1 (20.7, H.12.2). Four selected cases changed their expected output. The rows, the selection and the totals did not change.
The [single run](../coverage/interaction-results/full-20261112-kirimasim-7de185f7-dpi-array.json) of all 4,413 cases on kirimasim `7de185f776a1` after the correction records **3,915 pass / 484 unsupported / 14 fail**, with the same 14 failures.

The 2026-11-08 delay-value, package-lookup and escaped-name additions bring totals to **107 models / 4,296 cases / 185 chapter pairs**.
The [single run](../coverage/interaction-results/cross107-kirimasim-28c6c1a1-delaypkgesc.json) on kirimasim `28c6c1a1cb83` records
**3,809 pass / 479 unsupported / eight fail**: the four existing config failures and the four where `defparam` gets the type and range wrong, as before.
All 126 additions pass, and preceding 4,170 inputs and statuses are unchanged. 82 models pass their entire selection.
See [how a delay value is written](#delay-value-form), [package name lookup](#package-name-lookup) and [escaped identifier binding](#escaped-name-binding) for the independent checks and pinned comparisons.
The 126 additions passed the pinned comparisons in [Check on `c229a05f`](https://github.com/kurochan001/kirimasim-tests/actions/runs/42435564931); they have not run in Nightly.

The 2026-11-08 hierarchical-process-control, %m and array-query-loop additions bring totals to **104 models / 4,170 cases / 181 chapter pairs**.
The [single run](../coverage/interaction-results/cross104-kirimasim-28c6c1a1-hierloop.json) on kirimasim `28c6c1a1cb83`, built from the latest main, records
**3,683 pass / 479 unsupported / eight fail**: the four existing config failures and the four where `defparam` gets the type and range wrong, as before.
All 147 additions pass, and preceding 4,023 inputs and statuses are unchanged. 79 models pass their entire selection.
See [process control through hierarchical names](#hierarchical-process-control), [hierarchical names printed by %m](#hierarchical-name-display) and [array query functions and loops](#array-query-loop) for the independent checks and pinned comparisons.
The 147 additions passed the pinned comparisons in [Check on `b091fd3a`](https://github.com/kurochan001/kirimasim-tests/actions/runs/42424091234); they have not run in Nightly.

The 2026-11-07 parameter-override, assertion-query and literal-argument additions bring totals to **101 models / 4,023 cases / 177 chapter pairs**.
The [single run](../coverage/interaction-results/cross101-kirimasim-eee8cd16-paramassertlit.json) on kirimasim `eee8cd16ba1d`, built from the latest main, records
**3,536 pass / 479 unsupported / eight fail**: the four existing config failures and four additions where `defparam` gets the type and range wrong.
132 of the 136 additions pass, and preceding 3,887 inputs and statuses are unchanged. 76 models pass their entire selection.
See [parameter overrides and types](#parameter-override-type), [bit vector functions in assertions](#assertion-vector-query) and [literal arguments and conversion](#literal-argument-conversion) for the independent checks and pinned comparisons.
The 136 additions passed the pinned comparisons in [Check on `76cb9785`](https://github.com/kurochan001/kirimasim-tests/actions/runs/42386486773); they have not run in Nightly.

The 2026-11-07 interface-expression, loop-control and literal-format additions bring totals to **98 models / 3,887 cases / 173 chapter pairs**.
The [single run](../coverage/interaction-results/cross98-kirimasim-6e32b04e-ifexprloopfmt.json) on kirimasim `6e32b04ed6ec`, built from the latest main, records
**3,404 pass / 479 unsupported / four existing config failures**. All 195 additions pass. Preceding 3,692 inputs are unchanged,
and 50 `inside`, range and `case inside` cases moved from unsupported to pass. 74 models pass their entire selection.
See [interface members](#interface-member-expression), [loop control and scheduling regions](#loop-control-scheduling) and [literal forms and display formats](#literal-format-display) for the independent checks and pinned comparisons.
The 195 additions passed the pinned comparisons in [Check on `b81077b0`](https://github.com/kurochan001/kirimasim-tests/actions/runs/42377388671); they have not run in Nightly.

The 2026-11-07 macro, force/release and implicit-sensitivity additions bring totals to **95 models / 3,692 cases / 168 chapter pairs**.
The [single run](../coverage/interaction-results/cross95-kirimasim-97d5b000-macroforcesense.json) on kirimasim `97d5b0001e7c`, built from the latest main, records
**3,159 pass / 529 unsupported / four existing config failures**. All 247 additions pass; preceding 3,445 inputs/statuses are unchanged.
68 models pass their entire selection.
See [macro expansion and context](#macro-expansion-context), [force and release](#force-release-visibility) and [implicit sensitivity](#implicit-sensitivity-update) for the independent checks and pinned comparisons.
The 247 additions passed the pinned comparisons in [Check on `6a0f260c`](https://github.com/kurochan001/kirimasim-tests/actions/runs/42352682135); they have not run in Nightly.

The 2026-11-07 time-scope, literal and gate-array additions bring totals to **92 models / 3,445 cases / 151 chapter pairs**.
The [single run](../coverage/interaction-results/cross92-kirimasim-60c26d7c-timelitgate.json) on kirimasim `60c26d7c8113`, built from the latest main, records
**2,912 pass / 529 unsupported / four existing config failures**. All 165 additions pass; preceding 3,280 inputs/statuses are unchanged.
65 models pass their entire selection. These are the first models whose primary chapters are 3 and 5.
See [time scopes and delays](#time-scope-delay), [literals and expression context](#literal-context-extension) and [gate-array connections](#gate-array-connection).
The 165 additions and the 36 event-loop cases have not run in formal Check/Nightly. Records below describe each addition at its time.

On 2026-11-07 the fix for Issue #28 changed the inputs of two selected `scheduling_visibility` cases, so [all 3,280 cases were run again](../coverage/interaction-results/cross89-kirimasim-1e840ea3-assignwait.json) on a saved build of kirimasim `1e840ea322cc`.
The run records **2,747 pass / 529 unsupported / four existing config failures**, with no status changed from the previous complete run on `6f5c69841228`. The model's 51 cases all pass on [Icarus 13.0](../coverage/interaction-results/scheduling-20261107-icarus13.json); Verilator 5.052 [seed 1](../coverage/interaction-results/scheduling-20261107-verilator5052-seed1.json) and [seed 73](../coverage/interaction-results/scheduling-20261107-verilator5052-seed73.json) record 43 pass and 8 known.

The 2026-11-06 event-loop addition brings totals to **89 models / 3,280 cases / 132 chapter pairs**.
The [single run](../coverage/interaction-results/cross89-kirimasim-6f5c6984-eventflow.json) on freshly fetched/built `6f5c69841228` records
**2,747 pass / 529 unsupported / four existing config failures**. All 36 additions parse/pass; preceding 3,244 inputs/statuses are unchanged.
There are 62 full-selection-pass models. See [named events and loop transfers](#named-event-loop-transfer) for independent checks and pinned comparisons.
Check and Nightly workflows on baseline 67321079 succeeded; Nightly artifacts remain uninspected and these new 36 cases are outside both runs. See [verification scope](nightly-results.en.md#latest-verified-checkpoint). Records below describe each addition’s checkpoint.

The 2026-11-06 package-query addition brings totals to **88 models / 3,244 cases / 131 chapter pairs**.
The [single run](../coverage/interaction-results/cross88-kirimasim-6f5c6984-pkgquery.json) on freshly fetched/built `6f5c69841228` records
**2,711 pass / 529 unsupported / four existing config failures**. All 36 additions parse/pass; preceding 3,208 inputs/statuses are unchanged.
There are 61 full-selection-pass models. See [package array queries and name lookup](#package-array-query-scope) for independent checks and pinned comparisons.
Verified Check covers 86 models on 9c39d865; verified formal Nightly covers 82 on 19cd790a. These new 36 cases have not run in either. Records below describe each addition’s checkpoint.

The 2026-11-06 program/task addition brings totals to **87 models / 3,208 cases / 130 chapter pairs**.
The [single run](../coverage/interaction-results/cross87-kirimasim-6f5c6984-progframe.json) on freshly fetched/built `6f5c69841228` records
**2,675 pass / 529 unsupported / four existing config failures**. All 36 additions parse/pass; preceding 3,172 inputs/statuses are unchanged.
There are 60 full-selection-pass models. See [program termination and automatic tasks](#program-task-frame-lifetime) for independent checks and pinned limitations.
Verified Check covers 86 models on 9c39d865, and verified formal Nightly covers 82 on 19cd790a; these new 36 cases have not run in either. Records below describe each addition’s checkpoint.

The 2026-11-05 formatted-scan addition brings totals to **86 models / 3,172 cases / 128 chapter pairs**.
The [single run](../coverage/interaction-results/cross86-kirimasim-6f5c6984-scansel.json) on freshly fetched/built `6f5c69841228` records
**2,639 pass / 529 unsupported / four existing config failures**. All 36 additions parse/pass; preceding 3,136 inputs/statuses are unchanged.
There are 59 full-selection-pass models. See [formatted scanning and partial writes](#formatted-scan-partial-write) for independent checks and pinned differences.
Verified Check covers 85 models on d98d6e4c, and verified formal Nightly covers 82 on 19cd790a; the new 36 cases have not run in either. Records below describe each addition’s checkpoint.

The 2026-11-05 typed-constant/generate addition brings totals to **85 models / 3,136 cases / 126 chapter pairs**.
The [single run](../coverage/interaction-results/cross85-kirimasim-92001039-genexpr.json) on freshly fetched/configured/built `92001039e896` records
**2,603 pass / 529 unsupported / four existing config failures**. All 36 additions parse/pass; preceding 3,100 inputs/statuses are unchanged.
There are 58 full-selection-pass models. See [typed constants and generate](#generated-constant-expression-shape) for independent checks and pinned comparisons.
Check on baseline 8df0dde9 passed pinned comparisons/static checks for 84 models; verified formal Nightly covers 82 models on 19cd790a.
The new 36 cases have not run in Check/Nightly. Records below describe each addition’s checkpoint.

The 2026-11-05 interface-query addition brings totals to **84 models / 3,100 cases / 124 chapter pairs**.
The [single run](../coverage/interaction-results/cross84-kirimasim-50a897de-ifquery.json) on freshly fetched/configured/built main `50a897dee62a` records
**2,567 pass / 529 unsupported / four existing config failures**. All 36 additions parse/pass; preceding 3,064 inputs/statuses are unchanged.
There are 57 full-selection-pass models. See [interface array queries](#interface-array-query-walk) for independent checks and pinned comparisons.
[Formal Check/Nightly on baseline `19cd790a`](nightly-results.en.md#latest-verified-checkpoint) confirm 82 models;
the combined 72 generated-loop/interface-query additions have not run in formal CI. Records below describe each addition’s checkpoint.

The 2026-11-05 generated-process addition gives **83 models / 3,064 cases / 121 chapter pairs**.
The [single full run](../coverage/interaction-results/cross83-kirimasim-50a897de-genloop.json) on freshly fetched/configured/built main `50a897dee62a`
records **2,531 pass / 529 unsupported / four existing config failures**. All 36 additions parse and pass; all preceding 3,028 inputs/statuses are unchanged.
There are 56 full-selection-pass models. See [generated-process loops](#generated-process-loop-transfer) for independent checks and fixed-release differences.
[Formal Check/Nightly on baseline `19cd790a`](nightly-results.en.md#latest-verified-checkpoint) confirm the preceding 82 models.
Formal CI has not run the new 36 cases. Dated addition records below describe their own verification points.

The 2026-11-05 class-selection addition gives **82 models, 3,028 selected cases and 119 chapter pairs**.
The [complete local run](../coverage/interaction-results/cross82-kirimasim-16222215-classsel.json) on upstream kirimasim `162222153c57`,
fetched/configured/built immediately beforehand, records **2,495 pass, 529 unsupported and four existing config failures**.
All 36 additions parse and pass; all preceding 2,992 input fingerprints and statuses are unchanged.
**55 models** pass their full selection. The new model maps 8×11 with all 36 cases and 8×12 with 24 if/case cases.
See [class conditional returns](#class-conditional-return) for design, independent checks and fixed-version observations.
The new cases have not run in formal Check/Nightly. The dated generated-subroutine record below describes the preceding addition.

The 2026-11-05 generated-subroutine addition gives **81 models, 2,992 selected cases and 117 chapter pairs**.
The [complete local run](../coverage/interaction-results/cross81-kirimasim-16222215-gensub.json), using upstream kirimasim `162222153c57`
fetched/configured/built immediately beforehand, records **2,459 pass, 529 unsupported and four config failures**.
All 36 additions parse and pass; all preceding 2,956 input fingerprints and statuses are unchanged.
**54 models** pass their full selection. The new model covers Chapters 13×27 and 7×27 and extends the existing 7×13 mapping.
See [generated subroutine binding](#generated-subroutine-binding) for scope, independent qualification and fixed-release differences.
The [Check on baseline `fd140002`](https://github.com/kurochan001/kirimasim-tests/actions/runs/41852637183) succeeded;
these 36 additions have not run in formal Check/Nightly.

The class/package addition on 2026-11-04 gives **80 models, 2,956 selected cases and 115 chapter pairs**.
The [single complete local run](../coverage/interaction-results/cross80-kirimasim-91139559-classimp-final.json) on upstream kirimasim `9113955914d8`,
fetched, configured and built immediately before execution, records **2,423 pass, 529 unsupported and four config failures**.
All 34 additions parse and pass. The preceding 2,922 input fingerprints and status categories are unchanged;
**53 models** pass their full selection. This is separate from the formal checkpoint below, which predates the additions.
See [class method/package lookup](#class-method-package-lookup) for design and qualification.

The [latest verified checkpoint](nightly-results.en.md#checkpoint-9926160a), checked on 2026-11-04 JST,
confirms successful Check and Nightly on suite `9926160a`.
That formal kirimasim `9113955914d8` run includes the preceding **2,922 selected cases in 79 models**:
**2,389 pass, 529 unsupported and four config failures**, with **52 full-selection-pass models** and **114 mapped chapter pairs**.
All selected input fingerprints and status categories agree with the saved cross79 snapshot below.
The [verification record](../coverage/interaction-qualification/formal-ci-9926160a-20261104.json) keeps this formal confirmation separate from the CSVs' local evidence.
Random thirteen-profile validation also has 96 valid passes in that Nightly; it does not increase these finite counts.

The following dated snapshots describe each addition and repair at the time it was executed.
References to uncommitted repairs apply to those historical builds, not the current upstream state.

At the package-observer addition on 2026-11-03, the selection had **79 models, 2,922 tests and 114 chapter pairs**.
The [complete saved run](../coverage/interaction-results/cross79-kirimasim-a682e19e-pkgwatch.json) records
**2,389 pass, 529 unsupported and four existing config failures** on kirimasim `a682e19e3238`, fetched, configured and built immediately before execution.
All 36 additions parse and pass; all preceding 2,886 input fingerprints and status categories are unchanged.
52 models pass their entire selection. No core change is introduced; this local run is separate from formal Nightly.
See [design, independent checks and limits](#package-change-observers).

At the package-NBA addition on 2026-11-03, the selection had **78 models, 2,886 tests and 112 chapter pairs**.
The [complete saved run](../coverage/interaction-results/cross78-kirimasim-7554bb47-pkgnba.json) records **2,353 pass, 529 unsupported and four existing config failures**
on upstream kirimasim `7554bb47`, fetched, configured and built immediately before execution. All 36 additions parse and pass;
all preceding 2,850 input fingerprints and status categories remain unchanged. 51 models pass their entire selection.
No core change is introduced; this local run is separate from formal Nightly. See [package NBA design and limits](#package-nba-capture).

At the enum/generate addition on 2026-11-03, the selection had **77 models, 2,850 tests and 109 chapter pairs**.
The [complete saved run](../coverage/interaction-results/cross77-kirimasim-7554bb47-genenum.json) records
**2,317 pass, 529 unsupported and four existing config failures** on kirimasim `7554bb47`, fetched, configured and built immediately before execution.
All 36 additions parse and pass; all preceding 2,814 input fingerprints and status categories are unchanged.
50 models pass their entire selection. No core change is introduced; this local run is separate from formal Nightly.
See [design, independent checks and limits for Chapters 6×27](#generated-enum-navigation).

At the deferred-argument addition on 2026-11-03, the selection had **76 models, 2,814 tests and 108 chapter pairs**.
The [full cross run](../coverage/interaction-results/cross76-kirimasim-7654825d-deferarg.json) records
**2,281 pass, 529 unsupported and four existing config failures**, using kirimasim `7654825d`
fetched and rebuilt immediately before execution with the preserved uncommitted repairs.
All 29 additions parse and pass. All preceding 2,785 input fingerprints and status categories remain unchanged;
49 models pass their entire selection. This addition changes no core code. The local result is separate
from formal Nightly and upstream releases. See [design, independent checks and limits for Chapters 13×16](#deferred-argument-capture).

Each run's version is recorded in linked JSON. Unless stated otherwise, added/total counts and check results in the model descriptions below record the state when that model was added. See the beginning of this overview and [Generated report](interaction-coverage.en.md) for current aggregates.

Approved label-cancellation implementation on 2026-11-03: the [full 2,785-case run](../coverage/interaction-results/cross75-kirimasim-7654825d-labelcancel-final.json) on upstream main `7654825d` plus uncommitted changes records **2,252 pass, 529 unsupported and four config failures**. All 31 deferred-disable cases pass; 48 models pass their full selection. Input fingerprints are unchanged; only the five label failures change to pass relative to the inside-repair snapshot. See [approved implementation and replays](cross-verification-followup.en.md).

Inside-repair integration on 2026-11-03: the [full 2,785-case run](../coverage/interaction-results/cross75-kirimasim-26a3e5a3-insidefix.json) on local main `26a3e5a3` plus uncommitted changes records **2,247 pass, 529 unsupported and nine fail**. Only the two inside failures change to pass; all input fingerprints are unchanged. Original failing snapshots remain separate from formal Nightly and upstream releases. See [triage, the 19-mechanism inventory and next chapter pairs](cross-verification-followup.en.md).

At the clocking-notification addition on 2026-11-03, the selection had **75 models, 2,785 tests and 107 chapter pairs**. The [full cross run](../coverage/interaction-results/cross75-kirimasim-f3ea0379.json) on kirimasim `f3ea0379a7e5`, fetched and built immediately before execution, records **2,245 pass, 529 unsupported and 11 existing failures**. All 24 new inputs parse: 12 pass and 12 `input #0` cases are unsupported. All preceding 2,761 input fingerprints and status categories are unchanged; 47 models pass their full selection. Both fixed Verilator seeds record 12 pass and 12 known results; fixed Icarus rejects all 24 builds. Chapter 14×15 is registered, leaving three E and one C candidate pairs. See [design, independent checks and limits](#clocking-named-event).

At the deferred-report disable addition on 2026-11-03, the selection had **74 models, 2,761 tests and 106 chapter pairs**. The [full cross run](../coverage/interaction-results/cross74-kirimasim-786c94bb.json) on kirimasim `786c94bbeafb`, fetched and built immediately before execution, records **2,233 pass, 517 unsupported and 11 failures**. All 31 new inputs parse; 26 pass and five label-cancellation cases fail. All preceding 2,730 fingerprints and status categories are unchanged. Five output differences are replayed with four passing controls and a separately identified empty-target-report control. 47 models pass their full selection. Both fixed Verilator seeds record 13 pass and 18 known results; fixed Icarus records 23 build rejections and eight output differences. Chapter 9×16 is registered, leaving three E and two C candidate pairs. See [design, independent checks and complete-output replays](#deferred-disable-reports).

At the container-sampling addition on the same day, the selection had **73 models, 2,730 tests and 105 chapter pairs**. The [full cross run](../coverage/interaction-results/cross73-kirimasim-786c94bb.json) on kirimasim `786c94bbeafb`, fetched and built immediately before execution, records **2,207 pass, 517 unsupported and six existing fail results**. All 33 new inputs parse; covergroups remain unsupported. All preceding 2,697 fingerprints and status categories are unchanged; 47 models pass their full selection. Both fixed Verilator seeds match all 33 cases; fixed Icarus rejects all 33 builds. Chapter 7×19 is registered, leaving four E and two C candidate pairs. See [design, independent checks and limits](#container-coverage-sampling).

At the program-assertion attempt addition on the same day, the selection had **72 models, 2,697 tests and 104 chapter pairs**. The [full cross run](../coverage/interaction-results/cross72-kirimasim-786c94bb.json) on kirimasim `786c94bbeafb`, fetched and built immediately before execution, records **2,207 pass, 484 unsupported and six existing fail results**. All 27 new inputs parse; concurrent assertions remain unsupported. All preceding 2,670 fingerprints and status categories are unchanged; 47 models pass their full selection. Both fixed Verilator seeds record 18 pass and nine known results; fixed Icarus rejects all 27 builds. Chapter 16×24 is registered, leaving four E and three C candidate pairs. See [design, independent checks and limits](#program-assertion-attempts).

At the checker-sampling addition on the same day, the selection had **71 models, 2,670 tests and 103 chapter pairs**. The [full cross run](../coverage/interaction-results/cross71-kirimasim-2ffb5ddd.json) on kirimasim `2ffb5dddca04`, fetched and built immediately before execution, records **2,207 pass, 457 unsupported and six existing fail results**. All 27 new inputs parse; execution lacks checker instances. All 2,643 preceding fingerprints and status categories are unchanged; 47 models still pass their full selection. Both fixed Verilator seeds record 25 pass and two known results; fixed Icarus rejects all 27 builds. Chapter 16×17 is registered, with Chapter 17×25 for seven interface cases, leaving five E and three C candidate pairs. See [design, independent model and limits](#checker-assertion-sampling).

At the SDF conditional-path addition on the same day, the selection had **70 models, 2,643 tests and 101 chapter pairs**. The [full cross run](../coverage/interaction-results/cross70-kirimasim-2ffb5ddd.json) on kirimasim `2ffb5dddca04`, fetched and built immediately before execution, records **2,207 pass, 430 unsupported and six existing fail results**. All 18 new inputs parse; execution reports unsupported conditional paths for 12 cases and unsupported $sdf_annotate for six. All 2,625 preceding fingerprints and status categories are unchanged; 47 models still pass their full selection. Fixed Icarus records three pass and 15 known results; both fixed Verilator seeds record 18 known results. Chapter 30×32 is registered, leaving six E candidate pairs. See [design, controls, faults and limits](#sdf-conditional-paths).

At the SV/DPI array-query addition on the same day, the selection had **69 models, 2,625 tests and 100 chapter pairs**. The [full cross run](../coverage/interaction-results/cross69-kirimasim-50f1f77b.json) on kirimasim `50f1f77b8c94`, fetched and built immediately before execution, records **2,207 pass, 412 unsupported and six existing fail results**. All 19 new inputs parse; the runner classifies C-backed tests as unsupported, so DPI execution is unconfirmed. All 2,606 preceding fingerprints and status categories are unchanged; 47 models still pass their full selection. Both fixed Verilator seeds record 11 pass and eight known results (two range differences and six build rejections). Chapter 20×35 is registered, leaving four C candidate pairs. See [design, controls and limits](#sv-dpi-array-queries).

At the automatic-event lifetime addition on the same day, the selection had **68 models, 2,606 tests and 99 chapter pairs**. The [full cross run](../coverage/interaction-results/cross68-kirimasim-50f1f77b.json) on kirimasim `50f1f77b8c94`, fetched and built immediately before execution, records **2,207 pass, 393 unsupported and six existing fail results**. All 18 new cases parse but event-value operations are unsupported on execution. All 2,588 preceding input fingerprints and outcomes are unchanged; 47 models still pass their full selection. Fixed Icarus/Verilator reject all 18 new builds. Chapter 7×15 is registered, leaving seven E candidate pairs. See [design, independent checks and limits](#aggregate-event-lifetime).

At the distribution-precedence addition on the same day, the selection had **67 models, 2,588 tests and 98 chapter pairs**. The [full cross run](../coverage/interaction-results/cross67-kirimasim-50f1f77b.json) on kirimasim `50f1f77b8c94`, fetched and built immediately before execution, records **2,207 pass, 375 unsupported and six existing fail results**. All 31 new cases parse but randomize is unsupported on execution. All 2,557 preceding input fingerprints and outcomes are unchanged; 47 models still pass their full selection. Both fixed Verilator seeds match 19 cases and differ on 12 containing all-zero weights. Chapter 11×18 is registered, reducing E candidates to eight pairs. See [design, auxiliary controls and limits](#distribution-expression-binding).

At the generate/default-disable addition on the previous day, the selection had **66 models, 2,557 tests and 97 chapter pairs**. The [full cross run](../coverage/interaction-results/cross66-kirimasim-2edfebbc.json) on kirimasim `2edfebbc6270`, fetched and built immediately before execution, records **2,207 pass, 344 unsupported and six existing fail results**. All 18 new cases parse, but concurrent assertions are unsupported on execution. All 2,539 preceding input fingerprints and outcomes are unchanged; 47 models still pass their full selection. Both fixed Verilator seeds match five cases and differ on 13. Chapter 16×27 is registered, reducing E candidates to nine pairs. See [design, controls and limits](#generate-default-disable-scopes).

At the reduction-constraint addition on the same day, the selection had **65 models and 2,539 tests**. The [full cross run](../coverage/interaction-results/cross65-kirimasim-80859f34.json) on kirimasim `80859f34f0aa`, built after verifying upstream main immediately before execution, records **2,207 pass, 326 unsupported and the existing 6 fail**. All 13 new cases parse successfully: 8 fixed-array cases encounter unsupported randomize and 5 dynamic-array cases encounter unsupported class-array operations. All 2,526 preceding input fingerprints and outcomes are unchanged. Chapter 7×18 is registered, giving 96 chapter pairs; 47 models pass their full selection. Both fixed Verilator 5.052 seeds have output differences on all 13 original cases; fixed Icarus Verilog 13.0 rejects all 13 builds. No fixed oracle is added. See [design and auxiliary-control scope](#array-reduction-constraints-and-retention).

At the associative-query addition on the same day, the selection had **64 models and 2,526 tests**. The [full cross run](../coverage/interaction-results/cross64-kirimasim-80859f34.json) on kirimasim `80859f34f0aa`, built after verifying upstream main immediately before execution, records **2,207 pass, 313 unsupported and the existing 6 fail**. All 18 new cases parse successfully but encounter unsupported typed associative-array variables. All 2,508 preceding input fingerprints and outcomes are unchanged. Chapter 7×20 is registered, giving 95 chapter pairs; 47 models pass their full selection. Both fixed Verilator 5.052 seeds have output differences on all 18 cases; fixed Icarus Verilog 13.0 rejects all 18 builds. No fixed oracle is added; standard-derived expectations are retained. See [design and scope](#associative-array-domains-and-allocation).

At the clocking-iff addition on the previous day, the selection had **63 models and 2,508 tests**. The [full cross run](../coverage/interaction-results/cross63-kirimasim-80859f34.json) on kirimasim `80859f34f0aa`, built after verifying upstream main immediately before execution, records **2,207 pass, 295 unsupported and the existing 6 fail**. All 12 new cases parse and type-check but encounter unsupported guarded clocking events. All 2,496 preceding input fingerprints and outcomes are unchanged. Chapter 9×14 is registered, giving 94 chapter pairs; 47 models pass their full selection. Both fixed Verilator 5.052 seeds pass 4 scalar-guard cases; 8 vector-guard cases have internal build errors. See [design and scope](#clocking-event-guards-and-held-samples).

At the preceding class/virtual-interface addition on the same day, the selection had **62 models and 2,496 tests**. The [full cross run](../coverage/interaction-results/cross62-kirimasim-80859f34.json) on kirimasim `80859f34f0aa`, built after verifying upstream main immediately before execution, records **2,207 pass, 283 unsupported and the existing 6 fail**. All 13 new cases parse and type-check but encounter unsupported class-held virtual-interface types. All 2,483 preceding input fingerprints are unchanged: 31 strength-format cases improve from unsupported to pass, while the other 2,452 outcomes are unchanged. Chapter 8×25 is registered, giving 93 chapter pairs; 47 models pass their full selection. Both fixed Verilator 5.052 seeds pass all 13 new cases. See [design and scope](#class-virtual-interface-rebinding).

At the preceding strength-format addition on the same day, the selection had **61 models and 2,483 tests**. The [full cross run](../coverage/interaction-results/cross61-kirimasim-f2d9a113.json) on kirimasim `f2d9a1136576`, built after verifying upstream main immediately before execution, records **2,176 pass, 301 unsupported and the existing 6 fail**. All 31 new cases encounter unsupported `%v`; all 2,452 preceding input fingerprints and outcomes are unchanged. All new cases parse and type-check. Chapter 21×28 is registered, giving 92 chapter pairs; 46 models pass their full selection. Fixed Icarus Verilog 13.0 passes all 31 new cases. See [design and scope](#resolved-strength-formatting).

At the preceding class-array addition on the same day, the selection had **60 models and 2,452 tests**. The [full cross run](../coverage/interaction-results/cross60-kirimasim-f2d9a113.json) on kirimasim `f2d9a1136576`, built after verifying upstream main immediately before execution, records **2,176 pass, 270 unsupported and the existing 6 fail**. Six new fixed-array cases pass; the 12 dynamic-array/queue cases encounter unsupported array-property operations; all 2,434 preceding input fingerprints and outcomes are unchanged. All 18 new cases parse and type-check. Chapter 7×8 is registered, giving 91 chapter pairs; 46 models pass their full selection. Both fixed Verilator 5.052 seeds pass all 18 new cases. See [design and scope](#class-array-storage-and-shared-elements).

At the preceding DPI open-array addition on the same day, the selection had **59 models and 2,434 tests**. The [full cross run](../coverage/interaction-results/cross59-kirimasim-f2d9a113.json) on kirimasim `f2d9a1136576`, built after verifying upstream main immediately before execution, records **2,170 pass, 258 unsupported and the existing 6 fail**. The runner marks all 30 new cases unsupported because it cannot load their C helper; all 2,404 preceding input fingerprints and outcomes are unchanged. Separate parsing accepts 24 cases and rejects 6 legal queue cases during argument type matching. Chapter 7×35 is registered, giving 90 chapter pairs; 46 models pass their full selection. Both fixed Verilator 5.052 seeds pass the 18 static-array cases; 12 dynamic-array/queue cases have known build failures. See [design and scope](#dpi-open-array-shape-and-copyback).

At the preceding clocking/assertion addition on the same day, the selection had **58 models and 2,404 tests**. The [full cross run](../coverage/interaction-results/cross58-kirimasim-1144b2ac.json) on kirimasim `1144b2acab1e`, built after verifying upstream main before execution, records **2,170 pass, 228 unsupported and the existing 6 fail**. The 18 new cases require unsupported concurrent assertions; all 2,386 preceding input fingerprints and outcomes are unchanged. Chapter 14×16 is now registered, giving 89 chapter pairs; 46 models pass their full selection. Both fixed Verilator 5.052 seeds pass all 18 new cases. See [design and scope](#clocking-inputs-and-assertion-clocks).

At the constraint-inheritance addition on the same day, the selection had **57 models and 2,386 tests**. The [full cross run](../coverage/interaction-results/cross57-kirimasim-1144b2ac.json) on kirimasim `1144b2acab1e`, built after verifying upstream main before execution, records **2,170 pass, 210 unsupported and the existing 6 fail**. The 13 new cases require unsupported randomize; all 2,373 preceding input fingerprints and outcomes are unchanged. Chapter 8×18 is now registered, bringing the total to 88 chapter pairs; 46 models pass their full selection. All 13 new cases match fixed Verilator 5.052 at both seeds. See [design and scope](#constraint-inheritance-and-failure-retention).

At the DPI/NBA addition on the same day, the selection had **56 models and 2,373 tests**. The [full cross run](../coverage/interaction-results/cross56-kirimasim-1144b2ac.json) on kirimasim `1144b2acab1e`, built from upstream main verified immediately before execution, records **2,170 pass, 197 unsupported and the existing 6 fail**. The 18 new cases need unsupported C loading; all 2,355 preceding input fingerprints and outcomes are unchanged. Chapter 10×35 is now registered, bringing the total to 87 chapter pairs; 46 models pass their full selection. Fixed Verilator 5.052 matches 14 new cases at both seeds; four 65-bit output/inout copyback cases stop on internal build errors. See [design and scope](#dpi-copyback-and-nba-capture).

At the event-rebinding addition on the same day, there were 55 models and 2,355 tests. All 27 new cases had unsupported event-value operations on kirimasim `ddf48e2b0436` built after checking upstream main immediately before execution. [Saved runs of all crosses](../coverage/interaction-results/cross55-kirimasim-ddf48e2b.json) is 2,170 pass, 179 unsupported, and existing 6 fail. Input hashes and result categories for the preceding 2,328 cases are unchanged. Registered Clause 6 × Clause 15, bringing the total to 86 chapter pairs and 46 models with their full selection PASS. See [Event-rebinding design and verification scope](#イベント変数の再結合と登録済み待機の保持).

At the time of the mailbox addition on the same day, there were 54 model and 2,328 items. All 36 new cases had unsupported mailbox types on kirimasim `d0865eb65999` built after checking upstream main immediately before execution. [Saved runs of all crosses](../coverage/interaction-results/cross54-kirimasim-d0865eb6.json) is 2,170 pass, 152 unsupported, and existing 6 fail. Input hashes and result categories for the preceding 2,292 cases are unchanged. Registered Clause 8 × Clause 15, bringing the total to 85 chapter pairs and 46 models with their full selection PASS. See [mailbox design, fixed-version verification, and limits](#mailboxのclassハンドルと別名経由の更新).

At the time of interface import added on the same day, there were 53 model and 2,292 item. On kirimasim `4fb5f6b1aec8` built for the upstream update before full regression, all 36 new cases returned PASS. [Saved runs of all crosses](../coverage/interaction-results/cross53-kirimasim-4fb5f6b1.json) is 2,170 pass, 116 unsupported, and existing 6 fail. Input hashes and result classifications for the existing 2,256 cases are unchanged. Registered Clause 25 × Clause 26 and Clause 6 × Clause 26, bringing the total to 84 chapter pairs and 46 models with their full selection PASS. See [Interface-header import/conversion design and verification](#interfaceヘッダのimportとpackage関数の型変換).

The UDP was added on the same day in succession to the 52 model and 2,256 item. After reconfiguring and building kirimasim `3550d77474f1` for an upstream update detected immediately before full regression, all 36 new cases returned PASS. [Saved runs of all crosses](../coverage/interaction-results/cross52-kirimasim-3550d774.json) is 2,134 pass, 116 unsupported, and existing 6 fail. Input hashes for the existing 2,220 cases are unchanged. Implementation updates improved 18 existing class-method cases from unsupported to pass. Other result classifications are unchanged. Registered Clause 27 × Clause 29 and Clause 6 × Clause 29, bringing the total to 82 chapter pairs and 45 models with their full selection PASS. See [Design and verification of sequential UDP generation, state retention, and input conversion](#generateで生成した逐次udpの状態と入力変換).

The UDP added on the same day was a 51 model and 2,220 item. All 25 new cases returned PASS on kirimasim `4b58e29f8c94`, whose build version was checked against upstream main immediately before execution. [Saved runs of all crosses](../coverage/interaction-results/cross51-kirimasim-4b58e29f.json) is 2,080 pass, 134 unsupported, and existing 6 fail. Input hashes and result classifications for the existing 2,195 cases are unchanged. Registered Clause 28 × Clause 29, bringing the total to 80 chapter pairs and 44 models with their full selection PASS. See [Design and verification of array connections and strengths in UDP](#udpの配列接続と駆動強度の解決).

The configuration was added on the same day with the 50 model and 2,195 item. The 41 new cases had 37 pass and 4 fail on kirimasim `4b58e29f8c94`, whose build version was checked against upstream main immediately before execution. [Saved runs of all crosses](../coverage/interaction-results/cross50-kirimasim-4b58e29f.json) is 2,055 pass, 134 unsupported, and 6 fail (existing 2 and new 4). Input hashes and result classifications for the existing 2,154 cases are unchanged. Registered Clause 23 × Clause 33 and Clause 27 × Clause 33, bringing the total to 79 chapter pairs and 43 models with their full selection PASS. See [config/generate design and whole-reset differences](#configのパラメータ設定とgenerateの形状).

The program Reactive added on the same day was 49 model and 2,154 item. All 36 new cases returned PASS on kirimasim `4b58e29f8c94`, whose build version was checked against upstream main immediately before execution. [Saved runs of all crosses](../coverage/interaction-results/cross49-kirimasim-4b58e29f.json) is 2,018 pass, 134 unsupported, and existing 2 fail. Input hashes and result classifications for the existing 2,118 cases are unchanged. Registered Clause 4 × Clause 24, Clause 10 × Clause 24, and Clause 6 × Clause 24, bringing the total to 77 chapter pairs and 43 models with their full selection PASS. See [Program event-region design and verification](#programのイベント領域と非ブロッキング代入).

The generate interface added on the same day was 48 model and 2,118 item. All 36 new cases returned PASS on kirimasim `4b58e29f8c94`, whose build version was checked against upstream main immediately before execution. [Saved runs of all crosses](../coverage/interaction-results/cross48-kirimasim-4b58e29f.json) is 1,982 pass, 134 unsupported, and existing 2 fail. Input hashes and result classifications for the existing 2,082 cases are unchanged. Registered Clause 25 × Clause 27 and Clause 6 × Clause 25, bringing the total to 74 chapter pairs and 42 models with their full selection PASS. See [generate/interface design and verification](#generateで生成したinterfaceとmodport接続).

The previous day, when default_nettype was added, there were 47 models and 2,082 items. All 40 new cases returned PASS on kirimasim `4b58e29f8c94`, whose build version was checked against upstream main immediately before execution. [Saved runs of all crosses](../coverage/interaction-results/cross47-kirimasim-4b58e29f.json) is 1,946 pass, 134 unsupported, and existing 2 fail. Input hashes and result classifications for the existing 2,042 cases are unchanged. Registered Clause 6 × Clause 22 and Clause 22 × Clause 23, bringing the total to 72 chapter pairs and 41 models with their full selection PASS. See [Net-type and port-declaration design and verification](#default_nettypeとポートnetの解決).

The program was added at the same day when the 46 model and 2,042 item were finished. All 18 new cases returned PASS on kirimasim `4b58e29f8c94`, whose build version was checked against upstream main immediately before execution. [Saved runs of all crosses](../coverage/interaction-results/cross46-kirimasim-4b58e29f.json) is 1,906 pass, 134 unsupported, and existing 2 fail. Input hashes and result classifications for the existing 2,024 cases are unchanged. Registered Clause 9 × Clause 24 and Clause 15 × Clause 24, bringing the total to 70 chapter pairs and 40 models with their full selection PASS. See [Program-termination design and verification](#program終了と子孫プロセスの取消し).

The memory file added on the same day was 45 model, 2,024 item. All 36 new cases returned PASS on kirimasim `4b58e29f8c94`, whose build version was checked against upstream main immediately before execution. [Saved runs of all crosses](../coverage/interaction-results/cross45-kirimasim-4b58e29f.json) is 1,888 pass, 134 unsupported, and existing 2 fail. Input hashes and result classifications for the existing 1,988 cases are unchanged. Registered Clause 6 × Clause 21, bringing the total to 68 chapter pairs and 39 models with their full selection PASS. See [Memory-file design and verification](#型と範囲を組み合わせたメモリファイル入出力).

The package import added on the same day was 44 model and 1,988 item. All 39 new cases returned PASS on kirimasim `4b58e29f8c94`, whose build version was checked against upstream main immediately before execution. [Saved runs of all crosses](../coverage/interaction-results/cross44-kirimasim-4b58e29f.json) is 1,852 pass, 134 unsupported, and existing 2 fail. Input hashes and result classifications for the existing 1,949 cases are unchanged. Registered Clause 23 × Clause 26, bringing the total to 67 chapter pairs and 38 models with their full selection PASS. See [Import and port-connection design and verification](#packageのimportとワイルドカードポート接続).

The delay added on the same day was 43 model and 1,949 case. All 63 new cases returned PASS on kirimasim `4b58e29f8c94`, whose build version was checked against upstream main immediately before execution. [Saved runs of all crosses](../coverage/interaction-results/cross43-kirimasim-4b58e29f.json) is 1,813 pass, 134 unsupported, and existing 2 fail. Input hashes and result classifications for the existing 1,886 cases are unchanged. Newly registered Clause 10 × Clause 28 and Clause 6 × Clause 28, bringing the total to 66 chapter pairs and 37 models with their full selection PASS. See [Continuous-assignment delay design and verification](#連続代入の遅延と短パルスの除去).

The event arguments added on the same day were 42 model and 1,886 item. All 13 new cases returned PASS on kirimasim `4b58e29f8c94`, whose build version was checked against upstream main immediately before execution. [Saved runs of all crosses](../coverage/interaction-results/cross42-kirimasim-4b58e29f.json) is 1,750 pass, 134 unsupported, and existing 2 fail. Input hashes and result classifications for the existing 1,873 cases are unchanged. Newly registered Clause 4/13/25/26 × Clause 15, bringing the total to 64 chapter pairs and 36 models with their full selection PASS. See [Event-argument design and verification](#イベント引数によるスコープ間の同期).

The default arguments added on the same day were 41 model, 1,873 item. All 36 new cases returned PASS on kirimasim `4b58e29f8c94`, whose build version was checked against upstream main immediately before execution. [Saved runs of all crosses](../coverage/interaction-results/cross41-kirimasim-4b58e29f.json) is 1,737 pass, 134 unsupported, and existing 2 fail. Input hashes and result classifications for the existing 1,837 cases are unchanged. Registered Clause 13 × Clause 23 and Clause 23 × Clause 25, bringing the total to 60 chapter pairs and 35 models with their full selection PASS. See [Default-argument design and verification](#デフォルト引数と階層呼出しのスコープ).

The same day, the 40 model and 1,837 item were added to the generate. All 36 new cases returned PASS on kirimasim `4b58e29f8c94`, whose build version was checked against upstream main immediately before execution. [Saved runs of all crosses](../coverage/interaction-results/cross40-kirimasim-4b58e29f.json) is 1,701 pass, 134 unsupported, and existing 2 fail. Input hashes and result classifications for the existing 1,801 cases are unchanged. Registered Clause 10/23/26 × Clause 27, bringing the total to 58 chapter pairs and 34 models with their full selection PASS. See [generate design and verification](#generate階層でのpackageと局所宣言の名前探索).

The implicit process added on the same day was a 39 model, 1,801 item. All 36 new cases returned PASS on kirimasim `95eefebeb952`, whose build version was checked against upstream main immediately before execution. [Saved runs of all crosses](../coverage/interaction-results/cross39-kirimasim-95eefebe.json) is 1,665 pass, 134 unsupported, and existing 2 fail. Input hashes and result classifications for the existing 1,765 cases are unchanged. Registered Clause 9 × Clause 25 and Clause 13 × Clause 25, bringing the total to 55 chapter pairs and 33 models with their full selection PASS. See [Implicit-process design and verification](#暗黙の感度リストとラッチ保持).

The loop assignment was added on the same day for the 38 model and 1,765 case. All 36 new cases returned PASS on kirimasim `95eefebeb952`, whose build version was checked against upstream main immediately before execution. [Saved runs of all crosses](../coverage/interaction-results/cross38-kirimasim-95eefebe.json) is 1,629 pass, 134 unsupported, and existing 2 fail. Input hashes and result classifications for the existing 1,729 cases are unchanged. Registered Clause 10 × Clause 12 and Clause 10 × Clause 25, bringing the total to 53 chapter pairs and 32 models with their full selection PASS. See [Loop-assignment design and verification](#ループ代入の更新順序とインスタンスの独立性).

The return function was added on the same day for the 37 model and 1,729 item. All 36 new cases returned PASS on kirimasim `3a31b060c158`, whose build version was checked against upstream main immediately before execution. [Saved runs of all crosses](../coverage/interaction-results/cross37-kirimasim-3a31b060.json) is 1,593 pass, 134 unsupported, and existing 2 fail. Input hashes and result classifications for the existing 1,693 cases are unchanged. Registered Clause 12 × Clause 13 and Clause 13 × Clause 26, bringing the total to 51 chapter pairs and 31 models with their full selection PASS. See [Function-return design and verification](#ループからの関数returnと状態の共有範囲).

The class method added on the same day was 36 model and 1,693 item. The 36 new cases had unsupported class types on kirimasim `3a31b060c158`, whose build version was checked against upstream main immediately before execution. [Saved runs of all crosses](../coverage/interaction-results/cross36-kirimasim-3a31b060.json) is 1,557 pass, 134 unsupported, and existing 2 fail. Input hashes and result classifications for the existing 1,657 cases are unchanged. Registered Clause 6 × Clause 8 and Clause 8 × Clause 13, bringing the total to 49 registered chapter pairs. See [Class-method design and verification](#クラスメソッドの呼出し先と再帰引数).

The same day, the assignment container wait was added to the 35 model and 1,657 item. All 36 container-wait cases agreed on kirimasim `3a31b060c158` after fetching upstream main, reconfiguring/building, and verifying the version immediately before execution. The 36 assertion cases lack support for concurrent assertions themselves. [Saved runs of all crosses](../coverage/interaction-results/cross35-kirimasim-3a31b060.json) is 1,557 pass, 98 unsupported, and 2 fail, and the input hash and result classification of the conventional 1,585 is the same. All 214 container-wait pairs, 88 combinations of 3 factors, and 6 mandatory cases were satisfied by successful runs. Retain the planned 225 assertion pairs, 96 combinations of 3 factors, and 7 mandatory cases without reducing the denominator for unsupported cases. See [Assertion design and comparison](#アサーションのサンプル値とactionのライブ値) and [Container-wait design and verification](#コンテナ変更とwaitの起床).

The clock input added on the same day was 33 model and 1,585 item. The 36 new `clocking_input_sampling` cases had 24 pass, 12 unsupported, and 0 fail on kirimasim `55ce80b9d5bc` after fetching upstream main, reconfiguring/building, and verifying the version immediately before execution. [Saved runs of all crosses](../coverage/interaction-results/cross33-kirimasim-55ce80b9.json) is 1,521 pass, 62 unsupported, and 2 fail. Input hashes and result classifications for the existing 1,549 cases are unchanged. The new model plans 165 pairs, 72 combinations of 3 factors, and 5 mandatory cases, but execution satisfaction is not achieved. Do not exclude unsupported input skew #0 or virtual-modport types from the legal plan. See [Design, fixed-version checks, and fault-injection verification](#クロッキング入力のサンプリングと参照経路).

The arguments were added on the same day, and the result was 32 model and 1,549 item. All 36 new `argument_binding_index` cases agreed on kirimasim `a08e3489b8ab`, whose build version was checked against upstream main immediately before execution. [Saved runs of all crosses](../coverage/interaction-results/cross32-kirimasim-a08e3489.json) is 1,497 pass, 50 unsupported, and 2 fail. Input fingerprints and result classifications for the existing 1,513 cases are unchanged. All 162 pairs, 63 combinations of 3 factors, and 5 mandatory cases of the new model were satisfied by successful runs. The 3 models with remaining unsupported cases and disagreements are separate from these additions. See also [Argument-binding design and verification records](#引数の結合と呼出し後の添字変更).

The queue reference added on the same day was 31 model and 1,513 item. All 60 new `queue_element_reference` cases agreed on kirimasim `29ad73153518`, whose build version was checked against upstream main immediately before execution. [Saved runs of all crosses](../coverage/interaction-results/cross31-kirimasim-29ad7315.json) is 1,461 pass, 50 unsupported, and 2 fail. Input fingerprints and result classifications for the existing 1,453 cases are unchanged. All 257 pairs, 96 combinations of 3 factors, and 5 mandatory cases of the new model were satisfied by successful runs, but 2 inside/case inside disagreements and 50 unsupported cases in the 3 model remain. See also [Queue-reference design and verification records](#キュー要素への参照と要素の寿命).

The first addition of the same day was 30 model and 1,453 item. All 27 cases of new `event_or_iff` agreed on kirimasim `17b7192b4f05`, whose build version was checked against upstream main immediately before execution. [Saved runs of all crosses](../coverage/interaction-results/cross30-kirimasim-17b7192b.json) is 1,401 pass, 50 unsupported, and 2 fail. Input fingerprints for the existing 1,426 cases are unchanged. Compared with the previous `f303beca`, 6 array-slice cases changed from unsupported to pass; 2 disagreements concerning signed arrays in inside and case inside remain. All 104 pairs, 59 combinations of 3 factors, and 4 mandatory cases targeted by the 27 new cases were satisfied by successful runs, but this does not establish success for all 30 models. See also [Model design and verification records](#イベントorと項ごとのiff条件).

The following records 2026-10-30.

Recorded in 2026-10-30, from suite `af21eff0` onwards. Each entry identifies the target version. [Automatic report](interaction-coverage.en.md) is authoritative for aggregates checked against the current plan and each run's input hashes. Do not interpret this section's figures as the support status of simulator versions updated later.

- There are 27 registered models and 1,346 short-run target cases. This scope differs from the full suite's 9,095 cases.
- For [Saved runs](../coverage/interaction-results/cross27-kirimasim-latest.json), 1,313 cases agreed, 32 were unsupported, and 1 disagreed on kirimasim `74fb2340925a` built after checking upstream main immediately before execution.
- All 40 compound-shift-assignment cases agree. The 46 set-membership cases have 19 agreements, 26 unsupported cases, and 1 disagreements. Planned target coverage and execution satisfaction are separate for these 2 models.
- Successful set-membership runs verified 208 of 305 pairs and 84 of 174 combinations of 3 factors. Of 5 mandatory cases, 1 agree, 3 are unsupported, and 1 disagree; whole-model satisfaction is not achieved.
- The 32 unsupported cases comprise 6 existing array-slice assignment cases and 26 set-membership cases reading dynamic arrays / queues. The 1 disagreements occur when fixed-array elements and individually listed values give different results with differing widths and signedness. [Minimal examples, controls, and build evidence](../coverage/interaction-qualification/20261030-inside.json) is saved.
- On the same day, also ran all 1,346 cases on kirimasim `fb79248e46f6` rebuilt after checking upstream main immediately before execution, retaining them as [Separate saved run](../coverage/interaction-results/cross27-kirimasim-fb79248e.json). 1,313 cases agreed, 32 were unsupported, and 1 disagreed; no case changed status. The input hashes also match.
- The 28 models and 1,392 cases including the range-specification model were [Saved runs](../coverage/interaction-results/cross28-kirimasim-f303beca.json) with kirimasim `f303becad9ca`, built after checking upstream main immediately before execution, producing 1,343 matches, 48 unsupported cases, and 1 mismatches. The existing 1,346 case statuses match the `fb79248e46f6` run. The 46 range cases comprise 30 agreements and 16 unsupported cases, all involving tolerance ranges (`tolerance range (not implemented yet)`). Agreement verified 252 of 303 pairs, 117 of 178 combinations of 3 factors, and 4 of 6 mandatory cases; this model remains unsatisfied.
- The 29 models and 1,426 cases including the case-inside model were [Saved runs](../coverage/interaction-results/cross29-kirimasim-f303beca.json) with the same kirimasim `f303becad9ca`, producing 1,368 matches, 56 unsupported cases, and 2 mismatches. The existing 1,392 case statuses match the 28-model run. The 34 case inside cases comprise 25 agreeing, 8 unsupported, and 1 disagreeing cases. Unsupported cases have function-call items (`set member with side effects (not implemented yet)`); disagreements have signed fixed-array items. Matching results confirm 274 of 315 pairs, 115 of 154 3-factor combinations, and 3 of 7 mandatory cases.

See also [Configuration of Check](../.github/workflows/check.yml) and [Execution history](https://github.com/kurochan001/kirimasim-tests/actions/workflows/check.yml). Success of Check means that checks such as the fixed-oracle cases and consistency of generated artifacts and ledgers passed; it does not establish that all kirimasim cases pass or that all crosses are satisfied. For each saved run, `--require-pass` checks successful satisfaction of all target combinations and mandatory cases in the specified models. Set-membership satisfaction is not achieved in this run.

These are saved runs of selected crosses, separate from a full-suite run of Nightly. When comparing with Nightly, check the commit of the target suite, the version of the simulator, and the scope of execution. Differences in the fixed reference versions of Icarus and Verilator are summarized in [Simulator differences](simulator-differences.md) and the model-specific verification records at the end.

<a id="導入済みのモデル"></a>

## Implemented models

<a id="スケジューリングと値の観測"></a>

### Scheduling and value observation

`scheduling_visibility` uses an existing `scheduling` generator. Use write method, read method, execution location, and delay as factors; select 51 short-run cases from 325 combinations satisfying the constraints. Cover all 126 factor pairs plus 51 combinations of write method × read method × delay.

Write/observation times and event regions in each case correspond to the existing generator's reference model. Use existing `allowed()` exclusions where the standard leaves observations unspecified or similar conditions apply. These constraints do not reduce the model denominator because of unsupported tool features. Retain the existing 325 cases and expected values, continuing to run them in ordinary full runs.

<a id="ノンブロッキング代入の値と代入先の確定"></a>

### Determining nonblocking-assignment values and destinations

`nba_capture` comprises 36 new generated tests combining the following factors.

- Widths: 1, 32, 33, 64, 65, and 129 bits.
- State type: 2-state `bit`, 4-state `logic`.
- Input value: known values with the highest/lowest bit set, X, Z.
- Destination: scalar, fixed-size unpacked array.
- Array index direction: inapplicable, ascending `[2:3]`, descending `[3:2]`.
- Assignment location: initial, automatic task.
- Update timing: no delay, intra-assignment delay `#1`.

Index direction is inapplicable to scalars; choose ascending/descending for arrays. Use 432 constraint-satisfying candidates from 864 Cartesian-product possibilities; 36 cases cover all 162 factor pairs, 36 width × state × input-value combinations, and 8 destination × location × update-timing combinations. Also retain the following 3 cases even if other cases can cover their factor combinations.

- 65 bits, logic, X, descending arrays, automatic tasks, and delayed NBA.
- 129 bits, logic, Z, ascending arrays, automatic tasks, and delayed NBA.
- 129 bits, bit, X, descending arrays, automatic tasks, and NBA with no delay.

Change the original value and index immediately after scheduling NBA. Display values immediately after assignment, the changed stimulus, the Active region at time 1, and the result at time 2; use expected output to check that the original value and assignment target are fixed, adjacent elements remain unchanged, and Active-region reads precede delayed NBA. In cases selecting a task, it returns before the update occurs. The destination has static lifetime. NBA targeting automatic variables or dynamic-array elements is out of scope.

Calculate expected values in Python based on 10.4.2, 9.4.5, 4.4.2.2, 4.4.2.4, 6.11.2, 13.5.1, and 7.4.1 in IEEE 1800-2023. Cases containing X/Z carry `:fourstate: yes`, including cases that check conversion to bit. The presence of a feature name in a test alone does not establish cross satisfaction.

<a id="演算の幅符号代入コンテキスト"></a>

### Operation width, signedness, and assignment context

`expression_context` crosses left-operand width (1, 32, 33, 64, 65, 129), right-operand and destination widths (1 bits narrower than the left, equal, 1 bits wider), each operand's signedness, and addition/subtraction/multiplication. Select 51 cases from 588 possibilities after excluding combinations yielding width 0. Cover all 143 factor pairs plus 51 combinations of width × destination width × operator, 12 combinations of left sign × right sign × operator.

Provide 4 input combinations per 1 cases to check negative values, the top bit, carries, and truncation. Under 11.6.1, 11.8.1, and 11.8.2, determine evaluation width including the destination before operating, and sign-extend only when both operands are signed. Require signed 129-bit multiplication, mixed-sign addition near 65 bits, and subtraction near 33 bits. Division, shifts, and context blocking by self-determined expressions are outside this model's scope.

<a id="パック配列の添字方向と部分選択への書き込み"></a>

### Packed-array index direction and writes to part-selects

`packed_part_select` crosses width (1, 32, 33, 64, 65, 129), ascending/descending indices, indexed part-select `+:`/`-:`, selection width (1 bit or half the vector), position (low end, high end, interior), bit/logic, and known/X/Z values. Select 36 cases from 744 combinations of width-0 selections, excluding combinations where an edge and an interior position coincide. Cover all 162 factor pairs plus 36 combinations of width × state × input value, 12 combinations of index direction × selection direction × selection position.

Use index lower bound 4 to detect implementations assuming a 0-based range. Read/write using a runtime base index and constant select width; display all bits and the selected range before/after writing. Use the inverse of the original selected range for known values so every write causes a change. Also check preservation of unselected bits against expected values. Under 11.5.1, 7.4.1, and 6.11.2, calculate expected values in bit-significance order independently of index syntax. Out-of-range accesses are outside this work's scope. Make the following mandatory cases: writing Z through a 65-bit ascending `-:`, writing X at an interior position in a 129-bit value, and converting X to bit at the upper end of a 33-bit value.

<a id="条件演算子のxz結合と代入先への変換"></a>

### Conditional-operator X/Z merging and destination conversion

`conditional_merge` crosses width (1, 33, 65, 129), the signedness of each branch, condition (0, 1, X, Z), branch-value patterns (equal known values, inverted known values, equal X/Z, different X/Z), target width (1 bit narrower, equal, 1 bit wider), and bit/logic. Select 32 cases from 1,408 possibilities after excluding combinations yielding width 0. Cover all 185 factor pairs plus 32 combinations of width × condition × state, 32 combinations of condition × branch pattern × state, 12 combinations of left-branch sign × right-branch sign × destination width.

Expected values are based on 11.4.11, 11.6.1, 11.8.1, 11.8.2, and 6.11.2. A known condition selects one branch; an X/Z condition merges the extended branches bit by bit using Table 11-20, followed by truncation and conversion to bit. Z/Z at the same position also becomes X under an ambiguous condition. Require cases for merging identical X/Z branches at 129 bits, mixed-sign extension at 65 bits, and truncation from 33 bits with 2-state conversion. Both branches have the same original width; nonintegral types and side-effecting branch expressions are out of scope.

<a id="シフト量符号演算幅"></a>

### Shift amount, signedness, and operation width

`shift_context` crosses source width (1, 32, 33, 64, 65, 129), signedness, `<<`/`>>`/`<<<`/`>>>`, shift amount (0, 1, width−1, width, width+1, X, Z), known/X/Z values, target width (1 bit narrower, equal, 1 bit wider), and bit/logic. After excluding targets of width 0 and representative values that become numerically identical at width 1, 56 cases are selected from 5,520 combinations. Cover all 298 factor pairs plus 56 combinations of operator × shift amount × signedness, 36 combinations of width × input value × state.

Under 11.4.10, 11.6.1, 11.8.1, 11.8.2, and 6.11.2, first extend the left operand to include the destination width, then shift. Verify that even a shift equal to the original width leaves a result when the evaluation width is 1 bits wider. The right operand does not change the result's signedness. Signed `>>>` also replicates X/Z sign bits; if the shift amount contains X/Z, make the result X before applying the final 2-state conversion. Require cases for a Z sign bit at 65 bits, truncation at 129 bits, logical right shift from 33 bits to a wider destination, and a shift beyond the width at 64 bits.

<a id="キャストと後続演算の型変換"></a>

### Casts and type conversion in subsequent operations

`cast_pipeline` crosses source width (1, 32, 33, 64, 65, 129), signedness, known/X/Z values, cast kind (size, signed, unsigned, bit type, logic type), cast width (1 bit narrower, equal, 1 bit wider), subsequent operation (direct assignment or addition of 1), and target bit/logic. Signing casts retain the original width, so only equal-width cases are allowed; after also excluding width 0, 32 cases are selected from 1,512 legal combinations. Cover all 214 factor pairs plus 30 combinations of cast × input value × subsequent operation, 24 combinations of width × signedness × state, 22 combinations of cast × cast width × signedness.

Under 6.24.1, 6.11.2, 11.6.1, 11.8.1, and 11.8.2, determine the cast's intermediate value first, extend it to the original width-+2 destination, then perform subsequent operations. Use `2'sb01` for the addition's 1, preserving the signed cast's signedness. Distinguishes a bit-type cast converting X/Z to 0 before the operation from a logic-type cast retaining X/Z and making the addition result X. Display the original value, value immediately after the cast, and final result separately. Require conversion to a 129-bit bit type followed by addition, sign extension of 65-bit Z, and truncation from 33 bits followed by addition. Restrict cast target types to unsigned packed types; real, enum, and bit-stream casts are out of scope.

<a id="タスク引数のコピー渡しと参照渡し"></a>

### Task arguments passed by copy and by reference

`task_argument_visibility` crosses width (1, 32, 33, 64, 65, 129), bit/logic, known/X/Z values, argument direction (input, output, inout, ref), actual argument (scalar or fixed-array element), and return timing (without delay or after `#1`). Select 36 cases from 576 possibilities. Cover all 144 factor pairs plus 36 combinations of width × state × input value, 16 combinations of argument direction × actual-argument destination × return timing.

Under 13.5, 13.5.1, and 13.5.2, observe actual arguments inside the task, immediately before return, and after return. Use expected values to verify that input writes do not propagate back to the actual argument, output/inout copies out on return, and ref changes the actual argument immediately. Do not depend on uninitialized output values. Use array `[2:3]` and also check that adjacent elements remain unchanged. Make the following mandatory cases: ref and Z on a 129-bit array element, inout and X at 65 bits, and conversion from a 33-bit output to bit. Use automatic tasks in every case and the same typedef for matching ref types. Changes to actual-argument indices during calls, NBA, and other concurrent writes are out of scope.

<a id="パック構造体の配置メンバ更新符号拡張"></a>

### Packed-structure layout, member updates, and sign extension

`packed_structure` crosses payload width (1, 32, 33, 64, 65, 129), member order, signedness of the entire structure and of its payload, bit/logic, known/X/Z values, member versus whole-structure writes, and blocking assignment versus NBA. Select 36 cases from 1,152 possibilities. Cover all 186 factor pairs plus 36 combinations of width × state × input value, 8 combinations of order × access × update method, 8 combinations of whole-value sign × member sign × order.

Under 7.2.1, 10.4.1, 10.4.2, 11.8.1, 11.8.2, and 6.11.2, place the first member at the high end and check all payload bits and fixed tag `101` against expected values. Change the original value immediately after writing and observe with `#1`, also verifying that NBA captured the value. Assign the payload member expression and whole structure to separate wider variables, verifying extension according to each expression's signedness. Require 129-bit Z with whole-object NBA, 65-bit X with member NBA, and 33-bit bit member updates. Use uniformly 2-state or 4-state members; mixing 2-state and 4-state members and unpacked structures are out of scope.

<a id="caseの幅符号ワイルドカード優先順位"></a>

### case widths, signedness, wildcards, and priority

`case_matching` crosses selector width (1, 32, 33, 64, 65, 129), selector and item signedness, item width (1 bit narrower, equal, 1 bit wider), case/casez/casex, known/X/Z values, and item patterns (equal, low-bit inversion, high Z, low X). Select 36 cases from 2,448 possibilities excluding width 0. Cover all 220 factor pairs plus 36 combinations of kind × input value × item pattern, 34 combinations of width × item width × selector sign, 12 combinations of selector sign × item sign × kind.

Under 12.5 and 12.5.1, match the widest expression's width and sign-extend only when every expression is signed. case matches exactly, including X/Z; casez masks Z on both sides, and casex masks X/Z on both sides. For each of 1 cases, evaluate 2 runs: one with 2 equal-valued items and one with item 2 reset to the reference value; check first-match selection and branching to fallback/default. Require 129-bit casez, 65-bit mixed signedness, and 33-bit casex cases. Both items have the same type and width; unique/priority qualifiers, inside, matches, and expression side effects are out of scope.

<a id="モジュールのポート接続と幅変換"></a>

### Module port connections and width conversion

`port_connection` crosses original widths (1, 32, 33, 64, 65, 129), input/output, source signedness, destination widths (1 bit(s) narrower, equal, 1 bit(s) wider), known values/X/Z, sample-variable bit / logic, named/positional connections, and ANSI / non-ANSI declarations. Select 36 cases from 1,632 possibilities excluding width 0. Cover all 204 factor pairs plus 36 combinations of width × input value × sample type, 12 combinations of connection direction × signedness × connection width, 8 combinations of connection direction × connection form × declaration form.

Under 23.3.3, 23.3.3.3, 23.3.3.8, and 10.7, pass values using assignment rules: from the parent variable to the child port for input, and from the child's output port to the parent's connection for output. After `#1`, display the original value, connection, and sample to distinguish the final 2-state conversion. The ports and connections themselves are explicit 4-state wire. The bit / logic factors represent the types of sampled variables; they do not mean that 2-state ports were verified. inout, ref, and multiple drivers are out of scope.

In addition to a signed 129-bit output, 65-bit input truncation, and an unsigned 33-bit output, require the 33-bit X input that differed in Icarus and a 32-bit input checking the same extension with known values.

<a id="アンパック配列のコピーと添字方向要素型"></a>

### Unpacked-array copies, index direction, and element types

`unpacked_array_copy` crosses element width (1, 32, 33, 64, 65, 129), signed/unsigned, bit/logic, source and destination index directions, known/X/Z values, and whole-array versus slice assignment. Select 36 cases from 576 possibilities. Cover all 148 factor pairs plus 36 combinations of width × state type × input value, 8 combinations of source direction × destination direction × assignment range, 8 combinations of signedness × assignment range × source direction.

Under 7.6 and 7.4.6, both arrays have the same typedef element type, and 3 fixed-length elements with nonzero indices are matched in declaration order. Whole-array assignment copies 3 elements; slice assignment copies the first 2, also checking preservation of the remaining 1 elements. Use 2 patterns cycling inputs to distinguish confused elements even at 1-bit width. After assignment, change the source to verify independence of the copy; also widen each read element by 1 bits to check sign extension. Make the following mandatory cases: a reverse-direction 129-bit slice containing Z, storing X in a 65-bit bit type, and a signed 33-bit value. Conversions between arrays of different element types, dynamic arrays, and queues are out of scope.

<a id="ビットベクタの集計判定関数と式の形"></a>

### Bit-vector counting/test functions and expression forms

`bit_vector_queries` crosses width (1, 32, 33, 64, 65, 129), bit/logic, expression form (variable, lower half, concatenation prefixed by 1, 2 repetitions), value pattern (0, one 1, multiple 1, X, Z, mixed X/Z/1), distinguished-bit position, and the `$countbits` control-bit set. After excluding lower-half and multi-bit patterns that cannot occur at width 1, 60 cases are selected from 3,320 legal combinations. Cover all 285 factor pairs plus 60 combinations of value pattern × state type × control set, 48 combinations of expression form × value pattern × state type.

Under 20.9, calculate the expected values of `$countbits`, `$countones`, `$onehot`, `$onehot0`, and `$isunknown` from bit strings after state-type conversion and expression construction. The same control bit of `$countbits` is counted only 1 times, and the one-hot decision is determined by the number of known 1 even if X/Z is included. Also observe the original variable, function actual argument, and result of `$bits`. Require replication of mixed 129-bit values with duplicate control bits, X at bit 65, 1 at bit 33 discarded from the low half, and 32-bit Z with concatenation.

<a id="ストリーミング演算と端数ブロック逆変換"></a>

### Streaming operations, partial blocks, and inverse conversion

`streaming_permutation` crosses widths (1, 32, 33, 64, 65, 129), left/right directions, slice widths (1, 4, 8, 16), single vectors versus 3-bit-tagged forms, pack/unpack, destination bit / logic, and known values/X/Z. Select 36 cases from 1,152 possibilities. Cover all 182 factor pairs plus 36 combinations of width × state type × input value, 16 combinations of direction × slice width × pack/unpack, 16 combinations of tag presence × slice width × pack/unpack.

Based on 11.4.14.1 to 11.4.14.3, the right direction keeps the order and the left direction reverses the order of the blocks cut from the right edge. Preserve order within blocks and partial blocks; apply the inverse of pack's index permutation for unpack. With a partial block, applying the same permutation 2 times does not restore the original. For example, representing 6 bits as characters `abcdef` with slice width 4, pack gives `cdefab` and unpack of the same input gives `efabcd`. Unit tests also check inverse-conversion round trips.

Require unpack with Z in 129 bits plus a tag, pack with X at 65 bits, a partial-block unpack of 33 bits with width 4, and rightward streaming of 32 bits plus a tag. Input/output bit counts are equal; width-mismatch padding, dynamic arrays, and `with` range specifications are out of scope.

<a id="比較演算の幅符号未知値と結果の格納"></a>

### Comparison width, signedness, unknowns, and result storage

`comparison_context` crosses left-operand width (1, 32, 33, 64, 65, 129), right-operand width (1 bits narrower, equal, 1 bits wider), each operand's signedness, 10 comparison operators, and 5 value patterns. Select 100 cases from 3,400 possibilities excluding width 0. Cover all 302 factor pairs plus 100 combinations of operator × value pattern × right-operand sign, 34 combinations of width × right width × left-operand sign, 40 combinations of left-operand sign × right-operand sign × operator.

Based on 11.4.4 to 11.4.6, it handles `< <= > >= == != === !== ==? !=?`. Sign extension applies only when both operands are signed. Relational operations return X if even 1 bit is X/Z; a known mismatch makes logical equality `==` return 0 and logical inequality `!=` return 1. Case equality compares 4-state values exactly; wildcard equality masks X/Z only on the right operand.

Use 4 input combinations per test to check negative numbers, upper bits, known mismatches, and unknown matches. `both_unknown` successively places X/X, Z/Z, X/Z, and Z/X in the upper bits. The comparison is observed as 1 bit and assigned directly to 7-bit logic/bit targets, checking that the unsigned 1-bit result is extended with 0 before conversion to 2-state values, and that `$bits` is 1. Require mixed-sign wildcard comparison at 129 bits, two signed operands with unknowns at 65 bits, known-value relational comparison at 33 bits, and case equality with unknowns at 1 bits. Real, handle, and string comparisons are out of scope.

<a id="配列リダクションの要素型with式コンテナ"></a>

### Array-reduction element types, with expressions, and containers

`array_reduction_pipeline` crosses element width (1, 32, 33, 64, 65, 129), bit/logic, signed/unsigned, fixed arrays/dynamic arrays/queues, `sum/product/and/or/xor`, transformation (no with, size cast of width +1, int cast, integer cast), and known/high-X/high-Z values. Select 72 cases from 4,320 possibilities. Cover all 261 factor pairs plus 72 combinations of width × conversion × input value, 60 combinations of method × container × conversion, 30 combinations of method × state type × input value.

Under 7.12.3, 6.24.1, and 6.11.2, convert elements to the with-expression type, then reduce at that type's width. Distinguish `int` as a signed 32-bit 2-state type and `integer` as a 4-state type with the same width and signedness. The fixed-size array is `[3:1]`; other containers also have 3 elements. Across 2 rounds, use one selected value and all-1 / all-0 backgrounds to check arithmetic overflow, controlling values in bitwise operations, X/Z propagation, and upper-bit truncation to 32 bits.

Observe the result stored in its specified type, the method call assigned directly to a variable 1 bits wider, the widened stored result, and the method expression's `$bits`. For example, when all 3 unsigned 1-bit elements equal 1, ordinary sum overflows at 1 bits and produces 1; reduction with a 2-bit with expression produces 3. A wider destination alone does not prevent overflow during reduction.

Make the following mandatory cases: 129-bit queues and type casts, 65-bit dynamic arrays and width extension, 33-bit fixed-size arrays, 1-bit aggregation, paired conversion of X to int / integer, extension of a 32-bit product, and dynamic-array and at 129 bits. Empty arrays, associative arrays, and with-expression side effects are out of scope.

<a id="可変ビット選択と添字範囲無効アクセス"></a>

### Variable bit-selects, index ranges, and invalid accesses

`variable_bit_index` crosses width (1, 32, 33, 64, 65, 129), index-range origin (0, 5, all-negative indices), ascending/descending order, bit/logic, signedness of the 16-bit index, index value (minimum, maximum, middle, just below/above the range, X, Z), and written value. At width 1, maximum/middle equal minimum and are excluded; select 44 cases from 2,880 possibilities. Cover all 253 factor pairs plus 36 combinations of width × state type × write value, 42 combinations of range start × index sign × index value, 28 combinations of range direction × index value × state type.

Under 11.5.1 and 7.4.5, check read, write, and reread in every case. The index is a runtime 4-state variable, evaluated using its own type and width independently of the vector width. The same negative-number 16-bit representation is negative when signed and a large positive number when unsigned. Verify that reads at invalid indices return X for logic and 0 for bit, and that writes preserve all bits. Every valid known-value write inverts the target bits; X/Z writes follow the destination type. Observe all bits and read values before/after writes, and sampled values of type bit.

Make the following mandatory cases: a negative 129-bit range with an unsigned index, a nonzero start and an X write in the middle at 65 bits, a negative signed index at 33 bits, and a 1-bit bit type with a Z index. Part-selects, multidimensional arrays, and compound assignments are outside this model's scope.

<a id="キュー操作と容量初期サイズ要素型"></a>

### Queue operations, capacity, initial size, and element types

`queue_update_capacity` crosses element width (1, 32, 33, 64, 65, 129), bit/logic, signed/unsigned, capacity (unbounded, 2 elements, 3 elements), initial size (0, 2, 3), push_front/push_back/insert/write at size()/pop_front/pop_back, and known/X/Z values. Select 48 cases from 3,456 possibilities, excluding initial size 3 for capacity 2. Cover all 258 factor pairs plus 36 combinations of width × state type × input value, 48 combinations of capacity × initial size × operation, 36 combinations of operation × signedness × input value.

Under 7.10.1, 7.10.2, and 7.10.5, discard capacity overflow from the end after each operation. Capacities 2 and 3 are `[$:1]` and `[$:2]`, respectively. Also check the mandatory warning when adding to a full queue. Insert in the middle; use `q[q.size()]` for element writes. Popping an empty queue checks the default value: 0 for bit elements and X for logic elements. Widening the popped value by 1 bit also observes extension according to the element type's signedness.

Make the inserted argument 1 bits wider than the element to check truncation and 2-state conversion. Cycle through 2 input combinations to distinguish element order even for 1-bit elements. Observe the pre-operation queue copy, all post-operation elements and size, retrieved values, and the original argument changed afterward to verify value-copy independence. Attach clauses per case according to the actual operations and capacity.

Require push_front into a full 129-bit queue, insert into a full 65-bit queue, removal from empty queues with signed logic-type and bit-type elements, and a tail write into a full 1-bit queue. Element-reference lifetime, queue slices, and invalid insert positions are out of scope.

<a id="除算剰余と演算前の幅符号の統一"></a>

### Division/remainder and width/sign alignment before operation

`division_context` crosses left width (1, 32, 33, 64, 65, 129), right and target widths (1 bit narrower than the left, equal, 1 bit wider), both inputs' signedness, division/remainder, known values/division by zero/X/Z on either side, and target bit/logic. Select 72 cases from 4,704 possibilities excluding width 0. Cover all 283 factor pairs plus 72 combinations of width × input value × state type, 8 combinations of both input signs × operation, 18 combinations of right width × destination width × operation.

Under 11.4.3, 11.6.1, 11.8.1, and 11.8.2, extend to a width that also includes the destination before operating, and calculate as signed only when both inputs are signed. Round the quotient toward 0; give the remainder the left input's sign. Do not use Python's `//` or `%` directly for negative numbers; compute the quotient from integer absolute values, then calculate the remainder as left input − quotient × right input. Division by zero or X/Z input makes the entire result X; apply conversion to bit after the operation.

Give every case 4 known-input combinations and observe 4 additional combinations for zero/X/Z cases. Even when unknowns make the entire result X, check signedness and context effects with known inputs. Display inputs, results stored at natural width, direct assignments to wider/narrower destinations, and the expression's `$bits`. Require the 129-bit minimum negative value divided by −1, a 65-bit mixed-signedness remainder, 33-bit truncation, bit conversion after division by zero, and extension from division of 1-bit signed operands to 2 bits. Reals and side-effecting input expressions are out of scope.

<a id="動的配列のサイズ変更初期化コピーの独立性"></a>

### Dynamic-array resizing, initialization, and copy independence

`dynamic_array_resize` crosses element width (1, 32, 33, 64, 65, 129), bit/logic, signed/unsigned, known/X/Z values, original size (0, 2, 3), new size (0, 1, 2, 4), and copying from another array/self-resizing/reallocation without an initializer. For original size 0, fix values to known and select 38 cases from 2,016 possibilities after removing duplicates. Cover all 219 factor pairs plus 36 combinations of width × state type × value, 36 combinations of original size × new size × operation, 24 combinations of state type × new size × operation.

Under 7.5.1 and 6.8, `new[n](source)` copies from the beginning, truncates the tail when shrinking, and fills added elements with the element type's default value (0 for bit and X for logic). Self-resizing uses pre-change values; `new[n]` does not retain old values. Use a runtime variable for the size; the element type remains the same typedef. Cycle through 2 input combinations to distinguish positions even for 1-bit elements. Observe sizes/all elements before and after reallocation, both arrays after changing source and result in turn, and element values widened by 1 bits. Even with known inputs, cases observing X in newly allocated logic regions are 4-state tests.

Make the following mandatory cases: self-extension preserving Z in 129-bit logic, X input and a shortened copy in 65-bit bit, same-size reallocation of 33-bit logic, self-extension of an empty 1-bit bit array, and changing 65-bit logic to an empty array. Element-reference lifetime and multidimensional arrays are out of scope.

<a id="連結した左辺への代入型変換nba"></a>

### Assignments to concatenated left-hand sides, type conversion, and NBA

`concatenated_assignment` crosses total concatenation width (2, 32, 33, 64, 65, 129), split (1 bit on the left, equal halves, 1 bit on the right), RHS width (1 bit narrower, equal, wider), RHS signedness, the 4 left/right bit/logic combinations, common signedness of both terms, blocking/NBA, and known/X/Z values. Give all 2 terms positive widths, then select 72 cases from 4,608 combinations after removing duplicate partitions of width 2. Cover all 265 factor pairs plus 72 combinations of width × left/right state types × value, 18 combinations of partition × right width × right-operand sign, 24 combinations of left/right state types × update method × value, 12 combinations of right-operand sign × term sign × right width.

Following 11.4.12, 10.7, and 6.11.2, convert the right-hand side to the width of the entire concatenation before splitting it, then store each item according to its bit / logic. Even if the left-hand concatenation is unsigned, a standalone right-hand variable retains its signed/unsigned attribute; extend a narrower right operand according to its own sign. Reads extend each term according to its sign, but the concatenation expression as a whole is unsigned and uses 0 extension.

Give every case 2 known-input combinations and add 2 combinations for X/Z cases. Observe both terms and widened values immediately after updating, after changing the right-hand side, and at the next time, verifying that NBA captured the pre-change right-hand side. Destinations are separate static variables. Make the following mandatory cases: NBA using mixed types and Z at 129 bits, truncation and 2-state conversion at 65 bits, NBA at 33 bits, reverse-direction mixed types at 32 bits, and sign extension of a 1-bit right-hand side. Overlapping destinations, part-selects, and multidimensional arrays are out of scope.

<a id="パックベクタの論理リダクションと状態変換の順序"></a>

### Packed-vector logical/reduction operations and state-conversion order

`packed_logical_reduction` crosses width (1, 32, 33, 64, 65, 129), input bit/logic, expression form (unchanged, lower half, concatenation prefixed by 0 or 1), value (all 0, all 1, one 1, X, Z, mixed X/Z/1), distinguished-bit position, and result bit/logic. Treat positions of all-0 and all-1 as inapplicable; select 70 cases from 1,180 possibilities after excluding duplicate positions / mixed values at width 1 and part-selects at width 0. Cover all 218 factor pairs plus 70 combinations of width × input state type × value, 48 combinations of expression × input state type × value, 24 combinations of input state type × result state type × value.

Execute all `&/~&/|/~|/^/~^` and logical negation `!` on each row. Instead of adding cases per operator, independently assess expected values for 7 operations under the same stimulus. Beyond existing individual-operation tests, this model checks input state conversion, expression form, width boundaries, and result extension as a sequence.

Under 11.4.9 and 11.4.7, 0 is the controlling value for AND, and 1 for OR. A known 1 makes logical negation 0 even if other positions contain X/Z. XOR propagates the unknown value and checks the parity of the number of 1 if the input is known. Input-type bit conversion occurs before the operation; result-type bit conversion occurs afterward. For the same X input, observe the distinction between producing known 0/1 in the former and converting an X operation result to 0 in the latter.

Observe original 4-state inputs, inputs after conversion, the actual expression, the 1-bit result, direct assignment to 7 bits, and the expression's `$bits`. Fix inputs as signed and verify that the result is unsigned 1-bit and 0-extended. Also use known all-1 input in every case, distinguishing width and controlling-value effects even in X/Z rows. Make the following mandatory cases: mixed upper bits at 129 bits, leading 1 and Z at 65 bits, a 33-bit part-select with input bit conversion, 1-bit Z, a AND controlling value with leading 0, and parity of a 65-bit all-1 value. Binary logical operations and side-effecting expressions are out of scope.

<a id="二項論理演算の短絡評価副作用型変換"></a>

### Short-circuit evaluation, side effects, and type conversion in binary logical operations

`logical_short_circuit` crosses left width (1, 32, 33, 64, 65, 129), right width (1 bit narrower, equal, wider), the 4 left/right bit/logic combinations, each input's value class (all 0, one highest-position 1, unknown, unknown mixed with known 1), and result bit/logic. Select 92 cases from 2,088 possibilities after removing mixed values impossible at widths 0 and 1. Cover all 214 factor pairs plus 92 combinations of width × left/right state types × left value, 64 combinations of left/right values × state type, 32 combinations of left/right values × result state type, 48 combinations of right width × state type × right value.

Execute all `&&/||/->/<->` on each row. Under 11.4.7, `&&` and logical implication `->` do not evaluate the right operand if the left operand is false; `||` does not evaluate the right operand if the left operand is true. Evaluate the right operand when the left is unknown. Logical equivalence `<->` evaluates each operand only 1 times. Give left/right functions independent call counters, read-value records, and markers; also check retention when the right function is not called. Neither function changes the other's values or side effects, so the test does not depend on unspecified evaluation order.

2-state conversion to the input type precedes Boolean evaluation; conversion to the result type follows the operation. Place a single 1 and unknowns in the top bit; for mixed values, also put 1 in the lowest bit. Verify that positions beyond 64 bits also contribute to Boolean evaluation. Inputs remain signed; the tests also check 0 extension of the unsigned 1-bit result to 7 bits. Run the 1-bit result and direct assignment to 7 bits separately, resetting side-effect records each time. `$bits` is passed a variable expression instead of a function call, and does not cause any additional side effects.

In rows containing unknowns, observe both pairs short-circuited by known 0/1 and distinct X/Z input pairs in the same case. When both operands contain unknowns, use X/X, X/Z, Z/X, and Z/Z. Make the following mandatory cases: unknown upper bits at 129 bits, bit conversion of a 65-bit input, mixed true/false values at 33 bits, 1-bit and 2-bit left/right operands, and logical implication from a zero left operand. Reals, side effects shared between the two functions, and functions consuming time are out of scope.

<a id="イベント式のエッジ判定xz遷移更新時点"></a>

### Event-expression edge classification, X/Z transitions, and update timing

`edge_event_expression` crosses width (1, 32, 33, 64, 65, 129), bit/logic, event expression (whole vector, LSB, MSB, OR reduction), change position (low, middle, high), before/after 0/1/X/Z, and blocking/NBA. Select 64 cases from 4,032 legal possibilities. Width 1 keeps only the low position. Since model version 2 (2026-11-12) width 1 also keeps only the LSB of the two bit-select expressions, because the LSB and the MSB are then the same bit, `source[0]`. Cover all 259 factor pairs plus 64 combinations of expression × before change × after change, 32 combinations of state type × before change × after change, 32 combinations of width × position × state type, 24 combinations of expression × position × update method.

Use both 0/1 backgrounds on each row; observe `posedge`, `negedge`, and value-change events without an edge qualifier using separate counters. Under 9.4.2, posedge comprises 0→1/X/Z and X/Z→1, while negedge comprises 1→0/X/Z and X/Z→0. In X↔Z, neither `posedge` nor `negedge` occurs, and only the edge-unspecified event control is triggered. Vector-expression edge detection examines only LSB, while event controls without an edge qualifier examine changes to all bits. For OR reduction, verify that a background 1 keeps the expression result unchanged when the selected bit changes, so no event occurs. If the input is bit, evaluate the value after converting X/Z to 0.

Wait `#1` after initialization and clear counters, wait another `#1` before updating the target, then observe values and 3 counters `#1` afterward. Immediately after updating, observe only original signal values to check blocking versus NBA behavior. Do not read counters immediately afterward when that would race event processing. Each line also observes the known 0 → 1 transition, using it to distinguish cases where bit conversion turns the specified transition into no change.

Mandatory cases include high-position X→Z at 129 bits, X→1 for 65-bit MSB, Z→1 and NBA for 33-bit bit, 0→Z at 1 bits, and background 1 suppressing changes in the OR expression. Event OR, iff, multiple updates within one time step, glitches, and multiple clocks are out of scope.

Model version 1 had 4,096 legal possibilities and selected five pairs of equal tests at width 1. Version 2 replaces 17 of the 64 selected cases. The expectations of the remaining rows did not change.
Every one of the 4,032 legal rows ran once on kirimasim `7de185f776a1` and on pinned Icarus Verilog 13.0, and all rows match on both ([record](../coverage/interaction-qualification/edgedpiquery-all-rows.json)).
The 64 selected cases pass on [kirimasim](../coverage/interaction-results/full-20261112-kirimasim-7de185f7-edgedpiquery.json) and on [pinned Icarus Verilog 13.0](../coverage/interaction-results/edgedpiquery-20261112-icarus13.json). Pinned Verilator 5.052 records 16 pass and 48 known for [seed 1](../coverage/interaction-results/edgedpiquery-20261112-verilator5052-seed1.json) and for [seed 73](../coverage/interaction-results/edgedpiquery-20261112-verilator5052-seed73.json).

<a id="キュー動的配列のファイル監視と登録元の記述位置"></a>

### File monitoring of queues/dynamic arrays and placement of registration code

`heap_file_monitor_context@1` crosses 9 places for registering `$fmonitor` (initial, task, void function, fork, generate, interface, program, package, always), queue / dynamic array, and MCD / FD. Select 18 cases from 36 legal possibilities, covering all 40 factor pairs. Retain the 3 cases program × dynamic array × MCD, package × queue × FD, and function × queue × MCD as mandatory cases.

The monitored container and selected index are variables with static lifetime. Distinguish registration location from monitored-object lifetime; place another persistent process in the program. After registration completes, change values and successively apply multiple same-time updates, updates only to unselected elements, selected-index changes, container replacement, and resizing. Under 21.2.3, 21.3.2, and 4.4.2.9, read the file back within SV to check the final values and size in Postponed. We also observe that file monitoring continues after `$monitoroff` and that no output is produced after close according to 21.3.1. Open another file after close to check its contents, but do not require reuse of the same descriptor number.

This selection covers a finite model of 9 registration origins × 2 container types × 2 descriptor types. This does not guarantee all 36 3-factor combinations, arbitrary syntax nesting, containers in automatic variables, or registrations inside classes. Output stopping alone does not establish removal of internal GC roots or release of actual memory. Registration/reallocation during native callback execution remains unverified as the scope of separate API tests. Because of the Postponed-region restrictions, we do not assume that a SV function with side effects can be substituted directly, or conclude that arbitrary nested registrations are illegal.

<a id="複合シフト代入と左辺の選択"></a>

### Compound shift assignments and left-hand-side selection

`compound_shift_target@1` crosses width (1, 32, 33, 64, 65, 129), bit/logic, signed/unsigned, LHS (scalar, fixed-array element, packed part-select), `<<=`/`>>=`/`>>>=`, shift amount (0, width−1, width, all 1, X, Z), shift-amount width (8, 65), and input (known, X, Z). Exclude only rows where width − 1 duplicates 0 at width 1; select 40 cases from 7,560 possibilities. Cover all 308 factor pairs plus 90 total combinations of operator × shift amount × signedness, width × state type × input, and signedness × operator × left operand; require 4 boundary cases.

Under 11.4.1, index functions for array elements and part-selects are evaluated only 1 times. The function changes its next return value, so evaluating it 2 times changes the call count or write destination. Use 2 background-value combinations and observe pre-operation inputs and shift amounts; post-operation scalar, all array elements, and parent vector; the read value extended to 1 bits; indices; and call counts. Check preservation of unselected elements and bits as well as the result.

Under 11.8.1, array elements retain their element type's signedness, while part-selects are unsigned even when their parent is signed. Under 11.4.10 and 11.6.1, treat the signed 8/65-bit shift amount as a self-determined unsigned value; it does not change the data's width or signedness. All-1 represents a large positive shift amount even when declared as −1. Also distinguishes unknown results caused by X/Z shift amounts from conversion when storing bit in 6.11.2. Construct expected values from bit-position mappings, also checking every known-value candidate with separate integer / 2's-complement calculations.

Require replication of a Z sign bit from 65-bit signed elements, unsigned part-selects of a 33-bit signed parent, 129-bit bit elements with X shift amounts, and 1-bit part-selects with shift amounts consisting entirely of 1. Side effects shared by left/right operands, invalid indices, NBA, overlapping left-hand sides, and `<<<=` are out of scope. Planned coverage applies only to this finite model; it does not guarantee arbitrary expressions or higher-order combinations.

<a id="集合所属判定と集合の格納形式"></a>

### Set membership and set storage forms

`membership_container@1` crosses set-element width (1, 32, 33, 64, 65, 129), LHS width (1 bit narrower, equal, 1 bit wider), signed/unsigned on both sides, element bit/logic, representation (listed values, fixed array, dynamic array, queue), element count (0, 1, 3), and input (known, LHS X, RHS X, RHS Z, X/Z on both sides). Select 46 cases from 5,984 possibilities, excluding only width-0 rows, empty individual lists/fixed arrays, and RHS values for which an empty set does not exist. Cover all 305 factor pairs plus 174 combinations of the following 3-factor groups.

- Set-element width × left-operand width relationship × left-operand signedness
- Set-element state type × input × storage form
- Left-operand signedness × set-element signedness × input
- Element count × storage form × input
- Left-operand width relationship × element count × input

Under 11.4.13, descend through array-set elements to individual values, compare integral elements using `==?` of 11.4.6, and combine the results with 4-state OR. Treat X/Z as wildcards only on the right operand. Distinguishes X/Z stored in bit and converted to 0 before comparison from X/Z retained in logic and acting as wildcards. All elements have the same type/width; comparison width and signedness follow 11.8.2.

Use 0, 1, MSB, and all-1 across 4 input combinations, also permuting element order. Observes the input, supplied and stored values, all elements, actual size, 1-bit decision, direct assignment to wide logic/bit targets, and `$bits`. For nonempty sets, also compare against listing the same values individually in reverse order. Traversal order and expression evaluation counts are unspecified, so the test does not depend on function side effects or evaluation order.

Retains 5 mandatory conditions: 129-bit dynamic arrays with X/Z on both sides; 65-bit bit queues with differing widths and signedness; 33-bit signed fixed arrays with a wider unsigned LHS; 1-bit empty queues with LHS X; and equal-width 33-bit listed values mixing X comparisons and matches. In the final condition, check that even if some comparisons are X, another comparison yielding 1 makes the result 1. Meanwhile, `1'bx inside {1'b0, 1'b1}` is X. Do not change the result to 1 merely because every 2-valued concretization of the left operand matches some element. The independent cross-check also enumerates concretizations separately per comparison before applying OR.

Ranges, nonintegral types, differently typed set elements, nested arrays, and side-effecting expressions are out of scope. Ranges are handled in the following `membership_range@1`. Do not remove legal targets from the model because a simulator lacks support or disagrees.

<a id="集合所属判定の範囲指定と端点の型"></a>

### Set-membership ranges and endpoint types

`membership_range@1` crosses endpoint/element width (1, 32, 33, 64, 65, 129), LHS width (1 bit narrower, equal, 1 bit wider), LHS/endpoint signedness, endpoint bit/logic, range form (closed interval `[lo:hi]`, reversed, `[$:hi]`, `[lo:$]`, absolute tolerance `[a +/- b]`, relative tolerance `[a +%- b]`), input (known, LHS X, endpoint X, endpoint Z), and set composition (range only or mixed ranges and values). Select 46 cases from 5,680 possibilities, covering all 303 factor pairs and 178 combinations of the following 3 factor groups.

- Endpoint width × left-operand width relationship × left-operand signedness
- Left-operand signedness × endpoint signedness × range form
- Endpoint state type × input × range form
- Range form × input × set composition
- Left-operand width relationship × endpoint signedness × range form

According to 11.4.13, the range is matched when the left-hand side is between the two endpoints (including the endpoints), and the relational operator (11.4.4) is used to compare with the endpoints. Compare set values using `==?` (11.4.6), treating X/Z as wildcards only on the right operand. All endpoints and set elements have the same type/width; comparison width and signedness follow 11.8.1 and 11.8.2. If either side is unsigned, also 0-extend signed endpoints. `$` represents the minimum/maximum values of the left operand's type, so that bound always holds when the left operand is known. Tolerance ranges have type `a`; absolute endpoints subtract/add `b` from/to `a`, while relative endpoints use `b` percent of `a` truncated toward 0; swap endpoints when necessary. Choose values where signed negative `b` or negative `a` causes swapping, and truncation affects relative tolerance.

Each row uses 4 input combinations. At the left operand's width, provide endpoints extended using the comparison type (values that should match), endpoints extended using their own sign (matching only on incorrect sign-extending implementations), values 1 below endpoints, all-1, and similar candidates. Observes the input, supplied and stored endpoints, 1-bit decision, direct assignment to wide logic/bit targets, and `$bits`. For colon ranges, also print a parallel test expressing the same endpoints with relational operators. In mixed sets, also list the same X/Z-bearing endpoint variables as value items and add an all-1 value. Check that X/Z makes range comparisons X but acts as wildcards in value items, and check OR where a match takes precedence over X.

Avoid combinations without a uniquely specified standard result through constraints and input selection.

- Construct reversed ranges with positive endpoints (3 and 1) whose left endpoint remains larger regardless of signedness interpretation. Exclude conditions impossible at width 1; use only known values because the text does not define empty ranges containing X/Z.
- For closed intervals with X/Z in one endpoint, use only inputs satisfying the other endpoint. The result is X whether the two relations are combined with `&&` or the range is taken as X whenever either comparison is X.
- Restrict tolerances to values within the range of type `a`. This prevents results from depending on whether endpoint calculations use a wider context or the `a` type.

Retain 6 mandatory conditions: a signed 33-bit closed interval with a wider unsigned left-hand side; 129-bit bit absolute tolerance with a wider unsigned left-hand side; signed 65-bit relative tolerance with a narrower left-hand side; mixed X endpoints and values at unsigned 64 bits; mixed reversed ranges and values at 32 bits; and signed 1-bit `[$:hi]` with an X left-hand side.

The independent cross-check recalculates each case using integral intervals rather than bit strings. Calculate tolerances exactly in base 10 and truncate toward 0. Fault injection into the reference model detected all 7 error types in at least 2 cases: extending endpoints using their own sign, reading endpoint X/Z as 0, not swapping tolerance endpoints, rounding relative tolerance to nearest, deriving `$` from the endpoint type, swapping endpoints of reversed ranges, and reading left-operand X/Z as 0.

Nonintegral types, differently typed set elements, side-effecting expressions, and evaluation order are out of scope.

<a id="case-insideの項目の種類と選択"></a>

### case inside item kinds and selection

`case_inside_selection@1` crosses item widths (1, 32, 33, 64, 65, 129), case-expression widths (1 bit(s) narrower, equal, 1 bit(s) wider), case-expression/item signedness, item bit / logic, first-item kind (value, range `[lo:hi]`, fixed array of 2 elements, list of 2 values), inputs (known values, case-expression X, item X, item Z), modifiers (none / `unique0`), and item 3 (variable or function call with an evaluation counter). Select 34 cases from 8,704 possibilities, covering all 315 factor pairs and 154 combinations of the following 3 factor groups.

- Item width × case-expression width relationship × case-expression signedness
- Case-expression signedness × item signedness × first-item kind
- Item state type × input × first-item kind
- First-item kind × input × qualifier
- Case-expression width relationship × item signedness × first-item kind
- Item 3 × qualifier × first-item kind

Under 12.5.4, compare using `inside` with the case expression as the left operand and each item as the right operand. X/Z in value items are wildcards; X/Z in range endpoints make the comparison X; X/Z in the case expression are not wildcards. Only an item producing 1 matches. Both 0 and X count as nonmatches and advance to the next item; if none matches, `default` executes. All items have the same type/width; no integer-literal items are used. Thus each comparison's width and signedness are determined by the case-expression/item type pair in 11.8.1 and 11.8.2, giving the same result as the rule aligning all items in 12.5.

Each `case` lists the first item, value `second`, variable/function-call item 3, and `default` in that order. Use 4 case-expression combinations targeting the first, 2-th, 3-th, and `default` items; among values reaching each target, prioritize those making an earlier item X. Candidate values include item values extended using the comparison type and using the item's own sign, the latter selected only by implementations that incorrectly sign-extend. Provide the case expression through a call-counting function and observe that it is evaluated only 1 times on each execution. Without a qualifier, a prior matching item prevents the function in item 3 from being called. `unique0` evaluates remaining items even after a match, so print that the function was called (12.5.3); do not use inputs matching 2 or more items. Also output item values before/after storage.

priority and unique are out of scope because the text does not explicitly state the relationship between no-match violation reporting and `default`. Item 3 is split into variable and function-call factors so that implementations lacking side-effecting items can still check interactions among width, signedness, X/Z, and item kind.

Retains 7 mandatory conditions: 33-bit signed fixed arrays with a wider unsigned case expression; 65-bit signed ranges with `unique0` and function calls; value-item X at 129 bits; list-item Z and `unique0` for 64-bit bit; case-expression X and a function call at 32 bits; item X in 1-bit signed ranges; and endpoint X in a 64-bit unsigned range, where the first item produces X and item 2 is selected.

The independent cross-check recalculates each case using integer comparisons and linear search. Fault injection into the reference model detected all 7 error types: accepting X results as matches, extending items using their own sign, reversing wildcard-comparison operands, selecting the last match, reading item X/Z as 0, calling item 3 after a match, and reevaluating the case expression for each comparison.

Evaluation counts of multiple expressions within items, side-effect order, combinations with casez/casex, and nonintegral items are out of scope.

<a id="短時間実行と合否の確認"></a>

## Short runs and pass/fail checks

The combined short run for 29 models targets 1,426 cases. Added 46 range cases and 34 case inside cases. The 2 short-circuit/event-control models have 156 cases selected from 6,184 constraint-satisfying possibilities. The following example passes selected paths as arguments to the existing runner. Specify a simulator prepared in advance.

```sh
python3 tools/interaction_coverage.py --list-tests
python3 tools/interaction_coverage.py --list-tests --model nba_capture
python3 tools/interaction_coverage.py --list-tests --model expression_context
python3 tools/interaction_coverage.py --list-tests --model task_argument_visibility
python3 tools/interaction_coverage.py --list-tests --model port_connection
python3 tools/interaction_coverage.py --list-tests --model unpacked_array_copy
python3 tools/interaction_coverage.py --list-tests --model bit_vector_queries
python3 tools/interaction_coverage.py --list-tests --model streaming_permutation
python3 tools/interaction_coverage.py --list-tests --model comparison_context
python3 tools/interaction_coverage.py --list-tests --model array_reduction_pipeline
python3 tools/interaction_coverage.py --list-tests --model variable_bit_index
python3 tools/interaction_coverage.py --list-tests --model queue_update_capacity
python3 tools/interaction_coverage.py --list-tests --model division_context
python3 tools/interaction_coverage.py --list-tests --model dynamic_array_resize
python3 tools/interaction_coverage.py --list-tests --model concatenated_assignment
python3 tools/interaction_coverage.py --list-tests --model packed_logical_reduction
python3 tools/interaction_coverage.py --list-tests --model logical_short_circuit
python3 tools/interaction_coverage.py --list-tests --model edge_event_expression
python3 tools/interaction_coverage.py --list-tests --model heap_file_monitor_context
python3 tools/interaction_coverage.py --list-tests --model compound_shift_target
python3 tools/interaction_coverage.py --list-tests --model membership_container
python3 tools/interaction_coverage.py --list-tests --model membership_range
python3 tools/interaction_coverage.py --list-tests --model case_inside_selection
```

```python
import subprocess
import sys

tests = subprocess.check_output(
    [sys.executable, "tools/interaction_coverage.py", "--list-tests"],
    text=True,
).splitlines()
subprocess.run(
    [sys.executable, "tools/run_icarus.py", "--iverilog-bin", "/path/to/icarus/bin",
     "-j", "8", "--json", "my-results/cross.json", *tests],
    check=True,
)
```

In addition to the runner exit code, check cross satisfaction with the following command. Normal runner termination that tolerates known differences does not establish a passing cross.

```sh
python3 tools/interaction_coverage.py --results my-results/cross.json --require-pass
python3 tools/interaction_coverage.py --model nba_capture \
  --results my-results/cross.json --require-pass
```

For each specified run, `--require-pass` requires all target combinations and mandatory cases of every selected model to pass. On a simulator unable to execute 4-state cases, omitting X/Z cases does not satisfy the entire model. Inspect partial results by omitting `--require-pass` from the same command.

Ordinary full runs are unchanged. Full-run results can use passes from every available case registered to the same model, so existing scheduling tests beyond the 51 selected cases also provide evidence. Do not interpret fewer selected short-run cases as an equivalent reduction in runtime.

<a id="計画と実行証跡の扱い"></a>

## Handling plans and execution evidence

`generators/interaction_cover.py` lists the complete combinations that satisfy the constraints, and constructs the denominators from the factor pairs and factor groups contained in them. A partial assignment alone does not establish compatibility with all other constraints. Selection uses deterministic greedy selection and redundant-case removal; there is no general guarantee of a minimum count. Reject models whose Cartesian products exceed 10,000 rows. Split the scope by meaning before registration.

`tools/interaction_coverage.py` checks the generated file for matches with the expected values, and checks the simulator version of the execution trace, the date, the hash of the runner, and the input hash of each test. Results from runs whose runner or inputs changed during execution do not count as passes.

- `pass`: a pass matching the current inputs and runner. Count this among combinations verified by passing results.
- `fail`, `known`, `unsupported`: not used as passing results.
- `stale`: a result unusable as current evidence, for example due to a different input hash.
- `not_run`: no result in that run.

Do not combine partial successes from runs with different versions or seeds. Each mandatory case must itself pass. Raw reachability, measuring which stimuli were reached during a failed run, is not measured. 100% in this aggregate refers to target combinations of registered models; it does not establish all-language combination coverage or absence of defects.

<a id="ci更新手順"></a>

## CI and update procedure

Check checks generated results, selection plans, aggregates from saved execution evidence, and unit tests. Register oracles for cases matching expected values on fixed release Icarus Verilog 13.0. Keep cases differing from standard-derived expected values as `spec`; do not count them as execution-verified. Distinguish fixed-release verification from Nightly measurements using the latest development commit. Nightly generates `interaction-coverage.md` and `interaction-coverage.json` for branch `results` from that run's simulator-specific JSON.

<a id="issue-21の境界条件の回帰テスト"></a>

### Regression test of boundary conditions for issue #21

Issue #21 added 74 cases in total: 9 event cases, NBA16 cases, 18 composite-type cases, I/O13 cases, and 18 file-monitoring cases. Only 18 of these cases are selected cases in `heap_file_monitor_context@1`. The remaining 56 cases are regression tests for mechanism boundaries, not part of t-way achievement rates for cross models with defined factors and complete targets. Also reuse existing tests, managing each candidate's primary observations, controls, standard rationale, and input fingerprints in [Mapping registry](../coverage/combination-gaps.json).

[Regression incorporation report](p1-combination-regressions-20261030.en.md) documents pending standard interpretations, the scope to be checked with separate API, and execution results for the current inputs. Check registration / standard-review completion separately from implementation passes. Besides the 18 finite-model cases, the following list includes other new tests and reused existing tests.

```sh
python3 tools/combination_gaps.py --list-tests
python3 tools/combination_gaps.py --check
```

`--check` checks consistency of the ledger, test fingerprints, and reports built from saved results. This command does not require every simulator case to pass. Pass the listed paths to the existing runner, save new result JSON to `coverage/combination-results/`, then update the report with `python3 tools/combination_gaps.py --update`. kirimasim checks for the latest commit upstream just before execution and builds from that commit. Record unsupported cases and disagreements without changing expected values.

<a id="過去の導入確認"></a>

### Historical introduction checks

The execution trace stored in `main` is `coverage/interaction-results/`. During introduction checks for 2026-10-29, all 87 cases matched with Icarus Verilog 13.0 and with kirimasim `dd2c01887e0a`, whose agreement with upstream main was confirmed immediately before execution. Verilator 5.052 ran 63 cases with each of seeds 1 and 73; the 12 new known-value cases agreed in both runs. Report 8 existing scheduling differences and 24 unexecuted X/Z cases as unsatisfied.

After the 3-model expansion that day, all 206 cases matched with kirimasim `f8408ea37ac1`, rebuilt after confirming agreement with upstream main immediately before execution. 204 cases agreed on Icarus Verilog 13.0; the following 2 conditional-operation cases retain Z and therefore differ from expected values based on Table 11-20 of the standard. Retain this as unsatisfied `known` without changing the denominator or expected values.

Verilator 5.052 ran 134 cases with each of seeds 1 and 73; 126 cases agreed in each run. Do not count 8 existing scheduling differences or the 72 excluded 4-state cases as passes.

- `test_gen_cross_cond_w129_ss_x_same_xz_w_l`: two signed 129-bit branches, condition X, extension destination logic.
- `test_gen_cross_cond_w65_uu_z_same_xz_n_l`: two unsigned 65-bit branches, condition Z, truncation destination logic.

Save initial and extended execution results in separate files. The initial 87 case results do not establish execution of models added later.

For the subsequent shift/cast/task extension, all 330 cases agreed on kirimasim `b86ccb6eeee4` checked against upstream main immediately before execution. 322 cases agreed on Icarus Verilog 13.0; in addition to the previous 2 conditional-operation cases, the new 6 ref-argument cases are unsupported at compilation. Verilator 5.052 ran 181 cases with each of seeds 1 and 73; 172 cases agreed in each run. Known differences comprise the previous 8 cases and 1 array-element ref-call cases. The 149 4-state cases have not been run.

Sources used to verify the 124 added cases: 118 from Icarus 13.0, 1 unsupported by Icarus but agreeing on both seeds of Verilator 5.052, and 5 from the standard alone. Record the 6 cases with unsupported ref in Icarus and rejection by `Error-IMPURE` for `test_gen_cross_task_w33_b_k_ref_e_i` in Verilator without removing them from the tests. The latter occurred with an array-element ref call to a non-inlined task that reads an external variable. Do not change the plan denominator according to implementation support.

After structure/case/port extensions, all 438 cases agreed on kirimasim `ee36c83de3c9` rebuilt after checking against upstream main. 428 cases agreed on Icarus 13.0; the previous 8 cases and the following 2 port-connection cases have known differences. With the runner's `-ginterconnect`, connecting a signed parent variable to a wider input extends it with 0. The same cases matched expected values without this option. Retain expected values using sign extension under 23.3.3.8 and 10.7.

- `test_gen_cross_port_w32_i_s_w_k_l_n_a`: 32-bit known value, named specification, ANSI declaration.
- `test_gen_cross_port_w33_i_s_w_x_b_p_n`: 33-bit X, positional specification, non-ANSI declaration.

Verilator 5.052 ran 211 cases with each of seeds 1 and 73; 202 cases agreed in each run. The 9 known differences are unchanged; 227 4-state cases are unexecuted. Verification sources for the 108 additions: 106 cases using Icarus, 1 using both seeds with Verilator, and 1 based on the standard alone. Also check known-value port connections with Verilator and record option-dependent differences from Icarus in [Simulator differences](simulator-differences.md).

After the array-copy / bit-function / streaming extension, ran 570 cases on kirimasim `5e8ab597520a` rebuilt after checking upstream main immediately before execution; 564 agreed. 6 array-slice assignment cases are unsupported in `assignment of this unpacked array value (not implemented yet)`. There are no comparison disagreements, but not all cases pass. All bit-function and streaming cases agree, but `--require-pass` for the full array model remains unsatisfied.

Sources used to verify the 132 added cases: 39 from Icarus 13.0, 25 from both seeds of Verilator, and 68 from the standard alone. Checking 60 bit-function cases with identical inputs across 6 runs on Icarus gave varying agreement counts of 54, 52, 55, 56, 53, and 54; 51 cases agreed in every run. `$countones` results varied in 9 cases whose concatenated/replicated width exceeded 64 and was not a multiple of 32. In the Ubuntu 24.04 environment of Check, 12 cases that agreed in all 6 local runs also differed. Argument widths are 2, 33, and 34 bits. Do not register a Icarus oracle for the combined 21 cases whose widths after concatenation/replication are not multiples of 32. Save preliminary verification JSON and selection criteria in [Verification-source selection records](../coverage/interaction-qualification/README.en.md), retaining original input hashes. Keep this separate from current execution evidence; unit tests also prohibit registering Icarus oracles for cases whose results vary by run or environment.

Verilator 5.052 ran 247 cases with each of seeds 1 and 73; 237 cases agreed in each run. Known differences comprise the previous 9 cases and 1 cases of `test_gen_cross_stream_w33_l_s4_p_unpack_b_k`. For this unpack of 33 bits with width 4, the measured result used the same index permutation as pack. Retain expected values using inverse conversion under 11.4.14.3. The inverse-conversion interpretation also agrees with [Accellera description](https://www.accellera.org/images/eda/sv-ec/4737.html) from the clause's proposer, but this historical discussion does not replace the current standard. The 323 4-state cases were not run on Verilator.

For the comparison / array-reduction extension in 2026-10-30, all 172 added cases agreed on kirimasim `5e8ab597520a`, checked against upstream main immediately before execution. Of all 742 cases, 736 agree; the previous 6 array-slice assignment cases remain unsupported. `--require-pass` for these 2 models passes, but selecting all 16 models leaves the array-copy model containing these 6 cases unsatisfied. Verification sources for additions: 100 cases from Icarus 13.0, 13 from both seeds of Verilator, and 59 from the standard alone. The 100 comparison cases in Icarus agree; the 72 array-method cases are unsupported at compilation.

Verilator 5.052 ran 291 cases with each of seeds 1 and 73; 266 cases agreed in each run. The 451 4-state cases are excluded from execution. Of 25 known differences, this work adds 4 comparison cases and 11 array-method cases. In 4 comparison-operation cases, `UNSUPPORTED` rejects a nonconstant 4-value expression on the right-hand side of a wildcard operation, even when the variable stores a known value.

Of 11 array-method cases, 4 fail during C++ build; 7 differ from expected return values, extension, or width observations. For example, in `test_gen_cross_method_w1_b_u_d_sum_plain_known`, extending unsigned 1-bit result 1 to 2 bits gave `11` instead of expected `01`. In `test_gen_cross_method_w32_l_u_f_product_widen_known`, assigning the return value determined by the with expression to a wider destination produces bits that differ from the expected value. Retain standard-derived expected values for both. The 7 cases with output differences are as follows.

- `test_gen_cross_method_w1_b_u_d_sum_plain_known`
- `test_gen_cross_method_w32_b_u_d_and_integer_known`
- `test_gen_cross_method_w32_l_u_f_product_widen_known`
- `test_gen_cross_method_w33_b_u_d_product_int_known`
- `test_gen_cross_method_w33_b_u_d_xor_integer_known`
- `test_gen_cross_method_w33_b_u_q_product_widen_known`
- `test_gen_cross_method_w64_l_u_d_or_int_known`

Only temporary build-directory names in saved failure diagnostics are redacted. Do not change execution timestamps, versions, assessments, or input/runner hashes.

The same-day variable-bit-select / queue-operation extension used kirimasim `b0fc996cc2c7` built in an independent working directory after incorporating upstream updates. Agreement with upstream main is checked immediately before execution. All 92 additions agree, and `--require-pass` for these 2 models passes. Of all 834 cases, 828 agree; the existing 6 array-slice assignment cases are unsupported. Verification sources for additions: 64 cases from Icarus 13.0, 3 from both seeds of Verilator, and 25 from the standard alone.

Icarus ran the 92 additions 2 times with identical inputs; 64 cases agreed in both runs. The 18 variable-bit-select differences concern invalid reads from bit returning X rather than 0. For queues, 3 empty-queue pops of type bit returned X; 7 additions of differently sized arguments to queues of 4-state elements stopped on a runtime assertion. For example, `test_gen_cross_queue_w129_l_s_c2_n0_insert_known` compiles successfully but then stops on assertion `value.size() == wid`. Retain the tests and expected values.

Verilator 5.052 ran 324 cases with each of seeds 1 and 73; 292 cases agreed in each run. The 510 4-state cases have not been run. Of 32 known differences, 7 are additions from this work. The following 3 invalid-bit-select cases differed from the required read value 0 / ignored-write behavior.

- `test_gen_cross_index_w129_z_a_b_u_before_known`
- `test_gen_cross_index_w64_n_a_b_u_after_known`
- `test_gen_cross_index_w65_n_a_b_s_before_known`

Of the 4 queue cases, `test_gen_cross_queue_w1_b_u_c3_n3_insert_known` made a full capacity-3 queue reach size 4. The following 3 cases match elements and size but lack the mandatory capacity-overflow warning, so they do not count as passes.

- `test_gen_cross_queue_w1_b_u_c2_n2_push_front_known`
- `test_gen_cross_queue_w1_b_u_c3_n3_write_end_known`
- `test_gen_cross_queue_w65_b_s_c2_n2_push_back_known`

The same-day division/remainder and dynamic-array extension used kirimasim `2020305e0ae2` built in an independent working directory after checking agreement with upstream main immediately before execution. All 110 additions agree; 938 of all 944 cases agree. 6 array-slice assignment cases remain unsupported. `--require-pass` for these 2 models passes for both kirimasim and Icarus. In all the 20 models of kirimasim, only the array copy model containing this 6 item is not complete.

Reproduced all 110 additions 2 times on Icarus 13.0 and registered that version's oracle. The overall 741 fixed-oracle cases also agree. Measurements including non-fixed-oracle cases had 757 agreements and 187 known differences. Measurements also include previously unstable bit-counting results, but agreement in only this run is not used to add an oracle.

Verilator 5.052 ran 346 cases with each of seeds 1 and 73; 314 cases agreed in each run. The 88 added 4-state cases are outside execution scope; the remaining 22 agree on both seeds. The overall 32 known differences are unchanged from the previous run. Also cross-checked new-model expected values with independent rational arithmetic for division and a separate array-operation model for dynamic arrays. Test counts and cross targets increase, but no requirement-ledger mappings are added, so the whole-standard requirement-coverage denominator and achieved count remain unchanged. Execution evidence is saved in `coverage/interaction-results/cross-20261030-divresize-*.json`.

The subsequent concatenation-assignment / logical-reduction extension used kirimasim `1d67d4ec852c` built from the commit checked against upstream main immediately before execution. All 142 additions agree; among all 1,086 cases, 1,080 agree and 6 array-slice assignment cases remain unsupported. `--require-pass` for these 2 models passes; among all 22 models in kirimasim, only the array-copy model remains unsatisfied.

Icarus 13.0 ran the additions 2 times, with 136 cases agreeing each time. Register oracles for the 136 verified cases; retain standard-only expected values for the remaining 6 cases. All 70 logical/reduction cases agree, and the model's `--require-pass` also passes. 66 of 72 concatenation-assignment cases agree. For 6 mixed bit/logic destinations, differences retained X/Z on the bit side or converted X/Z on the logic side to 0. For example, `test_gen_cross_concat_w33_halves_s_u_bl_ms_b_z` retained Z in the left bit term, while `test_gen_cross_concat_w64_head_bit_s_u_lb_mu_b_z` converted Z in the left logic term to 0. Reaudited each term's state conversion under 6.11.2 without changing expected values. Overall, 877 fixed-oracle cases agreed; measurements including non-oracle cases had 893 agreements and 193 known differences.

Verilator 5.052 ran 406 cases with each of seeds 1 and 73; 374 cases agreed in each run. The 82 added 4-state cases are outside execution scope; the remaining 60 agree on both seeds. The 32 known differences are unchanged from the previous run. New evidence is saved in `coverage/interaction-results/cross-20261030-concatlogic-*.json`.

The short-circuit/event-control extension used kirimasim `51cda3143aed` built from the commit checked against upstream main immediately before execution. All 156 additions agree; 1,236 of all 1,242 cases agree. 6 array-slice assignment cases remain unsupported. `--require-pass` for these 2 models passes; among all 24 models in kirimasim, only the array-copy model remains unsatisfied.

Verification sources for the additions: 80 cases using Icarus 13.0, 12 using both seeds with Verilator 5.052, and 64 based on the standard alone. All 64 event-control cases and 16 short-circuit cases agreed on Icarus, both initially and on the rerun after registration. The `--require-pass` event-control cases also pass. In the remaining 76 short-circuit cases, the right function of logical implication `->` was evaluated for a false left operand, differing in call count and side-effect retention. For example, in `test_gen_cross_sc_w1_s_ll_zero_one_l`, the result was 1, but the left/right counts were `1,1` rather than the standard-required `1,0`. Keep the expected value based on 11.4.7. All 957 fixed-oracle cases agreed; measurements including non-oracle cases had 972 agreements and 270 known differences.

Verilator 5.052 ran 454 cases with each of seeds 1 and 73; 414 cases agreed in each run. The 108 added 4-state cases are out of scope; of 48 executed cases, each run has 40 agreements and 8 known differences. All 8 cases use logical equivalence `<->`; for example, `test_gen_cross_sc_w1_s_ll_zero_one_l` had left/right counts `2,1`, and `test_gen_cross_sc_w1_s_bl_one_one_l` had `2,2`. In 11.4.7, each operand of `<->` is evaluated 1 times, so even if only the result value matches, it is not considered a pass. Including the existing 32 cases, there are 40 known differences overall.

Reaudited both simulators' differences against minimal examples and the standard without consulting implementation source. Cross-check expected values by another method, verifying operation results, call counts, side effects, and transition-table agreement. Evidence for this work is saved in `coverage/interaction-results/cross-20261030-logicedge-*.json`.

<a id="複合シフト代入の追加確認2026-10-30"></a>

### Additional compound-shift-assignment checks (2026-10-30)

All 40 additions agreed on kirimasim `56964ff9b02a` rebuilt after checking upstream main immediately before execution; the model's `--require-pass` passed. Of all 1,300 cases, 1,294 agree; the existing 6 array-slice assignment cases remain unsupported. Build versions and binary fingerprints are saved in [Verification evidence](../coverage/interaction-qualification/20261030-compound-shift.json), and all execution results in `coverage/interaction-results/cross26-*.json`.

The 33 added cases agreed on Icarus 13.0, and only these 33 cases were registered with the oracle. Of the remaining 7 differences, 6 involve X/Z shift amounts on a bit destination: the input remains instead of the unknown result required by 11.4.10 being converted to 0 on storage. The other 1 case uses a signed 65-bit array element; it became 0 without replicating the Z sign bit. Retain standard-derived expected values and keep this as a known difference. Of all 1,300 measured cases, 1,005 agreed and 295 had known differences; every case covered by the fixed oracle agreed. The status also changed for 3 bit-function cases with previously recorded variability, but oracle registrations and existing expected values for these 3 cases are unchanged.

Verilator 5.052 ran 481 2-state cases with each of seeds 1 and 73; 421 cases agreed in each run. The additions exclude 31 4-state cases; 7 of 9 2-state cases agree on both seeds. The remaining 2 cases use 33/129-bit part-selects: index functions are called 2 times instead of expected 1, and selected positions and unselected bits also change. Retained detailed output from both seeds as verification evidence. Do not exclude cases or change expected counts to 2 for this reason.

For array-element cases that agree on Icarus, also injected faults into assignments that evaluate the left-hand side 2 times, detecting differences in call counts and output. No simulator implementation source was consulted.

<a id="集合所属判定の追加確認2026-10-30"></a>

### Additional set-membership checks (2026-10-30)

The 46 additions had 19 agreements, 26 unsupported cases, and 1 disagreements on kirimasim `74fb2340925a` rebuilt after checking upstream main immediately before execution. The 26 cases are `set member of this array (not implemented yet)` when reading dynamic arrays / queues as sets. Do not exclude these cases or make their diagnostics the expected result of success. Of all 1,346 cases, 1,313 agree, 32 are unsupported, and 1 disagree; the previous 6 array-slice assignment cases also remain. This model's `--require-pass` is not yet satisfied. Save planned coverage separately from implementation passes.

The disagreement is `test_gen_cross_inside_w33_w_us_l_fixed_n3_rhs_x`. Comparing an unsigned 34-bit all-1 value against a fixed array of signed 33-bit elements gave 1 in array form and 0 when the same elements were listed individually. The expected value remains 0 because comparison under 11.4.13, 11.4.6, and 11.8.2 applies 0 extension to a common unsigned type. A minimal example using only known 2/3-bit values also confirms array=1, listed values=0, and direct `==?`=0 under both bit and logic. Inputs, expected values, and measured values, including same-sign controls, are saved in [Isolation and build evidence](../coverage/interaction-qualification/20261030-inside.json). No simulator implementation source was consulted.

On the same day, reproduced the same minimal example on kirimasim rebuilt at upstream main `fc4cc356`. An additional minimal example changing the left value shows that signed array elements are compared using sign extension instead of 0 extension. Evaluating the same comparison as a constant gives the expected value; the discrepancy is limited to runtime array-set comparisons. Added handwritten test [ `test_inside_array_set_mixed_sign_width` ](../tests/ch11/test_inside_array_set_mixed_sign_width.sv) to check this property using only 2 states. The array form also differs in another way on Verilator 5.052, recorded in [Fixed-version difference list](simulator-differences.md). Recheck evidence is [ `20261030-inside-fc4cc356.json` ](../coverage/interaction-qualification/20261030-inside-fc4cc356.json).

Icarus 13.0 does not support `inside`, so all 46 cases had known differences. Register no new Icarus oracle. Verilator 5.052 ran 11 2-state cases with each of seeds 1 and 73; 6 cases agreed in each run. Register only these 6 cases with the Verilator oracle; retain standard-derived expected values for the remaining 40 cases. The 5 differences consist of 4 cases unable to compare variable 4-state RHS, and 1 cases comparing an all-1 128-bit signed value with a 129-bit unsigned element and returning 1 rather than 0. The 35 4-state cases are outside the execution scope. See `coverage/interaction-results/cross27-*.json` for overall results and current input hashes.

For each comparison, the independent cross-check concretizes and checks every 4-valued 1/2/3-bit pattern and signedness combination. For mandatory individual-list cases that work correctly, also inject a fault comparing only the first element, detecting missed later matches. Fault-injection inputs do not count toward the ordinary suite.

<a id="範囲指定の追加確認2026-10-30"></a>

### Additional range checks (2026-10-30)

The 46 additions had 30 agreements and 16 unsupported cases, with no disagreements, on kirimasim `f303becad9ca` rebuilt after checking upstream main immediately before execution. The 16 cases involve absolute/relative tolerance ranges and report `tolerance range (not implemented yet)`. Do not exclude these cases or make their diagnostics the expected result of success. Closed intervals, reversed ranges, and `$` endpoints do not reproduce the array-set sign-extension error; signed endpoints are 0-extended against a wider unsigned left operand.

Icarus 13.0 does not support `inside`, so all 46 cases had known differences. Register no new Icarus oracle. Verilator 5.052 ran 16 2-state cases with each of seeds 1 and 73; 7 cases agreed in each run. Register only these 7 cases (5 reversed-range cases and 2 closed-interval cases) with the Verilator oracle; retain standard-derived expected values for the remaining 39 cases. The 9 differences comprise 4 cases with unsupported tolerance syntax, 3 cases where variable 4-state RHS cannot be compared with `==?`, and 2 cases with different range results when `$` is an endpoint. Even in a small example, both seeds gave results such as 0 for a value satisfying the lower bound of a range with upper bound `$`; recorded them in [Fixed-version difference list](simulator-differences.md). kirimasim has the expected value in the same example. Examples and output, build versions, and fault-injection results are saved in [Range-specification evidence](../coverage/interaction-qualification/20261030-range.json). No simulator implementation source was consulted.

Across all 1,392 cases, Icarus 13.0 had 1,008 agreeing cases and 384 known differences; on Verilator 5.052, each seed had 434 agreeing cases and 74 known differences among 508 2-state cases. Existing statuses and input hashes match the 27-model saved run. However, in Icarus, the 2 bit-function cases with previously recorded variability changed from known differences to agreement. The oracle registrations and existing expected values for these 2 cases are unchanged. See `coverage/interaction-results/cross28-*.json` for overall results.

<a id="case-insideの追加確認2026-10-30"></a>

### Additional case inside checks (2026-10-30)

On kirimasim built from the same upstream main `f303becad9ca`, the 34 additions had 25 agreements, 8 unsupported cases, and 1 disagreements. The 8 cases put a call-counting function in item 3 and report `set member with side effects (not implemented yet)`. The initial design put function calls in every row, making all cases unsupported; split item 3 into variable and function-call factors. Do not exclude function-call rows or make diagnostics the expected result of success.

The disagreement is `test_gen_cross_caseinside_w33_w_us_l_array_known_pv`. When a signed 33-bit fixed array is used as an item against an unsigned 34-bit case expression, the value obtained by 0-extending array elements goes to `default`, while sign-extended element values select the array item. The expected result is the reverse. Even in the minimal 2/3-bit example, the array item was selected by left operand `111` but not `011`; writing the same values as value items gave the expected result. Array items in case inside exhibit the same form of sign extension found in the array set of `inside`. This does not occur for value, range, or list items.

Icarus 13.0 does not support `case inside`, so all 34 cases had known differences. Verilator 5.052 ran 9 2-state cases with each of seeds 1 and 73; 4 cases agreed in each run. Register only these 4 cases with the Verilator oracle; retain standard-derived expected values for the remaining 30 cases. The 5 differences comprise 2 failures to build C++ generated for array items, 2 cases unable to compare variable 4-state RHS using `==?`, and 1 cases evaluating items after a match. The final 1 cases show the same behavior as the difference already recorded by handwritten test `test_case_inside_evaluation_order_by_qualifier`. Minimal examples, kirimasim output, and fault-injection results are saved in [case inside evidence](../coverage/interaction-qualification/20261030-case-inside.json).

Across all 1,426 cases, Icarus 13.0 had 1,007 agreeing cases and 419 known differences; on Verilator 5.052, each seed had 438 agreeing cases and 79 known differences among 517 2-state cases. Existing input hashes match the 28-model saved run; in Icarus, the 1 bit-function cases with recorded variability again became known differences. See `coverage/interaction-results/cross29-*.json` for overall results.

<a id="イベントorと項ごとのiff条件"></a>

### Event OR and per-term iff conditions

`event_or_iff@1` is an independent model of the interactions of the events OR and `iff`, which were excluded by the existing `edge_event_expression`. [Generator](../generators/interaction_iff.py) combines the following 6 factors based on 9.4.2.1, 9.4.2.3, 12.4, and 15.5.1.

- The notation of OR is `or`, with a comma.
- Trigger source: two signals, two named events, signal on the left and named event on the right.
- Signal-term detection: value change, posedge, negedge. Apply the same kind to both signal terms.
- Terms with `iff`: both, left only, right only.
- Condition: known 0/1, 1-bit X/Z, 33-bit mixtures of known values and X/Z.
- Updates: blocking assignments / `->`, NBA / `->>`.

Of 324 Cartesian-product possibilities, normalize edge specification to `change` in named-event-only rows, then select 27 cases from 252 legal possibilities. Cover all 104 pairs plus 59 combinations of trigger source × conditioned term × condition, OR notation × conditioned term × edge, and trigger source × edge × update. Retain the 4 important rows involving mixtures, commas, NBA, and 4 states as mandatory cases. No combinations are excluded for lack of support.

On each row, first change only the condition, then apply left/right rising edges, falling edges, and a same-value rewrite on the left at separate times. Simultaneously observe raw event counts on both sides and the conditional OR wakeup count. This distinguishes errors that bind `iff` to the entire expression, omit one term, wake on condition changes, or treat unchanged-value assignment as equivalent to retriggering a named event. Include known inputs in every row, avoiding tests that never wake because they use only X/Z. For a 33-bit condition, a known 1 makes it true even with X/Z present; 0 or X/Z alone does not satisfy it. Also display values immediately after signal updates to distinguish blocking assignment from NBA. Separate count observation and the next stimulus by 1 ticks; exclude the initial event at time 0 from counts. Merging simultaneous triggers, different edge kinds on the two signal terms, glitches, sequence events, and condition-expression side effects are out of scope.

Calculate expected values in an independent Python model; [Cross-check tests](../tools/test_interaction_iff.py) also compares all 252 lines using per-phase closed-form counts. [Fault injection](../coverage/interaction-qualification/20261031-event-iff.json) matched all 4 selected rows as positive controls, then detected all 7 fault types as output differences: using the wrong condition, incorrectly conditioning both terms, omitting the right term, adding the condition as an event, rejecting mixtures of known 1 and X, omitting named retriggering, and replacing NBA with an immediate update. Fault-injection results do not count as ordinary success evidence.

Fixed-version results for the new cases: Icarus 13.0 gives [27 known](../coverage/interaction-results/event-or-iff-20261031-icarus13.json) (rejects `iff` syntax); [seed 1](../coverage/interaction-results/event-or-iff-20261031-verilator5.052-seed1.json) and [seed 73](../coverage/interaction-results/event-or-iff-20261031-verilator5.052-seed73.json) on Verilator 5.052 each give 7 pass and 2 known among 9 2-state cases. Registered an oracle only for the 7 cases that agreed on both seeds. In the remaining 2 cases, triggering a named event with `->>` does not increase the raw event count, matching the existing nonblocking-event difference. The 18 4-state cases are outside Verilator's verification scope. Added the 27 new cases to the ordinary suite too, bringing the total to 9,203 cases with 2,766 generated cases. No approved requirement mappings are added; retain the requirement-coverage denominator and design/execution verification rates.

To rerun only this model, fetch and build the latest upstream, verify version agreement, and run as follows with a new output destination name.

```sh
python3 tools/interaction_coverage.py --model event_or_iff --list-tests > /tmp/event-iff-tests.txt
python3 tools/run_kirimasim.py --kirimasim BIN --json NEW.json $(cat /tmp/event-iff-tests.txt)
python3 tools/interaction_coverage.py --model event_or_iff --results NEW.json --require-pass
```

All 339 tool regression tests passed when added. Consistency checks also passed for generated artifacts, cross plans/saved runs, combination ledgers, counts, catalogs, requirement coverage, and requirement mappings. Metadata covers 9,203 cases with 0 new issues (395 known issues); `git diff --check` also succeeds. This is different from the full execution results of GitHub Check and Nightly.

<a id="キュー要素への参照と要素の寿命"></a>

### References to queue elements and element lifetime

`queue_element_reference@1` models element-reference lifetime, excluded by the existing `queue_update_capacity`. Under 7.10.3, 7.10.4, and 13.5.2, verify that method updates preserve the identity of elements not deleted, while deletion and whole-queue assignment leave references pointing to old elements. An old reference remains usable inside the retaining task, but its writes do not reach the current queue. Physical memory-reclamation timing is not verified.

[Generator](../generators/interaction_queue_ref.py) has the following 6 factors.

- Element width: 1, 32, 33, 64, 65, 129 bits.
- State type: bit, logic.
- Capacity: unbounded, bounded at 3 elements. Both initial element counts are 3.
- Retained element: first, middle, last.
- Operations: push_front, push_back, insert at index 1, pop_front, pop_back, delete the retained element, delete another element, whole-array assignment from a value copy, whole-array assignment by concatenation, and delete all.
- Written value: known, X, Z.

Select 60 cases from all 2,160 possibilities, covering all 257 pairs, 36 width × state type × value combinations, and 60 capacity × retained element × operation combinations. Retain all 60 structural combinations and 5 mandatory cases in the latter, layering type/value combinations onto the same cases. No combinations are excluded for lack of support. Dynamic/associative arrays, ref static, changes to actual-argument indices, and same-time races are out of scope.

The parent process performs its operation 1 ticks after the task retains the reference; the task writes after 2 and 4 ticks. Observe all queue elements after 1, 3, and 5 ticks, distinguishing the state immediately after an operation, the first write, and after return without races. Also display the retained value before/after writing, separately checking reads of the old element and visibility of writes to the current queue. Also retain and observe the pre-operation value copy. Cycle through 3 initial-value combinations to distinguish 3 element identities even at 1 bits. Rows containing X/Z also include known-value controls so that conversion to bit cannot hide a missing operation by making the values equal. For bounded cases, also check tail truncation by 7.10.5 and the mandatory capacity-overflow warning.

Calculate expected values with a Python model whose element objects are independent of numeric positions. In [Cross-check tests](../tools/test_interaction_queue_ref.py), also compared all 2,160 lines against a position-mapping table. Use push_back and concatenation assignment producing the same value as controls with different effects on existing-reference validity. In [Fault injection](../coverage/interaction-qualification/20261031-queue-ref.json), all 4 selected lines agreed, and all 8 error types were detected as output differences after normal termination: obtaining the wrong element, passing ref by value, treating a method as whole-array assignment, omitting the first write, incorrectly retaining references across whole-array assignment, leaking from a deleted reference into the current queue, omitting capacity limits, and converting logic input to bit. Fault injection does not count toward ordinary success evidence or suite counts.

Icarus 13.0 does not support ref arguments, giving [All 60 cases are known](../coverage/interaction-results/queue-ref-20261031-icarus13.json). For each of [seed 1](../coverage/interaction-results/queue-ref-20261031-verilator5.052-seed1.json) and [seed 73](../coverage/interaction-results/queue-ref-20261031-verilator5.052-seed73.json) in Verilator 5.052, among 36 2-state cases, 19 passed and 17 had known results. Registered an oracle only for the 19 cases that agreed. The 24 4-state cases are outside Verilator's verification scope. Differences comprise 9 reference-value / write-visibility cases, 2 size cases after bounded insert, 1 cases without output, and 5 cases with matching output but missing mandatory warnings. The 1 cases with no output also terminated due to SIGBUS on both seeds in [Black-box recheck](../coverage/interaction-qualification/20261031-queue-ref-verilator.json). The cause was not investigated through implementation source. See [Fixed-version difference list](simulator-differences.md) for details.

Added the 60 new cases to the ordinary suite too, bringing the total to 9,263 cases with 2,826 generated cases. No new requirement mappings are registered; the requirement-coverage denominator and design/execution verification rates are retained. To rerun only the models, fetch and build the latest upstream, verify version agreement, and run as follows with a new output destination name.

```sh
python3 tools/interaction_coverage.py --model queue_element_reference --list-tests > /tmp/qref-tests.txt
python3 tools/run_kirimasim.py --kirimasim BIN --json NEW.json $(cat /tmp/qref-tests.txt)
python3 tools/interaction_coverage.py --model queue_element_reference --results NEW.json --require-pass
```

All 344 tool regression tests passed when added. Consistency checks also passed for generated artifacts, cross plans/saved runs, combination ledgers, counts, catalogs, requirement coverage, and requirement mappings. Metadata covers 9,263 cases with 0 new issues (395 known issues); `git diff --check` also succeeds. This is different from the full execution results of GitHub Check and Nightly.

<a id="引数の結合と呼出し後の添字変更"></a>

### Argument binding and index changes after calls

`argument_binding_index@1` models changes to indices after a call, which the existing `task_argument_visibility` excluded. Based on 13.5, 13.5.1, and 13.5.2, verify the difference between an input copy and ref / const ref, which share the original variable. const ref cannot be overwritten by the task, but changes by the caller are reflected in the read. This work targets those explicit rules; evaluation timing of the output/inout return destination is out of scope.

[Generator](../generators/interaction_binding.py) has the following 6 factors.

- Element width: 1, 32, 33, 64, 65, 129 bits.
- State type: bit, logic.
- Values later written by the caller: known, X, Z.
- Argument passing: input, ref, const ref.
- Actual-argument destination: fixed array `[2:4]`, dynamic array of 3 elements, queue of 3 elements.
- Index after call: unchanged, adjacent-element index, -1.

Select 36 cases from all 972 possibilities, covering all 162 pairs, 36 width × state type × value combinations, and 27 passing method × destination × index combinations, while retaining 5 mandatory cases. The index becomes -1 only after passing a valid first element. Correct behavior continues using the originally bound element rather than reading the array through the changed index. Invalid access is not treated as a normal expected result. Resizing while a reference is retained, argument-evaluation side effects, NBA, and output/inout are out of scope.

After 1 ticks, the parent process changes the index, original element, and adjacent element. When the task reads after 2 tick, input observes the initial value, while ref and const ref observe the new value of the original element. input and ref write known markers; const ref only reads. After 3 ticks, the parent observes all 3 elements and writes a different value into the original element. On reading after 4 ticks, ref and const ref observe that value, while input retains its own copy. Observe all elements again 5 ticks after return to distinguish incorrect copy-out and corruption of adjacent elements. Avoid races in stimulus and observation timing; cycle through 3 initial-value combinations to distinguish elements even at 1 bits. Include known-value controls in every X/Z row, separately checking bit / logic conversion at parent writes and determination of the reference target.

Calculate expected values in an independent Python model; [Cross-check tests](../tools/test_interaction_binding.py) compares all 972 lines using shared element objects and independent input copies. [Fault injection](../coverage/interaction-qualification/20261031-binding.json) matched 4 selected positive controls and detected all 8 fault types as output differences: selecting the wrong element, passing ref by value, omitting ref writes, passing const ref by value, passing input by reference, omitting a late parent update, changing logic to bit, and corrupting guard elements. Syntax errors, unsupported cases, and abnormal termination do not count as detection; fault injection does not count as ordinary success evidence.

Fixed [Icarus 13.0](../coverage/interaction-results/binding-20261031-icarus13.json) had 18 pass and 18 known. The 18 input cases succeed; ref and const ref are unsupported. [seed 1](../coverage/interaction-results/binding-20261031-verilator5.052-seed1.json) and [seed 73](../coverage/interaction-results/binding-20261031-verilator5.052-seed73.json) on Verilator 5.052 each had 8 pass and 4 known among 12 2-state cases. The differences comprise 2 cases that read the parent's value before the change and 2 cases that reject legal const ref actual arguments with type diagnostics. The 24 4-state cases are outside Verilator's verification scope. Registered the oracle only for the 18 cases of Icarus and the 8 cases of Verilator that agreed on both seeds. 21 cases, excluding 5 duplicates, have fixed oracles; the remaining 15 retain standard-derived expected values.

The ordinary suite increases by 36 to 9,299 cases, with 2,862 generated cases. No new requirement mappings are registered; the requirement-coverage denominator and design/execution verification rates are retained. After fetching/building the latest upstream and checking the version, rerun an individual model as follows. Specify a new destination without overwriting historical evidence.

```sh
python3 tools/interaction_coverage.py --model argument_binding_index --list-tests > /tmp/bind-tests.txt
python3 tools/run_kirimasim.py --kirimasim BIN --json NEW.json $(cat /tmp/bind-tests.txt)
python3 tools/interaction_coverage.py --model argument_binding_index --results NEW.json --require-pass
```

All 349 tool regression tests passed when added. Consistency checks also passed for generated artifacts, cross plans/saved runs, combination ledgers, counts, catalogs, requirement coverage, and requirement mappings. Metadata covers 9,299 cases with 0 new issues (395 known issues); `git diff --check` also succeeds. This is different from the full execution results of GitHub Check and Nightly.

<a id="クロッキング入力のサンプリングと参照経路"></a>

### Clocking-input sampling and reference paths

`clocking_input_sampling` is a model that combines the input sampling of the 14 chapter with the update method, state type, and reference path. Added Clause 4 × Clause 14 and Clause 14 × Clause 25, prioritized in triage, plus Clause 6 × Clause 14 and Clause 10 × Clause 14 to the model table. This is the first finite cross model focused on Chapter 14. Existing individual clocking tests are retained too.

Under 14.4 and 14.13 of IEEE 1800-2023, `#1step` samples the value immediately before the clock, while `#0` samples the value in the Observed region. Under 14.10 and 14.13, the observer waits on `@(cb)` rather than the raw clock edge to avoid racing clockvar updates. Check blocking/NBA in 10.4.1 and 10.4.2 together with state-type conversion in 6.11.2 and modports / virtual interfaces in 25.5.5 and 25.9.1.

- Width: 1, 32, 33, 64, 65, 129 bits.
- Destination state type: bit / logic.
- Input value: known / containing X / containing Z.
- Observation path: inside module, through interface, through virtual modport.
- Input skew: `#1step` / `#0`.
- Clock: posedge / negedge.
- Update method: blocking / NBA.

Select 36 cases from all 864 possibilities, covering all 165 factor pairs. Priority 3-factor groups total 72 combinations: 36 width × state type × value, 12 reference path × skew × edge, 12 reference path × skew × update method, and 12 state type × value × skew; retain 5 mandatory cases. Do not reduce constraints or denominators because of unsupported cases.

Use 3 background combinations per case, inverting all bits through known-value updates. Keep known-value controls in the X/Z rows too; for wide values, put unknowns at the edges and center and known values elsewhere. Prepare stimuli 2 ticks before the edge; the module updater writes at the edge. The observer saves sampled/live values and cumulative wakeup counts at `@(cb)`, then displays them with the actual destination after 1 ticks. This distinguishes old and updated values, state conversion to bit, missing updates, and missing wakeups.

Calculate expected values with the generator's standard model; [Cross-check tests](../tools/test_interaction_clocking.py) compares all 864 lines using a separate event-order model advancing Active→NBA→Observed. Expected values are not generated from simulator output. Program-derived clocks, output skews, inout, iff, multiple clocks, selection among multiple interface instances, and multiple edges within one time are outside this model's scope.

On [Saved runs of all 33 models](../coverage/interaction-results/cross33-kirimasim-55ce80b9.json) rebuilt after checking latest upstream `55ce80b9d5bc`, 24 of 36 new cases agreed and 12 were unsupported. There are no disagreements. Passing results verify 118/165 pairs, 38/72 combinations of 3 factors, and 2/5 mandatory cases. Unsupported diagnostics concern input skew `#0` and virtual-modport types. [Build evidence](../coverage/interaction-qualification/20261031-clocking-build.json) records upstream/source commits, binary hashes before/after execution, and comparisons with the previous 1,549 cases. This does not claim PASS for every selected case or satisfaction of all target combinations in the new model.

Fixed [Icarus 13.0](../coverage/interaction-results/clocking-20261031-icarus13.json) had 36 known and did not accept clocking syntax. No oracle is registered. For [seed 1](../coverage/interaction-results/clocking-20261031-verilator5.052-seed1.json) and [seed 73](../coverage/interaction-results/clocking-20261031-verilator5.052-seed73.json) in Verilator 5.052, all 12 cases without X/Z matched for both. Register a fixed oracle only for these 12 cases, preserving existing oracle registrations. The 24 cases containing X/Z are outside the verification scope of fixed Verilator.

[Fault injection](../coverage/interaction-qualification/20261031-clocking.json) was performed only for direct references / interface access to `#1step` supported by kirimasim. All 3 positive controls agreed, and all 9 error types were detected through output differences: confusing live and sampled values, omitting writes, writing on the wrong edge, omitting wakeups, fixing samples at 0, truncating upper bits, converting logic to bit, converting bit to logic, and observing the wrong live-value target. Syntax errors and unsupported cases do not count as detection or establish detection capability for unsupported `#0` or virtual paths.

The ordinary suite increases by 36 to 9,335 cases, with 2,898 generated cases. The short selection has 1,585 cases. No new requirement mappings are registered; retain the requirement-coverage denominator and design/execution verification rates. Registered chapter pairs increase from 37 to 41, but the new model has not achieved PASS for its full selection, so the added 4 pairs have 0 models with PASS on every selected case.

Fetch and rebuild the latest upstream, check the binary version, then rerun as follows. Use a new output path that does not overwrite earlier evidence.

```sh
python3 tools/interaction_coverage.py --model clocking_input_sampling --list-tests > /tmp/clock-tests.txt
python3 tools/run_kirimasim.py --kirimasim BIN --json NEW.json $(cat /tmp/clock-tests.txt)
python3 tools/interaction_coverage.py --model clocking_input_sampling --results NEW.json --require-pass
```

`--require-pass` fails for this saved run because unsupported cases remain. Distinguish this scope from the full-run results of Check and Nightly. At addition, passed 378 tool regression tests and consistency checks of generated artifacts, saved runs, chapter-pair CSV, the triage registry, counts, catalogs, requirement matching, and requirement coverage. Metadata covers 9,335 cases with 0 new issues (395 known issues); `git diff --check` also succeeds. Fault injection does not count toward ordinary-suite counts or success evidence.

<a id="アサーションのサンプル値とactionのライブ値"></a>

### Assertion sampled values and live values in actions

`assertion_sample_visibility` is the first finite cross model focused on Chapter 16. Registered Chapter 4 × Chapter 16, Chapter 6 × Chapter 16, Chapter 10 × Chapter 16, Chapter 11 × Chapter 16, and Chapter 16 × Chapter 25. The rationale is 16.5.1, which samples static variables in Preponed; 16.6, which treats Boolean 0/X/Z as false; 16.9.3 of `$sampled`; and 16.14.1, which executes pass/fail actions in Reactive.

- Width: 1, 32, 33, 64, 65, 129 bits. State type: bit / logic. Input value: known / X / Z.
- Expressions: reduction OR, logical equality `==` with 0, and case equality `===` with 0.
- Clock: posedge / negedge. Update method: blocking / NBA.
- Update time: 1 ticks before the edge / simultaneous with edge / 1 ticks after. Placement: module / interface.

Select 36 cases from all 2,592 possibilities, retaining 225 pairs, 96 priority 3-factor combinations, and 7 mandatory cases. Priority groups comprise 36 combinations of width × state type × value; 18 combinations of expression × state type × value; 12 combinations of update time × edge × update method; 12 combinations of placement × update time × update method; 18 combinations of placement × expression × update time.

Known-value controls in each case include inputs producing both pass and fail. In the X/Z row, the variable is changed from unknown to known and vice versa. In both actions, save cumulative counts, `$sampled(data)`, `$sampled(式)`, and the current data, then display them with data after 2 ticks. Use single-cycle Boolean properties without implication-induced vacuous successes. Distinguish updates before, simultaneous with, and after an edge: before, sample/action/final values agree; simultaneous, only the sample is old; after, both sample and action values are old. Also distinguish logical-equivalence result X and case-equality result 0 as observations of 1-bit expressions.

Calculate expected values with the generator's standard model and compare all 2,592 lines using [Independent event-order model](../tools/test_interaction_assertion_wait.py). Programs, clocking variables, automatic variables, disable iff, assertion control, time arithmetic, and history functions are out of scope.

[Saved run of kirimasim when added](../coverage/interaction-results/cross35-kirimasim-3a31b060.json) has 36 unsupported; the diagnostic is `statement 'ConcurrentAssertion' (not implemented yet)`. Do not exclude these from the plan; record the successful-combination count as 0. [Icarus 13.0](../coverage/interaction-results/assertion-wait-20261031-icarus13.json) also had 36 known. In [seed 1](../coverage/interaction-results/assertion-wait-20261031-verilator5.052-seed1.json) and [seed 73](../coverage/interaction-results/assertion-wait-20261031-verilator5.052-seed73.json) on Verilator 5.052, the 12 known-value cases comprise 11 pass and 1 known. Registered an oracle only for the 11 cases that agreed on both seeds. The 24 X/Z cases are outside the verification scope of fixed Verilator.

The existing SVA reference evaluator M4 also discovers this model's 25 cases with only standard-derived expected values, but the form saving values in an action for later display is outside M4's approved adapter scope. Register source hashes and reasons in [Pending ledger](../tools/sva_reference/fixtures/m4_deferred.json); [Check the range of M4](../tools/sva_reference/M4_REVIEW.md) distinguishes 7 existing agreeing tests from 42 pending tests. This cross is not counted as a M4 success or an additional formal proof.

The difference occurs on simultaneous updates involving NBA of `test_gen_cross_assert_1_bit_known_reduce_or_posedge_nba_edge_module`. The first action expects `sampled=0 at_action=1 final=1`, but the fixed version outputs `sampled=0 at_action=0 final=1`. Expected values are unchanged.

[Fault injection](../coverage/interaction-qualification/20261031-assertion.json) uses only known-value updates before/after edges that agree on fixed Verilator; the 2 positive controls agreed. Detected 8 error types through output differences: always-pass/fail decisions, missing pass/fail counts, fixing samples/expressions at 0, replacing live values with future inputs, and omitting later writes. Also verify that compilation, execution, and normalization all return exit code 0; abnormal termination, unsupported cases, and syntax errors do not count as detection. Do not interpret this check as establishing detection capability for updates simultaneous with edges or for 4-state behavior.

<a id="コンテナ変更とwaitの起床"></a>

### Container changes and wait wakeups

`container_wait_visibility` combines dynamic-array/queue changes from Chapter 7 with level-sensitive waits from 9.4.3. The new pair is Clause 7 × Clause 9. Also map Chapter 6 × Chapter 7 for types/storage, Chapter 6 × Chapter 9 for conversions/conditions, and Chapter 7 × Chapter 11 for element case equality / compound conditions.

- Width/state type/value: 1, 32, 33, 64, 65, 129 bits; bit / logic; known / X / Z.
- Container: dynamic array / queue. Changes: create, grow, shrink, delete, replace the whole container at the same size.
- Wait condition: matching size, case equality of first element and marker, both.
- Wait start: wait while condition is false / proceed after the change when already true.

Use only size conditions for creation/deletion involving empty containers; keep containers nonempty in rows reading the first element. Use same-size replacement only in rows with element conditions, with the pre-change condition false. These constraints avoid invalid indices and conditions already true before the change on waiting lines; they do not exclude unsupported cases. Select 36 cases from 1,440 legal possibilities, retaining 214 pairs, 88 combinations of 3 factors, and 6 mandatory cases. Priority groups comprise 36 combinations of width × state type × value; 20 combinations of container × change × condition; 20 combinations of change × condition × wait start; 12 combinations of container × condition × wait start.

Each case has 3 known-value control combinations, plus unknown markers in X/Z rows. Replace dynamic arrays using new initialized from a prepared array; change queues through push_front / pop_front / delete / whole-queue assignment. Change only the other container at tick +1 and verify no early wakeup at tick +2. The target changes at tick +3; final observation is at tick +4. Rows already true proceed at wait-start tick 0. The waiting side records elapsed time and value copies of contents, allowing checks of wakeup time and all captured elements. After observation, cancel children with `disable fork` so missing notifications are detected as output differences rather than timeouts. This test does not measure how often the condition is reevaluated internally.

[Cross-check](../tools/test_interaction_assertion_wait.py) compared all 1,440 lines using list insert/pop/clear/replacement operations and event times. Element conditions wake even for replacement without a size change; deletion to empty waits for size 0. Associative arrays, invalid indices, reference arguments, and multiple same-time change sources are out of scope.

[kirimasim when added](../coverage/interaction-results/cross35-kirimasim-3a31b060.json) had 36 pass, successfully satisfying all 214 pairs, 88 combinations of 3 factors, and 6 mandatory cases. Fixed [Icarus 13.0](../coverage/interaction-results/assertion-wait-20261031-icarus13.json) had 26 pass and 10 known. Differences include failure to wake after resizing and failure to print the expected lines. All 12 known-value cases in [seed 1](../coverage/interaction-results/assertion-wait-20261031-verilator5.052-seed1.json) and [seed 73](../coverage/interaction-results/assertion-wait-20261031-verilator5.052-seed73.json) on Verilator 5.052 agreed. 29 distinct cases have fixed oracles; the remaining 7 retain standard-derived expected values.

[Fault injection](../coverage/interaction-qualification/20261031-wait.json) matched 2 positive controls and detected 9 fault types as output differences: making the condition always false/true, waiting on a different container, updating a different container, omitting captures or counts, replacing case equality with logical equality, changing logic to bit, and using the wrong initialization expression. Apply comparison-operator faults across all phases so they affect X/Z observations too; save replacement counts as evidence. Check compilation, execution, and normalization exit codes; abnormal termination and unsupported cases do not count as detection. Fault injection does not count toward ordinary counts or success evidence.

With these 2 models, the normal suite increases by 72 cases to 9,407; there are 2,970 generated cases and 1,657 in the short-run selection. [Build evidence](../coverage/interaction-qualification/20261031-assertion-wait-build.json) stores the latest upstream `3a31b060c158`, binary hashes before and after execution, and comparisons of the previous 1,585 cases. No new requirement mappings are registered; the requirement-coverage denominator and design/execution verification rates are retained. Registered chapter pairs increase from 41 to 47. The added 5 assertion chapter pairs remain unsupported, so their all-selected-case PASS model count is 0; for container waits, Clause 7 × Clause 9 has an all-selected-case PASS model count of 1. At addition, passed 395 tool regression tests and consistency checks of generated artifacts, saved runs, chapter-pair CSV, the triage registry, counts, catalogs, requirement matching, and requirement coverage. Metadata covers 9,407 cases with 0 new issues (395 known issues). Rechecking M4 also gives 7 match and 42 deferred; retain checks that expected values are not read until all output is generated and that changes to pending sources are detected. Treat these local checks separately from full-run results of GitHub Check and Nightly.

<a id="クラスメソッドの呼出し先と再帰引数"></a>

### Class-method callees and recursive arguments

`class_method_reference` combines instances and method calls from Chapter 8 with argument passing and recursive calls from Chapter 13. In addition to Chapter 8 × Chapter 13, registered Chapter 6 × Chapter 8 for property types and stored values. Move from E classification based on ordinary existing tests to M classification based on a finite model. This round's Chapter 6 × Chapter 8 scope covers storage and retrieval of bit / logic; it does not imply comprehensive dynamic-cast coverage.

- Width: 1, 32, 33, 64, 65, 129 bits. State type: bit / logic. Value: known / X / Z.
- Call path: direct derived handle, virtual through base handle, nonvirtual through base handle.
- Method: function / task. Arguments: input / ref / const ref. Recursion depth: 0 / 1 / 3.

Select 36 cases from all 1,944 possibilities, retaining 202 pairs, 99 priority 3-factor combinations, and 6 mandatory cases. Priority groups comprise 36 combinations of width × state type × value; 18 combinations of call path × method × argument; 18 combinations of method × argument × depth; 27 combinations of call path × argument × depth. There are no exclusions for lack of support. Use the same typedef for formal and actual arguments so reference-argument types match. The rationale is 8.6 for automatic lifetime of class methods, 8.20 for callee selection, and 13.5.1 / 13.5.2 for value copies and references.

Owner ID creates derived instances 2 and 5 and calls them in A→B→A order. Declare the property only once in the base class, avoiding distinct variables introduced by hiding. Direct and virtual calls execute the derived body; nonvirtual calls through a base handle execute the base body. Give each body distinct identifiers and visit counts to observe switching to the wrong body or instance.

Each recursive frame updates the receiver's payload before displaying formal arguments. input sees the call-time copy; ref/const ref sees the same property after its update. Next, except for const ref, write depth-specific known markers into formals and pass those formals to the next recursive call. At return, distinguish input's per-frame markers, ref's deepest write, and const ref's deepest property update. Change the value through a property of the same object without writing through const ref. Display entry/exit formals and payloads, return values including depth, and both instances' payloads, guards, and visit counts. Give every case 3 known-value background combinations; add unknown initial values and intermediate updates in X/Z rows. Also check X/Z→0 conversion in bit, both for the initial state and for updates within a frame.

Calculate expected values with [Generator closed-form model](../generators/interaction_class_method.py). [Independent recursive-cell model](../tools/test_interaction_class_method.py) uses private cells for input and shared cells for ref/const ref, and all 1,944 lines were compared. The task also consumes no time. Concurrent calls, arrays, timing controls, super calls, and evaluation of the output/inout return destination are separate scopes.

All 36 new cases on [Saved run of kirimasim when added](../coverage/interaction-results/cross36-kirimasim-3a31b060.json) were unsupported due to `type 'leaf_t' (not implemented yet)`. The successful pairs, 3-factor combinations, and mandatory cases at that point are recorded as 0. The subsequent [Full regression on kirimasim `4fb5f6b1aec8`](../coverage/interaction-results/cross53-kirimasim-4fb5f6b1.json) improved to 18 pass and 18 unsupported. Do not rewrite initial evidence; distinguish each run. Fixed version [Icarus 13.0](../coverage/interaction-results/class-method-20261031-icarus13.json) has 15 pass and 21 known. In addition to unsupported reference arguments, 3 virtual cases differ by calling the base body instead of the derived body. All 12 known-value cases in [seed 1](../coverage/interaction-results/class-method-20261031-verilator5.052-seed1.json) and [seed 73](../coverage/interaction-results/class-method-20261031-verilator5.052-seed73.json) on Verilator 5.052 agreed. The 24 X/Z cases are outside the scope of fixed Verilator. 24 distinct cases have fixed oracles; the remaining 12 retain standard-derived expected values.

In [Fault injection](../coverage/interaction-qualification/20261031-class-method.json), all positive controls agreed: 4 known-value cases on fixed Verilator and 1 X-input cases on fixed Icarus. Output differences detected 13 fault kinds: confusing input/ref/const ref, missing formal-argument or property updates, missing recursion/depth/visit counts, guard corruption, reversing virtual/nonvirtual dispatch, using the wrong receiver, and converting logic to bit. Count detection only when compilation, execution, and normalization all terminate normally; exclude unsupported cases and abnormal termination. This fault injection does not guarantee detection capability for X/Z references or virtual access. This also does not count toward ordinary test counts or success evidence.

These additions increase the ordinary suite by 36 to 9,443 cases; generation has 3,006 cases, and the short selection has 1,693. The [Build evidence](../coverage/interaction-qualification/20261031-class-method-build.json) stored the latest upstream commit, the unchanged state of the source, the binary hash before and after execution, and the input and output comparison of the previous 1,657. Register no new requirement mappings; retain the requirement-coverage denominator and verification rate. Registered chapter pairs increase from 47 to 49, while the number of models with their full selection PASS remains 30. As saved runs increased, target coverage was changed to be calculated once per model within each 1 aggregation and shared across runs. Also verified that all plans for the existing 35 models and aggregates for 85 saved runs remain identical. After correction, passed 406 tool regression tests and consistency checks of generated artifacts, saved runs, chapter-pair CSV, the triage registry, counts, catalogs, requirement matching, and requirement coverage. Metadata covers 9,443 cases with 0 new issues (395 known issues). These are local check results, treated separately from full runs of GitHub Check and Nightly.

<a id="ループからの関数returnと状態の共有範囲"></a>

### Function returns from loops and state-sharing scope

`function_loop_return` combines for/while/repeat loops from Chapter 12 with return from functions from Chapter 13. Also registered Chapter 13 × Chapter 26, placing the same function in an instance and a package to check state-update targets and sharing scope. Both 2 chapter pairs move from E, supported by existing ordinary tests, to M, supported by finite models.

- Width: 1, 32, 33, 64, 65, 129 bits. State type: bit / logic. Input value: known / X / Z.
- Loop: for / while / repeat. Stop position: first / middle / last / no match.
- Function placement: inside instance / inside package.

Select 36 cases from all 864 possibilities, retaining 161 pairs, 120 priority 3-factor combinations, and 6 mandatory cases. Priority groups comprise 36 combinations of width × state type × value; 24 combinations of loop × stop position × placement; 24 combinations of state type × value × stop position; 36 combinations of loop × value × stop position. At width 1, first/middle/last coincide, but retain them as legal boundary cases. There are no exclusions for lack of support. The rationale is 12.7.1, 12.7.2, and 12.7.4 for loops; 12.8 and 13.4.1 for early return; 26.3 for package-name references; and 6.11.2 for state types.

The function scans inputs in order from LSB and returns the whole input at the first position satisfying `data[i] !== 1'b0`. If none matches, scan the full width and return the alternative value. Because case inequality is used, X/Z in logic also causes stopping. When conversion on entry to bit changes X/Z to 0, scanning either reaches the later known 1 or proceeds to the end. Give each row 3 known-value control combinations; add 3 combinations of unknown stopping candidates and alternative values in X/Z rows.

Observe scan counts, the sum of `i+1`, stop indices, end-reach counts, return values, and execution counts of statements immediately after each return. Beyond matching final values, distinguish skipped intermediate scanning and erroneous continuation after return. Swap first/middle/last left-to-right between A and B, calling 2 instances in A→B→A order. Instance functions update their respective states; the package function accumulates 3 calls into shared state. For package rows, initialize same-named caller variables with distinct identifying values and also verify that they retain those values. Display every counter, call count, and unchanged guard value in both instances and the package each time. Observe within the same initial process, printing 1 lines each with `$write` and `$display`.

Calculate expected values with [Generator model of the first non-0 position and arithmetic sum](../generators/interaction_return.py) and compare all 864 lines using [Independent sequential-scan model](../tools/test_interaction_return.py). Recursion, break/continue, concurrent calls, timing controls, and return-value conversion between different widths are out of scope.

All 36 additions on [Saved run of kirimasim when added](../coverage/interaction-results/cross37-kirimasim-3a31b060.json) returned PASS, successfully satisfying all 161 pairs, 120 combinations of 3 factors, and 6 mandatory cases. The 36 cases containing X/Z also agreed on fixed version [Icarus 13.0](../coverage/interaction-results/return-20261031-icarus13.json). For [seed 1](../coverage/interaction-results/return-20261031-verilator5.052-seed1.json) and [seed 73](../coverage/interaction-results/return-20261031-verilator5.052-seed73.json) in Verilator 5.052, all 12 known-value cases matched. The 24 X/Z cases are outside the verification scope of fixed Verilator.

[Fault injection](../coverage/interaction-qualification/20261031-return.json) uses runtime kirimasim; 3 positive controls matched, covering an early return with 1 bits, a full package traversal with 129-bit logic Z, and a midway return with 65-bit logic X. Output differences detected 13 fault kinds: missing early return; incorrect return value; missing or incorrect scan counts, index weights, call counts, or end-of-scan counts; calling another instance; execution after return; updating the caller's same-named variable; guard corruption; replacing case inequality with logical inequality; and converting logic to bit. Count detection only when compilation, execution, and normalization all terminate normally. Fault injection does not count toward ordinary test counts or success evidence.

These additions increase the ordinary suite by 36 to 9,479 cases; generation has 3,042 cases, and the short selection has 1,729. The [Build evidence](../coverage/interaction-qualification/20261031-return-build.json) stored the latest upstream commit and version, unchanged source, binary hash before and after execution, and the input and result comparison of the previous 1,693. Chapter pairs increase from 49 to 51. Map all 36 cases to Chapter 12 × Chapter 13 and 12 package cases to Chapter 13 × Chapter 26; for both, verify that all 36 model cases returned PASS in one run. This model addition registers no new requirement mappings and does not change the requirement-coverage denominator. Before committing, incorporated upstream main's full Ghost results `80f19e33` and regenerated requirement-coverage aggregates. The update to saved-evidence execution verification coverage 77.33% (9,510/12,298) comes from these Ghost results, not additional requirement mappings for new cross models. Passed 413 tool regression tests and consistency checks of generated artifacts, saved runs, chapter-pair CSV, the triage registry, counts, catalogs, requirement matching, and requirement coverage. Metadata covers 9,479 cases with 0 new issues (395 known issues). These are local check results, treated separately from full runs of GitHub Check and Nightly.

<a id="ループ代入の更新順序とインスタンスの独立性"></a>

### Loop-assignment update order and instance independence

`loop_assignment_order` checks the assignment order of the 10 chapter when writing multiple times from the loop of the 12 chapter to the same storage. Chapter 10 × Chapter 25 also checks assignments to static variables / fixed-array elements inside interfaces and independence across instances. Both 2 chapter pairs move from E, supported by existing boundary tests, to M, supported by finite models.

- Width: 1, 32, 33, 64, 65, 129 bits. State type: bit / logic. Input value: known / X / Z.
- Loop: for / while / repeat. Number of iterations: 2 / 3 / 5.
- Destination: scalar / same fixed-array element / cycle through fixed-array elements.
- Assignment method: blocking assignment / NBA. Destination location: module / interface.

Select 36 cases from all 3,888 possibilities, retaining 246 pairs, 111 priority 3-factor combinations, and 6 mandatory cases. Priority groups comprise 36 combinations of width × state type × value; 27 combinations of loop × iteration count × destination; 18 combinations of iteration count × destination × assignment method; 12 combinations of placement × destination × assignment method; 18 combinations of loop × iteration count × assignment method. There are no exclusions for lack of support. The rationale is 10.4.1 and 10.4.2 for assignments; 12.7.1, 12.7.2, and 12.7.4 for loops; and 25.3 for declarations inside interfaces.

Create 2 modules or interfaces and call their automatic tasks from the same process in A→B→A order. Each iteration assigns XOR of the current stored value and typed mask back to the same location. With blocking assignment, the next iteration reads the updated value; with NBA, calculate and schedule each right-hand side from the pre-update values. If NBA overlap at the same location, the last scheduled value takes effect. Use fixed array `[2:4]` starting at non-0; use index 2 for the same-element case and `2+(i%3)` when cycling. Across 5 passes, write some elements again, creating conditions beyond assignments to distinct elements.

Each iteration displays the caller, call count, iteration number, index, old value, raw mask, and converted mask. Rewrite the original mask variable to 0 immediately after each task returns. The scheduled value and static destination must remain available after the task-local right-hand side and index cease to exist. Observe in Active and again after 1 ticks to check all elements, call counts, assignment counts, and unchanged guard values in both instances. Distinguish not only intermediate values but also the final surviving write and leakage into another instance.

Give every row 3 known-value background combinations; add 3 masks containing unknowns in X/Z rows. Convert the mask to the destination's state type before applying XOR. X/Z in logic becomes X through XOR and propagates to later iterations with blocking assignment. In bit, the mask's X/Z values are first converted to 0. In NBA, a previously scheduled X does not change the old value used by a later right-hand side.

Calculate expected values with [Generator model of intermediate updates and final scheduled values per destination](../generators/interaction_loop_nba.py) and compare all 3,888 lines using [Independent model using integral values, unknown-bit masks, and FIFO queues](../tools/test_interaction_loop_nba.py). The left-hand side of NBA is a static scalar or fixed array element, and NBA to automatic variables or dynamic array elements is not created. Multiple-process races, delayed NBA, modports, and direct NBA driving from procedures outside the interface are out of scope. Retain existing [NBA tests on interface arrays from inside and outside](../tests/ch10/test_nba_interface_array_element.sv).

All 36 additions on [Saved run of kirimasim when added](../coverage/interaction-results/cross38-kirimasim-95eefebe.json) returned PASS, successfully satisfying all 246 pairs, 111 combinations of 3 factors, and 6 mandatory cases. The 36 cases containing X/Z also agreed on fixed version [Icarus 13.0](../coverage/interaction-results/loop-nba-20261031-icarus13.json). For [seed 1](../coverage/interaction-results/loop-nba-20261031-verilator5.052-seed1.json) and [seed 73](../coverage/interaction-results/loop-nba-20261031-verilator5.052-seed73.json) in Verilator 5.052, all 12 known-value cases matched. The 24 X/Z cases are outside the verification scope of fixed Verilator.

[Fault injection](../coverage/interaction-qualification/20261031-loop-nba.json) uses a 1-bit module-local scalar NBA, blocking assignment to the same interface element with 65-bit logic X, and cyclic NBA inside an interface with 129-bit logic Z. 3 positive controls matched, and output differences detected 13 fault types: immediate NBA updates, delayed blocking assignments, missing dependence on the original stored value, reuse of the first mask, changing logic to bit, fixed/reversed indices, omitting the final iteration, calling another instance, omitting assignment/call counts, guard corruption, and changing XOR to OR. Count detection only when compilation, execution, and normalization all terminate normally; do not add it to ordinary test counts or success evidence.

These additions increase the ordinary suite by 36 to 9,515 cases; generation has 3,078 cases, and the short selection has 1,765. The [Build evidence](../coverage/interaction-qualification/20261031-loop-nba-build.json) stored the latest upstream commit and version, unchanged source, binary hash before and after execution, and the input and result comparison of the previous 1,729. Chapter pairs increase from 51 to 53. Map all 36 cases to Chapter 10 × Chapter 12 and 7 interface cases to Chapter 10 × Chapter 25; for both, verify that all 36 model cases returned PASS in one run. No new requirement mappings are registered; the requirement-coverage denominator and verification rate are retained. Passed 420 tool regression tests and consistency checks of generated artifacts, saved runs, chapter-pair CSV, the triage registry, counts, catalogs, requirement matching, and requirement coverage. Metadata covers 9,515 cases with 0 new issues (395 known issues). Also verified that all plans for the existing 37 models and aggregates for 93 saved runs remain identical. These are local check results, treated separately from full runs of GitHub Check and Nightly.

<a id="暗黙の感度リストとラッチ保持"></a>

### Inferred sensitivity lists and latch retention

For always_comb / always_latch in 9.2.2.2 and 9.2.2.3, `implicit_process_visibility` combines direct variable reads and reads inside functions, true/false enables, state types, and module/interface placement. The new pairs are Clause 9 × Clause 25 and Clause 13 × Clause 25. Clause 9 × Clause 13 is also mapped because function reads contribute to implicit sensitivity.

- Width: 1, 32, 33, 64, 65, 129 bits. State type: bit / logic. Input value: known / X / Z.
- Process: always_comb / always_latch. Read: directly in the expression / argument-free automatic function.
- Placement: module / interface. Enable: 0 / 1 / X / Z.
- Disabled output: comb assigns 0 / 1; latch retains state. Do not create inapplicable combinations.

Select 36 cases from 1,728 legal possibilities, retaining 242 pairs, 96 priority 3-factor combinations, and 6 mandatory cases. Priority groups comprise 36 combinations of width × state type × value; 8 combinations of placement × read method × process; 12 combinations of process × enable × disabled output; 24 combinations of state type × value × enable; 16 combinations of read method × enable × process. This model restricts comb to circuits assigning in every branch and latch to circuits retaining state when disabled, excluding inapplicable idle values from the factor domain. These exclusions are not due to unsupported simulator features.

Initialize data = 0, mask = 1, and en = 1 at declaration in each instance, then observe outputs and evaluation counts after the first 1 tick. Even without input changes after initialization, the process must start once at time 0 and output XOR result 1. Then, across 1 rounds, change only 1 variables in 1 instance and display en, data, mask, outputs, noise, and evaluation counts for both after 1 ticks. Also check that rewriting the same stored input value or changing only another instance's variables causes no extra evaluations.

In function rows, read the instance's data and mask internally without arguments. Under 9.2.2.2.1, these remain in the inferred sensitivity even while an inactive branch that does not call the function is selected. Write observation counters only within the same process, also checking item b's rule excluding written expressions from sensitivity. Stop updating the counter after 512 times so execution terminates even under erroneous self-reexecution. The correct stimulus sequence evaluates at most 37 times per 1 instance and never exhausts this limit. Do not read noise from processes or functions; verify that toggling it changes neither outputs nor evaluation counts.

In addition to 3 known-value background combinations, give X/Z rows 3 combinations of unknown data and masks. When X/Z assigned to bit becomes 0 and equals the previous value, it does not trigger reexecution as a value change. The enable is always logic; 0, X, and Z select the false branch of if. comb updates to the specified 0 or 1, while latch retains its previous output. Change data and mask while disabled too; verify that returning to en = 1 updates using the latest values. Assign latch outputs with NBA and make all observations after completion.

Calculate expected values with [Generator model of value changes and sensitivity sets](../generators/interaction_process.py) and compare all 1,728 lines using [Independent Active / NBA event-queue model](../tools/test_interaction_process.py). Function delays, multiple driving processes, dynamic indices, data-path feedback, and modports are out of scope.

All 36 additions on [Saved run of kirimasim when added](../coverage/interaction-results/cross39-kirimasim-95eefebe.json) returned PASS, successfully satisfying all 242 pairs, 96 combinations of 3 factors, and 6 mandatory cases. 36 cases also agreed on fixed version [Icarus 13.0](../coverage/interaction-results/process-20261031-icarus13.json). For [seed 1](../coverage/interaction-results/process-20261031-verilator5.052-seed1.json) and [seed 73](../coverage/interaction-results/process-20261031-verilator5.052-seed73.json) with fixed Verilator 5.052, all 7 known-value inputs have known results. The remaining 29 cases contain X/Z data or enables and are outside fixed Verilator's verification scope.

A representative example is `test_gen_cross_process_1_bit_known_comb_direct_module_zero_zero`. On the first line before external input changes, fixed Verilator outputs `events=512` on both seeds instead of expected `events=1`. Because this counter increments only inside the process, it exposes evaluation-count differences that reach the limit at time 0. The expected values based on 9.2.2.2.1 b are maintained, and the oracle of Verilator is not registered in this model.

[Fault injection](../coverage/interaction-qualification/20261031-process.json) uses runtime kirimasim; the 3 positive controls agreed for direct comb in a module at 1 bits, function latch in an interface with 129-bit logic Z, and function comb in an interface with 65-bit logic X. Output differences detected 13 fault kinds: missing comb defaults or latch retention; treating an unknown enable as true; missing data/mask reads through a function; adding noise to sensitivity; missing evaluation counts or startup at time 0; stimulating another instance; converting logic to bit; incorrect comb defaults; ignoring the enable; and converting XOR to OR. Count detection only when compilation, execution, and normalization all terminate normally; do not add it to ordinary test counts or success evidence.

These additions increase the ordinary suite by 36 to 9,551 cases; generation has 3,114 cases, and the short selection has 1,801. The [Build evidence](../coverage/interaction-qualification/20261031-process-build.json) stored the latest upstream commit and version, unchanged source, binary hash before and after execution, and the input and result comparison of the previous 1,765. Map 7 interface cases to Chapter 9 × Chapter 25, 9 function cases to Chapter 9 × Chapter 13, and 4 interface-function cases to Chapter 13 × Chapter 25; verify that all 36 model cases returned PASS in one run. No new requirement mappings are registered; the requirement-coverage denominator and verification rate are retained. Passed 427 tool regression tests and consistency checks of generated artifacts, saved runs, chapter-pair CSV, the triage registry, counts, catalogs, requirement matching, and requirement coverage. Metadata covers 9,551 cases with 0 new issues (395 known issues). Also verified that all plans for the existing 37 models and aggregates for 93 saved runs remain identical. These are local check results, treated separately from full runs of GitHub Check and Nightly.

<a id="generate階層でのpackageと局所宣言の名前探索"></a>

### Package and local-declaration name lookup in generate hierarchy

`generate_scope_lookup` combines for/if/case generate from Chapter 27 with package-name references from Chapter 26, access to named hierarchy from Chapter 23, and per-generated-element continuous assignments from Chapter 10. Move Chapter 23 × Chapter 27 and Chapter 10 × Chapter 27 from E existing verification and Chapter 26 × Chapter 27 from C candidate to M finite models.

- Package type widths: 1, 32, 33, 64, 65, and 129 bits. State type: bit / logic. Input value: known / X / Z.
- Reference: unqualified name through wildcard import / explicit package qualification.
- Local declaration: none / same-named type and constant in branch 0. Nesting: 1 / 2 levels. Conditional generate: if / case.

Select 36 cases from all 576 possibilities, retaining 148 pairs, 68 priority 3-factor combinations, and 6 mandatory cases. Priority groups comprise 36 combinations of width × state type × value; 8 combinations of reference × local declaration × depth; 8 combinations of reference × local declaration × branch; 8 combinations of reference × depth × branch; 8 combinations of state type × local declaration × reference. There are no exclusions for lack of support. Do not create out-of-range hierarchy indices or illegal declarations with name conflicts. Restrict same-named conditional generate blocks to mutually exclusive branches of the same conditional statement, as permitted by 27.5.

The package defines WIDTH and identifying constants ORIGIN = 5 and word_t. Each worker creates 2 elements from genvar g = 0/1, and reverses branch selection in the 2 instance whose SELECT is 0/1. On the local-declaration line, only branch 0 contains WIDTH = package width +1, ORIGIN = 9, and word_t with bit / logic reversed. An unqualified name under wildcard import selects the local declaration; explicit qualification selects the package declaration even when a local declaration exists. The other branch references package declarations, providing a comparison of hidden and unhidden names within the same case.

Using the selected type, each element continuously assigns XOR of the parent instance's source and `used_t'(USED_ORIGIN + INDEX)`. INDEX is 0/1 obtained from the implicit genvar localparam of 27.4. Make inputs 1 bits wider than the package and use 3 known-value combinations to distinguish retaining and truncating upper bits. Add 3 combinations containing mixed unknowns to the X/Z rows, and also check 2-state conversion when storing into the selected type after XOR. Expected values do not convert the input to bit before applying XOR.

Use named hierarchical paths with 1 / 2 levels; for the 2 elements of both instances, display selected branch KIND, presence/absence of a local declaration LOCAL, genvar constant INDEX, and the selected USED_WIDTH, TYPE_BITS, USED_ORIGIN and their values. LOCAL indicates the existence of a local declaration, but does not mean that the declaration was used. In explicitly qualified rows, selection resolves to the package even with LOCAL = 1. Observe references to WIDTH constants and `$bits(used_t)` separately to detect errors where only the type selects a different scope. Wait 1 ticks after each input change and verify that values/constants do not leak across elements or instances.

Calculate expected values with [Generator type/constant selection and bit-string conversion](../generators/interaction_generate.py) and compare all 576 lines using [Independent model of lexical scopes, hierarchy lookup, and integral unknown-bit masks](../tools/test_interaction_generate.py). config, defparam, unnamed generate blocks, dynamic hierarchy indices, relative sibling references, signed-data operations, and sign extension are out of scope. Existing [Relative hierarchical-name references that also search enclosing scopes](../tests/ch23/test_generate_upward_scope_name.sv) and [Continuous assignments to array elements](../tests/ch27/test_generate_assign.sv) are retained.

All 36 additions on [Saved run of kirimasim when added](../coverage/interaction-results/cross40-kirimasim-4b58e29f.json) returned PASS, successfully satisfying all 148 pairs, 68 combinations of 3 factors, and 6 mandatory cases. The 36 cases containing X/Z also agreed on fixed version [Icarus 13.0](../coverage/interaction-results/generate-20261031-icarus13.json). For [seed 1](../coverage/interaction-results/generate-20261031-verilator5.052-seed1.json) and [seed 73](../coverage/interaction-results/generate-20261031-verilator5.052-seed73.json) in Verilator 5.052, all 12 known-value cases matched. The 24 X/Z cases are outside the verification scope of fixed Verilator.

[Fault injection](../coverage/interaction-qualification/20261031-generate.json) uses runtime kirimasim; 3 positive controls matched, covering 1-bit import without hiding, 129-bit logic Z with nested case/import/local declarations, and 65-bit logic X with nested if/explicit qualification/local declarations. 13 fault kinds were detected through output differences after normal termination: incorrect package/local widths or constants; fixing genvar; omitting genvar from branch selection; incorrect instance parameters or local state type; ignoring import hiding or explicit qualification; failing to track inputs; stimulating another instance; and converting XOR to OR. Detection relies on unknown-value state conversion as well as changes to widths and tags. Fault injection does not count toward ordinary test counts or success evidence.

These additions increase the ordinary suite by 36 to 9,587 cases; generation has 3,150 cases, and the short selection has 1,837. The [Build evidence](../coverage/interaction-qualification/20261031-generate-build.json) stored the latest upstream commit and version, unchanged source, binary hash before and after execution, and the input and result comparison of the previous 1,801. All 36 cases are bound to the added 3 chapter pairs, and the full model was confirmed PASS in one run. No new requirement mappings are registered; the requirement-coverage denominator and verification rate are retained. Passed 434 tool regression tests and consistency checks of generated artifacts, saved runs, chapter-pair CSV, the triage registry, counts, catalogs, requirement matching, and requirement coverage. Metadata covers 9,587 cases with 0 new issues (395 known issues). Also verified that all plans for the existing 39 models and aggregates for 101 saved runs remain identical. These are local check results, treated separately from full runs of GitHub Check and Nightly.

<a id="デフォルト引数と階層呼出しのスコープ"></a>

### Scopes of default arguments and hierarchical calls

`default_argument_scope` combines the hierarchical call from 23 with the functions in the interface from 25 to evaluate the default arguments in 13. Retain ordinary existing tests and move Chapter 13 × Chapter 23 and Chapter 23 × Chapter 25 from E existing verification to M finite models. Also add to Chapter 13 × Chapter 25.

- Width: 1, 32, 33, 64, 65, 129 bits. State type: bit / logic. Input value: known / X / Z.
- Declaration origin: module / interface. Default expression: variable read / function call with observed side effects.
- Actual-argument specification: all omitted, first empty, data only by name, both explicitly specified as 0, both named in reverse order.

All 720 possibilities are legal; select 36 cases, retaining 159 pairs, 128 priority 3-factor combinations, and 6 mandatory cases. Priority groups comprise 36 combinations of width × state type × value; 20 combinations of declaration origin × expression × specification form; 30 combinations of state type × value × specification form; 30 combinations of declaration origin × specification form × value; 12 combinations of expression × state type × value. There are no exclusions for lack of support.

According to 13.5.3, a default expression is evaluated in the scope of the subroutine's declaration source every time a call uses the default value as its argument. An explicitly supplied actual argument prevents evaluation of its default expression. Under 13.5.1 and 13.5.4, distinguish empty positional arguments from arguments omitted in named specification, and also check name-based binding.

Call function pick with 2 type-matched arguments on separate module/interface instances in A/B/A order. Immediately before each call, update that instance's source and mask_source; put different known values in same-named caller variables. Also define same-named getter functions in the caller and observe that their call counts remain 0. Distinguish reading values from the declaring scope, evaluating caller actual arguments, fixing values at declaration time, and referencing another instance.

Give every case 3 known-value combinations and add 3 mixed-unknown combinations in X/Z rows. Convert unknowns to bit when storing into source, then evaluate the default value and calculate XOR. Because XOR can cancel a swap of the two arguments in the return value, also display both formal values saved by the function. After each call, also check both instances' original variables, function-body call counts, and separate data/mask getter evaluation counts. The 2 getters do not change each other's inputs or counters, so the test does not depend on actual-argument evaluation order.

Calculate expected values with [Generator model of bit strings and default-value selection](../generators/interaction_default.py) and compare output from all 720 lines using [A model using a separate actual-argument binding table, delayed evaluation, and integral unknown-bit masks](../tools/test_interaction_default.py). Classes, virtual interfaces, output/inout/ref arguments, timing controls, and recursion are out of scope. Existing ordinary tests for [Evaluation only for omitted arguments](../tests/ch13/test_default_argument_only_when_omitted.sv) and [Declaration scope](../tests/ch13/test_default_argument_declaring_scope.sv) are unchanged.

All 36 additions on [Saved run of kirimasim when added](../coverage/interaction-results/cross41-kirimasim-4b58e29f.json) returned PASS, successfully satisfying all 159 pairs, 128 combinations of 3 factors, and 6 mandatory cases. The 36 cases containing X/Z also agreed on fixed version [Icarus 13.0](../coverage/interaction-results/default-20261031-icarus13.json). For [seed 1](../coverage/interaction-results/default-20261031-verilator5.052-seed1.json) and [seed 73](../coverage/interaction-results/default-20261031-verilator5.052-seed73.json) in Verilator 5.052, all 12 known-value cases matched. The 24 X/Z cases are outside the verification scope of fixed Verilator.

In [Fault injection](../coverage/interaction-qualification/20261031-default.json), the 6 mandatory positive controls agreed. 13 fault kinds were detected through output differences after normal termination: substituting caller values; using the wrong default variable or function; evaluating twice; fixing values at initialization; extra evaluation with an explicit argument; omitting explicit 0; missing defaults for empty or named-omitted arguments; incorrect named binding; calling another instance; missing body-call counts; and changing logic storage to bit. Swapped named actual arguments are detected through saved formal values even if they leave XOR's return value unchanged. Fault injection does not count toward ordinary test counts or success evidence.

These additions increase the ordinary suite by 36 to 9,623 cases; generation has 3,186 cases, and the short selection has 1,873. The [Build evidence](../coverage/interaction-qualification/20261031-default-build.json) stored the latest upstream commit and version, unchanged source, binary hash before and after execution, and the input and result comparison of the previous 1,837. Map all 36 cases to Chapter 13 × Chapter 23 and 15 interface cases to Chapter 23 × Chapter 25 and Chapter 13 × Chapter 25; verify that the whole model returned PASS in one run. No new requirement mappings are registered; the requirement-coverage denominator and verification rate are retained. Passed 441 tool regression tests and consistency checks of generated artifacts, saved runs, chapter-pair CSV, the triage registry, counts, catalogs, requirement matching, and requirement coverage. Metadata covers 9,623 cases with 0 new issues (395 known issues). Also verified that all plans for the existing 40 models and aggregates for 105 saved runs remain identical. These are local check results, treated separately from full runs of GitHub Check and Nightly.

<a id="イベント引数によるスコープ間の同期"></a>

### Cross-scope synchronization through event arguments

`event_task_scope` combines the named event in chapter 15 with the input/ref argument in chapter 13, the interface in chapter 25, the package in chapter 26, and the Active/NBA in chapters 4 and 10, and the visibility of assignment. Move Chapter 13 × Chapter 15 from E existing verification, Chapter 15 × Chapter 25/26 from C candidate, and Chapter 4 × Chapter 15 from R requiring review to M finite models. Also add to the existing Chapter 10 × Chapter 15 cross.

- Event declaration origin: module / interface / package. Argument passing: input / ref.
- Trigger path: direct / through a task in the declaring scope. Trigger: ordinary `->` / nonblocking `->>`.
- Number of waiters per event: 1 / 2 / 3. Initial trigger order: A→B / B→A. Wait start: early / late.

Select factors affecting event identity, wait registration, and wakeup regions rather than mechanically crossing numeric widths and X/Z. All 288 possibilities are legal; select 13 cases, retaining 109 pairs, 52 priority 3-factor combinations, and 6 mandatory cases. Priority groups comprise 12 combinations of declaration origin × passing method × trigger path; 8 combinations of passing method × trigger × wait start; 12 combinations of waiter count × order × wait start; 8 combinations of trigger path × trigger × order; 12 combinations of declaration origin × trigger × wait start. There are no exclusions for lack of support.

Pass the A/B 2 events in distinct module/interface instances or in a package to an automatic waiting task in another module. Both the event handle copied through input and the handle read through ref point to the same synchronization object. Register up to 3 waiting tasks per event; use each waiter's count, times, and read values to check confusion with other events and partial wakeups. The unused slots initialized with 0 are also observed. Each waiter updates a separate array element, avoiding dependence on wakeup order.

The early waiter executes `@(ev)` at time 1, and the late waiter at time 6. The first event triggers occur at times 3 and 4, and the next at 8 and 10. Under 15.5.2, late waiters do not remember past triggers and do not wake until times 8 and 10. Once a task returns, later triggers do not execute it again. Call all waiters again from time 12, then trigger at times 20 and 22 in reverse order from the first round to check repeated waiting and independence of different events. Trigger distinct noise 2 times, and trigger both events again after all waiters complete.

Before each trigger, write a known value to static variable stamp in the waiting module using blocking assignment, and schedule NBA of that value plus 1. Then trigger the event. Waiters returning to Active through an ordinary trigger read the old value; waiters returning through a NBA trigger read the scheduled updated value. The combination of 15.5.1, 4.4.2.2, 4.4.2.4, and 10.4.2 also produces output differences when the trigger operator is confused. The left-hand side of NBA is not an automatic variable. Use only undelayed NBA triggers, scheduling payload updates first. Display from one driving process, checking values before the current tick's trigger and after the previous tick's wakeup. Ordering is not established using `#0` or races within Active.

Calculate expected values with [Generator closed-form wakeup times and values](../generators/interaction_event_task.py) and compare all 288 lines using [Independent model of waiter queues and Active/NBA processing](../tools/test_interaction_event_task.py). Event-variable rebinding/comparison, waiting on null, triggered, wait_order, virtual interfaces, and event lifetime in automatic variables are out of scope. This does not establish verification of differences between input and ref upon rebinding. In [Comparison before execution](../coverage/interaction-qualification/20261031-event-task-preflight.json), existing event rebinding/merging remained unsupported in kirimasim when the model was added. Retain existing verification for Chapter 6 × Chapter 15 and Chapter 7 × Chapter 15 in the ledger.

All 13 additions on [Saved run of kirimasim when added](../coverage/interaction-results/cross42-kirimasim-4b58e29f.json) returned PASS, successfully satisfying all 109 pairs, 52 combinations of 3 factors, and 6 mandatory cases. Fixed version [Icarus 13.0](../coverage/interaction-results/event-task-20261031-icarus13.json) cannot build tasks with event arguments in any of the 13 cases; no oracle is registered. All 3 ref and ordinary-trigger cases in [seed 1](../coverage/interaction-results/event-task-20261031-verilator5.052-seed1.json) and [seed 73](../coverage/interaction-results/event-task-20261031-verilator5.052-seed73.json) on Verilator 5.052 agreed. Across both seeds, reproduced missing waiter-wakeup records at the expected times in 7 input cases and 3 ref / NBA-trigger cases. Save the 10 differences as known without registering a Verilator oracle; preserve expected values and the legal model scope.

In [Fault injection](../coverage/interaction-qualification/20261031-event-task.json), the 6 mandatory positive controls agreed. Detected 15 error types as output differences after normal termination: omitted waits, swapped early/late waits, waiting on another instance/noise, omitted value/time recording, double counting, shared destinations for multiple waiters, ignored task actual arguments, missing waiters, triggering another instance, omitted payload NBA, making NBA events ordinary, and making payload NBA blocking. Fault injection does not count toward ordinary test counts or success evidence.

These additions increase the ordinary suite by 13 to 9,636 cases; generation has 3,199 cases, and the short selection has 1,886. The [Build evidence](../coverage/interaction-qualification/20261031-event-task-build.json) stored the latest upstream commit and version, unchanged source, binary hash before and after execution, and the input and result comparison of the previous 1,873. Map all 13 cases to Chapter 4/10/13 × Chapter 15, 5 interface cases to Chapter 15 × Chapter 25, and 4 package cases to Chapter 15 × Chapter 26. No new requirement mappings are registered; the requirement-coverage denominator and verification rate are retained. Passed 449 tool regression tests and consistency checks of generated artifacts, saved runs, chapter-pair CSV, the triage registry, counts, catalogs, requirement matching, and requirement coverage. Metadata covers 9,636 cases with 0 new issues (395 known issues). Also verified that all plans for the existing 41 models and aggregates for 109 saved runs remain identical. These are local check results, treated separately from full runs of GitHub Check and Nightly.

<a id="連続代入の遅延と短パルスの除去"></a>

### Continuous-assignment delays and short-pulse cancellation

`continuous_delay_inertial` combines continuous-assignment delays from Clause 10 with gate-delay selection from Clause 28 and state conversion on storage to bit/logic from Clause 6. Move Chapter 10 × Chapter 28 from E existing verification and Chapter 6 × Chapter 28 from R requiring review to M finite models. Existing [Rise/fall delays and short pulses](../tests/ch10/test_continuous_assign_rise_fall_delay.sv) is unchanged.

- Width: 1, 2, 32, 33, 64, 65, 129 bits. Declare scalar nets at width 1 and vector nets at widths 2 or greater.
- Original-variable type: bit / logic. Input value: known / X / Z. Right-hand-side expression: direct / bitwise inverted.
- Delay specifications: 1 5, 2 (7,3), and 3 (7,5,2). Pulse width: 1 / 10 ticks.

All 504 possibilities are legal; select 63 cases, retaining 141 pairs, 129 priority 3-factor combinations, and 7 mandatory cases. Priority groups comprise 42 combinations of width × state type × value; 63 combinations of width × value × delay specification; 12 combinations of delay specification × pulse width × expression; 12 combinations of state type × value × expression. Do not make pulse widths equal propagation delays; separate initial settling from subsequent observations. There are no exclusions for lack of support.

For scalar delay selection in 28.16, a transition to 0 uses the fall delay, to 1 the rise delay, to Z the turn-off delay, and to X the minimum specified delay. With 2 specified values, also use the minimum for turn-off. For whole-vector continuous assignment in 10.3.3, use the fall delay for transitions to 0, the turn-off delay for transitions to all-Z, and the rise delay otherwise. Expected values do not apply delays independently to each bit. For example, with (7,5,2), a transition from 0 to X changes a scalar after 2 ticks and a vector of 2 bits or more after 7 ticks. Classification of 1-bit packed vectors is outside this model's scope.

Give every case known-value steps of all-0, all-1, alternating bits, and the opposite alternating pattern. Next apply pulses of 1 or 10 ticks, checking cancellation of short pulses and rise/fall times of long pulses. Also replace all pending 1 with another known value, verifying that old scheduled events are removed and delays are recalculated from the current output and new request. Add all-unknown values, mixtures with known values, and unknown-value pulses to the X/Z rows. Because the raw value is stored in the source variable before inversion, bit X/Z→0 conversion occurs before delay selection. Also observe the original raw value, stored source, and undelayed rhs on the same line.

After 20 ticks of initial settling, print each tick's values in Postponed using `$strobe` of 21.2.2. Also observe output-change counts and final change times to detect extra short transitions and incorrect update timing. An independent model verified that input changes never coincide with scheduled output updates in any model row. Restrict the model to one driver, integer delays, and 1ns precision, avoiding resolution order, rounding, and same-time input/output races. Net-declaration delays, strengths, multiple drivers, SDF, min/typ/max, and unknown-valued delay specifications are out of scope. Chapter pairs with Clause 21 or similar are not added merely because `$strobe` is used for display or observation.

Generate expected values with [Generator model of 1 pending updates and per-tick calculations](../generators/interaction_delay.py) and compare all 504 lines using [Independent event heap, generation-number cancellation, and 4-state encoding](../tools/test_interaction_delay.py). Separate scalar from/to tables from whole-vector classification, and independently calculate the order of 2-state conversion and inversion.

All 63 additions on [Saved run of kirimasim when added](../coverage/interaction-results/cross43-kirimasim-4b58e29f.json) returned PASS, successfully satisfying all 141 pairs, 129 combinations of 3 factors, and 7 mandatory cases. 57 cases agreed on fixed version [Icarus 13.0](../coverage/interaction-results/delay-20261031-icarus13.json); 6 differed in transition timing or other behavior. [seed 1](../coverage/interaction-results/delay-20261031-verilator5.052-seed1.json) and [seed 73](../coverage/interaction-results/delay-20261031-verilator5.052-seed73.json) under Verilator 5.052 matched 17 of 21 known-value cases; the 4 cases with 65/129-bit width and 2/3 delays failed to build. The 42 X/Z cases are outside the scope of fixed Verilator. [Build diagnostics for standalone reruns](../coverage/interaction-qualification/20261031-delay-verilator-build.json) is also saved. Saved JSON redacts only temporary build-directory paths; result classifications and input/runner fingerprints are unchanged. Save differing cases as known without registering a fixed-version oracle; preserve expected values and the legal model scope.

[Fault injection](../coverage/interaction-qualification/20261031-delay.json) uses runtime kirimasim; the 7 mandatory positive controls agreed. 16 fault kinds were detected through output differences after normal termination: scalar minimum delay, turn-off settings, rise/fall selection, single-delay handling, inversion, bit/logic types, source updates, delayed-driver values, short-pulse widths, duplicate or missing transition counts, time, vector width, substituting transport delay, and vector rise delay. For transport-delay faults, replace continuous assignment with a delayed NBA process and detect short pulses that are not canceled. Fault injection does not count toward ordinary test counts or success evidence.

These additions increase the ordinary suite by 63 to 9,699 cases; generation has 3,262 cases, and the short selection has 1,949. The [Build evidence](../coverage/interaction-qualification/20261031-delay-build.json) stored the latest upstream commit and version, unchanged source, binary hash before and after execution, and the input and result comparison of the previous 1,886. Because the previous 42 models were uncommitted, also saved digests of the pre-addition plan and 113 saved runs in [Comparison records](../coverage/interaction-qualification/20261031-delay-prior-digests.json). Mapped all 63 cases for Chapter 10 × Chapter 28, and 28 cases storing X/Z in type bit for Chapter 6 × Chapter 28. No new requirement mappings are registered; the requirement-coverage denominator and verification rate are retained. Passed 457 tool regression tests and consistency checks of generated artifacts, saved runs, chapter-pair CSV, the triage registry, counts, catalogs, requirement matching, and requirement coverage. Metadata covers 9,699 cases with 0 new issues (395 known issues). Also verified that all plans for the existing 42 models and aggregates for 113 saved runs remain identical. These are local check results, treated separately from full runs of GitHub Check and Nightly.

<a id="packageのimportとワイルドカードポート接続"></a>

### Package imports and wildcard port connections

`port_import_scope` combines the wildcard, implicit named, explicit port connections of chapter 23 with the visibility of package names of chapter 26. Move Chapter 23 × Chapter 26 from E existing verification to M finite model. Existing [Package imports and wildcard connections](../tests/ch23/test_wildcard_port_connection_package_import.sv) is unchanged.

- Width: 1, 32, 33, 64, 65, 129 bits. Final-sample type: bit / logic. Input value: known / X / Z.
- import: wildcard / explicit import of p. Local declaration: none / same-named p.
- Connection: `.*` only, or combined with `.p`, `.p(p)`, `.p(port_source::p)`, or `.p('0)`.

Of all 720 possibilities, exclude 180 combining an explicit import and a same-named local declaration, which are illegal under 26.3. Select 39 cases from the remaining 540 legal possibilities, retaining 158 pairs, 141 priority 3-factor combinations, and 6 mandatory cases. Priority groups comprise 36 combinations of width × sample type × value; 15 combinations of import × local declaration × connection; 30 combinations of sample type × value × connection; 30 combinations of import × connection × value; 30 combinations of local declaration × connection × value. There are no exclusions for lack of support. Match the types and widths of every connection; ports and connections use explicit 4-state wire. bit / logic are the types of sample variables that copy outputs after settling; they do not affect the rules for selecting connection targets.

Under 23.3.2.4, `.*` alone is not a reference that imports p from a wildcard import. Without local p or an explicit import, the child's input port uses default 23.2.2.4. Using `.p` or `.p(p)` also creates a name reference, importing the package's p through the wildcard import. If local p exists, use it under 26.3 hiding rules; a qualified-name connection uses package p even with a local declaration. `.p('0)` connects to the explicitly specified 0 instead of using the default value. Empty actual arguments are outside this model's scope.

Place 2 children in each parent, setting their input defaults to all-0 and all-1, respectively. Connecting inputs to package or local variables gives the same value on both sides, preventing accidental agreement with the default-value pair even at 1 bits. Also place a same-named FALLBACK constant in the parent, verifying that default constants depend on the child's declaration scope and each instance's parameters. Place only a wildcard import and `.*` in guard's separate parent scope as a control that always uses the child's default. Make sure that import and name references in DUT do not interfere with the visibility of the guard.

A writer in another module explicitly imports package p and updates it from a task. This reference is also independent of DUT and guard's scope. Adding an unqualified reference to p for display or type queries in a parent containing only `.*` would change the verification conditions, so no such reference is introduced. Declare every net and use `default_nettype none` so implicit-net creation cannot conceal connection errors. This auxiliary condition alone does not count toward the Chapter 22 × Chapter 23 cross.

Give every case known all-0, all-1, and alternating-bit values; add 3 combinations placing unknowns at MSB, the middle, and LSB in X/Z rows. Give local variables values with known bits inverted and X/Z exchanged to distinguish package and local connection targets. After 1 ticks of settling, observe current package values, local stimuli, each child's input port, parent-side outputs, final samples, and type widths. Check X/Z-to-0 conversion in the final bit sample separately from value selection on the 4-state port. Conflicting packages, width conversion, positional connections, inout/ref, and implicit-net behavior are out of scope.

Calculate expected values with [Generator connection-source selection and sample conversion](../generators/interaction_import.py) and compare all 540 lines using [Independent lazy-import symbol table and live-value binding](../tools/test_interaction_import.py).

All 39 additions on [Saved run of kirimasim when added](../coverage/interaction-results/cross44-kirimasim-4b58e29f.json) returned PASS, successfully satisfying all 158 pairs, 141 combinations of 3 factors, and 6 mandatory cases. 38 cases agreed on fixed version [Icarus 13.0](../coverage/interaction-results/import-20261031-icarus13.json). The remaining 1 cases—129-bit logic Z, wildcard import, no local declaration, and `.p`—fail to build because p cannot be bound. For [seed 1](../coverage/interaction-results/import-20261031-verilator5.052-seed1.json) and [seed 73](../coverage/interaction-results/import-20261031-verilator5.052-seed73.json) on Verilator 5.052, all 13 known-value cases differed from the expected output. For example, with width 1, wildcard import, no local declaration, and `.*`, the right input port is 0 instead of expected 1. No Verilator oracle is registered for this model. The 26 X/Z cases are outside the verification scope of fixed Verilator. Save differing cases as known without registering a fixed-version oracle; preserve expected values and the legal model scope.

[Fault injection](../coverage/interaction-qualification/20261031-import.json) uses runtime kirimasim; positive controls agreed for the 6 mandatory cases and 1 selected named-connection cases. 16 fault kinds were detected through output differences after normal termination: forcing a reference to DUT from `.*` alone; leaking an explicit import into the guard; changing explicit imports to wildcards; omitting `.p`/`.p(p)`; ignoring explicit qualification or local declarations; replacing explicit 0 with the package value; making paired defaults identical; missing package updates; incorrectly stimulating the local value; swapping bit/logic sample types; inverting or truncating child output; and replacing explicit 0 with 1. Fault injection does not count toward ordinary test counts or success evidence.

These additions increase the ordinary suite by 39 to 9,738 cases; generation has 3,301 cases, and the short selection has 1,988. The [Build evidence](../coverage/interaction-qualification/20261031-import-build.json) stored the latest upstream commit and version, unchanged source, binary hash before and after execution, and the input and result comparison of the previous 1,949. Because the previous work was uncommitted, also saved pre-addition digests of 43 models and 117 saved runs in [Comparison records](../coverage/interaction-qualification/20261031-import-prior-digests.json). Map all 39 cases to Chapter 23 × Chapter 26. No new requirement mappings are registered; the requirement-coverage denominator and verification rate are retained. Passed 465 tool regression tests and consistency checks of generated artifacts, saved runs, chapter-pair CSV, the triage registry, counts, catalogs, requirement matching, and requirement coverage. Metadata covers 9,738 cases with 0 new issues (395 known issues). Also verified that all plans for the existing 43 models and aggregates for 117 saved runs remain identical. These are local check results, treated separately from full runs of GitHub Check and Nightly.

<a id="型と範囲を組み合わせたメモリファイル入出力"></a>

### Memory-file I/O combining types and ranges

`typed_memory_file` combines memory-file writes/reads from Chapter 21 with enum numeric values and 2-state / 4-state conversions from Chapter 6, and fixed-array ranges from Chapter 7. Move Chapter 6 × Chapter 21 from E existing verification to M finite model, also adding to existing Chapter 7 × Chapter 21. Existing [Writing enum and integral arrays](../tests/ch21/test_writemem_two_state_enum.sv) and [Read direction and address specification](../tests/ch21/test_readmemh_directions_and_addresses.sv) are unchanged.

- Width: 1, 32, 33, 64, 65, 129 bits. Original-variable base type: bit / logic. Element type: ordinary packed vector / enum.
- Value: known / X / Z. File: binary / hex. Write range: all 5 elements / middle 3 elements / single element.
- Read-destination declaration direction: ascending / descending. Read-destination type: bit / logic. Explicit read direction: forward / reverse.

The full Cartesian product has 3,456 combinations. For a single element, forward/reverse start and end coincide, so omit 576 duplicate combinations. Select 36 cases from the remaining 2,880 possibilities, retaining 248 pairs, 82 priority 3-factor combinations, and 6 mandatory cases. Priority groups comprise 36 combinations of width × original-variable base type × value; 12 combinations of element type × original-variable base type × value; 12 combinations of file format × value × read-destination type; 12 combinations of element type × file format × write range; 10 combinations of declaration direction × read direction × write range. This removes duplicates; it is not exclusion due to illegal conditions or unsupported tool features.

The original array is [2:6]; explicitly specify 2:6, 3:5, and 4:4 for writes. The destination is a separate [10:16] or [16:10] array; update 1/3/5 elements from 11 in the specified direction. Under 21.4, proceed from start to end without changing order based on declaration direction. Initialize both ends and unselected elements; display all 7 elements to detect out-of-range writes and missing reads.

Store numeric values into the enum with a 6.19.4 static cast. This cast converts to the base type and does not validate whether the value is a defined enumerator. Expected values compare the stored numeric bit patterns under 21.5.2, rather than printing names or declaration-order numbers. Perform X/Z-to-0 conversion to the original bit type before writing, and conversion to the destination bit type when reading, distinguishing the two stages. Place unknowns across entire active nibbles so hexadecimal comparison does not lose known bits. Independently verify round trips to the original width in binary and hex, including a top nibble containing only 1–3 bits. Formatting mixed X/Z partial nibbles, width/sign conversion, dynamic/associative arrays, and multidimensional ordering are out of scope.

Known-value stimuli encode element numbers 1–5 over 3 rounds so every element has a distinct history even at 1 bits. Retain these known-value controls in the X/Z rows so unknowns do not hide element-order errors. After writing the file, change every bit of the original array to a different known value. Verify that reads restore values from write time rather than following the original array's current contents. Reusing the same filename for each stimulus also detects failures of 21.5 overwriting that leave stale contents.

In addition to written files, prepare separate literal input files generated from the Python model. Do not format these contents from the original DUT array using `%b` or `%h`. Read both files under the same conditions into separate arrays and compare against values calculated from the specification. This ensures detection through independent input even when write/read faults are inverses of each other. Use reference input containing @ only in comments and check that both files have 0 address specifiers after comments are excluded. Check 21.5.3, which emits no @ words for fixed arrays, without fixing implementation-specific whitespace, newline, or comment placement. See also [Practical procedure](interaction-verification-method.en.md) for applying this approach to other projects and LSI verification.

Calculate expected values with [Generator stored values and index mappings](../generators/interaction_memfile.py) and compare all 2,880 lines using [Independent integral/X/Z masks, token decoding, and array mappings](../tools/test_interaction_memfile.py).

All 36 additions on [Saved run of kirimasim when added](../coverage/interaction-results/cross45-kirimasim-4b58e29f.json) returned PASS, successfully satisfying all 248 pairs, 82 combinations of 3 factors, and 6 mandatory cases. 35 cases agreed on fixed version [Icarus 13.0](../coverage/interaction-results/memfile-20261031-icarus13.json). The 1 cases using enums with a 65-bit bit base, known values, binary, and a single range failed with an internal assertion during compilation. For [seed 1](../coverage/interaction-results/memfile-20261031-verilator5.052-seed1.json) and [seed 73](../coverage/interaction-results/memfile-20261031-verilator5.052-seed73.json) in Verilator 5.052, 11 of 12 known-value cases matched. The 1 cases covering a 32-bit logic-based enum, binary input, the middle 3 elements, and reverse-direction reading reproduced a difference where the expected lower-index values become 0. The 24 X/Z cases are outside the verification scope of fixed Verilator. Save disagreements/build failures as known without registering that fixed version as an oracle; preserve expected values and the legal model scope.

In [Fault injection](../coverage/interaction-qualification/20261031-memfile.json), the 6 mandatory positive controls agreed. Detected all 17 error types as output differences after normal termination: reversing both writes and reads, ignoring reverse direction, swapping bit / logic of the source variable / read destination, wrong enum values, shifted write ranges / read destinations, omitting either read, retaining stale files, failing to store into the source array, truncating width, using the wrong base, inserting @ words, miscounting @ in comments, and modifying the source array before writing. For simultaneous reversal, confirmed that the round-trip side still matches at written = 1, while the independent-input side produces 0 against expected canonical = 1. Detection on this independent input path is also a success condition for the fault-injection script. Fault injection does not count toward ordinary test counts or success evidence.

These additions increase the ordinary suite by 36 to 9,774 cases; generation has 3,337 cases, and the short selection has 2,024. The [Build evidence](../coverage/interaction-qualification/20261031-memfile-build.json) stored the latest upstream commit and version, unchanged source, binary hash before and after execution, and the input and result comparison of the previous 1,988. Map 8 enum cases to Chapter 6 × Chapter 21 and all 36 cases to Chapter 7 × Chapter 21. No new requirement mappings are registered; the requirement-coverage denominator and verification rate are retained. Passed 473 tool regression tests and consistency checks of generated artifacts, saved runs, chapter-pair CSV, the triage registry, counts, catalogs, requirement matching, and requirement coverage. Metadata covers 9,774 cases with 0 new issues (395 known issues). Also verified that all plans for the existing 44 models and aggregates for 121 saved runs remain identical. These are local check results, treated separately from full runs of GitHub Check and Nightly.

<a id="program終了と子孫プロセスの取消し"></a>

### Program termination and cancellation of descendant processes

`program_descendant_shutdown` combines program termination from Chapter 24 with fork/waiting from Chapter 9 and named events from Chapter 15. Existing [Natural-termination regression](../tests/ch24/test_program_end_kills_descendants.sv) and [Regression for $exit inside tasks](../tests/ch24/test_program_exit_in_task.sv) are unchanged. Moved Chapter 9 × Chapter 24 from E existing verification to M finite model and Chapter 15 × Chapter 24 from R requiring review to M.

- Termination method: natural / `$exit` from the main initial block / `$exit` inside an automatic task.
- Initial-block count in the target program: 1 / 2. Wait method: delay / named event / condition wait.
- Child structure: direct child / grandchild whose intermediate parent ends earlier. Progress before waiting: none / present.
- fork joining: join_none / join_any. Other programs kept alive: 1 / 2.

All 288 possibilities are legal; select 18 cases, retaining all 109 factor pairs, 38 priority 3-factor combinations, and 4 mandatory cases. Priority groups comprise 18 combinations of termination method × initial count × wait method; 8 combinations of join × child structure × progress; 12 combinations of termination method × initial count × other-program count. Widths and state types are not factors because they add no cancellation distinctions.

The target is a portless program inside a module, implicitly instantiated once under 24.3. The main initial block ends at time 4; an additional initial block, if present, ends at 6. Natural termination keeps descendants alive until all initial blocks end, canceling them when the final initial block ends. `$exit` in 24.7 also terminates other initial blocks and descendants of the calling program. Also provide observation variables counting return from the call inside the task and continuation of its caller, requiring 0 for both.

In fork, create a waiting child, a child advancing from the checkpoint at time 5 to a prohibited write at time 7, and a short child ending at time 1. join_none records return at time 0 and join_any at time 1; both align the end of the main initial block to time 4. In grandchild cases, only the intermediate parent ends at time 2; verify that cancellation by the original program also reaches the surviving grandchild. The checkpoint at time 5 succeeds only for natural termination with 2 initial blocks. This also detects erroneous child cancellation at the main initial block's end time 4 while other initial blocks remain active.

The waiting child records its start and, when progress is enabled, also records at time 1. Release delay waits at time 7/8 and event/condition waits at 8, after cancellation for every termination method. Ensure the control in another program with the same wait condition wakes; at time 9, check the terminated target's write count 0 and the control's wakeup count 1. Prevent tests from passing when events were never triggered or waits were not functioning. In particular, Chapter 15 × Chapter 24 maps 6 cases canceling only the terminated target among two programs waiting on the same event.

The separate program survives until time 12, or until 15 when there are 2 instances. For 2 instances, also observe at time 13 to verify that terminating one does not stop the other. Because of 24.3's implicit `$finish`, the module sentinel at time 20 does not execute; the final block in 9.2.3 prints time 12/15 and the final state. Do not use explicit `$finish` or `disable` to perform the cancellation being verified. Use only one module final block so expected values do not depend on execution order among multiple final blocks. Same-time Active/Reactive races, NBA region differences, class/process handles, and module tasks called from programs are out of scope.

[Generator](../generators/interaction_program.py) calculates expected values with conditional expressions and compares all 288 lines using [Independent event queue with owners](../tools/test_interaction_program.py). Independently of the generator's closed-form expressions, process waiting events chronologically, discard scheduled work for terminated programs, and continue module observations until the last program ends.

In [Saved run of kirimasim when added](../coverage/interaction-results/cross46-kirimasim-4b58e29f.json), all 18 cases returned PASS, successfully satisfying all 109 pairs, 38 combinations of 3 factors, and 4 mandatory cases. All 18 cases on fixed [Icarus 13.0](../coverage/interaction-results/program-20261031-icarus13.json) are known. The 6 natural-termination cases have different output; the 12 cases using `$exit` cannot execute because the system task is undefined. [Auxiliary evidence](../coverage/interaction-qualification/20261031-program.json) also stores complete diagnostics and output for the 4 mandatory cases. In 2 natural-termination controls, observed execution of child writes that should have been canceled and the module sentinel at time 20. [seed 1](../coverage/interaction-results/program-20261031-verilator5.052-seed1.json) and [seed 73](../coverage/interaction-results/program-20261031-verilator5.052-seed73.json) on fixed Verilator 5.052 cannot build any of the 18 cases because program declarations inside modules are unsupported. Do not register a fixed-version oracle; retain the legal model scope and expected values. The temporary path of Icarus is hidden from the diagnostics, and the state and input hash are preserved.

[Fault injection](../coverage/interaction-qualification/20261031-program.json) matched 4 normal controls and detected 18 fault kinds through output differences after normal termination: cancellation before the last initial starts; delayed termination; ignoring direct or task-local $exit; missing start/progress/checkpoint records; waking on pre-termination release for 3 wait kinds; failing to wake the control when the event is not triggered; failing to terminate an intermediate parent; replacing join_none with join; incorrect join_any return time; early/late termination of another program; and omitting the main initial-completion record. Do not add this count to the ordinary test count or requirement coverage. The control design for verifying stopped behavior is also documented in [Practical procedure for other projects and LSI](interaction-verification-method.en.md).

Recheck the latest upstream against the build version immediately before execution, then rerun [Verification tools](../tools/qualify_program.py) as follows. `--icarus-bin` is optional; specifying it also saves complete diagnostics for the fixed version's 4 mandatory cases. Use a new destination without overwriting historical evidence.

```sh
python3 tools/qualify_program.py --kirimasim BIN --commit VERIFIED_COMMIT \
  --icarus-bin ICARUS13_BIN \
  --output coverage/interaction-qualification/NEW-program.json
```

These additions increase the ordinary suite by 18, to 9,792 total cases, 3,355 generated cases, and 2,042 short-selection cases. [Build evidence](../coverage/interaction-qualification/20261031-program-build.json) stores the latest upstream and version, unchanged source, binary fingerprints before/after execution, and unchanged inputs/results for 2,024 existing cases. Compare the preceding 45 models' plans and 125 saved-run aggregates, including uncommitted additions, against [Fingerprints before execution](../coverage/interaction-qualification/20261031-program-prior-digests.json). No new requirement mappings are registered. Retain the latest upstream Ghost execution results; the 18 cases in this work do not change the requirement-coverage denominator or verification rate. Passed 480 tool regression tests and consistency checks of generated artifacts, saved runs, chapter-pair CSV, the triage registry, counts, catalogs, requirement matching, and requirement coverage. Metadata covers 9,792 cases with 0 new issues (395 known issues). These are local check results, treated separately from full runs of GitHub Check and Nightly.

<a id="default_nettypeとポートnetの解決"></a>

### default_nettype and port-net resolution

`implicit_port_nettype` combines the `default_nettype` and `resetall` in chapter 22, the implicit net declaration and multi-driver resolution in chapter 6, and the port type and width determination in chapter 23. Existing [Implicit-port-net regression](../tests/ch6/test_implicit_port_expression_nets.sv) is unchanged. Moved Chapter 6 × Chapter 22 from R requiring review to M finite model and Chapter 22 × Chapter 23 from E existing verification to M.

- Directed net type: wire / tri / wand / triand / wor / trior.
- Width: 1, 32, 33, 64, 65, 129 bits. Declaration form: non-ANSI / ANSI.
- Vector-output net type: omitted / explicit wire. Input value: 0/1 only / 0/1 / X / Z.
- Restore-default method: `default_nettype wire` / `resetall`.

All 576 possibilities are legal. Select 40 cases, retaining all 156 factor pairs, 72 priority 3-factor combinations, and 6 mandatory cases. Priority groups each have 24 combinations: default net type × declaration form × explicit wire; default net type × input value × restore method; and width × declaration form × explicit wire. wire and tri, wand and triand, and wor and trior have the same resolution rules within each pair, but remain separate levels to check directive spelling and declaration rules. Implicit declarations in `none` and multiple drivers on uwire are outside the scope of the positive cases. Pull behavior of tri0 / tri1, trireg charge retention, unequal driver strengths, and propagation delays are separate verification scopes. The denominator is not reduced for unsupported tool features.

Define the target module under the directive; only vector output y omits the net type or explicitly uses wire. Always omit the net type of scalar output g as a control for the default type. Under 6.10 and 23.2.2.3, check both non-ANSI implicit nets and default port kinds under ANSI. In ANSI, even when the vector output is explicitly wire, compare values and `$bits` to verify that a scalar output with a newly specified direction does not incorrectly inherit its wire or vector width.

Drive each output with 2 continuous assignments of equal strength. Calculate X from contention on wire / tri, dominance by 0/1 on wired-AND / OR, and X/Z handling from the specification. Each bit exercises all 4 driver-value combinations with 0/1 inputs and all 16 combinations with inputs containing X/Z. Shift resolution-table stimulus phases per bit position. These stimuli alone still leave equivalence with a period of 16 bits. Add 8 stimuli applying the same 0/1 to both drivers to uniquely identify bit positions 1–129 by their histories. This stimulus gives the same known value regardless of net type and also distinguishes replacement of an upper word with a lower word. Each case has 12 stimuli with 0/1 inputs and 24 with X/Z inputs, while the ordinary test count remains 40 for 1 cases. Even with only 0/1 inputs, wire contention can produce X, so all 40 cases carry `fourstate: yes`.

After restoring the directive to wire or using `resetall`, define another module. Omit this module's output net type and require wire resolution results for the same inputs. Write both module instantiations after restoring the setting. This distinguishes later directives erroneously applying retroactively to earlier module definitions and earlier directives incorrectly persisting into later modules. After waiting 1 time units each time, display parent/child vector/scalar outputs, values inside/outside the subsequent module, and input/output widths. Keep directive differences separate from process order and same-time read/write races.

[Generator](../generators/interaction_nettype.py) computes resolved values with conditional branches. Use [Independent resolution table and integral bit masks](../tools/test_interaction_nettype.py) to check expected values for all 576 lines, each bit's driver-value combination, resolution results for 6 types × 16 combinations, and distinguishability of 129 bit positions. Also check semantic agreement and lexical differences of synonymous net types, agreement between two ways of restoring settings, and the need to classify even 0/1 inputs as 4-state cases.

In [Saved run of kirimasim when added](../coverage/interaction-results/cross47-kirimasim-4b58e29f.json), all 40 cases returned PASS, successfully satisfying all 156 pairs, 72 combinations of 3 factors, and 6 mandatory cases. With fixed [Icarus 13.0](../coverage/interaction-results/nettype-20261031-icarus13.json), 14 wire / tri cases match, while 26 wand/triand/wor/trior cases are saved as known results. For example, under the wor condition in ANSI where only the vector is explicitly wire, the vector value matched, but the scalar became X instead of the expected 1. To prevent abbreviated displays from hiding differences near the end of long vectors, save unabridged first mismatching lines for 6 mandatory cases in [Auxiliary evidence](../coverage/interaction-qualification/20261031-nettype.json). Fixed Verilator 5.052 is used only to check `fourstate: no` under the policy, so 0 cases are in scope here. [Build evidence](../coverage/interaction-qualification/20261031-nettype-build.json) records the version and seed 1/73 policy, the scope determination, and that no simulation was launched. Unexecuted cases are not counted as known or PASS. Preserve the expected values and legal ranges of 26 cases, and register the Icarus oracle only for the 14 cases that agreed.

[Fault injection](../coverage/interaction-qualification/20261031-nettype.json) matched 6 normal controls and detected 19 fault types as output differences after normal termination: changing AND / OR to wire or swapping them, omitting/forcing explicit wire, omitting either of two setting resets, omitting drivers, using the wrong scalar input bit, truncating to 64 bits, scalar width inheritance, converting the source variable to 2-state, reusing an earlier definition in a later module, scalar inheritance of the vector's net type, and using the wrong upper word. Fault injection does not count toward ordinary passes. Confusing upper words passed 16 resolution-table rounds and was first detected at p22 of the position-identifying stimuli. Detection by post-resolution-table stimuli is also a verification-tool success condition. The comparison of setting scope is also documented in [Practical procedure for other projects and LSI](interaction-verification-method.en.md).

Recheck the latest upstream against the build version immediately before execution, then rerun [Verification tools](../tools/qualify_nettype.py). Specifying `--icarus-bin` also saves mismatching lines for the fixed version's 6 mandatory cases. Do not overwrite historical evidence.

```sh
python3 tools/qualify_nettype.py --kirimasim BIN --commit VERIFIED_COMMIT \
  --icarus-bin ICARUS13_BIN \
  --output coverage/interaction-qualification/NEW-nettype.json
```

These additions increase the ordinary suite by 40, to 9,832 total cases, 3,395 generated cases, and 2,082 short-selection cases. [Build evidence](../coverage/interaction-qualification/20261031-nettype-build.json) stores the latest upstream and version, unchanged source, binary fingerprints before/after execution, and unchanged inputs/results for 2,042 existing cases. Compare the preceding 46 models' plans and 129 saved-run aggregates, including uncommitted additions, against [Fingerprints before execution](../coverage/interaction-qualification/20261031-nettype-prior-digests.json). No new requirement mappings are registered; the requirement-coverage denominator and verification rate are retained. Passed 488 tool regression tests and consistency checks of generated artifacts, saved runs, chapter-pair CSV, the triage registry, counts, catalogs, requirement matching, and requirement coverage. Metadata covers 9,832 cases with 0 new issues (395 known issues). These are local check results, treated separately from full runs of GitHub Check and Nightly.

<a id="generateで生成したinterfaceとmodport接続"></a>

### Interfaces created by generate and modport connections

`generated_interface_binding` combines loop/if/case generate from Clause 27, interfaces and modports from Clause 25, and storage to bit/logic from Clause 6. Moved Chapter 25 × Chapter 27 from C addition candidate to M finite model and Chapter 6 × Chapter 25 from R requiring review to M.

- Base width: 1, 32, 33, 64, 65, 129 bits. Number of generated elements: 1 / 2 / 3.
- Conditional generate: if / case. Selected target: a / b. Port connection: whole interface / modport.
- Interface payload: bit / logic. Input: known / X / Z.

All 864 possibilities are legal. Select 36 cases, retaining all 165 factor pairs, 74 priority 3-factor combinations, and 6 mandatory cases. Priority groups comprise 36 combinations of base width × state type × input; 12 combinations of element count × generate form × selected target; 8 combinations of connection form × generate form × selected target; 18 combinations of element count × state type × input. Virtual interfaces, passing interface arrays through ports, clocking, and illegal modport accesses are out of scope. Legal combinations are not removed from the denominator for lack of support.

For each element i, generate 2 interfaces a and b with width W = BASE+i. The actual width is at most 131 bits. Constants derived from genvar in 27.4 and parameters determine each element's type and connections at elaboration. if/case uses the 27.5 rule that generates only one of two branches sharing the name route. Connect writer and reader to the selected interface; give the unselected side independent known control data and a negative identifying tag. Provide module interface-port forms accepting the entire interface and selecting modports with writer/reader directions. Negative tests for rejection of accesses in the wrong direction do not count toward this positive model's achievement rate.

The branch selecting a stores the input unchanged; the branch selecting b inverts the input bits before storing into payload. In logic, an inverted Z becomes X; in bit, that X becomes 0. Distinguish the conversion order, including cases where conversion to bit followed by inversion gives 1. Display each element's raw input, a/b payloads and tags, reader output and tag, the three actual widths, and generated-branch identifier. Update all elements, then wait 1 time units, avoiding dependence on generation order or same-time execution order. Map all 36 cases to Chapter 25 × Chapter 27 and 24 X/Z cases observing conversion differences to Chapter 6 × Chapter 25.

Encode generated elements and bit positions through 11 rounds of known-data history. These stimuli alone can leave identical histories on the inverted selected path and the other-element control path, so add 2 stimuli applying 0 → 1 only to the selected path. After inversion, 1 → 0 is distinguishable from the control's 0 → 0. For 3 elements of width 129/130/131, independently verify that all 780 bit-position histories across selected/control paths differ in both a and b branches. Tags differ per element and role, so the reader's connection target remains identifiable after storing unknowns. Retain 13 known-value rounds in every test; add 3 stimuli for X/Z conditions. The ordinary test count is 36.

For the value and index expression of [Generator](../generators/interaction_ifgenerate.py), all 864 rows are matched with [Independent interface objects and reader references](../tools/test_interaction_ifgenerate.py). The independent cross-check builds inputs from integral value/X/Z masks, stores them in two objects per generated element, then observes the value and type of the object referenced by the reader.

In [Saved run of kirimasim when added](../coverage/interaction-results/cross48-kirimasim-4b58e29f.json), all 36 cases returned PASS, successfully satisfying all 165 pairs, 74 combinations of 3 factors, and 6 mandatory cases. Fixed [Icarus 13.0](../coverage/interaction-results/ifgenerate-20261101-icarus13.json) reports syntax errors for interface-port declarations, so none of the 36 cases build; they are saved as known. The legal scope and expected values are retained. For [seed 1](../coverage/interaction-results/ifgenerate-20261101-verilator5.052-seed1.json) and [seed 73](../coverage/interaction-results/ifgenerate-20261101-verilator5.052-seed73.json) with fixed Verilator 5.052, all 12 known-value cases matched for both. The 24 X/Z cases are outside the verification scope of fixed Verilator. Register the fixed-version oracle only for the 12 cases that agreed on both seeds. Do not combine partial successes from separate runs into a whole-model PASS; assess all 36 cases in the saved kirimasim run above.

[Fault injection](../coverage/interaction-qualification/20261101-ifgenerate.json) matched 6 normal controls and detected 18 fault kinds through output differences after normal termination: incorrect branch selection; missing or forced inversion; swapping bit/logic; changing conversion/inversion order; connecting the reader to the control; missing tags or sharing them with another element; corrupting the control; reading the first element's input incorrectly; overriding widths in generated elements or interfaces; missing writer output; truncating the reader to 64 bits; and reusing the low word. Do not add this count to the ordinary pass count.

Recheck the latest upstream against the build version immediately before execution, then rerun [Verification tools](../tools/qualify_ifgenerate.py). Use a new destination without overwriting historical evidence.

```sh
python3 tools/qualify_ifgenerate.py --kirimasim BIN --commit VERIFIED_COMMIT \
  --output coverage/interaction-qualification/NEW-ifgenerate.json
```

These additions increase the ordinary suite by 36, to 9,868 total cases, 3,431 generated cases, and 2,118 short-selection cases. [Build evidence](../coverage/interaction-qualification/20261101-ifgenerate-build.json) stores the latest upstream and version, unchanged source, binary fingerprints before/after execution, and unchanged inputs/results for 2,082 existing cases. Compare the preceding 47 models' plans and 131 saved-run aggregates, including uncommitted additions, against [Fingerprints before execution](../coverage/interaction-qualification/20261101-ifgenerate-prior-digests.json). No new requirement mappings are registered; the requirement-coverage denominator and verification rate are retained. Passed 496 tool regression tests and consistency checks of generated artifacts, saved runs, chapter-pair CSV, the triage registry, counts, catalogs, requirement matching, and requirement coverage. Metadata covers 9,868 cases with 0 new issues (395 known issues). These are local check results, treated separately from full runs of GitHub Check and Nightly.

<a id="programのイベント領域と非ブロッキング代入"></a>

### Program event regions and nonblocking assignments

`program_reactive_handoff` combines program Reactive/Re-NBA from Clause 24, event regions from Clause 4, nonblocking assignment from Clause 10, and storage to bit/logic from Clause 6. Existing [Program outputs and module NBA chains](../tests/ch24/test_program_output_after_module_nba_chain.sv) and [Program observations in Reactive](../tests/ch24/test_program_reactive_sees_nba.sv) are unchanged. Moved Chapter 4 × Chapter 24 from E existing verification to M finite model, and Chapter 10 × Chapter 24 and Chapter 6 × Chapter 24 from R requiring review to M.

- Width: 1, 32, 33, 64, 65, 129 bits. Source type: bit / logic. Input: known / X / Z.
- Module NBA chain: 1 / 2 / 3 stages. Source update: blocking / nonblocking assignment.
- Program output: continuous / blocking / nonblocking assignment. Output expression: unchanged / bitwise inverted.

All 1,296 possibilities are legal. Select 36 cases, retaining all 183 factor pairs, 84 priority 3-factor combinations, and 6 mandatory cases. Priority groups comprise 36 combinations of width × source type × input; 18 combinations of stage count × source update × program output; 12 combinations of source update × program output × output expression; 18 combinations of program output × source type × input. NBA targeting automatic variables, clocking, competing writes, and same-time external stimuli are out of scope. Legal combinations are not removed from the denominator for lack of support.

Changes to the module's source initiate a NBA chain of 1–3 stages. Each stage i stores XOR of its input and constant i+1 truncated to width, distinguishing source and intermediate-stage values where width permits. Align the initial value using the same conversion for source = 0, and exclude initialization at time 0 from counts and event observations. `module_steps` is the number of times each stage's always schedules NBA. This is not the completed-write count. In addition to this count, compare values at every stage to distinguish cases where all expected updates are scheduled but have not yet taken effect.

Also continuously assign the same expression as source within the module, recording the final-stage value at the output event as a control that precedes the program. Because this wakes in Active, require the final stage still to hold the previous stimulus's value at that point. For module-side observations awakened by program output events, require the final-stage value and scheduling count after completion of the NBA chain, even within the same time. Under 24.3.1, 24.3.2, and 4.5, this checks Reactive processing after the module's Active/NBA regions settle, and the boundary where processing returns to the module's Active region.

Also place a process waiting for source changes in the program, and sample the module's actual final stage and scheduling count through hierarchical references. With blocking outputs, sample the new output value immediately after assignment. For program NBA outputs, sampling immediately after the assignment still captures the old value, distinguishing it from the output event after the Re-NBA update. For continuous assignment, sample the expression result and module-side context without depending on process order within the same Reactive region. Do not directly reference internal program variables from the module; observe sampled values, scheduling counts, and activation counts through output ports.

Space stimuli 10 ns apart; after 1 ns, display raw input, stored source, program output, every stage's value, and the sampled context. Verify that rewriting the same source value does not increase the program activation count. The 16 known-value stimuli use data identifying bit positions 1–129 and its inverse, providing a control that continues changing even at 1 bits. Immediately before each X/Z stimulus, drive all 1 so that at least 1 bits change even after conversion to bit. Storing into a bit source before inversion in the program distinguishes the X/Z→0→1 order from inversion while still logic, which produces X. Expected values also account for XOR within stages converting Z to X. Map all 36 cases to Chapter 4 × Chapter 24, 6 cases where the program outputs with NBA to Chapter 10 × Chapter 24, and 24 cases storing X/Z to Chapter 6 × Chapter 24.

[Generator](../generators/interaction_reactive.py) calculates the state and the number of times for each stimulus. [Independent per-region queues and integral value/X/Z masks](../tools/test_interaction_reactive.py) is matching all 1,296 rows. The independent model processes evaluation in Active, each NBA stage update, sampling in Reactive, and output updates in Re-NBA as separate events. For every selected case, verify that reversing processing order within Active gives the same observation sequence.

In [Saved run of kirimasim when added](../coverage/interaction-results/cross49-kirimasim-4b58e29f.json), all 36 cases returned PASS, successfully satisfying all 183 pairs, 84 combinations of 3 factors, and 6 mandatory cases. All 36 cases on fixed [Icarus 13.0](../coverage/interaction-results/reactive-20261101-icarus13.json) are known. [seed 1](../coverage/interaction-results/reactive-20261101-verilator5.052-seed1.json) and [seed 73](../coverage/interaction-results/reactive-20261101-verilator5.052-seed73.json) on fixed Verilator 5.052 classify all 12 known-value cases as known; the 24 X/Z cases are outside verification scope. Retain expected values and legal scope without registering a fixed-version oracle. Save preliminary run JSON after checking that all input and runner fingerprints match the current versions; do not rewrite input hashes or timestamps.

In the minimal 1-bit, 1-stage control, both fixed versions displayed 1 instead of the expected final-stage 0 at notification. In Verilator, even though the scheduling count was the expected 1, the value at notification was the old value 1. [Diagnostics for the first time interval](../coverage/interaction-qualification/20261101-reactive-fixed.json) stores the values at notification on both fixed versions and output showing the final stage 0 in the snapshot at the next time. Also verified normal termination of each process in all 3 runs: 1 runs on Icarus and seed 1/73 on Verilator. This illustrates why scheduling counts and actual updated data are observed separately.

[Fault injection](../coverage/interaction-qualification/20261101-reactive.json) matched 6 normal controls and detected 19 fault types as output differences after normal termination: moving 3 kinds of program processing into module regions, swapping blocking/NBA, swapping bit / logic and bypassing conversion, errors in the final stage/conversion constant/capture stage, errors in the module-side control expression, missing counts, output-width truncation, and capturing RHS rather than the old value immediately after NBA. Do not add this count to the ordinary pass count.

Recheck the latest upstream against the build version immediately before execution, then rerun [Verification tools](../tools/qualify_reactive.py). Use a new destination without overwriting historical evidence.

```sh
python3 tools/qualify_reactive.py --kirimasim BIN --commit VERIFIED_COMMIT \
  --output coverage/interaction-qualification/NEW-reactive.json
```

These additions increase the ordinary suite by 36, to 9,904 total cases, 3,467 generated cases, and 2,154 short-selection cases. [Build evidence](../coverage/interaction-qualification/20261101-reactive-build.json) records the latest upstream and version, unchanged source, binary fingerprints before and after execution, invariance of input and output of existing 2,118 items, and how to save fixed versions. Compare the preceding 48 models' plans and 135 saved-run aggregates, including uncommitted additions, against [Fingerprints before execution](../coverage/interaction-qualification/20261101-reactive-prior-digests.json). No new requirement mappings are registered; the requirement-coverage denominator and verification rate are retained. Passed 504 tool regression tests and consistency checks of generated artifacts, saved runs, chapter-pair CSV, the triage registry, counts, catalogs, requirement matching, and requirement coverage. Metadata covers 9,904 cases with 0 new issues (395 known issues). These are local check results, treated separately from full runs of GitHub Check and Nightly.

<a id="configのパラメータ設定とgenerateの形状"></a>

### config parameter settings and generate structure

`configuration_generated_shape` combines config from Clause 33, parameter settings/defparam/ordinary hierarchy from Clause 23, and loop/conditional generate from Clause 27. Existing [Precedence between config and defparam](../tests/ch33/test_config_defparam_precedence.sv) is unchanged. Moved Chapter 23 × Chapter 33 from E existing verification and Chapter 27 × Chapter 33 from C addition candidate to M finite models. M indicates that the model is registered; it does not indicate that all cases pass. For these 2 chapter pairs, 0 models have PASS on every selected case.

- Reference width: 1, 32, 33, 64, 65, 129 bits.
- Prior specification: defaults only / instance specification / defparam / both.
- config: set W/MODE / reset W only / reset all parameters.
- Setting values: 3 modes; numeric literal / config localparam / parent parameter in ordinary hierarchy.
- Generated branch: if / case. Ordinary hierarchy to the target: direct child / through a wrapper module.

From 2,592 full-product rows, use 0/literal as representatives for mode and RHS unused by reset, consolidating 1,536 rows expressing duplicate behavior. The scope is 1,056 rows. Legal combinations are not excluded for lack of support. Retain all 213 factor pairs, 80 priority 3-factor combinations, and 6 mandatory cases in 41 cases. Priority groups comprise 24 combinations of prior specification × config operation × hierarchy; 10 combinations of config operation × mode × if/case; 10 combinations of config operation × RHS × hierarchy; 36 combinations of reference width × config operation × if/case.

Apply config to target parameters in an ordinary module hierarchy. The resulting W, N, and MODE determine vector widths, generated-element counts, and if/case branches. Under 33.4.3, config settings take precedence over defparam for the same parameter; `#(.W())` must reset only W, and `#()` must reset all parameters to their module-declaration defaults. For unset N/TAG, also observe differences among defaults, instance specification, and defparam. Sibling guard has explicit parameters and serves as a control unaffected by target config/defparam settings.

Give numeric values, config localparam, and parent-module parameters distinct widths and MODE values. Even when same-named PW / PM are hidden, distinguish whether RHS resolves from the correct scope. RHS hierarchical references remain within an ordinary parent module without passing through generate blocks or instance arrays. Direct config settings on instances inside generate, cell/library substitution, and unknown-valued parameters are out of scope. This model does not perform direct configuration of generated hierarchy proposed in the earlier Chapter 27 × Chapter 33 candidate. This pair is registered on the observation that configuration changes the generated structure.

Each leaf observes its own actual array with a procedural loop. Do not hard-code hierarchical references to the expected element count; if generation count is wrong, detect output-count/data/width differences rather than compile errors from missing hierarchy names. Also give the child module an output returning its actual width numerically and compare it separately from the parent's `$bits`. For each if/case selection, perform TAG and XOR with the element number, inversion, and XOR of the low 2 bits, detecting faults where only the MODE display is correct but the processing differs.

The 13 known-value stimuli encode target/guard, element number, and bit position. Maximum widths are target 134 bits and guard 135 bits, identifying 807 bit positions across 3 elements each. Independently verified that inverted histories also do not overlap the original history set. Offset observation by 1 ns using stable ID, avoiding dependence on simultaneous target/guard display order.

[Generator](../generators/interaction_config.py) creates the expected string by applying the parameters in sequence. [Independent model](../tools/test_interaction_config.py) chooses values by prioritizing candidates per parameter, then computes observations from instance/child objects and integral bit planes. Verify agreement on all 1,056 lines, equivalence of the consolidated 1,536 rows, selection coverage, distinction of 807 positions, and preservation of defined behavior across if/case and ordinary hierarchy.

In [Saved run of kirimasim when added](../coverage/interaction-results/cross50-kirimasim-4b58e29f.json), 37 of 41 cases returned PASS, and 4 failed due to output differences. Successful cases satisfy 207 of 213 pairs and 72 of 80 combinations of 3 factors; all 6 mandatory cases are PASS. Separate planned coverage from the scope of successful execution. The 4 failing cases have prior specification defparam or both and a whole-reset config operation. The default values of W, N, MODE, and TAG were expected, but the defparam values were displayed. Retain legal inputs and expected values without excluding failures.

[Minimal comparisons and fault injection](../coverage/interaction-qualification/20261101-config.json) stores the source, output, and exit code of a small example applying `#()` and 4 explicit empty parentheses to the same parameter. Only the combination of `#()` and defparam differed; individual-name resets, a complete reset applied only to the instance setting, and resetting only W in defparam matched. All 4 examples terminated normally. This is an externally observed difference; its internal implementation cause has not been identified.

The 6 positive controls agreed on the same [Fault-injection records](../coverage/interaction-qualification/20261101-config.json). 19 fault kinds were detected through output differences after normal termination: ignoring config; applying or leaking it to an untargeted sibling; incorrect precedence against defparam or incorrect RHS scope; confusing individual and complete resets; omitting prior settings; incorrect generated elements/branches/widths; missing element or instance identity; reusing high bits; and incorrect control-width or child-width reporting. Do not add this count or the minimal comparisons to the ordinary suite's pass count.

Fixed [Icarus 13.0](../coverage/interaction-results/config-20261101-icarus13.json) cannot build any of the 41 cases due to syntax errors. [seed 1](../coverage/interaction-results/config-20261101-verilator5.052-seed1.json) and [seed 73](../coverage/interaction-results/config-20261101-verilator5.052-seed73.json) with fixed Verilator 5.052 also rejected all 41 tests because parameterized use or config localparam is unsupported, or because the top hierarchy to configure could not be found. All rows use known values, and both seeds run the same scope. Saved as known without registering a fixed-version oracle. Retain preliminary runs whose input/runner fingerprints match the final artifacts, without rewriting timestamps or input hashes.

Recheck the latest upstream against the build version immediately before execution, then rerun [Verification tools](../tools/qualify_config.py). Use a new destination without overwriting historical evidence.

```sh
python3 tools/qualify_config.py --kirimasim BIN --commit VERIFIED_COMMIT \
  --output coverage/interaction-qualification/NEW-config.json
```

These additions increase the ordinary suite by 41, to 9,945 total cases, 3,508 generated cases, and 2,195 short-selection cases. [Build evidence](../coverage/interaction-qualification/20261101-config-build.json) records the latest upstream and version, unchanged source, binary fingerprints before and after execution, invariance of input and output of existing 2,154 items, and how to save fixed versions. Compare the preceding 49 models' plans and 139 saved-run aggregates, including uncommitted additions, against [Fingerprints before execution](../coverage/interaction-qualification/20261101-config-prior-digests.json). No new requirement mappings are registered; the requirement-coverage denominator and verification rate are retained.

Passed 512 tool regression tests and consistency checks of generated artifacts, saved runs, chapter-pair CSV, the triage registry, counts, catalogs, requirement matching, and requirement coverage. Metadata covers 9,945 cases with 0 new issues (395 known issues). These are local check results, treated separately from full runs of GitHub Check and Nightly.

<a id="udpの配列接続と駆動強度の解決"></a>

### Array connections and drive-strength resolution in UDP

`udp_array_strength` combines combinational UDP from Clause 29 with primitive-array connections and drive strengths from Clause 28. Existing [Strengths and arrays of UDP](../tests/ch29/test_udp_instance_strength_and_array_range.sv) is unchanged. Moved Chapter 28 × Chapter 29 from E existing verification to M finite model. All 25 cases are mapped to this chapter pair.

- Array element count: 1, 32, 33, 64, 65, 129.
- UDP ：A AND NOT B／A OR NOT B。 This 2 function changes its result when input order changes.
- The strength of UDP: default strong/pull/strong0 and weak1/weak0 and strong1.
- Other-driver strength: weak / pull / strong.
- Instance-array range: descending / ascending. Index endpoints are 3 and element count +2.
- Output packed range: descending / ascending. Input B: common scalar connection / vector bit distribution.

All 1,152 rows are legal; none are excluded for lack of support. Retain all 182 factor pairs, 80 priority 3-factor combinations, and 6 mandatory cases in 25 cases. Priority groups comprise 24 combinations of UDP function × UDP strength × other-driver strength; 24 combinations of element count × B connection form × output packed range; 8 combinations of instance-array range × output packed range × B connection form; 24 combinations of element count × UDP function × B connection form.

Input A is a descending packed array; vector B is ascending. Under 28.3.6 and 29.8, verify that a scalar connects commonly to each instance and a vector distributes according to bit order. Vary the declaration directions of instance arrays and outputs independently, requiring the same defined behavior at external terminals. Hierarchical references in individual instance-name indices and settings applied to only specific elements are not verified. These observations do not distinguish permutations that swap all terminals consistently while preserving external behavior.

Place 2 arrays with identical inputs and UDP strength, connecting another driver to only one array's output. Compare standalone and conflicting outputs to check strength precedence, X from equal-strength conflicts, and release when the other driver becomes Z. Also include a single unnamed UDP and separately observe the outputs of A's and B's rightmost bits. Verify strength application from resolved logical values under contention, without relying on strength display `%v`.

The first 30 rounds per row use 8 encoding rounds identifying positions 1–129 and 2 rounds of all-0 / all-1. Vector B is A's inverse, while scalar B is the neutral value that passes A through each function, so the standalone UDP output equals A. In all 10 rounds, switch the other driver among 0, 1, and Z. At each bit, check all 6 combinations of UDP output 0/1 and other-driver 0/1/Z, observing the asymmetric strength0 / strength1 distinction. Independently verified that adding all-0 and all-1 also makes the 129 histories and their inverses mutually distinct.

The next 16 rounds apply all 16 0/1/X/Z input pairs to the terminals. Following 29.2 and 29.4, the Z input is treated the same as the X input, and the input pairs that do not match the table are required to output X. During these 16 rounds, release the other driver to Z. Ambiguous strength ranges where an unknown UDP output conflicts with a known other driver are outside this model's scope. Sequential UDP, delays, and `%v` are also out of scope. All 25 cases are classified as 4-state tests because they observe contention-induced X and 4-state truth tables.

[Generator](../generators/interaction_udp.py) calculates expected strings from UDP input conditions and relative strengths. [Independent model](../tools/test_interaction_udp.py) determines observed values from the set of Boolean completions of unknown inputs, terminal objects, and the candidate set of strongest drivers, comparing all 1,152 lines. Also verify all 16 input pairs and 6 conflict combinations at every bit, distinction between position histories and their inverses, retention of factor pairs / priority 3-factor combinations / mandatory cases, and equivalent external behavior across declaration directions.

In [Saved run of kirimasim when added](../coverage/interaction-results/cross51-kirimasim-4b58e29f.json), all 25 cases returned PASS, successfully satisfying all 182 pairs, 80 combinations of 3 factors, and 6 mandatory cases. On fixed [Icarus 13.0](../coverage/interaction-results/udp-20261101-icarus13.json), the 1 mandatory cases with 1 elements and default strength agree; 24 cases are known due to build-time rejection of explicit strengths or UDP arrays. Registered a fixed-version oracle only for the 1 cases that agreed and reran the final generated artifacts. Because Verilator is used only for 2-state tests under the policy, it was not run for the 0 target cases. Expected values and legal target scope are retained.

[Fault injection](../coverage/interaction-qualification/20261101-udp.json) matched 6 normal controls and detected 19 fault types as output differences after normal termination: swapping 0/1 strengths, omitting UDP's strength specification, changing/omitting/releasing another driver or affecting a standalone output, misconnecting input terminals/changing order on only one side/truncating upper bits, wrong capture bits or omission of unnamed UDP, changing AND NOT to AND, missing truth-table rows/incorrect constant outputs for unknown rows, converting unknown values to 2-state, misconnecting a standalone array, and omitting the last array element. For the fault omitting the last element, also narrow the connection expression to a legal width and observe the remaining undriven output. Compile errors and unsupported cases do not count as fault detection. Do not add this count to the ordinary suite's pass count.

Recheck the latest upstream against the build version immediately before execution, then rerun [Verification tools](../tools/qualify_udp.py). Use a new destination without overwriting historical evidence.

```sh
python3 tools/qualify_udp.py --kirimasim BIN --commit VERIFIED_COMMIT \
  --output coverage/interaction-qualification/NEW-udp.json
```

These additions increase the ordinary suite by 25, to 9,970 total cases, 3,533 generated cases, and 2,220 short-selection cases. [Build evidence](../coverage/interaction-qualification/20261101-udp-build.json) records the latest upstream and version, unchanged source, binary fingerprints before/after execution, and unchanged inputs/results for 2,195 existing cases. Compare the preceding 50 models' plans and 143 saved-run aggregates, including uncommitted additions, against [Fingerprints before execution](../coverage/interaction-qualification/20261101-udp-prior-digests.json). No new requirement mappings are registered; the requirement-coverage denominator and verification rate are retained.

Passed 521 tool regression tests and consistency checks of generated artifacts, saved runs, chapter-pair CSV, the triage registry, counts, catalogs, requirement matching, and requirement coverage. Metadata covers 9,970 cases with 0 new issues (395 known issues). These are local check results, treated separately from full runs of GitHub Check and Nightly.

<a id="generateで生成した逐次udpの状態と入力変換"></a>

### State and input conversion of sequential UDP created by generate

`generated_udp_state` combines sequential UDP from Clause 29, generate from Clause 27, and storage to bit/logic from Clause 6. Existing [Per-instance state of sequential UDP](../tests/ch29/test_sequential_udp_state_per_instance.sv) and [Initial value of UDP](../tests/ch29/test_udp_initial_value_is_current_state.sv) are unchanged. Moved Chapter 27 × Chapter 29 and Chapter 6 × Chapter 29 from R requiring review to M finite models. Map all 36 cases to Chapter 27 × Chapter 29, and 24 cases storing X/Z to Chapter 6 × Chapter 29.

- Width: 1, 32, 33, 64, 65, 129 bits. Module-side source type: bit / logic. Input: known / X / Z.
- Sampling clock edge: rising / falling. Generated branch: if / case.
- Initial-value selection: `(genvar+offset)%3`. Offsets are 0, 1, and 2; select UDP in 3 variants: 0, 1, and no initial setting.
- Target clock: shared by all bits / drive even and odd bits in turn.

All 864 rows are legal; none are excluded for lack of support. Retain all 165 factor pairs, 68 priority 3-factor combinations, and 6 mandatory cases in 36 cases. Priority groups comprise 36 combinations of width × source type × input; 8 combinations of edge × clock form × generated branch; 12 combinations of initial-value offset × generated branch × clock form; 12 combinations of source type × input × clock form.

At each generated bit, place 2 state-retaining UDP objects: target and guard. Under 29.7 and 29.3.3, target starts with selected 0 / 1 / no explicit initialization (X); guard starts according to the following initial-value categories. Display all bit states and the generated selection code before sampling overwrites initial values. Verify that multiple instances of the same primitive definition do not share state.

Following 29.6, collect data from 0/1 at the specified known edge. For data-only changes and the opposite clock edge, retain the current state through the table's hold rows. Unknown data at the specified edge has no matching table row, so require output X. Separate all data updates and clock edges by 1 ns to avoid dependence on evaluation order for simultaneous changes. Unknown clocks, simultaneous input changes, sequential UDP delays/drive strengths, and primitive array forms are out of scope. Instantiate UDP separately in each generate element.

Split each target stimulus across 2 clock cycles. With a common clock, sample all bits on both sides; with partial driving, sample even bits then odd bits, verifying that unselected bits retain their previous state in between. If one subset is empty at width 1, require state retention at that observation too. The 10 known-value stimuli comprise 8 histories representing bit positions 1–129, plus all-0 and all-1 controls. Even with partial driving, all bits have sampled the stimulus after round 2, allowing each position to be identified.

Immediately before each of the 3 X/Z stimuli, sample all-1 across all bits. Unknown bits converted to bit therefore become 0, while UDP sampling unknown bits of logic becomes X; both are distinguishable from the retained 1. Perform type conversion when storing into the source, and verify that Z in logic is treated like X at the input of UDP, in accordance with 29.2. For each stimulus, display raw input, stored source, actual clock, and UDP output before the edge, after sampling, and after the return edge.

guard's input is the bitwise inverse of source, but guard's clock does not run while target is being checked. guard is a control that retains its own initial state regardless of repeated data changes. Finally restore target to all-1 and stop its clock, then give 10 known-value stimuli while driving only guard. Verify that guard actually operates and samples all bits, while target retains all-1 throughout that interval. Prevent false passes caused by a stopped control that never operated, and distinguish confused clock connections or states. Independently verify that all 258 target histories of up to 129 bits and inverted guard histories differ.

[Generator](../generators/interaction_udpstate.py) creates an expected string by updating the selection bit and state of the stimulus directly. [Independent model](../tools/test_interaction_udpstate.py) takes the clock, data, and current state of each UDP to a separate object, interprets the transition table, and processes data change, capture edge, and return edge as separate events. Checks agreement on all 864 rows, preparation with all 1, sampling every bit through 2 subsets, distinguishing 258 histories, guard retention and later operation, conversion order, and if/case equivalence.

In [Saved run of kirimasim when added](../coverage/interaction-results/cross52-kirimasim-3550d774.json), all 36 cases returned PASS, successfully satisfying all 165 pairs, 68 combinations of 3 factors, and 6 mandatory cases. All 36 cases also agreed on fixed [Icarus 13.0](../coverage/interaction-results/udpstate-20261101-icarus13.json). The 2 target cases agreed on fixed Verilator 5.052 for [seed 1](../coverage/interaction-results/udpstate-20261101-verilator5.052-seed1.json) and [seed 73](../coverage/interaction-results/udpstate-20261101-verilator5.052-seed73.json). These 2 cases have width 1, offset 0, known inputs, and target/guard initial values both fixed at 0/1. The other 34 cases can have X in the initial state even with known inputs, so they are 4-state tests excluded from comparison. Registered Icarus for 36 cases and the Verilator oracle only for the 2 cases that agreed across both seeds, then reran the final generated artifacts. Expected values and legal target scope are retained.

For [Fault injection](../coverage/interaction-qualification/20261101-udpstate.json), the 6 positive controls agreed on the latest `3550d77474f1`. Detected 21 fault types as output differences after normal termination: missing initial 0, incorrect initial 1, fixing an uninitialized value at 0, wrong generate selection/UDP kind/guard initialization category, swapping bit / logic and bypassing conversion, omitting guard inversion, swapping target/guard clocks or sharing partial drives, incorrect capture edges/values, missing hold rows at data changes and return edges, incorrectly holding on unknown samples, reusing upper bits, omitting the guard clock, and connecting multiple outputs to the same bit. Do not add this count to the ordinary suite's pass count.

Recheck the latest upstream against the build version immediately before execution, then rerun [Verification tools](../tools/qualify_udpstate.py). Use a new destination without overwriting historical evidence.

```sh
python3 tools/qualify_udpstate.py --kirimasim BIN --commit VERIFIED_COMMIT \
  --output coverage/interaction-qualification/NEW-udpstate.json
```

These additions increase the ordinary suite by 36, to 10,006 total cases, 3,569 generated cases, and 2,256 short-selection cases. [Build evidence](../coverage/interaction-qualification/20261101-udpstate-build.json) stores the version incorporating the preceding upstream update, unchanged source, binary fingerprints before/after execution, unchanged inputs for the previous 2,220 cases, and 18 cases with improved result classifications. The 18 class-method cases changed from unsupported to pass after the implementation update; the remaining 18 cases in the model are still unsupported. Output differences in the existing 6 cases remain. Compared the existing 51 models' plans and 145 saved runs' aggregates/files against [Fingerprints before execution](../coverage/interaction-qualification/20261101-udpstate-prior-digests.json) and retained them unchanged. No new requirement mappings are registered; the requirement-coverage denominator and verification rate are retained.

All 530 tool regression tests and 11 consistency checks succeeded. Metadata covers 10,006 cases with 0 new issues (395 known issues). These are local check results, treated separately from full runs of GitHub Check and Nightly for this change.

<a id="interfaceヘッダのimportとpackage関数の型変換"></a>

### Interface-header imports and package-function type conversion

`interface_header_import` combines the interface of chapter 25 with header import and re-export of chapter 26 and type conversion of chapter 6. Existing [Types and functions in interface headers](../tests/ch26/test_package_import_interface_header_function.sv) and [Interface header elements](../tests/ch25/test_interface_declaration_all_header_elements.sv) are unchanged. Moved Chapter 25 × Chapter 26 and Chapter 6 × Chapter 26 from R requiring review to M finite models. Map all 36 cases to Chapter 25 × Chapter 26, and 24 cases passing X/Z to Chapter 6 × Chapter 26.

- Reference width: 1, 32, 33, 64, 65, 129 bits. The package's word_t type: bit / logic. Input: known / X / Z.
- Selected package: A / B. Define same-named parameters, types, and functions with distinct widths, tags, and operations.
- Header import: wildcard / explicit import / through re-export. Interface header: ANSI / non-ANSI.
- Target parameters: defaults / reduce width only / increase width and change the tag. guard retains the default value.

All 1,296 rows are legal; none are excluded for lack of support. Retain all 183 factor pairs, 78 priority 3-factor combinations, and 6 mandatory cases in 36 cases. Priority groups comprise 36 combinations of reference width × word_t type × input; 12 combinations of package × import form × header form; 12 combinations of package × parameter specification × header form; 18 combinations of import form × word_t type × input.

Following 26.4 and 25.3, the name imported in the header is passed to the default value of the parameter, the port declaration, and the interface body. Package A has the reference width and tag 11; package B has reference width +1 and tag 23. For both, input type raw_t is a logic vector, and type word_t is the selected bit/logic vector. A's encode function inverts the bits; B's performs XOR on the low 2 bits.

In the relay package on the re-export path, explicitly import the 5 items BASE, MARK, raw_t, word_t, and encode before exporting them. In 26.6, names that are merely wildcard-import candidates are not all automatically re-exported. Use a path carrying the 5 actually imported items into the interface as their original declarations. Conflicting imports, type-parameter changes, modports, virtual interfaces, and time-consuming package subroutines are out of scope.

Place same-named BASE, MARK, word_t, and encode in the caller with different values or definitions. Interface parameter defaults use imported BASE / MARK; require the input type and function to bind to the package declarations too. Meanwhile, instance-specified `.W(BASE), .TAG(MARK)` uses declarations in the caller's scope. Width-only specification reduces the width to `max(1, 基準幅/2)` and keeps the default tag. Width-and-tag specification uses the caller's reference width +3 and 99. guard, created from the same interface definition, serves as a control unaffected by target overrides.

raw uses reference width +2 bits, wider than both packages' inputs, so input-port truncation is also observed. incoming remains logic and retains X/Z; from it, the assignment to the interface's word_t variable typed and the input to the package function encode are created separately. Under 13.5.1 and 6.11.2, require conversion to the formal argument's word_t type before the function performs its operations. For example, in bit, converting the unknown input to 0 before inversion produces 1. This differs from 0, which inverts to X first and then converts back to bit. In logic, inverting or applying XOR to Z produces X.

stored is the function return value; echo is formed by narrowing/zero-extending stored to the specified width, then applying XOR with the tag. Display raw, incoming, typed, stored, echo, their actual widths, and W/TAG. Even if tag XOR cancels an intermediate error, separately evaluate values before/after conversion and after the operation. word_t is an unsigned vector; also check that its most significant bit 1/X is not sign-extended when widening.

Known inputs comprise 9 position-encoding rounds and all-0 / all-1, totaling 11 rounds. Give target and guard distinct encodings to distinguish 262 positions across 2 raw-input paths of up to 131 bits and 524 histories including their inverses. For X/Z cases, place 1 unknown values each at the lowest, highest, and middle positions of the retained range and at the highest raw bit discarded by the port. In the final stimulus, require discarded unknown bits not to contaminate incoming or later stages. Display both instances from a 1 process 1 ns after each update, avoiding dependence on zero-delay evaluation order.

[Generator](../generators/interaction_ifimport.py) builds expected values by string truncation, type conversion, operations, and width changes. [Independent model](../tools/test_interaction_ifimport.py) computes observations from a name environment containing original package declarations and re-export references, separate parameter environments for the caller and each instance, integral values/X/Z masks, and formal-argument conversions. Verify agreement on all 1,296 lines, distinguishable 524 histories, scope differences, references to re-exported declarations, equivalence of ANSI/non-ANSI, guard independence, and absence of effects from discarded unknown bits.

In [Saved run of kirimasim when added](../coverage/interaction-results/cross53-kirimasim-4fb5f6b1.json), all 36 cases returned PASS, successfully satisfying all 183 pairs, 78 combinations of 3 factors, and 6 mandatory cases. All 36 cases also agreed on fixed [Icarus 13.0](../coverage/interaction-results/ifimport-20261101-icarus13.json). The 12 target known-value cases agreed on fixed Verilator 5.052 for [seed 1](../coverage/interaction-results/ifimport-20261101-verilator5.052-seed1.json) and [seed 73](../coverage/interaction-results/ifimport-20261101-verilator5.052-seed73.json). The 24 X/Z cases are 4-state tests and are excluded from comparison. Registered Icarus for 36 cases and the Verilator oracle for the 12 cases that agreed across both seeds, then reran the final generated artifacts. Expected values and legal target scope are retained.

For [Fault injection](../coverage/interaction-qualification/20261101-ifimport.json), the 6 positive controls agreed on `4fb5f6b1aec8`. 20 fault kinds were detected through output differences after normal termination: incorrect import/re-export/internal-type/function binding; confusing declaration-default and actual-argument scopes; missing width settings, leaking them into the guard, or applying them to the input type; bypassing formal conversion, swapping bit/logic, or swapping port types; incorrect package operations; sign extension or truncation to 64 bits; missing tags; incorrectly connecting both inputs together; and reusing high bits. Do not add this count to the ordinary suite's pass count. For faults replacing function calls with `~incoming`, records show that 55 lines from 11 known-value rounds still agree, with the first disagreement at the initial unknown-input line 56. This illustrates why known values alone do not establish verification of conversion order.

Recheck the latest upstream against the build version immediately before execution, then rerun [Verification tools](../tools/qualify_ifimport.py). Use a new destination without overwriting historical evidence.

```sh
python3 tools/qualify_ifimport.py --kirimasim BIN --commit VERIFIED_COMMIT \
  --output coverage/interaction-qualification/NEW-ifimport.json
```

These additions increase the ordinary suite by 36, to 10,042 total cases, 3,605 generated cases, and 2,292 short-selection cases. In [Build evidence](../coverage/interaction-qualification/20261101-ifimport-build.json), the version matched to the immediately preceding upstream update, the source unchanged, the binary fingerprint pre and post execution, and the invariance of the input and result classification of the previous 2,256 items are preserved. Compared the existing 52 models' plans and 149 saved runs' aggregates/files against [Fingerprints before execution](../coverage/interaction-qualification/20261101-ifimport-prior-digests.json) and retained them unchanged. No new requirement mappings are registered; the requirement-coverage denominator and verification rate are retained.

All 539 tool regression tests and 11 consistency checks succeeded. Metadata covers 10,042 cases with 0 new issues (395 known issues). These are local check results, treated separately from full runs of GitHub Check and Nightly for this change.

<a id="mailboxのclassハンドルと別名経由の更新"></a>

### Mailbox class handles and updates through aliases

`mailbox_class_alias` combines the object handle from chapter 8 and the mailbox from chapter 15. Moved Chapter 8 × Chapter 15 from addition candidate C1 to M finite model. Retain existing [Sending and receiving class handles](../tests/ch15/test_mailbox_class_handle_messages.sv) and add verification combining width, state type, read method, update timing, capacity, and null.

- Width: 1, 32, 33, 64, 65, 129 bits. Member type: bit / logic. Input: known / X / Z.
- mailbox: packet-typed / typeless. Send the same packet type; type mismatches are out of scope.
- Front retrieval: get / try_get / peek / try_peek. The call occurs after inserting the target, so correct behavior does not wait.
- Updates through sender: before retrieval / after retrieval / both. Also update through the retrieved handle in every case.
- Capacity: 2 / unbounded. Message 3: another object / null.

Select 36 cases from all 3,456 possibilities, retaining all 245 factor pairs, 92 priority 3-factor combinations, and 9 mandatory cases. Priority groups comprise 36 combinations of width × state type × input; 16 combinations of mailbox typing × retrieval method × capacity; 24 combinations of retrieval method × update time × capacity; 16 combinations of retrieval method × capacity × message 3. Even covering the first 36 combinations requires 36 rows, so this model's selection count reaches that lower bound. This does not establish the minimum test count for the whole language or optimality of other models.

Under 15.4.3, 15.4.4, 8.4, and 8.12, a mailbox stores an object handle rather than an object copy. Prepare objects a, b, and c with distinct tags 11, 22, and 33; send a and b first. The 3-th try_put returns 0 for capacity 2, and a positive value for an unbounded instance. Check success using `> 0` without fixing a positive return value to a particular integer. Accepting null also increases the message count by 1.

Write a's members before/after retrieval and check retrieved handle r's value and identity. Values written through r must also propagate to a. peek retains messages and get removes them; separately observe num immediately after retrieval and the FIFO order from the final nonblocking read. Count null as a successful read too, distinguishing it from return value 0 for an empty mailbox. Do not access members through null. For empty try_get / try_peek, compare return value 0 and message count without additionally assuming that output arguments retain their values.

Put a separate object with tag 99 in the independent guard mailbox. Check both retention while operating on the target and updates after retrieving from guard. Controls retaining the same initial value alone cannot detect confused destinations or stalled updates. Concurrent operations by multiple processes, blocking waits on empty/full mailboxes, waiter selection order, type mismatches, and inherited handles are outside this model's scope.

Known inputs comprise 10 rounds of base-2 position encoding and all-0 / all-1, totaling 12 rounds. Drive the 4 paths a, b, c, and guard with distinct histories, distinguishing 1,032 histories that include up to 516 bit positions and their inverses. For X/Z cases, apply unknown values to 1 bit(s) each at the least significant, most significant, and middle positions, and check 0 conversion by bit and preservation by logic. Repeated known-value stimuli distinguish confused objects or inputs even at width 1 bits.

[Generator](../generators/interaction_mailbox.py) calculates expected values from FIFO's final ordering and update-stage strings. [Independent model](../tools/test_interaction_mailbox.py) computes observations by manipulating integral values/X/Z masks, separate Packet objects, and bounded queues. Verify agreement on all 3,456 lines, satisfaction and lower bounds for 36 rows, distinguishable 1,032 histories, null versus empty, bidirectional updates through aliases, and 4-state conversion.

In [Full regression on kirimasim `d0865eb65999`](../coverage/interaction-results/cross54-kirimasim-d0865eb6.json), all 36 new cases are unsupported because the mailbox type is unsupported. Do not exclude these from the plan; retain execution-verified combinations as 0. Fixed [Icarus 13.0](../coverage/interaction-results/mailbox-20261101-icarus13.json) also rejects all 36 cases during build; they are known. Of 12 known-value cases, 11 typed cases agreed on fixed Verilator 5.052 for [seed 1](../coverage/interaction-results/mailbox-20261101-verilator5.052-seed1.json) and [seed 73](../coverage/interaction-results/mailbox-20261101-verilator5.052-seed73.json). The remaining 1 typeless cases cannot use the type-parameter default and are rejected during build; they are known. Registered a fixed oracle only for these 11 cases and reran both seeds with the final generated artifacts. The 24 X/Z cases are excluded from comparison with fixed Verilator. Do not treat unsupported/known as success; retain denominators and standard-derived expected values for typeless and 4-state cases. [Build evidence](../coverage/interaction-qualification/20261101-mailbox-build.json) and [Existing fingerprints](../coverage/interaction-qualification/20261101-mailbox-prior-digests.json) show the version immediately before execution, binary invariance, inputs and result classifications for the previous 2,292 cases, and preservation of existing models and saved runs.

In [Fault injection](../coverage/interaction-qualification/20261101-mailbox.json), the 6 mandatory known-value / typed cases on fixed Verilator 5.052 agreed as positive controls. Detected 19 error types, including incorrect object copying, FIFO order, confusing peek/get, capacity limits, omitted updates, confused mailboxes, mishandled null, and truncation to 64 bits, as output differences after successful build and execution. This fault injection does not establish execution verification of typeless or X/Z behavior. Auxiliary-record counts do not contribute to ordinary test counts.

```sh
python3 tools/qualify_mailbox.py --verilator verilator --seed 1 \
  --output coverage/interaction-qualification/NEW-mailbox.json
```

Use [Execution tools](../tools/qualify_mailbox.py) for rechecking and specify a new output file. These additions increase the ordinary suite by 36 to 10,078 cases; generation has 3,641 cases, and the short-run selection has 54 models and 2,328 cases. Register no new requirement mappings; retain the requirement-coverage denominator and verification rate.

All 546 tool unit tests and 11 consistency checks succeeded. Metadata covers 10,078 cases with 0 new issues (395 known issues). Retained plans/aggregates for the existing 53 models and 153 saved runs, and the existing 6,714 generated files unchanged. These are local check results, distinct from full runs of GitHub Check and Nightly.

<a id="イベント変数の再結合と登録済み待機の保持"></a>

### Re-association of event variables and retention of registered waits

`event_rebinding` combines the event type of chapter 6 and the named event wait of chapter 15. Moved the Chapter 6 × Chapter 15 cross-check, which had checked 1 existing examples with [Triage ledger](chapter-cross-triage.en.md), to a finite model. The original [test_event_rebinding_retains_old_wait](../tests/ch6/test_event_rebinding_retains_old_wait.sv) is retained.

Factors are storage location (module/interface/package), wait method (direct/input/ref), rebinding time (before call/after call but before registration/after registration), trigger (blocking/NBA), initial alias path (direct/relay), old/new event notification order (2 possibilities), and main-waiter count (1/2/3). Select 27 cases from 648 legal combinations, preserving all 138 factor pairs, 69 priority 3-factor combinations, and 6 mandatory cases. Priority groups comprise 27 combinations of storage location × wait method × rebinding time; 18 combinations of wait method × rebinding time × trigger; 12 combinations of alias path × notification order × waiter count; 12 combinations of rebinding time × trigger × notification order. Covering the first 27 combinations requires at least 27 rows; this finite model's selection reaches that lower bound. This does not give the minimum test count for other models or the whole language.

Under 6.17 and 15.5.5.1, event assignment shares a synchronization object; it does not mutually bind the variables themselves. Rebinding does not change an already registered wait target; only subsequent waits use the new handle. Combining 13.5.1 and 13.5.2 exposes the difference: input copies the handle at call time, while ref and direct references use its value at wait registration.

Call the main waiter at time 2 and register `@` at time 4. Rebind the selected event at time 1/3/5, avoiding same-time registration/rebinding races whose order the standard does not define. Only when rebinding occurs at time 3 does input wait on the old object while ref/direct references wait on the new object. Rebinding at time 5 does not change any already registered wait on the old object, regardless of method.

A late waiter called at time 6 waits on the new object; place independent waiters on the separately retained old handle and noise. Also display unused main-waiter slots to distinguish aggregation into 1 entries and excess wakeups. Change the relay handle to noise at time 7 and verify that the change does not propagate to previously copied handles. Notify noise at time 9 and old/new objects at time 11/13; verify that another notification at time 15/17 does not restart the completed 1-iteration wait. Only the generating side displays, at a separate tick.

Before each notification, schedule payload NBA, distinguishing values read in the blocking trigger's Active region from updated values read after waking on a NBA trigger. Simultaneously observe per-slot counts, wakeup times, payloads, and the identity of selected/copied/relay/new handles. At time 20 after all waits complete, set only selected to null and verify retention of the other handles. Include triggering null as a legal operation, but there are no unfinished waiters at that point, so the stimulus does not detect an incorrect notification target. Do not wait on null because the result is undefined. `triggered`, `wait_order`, and resource reclamation for automatic events are also outside this model's scope.

[Generator](../generators/interaction_event_rebind.py) calculates expected values in closed form from whether the handle is selected at call or registration time and from the first notification time. [Independent reference model](../tools/test_interaction_event_rebind.py) creates separate synchronization objects and processes task frames, timed registrations, per-object waiting queues, and 2-region notifications in order. Checked expected-value agreement on all 648 lines, satisfaction of 27 rows, late arrivals, aliases, noise, and unused slots. Also verified that the selected stimuli produce observation differences for 13 abstract error types. This checks sensitivity in the reference model; it is not successful fault injection through execution on SystemVerilog.

Fetched and checked upstream main immediately before execution, then built kirimasim `ddf48e2b0436` in Release configuration. All 27 cases pass syntax and semantic analysis, but [Behavioral execution](../coverage/interaction-results/cross55-kirimasim-ddf48e2b.json) does not support event-value operations. All 27 cases in [Icarus 13.0](../coverage/interaction-results/event-rebind-20261101-icarus13.json) and in [seed 1](../coverage/interaction-results/event-rebind-20261101-verilator5.052-seed1.json) / [seed 73](../coverage/interaction-results/event-rebind-20261101-verilator5.052-seed73.json) on Verilator 5.052 also fail to build and are known. No fixed oracle was added. Do not interpret syntax acceptance or agreement of independent calculations as behavioral execution PASS; retain legal factors and standard-derived expected values. Rerun on a future supporting version, and perform SystemVerilog fault injection after the positive controls operate correctly.

I also saved [Build and analysis records](../coverage/interaction-qualification/20261101-event-rebind-build.json) and [Preserving existing inputs and records](../coverage/interaction-qualification/20261101-event-rebind-prior-digests.json). The total is 55 models and 2,355 cases: 2,170 pass, 179 unsupported, and 6 existing failures. Preserved inputs/result classes for the existing 2,328 cases, plans for 54 models, existing-model aggregates for 157 saved runs, and 6,786 generated files. The full suite increased by 27 to 10,105 cases, with 3,668 generated cases. Register no new requirement mappings; retain the requirement-coverage denominator and verification rate.

All 552 local tool unit tests and 11 consistency checks succeeded. Metadata checks cover 10,105 cases with 0 new issues and 395 known issues. All 765 local links in the document are also valid. These are local check results, distinct from full runs of GitHub Check and Nightly.

<a id="dpiの書戻しとnbaの値代入先の確定"></a>

### DPI copyback and NBA capture

`interaction_dpi_nba.py` implements the chapter 10×35 P1 candidate as `dpi_nba_capture@1`.
It passes static fixed-array elements to DPI `input`, `output` and `inout int` formals and schedules an NBA before or after the call.
Same/different elements, widths 8/32/65, signed/unsigned and bit/logic define 144 legal rows. The 18 selected cases retain
all 81 factor pairs, 48 targeted triples and four anchors: 87.5% fewer rows, without a claim about elapsed-time savings.

The return value and all elements immediately after the call expose copy-in, copyback and conversion to int.
The NBA RHS XORs the DPI actual element with a payload, so scheduling after an output/inout call must use the copied-back value.
The source element, both indices and payload then change. Postponed and next-time observations check every element,
distinguishing wrong captured bits, a wrong destination and damaged neighbors. A single module process orders these operations;
there is no `#0` wait or competing process. Clauses 35.6.1, 35.6.1.1, 35.6.2, 10.4.2, 10.8 and the event-region rules govern the expectations.
The C helper never reads an output argument's unspecified initial value, and its arithmetic cannot overflow.

Fixed Verilator 5.052 at [seed 1](../coverage/interaction-results/cross56-dpi-nba-verilator5052-seed1.json) and
[seed 73](../coverage/interaction-results/cross56-dpi-nba-verilator5052-seed73.json) records 14 pass and 4 known each.
Four 65-bit output/inout actuals stop on internal build errors. They retain standard-derived expectations and have no fixed oracle;
only the other 14 gain that oracle. All 18 parse and type-check in the latest kirimasim build, but its runner marks them unsupported
because C loading is unavailable. Fixed-release partial success is not added to kirimasim success.

The [independent checks and fault injection](../coverage/interaction-qualification/dpi-nba.json) use bit strings and the actual C ABI
to recalculate all 144 rows. After a passing control, four faults—immediate update, late value/index capture, lost copyback and wrong
signedness—were detected by output differences, rather than compilation failures. The [latest-build and parse record](../coverage/interaction-qualification/dpi-nba-build.json)
is also saved. Reproduce with fixed Verilator 5.052 and a C compiler, choosing a new output filename:

```sh
python3 tools/qualify_dpi_nba.py --verilator /path/to/verilator-5.052 --cc cc \
  --output coverage/interaction-qualification/NEW-dpi-nba.json
```

X/Z, open arrays, NBAs into dynamic arrays, C-to-SV reentry, time-consuming DPI tasks, competing processes and scalar-variable
copyback are outside this model. It does not qualify all of chapter 35 or every DPI boundary.

<a id="継承制約の動的な選択と失敗時の値の保持"></a>

### Constraint inheritance and failure retention

`interaction_constraint.py` implements the chapter 8×18 P1 candidate as `constraint_inheritance@1`.
Base/derived handles, replacement/addition, pure/concrete constraints, inline/extern leaf definitions,
success→failure→success/failure→success→failure and widths 4/8/33 define 96 legal rows. The 13 selected cases retain
all 70 factor pairs, 40 targeted triples and four anchors: 86.46% fewer cases, without a claim about elapsed-time savings.

A root, middle and leaf class inherit an a-value constraint and the relation `b == a + 3`.
Replacing a same-name block selects the leaf value; adding a new-name block also retains the base value constraint.
The middle class always implements a pure constraint inline; the extern factor applies to the leaf's replacement/addition.
A non-rand flag switches between a unique solution and a contradiction. Each call checks its return and all rand fields.
First failure preserves sentinel words; failure after success preserves the preceding solution. A separate object, called
through the opposite static handle type, must succeed every time. These are legal simulation tests of unsatisfiable constraints,
rather than illegal-design rejection tests. Expected output does not depend on RNG sequences or search order.
Clauses 18.5.1, 18.5.2, 18.6.1, 18.6.3, 8.13 and 8.21 govern the observations.

All 13 cases pass fixed Verilator 5.052 at [seed 1](../coverage/interaction-results/cross57-constraint-verilator5052-seed1.json)
and [seed 73](../coverage/interaction-results/cross57-constraint-verilator5052-seed73.json), and gain that fixed oracle.
All 13 parse and type-check in the latest kirimasim build, but randomize is unsupported. Fixed-release success is not
added to kirimasim success. The [latest-build and parse record](../coverage/interaction-qualification/constraint-inheritance-build.json) is saved.

The [independent checks and fault injection](../coverage/interaction-qualification/constraint-inheritance.json) compose named
constraint blocks and enumerate candidate values, separately from the closed-form oracle, to check solutions, contradictions
and state transitions for all 96 rows. After passing replacement and addition controls, five faults—lost override, missing
added constraint, failure clobbering, aliased guard and use of base constraints instead of leaf constraints—were detected
by output differences, rather than compilation failures. Reproduce with fixed Verilator 5.052 and Z3, choosing a new output filename:

```sh
python3 tools/qualify_constraint_inheritance.py --verilator /path/to/verilator-5.052 \
  --output coverage/interaction-qualification/NEW-constraint-inheritance.json
```

X/Z, randc, soft, constraint_mode, rand_mode, callbacks, parallel solvers, RNG sequence matching, re-abstracted pure constraints
and extern completion in the middle class are outside this model. It does not qualify every class or constraint feature.

<a id="clocking変数とアサーションの評価クロック"></a>

### Clocking inputs and assertion clocks

`interaction_clockassert.py` implements the chapter 14×16 P1 candidate as `clocking_assertion_sampling@1`.
Widths 1/8/33, bit/logic, independent sample/probe polarities, early/edge/between writes, blocking/NBA and default/explicit
input skew define 288 legal rows. The 18 selected cases retain all 109 pairs, 50 targeted triples and four anchors: 93.75% fewer rows.
The width×state×timing projection alone has 18 combinations, requiring at least 18 rows for this plan; the selection meets that lower bound.
This is neither an elapsed-time saving nor a claim that other models' selections are minimal.

Clause 16.5.1 requires #1step sampling for clocking inputs referenced by assertions. Default and explicit #1step are equivalence controls;
#0 and time skews that are legal for ordinary clocking input use are not legal levels here. In each 20-tick cycle, writes occur at 6, 8 or 10;
the clocking event is at 8, the independent probe clock at 12 and reporting at 14. Three single-cycle assertions compare the clockvar at
`@(cb)`, the same clockvar on the other clock, and raw data on that other clock. Both actions save sampled and Reactive live vectors
separately; delayed reports check counts and every bit. Known zero/ones and complementary patterns provide positive and negative controls,
distinguishing incorrect resampling and missing actions. Clauses 16.18, 16.5.1, 16.9.3, 16.14.1, 14.13, 14.10 and 14.4 govern the observations.
Blocking and NBA writes intentionally have the same expected observations here, checking consistency of both paths. This model does not
observe between Active and NBA or qualify NBA value/destination capture.

Both fixed Verilator 5.052 [seed 1](../coverage/interaction-results/cross58-clockassert-verilator5052-seed1.json) and
[seed 73](../coverage/interaction-results/cross58-clockassert-verilator5052-seed73.json) pass all 18 cases, which gain that fixed oracle.
All 18 parse and type-check in the latest kirimasim build, but concurrent assertion statements are unsupported.
The [latest-build and parse record](../coverage/interaction-qualification/clockassert-build.json) is saved; fixed-version success is not added to kirimasim success.

The [independent checks and fault injection](../coverage/interaction-qualification/clockassert.json) compare all 288 rows with a separate
history of timed and region-ordered updates. After passing edge-write and between-clock controls, five faults—resampling on the other clock,
confusing live action data with sampled data, using the wrong clocking-assertion event, reversing the sample polarity and missing a fail action—
were detected by output differences. Compile failures and illegal non-#1step inputs are not counted as detected faults. Reproduce with fixed
Verilator 5.052 and a new output filename:

```sh
python3 tools/qualify_clockassert.py --verilator /path/to/verilator-5.052 \
  --output coverage/interaction-qualification/NEW-clockassert.json
```

X/Z, rejection of non-#1step misuse, output skew, programs, disable iff, temporal operators, simultaneous clocks and virtual interfaces are
outside this model. It checks separate assertions on different clocks, not temporal properties spanning multiple clocks.

<a id="dpi-open-arrayの形状と書戻し"></a>

### DPI open array shape and copyback

`interaction_dpi_array.py` implements the chapter 7×35 P1 candidate as `dpi_openarray_shape@1`.
It crosses ascending/descending fixed arrays, dynamic arrays and queues with input/output/inout, initial sizes 1/3/5,
positive/mixed-sign words, numerical ascending/descending C traversal, and stable/resized calls.
Of 288 Cartesian rows, clause 7.7 forbids 48 dynamic-array/queue open-output rows; 72 fixed-array resize rows have no meaning in this model.
The 30 cases selected from 168 legal rows retain all 100 pairs, 72 targeted triples and four anchors: 82.14% fewer cases.
The actual×direction×length projection alone has 30 legal combinations, requiring at least 30 rows; this plan meets that lower bound.
This is not an elapsed-time saving or whole-chapter coverage. No legal rows are excluded for tool limitations.

Every test calls the same import twice and resets all elements for each call. Fixed arrays use negative ascending bounds or descending
bounds ending above zero. Dynamic arrays and queues resize 1→3, 3→5 or 5→2, checking each call's shape after growth or shrinkage.
C reports `svLeft`, `svRight`, `svLow`, `svHigh`, `svIncrement`, `svSize` and `svDimensions` and obtains each element pointer by its
original SV index, without assuming contiguous whole-array layout. Observations include every C before/after value, an order-sensitive
checksum, every SV element on return and an independent guard array. Input is unchanged; output writes every element without reading
its initial value; inout combines input values with original indices. Clauses 7.7, 35.5.6.1, 35.6.1.1, H.7.6, H.12.2, H.12.4 and 20.7
govern these observations.

Both fixed Verilator 5.052 [seed 1](../coverage/interaction-results/cross59-dpi-array-verilator5052-seed1.json) and
[seed 73](../coverage/interaction-results/cross59-dpi-array-verilator5052-seed73.json) pass the 18 static-array cases.
Only those 18 gain the fixed oracle. The 12 dynamic-array/queue cases have known internal build errors for unsupported DPI open-array
actuals and retain spec expectations. Build failures are neither behavior verification nor passes of illegal-design tests.

The normal runner marks all 30 cases unsupported before execution because latest kirimasim `f2d9a1136576` cannot load C code.
[Separate parsing](../coverage/interaction-qualification/dpi-array-build.json) accepts 24 and rejects 6 queue cases during argument type
matching. Those 6 remain legal positive cases under clause 7.7. The C-loading preflight prevents these parse errors from appearing in
the normal runner classification; the 24 successful parses are not counted as DPI execution passes.

The [independent checks and fault injection](../coverage/interaction-qualification/dpi-array.json) compare expectations for all 168 rows
with a separate explicit stimulus table. The actual C helper also runs all 168 rows against a test-owned ABI stub with two output
initialization poisons. Separated element slots and canaries check element-wise access and detect out-of-bounds writes.
These auxiliary checks qualify the C helper and expectations, not simulator marshalling or copyback of dynamic arrays and queues.
On fixed Verilator, one normal control passes and five faults—wrong bounds, reversed traversal, lost SV copyback, lost input sign and
reusing the first call's phase—are detected by output differences, not build failures.

On 2026-11-12 the expected value of `svIncrement` was corrected. 20.7 gives `$increment` the value -1 for every queue or dynamic array dimension, and H.12.2 gives the C queries the same semantics. The rule that compares the left and right bounds is for a fixed-size dimension.
The model had applied that rule to a dynamic array or queue of one element and expected 1. The expected text changed for 32 of the 168 rows and for four of the 30 selected cases. The legal rows, the selection and the designs did not change, so the model stays version 1.
The independent check has the same correction, and its ABI stub now knows whether the actual can change its size. The [new record](../coverage/interaction-qualification/dpi-array-20261112.json) again covers all 168 rows, the control and the five faults. The generator and the check were corrected from the same reading of 20.7, so their agreement does not confirm that reading.
[Every legal row ran once](../coverage/interaction-qualification/dpi-array-all-rows-20261112.json). Verilator 5.052 matches the 72 rows with a fixed-size actual and cannot build the 96 rows with a dynamic array or queue. kirimasim does not load C code and Icarus Verilog 13.0 has no DPI. So none of the three executes a row whose expectation changed.
The 30 selected cases ran again on [Icarus Verilog 13.0](../coverage/interaction-results/dpi-array-20261112-icarus13.json) (30 known) and on Verilator 5.052 with [seed 1](../coverage/interaction-results/dpi-array-20261112-verilator5052-seed1.json) and [seed 73](../coverage/interaction-results/dpi-array-20261112-verilator5052-seed73.json) (18 pass and 12 known each), as before. `generators/oracles.txt` did not change.

```sh
python3 tools/qualify_dpi_array.py --verilator /path/to/verilator-5.052 \
  --output coverage/interaction-qualification/NEW-dpi-array.json
```

X/Z, empty arrays, multiple dimensions, sized formals, ref arguments, retained element pointers/handles and C reentry are outside scope.
This model uses only open formals; clause 35.5.6 permits implementation-dependent restrictions on actuals for sized array formals.
All registered P1 candidates have moved into finite models; P2/P3 candidates and unreviewed pairs remain, so this is not completion of
verification across all chapter pairs.

<a id="クラスの浅いコピーと配列領域要素ハンドル"></a>

### Class array storage and shared elements

`interaction_class_array.py` implements the chapter 7×8 P2 candidate as `class_array_shallow_copy@1`.
It crosses fixed/dynamic arrays and queues, widths 1/8/33, initial lengths 1/3, first/last positions, shallow copy/handle assignment,
mutation through the source/copy, and element replacement/resizing. Excluding 48 meaningless fixed-array resize rows from 288 Cartesian
rows leaves 240 legal rows. The 18 selected cases retain all 108 pairs, 60 targeted triples and four anchors: 92.5% fewer cases.
The container×width×copy projection alone needs 18 rows, so this plan meets that lower bound. This is neither an elapsed-time saving
nor coverage of every class or array feature. No legal rows are excluded for unsupported tools.

Under clause 8.12, shallow copying creates a new holder with independent array-element storage. Objects referenced by element handles
remain shared. Ordinary handle assignment is the control that shares the holder itself. Each holder has a bit-vector array and a
same-shaped handle array. Four sequential snapshots observe the copy, a shared element-object update, replacement or resizing in one
holder, and a later update through a saved element handle. Every vector, null and payload is checked, together with holder/element
identity and an independent guard. The constructor count remains two and the copied stamp is retained, checking that shallow copy
does not rerun the constructor.

Dynamic arrays use `new[size](old)`; queues use push_back/pop_back to grow 1→3 or shrink 3→1. Dynamic growth checks zero/null defaults; queue growth explicitly pushes zero/null. Checks also include the preserved prefix,
unchanged size and values in the other shallow copy, and saved-handle lifetime after shrinking or replacement.
First/last positions for length one are equivalence controls. Clauses 8.12, 8.8, 7.6, 7.5.1, 7.10.2.5 and 7.10.2.7 govern these observations.

Both fixed Verilator 5.052 [seed 1](../coverage/interaction-results/cross60-class-array-verilator5052-seed1.json) and
[seed 73](../coverage/interaction-results/cross60-class-array-verilator5052-seed73.json) pass all 18 cases, which gain that fixed oracle.
All 18 parse and type-check in latest kirimasim; 6 fixed-array cases pass and 12 dynamic-array/queue cases encounter unsupported array-property operations.
The [latest-build, parse and execution record](../coverage/interaction-qualification/class-array-build.json) is saved; fixed-version
success and parsing success are not added to kirimasim execution passes.

The [independent checks and fault injection](../coverage/interaction-qualification/class-array.json) compare all 240 rows with a separate
Python object graph: the generator's closed-form snapshots are checked against actual object identities, lists and copy operations.
Two fixed-array/resize controls pass. Six faults—aliasing instead of shallow copying, deep-copying referenced elements, omitting vector
elements, rerunning the constructor, writing the wrong index and leaking a resize into the other holder—are detected by output
differences. Build failures are not counted as detected faults. Reproduce with fixed Verilator 5.052 and a new output filename:

```sh
python3 tools/qualify_class_array.py --verilator /path/to/verilator-5.052 \
  --output coverage/interaction-qualification/NEW-class-array.json
```

X/Z, empty arrays, inheritance/base-handle paths, rand state, covergroups, ref arguments and concurrent execution are outside scope.
This does not qualify custom deep-copy methods or UVM copy implementations.

<a id="解決済み駆動強度と表示文字列整形"></a>

### Resolved strength formatting

`interaction_strengthfmt.py` implements the chapter 21×28 P2 candidate as `resolved_strength_format@1`.
It crosses wire/tri0/tri1, five drive-strength pairs, AB/BA update order, display/sformatf/swrite and normal/inverted polarity.
The 31 selected cases retain all 87 pairs, 78 targeted triples and four anchors from 180 legal rows: 82.78% fewer selected cases.
The [fixed Icarus Verilog 13.0 run](../coverage/interaction-results/cross61-strength-format-icarus13.json) passes all 31, which gain that oracle.

Each continuous assignment has one matching strength for logic zero and one. Pairs use equal weak/pull/strong or strong versus weak.
Only known 0/1 and Z drive the net; opposite values at equal maximum strength create X. This model does not inject ambiguous strengths.
Checks cover released-wire HiZ, tri0/tri1 pull defaults, stronger-driver dominance and equal-strength contention. Eleven observations
cover the initial release, half/full updates for four 0/1 pairs, and two release steps. Every write and observation is separated by one
tick so continuous assignments settle. Polarity and update order change the intermediate path to the final value.

The same scalar net is passed directly to `%v` in `$display`, `$sformatf` or `$swrite`. Drive inputs, resolved logic and strength strings
are checked separately. String APIs overwrite a poisoned variable and report it with `%s`; isolated supply0/supply1 nets provide Su0/Su1
controls. Clauses 21.2.1.4, 21.3.3, 28.12.1, 28.15.1, 6.6.5 and 10.3.4 govern the observations.
The scope includes known-value/X mnemonics at We/Pu/St and HiZ. L/H, numeric strength ranges, trireg, wired logic, vectors, delayed gates
and file output are outside scope. Positive cases do not qualify strength propagation through variables; fault injection checks an
incorrect variable argument. No legal rows are excluded for unsupported tools.

At addition time, kirimasim `f2d9a1136576` parsed all cases but reported unsupported `%v`; that [record](../coverage/interaction-qualification/strength-format-build.json) is retained.
The current kirimasim `80859f34f0aa` [full cross run](../coverage/interaction-results/cross62-kirimasim-80859f34.json) passes all 31 cases with unchanged input fingerprints.
Parsing and fixed-version successes are not added to kirimasim execution passes.

The [independent checks and fault injection](../coverage/interaction-qualification/strength-format.json) compare all 180 rows with a
separate drive-contribution table and priority truth table. All three API controls pass; five faults—ignored strengths, swapped driver
strengths, a variable in place of the net, the wrong format code and a stale string—are detected by output differences. Build failures
are not counted as detected faults. Reproduce with an explicit 13.0 binary directory and a new output filename; saved JSON retains the
actual version string:

```sh
python3 tools/qualify_strength_format.py --iverilog-bin /path/to/icarus-13.0/bin \
  --output coverage/interaction-qualification/NEW-strength-format.json
```

<a id="クラス内virtual-interfaceの再結合と保存参照"></a>

### Class virtual interface rebinding

`interaction_vif_class.py` implements the chapter 8×25 P2 candidate as `class_virtual_interface@1`.
It crosses widths 1/8/33, bit/logic, full/modport types, initial A/B bindings, shallow copy/class-handle assignment, mutation through
the source/copy and method/direct-property writes. The 13 selected cases retain all 96 pairs, 48 targeted triples and four anchors
from 192 legal rows: 93.23% fewer selected cases. Known bit/logic and full/modport paths are equivalence controls; no legal rows are
excluded for unsupported tools.

Three interface instances share one type and have distinct tags 11/22/33 and independent data. The modport exposes data by ref and tag
as input. A shallow class copy has a separate virtual-interface binding variable; ordinary class-handle assignment shares the holder.
Both initially reference the same actual interface, and rebinding one distinguishes independent slots from a shared class object.
Seven snapshots cover copying, the first write, rebinding, the other-interface write, a guarded null write, a saved-reference write and
restoration. They check every actual data bit, tags, class/binding identities, successful-write counts and an independent guard.
The saved reference continues to address the original interface and writes it while the actor is null.

Clause 25.9 defines compatible bindings, comparisons and null, and requires a fatal error for null member access. These positive cases
use comparisons and guards without dereferencing null or increasing the successful-write count. Read methods return neutral zero and
tag -1; null writes return zero. The other binding and actual interface data are checked simultaneously.
Clauses 25.9, 25.9.2, 25.10, 25.5, 8.4 and 8.12 govern the observations. X/Z, incompatible types, fatal null dereferences, inheritance,
clocking, time controls and concurrent drivers are outside scope.

Both fixed Verilator 5.052 [seed 1](../coverage/interaction-results/cross62-vif-class-verilator5052-seed1.json) and
[seed 73](../coverage/interaction-results/cross62-vif-class-verilator5052-seed73.json) pass all 13 cases, which gain that oracle.
All 13 parse and type-check in latest kirimasim but encounter unsupported full/modport virtual-interface types in classes.
The [latest-build, parse and execution record](../coverage/interaction-qualification/vif-class-build.json) is saved; parsing and
fixed-version successes are not combined into execution passes.

The [independent checks and fault injection](../coverage/interaction-qualification/vif-class.json) compare all 192 rows with a separate
Python object graph. Closed-form snapshots are checked against sequential operations on interface objects, class copies and reference
bindings. Full/modport/class-alias controls pass; six faults—aliasing instead of copying, lost rebinding, an overwritten saved reference,
lost writes, null-state mutation and stale reads—are detected by output differences. Build failures are not counted as detected faults.

```sh
python3 tools/qualify_vif_class.py --verilator /path/to/verilator-5.052 \
  --output coverage/interaction-qualification/NEW-vif-class.json
```

<a id="clocking-eventのガードとサンプル保持"></a>

### Clocking event guards and held samples

`interaction_clockiff.py` implements the chapter 9×14 P2 candidate as `clocking_event_iff@1`.
It crosses widths 1/8/33, bit/logic, posedge/negedge, input #1step/#0, blocking/NBA, scalar/33-bit-low/33-bit-high guards and before/after
guard updates. The 12 selected cases retain all 109 pairs, 44 targeted triples and four anchors from 288 legal rows: 95.83% fewer cases.
The width×state×skew projection alone needs 12 rows, so this plan meets that lower bound.

A warm-up establishes a known zero clockvar. Four raw edges alternate desired guards 0/1/0/1. Guards change two ticks before or four
ticks after an edge, never in the same slot. Each cycle reports one tick before the edge and two/five ticks after it, including a read
one tick after the selected guard update. Thirteen snapshots including warm-up check raw counts, cb wake counts, live data, clockvar
and the observer's saved sample. Clause 9.4.2.3 evaluates iff on the original event; changing only the guard does not wake it. The timing
separates erroneous guard-only wakeups from accepted-edge sampling.

A module writer updates data on every raw edge. On accepted edges, clause 14.13 makes #1step retain the prior value and #0 sample the
updated Observed value. The observer waits on cb and reads after clockvar updates; rejected edges retain the prior sample.
Blocking/NBA paths intentionally have the same expected observations here. This model does not observe between Active and NBA or
qualify NBA value/destination capture. It uses no assertions; #0 input is a legal positive case under clause 14.13.
Clauses 14.3, 14.13, 14.10, 14.4, 9.4.2.3 and 12.4 govern these observations.

Both fixed Verilator 5.052 [seed 1](../coverage/interaction-results/cross63-clockiff-verilator5052-seed1.json) and
[seed 73](../coverage/interaction-results/cross63-clockiff-verilator5052-seed73.json) pass the 4 scalar-guard cases, which alone gain the
fixed oracle. The 8 legal cases passing a vector directly to `iff enabled` have internal build errors and retain spec expectations.
No legal rows are excluded for unsupported tools; build failures are neither behavior verification nor passes of illegal-design tests.
All 12 parse and type-check in latest kirimasim but encounter unsupported guarded clocking events.
The [latest-build, parse and execution record](../coverage/interaction-qualification/clockiff-build.json) is saved.

The [independent checks and fault injection](../coverage/interaction-qualification/clockiff.json) compare all 288 rows with a separate
time/operation-ordered event queue. Of three auxiliary normal controls, the two vector controls alone use `iff (|enabled)`. This has
the same known-value truth condition and avoids the fixed tool's internal error to check timing and sampling expectations.
These controls are not added to execution passes for the original 8 vector cases; the JSON records the transformation.
Six faults—dropped iff, guard changes becoming clock edges, wrong skew, testing only the low guard bit, missing observer capture and
wrong clock polarity—are detected by output differences. Build failures are not counted as detected faults.

```sh
python3 tools/qualify_clockiff.py --verilator /path/to/verilator-5.052 \
  --output coverage/interaction-qualification/NEW-clockiff.json
```

X/Z, same-slot guard updates, output skew, programs, interface paths, multiple clocks and assertions are outside scope.
Guards use known values; the model checks 33-bit truth and event-acceptance boundaries.

<a id="associative-array-domains-and-allocation"></a>

<a id="連想配列の添字型と割当て済み範囲の問い合わせ"></a>

### Associative-array index domains and allocated bounds

`interaction_assocquery.py` models the chapter 7×20 P2 candidate as `associative_array_queries@1`.
It crosses key widths 4/8/33, unsigned/signed indices, compact/extreme keys, ascending/descending/zigzag insertion, low/middle/high deletion
and omitted/explicit dimension one. The 18 cases retain all 93 pairs, 54 targeted triples and four anchors from 216 legal rows:
91.67% fewer cases. The keys×order×delete projection alone needs 18 rows, so this plan meets that lower bound.

Clause 20.7 makes associative-array `$left` return zero, `$right` the index type's maximum and `$increment` minus one.
`$low`/`$high` describe allocated extrema, while `$size` counts entries. The index domain and allocated bounds are distinct.
The return type is integer, so 33-bit query results convert to 32 bits: for example, unsigned maximum 8589934591 becomes -1.
Queries are observed after storage in integer variables. Because this destination also converts to 32 bits, the test does not independently distinguish the return width of the function expression itself.
In contrast, first/last output arguments and foreach indices keep the key type. Full-width keys and signed ordering under clause 7.8.4
are checked separately. Clauses 20.7, 7.8, 7.8.4, 7.8.7, 7.9.1, 7.9.2, 7.9.4, 7.9.5 and 12.7.3 govern these observations.

Each case has ten snapshots: empty, three insertions, overwrite, deleting the selected key, deleting a missing key, reinsertion,
clearing and reuse. Every snapshot reports domain queries, counts via query/num/size, nonempty extrema via query/first/last,
and every allocated key/value. Overwrite must not allocate another entry, deleting a missing key must preserve others,
and reuse after clearing must not retain old values. Empty low/high and first/last output arguments are never read.
The [existing direct test](../tests/ch20/test_associative_array_query_functions.sv) retains the empty-low/high X rule;
it is not added to this finite model's execution evidence.

Fixed Verilator 5.052 [seed 1](../coverage/interaction-results/cross64-assocquery-verilator5052-seed1.json) and
[seed 73](../coverage/interaction-results/cross64-assocquery-verilator5052-seed73.json) execute all 18 cases but have output differences.
Already in the initial empty state, right=0 and increment=1 differ from the standard-derived values.
[Fixed Icarus Verilog 13.0](../coverage/interaction-results/cross64-assocquery-icarus13.json) rejects all 18 builds at the typed associative
declaration. Every oracle remains spec; neither expectations nor legal rows are changed to accommodate differences.
All 18 new cases parse in latest kirimasim but encounter unsupported typed associative-array variables.
The [build, parse and execution record](../coverage/interaction-qualification/assocquery-build.json) is saved.

The [independent check](../coverage/interaction-qualification/assocquery.json) compares all 216 rows using a list of entries and literal
boundary tables, separate from the generator's dictionary. Six Python specification-model mutations use allocated high as domain right,
reverse extrema, use span as entry count, allocate on overwrite, ignore deletion, or sort signed keys as unsigned.
Selected cases distinguish every mutation from the expected output. These are Python model mutations, not executed SystemVerilog faults
or successful simulator normal controls. Correct full-output reproduction and fault detection by simulator execution remain unverified.

```sh
python3 tools/qualify_assocquery.py \
  --output coverage/interaction-qualification/NEW-assocquery.json
```

X/Z, nonintegral or wildcard keys, multidimensional arrays, concurrent updates and queries of empty-state X values are outside scope.
The model records standard review and independent expectation checks while retaining the lack of full-output reproduction by fixed tools.

<a id="array-reduction-constraints-and-retention"></a>

<a id="配列リダクション制約の型と失敗時の状態保持"></a>

### Array-reduction constraint types and state retention

`interaction_randreduce.py` implements the chapter 7×18 P2 candidate as `array_reduction_constraint@1`.
It crosses widths 4/8/33, unsigned/signed elements, fixed/dynamic arrays, sum/product, element type/longint inside with, lengths 2/3,
and success/failure/success versus failure/success/failure. Thirteen cases retain all 96 pairs, 40 targeted triples and four anchors
from 192 legal rows: 93.23% fewer cases. No minimum-size claim is made.

Clauses 18.5.7.2 and 7.12.3 use the element type without with, or the with-expression type when present.
An unsigned maximum or signed minimum followed by 3 or -3 distinguishes narrow overflow in sum/product from extension before arithmetic.
All wide results fit signed 64 bits. Assigning an ordinary reduction to a wider variable must not widen the reduction itself;
this path is observed separately from the explicit with cast. Both reduction-expression widths are reported with $bits.
Clauses 18.5.7.2, 7.12.3, 18.5.7.1, 18.6.1, 18.6.3 and 6.24.1 govern these observations.

Per-element equalities make the successful solution unique. A non-rand flag offsets only the reduction target by one, making it infeasible.
This model tests how types and arithmetic affect constraint satisfiability; it does not search a free array for an arbitrary solution.
Each of three calls reports status, size, all element bits, natural/wide results and expression widths. A separate object always succeeds.
Failure must retain initial twos or the preceding solution under clause 18.6.3. A dynamic array starts one element larger than required:
first-attempt failure must retain its size, while success must apply the constrained size.

Fixed Verilator 5.052 [seed 1](../coverage/interaction-results/cross65-randreduce-verilator5052-seed1.json) and
[seed 73](../coverage/interaction-results/cross65-randreduce-verilator5052-seed73.json) have output differences on all 13 original cases.
In the 8 fixed cases, assignment to the wide observation variable does not retain the narrow result; the 5 dynamic cases differ in status
or output including diagnostics. [Fixed Icarus Verilog 13.0](../coverage/interaction-results/cross65-randreduce-icarus13.json) rejects all 13 builds.
Every oracle remains spec. Expectations and legal rows are retained, and auxiliary success does not register an original-case oracle.
The latest kirimasim [build, parse and execution record](../coverage/interaction-qualification/randreduce-build.json) shows all 13 parse:
8 fixed cases use unsupported randomize, and 5 dynamic cases use unsupported class-array operations.

The [independent checks and auxiliary controls](../coverage/interaction-qualification/randreduce.json) compare all 192 rows using literal
endpoints and bit-serial addition/multiplication. Four auxiliary controls use fixed arrays and add an element-type cast only to the natural
observation assignment. Expected output and constraint expressions remain unchanged; this avoids the fixed tool's observation-path difference.
These controls are not passes for the original 13 cases and do not qualify dynamic-array size retention by execution.
Seven faults are detected by output differences after normal termination: dropped reduction constraint, wrongly widened element arithmetic,
truncation before a later extension, zero-extension of signed elements, value corruption after failure, aliased guard object and wrong method.
Syntax errors, build failures and timeouts are not counted as detected faults.

```sh
python3 tools/qualify_randreduce.py --verilator /path/to/verilator-5.052 \
  --output coverage/interaction-qualification/NEW-randreduce.json
```

Empty arrays, X/Z, queues, soft constraints, inheritance, callbacks, concurrent randomize and matching random streams are outside scope.
Original full-output reproduction and execution verification of dynamic size retention remain unmet, separate from auxiliary-control results.

<a id="generate-default-disable-scopes"></a>

<a id="generateスコープのdefault-disable-iff"></a>

### Default disable iff across generate scopes

`generate_default_disable@1` in `interaction_gendisable.py` extends the reviewed Chapter 16 × 27 witness into a factor model.
Under 16.15, a default's names resolve in its declaration scope, its condition extends into child generate scopes,
and an inner default or an explicit condition takes precedence. The model also checks same-name child signals and declarations after assertions.

<a id="因子と観測"></a>

#### Factors and observations

Factors are if/case/loop generate form, parent-default inheritance versus outer-generate override, inner shadow signals,
default/explicit-zero/explicit-condition selection, condition updates before launch/between clocks/by NBA at the final clock, and declaration order.
The selection preserves all 93 factor pairs, 60 targeted three-factor combinations and four mandatory cases in 18 of 216 legal rows.
Two instances have separate local and explicit conditions and independent counters.

Each case has seven phases: no condition, parent condition, each instance's local and explicit conditions, and a successful consequent.
`start |=> datum` launches at time 5 and concludes at 15. Conditions are asserted from time 2 to 12, from 8 to 12, or by NBA at 15.
A pulse entirely between clocks also disables a pending attempt; a final-clock condition uses its current unsampled value (16.12).
`start` falls at time 10. Counts distinguish the new vacuous success at the final clock from the earlier attempt's success or failure.
Disabled attempts execute neither success nor failure actions.

Explicit-zero guards at both sites and a module-scope assertion provide controls; reports occur at time 19.
Same-name signals invert the original conditions, making incorrect rebinding observable.
X/Z, multiple clocks, nested module declarations, interface/program, explicit disable inside a property and assertion control are outside scope.

<a id="保存実行と確認範囲"></a>

#### Saved runs and verification limits

Fixed Verilator 5.052 [seed 1](../coverage/interaction-results/cross66-gendisable-verilator5052-seed1.json) and
[seed 73](../coverage/interaction-results/cross66-gendisable-verilator5052-seed73.json) each record 5 pass and 13 known.
Only the five matches receive an oracle. Output differences affect six interclock-pulse cases, six final-clock NBA cases,
and one before-launch case using a local default. In the last case, pulsing one local condition changes the other instance's
observed action counts relative to expectations. The internal implementation cause is unverified.
[Fixed Icarus Verilog 13.0](../coverage/interaction-results/cross66-gendisable-icarus13.json) rejects all 18 builds.

The [build and parse record](../coverage/interaction-qualification/gendisable-build.json) on kirimasim `2edfebbc6270` confirms all 18 parse successfully;
execution reports unsupported `ConcurrentAssertion`. The [full 2,557-case run](../coverage/interaction-results/cross66-kirimasim-2edfebbc.json)
has 2,207 pass, 344 unsupported and six existing fail results. All 2,539 preceding input fingerprints and outcomes are unchanged.
Unsupported and known differences are not PASS; standard-derived expectations and the legal space are retained.

<a id="独立した検算と故障注入"></a>

#### Independent calculations and fault injection

The [independent checks and executions](../coverage/interaction-qualification/gendisable.json) compare the generator's closed-form counts
against a separate scope-tree resolver and a scoreboard that advances pending attempts one time step at a time, covering all 216 rows.
Four selected before-launch cases that match fixed Verilator are normal controls. Six SV mutations detect a dropped inherited condition,
wrong condition source, ignored explicit zero, ignored explicit condition, shared conditions between instances and a missing guard action.
All ten control/mutant executions exit zero; detection does not rely on build rejection or execution failure.

These controls do not qualify implicit generate-default overrides, interclock cancellation or final-clock NBA through execution.
They do not resolve the original 13 differences or kirimasim's 18 unsupported cases. Repeating selected cases as controls does not add tests.

Local validation at addition passed 661 tool tests and 13 consistency checks.
Metadata validation covered 10,307 tests with no new issues (395 known); 114 language pairs and 52,201 local links also passed validation.
Check GitHub Check/Nightly status against each execution's commit separately.

```sh
python3 tools/qualify_gendisable.py --verilator /path/to/verilator-5.052 \
  --output coverage/interaction-qualification/NEW-gendisable.json
```

<a id="distribution-expression-binding"></a>

<a id="dist制約と演算子の優先順位"></a>

### Distribution constraints and operator precedence

`distribution_expression_binding@1` in `interaction_dist.py` extends the existing Chapter 11 × 18 precedence witness into a factor model.
It crosses precedence and left associativity (11.3.2), expression widths/signedness (11.6.1 and 11.8), and distribution support/weights (18.5.3).
A unique positive-weight solution permits exact checks of randomize status and every bit without statistical frequency assumptions.

<a id="因子と観測-1"></a>

#### Factors and observations

Factors are widths 4/8/33, signed/unsigned words, addition with shift/multiplication/comparison, implicit/whole/altered grouping,
`:=`/`:/`, singleton/zero-alternative/overlapping items, and repeated success/success-failure-success/failure-success-failure.
The selection preserves 154 factor pairs, 81 targeted three-factor combinations and eight mandatory cases in 31 of 972 legal rows.

Expression shapes are `x + 1 << 1`, `x + 1 * 2` and `x + 1 < threshold`.
Actual literals for one, two and threshold have the same width and signedness as x.
Parentheses changing them to `x + (1 << 1)`, `(x + 1) * 2` or `x + (1 < threshold)` are separate levels.
In the last form, the unsigned one-bit comparison also makes the surrounding sum unsigned.
Two or three candidates per width expose negative values, high bits, the 32-bit boundary and overflow before comparison.
This does not cover every representable input value.

Overlapping zero and positive weights are added; a zero item alone does not exclude a value that also has a positive item.
Ranges contain a single value. Multi-value range probability ratios and statistical differences between `:=` and `:/` are outside scope.
All-zero weights leave no solution; failed randomization retains initial all-one bits or the previous solution (18.5.3, 18.6.3).
A separate object always succeeds as a control. Every call prints status, all bits, typed decimal values, expression results and widths.
X/Z, real values, randc, default distributions, inheritance, callbacks and concurrent randomize are outside scope.

<a id="保存実行と確認範囲-1"></a>

#### Saved runs and verification limits

Fixed Verilator 5.052 [seed 1](../coverage/interaction-results/cross67-dist-verilator5052-seed1.json) and
[seed 73](../coverage/interaction-results/cross67-dist-verilator5052-seed73.json) each record 19 pass and 12 known.
Only the 19 repeated-success cases receive an oracle. In the 12 alternating success/failure cases, randomize returns one even with all weights zero,
differing from the standard-derived failure and retention expectations. The internal implementation cause is unverified.
[Fixed Icarus Verilog 13.0](../coverage/interaction-results/cross67-dist-icarus13.json) rejects all 31 builds.

The [build and parse record](../coverage/interaction-qualification/dist-build.json) on kirimasim `50f1f77b8c94` confirms all 31 parse successfully;
execution reports unsupported randomize. The [full 2,588-case run](../coverage/interaction-results/cross67-kirimasim-50f1f77b.json)
has 2,207 pass, 375 unsupported and six existing fail results. All 2,557 preceding input fingerprints and outcomes are unchanged.
The legal space and expectations are retained; unsupported and known differences are not PASS.

<a id="独立した検算と故障注入-1"></a>

#### Independent calculations and fault injection

The [independent checks and executions](../coverage/interaction-qualification/dist.json) read the generated declarations, expressions,
candidates, distribution items and call order. A separate typed-expression parser, candidate enumeration and additive weights check all 972 rows.
The generator's solution and arithmetic functions are not reused.

Controls are four original success-only cases and one auxiliary failure-after-success case.
The auxiliary adds the independent contradiction `if (impossible) x != x;`. The standard already leaves no solution in that condition,
but this addition bypasses fixed Verilator's all-zero-weight difference to observe failure status and retained values.
It does not qualify rejection due to all-zero weights themselves or first-failure observations.

Seven SV mutations detect wrong grouping for the three operations, a wrong positive-weight candidate, a wrong overlapping range,
clobbering after failure and sharing the control object. All 12 control/mutant executions exit zero;
detection does not rely on build rejection or execution failure. Auxiliary success does not qualify the original 12 differences or add duplicate tests.

Local validation at addition passed 667 tool tests and 13 consistency checks.
Metadata validation covered 10,338 tests with no new issues (395 known); 114 language pairs and 52,291 local links also passed validation.
Check GitHub Check/Nightly status against each execution's commit separately.

```sh
python3 tools/qualify_dist.py --verilator /path/to/verilator-5.052 \
  --output coverage/interaction-qualification/NEW-dist.json
```

<a id="aggregate-event-lifetime"></a>

<a id="構造体内イベントと自動タスクの寿命"></a>

### Aggregate events and automatic task lifetime

`aggregate_event_lifetime@1` selects 18 cases for the Chapter 7×15 interaction.
The generator is [`interaction_eventlife.py`](../generators/interaction_eventlife.py).
Structure members and whole assignments follow 7.2/7.2.2; default event initialization follows 6.8/6.17;
the scope lifetime that includes children after task return follows 6.21/9.3.2.
Waits, triggers, aliases, null and comparisons follow 15.5.1/15.5.2/15.5.5.1–15.5.5.3.

<a id="因子と観測-2"></a>

#### Factors and observations

Storage is scalar/struct/nested struct; capture is direct/copy; call count is 1/2/3.
Alias release occurs before registration/after registration/after wakeup; triggers are blocking/NBA;
call trigger order is forward/reverse; listener count is 1/2.
The selection retains all 123 factor pairs, 54 targeted triples and six anchors from 432 legal combinations in 18 cases.

Each automatic task creates a fresh event and a `100 + tag` payload, then returns with children outstanding.
Children register their wait two ticks later and read the local payload after waking.
Copy rows assign the whole structure, then rebind the original event to noise and overwrite its payload.
Scalar rows copy the event and integer separately as controls.
Clearing one caller alias to null leaves the trigger alias and waiting children holding the original object.

Observe identity across calls, null state, each listener's hit count, wake time, automatic payload and static stamp.
An NBA to stamp is queued before the event trigger to distinguish Active and NBA wakeup reads.
Stimulus, registration, release and observation occur in separate ticks; listeners update separate array slots.
Noise, repeated pulses after completion and a fresh call after clearing all retained aliases are included.
Null waits, triggered, ref arguments, delayed NBA triggers, GC timing and physical memory reclamation are outside scope.

<a id="独立検算と実行の限界"></a>

#### Independent checks and execution limits

[`qualify_eventlife.py`](../tools/qualify_eventlife.py) reads the emitted SV task and straight-line driver.
It independently models object identities, automatic frames, structure copies, wait registrations and an ordered NBA queue.
It does not reuse the generator's expected-output calculation or timetable; all 432 rows match.
The [check record](../coverage/interaction-qualification/eventlife.json) also records eight source mutations:
a missing copy, reading the overwritten original, sharing events across calls, late registration,
early release of the trigger alias, the wrong trigger target, double counting and a missing scalar payload copy.
These produce output differences or stranded registrations in the independent interpreter; they are not executed SV fault injections.

Fixed Verilator 5.052 [seed 1](../coverage/interaction-results/cross68-eventlife-verilator5052-seed1.json) and
[seed 73](../coverage/interaction-results/cross68-eventlife-verilator5052-seed73.json) reject all 18 builds because event assignment is unsupported.
[Fixed Icarus Verilog 13.0](../coverage/interaction-results/cross68-eventlife-icarus13.json) also rejects all 18 builds.
No fixed-release oracle is added; standard-derived expectations are retained.
Successful simulator controls and runtime mutation detection remain unconfirmed.

kirimasim `50f1f77b8c94` parses all 18 inputs in the [build/parse record](../coverage/interaction-qualification/eventlife-build.json)
but event-value operations are unsupported on execution.
The [full 2,606-case run](../coverage/interaction-results/cross68-kirimasim-50f1f77b.json) records
2,207 pass, 393 unsupported and six existing failures. All preceding 2,588 input fingerprints and status categories are unchanged.
Plan completion is not execution fulfillment; unsupported rows remain in the legal universe.

Local validation at introduction passed all 673 tool unit tests and 13 consistency checks.
Metadata checks cover 10,356 tests with zero new problems (395 known); 114 language pairs and 52,327 local links were also checked.
These are local validation results, separate from GitHub Check/Nightly results for this addition.

```sh
python3 tools/qualify_eventlife.py \
  --output coverage/interaction-qualification/NEW-eventlife.json
```

<a id="sv-dpi-array-queries"></a>

<a id="svとdpi-cの配列問い合わせ"></a>

### SV and DPI-C array queries

`sv_dpi_array_queries@2` selects 16 cases for the Chapter 20×35 interaction.
The generator is [`interaction_dpiquery.py`](../generators/interaction_dpiquery.py);
the C probe is [`cross_dpiquery.c`](../tests/ch35/cross_dpiquery.c).
SV queries follow 20.7; open-array matching and ranges follow 35.5.6.1/35.6.1.1/H.7.5/H.7.6/H.12.1;
C queries follow H.12.2.

<a id="因子と観測-3"></a>

#### Factors and observations

Combine 1/2/3 unpacked dimensions, ascending/descending/mixed directions, negative/positive index offsets,
singleton/distinct dimension sizes, packed widths 4/33, sized/open packed formals,
normalized/offset packed actual ranges, the same/different actual on the second call and literal/variable dimension queries.
The selection retains all 176 factor pairs, 63 targeted triples and seven anchors from 832 legal combinations in 16 cases.

Since model version 2 (2026-11-12) a row is legal only when no other direction value declares the same ranges.
A one-element range has no direction, and a normalized packed range is always `[width-1:0]`.
Rows with one-element dimensions keep only the descending value when the packed range is normalized, and the ascending and descending values when it has an offset.
Rows with one unpacked dimension and a normalized packed range keep the ascending and descending values.
This leaves 832 of the 1,152 combinations. Version 1 took all 1,152 as legal and selected one pair of equal tests.

For the same actual, display SV `$dimensions`/`$unpacked_dimensions` and
`$left/$right/$low/$high/$increment/$size` on every dimension, then call the same import for C queries.
C `svDimensions` counts unpacked dimensions; dimension zero is packed and positive dimensions are unpacked.
SV numbers unpacked dimensions before packed dimensions, so its last dimension maps to C dimension zero.
The C packed range is normalized to `[width-1:0]`; unpacked ranges retain the actual indices.
A fixed singleton has `increment=1` even in rows intended as ascending.
C prints every query result and returns a checksum with distinct dimension weights.

Switching actuals changes each unpacked endpoint, direction and size; singleton rows retain size one.
Open packed formals also change width between 4 and 33; sized packed formals retain their declared width.
Dynamic, queue or empty arrays, multiple packed dimensions, X/Z, invalid dimension numbers, sized unpacked formals,
C callbacks and retained C handles are outside scope. Element access and copyback are not verified here.

<a id="独立検算と実際の故障注入"></a>

#### Independent checks and actual fault injection

[`qualify_dpiquery.py`](../tools/qualify_dpiquery.py) reads emitted SV declarations, query expressions and actual-argument call order.
It uses separate index enumeration and dimension tables without reusing generator shape/query calculations; all 832 rows of version 2 match (1,152 rows in version 1).
The actual C probe is also checked over 1,664 calls through a test-owned DPI ABI stub (2,304 calls in version 1).
The stub supplies synthetic shapes and does not qualify simulator DPI marshalling.

Three original sized/normalized-packed anchors cover 1/2/3 unpacked dimensions as successful runtime controls.
Six injected faults swap C endpoints, negate increment, use the wrong packed dimension, omit the last dimension,
use the wrong SV packed dimension or query the old SV shape on the second call.
All nine executions exit zero; detection is through output differences, not unsupported input or build rejection.
The [check/runtime record](../coverage/interaction-qualification/dpiquery-v2.json) of version 2 retains source fingerprints, output and exit codes; the [record of version 1](../coverage/interaction-qualification/dpiquery.json) stays.
These controls do not qualify offset-packed normalization or execution of open packed formals.

<a id="保存実行と未確認の範囲"></a>

#### Saved runs and unconfirmed scope

For version 2, pinned Verilator 5.052 [seed 1](../coverage/interaction-results/edgedpiquery-20261112-verilator5052-seed1.json) and [seed 73](../coverage/interaction-results/edgedpiquery-20261112-verilator5052-seed73.json) each record six pass and ten known results.
The six sized/normalized-packed cases have oracle entries. Four offset-packed cases differ at C dimension zero, and six open-packed cases are rejected during build parsing.
[Pinned Icarus Verilog 13.0](../coverage/interaction-results/edgedpiquery-20261112-icarus13.json) rejects all 16 builds. The kirimasim `7de185f776a1` runner classifies all 16 as unsupported in the [complete 4,413-case run](../coverage/interaction-results/full-20261112-kirimasim-7de185f7-edgedpiquery.json).
One [run of all 832 legal rows](../coverage/interaction-qualification/edgedpiquery-all-rows.json) shows the same on every row: Verilator seed 1 matches the 176 sized/normalized-packed rows, differs at C dimension zero on the 240 sized/offset-packed rows and rejects the 416 open-packed rows. kirimasim and Icarus Verilog execute no row of this model.
The paragraphs below describe the runs of version 1 with its 19 cases.

Fixed Verilator 5.052 [seed 1](../coverage/interaction-results/cross69-dpiquery-verilator5052-seed1.json) and
[seed 73](../coverage/interaction-results/cross69-dpiquery-verilator5052-seed73.json) each record 11 pass and eight known results.
Only the 11 sized/normalized-packed cases receive oracle entries.
Two offset-packed cases report C dimension-zero ranges differing from the normalized range; for example an actual `[4:7]`
reports endpoints/direction different from the expected `[3:0]`. The internal cause is unconfirmed.
Six open-packed cases are rejected during build parsing.
[Fixed Icarus Verilog 13.0](../coverage/interaction-results/cross69-dpiquery-icarus13.json) rejects all 19 builds.

The kirimasim `50f1f77b8c94` [build/parse record](../coverage/interaction-qualification/dpiquery-build.json) records 19 successful parses.
The normal runner classifies C-backed tests as `unsupported` before execution; this record does not establish DPI execution success or failure.
The [full 2,625-case run](../coverage/interaction-results/cross69-kirimasim-50f1f77b.json) records
2,207 pass, 412 unsupported and six existing failures. All preceding 2,606 input fingerprints and status categories are unchanged.
Plan completion and execution fulfillment remain separate; unsupported/known rows and standard-derived expectations are retained.

Local validation at introduction passed all 679 tool unit tests and 13 consistency checks.
Metadata checks cover 10,375 tests with zero new problems (395 known); 114 language pairs and 52,399 local links were also checked.
These are local validation results, separate from GitHub Check/Nightly results for this addition.

```sh
python3 tools/qualify_dpiquery.py --verilator /path/to/verilator-5.052 \
  --output coverage/interaction-qualification/NEW-dpiquery.json
```

<a id="sdf-conditional-paths"></a>

<a id="条件付きspecifyパスとsdfバックアノテーション"></a>

### Conditional specify paths and SDF back-annotation

`sdf_conditional_paths@1` selects 18 cases for the Chapter 30×32 interaction.
The generator is [`interaction_sdfpath.py`](../generators/interaction_sdfpath.py).
State-dependent paths follow 30.4.4/30.4.4.2; SDF/path matching follows 32.4.1;
replacement/addition follows 32.5; rise/fall mapping follows 32.8; annotation scope follows 32.9.
Annotation here means back-annotation of delay values from SDF.

<a id="因子と観測-4"></a>

#### Factors and observations

Seven factors cover plain IOPATH/COND/CONDELSE, ABSOLUTE/INCREMENT, balanced/slow-rise/slow-fall delays,
explicit cell scope versus child instance relative to the caller, target v/g, initial condition 1/0
and identical/opposite sibling conditions. The selection retains all 109 factor pairs, 46 targeted triples
and seven anchors from 288 legal combinations in 18 cases.
The targeted path×mode×profile group has 18 combinations; each test covers one, so this finite plan reaches its 18-case lower bound.
This is not a minimum test count for the entire language.

Both instances receive the same input; annotate only one instance's y path.
Both z outputs and the unannotated sibling's y are delay-retention controls.
The plain y path uses rise/fall 2/4; conditional y uses 2/4 for condition one and 6/2 for condition zero or ifnone.
The z paths retain 4/6. SDF values are 4/4, 8/2 or 2/8; ABSOLUTE replaces defaults and INCREMENT adds to them.
COND matches only the same condition; CONDELSE matches only ifnone.
Plain IOPATH rows also use a plain cell path; applying plain IOPATH to every path of a conditional cell is outside this model.

Each condition receives one rise and one fall. Change selects two ticks before the next data transition.
All delays are positive even numbers up to 14; data transitions are 20 ticks apart;
observations occur 1/3/5/7/9/11/13/15 ticks after each transition.
Record each of four output values, change counts and exact last-change times separately, avoiding observation/update races.
Short pulses, X/Z, edge-qualified paths, equivalent conditions, repeated annotations, min/typ/max, timescale conversion,
INTERCONNECT and TIMINGCHECK are outside scope.

<a id="独立検算と故障注入"></a>

#### Independent checks and fault injection

[`qualify_sdfpath.py`](../tools/qualify_sdfpath.py) reads emitted specify declarations, the SDF actually written by SV,
the annotation call and the stimulus/observation sequence. A separate S-expression parser, conditional path table
and chronological event heap check all 288 rows without reusing generator condition, delay, SDF or expected-output functions.

Three original plain/ABSOLUTE controls execute successfully on fixed Icarus.
Six SV/SDF mutations use the wrong cell scope, swap rise/fall, omit annotation, select the wrong output path,
annotate both instances or corrupt the unannotated z default delay.
All nine executions exit zero; detection is through output differences, not warnings, build rejection or abnormal termination.

Three additional source mutations replace COND with plain IOPATH to match both branches,
replace INCREMENT with replacement semantics or map CONDELSE to condition one.
These produce interpreted output differences and are not executed SV fault injections.
See the [check/runtime record](../coverage/interaction-qualification/sdfpath.json).
The executed controls/mutants do not qualify runtime COND/CONDELSE/INCREMENT behavior.

<a id="保存実行と未確認の範囲-1"></a>

#### Saved runs and unconfirmed scope

[Fixed Icarus Verilog 13.0](../coverage/interaction-results/cross70-sdfpath-icarus13.json) records three pass and 15 known results.
Only the three plain/ABSOLUTE cases receive oracle entries. The other 15 conditional-annotation/INCREMENT cases differ in output.
Fixed Verilator 5.052 [seed 1](../coverage/interaction-results/cross70-sdfpath-verilator5052-seed1.json) and
[seed 73](../coverage/interaction-results/cross70-sdfpath-verilator5052-seed73.json) each record 18 known output differences.
These are not passes; standard-derived expectations and legal rows are retained.

The kirimasim `2ffb5dddca04` [build/parse record](../coverage/interaction-qualification/sdfpath-build.json) records 18 successful parses.
The first unsupported feature reported on execution is conditional specify paths for 12 cases and system task $sdf_annotate for six.
The [full 2,643-case run](../coverage/interaction-results/cross70-kirimasim-2ffb5ddd.json) records
2,207 pass, 430 unsupported and six existing failures. All preceding 2,625 input fingerprints and status categories are unchanged.
Implementation revision and model additions are recorded separately; plan completion is not execution fulfillment.

Local validation at introduction passed all 685 tool unit tests and 13 consistency checks.
Metadata checks cover 10,393 tests with zero new problems (395 known); 114 language pairs and 52,467 local links were also checked.
These are local validation results, separate from GitHub Check/Nightly results for this addition.

```sh
python3 tools/qualify_sdfpath.py --iverilog-bin /path/to/iverilog-13.0/bin \
  --output coverage/interaction-qualification/NEW-sdfpath.json
```

<a id="checker-assertion-sampling"></a>

<a id="checkerとmodule参照モデルのサンプリング"></a>

### Checker and module-reference sampling

`checker_assertion_sampling@1` selects 27 cases for Chapter 16×17, plus Chapter 17×25 with interface placement.
The generator is [`interaction_checksample.py`](../generators/interaction_checksample.py).
Invariant assertion scheduling between checkers and design code follows 17.7.3;
checker declarations, input substitution and outputs follow 17.2/17.3/17.7.1;
sampling/actions follow 16.5.1/16.9.3/16.14.1; default clocking follows 14.12 and interface placement follows 25.3.

<a id="因子と観測-5"></a>

#### Factors and observations

Eight factors cover width 1/8/33, module/interface placement, positional/named/wildcard connections,
updates before/on/after the clock, blocking/NBA assignments, posedge/negedge,
explicit event/checker-local default clocking and nonzero/zero/reduction-XOR predicates.
The selection retains all 174 factor pairs, 63 targeted triples and six anchors from 1,296 legal combinations in 27 cases.
The width×predicate×timing group has 27 combinations, so this finite plan reaches its 27-case lower bound.
This is not a minimum test count for the entire language.

Two instances receive complementary known data; clocks occur at ticks 8/12 of each 20-tick period.
Separate top-level module reference assertions receive the same actuals as each checker.
Checker output arguments expose decision counts, sampled data, sampled predicate, live action data and action time;
no hierarchical references enter a checker. Internal state is initialized in declarations and continuously assigned to outputs.
Output-port default initialization is not required, preventing an unrelated observation feature from blocking every case.
Output-port initialization semantics themselves are outside this model's qualification scope.

Six periods use zeros, ones, single-bit values and complementary backgrounds.
Data updates occur two ticks before, on or two ticks after each clock; final observation is at tick 16.
Properties evaluate Preponed values; both action branches separately record `$sampled(data)` and Reactive `data`.
Final data is also printed to distinguish sampled/live/final values around a same-slot NBA.
X/Z, procedural checker instances, bind, checker procedures, free variables, output NBA, disable iff,
multicycle properties, history functions and programs are outside scope.

<a id="独立検算と実際の故障注入-1"></a>

#### Independent checks and actual fault injection

[`qualify_checksample.py`](../tools/qualify_checksample.py) reads emitted predicates, clocking, connections, output bindings and stimulus.
Separate Preponed/Active/NBA/Reactive state checks all 1,296 rows without reusing generator input, predicate or expected-output calculations.
Agreement between two implementations alone is insufficient; both are compared with independent specification expectations.

Five original controls and seven SV mutations execute: replacing samples with live data, replacing live data with samples,
inverting the checker predicate, swapping output counters, aliasing a reference instance, reversing the explicit clock edge and omitting fail counts.
All 12 executions exit zero; faults are detected through output differences.
Two known differences are replayed separately with complete output and are not counted as controls or detected faults.
See the [independent/fault/replay record](../coverage/interaction-qualification/checksample.json).

<a id="保存実行と共通の誤りを見逃さない照合"></a>

#### Saved runs and checking for common errors

Fixed Verilator 5.052 [seed 1](../coverage/interaction-results/cross71-checksample-verilator5052-seed1.json) and
[seed 73](../coverage/interaction-results/cross71-checksample-verilator5052-seed73.json) each record 25 pass and two known results.
Only the 25 matching cases receive oracle entries. Both remaining cases use a one-bit vector, same-slot NBA and explicit clock:
module placement with posedge/nonzero, and interface placement with negedge/zero.

In the first period, Preponed at tick 8 samples zero; after an NBA updates data to one, the Reactive action should read live value one.
Saved output instead records live zero in both checker and module reference, while final data at tick 16 is one.
The two implementations agree, so comparing them alone misses the error. Independent specification expectations expose the difference.
The internal cause is unconfirmed. These expectations are retained rather than being changed to require only agreement.
[Fixed Icarus Verilog 13.0](../coverage/interaction-results/cross71-checksample-icarus13.json) rejects all 27 builds.

The kirimasim `2ffb5dddca04` [build/parse record](../coverage/interaction-qualification/checksample-build.json) records 27 successful parses.
Execution lacks checker instances. The [full 2,670-case run](../coverage/interaction-results/cross71-kirimasim-2ffb5ddd.json) records
2,207 pass, 457 unsupported and six existing failures. All preceding 2,643 input fingerprints and status categories are unchanged.
Chapter 16×17 maps to all 27 cases; Chapter 17×25 maps to the seven interface cases.
Plan coverage and execution fulfillment remain separate; unsupported/known rows remain in the legal universe.

The existing M4 sampled-function evaluator covers audited single-clock static inputs and report protocols.
The two new spec-only candidates use checker input substitution/output connections and two clocks, so reasons are recorded in the
[source-hashed deferral ledger](../tools/sva_reference/fixtures/m4_deferred.json).
The [current M4 inventory](../coverage/interaction-qualification/checksample-m4.json) records seven matches, 44 deferrals and zero unhandled cases.
These two are not M4 matches; cross-specific independent checks remain separate.
A changed source fails the deferral hash check and returns to unhandled until re-audited.

Local validation at introduction passed all 692 tool unit tests and 13 consistency checks.
Metadata checks cover 10,420 tests with zero new problems (395 known); 114 language pairs and 52,565 local links were also checked.
M4 deferrals retain the previous seven matches and 42 deferrals, with regression checks returning changed inputs to unhandled.
These are local validation results, separate from GitHub Check/Nightly results for this addition.

```sh
python3 tools/qualify_checksample.py --verilator /path/to/verilator-5.052 \
  --output coverage/interaction-qualification/NEW-checksample.json
```

<a id="program-assertion-attempts"></a>

<a id="programとmodule参照モデルのアサーション試行"></a>

### Program and module-reference assertion attempts

`program_assertion_attempts@1` adds 27 cases for Chapters 16×24.
The generator is [`interaction_progassert.py`](../generators/interaction_progassert.py).
Program assertions retain invariant sampling/evaluation under 24.3.1; new attempts on each leading clock follow 16.14.5.
Sampling follows 16.5.1/16.9.3, implication completion follows 16.12.7,
actions follow 16.14.1 and default vacuous-success actions follow 20.11.

<a id="因子と観測-6"></a>

#### Factors and observations

Seven factors cover width 1/8/33, plain/overlapped/nonoverlapped properties,
updates two ticks before/on/two ticks after the clock, blocking/NBA assignment,
posedge/negedge, positional/named/wildcard connections and three/five clock ticks per instance.
From 648 legal combinations, 27 cases retain all 138 factor pairs, 75 targeted triples and six anchors.
The width×property×timing group has 27 combinations, so this finite plan reaches its 27-case lower bound.
This is not a minimum test count for the entire language.

Each case has two program instances and two module references receiving the same actuals per site.
Known complementary stimuli include the high bit of each width.
Distinct clocks occur at ticks 8/12 of each 20-tick period; observations at tick 16 use output arguments only.
No external hierarchical reference enters a program. Programs have no initial procedures,
keeping implicit simulation termination from completed program procedures outside the stimulus.

Both action branches record decision counts and 64-bit sums of action-time `$sampled(req/ack)` for
`(|ack)`, `(|req) |-> (|ack)` and `(|req) |=> (|ack)`.
Vacuous success executes the default pass action, but expectations distinguish it from nonvacuous success.
A nonoverlapped consequence and a current vacuous success can complete on the same tick.
Use commutative counts/sums instead of an order-dependent last value.
Do not count a final pending attempt as successful before its consequent clock.
X/Z, disable iff, history functions, program procedures/termination, clocking blocks, checkers, bind,
multiclock properties and action controls are outside scope.

<a id="独立検算故障注入と確認範囲"></a>

#### Independent checks, fault injection and limits

[`qualify_progassert.py`](../tools/qualify_progassert.py) parses emitted program/module declarations,
connections, properties, actions and stimulus. Separate Preponed/Active/NBA state and per-instance pending attempts
check all 648 rows without reusing generator stimulus or expected-output calculations.

Six original plain/overlapped controls and seven actual SV faults execute on fixed Verilator.
Faults replace samples with live data, invert the predicate, swap output counters, delay an overlapped consequence,
alias a reference instance, reverse the clock or swap req/ack.
All 13 executions exit zero; faults are detected through output differences.
Two separate known nonoverlapped differences are replayed and are not counted as controls or detected faults.
These controls/mutations do not establish correct runtime nonoverlap behavior.
See the separate categories in the [independent/runtime record](../coverage/interaction-qualification/progassert.json).

<a id="保存実行と未確認の範囲-2"></a>

#### Saved runs and unconfirmed scope

Fixed Verilator 5.052 [seed 1](../coverage/interaction-results/cross72-progassert-verilator5052-seed1.json) and
[seed 73](../coverage/interaction-results/cross72-progassert-verilator5052-seed73.json) each record 18 pass and nine known results.
Only the 18 matching cases receive oracle entries.
All nine nonoverlapped cases record a success while the first nonvacuous attempt is still awaiting its consequent clock.
Both program and module reference show this difference in the two separate replays, so comparing them alone misses it.
Independent specification-derived attempt starts/completions expose the discrepancy; expectations are retained.
The internal cause is unconfirmed.
See [fixed Icarus Verilog 13.0](../coverage/interaction-results/cross72-progassert-icarus13.json) and the
[build record](../coverage/interaction-qualification/progassert-build.json) for Icarus results and kirimasim revision, parsing and execution from latest upstream.

kirimasim `786c94bbeafb`, built from upstream main fetched immediately before execution, parses all 27 new inputs.
Execution lacks concurrent assertions for all 27. The [full 2,697-case run](../coverage/interaction-results/cross72-kirimasim-786c94bb.json)
records 2,207 pass, 484 unsupported and six existing failures. All preceding 2,670 input fingerprints and status categories are unchanged.
47 models pass their full selection. Plan coverage and execution fulfillment remain separate; unsupported rows remain legal combinations.
Fixed Icarus rejects all 27 new builds.

The M4 reference evaluator retains its audited input/report scope.
Nine new spec-only candidates require separate auditing of program connections, two clocks, pending attempts and sum reports;
register [source-hashed deferral reasons](../tools/sva_reference/fixtures/m4_deferred.json).
The [current M4 comparison](../coverage/interaction-qualification/progassert-m4.json), using existing input traces,
records seven matches, 53 deferrals and zero unhandled cases. All previous 44 deferrals and seven matches are retained.
This is not a new simulator execution or an M4 support pass.
Source changes fail the deferral hash check and return to unhandled until re-audited, with regression checks enforcing this.

Local validation at introduction passed all 700 tool unit tests and 13 consistency checks.
Metadata checks cover 10,447 tests with zero new problems (395 known); 114 language pairs and 52,661 local links were also checked.
These are local validation results, separate from GitHub Check/Nightly results for this addition.

```sh
python3 tools/qualify_progassert.py --verilator /path/to/verilator-5.052 \
  --output coverage/interaction-qualification/NEW-progassert.json
```

<a id="container-coverage-sampling"></a>

<a id="コンテナ更新前後のカバレッジサンプリング"></a>

### Coverage sampling around container mutations

`container_coverage_sampling@1` adds 33 cases for Chapters 7×19.
The generator is [`interaction_cgsample.py`](../generators/interaction_cgsample.py).
Storage/copies follow 7.4.1/7.5/7.10; dynamic allocation/deletion follow 7.5.1/7.5.2;
reverse follows 7.12.2; coverpoints/bins follow 19.5/19.5.1; options follow 19.7;
queries/sample arguments follow 19.8/19.8.1 and percentages follow 19.11.1.

<a id="因子と観測-7"></a>

#### Factors and observations

Eight factors cover fixed/dynamic/queue storage, overwrite/reverse/replacement/clear-and-recreate,
samples before/after/both sides, live/sample-argument binding, first/last position,
one/two required hits, all/nonempty samples and initial length one/three.
Of 1,152 combinations, only 96 illegal fixed-array clear rows are excluded, leaving 1,056 legal rows.
33 cases retain all 172 factor pairs, 79 targeted triples and six anchors.
The 33 legal container×operation×sampling triples establish this finite plan's 33-case lower bound.
No rows are excluded because of implementation support.

Copy a container into a same-type control; mutate only target a through three stages while control b remains unchanged.
Replacement changes dynamic/queue lengths between one and three, retaining fixed-array length.
Clear cases delete, recreate and delete again. Single-element reversal and fixed-array size are unchanged controls.
Sample twice at each selected boundary and report both containers' size/first-or-last value and coverage percentages
after each sample and at unsampled boundaries. Check that an unsampled mutation alone does not advance bin history
and distinguish the first from the second hit.

Size has four bins for zero through three. Value has four bins for zero through three plus a regular singleton bin
for the empty-container sentinel -1. A function checks size before returning -1, avoiding any element read when empty.
Do not assume iff alone prevents an out-of-bounds read. The nonempty guard suppresses both coverpoints for empty samples.
Set `option.at_least` directly on each coverpoint, separating it from group-default inheritance.
Each group contains a single coverpoint, so group `get_inst_coverage()` exposes that point's percentage.
Keep separate target/control and size/value histories across four instances.
Some bins, such as other sizes for fixed storage, are unreachable; attaining 100% of SV bins is not the test objective.
Those percentages are distinct from finite-factor plan coverage.

Live expressions select a target/control lane via constructor input and read functions at sample time.
Sample-argument cases evaluate size, value and guard on every call. One procedure orders mutations and samples.
X/Z, concurrency, event-driven sampling, cross bins, type aggregation, coverpoint-query APIs,
query ref outputs, start/stop, automatic bins and default/ignore/illegal bins are outside scope.

<a id="独立検算と実際の故障注入-2"></a>

#### Independent checks and actual fault injection

[`qualify_cgsample.py`](../tools/qualify_cgsample.py) parses emitted declarations, storage, copies, mutations,
functions, constructor/sample arguments, call order, bins, guards and hit thresholds.
A separate sequential interpreter and per-instance bin counters check all 1,056 rows without reusing generator update
or expected-output calculations.

Six original controls and seven actual SV faults execute on fixed Verilator.
Faults omit a target sample, supply control values to a target, ignore the empty guard, lower the hit threshold,
select the wrong endpoint, alias the control lane or unintentionally update the control copy.
All 13 executions exit zero; output differences detect faults.
See the [independent/runtime record](../coverage/interaction-qualification/cgsample.json).
This does not qualify excluded APIs, group-default inheritance or expansion of negative-valued range bins.

<a id="保存実行と実行限界"></a>

#### Saved runs and execution limits

Fixed Verilator 5.052 [seed 1](../coverage/interaction-results/cross73-cgsample-verilator5052-seed1.json) and
[seed 73](../coverage/interaction-results/cross73-cgsample-verilator5052-seed73.json) each match all 33 cases.
Only these 33 matching cases receive fixed-version oracle entries.
See [fixed Icarus Verilog 13.0](../coverage/interaction-results/cross73-cgsample-icarus13.json) and the
[build record](../coverage/interaction-qualification/cgsample-build.json) for Icarus results and kirimasim revision, parsing and execution
from upstream main fetched and built immediately before execution.
Unsupported cases remain legal plan rows; completing the plan is not an implementation pass.

kirimasim `786c94bbeafb`, built from upstream main fetched immediately before execution, parses all 33 new inputs.
Execution lacks covergroups for all 33. The [full 2,730-case run](../coverage/interaction-results/cross73-kirimasim-786c94bb.json)
records 2,207 pass, 517 unsupported and six existing failures. All preceding 2,697 input fingerprints and status categories are unchanged.
47 models pass their full selection. Fixed Icarus rejects all 33 new builds.

Local validation at introduction passed all 707 tool unit tests and 13 consistency checks.
Metadata checks cover 10,480 tests with zero new problems (395 known); 114 language pairs and 52,757 local links were also checked.
These are local validation results, separate from GitHub Check/Nightly results for this addition.

```sh
python3 tools/qualify_cgsample.py --verilator /path/to/verilator-5.052 \
  --output coverage/interaction-qualification/NEW-cgsample.json
```

<a id="deferred-disable-reports"></a>

<a id="disableと遅延報告引数取得"></a>

### Disable, deferred reports and input capture

`deferred_disable_reports@1` adds 31 cases for Chapters 9×16.
The generator is [`interaction_deferdis.py`](../generators/interaction_deferdis.py).
Ordinary control transfer follows 9.6.2; deferred assert/assume/cover and input capture follow 16.4;
maturity/execution follow 16.4.1, flush points follow 16.4.2 and disable-specific cancellation follows 16.4.4.

<a id="因子と観測-8"></a>

#### Factors and observations

Seven factors cover none/assertion-label/outer-worker/inner-block/task targets, assert/assume/cover,
odd/even cancellation, alternating/inverse/always-true predicates, sibling before/after,
variable/function inputs and stable/changed payload.
31 cases retain all 151 factor pairs, 92 targeted triples and ten anchors from 720 legal combinations.
The scope×cancel×predicate lower bound is 30. Greedy selection retains mandatory rows;
this is not a proof that 31 is minimal. No rows are excluded because of implementation support.

Worker activations occur at ticks 10/20/30, control-process activations at 12/22/32 and observations at 13/23/33.
Distinguish a sibling in the same worker from the separate-process control.
A label cancels only its target's pending reports; outer-worker disable clears all immature reports of that process.
Inner-block and task disable skip the local tail but retain pending reports.
Outer disable may skip a later sibling entirely, so count local/worker tail visits as well.
Previously reported history remains intact.

Record pass/fail counts, captured-input sums, live-data sums read inside the report function,
argument-function evaluation counts and last report times for each site.
Input capture and argument-function side effects occur when the directive is processed and are not rolled back by cancellation.
Changed-payload cases add 100 after the target directive, separating captured input from Reactive live data.
A later sibling captures the changed value. Failed cover has neither a report nor action-argument evaluation.

Only observed deferred `#0` is used. Final/Postponed, always_comb, flush on resumption,
same-slot repeated activations, task outputs/ref arguments, NBA, assertion controls and X/Z are outside scope.
The offset separate-process control does not qualify interference between simultaneously pending queues in multiple processes.

<a id="独立検算固定版の実行と限界"></a>

#### Independent checks, fixed tools and limits

[`qualify_deferdis.py`](../tools/qualify_deferdis.py) parses emitted statements into an AST and interprets
block/task unwinding, per-process report queues, input capture/side effects, Observed maturity and Reactive actions.
All 720 rows are checked without reusing generator predicate or expected-output calculations.

Fixed Verilator 5.052 [seed 1](../coverage/interaction-results/cross74-deferdis-verilator5052-seed1.json) and
[seed 73](../coverage/interaction-results/cross74-deferdis-verilator5052-seed73.json) each record 13 pass and 18 known results.
Only the 13 matching cases receive oracle entries. Twelve label/outer-cancellation cases and six other changed-payload cases differ.
Fixed [Icarus Verilog 13.0](../coverage/interaction-results/cross74-deferdis-icarus13.json) records 31 known results: 23 build rejections and eight output differences involving cover action counts/input evaluations.

Six original stable-payload none/inner/task controls and seven actual SV faults execute on fixed Verilator.
Faults omit fail counts, invert a predicate, capture another payload, omit input-evaluation side effects,
replace inner with outer disable, omit the target task or alias the control report.
Three known label/outer/live differences are replayed separately. All 16 executions exit zero;
known replays are not controls or detected faults. See the [independent/runtime record](../coverage/interaction-qualification/deferdis.json).
These controls alone do not qualify fixed-Verilator label cancellation, outer flushing or Reactive phase timing.

<a id="最新kirimasimで検出したラベル取消しの不一致"></a>

#### Label-cancellation differences found on latest kirimasim

kirimasim `786c94bbeafb`, fetched from upstream main and built immediately before execution, parses all 31 inputs
and records 26 pass and five fail results. The [build record](../coverage/interaction-qualification/deferdis-build.json) and
[full 2,761-case run](../coverage/interaction-results/cross74-kirimasim-786c94bb.json) record
2,233 pass, 517 unsupported and 11 failures. All preceding 2,730 input fingerprints and status categories are unchanged.
The 11 failures are five new label-cancellation cases plus six existing failures; 47 models still pass their full selection.

All five new differences disable a deferred directive's label inside an inner block, yet its report remains.
They span assert/assume/cover, odd/even cancellation, variable/function inputs and stable/changed payloads.
Using the same fresh-fetch/build procedure, [complete-output replays](../coverage/interaction-qualification/deferdis-native.json)
reproduce all five with exit zero. Headers, sibling/control outputs and target argument-evaluation counts match expectations.
Four inner/task/outer/live controls pass. Only stderr execution paths are replaced with public test paths.

One further cover control passes, but the target is false on cancellation activations, so no report is pending.
It is an empty-target-report control and does not establish successful label cancellation. A sibling report is pending, so the whole process queue is not empty.
The internal cause is unconfirmed. Expectations and existing regressions are retained.

Local validation at introduction passed all 714 tool unit tests and 13 consistency checks.
Metadata checks cover 10,511 tests with zero new problems (395 known); 114 language pairs and 52,855 local links were also checked.
These are local validation results, separate from GitHub Check/Nightly results for this addition.

```sh
# Use a build fetched from upstream main immediately before execution.
python3 tools/run_kirimasim.py --kirimasim /path/to/latest/kirimasim \
  tests/gen/ch16/test_gen_cross_deferdis_assertion_assert_odd_inverse_before_function_change.sv
python3 tools/qualify_deferdis.py --verilator /path/to/verilator-5.052 \
  --output coverage/interaction-qualification/NEW-deferdis.json
```

<a id="モデル変更時の更新"></a>

<a id="clocking-named-event"></a>

### Clocking inputs and named-event waiters

Added `clocking_named_event@1` on 2026-11-03, connecting Chapter 14 input sampling
to Chapter 15 named-event notification and waiting through shared stimuli and observations.
The generator is [`interaction_clockevent.py`](../generators/interaction_clockevent.py).
Expectations follow sampled values and clocking events in §§14.4, 14.10 and 14.13,
notifications in §§15.5.1–15.5.2, and updates in §§10.4.1–10.4.2.

Factors are width (1/32/33/64/65/129), input skew (`#1step`/`#0`), posedge/negedge,
input update (blocking/NBA), event notification (`->`/`->>`), and listener count (1/2).
All 192 combinations are legal, without exclusions for unsupported tools. A deterministic
24-case selection satisfies 100 pair targets, 40 triple targets for width×skew×notification,
skew×update×notification and edge×notification×listeners, and six mandatory boundaries.
Width×skew×notification alone requires 24 cases, so this model meets that lower bound
(87.5% reduction from the product). Minimum selections for other models are not guaranteed.

Each case has three known-value periods. Data before and after the clock differ at every bit.
A process notifies the event after `@(cb)`. Listeners save sampled and live values immediately
and two ticks later; only the live signal is restored on the intervening tick. `#1step` samples
before the update, `#0` after it, retaining the sample until the next clock. Observations cover
wakeup counts and times, independent listener storage and the final idle interval. A distinct
event between periods checks spurious wakeups and rearming. Waiter order within a tick and
notification regions themselves are not distinguished; there are no procedural `#0` observation
checkpoints. X/Z, rebinding, virtual interfaces, output skew and programs are outside scope.
Complete coverage of Chapters 14×15 is not claimed.

[`qualify_clockevent.py`](../tools/qualify_clockevent.py) interprets emitted SV values,
assignments, waits, notifications and displays using a separate event queue, without using
the generator's expected output, and checks all 192 rows. Four normal controls and nine
actual SV faults execute on fixed Verilator, all with exit zero; controls match and faults cause
output differences. Faults substitute live data, lose retention, change skew, notify the wrong
event, move the second waiter, omit input updates, change the writer edge, lose high bits or omit
rearming. See the [independent/runtime record](../coverage/interaction-qualification/clockevent.json).
The normal controls use blocking notifications; they do not qualify `->>` success or distinguish notification regions.

Fixed Verilator 5.052 [seed 1](../coverage/interaction-results/cross75-clockevent-verilator5052-seed1.json) and
[seed 73](../coverage/interaction-results/cross75-clockevent-verilator5052-seed73.json) each record 12 pass and 12 known results.
Only the 12 blocking-notification matches receive fixed oracle entries. The 12 `->>` cases have
matching bridge counts and samples but do not wake the listeners. Original SV and expectations
are retained; representative `#1step` and `#0` cases also have separate
[complete-output replays](../coverage/interaction-qualification/clockevent-notification-replays.json).
Fixed [Icarus Verilog 13.0](../coverage/interaction-results/cross75-clockevent-icarus13.json) rejects all 24 builds.

kirimasim `f3ea0379a7e5`, fetched from upstream main and built immediately before execution,
parses all 24 inputs: 12 `#1step` cases pass and 12 `#0` cases are unsupported.
The [build record](../coverage/interaction-qualification/clockevent-build.json) and
[full 2,785-case run](../coverage/interaction-results/cross75-kirimasim-f3ea0379.json) record
2,245 pass, 529 unsupported and 11 existing failures. All preceding 2,761 input fingerprints
and status categories are unchanged. Partial successes from different simulators or cases are
not combined. The requirement-ledger denominator and random-exploration counts do not change.

```sh
python3 -m unittest discover -s tools -p test_interaction_clockevent.py
python3 tools/qualify_clockevent.py --verilator /path/to/verilator-5.052 \
  --output my-results/clockevent-qualification-new.json
python3 tools/run_kirimasim.py --kirimasim /path/to/latest/kirimasim -j 4 \
  --json my-results/clockevent-kirimasim-new.json tests/gen/ch14/test_gen_cross_clockevent_*.sv
```

<a id="deferred-argument-capture"></a>

### Deferred argument capture, static references and formal conversion

`deferred_argument_capture@1` adds 29 cases for Chapters 13×16.
The generator is [`interaction_deferarg.py`](../generators/interaction_deferarg.py).
IEEE 1800-2023 13.5.1, 13.5.2, 16.4 and 16.4.1 establish registration-time input capture,
including function calls during actual-expression evaluation, and action-time reference reads.
All reference actuals are whole, equivalent-type module-static variables; subroutines are automatic.
Input conversion, sign extension and truncation follow 10.4 and 11.8.2.

Factors are source width 1/32/33/64/65/129, unsigned/signed, input/constref, same/narrow/wide formal width,
function/task, observed/final and blocking/NBA updates. Formal widths equal the source width or differ by one, reaching 130 bits.
The 576-row Cartesian product excludes only non-equivalent reference types and width-one narrowing, leaving **368 legal rows**.
No exclusion is based on unsupported behavior. Retain 145 pair targets, 71 targeted triples in the following groups
and seven mandatory boundaries with **29 selected cases: 92.12% fewer legal rows**. Minimality is not proved.

- Width×passing×formal width; width×passing×report queue
- Passing×update×report queue; routine×passing×report queue
- Signedness×passing×formal width

Each case uses alternating bits, MSB-only and all-zero frames, then complements every bit after registration.
Observe an always-captured control, the input or const-ref argument and the live source together.
Compare binary data, signed/unsigned decimal data, formal width, time, the post-update ready marker and input-evaluation call count.
Mandatory boundaries include signed one-bit extension, 33→32 truncation, 65-bit extension, a 129-bit reference and a same-width signed-input control.
Reports at times 2/12/22, subsequent observations at 3/13/23 and an idle observation at 30 retain later-state checks.

Observed deferred actions display in Reactive; final actions display in Postponed, without static-variable writes.
Both report after producer and NBA updates in this stimulus, so **this does not distinguish Reactive versus Postponed relative ordering**.
No ordering of unrelated same-slot processes is assumed. Changed reference selectors, automatic/dynamic reference actuals,
output/inout, X/Z, failing conditions, cancellation, flushing and waiting actions are outside scope.
Retain the [existing cancellation model](#deferred-disable-reports).

[`qualify_deferarg.py`](../tools/qualify_deferarg.py) interprets actual emitted SV types, literals, assignments, calls and displays
with a separate event queue. It matches all 368 legal rows without using the generator's expectation or conversion functions.
Four selected native controls pass; ten real SV faults compile and exit successfully but produce detected output differences.
Faults swap passing modes, confuse captured/live data, remove a side effect, drop upper bits, change formal width/signedness,
remove ready, make a call immediate or omit an NBA update. The [independent/control/fault record](../coverage/interaction-qualification/deferarg.json) retains complete outputs.
The [12 dedicated regression tests](../tools/test_interaction_deferarg.py) check legal rows and selection, independence,
hand-calculated boundaries, sensitivity to actual emitted-source mutations and rejection of unknown syntax.

Fixed Verilator 5.052 [seed 1](../coverage/interaction-results/cross76-deferarg-verilator5052-seed1.json) and
[seed 73](../coverage/interaction-results/cross76-deferarg-verilator5052-seed73.json) each record 29 known and zero pass results.
[Complete-output replays](../coverage/interaction-qualification/deferarg-fixed-replays.json) of four original cases,
one per function/task×observed/final pair, report ready=0 and pre-update live data.
This observes an early action after input capture and before producer updates; it does not identify an internal implementation cause.
Known replays are not passing controls or detected faults.
Fixed [Icarus Verilog 13.0](../coverage/interaction-results/cross76-deferarg-icarus13.json) rejects all 29 builds.
Common standard-derived expectations are retained, and this addition registers no fixed-version oracle.

The [build, parse and stability record](../coverage/interaction-qualification/deferarg-build.json) saves upstream revision,
the preserved core-patch hash, slang `d02b7cda`, actual binary and runner hashes, all 29 parse results and comparison with the preceding 2,785 cases.
The 29 new passes are not automatically added to fixed requirement fulfillment. Existing inputs and expectations,
529 unsupported cases and four config failures remain.

Local introduction checks pass all 766 tool regressions and 13 checks covering statistics, generated artifacts,
catalogs, interaction plans, matrices, triage, the combination ledger, languages, requirement matching/coverage and metadata.
Metadata covers 10,564 tests with zero new problems (395 known); 115 language pairs and 52,623 local links were also checked.
GitHub Check and formal Nightly have not run for these uncommitted changes.

```sh
python3 -m unittest discover -s tools -p test_interaction_deferarg.py
# Check latest upstream and rebuild kirimasim immediately before execution.
python3 tools/qualify_deferarg.py --kirimasim /path/to/latest/kirimasim \
  --output my-results/deferarg-qualification-new.json
python3 tools/run_kirimasim.py --kirimasim /path/to/latest/kirimasim -j 4 \
  --json my-results/deferarg-kirimasim-new.json tests/gen/ch13/test_gen_cross_deferarg_*.sv
python3 tools/run_verilator.py --verilator /path/to/verilator-5.052 --seed 1 -j 4 \
  --json my-results/deferarg-verilator-new.json tests/gen/ch13/test_gen_cross_deferarg_*.sv
```

<a id="generated-enum-navigation"></a>

### Generated enum tables and navigation methods

`generated_enum_navigation@1` adds 36 cases for Chapters 6×27.
The generator is [`interaction_genenum.py`](../generators/interaction_genenum.py).
IEEE 1800-2023 6.19, 6.19.1, 6.19.5, 27.4 and 27.5 establish the per-generated-scope types and enum tables.
The existing generate model focuses on lookup and excludes signed arithmetic, so this is a separate finite model.

Factors are base width 1/32/33/64/65/129, unsigned/signed, if/case generate,
consecutive/MSB-containing/descending encodings, two/three members, next/prev,
and zero/one/cycle/beyond step counts. Of 1,152 Cartesian rows, exclude only width-one three-member rows.
Select **36 of 1,056 legal rows: 96.59% fewer rows**, without unsupported-based exclusions.
Retain 181 pair targets, 110 targeted triples and six mandatory boundaries. Triple groups are:

- Width×signedness×encoding; width×generate form×member count
- Encoding×method×step; member count×method×step
- Generate form×encoding×member count

Two instances choose opposite branches and each creates two elements. Local widths add the implicit genvar
localparam and branch value to base width, reaching 131 bits; branch one rotates declaration-order values by one.
Compare first/last/num, next/prev, name, binary values and signed/unsigned decimals, checking declaration-order rather than numeric-order navigation.
Every case starts at both first and last. Re-read the resulting value and held copy after other elements operate and at idle.
Step counts are 0, 1, member count and member count+2. Keep zero and full-cycle inputs distinct even when observations coincide.

Scope includes a signed one-bit value, 32/33 and 64/65 boundaries, base width 129, wraparound,
and independent tables/state across instances and generated elements.
X/Z members, nonmembers, negative counts, config, defparam and rejection of incompatible assignments are outside scope.
These are positive type-method observations, not a proof of assignment compatibility between distinct generated types.

[`qualify_genenum.py`](../tools/qualify_genenum.py) reads actual SV instances, generate loops/branches,
constant expressions, widths/signs, declaration-order members, task bodies and top-level calls.
It independently matches all 1,056 legal rows without the generator's expectation, table or step-calculation helpers.
Four latest-native controls pass; eight real SV faults compile and exit normally but produce detected output differences.
Faults lose genvar-dependent width, choose another instance's branch, change direction/count/signedness,
drop high bits, overwrite a held copy or misname a member.
The [independent/control/fault record](../coverage/interaction-qualification/genenum.json) retains complete outputs;
[13 dedicated regressions](../tools/test_interaction_genenum.py) cover boundaries and interpreter independence.
Unsupported expressions/statements are rejected, not ignored. Interpreting all legal expectations and natively executing the selected 36 are separate checks.

Fixed Verilator 5.052 [seed 1](../coverage/interaction-results/cross77-genenum-verilator5052-seed1.json) and
[seed 73](../coverage/interaction-results/cross77-genenum-verilator5052-seed73.json) each record 18 pass and 18 known results.
Only the 18 base-width 1/32/33 cases receive its fixed-version oracle. Base widths 64/65/129 produce actual types
wider than 64 bits and build diagnostics limiting enum values to 64 bits. Widths are retained.
Fixed [Icarus Verilog 13.0](../coverage/interaction-results/cross77-genenum-icarus13.json) records 36 known build differences.
[Complete-diagnostic replays of four original cases](../coverage/interaction-qualification/genenum-fixed-replays.json)
retain Verilator's width diagnostics and Icarus Bus error exits (138). The internal cause is unconfirmed.
Known replays are not controls or detected faults. Only local diagnostic paths are redacted, retaining original-byte hashes.

The [build/parse/stability record](../coverage/interaction-qualification/genenum-build.json) and
[single complete 2,850-case run](../coverage/interaction-results/cross77-kirimasim-7554bb47-genenum.json) identify upstream main
`7554bb47` and the actual binary, all 36 new parse/pass results and unchanged preceding 2,814 inputs/statuses.
No core changes, automatic requirement bindings or existing expectation changes are introduced.

Local introduction checks pass 779 tool regressions and 13 checks covering statistics, generated artifacts,
catalogs, interactions, matrices, triage, the combination ledger, languages, requirement matching/coverage and metadata.
Metadata covers 10,600 tests with zero new problems (395 known); 115 language pairs and 52,729 local links were checked.
GitHub Check and formal Nightly have not run for these uncommitted changes.

```sh
python3 -m unittest discover -s tools -p test_interaction_genenum.py
# Check upstream main, reconfigure and build latest kirimasim immediately before execution.
python3 tools/qualify_genenum.py --kirimasim /path/to/latest/kirimasim \
  --output my-results/genenum-qualification-new.json
python3 tools/run_kirimasim.py --kirimasim /path/to/latest/kirimasim -j 8 \
  --json my-results/genenum-native-new.json tests/gen/ch6/test_gen_cross_genenum_*.sv
python3 tools/run_verilator.py --verilator /path/to/verilator-5.052 --seed 1 -j 4 \
  --json my-results/genenum-verilator-new.json tests/gen/ch6/test_gen_cross_genenum_*.sv
```

<a id="package-nba-capture"></a>

### Shared package NBA capture and ordered updates

`package_nba_capture@1` adds 36 cases from [`interaction_pkgnba.py`](../generators/interaction_pkgnba.py).
IEEE 1800-2023 26.3/26.4, 10.4.2, 4.6/4.4.2.2/4.4.2.4, 7.4.1 and 13.5.1 establish shared package objects,
reservation-time NBA value/target capture and ordering.

Factors are width 1/32/33/64/65/129, bit/logic, known/X/Z values, qualified/wildcard/explicit references,
scalar/ascending-array/descending-array storage, immediate/delayed NBA and a→b/b→a call order.
**All 1,296 rows are legal**; none is excluded for unsupported behavior. Select **36 cases: 97.22% fewer rows**,
retaining 183 pair targets, 126 targeted triples and six mandatory boundaries. Triple groups are:

- Width×state type×input; reference×storage×order
- Storage×delay×order; width×storage×delay
- State type×input×order; reference×delay×order

**One initial thread sequentially calls** automatic tasks in two writer modules. No ordering of independent concurrent processes is assumed.
Both tasks reserve NBAs on one static package object, mutate their input data/index and return; the caller also changes source/index.
A probe reads the same object with another reference spelling. A neighbor and a same-named variable in another package are controls.
Arrays use ascending negative bounds [-2:-1] and descending nonzero bounds [2:1].

Each of two input frames compares reservation-time Active, Active one tick later, settled data two ticks later and idle data three ticks later.
A one-tick delayed NBA still has its old value during Active at its due time. Input logs preserve X/Z;
only assignment to a bit destination converts them to zero. Conflicting values/order, retained neighbors and alias reads affect one observation sequence.
Dynamic arrays, real values, nets, force, VPI, independent-writer ordering and more general delay expressions are outside scope.

[`qualify_pkgnba.py`](../tools/qualify_pkgnba.py) parses actual SV package types, bindings, task bodies,
literals, indices, displays and call order into an independent event queue.
It matches all 1,296 legal rows without generator expectation, stimulus or address-calculation helpers.
Unsupported expressions/statements and extra producers are rejected. Four latest-native controls pass;
eight real SV faults compile and exit normally but produce detected output differences.
Faults change package/import bindings, make writes blocking, omit delay, reverse reservation order,
write a neighboring element, lose four-state data or overwrite an input before reservation.
The [complete control/fault record](../coverage/interaction-qualification/pkgnba.json) and
[14 dedicated regressions](../tools/test_interaction_pkgnba.py) retain these checks.
Independent interpretation of all legal rows and native execution of the selected 36 are separate checks.

Fixed Verilator 5.052 [seed 1](../coverage/interaction-results/cross78-pkgnba-verilator5052-seed1.json) and
[seed 73](../coverage/interaction-results/cross78-pkgnba-verilator5052-seed73.json) each record 12 pass and 24 known results.
Only the 12 known-value cases requiring no X/Z observations receive its fixed oracle; final inputs are re-executed after registration.
The other 24 require X/Z input logs, so two-state differences establish neither a functional defect nor a correctness oracle.
Fixed [Icarus Verilog 13.0](../coverage/interaction-results/cross78-pkgnba-icarus13.json) records 36 known build differences.
[Complete outputs/diagnostics from four original cases](../coverage/interaction-qualification/pkgnba-fixed-replays.json)
retain two Verilator X/Z differences and two Icarus build diagnostics. Known replays are not controls or detected faults.
Local-path redaction and original-byte hashes are explicit.
The two originals also differ in their first known-valued input log. [Separate diagnostic controls](../coverage/interaction-qualification/pkgnba-known-input-controls.json),
replacing only their X/Z source assignments with known zero, match on kirimasim and fixed Verilator.
Retain their actual SV and independently interpreted expectations, without changing original expectations or oracles.
This does not identify the original internal cause. These two diagnostics are not added to the fixed suite, finite-model count or four native controls.

The [build/parse/stability record](../coverage/interaction-qualification/pkgnba-build.json) and
[single complete 2,886-case run](../coverage/interaction-results/cross78-kirimasim-7554bb47-pkgnba.json) identify upstream main
`7554bb47`, fetched, configured and built immediately before execution. All 36 additions parse and pass;
all preceding 2,850 inputs/statuses remain unchanged. Overall results are 2,353 pass, 529 unsupported and four existing config failures.
No core code or existing expectation changes and no automatic requirement bindings are introduced.

The matrix maps all 36 cases to Chapters 10×26 and 4×26, and the 24 array cases to 7×26.
Each pair's all-selection-pass result requires all 36 model cases to pass in one execution.
The registry records how package references, region observations and reservation-time array indices affect actual outputs.

Local introduction checks pass 793 tool regressions and 13 checks covering statistics, generated artifacts,
catalogs, interactions, matrices, triage, the combination ledger, languages, requirement matching/coverage and metadata.
Metadata covers 10,636 tests with zero new problems (395 known); 115 language pairs and 52,839 local links were checked.
GitHub Check and formal Nightly have not run for these uncommitted changes.

```sh
python3 -m unittest discover -s tools -p test_interaction_pkgnba.py
# Check upstream main, reconfigure and build latest kirimasim immediately before execution.
python3 tools/qualify_pkgnba.py --kirimasim /path/to/latest/kirimasim \
  --output my-results/pkgnba-qualification-new.json
python3 tools/run_kirimasim.py --kirimasim /path/to/latest/kirimasim -j 8 \
  --json my-results/pkgnba-native-new.json tests/gen/ch26/test_gen_cross_pkgnba_*.sv
python3 tools/run_verilator.py --verilator /path/to/verilator-5.052 --seed 1 -j 4 \
  --json my-results/pkgnba-verilator-new.json tests/gen/ch26/test_gen_cross_pkgnba_*.sv
```

<a id="package-change-observers"></a>

### Package changes and independent observer processes

`package_change_observers@1` combines two modules reading one package variable with a control reading an identically named variable in another package.
The [generator](../generators/interaction_pkgwatch.py) crosses widths 1/32/33/64/65/129, bit/logic, known/X/Z values,
qualified/wildcard/explicit imports, scalar/ascending/descending storage, blocking/NBA updates,
whole-word/least-significant-bit event sensitivity and logical/case-equality wait conditions.
**36 selected cases** retain all 225 factor pairs, 122 targeted triples and six anchors from 2,592 legal combinations:
98.61% fewer selected cases, without a claim about elapsed time or general minimality.
No legal row is excluded for unsupported behavior.

IEEE 1800-2023 26.3/26.4 ground name binding, 9.4.2 event controls, 9.4.3 waits,
9.2.2.2.1 always_comb sensitivity including external references inside functions, and 11.4.6 equality.
Initialization sets all bits to one at time zero; event/wait observers arm at time one and are sampled at time two.
The first write at time five avoids a registration race.
One producer writes every five ticks: low-bit-only one, its repeat, all ones or X/Z, high-bit-only one,
zero, repeated zero, a neighbor update and a control-package update.
Immediately after each write it displays only the actual input and destination; observer state is sampled one tick later.
This distinguishes a blocking assignment's new value from the old value immediately after NBA scheduling,
without expecting an order between observer processes.

Each observer exposes the always_comb value read through a function; event count, last notification time and whole-word value;
the current wait condition; and a one-shot wait's count, time and held value.
For multi-bit widths, all ones to low-bit-only one wakes only the whole-word event observer.
A low-bit observer can retain an older whole-word event value after an upper-only change, distinct from live data.
Logical equality of logic X/Z to zero is X; case equality is zero. Neither wakes the wait.
Conversion of X/Z into bit storage produces zero and first wakes at time 15; logic first wakes on known zero at time 25.
The first wake history persists after the condition becomes false again.
Checks also cover no extra notification from repeated/neighbor writes, fanout to both observers,
independent packages and the control's later progress at time 40.

The [independent interpreter](../tools/qualify_pkgwatch.py) reads emitted SV types, bindings, functions, event/wait expressions,
callbacks, actual assignments and displays. It calls no generator operation-sequence, index or expected-value helpers.
All 2,592 emitted legal programs agree with the reference. Reversing observer execution order also preserves output.
Only Word and literal from the existing [value decoder](../tools/qualify_pkgnba.py) are shared.
This is bounded to one producer and independent read-only observers, not a general concurrent-scheduler proof.
Variable observer indices, classes, dynamic arrays, ordering between independent writers and direct X-to-Z transitions are excluded.

[Executed controls and fault injections](../coverage/interaction-qualification/pkgwatch.json) record four passing originals
and eight actual SV mutations, each compiled and exited normally before differing from the original expectation.
Faults change the function's package binding, remove a notification recipient, project a whole-word event,
omit event counts, wake a wait early, retain the wrong value, lose unknown state or replace NBA with blocking.
Original inputs and expectations remain intact; fault variants are not added to fixed-suite counts.

Fixed Verilator 5.052 [seed 1](../coverage/interaction-results/cross79-pkgwatch-verilator5052-seed1.json) and
[seed 73](../coverage/interaction-results/cross79-pkgwatch-verilator5052-seed73.json) each record 12 pass and 24 known.
Only the 12 cases without X/Z are registered as fixed-release oracles. All 24 displaying actual X/Z inputs remain fourstate,
including those with bit destinations.
[Icarus Verilog 13.0](../coverage/interaction-results/cross79-pkgwatch-icarus13.json) records 36 known compilation differences.
[Original-input replays](../coverage/interaction-qualification/pkgwatch-fixed-replays.json) preserve Verilator output for two X/Z cases
and diagnostics for two Icarus cases. These observations do not identify an internal cause or count as successful controls/fault detection.
No input, expectation or oracle is weakened to match a difference.

The two originals also differ at the first known-valued input display. [Diagnostic copies replacing only X/Z inputs with known zero](../coverage/interaction-qualification/pkgwatch-known-input-controls.json) match on kirimasim and fixed Verilator against independent interpretations of the actual modified SV. Original differences remain preserved; this does not identify an internal cause. These diagnostics are not added to the fixed suite, model counts or four original qualification controls.

The [build/parse/stability record](../coverage/interaction-qualification/pkgwatch-build.json) and
[single complete 2,922-case run](../coverage/interaction-results/cross79-kirimasim-a682e19e-pkgwatch.json) identify upstream main
`a682e19e3238`, fetched, configured and built immediately before execution, the actual binary, unmodified slang pin and runner.
All 36 additions parse and pass; all preceding 2,886 inputs and status categories are unchanged.
Overall results are 2,389 pass, 529 unsupported and four existing config failures. No core code changes are introduced.
The matrix maps all 36 cases to Chapters 9×26 and 4×26, the 12 logic X/Z cases to 11×26, and the 24 array cases to 7×26.
Each pair's all-selection-pass result requires all 36 model cases to pass in one execution.
No new requirement bindings or denominator changes are introduced.

Local introduction checks pass all 811 tool regressions and 13 consistency checks. The fixed suite grows by 36 to 10,672 tests, including 4,235 generated cases from 88 generators. Metadata has zero new problems and 395 known; 115 language pairs and 53,265 local links were checked. All preceding 78 plans, existing-model aggregates in the previous 250 saved runs and existing test inputs/expectations are retained. GitHub Check and formal Nightly have not run for these changes.

```sh
python3 -m unittest discover -s tools -p test_interaction_pkgwatch.py
# Check upstream main, reconfigure and build latest kirimasim immediately before execution.
python3 tools/qualify_pkgwatch.py --kirimasim /path/to/latest/kirimasim \
  --output my-results/pkgwatch-qualification-new.json
python3 tools/run_kirimasim.py --kirimasim /path/to/latest/kirimasim -j 8 \
  --json my-results/pkgwatch-native-new.json tests/gen/ch26/test_gen_cross_pkgwatch_*.sv
python3 tools/run_verilator.py --verilator /path/to/verilator-5.052 --seed 1 -j 4 \
  --json my-results/pkgwatch-verilator-new.json tests/gen/ch26/test_gen_cross_pkgwatch_*.sv
python3 tools/run_icarus.py --iverilog-bin /path/to/iverilog-13/bin -j 4 \
  --json my-results/pkgwatch-icarus-new.json tests/gen/ch26/test_gen_cross_pkgwatch_*.sv
```

### Updates after model changes

When changing models or tests, rerun the necessary cases and save new evidence. Do not carry forward a pass by rewriting only an old result's input hash.

```sh
python3 generators/generate.py
# シミュレータで実行し、必要ならcoverage/interaction-results/へ新しいJSONを保存
python3 tools/interaction_coverage.py --update
python3 tools/interaction_coverage.py --check
python3 tools/chapter_cross_matrix.py --update
python3 tools/chapter_cross_matrix.py --check
python3 tools/chapter_cross_triage.py --update
python3 tools/chapter_cross_triage.py --check
python3 -m unittest discover -s tools -p test_interaction_coverage.py
```

When adding generated tests, update README statistics, catalogs, per-clause test counts, requirement-mapping lists, and requirement-coverage artifacts as usual. New cross models do not change the requirement-ledger denominator. Also register cross-chapter mappings in the [Cross-chapter verification matrix](chapter-cross-matrix.en.md) ledger and update CSV. If [0-cell triage](chapter-cross-triage.en.md) already lists verification or candidates for the chapter pair, review their disposition after registration. Counting new tests toward requirement coverage requires separate review and registration of mappings between requirements and stimulus, observations, and expected values. Retain existing tests, negative cases, and expected values.

See [NIST SP 800-142, Practical Combinatorial Testing](https://csrc.nist.gov/pubs/sp/800/142/final) for the approach's background. Do not assume that 2 factors alone suffice; also use the specified 3-factor groups and mandatory cases.

<a id="class-method-package-lookup"></a>

## Class methods, package lookup and retained aliases (Chapters 8×26)

The `class_method_package_lookup@1` model in [interaction_class_import.py](../generators/interaction_class_import.py)
adds 34 tests. From 3,456 parameter combinations, exclude only the 192 producing a zero-width package type:
3,264 legal rows remain. The 34 selected rows retain all 244 pair targets, 110 targeted triples and six mandatory witnesses,
a 98.96% reduction from the legal product. The factors are result width (1/32/33/64/65/129), bit/logic,
signedness, package width relative to the result, known/X/Z values, wildcard/explicit/qualified/enclosing lookup,
function/task and retained/rebound handles.

IEEE 1800-2023 §26.3 defines package qualification and scope-local imports; §8.6 binds methods to their own objects,
§8.7 defines allocation and §8.12 distinguishes handle assignment from new allocation. Assignment conversion follows
§10.8 and §11.8.2. Imports appear in method bodies or the enclosing module, never directly in class scope.
An inner import resolves its method's `data` to the source package; qualification selects that package directly.
Without an inner import, the class property hides the enclosing module's imported declaration.
A second method and the module keep their own bindings.

Each test observes eight phases: initialization, property update, package update, optional handle replacement,
retained-alias update, outer-package update, independent-object progress and recovery to known data.
Compare both package values, three object properties, three typed method results and handle identity at every phase.
A retained alias follows the original object after rebinding; imported reads continue to see the common package.
Distinct package/result widths expose extension or truncation, and separate objects/packages expose accidental sharing.
One initial process performs all operations, and methods consume no time, so the expected output imposes no concurrent-call ordering.

The [independent qualifier](../tools/qualify_class_import.py) parses the actual emitted declarations, imports, methods,
allocations, assignments, calls and displays. It uses integer value/X/Z planes and object identities, separately from
the generator's string conversions and operation schedule. All 3,264 programs agree with the reference.
Tests prohibit generator/reference/stimulus helper calls while interpreting saved SV and reject unrecognized syntax.
The [qualification record](../coverage/interaction-qualification/classimp-final.json) also retains four native controls and
**eight actual SV faults**, all terminating normally and detected by output differences: wrong package, property lookup,
alias target, ordinary-method scope, signedness, source width, state type and leaked module import.
These auxiliary executions do not increase ordinary pass counts.

The [complete native run](../coverage/interaction-results/cross80-kirimasim-91139559-classimp-final.json) on upstream
`9113955914d8`, fetched/configured/built immediately beforehand, records **2,423 pass, 529 unsupported and four existing config failures**
across 80 models and 2,956 selected tests. All 34 additions parse and pass; all preceding 2,922 input fingerprints and statuses are unchanged.
There are 115 mapped chapter pairs and 53 full-selection-pass models. The [build record](../coverage/interaction-qualification/classimp-build-final.json)
identifies the binary, dependency pin and parsing results. No core code changed.

Both pinned Verilator 5.052 seeds (1/73) record **18 pass and 16 known** on the same original inputs.
All 16 known cases require X/Z inputs, including eight that check conversion into bit types. Both seeds record eight Z-input build rejections and eight X-input output differences. These two-state observations do not establish four-state conformance, and none of the 16 receives a Verilator oracle.
Pinned Icarus 13.0 rejects all 34 builds at package-qualified writes, retaining known status.
[Fixed-release records](../coverage/interaction-qualification/classimp-fixed-replays-final.json) identify each run and executable;
only the 18 non-fourstate cases matching both fixed Verilator seeds receive its oracle.
Expectations remain standard-derived. At this introduction, formal Check/Nightly had not run; the subsequent
[Check on `fd140002`](https://github.com/kurochan001/kirimasim-tests/actions/runs/41852637183) passed. Formal Nightly still predates this class/package addition.

The [metadata correction](../coverage/interaction-qualification/classimp-metadata-correction.json) records eight bit X/Z cases changing only `fourstate` from no to yes. Their SV bodies and expectations are byte-identical. Earlier snapshots remain separate and stale for those eight fingerprints; final runs use the corrected metadata.


```sh
python3 tools/interaction_coverage.py --list-tests --model class_method_package_lookup
python3 -m unittest discover -s tools -p test_interaction_class_import.py
# Fetch/configure/build latest core main immediately before execution; keep an unused evidence path.
python3 tools/qualify_class_import.py --kirimasim /path/to/latest-build/kirimasim \
  --output my-results/classimp-qualification-new.json
```

The class is declared inside one module; package-declared class types are outside this model.
Scope excludes inheritance, static methods, shallow-copy construction, null/GC behavior, concurrent calls,
timing controls, mixed input/result signedness and direct imports in class scope. This is one finite cross,
not a proof of every class/package interaction, and it adds no random profile or requirement binding.

<a id="generated-subroutine-binding"></a>

## Generated subroutines, defaults and array state (Chapters 13×27 and 7×27)

The `generated_subroutine_binding@1` model in [interaction_gensub.py](../generators/interaction_gensub.py)
adds 36 tests selected from 2,304 legal rows. All 228 pair targets, 112 targeted triples and six mandatory cases remain,
a 98.44% reduction from the legal product. Factors are base width (1/32/33/64/65/129), bit/logic, signedness,
if/case generate, default/explicit input, function/task, call order, known/X/Z data and ascending/descending array ranges.
There are no simulator-support exclusions. Chapters 13×27 and 7×27 were unassessed; the model also strengthens the existing 7×13 mapping.

IEEE 1800-2023 §27.4 supplies the implicit local parameter for each loop-generated scope; §27.5 selects one conditional block.
Each of two instances has two generated elements. Their branches declare local widths, constants, array bounds and routines.
Section 13.5.3 evaluates an omitted argument in the declaring scope on every call; §13.5.2 and §11.8.2 govern input/output conversion.
The fixed arrays use §7.4.2 ranges, including negative and nonzero indices. Actual bound queries and element updates observe this interaction.

Each case runs two phases, with known data first and then known or X/Z data. One initial process initializes all scopes,
calls every routine in the selected order, changes the caller input and one callee element, and calls again in reverse order.
A neighbor-only update is followed by a probe call and a retention snapshot. Every step prints both actual bounds, element width,
local update constant, target/neighbor values and the retained typed result in every scope. Function returns and task outputs widen
into the same destination. Observe the pre-write value separately from the updated array, and keep X/Z input tags even for bit conversion.
No call order between concurrent processes is assumed.

The [independent interpreter](../tools/qualify_gensub.py) reads the actual worker parameters, loop/conditional generation,
local declarations, default expressions, routine statements, caller writes and displays. It elaborates each scope separately and
uses existing independent constant-expression and value/X/Z-plane helpers; it never calls generator layout, stimulus or reference helpers.
All 2,304 emitted programs agree with the reference. Tests reject unknown syntax and out-of-range accesses.
The [qualification record](../coverage/interaction-qualification/gensub.json) retains four native controls and **nine actual SV faults**,
all exiting zero and detected by output differences: wrong scope constant, default element, write element, function capture,
task copy-out, signed return, generated width, called scope and array-range direction. Code, input and binary fingerprints are checked before/after qualification.
These executions and the full legal-row interpretation do not increase suite or coverage counts.

The [single full native cross run](../coverage/interaction-results/cross81-kirimasim-16222215-gensub.json), on upstream `162222153c57`
fetched/configured/built immediately before the batch, records **2,459 pass, 529 unsupported and four existing config failures**
across 81 models and 2,992 cases. All 36 additions parse and pass, and all preceding 2,956 inputs and status categories are unchanged.
There are 117 chapter pairs and 54 full-selection-pass models. The [build record](../coverage/interaction-qualification/gensub-build.json)
identifies the core revision, dependency pin and unchanged binary. Core source is unchanged.

Pinned Icarus 13.0 matches all 36 cases, including the 24 using X/Z; all receive its fixed-release oracle.
Pinned Verilator 5.052 at seeds 1/73 records **11 pass and 25 known** each: 24 X/Z cases and one known-value difference.
Keep those [separate fixed-release results](../coverage/interaction-qualification/gensub-fixed-replays.json); two-state output does not establish four-state correctness.
The known-value case has a 33-bit signed task output copied into a 36-bit producer variable: both seeds put zero in the upper three bits
where the standard-derived expectation has sign extension. Array data and neighbor observations agree; the mismatches are confined to retained results.
[Full-output replays](../coverage/interaction-qualification/gensub-known-replays.json) retain both seeds, the original Icarus match and
an [exact function counterpart](../coverage/interaction-qualification/gensub-function-control/) with byte-identical expectations.
Icarus and both Verilator seeds match that function control. This contrast narrows the observed difference to the task copy-out path;
it is not an inspection of simulator implementation code, an extra ordinary pass or a reason to weaken the expectation.

```sh
python3 tools/interaction_coverage.py --list-tests --model generated_subroutine_binding
python3 -m unittest discover -s tools -p test_interaction_gensub.py
# Fetch/configure/build current core main immediately before execution; use a new output path.
python3 tools/qualify_gensub.py --kirimasim /path/to/latest-build/kirimasim \
  --output my-results/gensub-qualification-new.json
```

Scope is two finite generated elements in each of two module instances, fixed arrays, ANSI input defaults, automatic zero-time routines
and known constant branch conditions. Recursion, ref arguments, concurrency, timing controls, dynamic arrays, callable objects and function-default side effects are excluded.
No random profile or requirement binding is added. New cases have not run in formal Check/Nightly yet.

<a id="class-conditional-return"></a>

## Class selection, early typed returns and retained receiver identity

[`interaction_class_select.py`](../generators/interaction_class_select.py) implements `class_conditional_return@1`.
All 1,296 rows are legal; 36 selected cases retain **183 pair targets, 135 targeted triples and six anchors** (97.22% fewer cases).
The factors are width 1/32/33/64/65/129, bit/logic, unsigned/signed, direct/virtual/nonvirtual dispatch,
if/ordinary-case/conditional-expression selection, known/X/Z inputs and retained/rebound handles.
Relevant rules are class receiver dispatch and handle identity (8.6, 8.12, 8.20), conditional merging (11.4.11),
assignment sizing/sign extension (11.8.2), if/case (12.4, 12.5) and function return (13.4.1).
No support-based exclusions or old-test changes are introduced.

Two derived objects share a base class with data, backup and guard properties and separate base/leaf invocation counters.
The derived method reverses the base method's true/false operands and uses a different XOR update constant.
A direct or virtual-base call must choose the derived body; a nonvirtual-base call must choose the base body.
Each body saves the selected value, updates only its receiver's data and returns the saved typed word.
Statements after the return must not execute. A wider unsigned logic destination exposes the function return's sign extension.
If and ordinary case use the false/default path for X/Z selectors; a conditional expression instead merges corresponding bits.
The selector stays logic even for bit properties, so conversion of the selected value to bit cannot justify removing four-state metadata.

Every case first executes known inputs, then known or X/Z inputs. A retained alias initially names object A.
Calls to A and B, an external alias write, optional rebinding of A's handle to B, calls through both the rebound and retained handles,
a guard-only write, repeated calls and a final idle observation expose receiver identity and state retention.
After every step, the test displays all three handles, both identity comparisons, all properties, invocation/dead-effect counters and retained results.
No observation depends on concurrent process ordering or simulator-generated random values.

[`qualify_class_select.py`](../tools/qualify_class_select.py) independently reads actual SV declarations, static handle types,
virtual-method declarations, control statements, typed expressions, writes, calls and displays.
It reuses the independent value/X/Z bit-plane implementation and XOR evaluator, not the generator's string-based selection or reference functions.
All 1,296 programs match the reference. Unknown syntax and extra processes are rejected.
[`classsel.json`](../coverage/interaction-qualification/classsel.json) records five normal native controls and **nine real SV faults**:
lost virtual dispatch, wrong selected property, wrong update constant, wrong captured return, effects moved before return,
lost sign extension, lost unknown merging, wrong retained alias and wrong called receiver.
All exit normally; every fault is detected by output difference. Code, input, runner and executable hashes remain unchanged during qualification.
These auxiliary executions do not add fixed-suite passes or requirement coverage.

The [single complete native run](../coverage/interaction-results/cross82-kirimasim-16222215-classsel.json) uses a fresh main fetch/configure/build,
kirimasim `162222153c57`, and records **2,495 pass, 529 unsupported and four existing config failures** across 82 models / 3,028 cases.
All 36 new inputs parse and pass; the preceding 2,992 input fingerprints and classifications are unchanged.
[`classsel-build.json`](../coverage/interaction-qualification/classsel-build.json) records the actual revision, binary and parse results.
The chapter table has 119 mapped pairs and 55 full-selection-pass models. Chapter 8×11 maps all 36 cases;
8×12 maps only the 24 if/case cases, while model-level success still requires all 36 to pass together.

[Pinned-release comparisons](../coverage/interaction-qualification/classsel-fixed-replays.json) preserve separate simulator identities.
Verilator 5.052 seeds 1/73 each record **12 pass and 24 known**. Only the 12 known-input tests receive its oracle after both seed runs agree.
The X cases differ under its two-state unknown handling; the Z cases reject a tristate class-member assignment during the build.
Icarus 13.0 rejects all 36 builds with an unimplemented class-handle comparison diagnostic.
[Full saved-input replays](../coverage/interaction-qualification/classsel-known-replays.json) retain representative X outputs for both seeds,
Z build diagnostics and an Icarus rejection, alongside unchanged expectations.
No two-state observation validates four-state behavior. External four-state confirmation of these X/Z cases remains unverified;
native agreement and independent interpretation are the available evidence. Known outcomes and expected values are retained.

```sh
python3 tools/interaction_coverage.py --list-tests --model class_conditional_return
python3 -m unittest discover -s tools -p test_interaction_class_select.py
# Fetch/configure/build current core main immediately before native execution.
python3 tools/qualify_class_select.py --kirimasim /path/to/latest-build/kirimasim \
  --output my-results/classsel-qualification-new.json
python3 tools/run_verilator.py --all --seed 1 \
  tests/gen/ch8/test_gen_cross_classsel_32_logic_s_virtual_if_known_rebind.sv
```

Scope is two derived objects, one inheritance level, inherited properties, a retained alias, same-sign integral words and time-free automatic functions.
Recursion, ref, null dereferences, property hiding, super, mixed-sign operations, concurrency, garbage collection and allocation stress are outside scope.
Random profiles remain thirteen; requirement bindings and core source are unchanged. Formal Check/Nightly for the new cases have not run.

<a id="generated-process-loop-transfer"></a>

## Generated processes, loop transfers and private array state

[`interaction_genloop.py`](../generators/interaction_genloop.py) defines `generated_process_loop_transfer@1`.
All **6,912** rows are legal; **36** tests retain **293 pairs, 160 targeted triples and six anchors** (99.48% fewer cases).
Factors are width 1/32/33/64/65/129, bit/logic, known/X/Z, for/while/repeat, break/continue,
head/middle/tail/miss, if/case generation, ascending/descending ranges and length 1/3.
Rules come from generate (27.4/27.5), always/edge control (9.2.2.1/9.4.2), loops/transfers (12.7.1/12.7.2/12.7.4/12.8),
unpacked ranges (7.4.2), case inequality (11.4.6) and state conversion (6.11.2). No support-based exclusions are used.

Two differently parameterized workers each elaborate two private posedge processes. Branch and genvar constants determine width and bounds,
including negative ascending and nonzero descending indices. Arrays are scanned in logical order. A low-bit marker triggers break or continue;
case inequality makes X/Z a hit in logic, while bit storage first converts those inputs to zero.
While/repeat increment before the conditional transfer, preserving termination on continue; for increments at its header.
Their final indices can differ on break even when they visited the same elements.

Each case runs known, known/X/Z and known-recovery phases. Every phase has two rising edges.
Between them, only scope a0's first array word and scope b1's guard change. The full-word XOR refresh converts upper Z bits to X as well;
this is independently modeled, rather than treating XOR as only a low-bit edit. Results remain retained until the next rising edge.
Every snapshot reads all array elements, bounds/widths, checksum, visited/kept counts and ordinal weights, hit counts,
current/final indices and persistent run/completion counts. Falling edges and idle snapshots check that processing does not run again.
Each process owns its state; there are no races between independent writers.

[`qualify_genloop.py`](../tools/qualify_genloop.py) parses actual SV parameters, branches, types, array bounds, edge declarations,
loop statements, transfers, writes and displays. Its bounded integer AST and independent value/X/Z bit planes do not call primary layout,
stimulus or reference helpers. All 6,912 emitted programs agree. [`genloop.json`](../coverage/interaction-qualification/genloop.json)
records five normal native controls and nine executable SV faults: wrong generated width, lost break/continue, wrong marker element,
skipped final iteration, lost checksum accumulation, wrong clock edge, guard corruption and reversed range.
All exit normally and every fault differs in output. Source/input/runner/binary hashes are checked before and after; these auxiliary runs add no suite passes.

A fresh upstream main fetch/configure/build on `50a897dee62a` passes all 36, including parsing, in
[one 3,064-case run](../coverage/interaction-results/cross83-kirimasim-50a897de-genloop.json): **2,531 pass / 529 unsupported / four existing config failures**.
All preceding 3,028 fingerprints/statuses remain unchanged. [`genloop-build.json`](../coverage/interaction-qualification/genloop-build.json)
records the actual build and parse results. Totals are 83 models / 121 pairs / 56 full-selection-pass models.
The new 12×27 and 9×27 mappings and strengthened 7×27 use all 36 cases; partial results are not combined across snapshots.

[Pinned comparisons](../coverage/interaction-qualification/genloop-fixed-replays.json) give Icarus 13.0 **31 pass / five known**, including 19 passing X/Z inputs.
The five known inputs all use repeat count one and are rejected at the build with a break/continue-not-in-loop diagnostic.
[Full diagnostics and separate count-three controls](../coverage/interaction-qualification/genloop-known-replays.json) retain every original;
independently interpreted [control SV/expectations](../coverage/interaction-qualification/genloop-repeat-controls/) match Icarus for both transfers.
This bounds an observed release difference; no simulator source was inspected and no internal cause or later-version behavior is asserted.
Verilator 5.052 seeds 1/73 each give **12 pass / 24 known**. All 31 matching Icarus cases receive its oracle;
the 12 known-input cases also retain Verilator oracles. Two-state results do not validate the remaining five X/Z cases.
The current baseline `19cd790a` passed formal Check/Nightly, but these 36 additions have not run there.

```sh
python3 tools/interaction_coverage.py --list-tests --model generated_process_loop_transfer
python3 -m unittest discover -s tools -p test_interaction_genloop.py
# Fetch/configure/build current core main immediately before native execution.
python3 tools/qualify_genloop.py --kirimasim /path/to/latest-build/kirimasim \
  --output my-results/genloop-qualification-new.json
```

Scope is private static arrays, one shared clock, single-process loop transfers and bounded parameters. Signed arithmetic, foreach,
dynamic containers, NBA, named disable, concurrent writers and variable hierarchy indices are outside scope. Random profiles remain thirteen;
requirement bindings and core implementation are unchanged.

<a id="interface-array-query-walk"></a>

## Interface-local query-driven walks and typed results

[`interaction_ifquery.py`](../generators/interaction_ifquery.py) defines `interface_array_query_walk@1`.
All **4,608 rows** are legal. **36 cases** retain **274 pair targets, 96 targeted triples and six mandatory anchors**, reducing case count by 99.22%.
Factors are widths 1/32/33/64/65/129, bit/logic, known/X/Z, ascending/descending unpacked bounds, negative/positive origins,
length 1/3, omitted/explicit dimension, function/task, call order ab/ba and ascending/descending packed bounds.
Grounds are interfaces/subroutines (25.2/25.7), array queries (20.7), $bits (20.6.2), unpacked arrays (7.4.2),
functions/arguments (13.4/13.5), bit conversion (6.11.2) and shifts (11.4.10). No support-based exclusions are applied.

Two interfaces have widths W and W+2, lengths N and N+1, distinct origins and opposite bounds.
Each automatic function/task starts at `at=$left(data)` and repeats `$size(data)` times, advancing with `at-=$increment(data)`.
Queries determine the actual element and iteration count, beyond displaying shape metadata. Packed origins and directions also vary.
Dimension one is unpacked and dimension two is packed. For a singleton, `$increment` is one regardless of declared orientation.
In the [actual width-one case](../tests/gen/ch25/test_gen_cross_ifquery_1_bit_known_up_negative_one_default_function_ab_up.sv),
a has bounds [-4:-4] and initial value zero. One visit gives checksum 0, visited=1, weight=-4 and terminal=-5;
complementing the last element and recalling gives checksum 1. Assuming an ascending declaration always has increment -1 would mishandle this boundary.

Before XORing each full element, shift the checksum left one bit. Low bits identify element positions so a reversed walk cannot hide behind exclusively symmetric stimuli.
Every call initializes its accumulator/index. Compare visited counts, index weights, terminal index, call counts, full-width checksum and return/output copyout.
Results are stored in width-W+4 logic, exposing four-bit zero extension for a and two-bit extension for b.

Known, known/X/Z and known-recovery phases call in the selected order, observing every element and both instances after each call.
Then complement only a’s last element and b’s guard. Computed results remain unchanged immediately after the input update;
only reverse-order calls refresh them. Distinguish logic X/Z, bit conversion to zero and Z-to-X behavior on complement.
The final repeated-state observation does not claim elapsed-time or clock-edge verification.

[`qualify_ifquery.py`](../tools/qualify_ifquery.py) reads actual declarations, instance parameters, queries, expressions, loops, receivers and displays.
Independent value/X/Z bit planes and a bounded integer AST interpret them without primary layout/stimulus/reference/query helpers.
All 4,608 programs agree. [`ifquery.json`](../coverage/interaction-qualification/ifquery.json) records five normal controls and nine real source faults:
wrong width, reversed traversal, skipped last element, lost shift, lost accumulation, terminal index, call count, receiver and guard clobber.
All exit normally; every fault is detected by output difference. Check source/input/runner/binary hashes before and after; auxiliary executions are not fixed passes.

Freshly fetched/configured/built main `50a897dee62a` passes and parses all 36 additions in [one full 3,100-case run](../coverage/interaction-results/cross84-kirimasim-50a897de-ifquery.json).
Totals are **2,567 pass / 529 unsupported / four existing config failures**, with preceding 3,064 inputs/statuses unchanged.
[`ifquery-build.json`](../coverage/interaction-qualification/ifquery-build.json) identifies the actual build and parse outcomes.
Each of 7×25, 20×25 and 13×20 maps all 36 cases; totals are 84 models / 124 chapter pairs / 57 full-selection-pass models.

[Pinned comparisons](../coverage/interaction-qualification/ifquery-fixed-replays.json) record Icarus 13.0 at **36 pass**, including all 24 X/Z-input cases.
Verilator 5.052 seed 1 records **12 pass / 24 known**, and seed 73 **13 pass / 23 known**.
Only the twelve known-input cases matching both seeds obtain Verilator oracles.
The extra seed-73 match, `33_bit_x_up_negative_one_explicit_function_ab_down`, includes X-to-bit conversion;
this observation under one two-state randomization seed does not validate four-state behavior. Icarus matches the same saved SV and expectation.
All 36 receive Icarus oracles; existing oracles, expectations and cases are unchanged.
Formal Check/Nightly on baseline 19cd790a cover the preceding 82 models; the combined 72 generated-loop/interface-query cases have not run there.

```sh
python3 tools/interaction_coverage.py --list-tests --model interface_array_query_walk
python3 -m unittest discover -s tools -p test_interaction_ifquery.py
# Fetch/configure/build the latest core main immediately before native execution.
python3 tools/qualify_ifquery.py --kirimasim /path/to/latest-build/kirimasim \
  --output my-results/ifquery-qualification-new.json
python3 tools/run_icarus.py --iverilog-bin /path/to/icarus/bin \
  --json my-results/ifquery-icarus-new.json tests/gen/ch25/test_gen_cross_ifquery_*.sv
python3 tools/run_verilator.py --all --seed 73 \
  --json my-results/ifquery-verilator-new.json tests/gen/ch25/test_gen_cross_ifquery_*.sv
```

Scope is one fixed unpacked dimension, unsigned one-dimensional packed elements, direct hierarchical calls and a single initial block.
Interface ports, modports, virtual interfaces, dynamic arrays, signed arithmetic, concurrent calls, timing controls and ref are outside scope.
This does not complete general array-query/interface verification. Requirement bindings, core code and the thirteen random profiles are unchanged.

<a id="generated-constant-expression-shape"></a>

## Typed constant expressions and context-dependent generated shape

[`interaction_genexpr.py`](../generators/interaction_genexpr.py) defines `generated_constant_expression_shape@1`.
All **6,912 rows** are legal; **36 cases** retain **297 pair targets, 132 targeted triples and six anchors**, a 99.48% case-count reduction.
Factors are width 1/32/33/64/65/129, bit/logic, known/X/Z runtime inputs, independent left/right signedness, result declaration sign,
same/one-bit-wider assignment context, addition/XOR/conditional expression, if/case generate and named/positional parameter overrides.
Grounds are expression width/sign (11.8.2), arithmetic/relational/bitwise/conditional operators (11.4.3/11.4.4/11.4.8/11.4.11),
generate (27.4/27.5), $bits (20.6.2) and bit conversion (6.11.2). No support-based exclusions are applied.
Generate is the primary chapter. Align generator `CHAPTER=27`, the first `:lrm:` clause 27.4 and matrix `primary_chapter=27`; focused tests and matrix gates check consistency.

Two modules use SELECT=0/1. Constant A has only its high bit set or value one; B has every bit set. Equally wide operands have independent signs.
The typed localparam E supplies assignment-context width. For these three operators, sign extension requires both operands to be signed.
A signed destination declaration alone does not sign-extend a mixed-sign expression. After storage, E’s declaration sign controls negative testing and decimal display.

In the [actual width-one case](../tests/gen/ch27/test_gen_cross_genexpr_1_bit_known_s_s_s_wide_add_if_named.sv),
A and B are both signed 1'b1, meaning -1. A two-bit assignment context gives E=2'b10 (-2), NEG=1 and COUNT=3.
It does not first add at one bit to get zero and then widen. At same-width context, E=1'b0, NEG=0 and COUNT=1.
The difference changes the actual selected branch and elaborated hierarchy count.

E’s high/low bits bound the count to 1–4. `BASE+1+($bits(E)%3)` determines base generated width; genvar further varies each element width.
$bits measures type width rather than the count of one bits, and participates in shape computation beyond display instrumentation.
If/case alternatives have different KIND/TAG constants. Each element owns raw/guard words and a full-width XOR continuous-assignment result.
Observe E’s bits/decimal value, negative test, count, base width, actual element widths and every full word.

Known, known/X/Z and known-recovery phases drive every element and wait one time unit.
Then update only a’s first input, followed by b’s last guard, observing all elements and the other instance after each update.
Distinguish X/Z conversion into bit and whole-word XOR converting Z to X. X/Z appear only in runtime stimulus; constant expressions/generate conditions remain known.
This does not validate unknown generate conditions, all constant operators or independently cover every bit position.

[`qualify_genexpr.py`](../tools/qualify_genexpr.py) reads actual typedefs, localparams, typed expressions, overrides, branches,
generate loops, continuous assignments, writes and displays. Independent bit planes and a bounded integer AST compute context width,
common expression sign and post-storage sign without primary constant/layout/stimulus/reference helpers. All 6,912 programs agree.
[`genexpr.json`](../coverage/interaction-qualification/genexpr.json) records five normal controls and nine real SV faults:
operand sign, result sign, context width, operator, $bits target, branch tag, override binding, continuous mask and write target.
All exit normally; every fault is detected by output difference. Auxiliary runs are not additional fixed passes.

Freshly fetched/configured/built `92001039e896` parses and passes all 36 additions in [one complete 3,136-case run](../coverage/interaction-results/cross85-kirimasim-92001039-genexpr.json).
Totals are **2,603 pass / 529 unsupported / four existing config failures**, with preceding 3,100 inputs/statuses unchanged.
[`genexpr-build.json`](../coverage/interaction-qualification/genexpr-build.json) identifies the build and parse outcomes.
Execute an immutable binary snapshot with the actual build’s identical hash, isolating later builds in the shared workspace.
Source/input/runner/executable hashes are checked before and after.

[Pinned comparisons](../coverage/interaction-qualification/genexpr-fixed-replays.json) record Icarus 13.0 at **36 pass**, including all 24 X/Z-input cases.
Verilator 5.052 seeds 1/73 each give **12 pass / 24 known**. All 36 receive Icarus oracles; only twelve known-input cases matching both seeds also receive Verilator oracles.
Two-state observations do not qualify X/Z behavior; existing expectations, classification and seeds are unchanged.
Each of 11×27 and 20×27 maps all 36 cases: totals are 85 models / 126 chapter pairs / 58 full-selection-pass models.
[Check on baseline 8df0dde9](../coverage/interaction-qualification/check-8df0dde9-20261105.json) covers the preceding suite; these 36 cases have not run in Check/Nightly.

```sh
python3 tools/interaction_coverage.py --list-tests --model generated_constant_expression_shape
python3 -m unittest discover -s tools -p test_interaction_genexpr.py
# Fetch/configure/build latest core main immediately before native execution.
python3 tools/qualify_genexpr.py --kirimasim /path/to/latest-build/kirimasim \
  --output my-results/genexpr-qualification-new.json
python3 tools/run_icarus.py --iverilog-bin /path/to/icarus/bin \
  --json my-results/genexpr-icarus-new.json tests/gen/ch27/test_gen_cross_genexpr_*.sv
python3 tools/run_verilator.py --all --seed 73 \
  --json my-results/genexpr-verilator-new.json tests/gen/ch27/test_gen_cross_genexpr_*.sv
```

Scope is known typed constants, addition/XOR/conditional expressions, finite if/case and generate loops, direct hierarchy references and a single initial block.
Configuration, defparam, variable hierarchy indices, unknown constant conditions and signed runtime arithmetic are outside scope.
Existing regressions, requirement bindings, core code and thirteen random profiles are unchanged.

<a id="formatted-scan-partial-write"></a>

## Stopped formatted scans and preservation around partial writes

[`interaction_scansel.py`](../generators/interaction_scansel.py) defines `formatted_scan_partial_write@1`.
Of 6,912 product rows, represent the 1,152 unused whole-target/high-placement rows with low placement, leaving **5,760 legal representatives**.
This is not exclusion by support or prior passes. **36 cases** retain **292 pair targets, 142 targeted triples and six anchors**, reducing the representative count by 99.38%.
Factors are width 1/32/33/64/65/129, bit/logic, known/X/Z digits, bin/hex, full success/overlong first field/second mismatch/empty input,
whole/+:/-: destinations, target/word-derived field width, low/high placement and literal/runtime formats.
Grounds are scanning (21.3.4.3), format construction (21.3.3), part-selects (11.5.1), $bits (20.6.2) and two-state conversion (6.11.2).
Generator CHAPTER, first :lrm: clause and matrix primary chapter all identify chapter 21.

Destinations have widths W and W+1. Part-selects embed them in width-W+7 wa/wb storage words.
Distinguish low/high placement and +:/-: spelling, observing every a/b/wa/wb word plus selected views after each operation.
Checking only the successful field could miss damage to bits outside the selection when a scanner overwrites the whole word.
Runtime format width comes from actual $bits of the target or wa. Literal calls embed the same format contents directly.
Field width is a **maximum character count**: for illustration, `%2h` reads two characters a5, representing eight bits; a four-bit destination receives low bits 5.
Using $bits to choose that number does not make a hexadecimal field’s width a bit count.

For an illustrative example, start with 8'hA5 and scan into its low four bits, with another output 8'h5A and marker=-91.
Scanning `0011|!|7` with `%4b|%b|%d` assigns only the first output: return 1, whole word 8'hA3, other output 8'h5A, marker=-91.
Empty input returns -1 and writes nothing. With `00111|...`, the extra 1 after four consumed characters fails the following literal separator and retains later outputs.
This is an explanatory example, not another fixed-suite case.

Each known, known/X/Z and known-recovery phase performs a selected trial followed immediately by a completely successful call.
Do not reset outputs: check the history of the assigned first field, unassigned later field and previous marker. Finally change only an unscanned guard.
X/Z are known ASCII digit characters, not unknown bits in the input string. Distinguish X/Z stored in logic from conversion to zero in bit; retain fourstate metadata for bit as well.

[`qualify_scansel.py`](../tools/qualify_scansel.py) reads actual declarations, string concatenations, $bits, format construction, calls, select ranges and displays.
An independent character cursor implements widths and stopping at failed conversions/literals; value/X/Z bit planes merge only the selected region.
It does not use primary stimulus/reference/conversion/index helpers. All 5,760 programs agree.
[`scansel.json`](../coverage/interaction-qualification/scansel.json) records six normal controls and nine actual SV faults:
query target, select position, destination, failed-word/marker clobber, lost partial preservation, literal width, guard target and input digit.
All exit normally and every fault is detected by output difference. Auxiliary runs are not additional fixed passes.

Freshly fetched/configured/built `6f5c69841228` parses and passes all 36 additions in [one full 3,172-case run](../coverage/interaction-results/cross86-kirimasim-6f5c6984-scansel.json).
Totals are 2,639 pass / 529 unsupported / four existing config failures, with preceding 3,136 inputs/statuses unchanged.
[`scansel-build.json`](../coverage/interaction-qualification/scansel-build.json) identifies the revision, binary fingerprint and parse outcomes; execute an immutable copy with the actual build’s identical hash.
Source/input/runner/binary hashes are checked before and after. Map only the 24 part-select cases to 11×21 and twelve runtime-format cases to 20×21;
full-model success requires all 36 together. Totals are 86 models / 128 chapter pairs / 59 full-selection-pass models.

[Pinned comparisons](../coverage/interaction-qualification/scansel-fixed-replays.json) record Icarus 13.0 at **17 pass / 19 known**.
Only those seventeen matches, including nine X/Z cases, obtain its oracle. Differences are twelve runtime-format cases and seven literal-format bit/X/Z cases.
[All nineteen outputs/diagnostics](../coverage/interaction-qualification/scansel-known-replays.json) are retained: replay observes seventeen normal exits and two abnormal exits with returncodes -10/-11.
[Twelve separate literal-format controls](../coverage/interaction-qualification/scansel-literal-controls/) retain saved inputs/expectations and change only the call’s format argument:
seven match; five retain bit/X/Z differences. Controls never overwrite the original failure or count as suite passes.

Verilator 5.052 seeds 1/73 each record **3 pass / 33 known**. Only two known-input cases matching both seeds receive its oracle.
Record the extra bit/X match without treating it as evidence for logic four-state behavior.
Three unchanged saved-SV replays retain full diagnostics for runtime-format syntax rejection, a generated-C++ build failure for a 64-bit literal-format selection,
and output differences for a 129-bit selection. Do not infer internal causes from implementation source; standard-derived expectations, seeds and existing classification are unchanged.
The new 36 cases have not run in formal Check/Nightly.

```sh
python3 tools/interaction_coverage.py --list-tests --model formatted_scan_partial_write
python3 -m unittest discover -s tools -p test_interaction_scansel.py
# Fetch/configure/build latest core main immediately before native execution.
python3 tools/qualify_scansel.py --kirimasim /path/to/latest-build/kirimasim \
  --output my-results/scansel-qualification-new.json
python3 tools/run_icarus.py --iverilog-bin /path/to/icarus/bin \
  --json my-results/scansel-icarus-new.json tests/gen/ch21/test_gen_cross_scansel_*.sv
python3 tools/run_verilator.py --all --seed 73 \
  --json my-results/scansel-verilator-new.json tests/gen/ch21/test_gen_cross_scansel_*.sv
```

Scope is fixed select indices, a first bin/hex field, a second binary field and a third decimal field, known ASCII strings, one initial block and finite input sequences.
Variable indices, suppression, mixed known/X/Z tokens, whitespace/NUL boundaries, short X/Z-digit extension, reals, file I/O and concurrency are outside scope.
Requirement bindings, existing tests, core code and thirteen random profiles are unchanged.

<a id="program-task-frame-lifetime"></a>

## Program termination, private automatic task frames and copyout (2026-11-06)

[`interaction_progframe.py`](../generators/interaction_progframe.py) defines `program_task_frame_lifetime@1`.
Map all 36 cases to 13×24 and the eight `completion=return` cases to 12×24.
Termination scope and completion method affect actual copies and call history; merely declaring a task in a program is not the mapping rationale.
See [private frames and copyout](glossary.en.md#9-クロステストで使う言語機能).

### Factors and selection

Cross widths 1/32/33/64/65/129, bit/logic, known/X/Z, unsigned/signed, output/inout,
scalar/fixed-array-element actuals, stop before the first return/between returns/natural completion, endtask/early return, and ab/ba call order.
All 3,456 rows are legal. Select 36, retaining all 249 pair targets, 100 priority triple targets and six anchors (98.96% fewer cases).
Priority groups are width×state×value, stop×mode×completion, sign×mode×storage,
stop×completion×order, width×sign×mode and storage×mode×order.
No support-based denominator exclusions apply. Complete pairs do not mean all 3,456 rows ran; see [how to read these numbers](faq.en.md#q28-why-not-simply-cross-every-feature).

### Stimulus, observations and expectations

Two independent programs `p` and `q` inside one module each overlap two automatic task calls.
Calls start at 1/3 and return at 7/11. Change original inputs and actuals at 5, then check retention of captured inputs/inout values and private locals.
Only `p` executes `$exit` at 6 or 9; retain natural completion as a control.
Normal endtask and early task return copy results out; early return skips subsequent task statements.
Canceled calls do not copy out, and terminating `p` must leave `q` running.

Actuals are logic words three bits wider than formals. Observe every bit, sign extension, truncation and neighboring array elements.
After a known reset at 12, surviving programs call the same task again and return at 13.
Keep counters and the other call's original X/Z history, distinguishing known recovery from erased evidence.

In the actual [one-bit output/cancellation case](../tests/gen/ch24/test_gen_cross_progframe_1_bit_known_u_output_scalar_before_end_ab.sv),
`sampled=1` at 1 produces task-local `result=0`. This does not yet update the four-bit actual.
After the external update at 5, `p_a=1011`. Terminating `p` at 6 retains `p_a=1011` in the observation at 8.
Surviving `q` returns normally at 7 and copies `q_a=0000`.
Follow `entry_first`, `refresh` and `first_return` in the [saved expectation](../tests/gen/ch24/test_gen_cross_progframe_1_bit_known_u_output_scalar_before_end_ab.expected).

### Race boundaries and independent checks

Only the module prints, at ticks distinct from normal task returns and cancellation.
At 12, module reset/observation is Active and program recall is Reactive, capturing updated values.
The peer program initial waits until 20; the module explicitly finishes at 15. Normal cases exclude implicit global completion.
Ref, variable indices, NBA, join_none, recursion, static tasks and concurrent same-tick writers are outside scope.

[`qualify_progframe.py`](../tools/qualify_progframe.py) interprets actual SV types, declarations, task statements, bindings, delays and displays.
It uses independent value/X/Z masks, private invocation frames and Active/Reactive events, without primary stimulus/reference helpers.
All 3,456 programs match. [Auxiliary evidence](../coverage/interaction-qualification/progframe.json) retains six normal controls and nine executable SV faults.
Removed/delayed termination, return replaced by $exit, removed return, lost copyout/sign extension, wrong input/destination and resampled locals
all exit normally and are detected by output difference. These fifteen executions add no fixed-suite, requirement or matrix passes.

### Results and limits

One [complete 3,208-case run](../coverage/interaction-results/cross87-kirimasim-6f5c6984-progframe.json) on kirimasim `6f5c69841228`, fetched/configured/built immediately beforehand,
records all 36 additions parsing/passing. Preceding 3,172 inputs/statuses are unchanged: totals are 2,675 pass / 529 unsupported / four existing config failures.
The [build record](../coverage/interaction-qualification/progframe-build.json) identifies revision, binary hashes and parses.
Totals are 87 models / 130 chapter pairs / 60 full-selection-pass models. A full-model pass requires all 36 together in one saved run.

[Pinned comparisons](../coverage/interaction-qualification/progframe-fixed-replays.json) record Icarus 13.0 at 6 pass / 30 known.
Only the six matching natural-completion cases receive its oracle. All thirty remaining replays compile, then reject execution because `$exit` is undefined.
Icarus also warns about Reactive assignment scheduling; six matches do not qualify general program-region behavior.
Verilator 5.052 records 36 known for each seed, rejecting nested program declarations even for known-input cases.
Preserve [all thirty Icarus diagnostics and representative Verilator replays](../coverage/interaction-qualification/progframe-known-replays.json).
Retain fourstate metadata even for X/Z-to-bit conversion; two-state agreement or majority voting does not replace standard expectations.

The suite adds 36 tests, totaling 10,958, including 4,521 generated cases from 96 generators. Requirement bindings/denominators/rates and thirteen random profiles are unchanged.
These additions have local evidence and have not run in formal Check/Nightly. Verified Check covers the preceding 86 models; formal Nightly covers 82.

### Rerun

Use the saved SV and expectations directly, with unused qualification output paths.
Prepare the simulator through [latest-commit fetch/build instructions](../README.md#kirimasim).

```sh
python3 -m unittest discover -s tools -p test_interaction_progframe.py
python3 tools/run_kirimasim.py --kirimasim /path/to/latest-build/kirimasim -j 8 \
  --json my-results/progframe-native-new.json tests/gen/ch24/test_gen_cross_progframe_*.sv
python3 tools/qualify_progframe.py --kirimasim /path/to/latest-build/kirimasim \
  --output my-results/progframe-qualification-new.json
python3 tools/run_icarus.py --iverilog-bin /path/to/icarus/bin -j 4 \
  --json my-results/progframe-icarus-new.json tests/gen/ch24/test_gen_cross_progframe_*.sv
python3 tools/run_verilator.py --all --seed 1 -j 3 \
  --json my-results/progframe-verilator-new.json tests/gen/ch24/test_gen_cross_progframe_*.sv
```

<a id="package-array-query-scope"></a>

## Package array queries and name lookup (2026-11-06)

[`interaction_pkgquery.py`](../generators/interaction_pkgquery.py) defines `package_array_query_scope@1`.
Map all 36 cases to 20×26 because lexical lookup determines query operand types/dimensions and therefore the elements walked and results obtained.
A function is the call/observation vehicle, not a reason to inflate chapter mappings. See [scope and shadowing](glossary.en.md#9-クロステストで使う言語機能).

### Factors, selection and scope

Cross widths 1/32/33/64/65/129, bit/logic, known/X/Z, ascending/descending bounds, negative/positive origins, lengths one/three,
explicit import/wildcard import/qualified reference, first/second package, and omitted/explicit dimension one.
All 3,456 rows are legal. Select 36, retaining all 249 pair targets, 118 priority triple targets and six anchors (98.96% fewer cases).
Priority groups are width×state×value, binding×source×query, bounds×origin×length,
width×source×binding, bounds×length×source and binding×value×query.
No support-based exclusions apply; see [the scope of complete pair coverage](faq.en.md#q28-why-not-simply-cross-every-feature).

The two packages have same-named `data` arrays with widths W/W+2, lengths one/three versus two/four, different origins and opposite directions.
Both caller modules also declare local `data[7:11]`, five elements wide with word widths W+5/W+7.
An inner explicit/wildcard import resolves references inside the automatic function ahead of outer local namesakes; qualification selects a package directly.
Export, dynamic arrays, signed arithmetic, tasks, timing and concurrent calls are outside scope.

### Queries affect actual values

A scan starts at `$left(data)`, repeats `$size(data)` times and subtracts `$increment(data)` each step.
Singleton increment is one. Accumulation uses `acc=(acc << 1) ^ data[at]`, applying the declared width/state on each store.
Observe order-sensitive full-width checksums, visits, weighted indices and terminal indices rather than an element sum alone.
Returns/checksums are stored in logic words five bits wider than the base width, comparing high bits too.

Record `$bits`, `$dimensions`, `$unpacked_dimensions`, and left/right/low/high/increment/size for both dimensions inside each function.
In the actual [one-bit case](../tests/gen/ch26/test_gen_cross_pkgquery_1_bit_known_up_negative_one_explicit_first_default.sv),
selected `first_pkg::data[-4:-4]` has one one-bit element. After the first call, bits=1, size=1, left=right=-4,
increment=1, visited=1 and terminal=-5. Its phase-zero element is 0, so the widened six-bit result is 000000.
Local `a.data[7:11]` has five six-bit elements: bits=30 and size=5. A mistaken local query changes dimensions/visits even if a value happens to match.
Follow `before` and `first0` in the [saved expectation](../tests/gen/ch26/test_gen_cross_pkgquery_1_bit_known_up_negative_one_explicit_first_default.expected).

### Retention and independent checks

Call from both modules across known, known/X/Z and known-recovery phases.
First update only the unselected package's last element; recalling must retain target queries/results.
Then update the selected package's last element and separate local elements in both modules, calling again in reverse order.
Retain results until each recall, displaying every array element, full result and call count after each operation. Final call counts are a=9 and b=6.
Keep fourstate metadata for X/Z-to-bit conversion and retain history/local values during known recovery.

[`qualify_pkgquery.py`](../tools/qualify_pkgquery.py) reads actual package/type/range declarations, imports, qualified references,
query arguments, scan statements, writes and displays. Independent typed arrays and value/X/Z masks interpret all 3,456 programs
without primary layout, stimulus, query-value or reference helpers.
[Auxiliary evidence](../coverage/interaction-qualification/pkgquery.json) retains six normal controls and nine faulty SV programs; all exit normally.
Removed/wrong imports, reverse/short scans, lost shifts, wrong dimensions/callers, clobbered locals and wrong query operands
are all detected by output differences. These fifteen auxiliary runs add no fixed-suite or chapter-matrix passes.

### Results and limits

One [complete 3,244-case run](../coverage/interaction-results/cross88-kirimasim-6f5c6984-pkgquery.json) on kirimasim `6f5c69841228`, fetched/configured/built immediately beforehand,
records all 36 additions parsing/passing. Preceding 3,208 inputs/statuses are unchanged: totals are 2,711 pass / 529 unsupported / four existing config failures.
The [build record](../coverage/interaction-qualification/pkgquery-build.json) identifies revision, immutable binary hashes and parses.
Totals are 88 models / 131 chapter pairs / 61 full-selection-pass models. A full-model pass requires all 36 together in one run.

[Pinned comparisons](../coverage/interaction-qualification/pkgquery-fixed-replays.json) record Icarus 13.0 at 36 known build rejections.
Preserve [all thirty-six original diagnostics](../coverage/interaction-qualification/pkgquery-known-replays.json); syntax errors occur at qualified package-array writes.
No simulator implementation sources were read; this observation alone does not establish an internal cause or general lack of query support.
Verilator 5.052 records 12 pass / 24 known at seed 1 and 13 pass / 23 known at seed 73.
Only the twelve known-input cases matching both seeds receive its oracle. The incidental bit/X match at seed 73 does not qualify four-state behavior.
Retain representative logic/X, logic/Z and bit/Z outputs, plus this identical bit/X input at both seeds, preserving original expectations and diagnostics.
External confirmation of all four-state cases remains unverified. Majority voting or accidental two-state agreement does not change expectations.

The suite adds 36 tests, totaling 10,994, including 4,557 generated cases from 97 generators. Requirement bindings/denominators/rates and thirteen random profiles are unchanged.
These additions have local evidence and have not run in formal Check/Nightly.

### Rerun

Use saved SV and expectations. Prepare the simulator through [latest-commit fetch/build instructions](../README.md#kirimasim).
Use an unused qualification output path.

```sh
python3 -m unittest discover -s tools -p test_interaction_pkgquery.py
python3 tools/run_kirimasim.py --kirimasim /path/to/latest-build/kirimasim -j 8 \
  --json my-results/pkgquery-native-new.json tests/gen/ch26/test_gen_cross_pkgquery_*.sv
python3 tools/qualify_pkgquery.py --kirimasim /path/to/latest-build/kirimasim \
  --output my-results/pkgquery-qualification-new.json
python3 tools/run_icarus.py --iverilog-bin /path/to/icarus/bin -j 4 \
  --json my-results/pkgquery-icarus-new.json tests/gen/ch26/test_gen_cross_pkgquery_*.sv
python3 tools/run_verilator.py --all --seed 1 -j 3 \
  --json my-results/pkgquery-verilator-new.json tests/gen/ch26/test_gen_cross_pkgquery_*.sv
```

<a id="named-event-loop-transfer"></a>

## Named events and loop transfers (2026-11-06)

[`interaction_eventflow.py`](../generators/interaction_eventflow.py) defines `named_event_loop_transfer@1`.
Map the 24 skip/stop cases to 12×15. Full-model success requires all 36, including twelve all-flow controls, together in one saved run.
See [named events and triggered](glossary.en.md#9-クロステストで使う言語機能).

### Factors and scope

Cross widths 1/32/33/64/65/129, bit/logic, known/X/Z, edge/triggered waiting, registration before/after the trigger statement,
blocking/NBA triggers, all/continue/break, and first/middle/last receive indices.
Of 2,592 Cartesian rows, canonicalize the unused all-flow pivot to middle, removing 576 duplicates. Select 36 of 2,016 legal rows.
Retain all 223 pair targets, 140 priority triple targets and six anchors: 98.21% fewer representative cases, separate from elapsed-time savings.
Priority groups are width×state×value, waiting×arm×trigger, flow×pivot×waiting, flow×pivot×trigger,
arm×flow×pivot, width×trigger×flow and state×value×flow. No support-based exclusions apply.

Two static named events trigger at target ticks 2/8/14/20 and control ticks 5/11/17/23, assigning payloads first.
Event copying/rebinding, null, ref, delayed triggers, simultaneous triggers and garbage collection are outside scope.

### Registration and loop semantics

Late rows create the target child with join_none after the first trigger statement. The child starts in the same tick when its parent suspends.
An edge wait registered after a blocking trigger misses that notification; `wait(go.triggered)` sees the same-slot persistent state.
NBA dispatch follows Active registration. Parent-captured `scheduled` is 1 for blocking and 0 for NBA triggers.
Observations occur two ticks later, when triggered itself has reset to 0.

The for loop attempts four receives. Pivot means **receive order**, not driver pulse number.
Continue preserves the captured word/time but skips accumulation, retention marking and the tail; break exits the consumer loop.
Every iteration advances one tick before rearming, preventing repeated consumption of the persistent same-slot state.
Rearm at trigger+1 and observe at +2; only the parent prints.

In the actual [one-bit case](../tests/gen/ch15/test_gen_cross_eventflow_1_bit_known_edge_early_blocking_all_middle.sv),
saved target words are 1/0/1/0 at 2/8/14/20. Left-shift high bits truncate in a one-bit accumulator, leaving checksum 0; the control checksum is 1.
See `b3` in the [expectation](../tests/gen/ch15/test_gen_cross_eventflow_1_bit_known_edge_early_blocking_all_middle.expected).

The [late edge/blocking case](../tests/gen/ch15/test_gen_cross_eventflow_64_logic_known_edge_late_blocking_all_middle.sv) misses its first pulse: at 25, hits=3, armed=4 and done=0.
Done records whether the for loop exited; waiting for a fourth receive is expected here. Test success depends on matching the saved expectation.
Cancel remaining children at 26, start fresh one-shot waiters at 28 and check known recovery at 30/33.
Retain old receive history/checksum/done and observe fresh values/times separately, detecting missed cancellation or erased history.
Display raw X/Z before conversion even with bit payload storage.

### Independent checks and results

[`qualify_eventflow.py`](../tools/qualify_eventflow.py) reads actual SV types, arrays, for/if, break/continue, forks, waits, triggers, writes and displays.
Independent typed values, private loop frames, Active/NBA queues, tick-indexed event flags and descendant cancellation interpret all 2,016 programs.
It does not call primary closed-form reference, payload or waiter helpers. This validates the bounded emitted grammar, not general SystemVerilog or a formal proof.
[Auxiliary evidence](../coverage/interaction-qualification/eventflow.json) retains six normal controls and nine executable source faults.
Lost persistence/rearm delay, changed break/continue, wrong payload, missed cancellation, a short loop, lost shift and changed dispatch region
all exit normally and are detected by output differences. These fifteen auxiliary runs add no fixed-suite passes.

One [complete 3,280-case run](../coverage/interaction-results/cross89-kirimasim-6f5c6984-eventflow.json) on freshly fetched/configured/built kirimasim `6f5c69841228` records all 36 additions parsing/passing.
Preceding 3,244 inputs/statuses are unchanged: totals are 2,747 pass / 529 unsupported / four existing config failures.
The [build record](../coverage/interaction-qualification/eventflow-build.json) identifies revision and immutable binary hashes.
Totals are 89 models / 132 pairs / 62 full-selection-pass models. This is the version tested then, not a claim about later main revisions.

### Pinned differences and auxiliary controls

[Pinned comparisons](../coverage/interaction-qualification/eventflow-fixed-replays.json) record Icarus 13.0 at 36 known and Verilator 5.052 at 8 pass / 28 known for each seed.
Only eight known-input matches at both seeds obtain its oracle. Preserve all Icarus build rejections concerning triggered event members and other unsupported syntax.
Verilator also differs in receive counts for four known-input NBA cases; retain [all Icarus diagnostics and original Verilator outputs](../coverage/interaction-qualification/eventflow-known-replays.json).
The other 24 X/Z cases cannot qualify four-state behavior through two-state observations.

[Four separate blocking-trigger controls](../coverage/interaction-qualification/eventflow-blocking-controls/) change only `->>` to `->` in saved SV,
with corresponding expectations independently interpreted for the changed semantics. Original inputs/expectations remain unchanged.
The separate controls match kirimasim in four runs and Verilator in eight runs across both seeds. They do not count as original NBA-case passes.
This records that changing dispatch removes the observed difference, without asserting an internal cause or general NBA support. No simulator implementation sources were read.

The suite adds 36 tests, totaling 11,030, including 4,593 generated cases from 98 generators. Requirement bindings/denominators/rates and thirteen random profiles are unchanged.
These additions have local evidence and have not run in formal Check/Nightly.

### Rerun

Prepare the simulator through [latest-commit fetch/build instructions](../README.md#kirimasim), then use saved SV/expectations and unused evidence output paths.

```sh
python3 -m unittest discover -s tools -p test_interaction_eventflow.py
python3 tools/run_kirimasim.py --kirimasim /path/to/latest-build/kirimasim -j 8 \
  --json my-results/eventflow-native-new.json tests/gen/ch15/test_gen_cross_eventflow_*.sv
python3 tools/qualify_eventflow.py --kirimasim /path/to/latest-build/kirimasim \
  --output my-results/eventflow-qualification-new.json
python3 tools/run_icarus.py --iverilog-bin /path/to/icarus/bin -j 4 \
  --json my-results/eventflow-icarus-new.json tests/gen/ch15/test_gen_cross_eventflow_*.sv
python3 tools/run_verilator.py --all --seed 1 -j 3 \
  --json my-results/eventflow-verilator-new.json tests/gen/ch15/test_gen_cross_eventflow_*.sv
```

<a id="time-scope-delay"></a>

## Time scopes and delays (2026-11-07)

[`interaction_timescope.py`](../generators/interaction_timescope.py) defines `time_scope_delay@1`, the first model whose primary chapter is 3.
Chapter 3 x 20 and x 21 map to all 48 cases; pairs with chapters 5, 9, 10, 13, 22, 23, 25 and 26 map only to the rows that meet their conditions.
The model passes only when all 48 succeed in one saved run.

### Factors and scope

Crosses how the scope is set (timeunit with timeprecision, timeunit with a slash, `` `timescale ``, the timeunit of `$unit`, inheritance by nesting),
the container (module/interface/package), the unit (1us/10ns/100ps), the precision (same as the unit, a tenth, a thousandth),
the delay form (real, time literal with the unit's suffix, time literal with a finer suffix, real actual argument),
rounding (none, down, tie, up), the caller's unit (ten times, a tenth) and the statement (delay statement, intra-assignment delay of a nonblocking assignment).
48 cases are selected from 8,064 legal rows, excluding only nested packages. They keep 291 pair targets, 136 focused triple targets and six mandatory rows.

`$timeunit`, `$printtimescale`, programs and class methods are outside the scope. Pinned Icarus does not accept `$timeunit` and kirimasim does not support `$printtimescale` in a package,
so units and precisions are observed only through delays and time reads.

### What it separates

Every row has settings that must lose. Declaration and nesting rows have `` `timescale 1ms/1us `` before them, and `` `timescale `` rows have a timeunit in `$unit`.
A precedence error (3.14.2.3) changes the length of the delay, which shows in the output. The same observation checks that a `` `timescale `` after a definition does not reach it.

In the [real-delay example](../tests/gen/ch3/test_gen_cross_timescope_keyword_module_10ns_tenth_real_up_finer_statement.sv), `#1.27` with unit 10ns and precision 1ns is 12.7 ns, rounded to 13 ns.
Two calls wait 13 ns + 13 ns, not a rounded 25.4 ns. The caller's unit is 1 ns, so the same `#1.27` there is 1.27 ns.
A read uses the unit of the scope that calls it, so `$time` and `$realtime` differ in the task and in the caller at one time (20.3). `%t` compares them in the same fs form through `$timeformat`.

Ties use only values exact in binary (2.5, 1.25, 1.0625) and round up, following the 2.75 to 2.8 example of 3.14.1.
The standard is not clear about a tie of `$time` itself, so the caller's first delay is 0.47, which keeps such ties out of every row. The interpretation stops on a tied read.

### Independent check and results

[`qualify_timescope.py`](../tools/qualify_timescope.py) reads the actual SV, sets scopes by declarations, directives and nesting in text order, and keeps time as exact fractions of femtoseconds.
It calls no closed-form expectation or scaling helper of the primary model, and all 8,064 programs match. [Auxiliary evidence](../coverage/interaction-qualification/timescope.json) holds five normal controls and nine executable faults, each detected by an output difference after a normal exit.

In the [complete 3,445-case run](../coverage/interaction-results/cross92-kirimasim-60c26d7c-timelitgate.json) on kirimasim `60c26d7c8113`, all 48 additions pass. The [build record](../coverage/interaction-qualification/timelitgate-build.json) keeps the revision and the fingerprint of the fixed binary.

### Pinned-release differences

[Pinned Icarus 13.0](../coverage/interaction-results/cross92-timelitgate-icarus13.json) has 44 pass / 4 known. The known cases are the four nested rows, whose builds fail with an unresolved module definition or the limit on instances in interfaces.
[Pinned Verilator 5.052](../coverage/interaction-results/cross92-timelitgate-verilator5052-seed1.json) has 48 known, also at [seed 73](../coverage/interaction-results/cross92-timelitgate-verilator5052-seed73.json): four are nested forms it does not support and 44 are output differences. See [representative outputs](../coverage/interaction-qualification/timelitgate-known-replays.json).

<a id="literal-context-extension"></a>

## Literals and expression context (2026-11-07)

[`interaction_literal.py`](../generators/interaction_literal.py) defines `literal_context_extension@1`, the first model whose primary chapter is 5.
Chapter 5 x 11, x 10 and x 22 map to all 66 cases; chapter 6 maps to bit targets and chapter 20 to sized rows.

### Factors and scope

Crosses base (b/o/d/h, unbased unsized), sign designator, digits against size (short, exact, truncated, unsized), leading digit (0/1/x/z), context (assignment, addition with a signed or an unsigned variable, conditional, unary minus, arithmetic right shift),
target (logic, signed, bit) and width (8/33/65). 66 cases are selected from 6,552 legal rows, excluding forms outside the grammar. They keep 303 pair targets, 148 focused triple targets and eight mandatory rows.

Each case carries one literal four ways: written directly in an initial procedure, through an untyped localparam, from macros holding the size, base and digits, and in a continuous assignment.
An unsized number is only "at least 32 bits", so digits stay within 32 bits and `$bits` is not observed. Forms whose width shows in the result, right shifts of unsized numbers led by x or z, are excluded too.

### What it separates

Short digits pad with 0 on the left, or with x or z when that leads. Long digits truncate from the left, so an x or z in a dropped digit does not remain (5.7.1).
The sign comes from the whole expression and not from the literal alone, so a signed literal is zero-extended when added to an unsigned variable (11.8). The sign of the target does not affect the extension.
An unsized unsigned number led by x or z and an unbased unsized literal take the width of the expression, and a localparam holds them at their own width. `'hx` assigned to 65 bits is all x, but through a localparam its upper 33 bits are 0.

### The expectation error and the all-row run

**The first version had a wrong expectation.** Both the generator and the independent check zero-extended an unsized unsigned number led by x or z beyond 32 bits, unlike Example 4 of 5.7.1 (`'hx` into 85 bits).
The 66 selected cases held no such row, so the selected runs on kirimasim and Icarus all passed. One run of all legal rows gave 96 differences, and kirimasim turned out to follow the standard.
Both were corrected from the clause, and two mandatory rows were added. The [all-row record](../coverage/interaction-qualification/timelitgate-all-rows.json) keeps the history and counts. As a result, the [method](interaction-verification-method.en.md#run-every-legal-row-once) now includes the all-row run.

### Independent check and results

[`qualify_literal.py`](../tools/qualify_literal.py) builds bits from the tokens after macro expansion and finds the width and sign of each expression by operator. All 6,552 programs match.
[Auxiliary evidence](../coverage/interaction-qualification/literal.json) holds six normal controls and nine executable faults. All 66 additions pass in the complete run.

### Pinned-release differences

Pinned Icarus 13.0 matches all 66. Pinned Verilator 5.052 has 32 pass / 34 known at both seeds: 11 of the known cases fail to build (nine on more digits than the size, two on tristate forms in an addition with z) and 23 are x or z output differences.
A two-state match on an x or z row does not stand for a four-state check.

<a id="gate-array-connection"></a>

## Gate-array connections (2026-11-07)

[`interaction_gatearray.py`](../generators/interaction_gatearray.py) defines `gate_array_connection@1`.
Chapters 7 and 23 x 28 map to all 51 cases; chapter 11 maps to concatenated outputs and chapter 4 to rows with delays.

### Factors and scope

Crosses the gate (and, xnor, not, bufif1, nmos), the array range (`[3:0]`, `[0:3]`, `[6:9]`), the output expression (descending or ascending vector, part-select, concatenation), the input expression (descending or ascending vector, concatenation, scalar),
the second input (scalar, part-select, none), the delay (none, one, two, three values) and the input values (known, X, Z). 51 cases are selected from 4,464 legal rows. They keep 278 pair targets, 135 focused triple targets and six mandatory rows.

Pulses shorter than a delay are not used, because Clause 28 has no rule for them. The standard does not define an output before its first delay ends (6.5), so the first phase is read after every output settles.
In a probe, `nmos` read z on kirimasim and x on Icarus in that window. Neither departs from the standard, so it is no expectation.

### What it separates

A terminal of the single-instance width is shared by all instances; otherwise the instance of the right-hand index takes the expression's least significant bit (28.3.6).
The bit mapping follows the position in the expression, so turning the array around does not change the result, and every row checks this. Bits outside a part-select stay z.

An array is a set of separate gates, so each bit chooses its own delay (28.16). In the [example](../tests/gen/ch28/test_gen_cross_gatearray_bufif1_up_whole_up_concat_vector_three_x.sv) with `bufif1 #(1, 3, 2)`,
bits of one word change after 1 to 1, 1 to x, 2 to z and 3 to 0. Reads happen at half times, which no output update shares.

### Independent check and results

[`qualify_gatearray.py`](../tools/qualify_gatearray.py) turns terminal expressions into lists of bits from the declarations and applies truth tables and delays to each instance. All 4,464 programs match.
The check itself stops on pulses, reads before the first delay and connection mismatches. [Auxiliary evidence](../coverage/interaction-qualification/gatearray.json) holds six normal controls and nine executable faults. All 51 additions pass in the complete run.

### Pinned-release differences

Pinned Icarus 13.0 has 34 pass / 17 known. All known cases have two or three delay values: when a word mixes transitions, the delays are not per bit. In the all-row run the differences also stay within such rows, 1,440 in total.
Pinned Verilator 5.052 has 6 pass / 45 known at both seeds: 12 fail to build on tristate forms it does not support and the rest are output differences. The output of one known-input case changes with the seed.

In the all-row run, kirimasim `60c26d7c8113` matches the expectations of all 19,080 rows of the three models. These rows are not in the fixed suite and enter no count.

The suite adds 165 tests, totaling 11,193, including 4,758 generated cases from 101 generators. Requirement bindings/denominators/rates and thirteen random profiles are unchanged.
This addition is local evidence and has not run in formal Check/Nightly.

### Rerun

```sh
python3 -m unittest discover -s tools -p 'test_interaction_timescope.py'
python3 -m unittest discover -s tools -p 'test_interaction_literal.py'
python3 -m unittest discover -s tools -p 'test_interaction_gatearray.py'
python3 tools/run_kirimasim.py --kirimasim /path/to/latest-build/kirimasim -j 8 \
  --json my-results/timelitgate-native-new.json tests/gen/ch3/test_gen_cross_timescope_*.sv \
  tests/gen/ch5/test_gen_cross_literal_*.sv tests/gen/ch28/test_gen_cross_gatearray_*.sv
python3 tools/qualify_timescope.py --kirimasim /path/to/latest-build/kirimasim \
  --output my-results/timescope-qualification-new.json
python3 tools/qualify_literal.py --kirimasim /path/to/latest-build/kirimasim \
  --output my-results/literal-qualification-new.json
python3 tools/qualify_gatearray.py --kirimasim /path/to/latest-build/kirimasim \
  --output my-results/gatearray-qualification-new.json
```

<a id="macro-expansion-context"></a>

## Macro expansion and context (2026-11-07)

[`interaction_macro.py`](../generators/interaction_macro.py) defines `macro_expansion_context@1`.
Chapter 11 x 22 maps to all 114 cases, and chapters 7, 8, 9, 10, 12, 13, 20, 21, 25, 26 and 27 x 22 map to the rows of their context.
The model passes only when all 114 succeed in one saved run.

### Factors and scope

Definition form (arguments, no arguments, an omitted default, an empty actual taking the default, a default for a later argument, an inner macro defined later, a macro inside an actual, several lines with comments, token pasting, stringification, an escaped quote);
body (no parentheses, parentheses, the formal used twice); actual argument (simple, a low-precedence expression, a comma inside braces, a conditional);
context (continuous assignment, case item, function, `$display`, package, interface, generate block, class, fork, width expression, structure assignment pattern);
and where the definition sits (top of the compilation unit, another module, the element using it, redefinition, `` `undef ``, `` `elsif ``, `` `ifndef ``).
114 cases come from 7,679 legal rows, with 463 factor-pair targets and nine mandatory rows. `` `__LINE__ `` and `` `__FILE__ `` are out of scope.

### What it distinguishes

A macro is placed as text, so an outer operator and an actual argument bind where they land (22.5.1). Every case has `* 3` outside the macro.
With `1 | 6` as the actual, a [body without parentheses](../tests/gen/ch22/test_gen_cross_macro_function_bare_low_show_unit.sv) gives `1 | 6 + 1 * 3`, which is 9, and a [body with parentheses](../tests/gen/ch22/test_gen_cross_macro_function_wrap_low_show_unit.sv) gives 24.
A formal used twice gives `1 | 6 + 1 + 1 | 6 * 3`, which is 27. A conditional actual without parentheses takes in all the rest, which gives 2.

An inner macro is defined after the outer one, to show that expansion happens at the point of use and not at the definition. In a redefinition the last definition is used, and a definition inside another module reaches the rest of the compilation unit.
A branch that is not chosen holds an undefined macro and an unmatched keyword, to show that it is not compiled. Each context also checks its own punctuation, such as the colon of a conditional in a case item and a comma in an assignment pattern.

### Independent check and execution

[`qualify_macro.py`](../tools/qualify_macro.py) expands the actual SV with a small preprocessor and evaluates by operator precedence. It calls no body or value table of the main model, and all 7,679 programs match.
[Auxiliary evidence](../coverage/interaction-qualification/macro.json) keeps nine normal controls and ten executable faults, all detected by an output difference after a normal exit.

In the [single complete 3,692-case run](../coverage/interaction-results/cross95-kirimasim-97d5b000-macroforcesense.json) on kirimasim `97d5b0001e7c`, all 114 additions pass. The [all-row record](../coverage/interaction-qualification/macroforcesense-all-rows.json) shows no kirimasim difference over all 7,679 rows.

### Pinned differences

[Pinned Icarus 13.0](../coverage/interaction-results/cross95-macroforcesense-icarus13.json) has 90 pass / 24 known. Over all rows, 5,537 match, 2,115 are rejected and 27 differ. [Pinned Verilator 5.052](../coverage/interaction-results/cross95-macroforcesense-verilator5052-seed1.json) has 114 pass, also at [seed 73](../coverage/interaction-results/cross95-macroforcesense-verilator5052-seed73.json).
See the [simulator differences](simulator-differences.md#macro-force-sense-differences).

<a id="force-release-visibility"></a>

## Force and release (2026-11-07)

[`interaction_force.py`](../generators/interaction_force.py) defines `force_release_visibility@1`.
Chapter 10 x 21 maps to the `$strobe` and `$monitor` rows, chapter 10 x 20 to the bit query rows, and chapter 4 x 6 to the rows of nets and driven variables.

### Factors and scope

Left-hand side (a variable, a variable with a continuous assignment, a variable under `assign`, a net, a part-select of a net, `wor`, a concatenation of variables, a concatenation of nets); right-hand side (a constant, a constant with X and Z, an expression);
action during the force (none, a driver write, a write of the right-hand signal); write form (blocking, nonblocking); observer (`$display`, `$strobe`, `$monitor`, `@`, `$countones` with `$isunknown` and `$bits`); site (direct, task, hierarchical).
72 cases come from 2,160 legal rows, with 228 factor-pair targets, 72 focused three-factor targets and eight mandatory rows. A bit-select or part-select of a variable is not used, because 10.6.2 forbids it.

### What it distinguishes

A force overrides every assignment and driver, and a forced expression follows its operands. After a release the result depends on the target (10.6.2).
A net takes its drivers at once, a variable with a continuous assignment or `assign` gets its value back by a reevaluation, and any other variable keeps its value until the next assignment.
In the [`assign` example](../tests/gen/ch10/test_gen_cross_force_pca_const_driver_nba_strobe_direct.sv), the driver is written during the force, and the release returns the value `0011`. After `deassign` the value stays until the next procedural assignment.

No read happens in the time step of a release whose reevaluation is only scheduled. Reads right after a release are limited to nets and undriven variables, where the standard gives the result.
The standard does not say whether `$monitor` displays when it starts, so a value changes at that time and a display is certain. `$monitor` and `@` also have to stay silent when the value does not change.

### Independent check and execution

[`qualify_force.py`](../tools/qualify_force.py) turns declarations into state per bit and reads through the force, then `assign`, then the drivers. All 2,160 programs match.
[Auxiliary evidence](../coverage/interaction-qualification/force.json) keeps eight normal controls and ten executable faults. In the single complete run all 72 additions pass, and there is no kirimasim difference over all 2,160 rows.

### Pinned differences

[Pinned Icarus 13.0](../coverage/interaction-results/cross95-macroforcesense-icarus13.json) has 52 pass / 20 known. Over all rows, 1,392 match, 360 are rejected and 408 differ. [Pinned Verilator 5.052](../coverage/interaction-results/cross95-macroforcesense-verilator5052-seed1.json) has 46 pass / 26 known, also at [seed 73](../coverage/interaction-results/cross95-macroforcesense-verilator5052-seed73.json).
See the [simulator differences](simulator-differences.md#macro-force-sense-differences).

<a id="implicit-sensitivity-update"></a>

## Implicit sensitivity and updates (2026-11-07)

[`interaction_sense.py`](../generators/interaction_sense.py) defines `implicit_sensitivity_update@1`.
Chapter 4 x 7 maps to the rows of array elements and structure members, chapter 4 x 11 to part-selects, conditionals and concatenations, and chapter 4 x 6 to the continuous assignments.

### Factors and scope

Process (`always_comb`, `always_latch`, `always @*`, a continuous assignment, a net declaration assignment); what is read (a plain variable, an element by a constant index, an element by a variable index, a structure member, a packed structure member, a part-select, a function reading its argument, a function reading something else, a conditional, a concatenation);
write (the part read, a part not read, the same value, the other operand, the index or select); write form (blocking, nonblocking, task).
61 cases come from 630 legal rows, with 177 factor-pair targets and 25 mandatory rows. Each form read has a mandatory `always_comb` row that writes a part not read.

### What it distinguishes

`always_comb` and `always_latch` wake on the longest static prefix of what they read (9.2.2.2.1, 11.5.3). A write to another element, member or part does not wake them, unless a variable index makes the prefix the whole array.
A `$display` in the body counts the evaluations, and reads at other times show the value. A write of the same value is no update, so it wakes nothing.

Only `always_comb` and `always_latch` react to what a function reads; `always @*` and a continuous assignment react only to its arguments (9.2.2.2.2, 10.3.2).
In the [continuous assignment example](../tests/gen/ch4/test_gen_cross_sense_assign_fnglobal_read_task.sv), a change of `a`, read by the function, leaves the output old, and the next change of `b` evaluates everything and gives `3c`.

To avoid races at time 0, initial values come from declaration initializers and each step has one write. `always @*` waits for the first change, so its first read is X.

### Independent check and execution

[`qualify_sense.py`](../tools/qualify_sense.py) finds the dependencies from the text of the right-hand side and wakes by the overlap with a write. All 630 programs match.
[Auxiliary evidence](../coverage/interaction-qualification/sense.json) keeps nine normal controls and nine executable faults. In the single complete run all 61 additions pass, and there is no kirimasim difference over all 630 rows.

### Pinned differences

[Pinned Icarus 13.0](../coverage/interaction-results/cross95-macroforcesense-icarus13.json) has 50 pass / 11 known. Over all rows, 546 match, 60 are rejected and 24 differ. [Pinned Verilator 5.052](../coverage/interaction-results/cross95-macroforcesense-verilator5052-seed1.json) has 19 pass / 42 known, also at [seed 73](../coverage/interaction-results/cross95-macroforcesense-verilator5052-seed73.json).
See the [simulator differences](simulator-differences.md#macro-force-sense-differences).

The [build and pinned records](../coverage/interaction-qualification/macroforcesense-build.json) and the [replays of the differences](../coverage/interaction-qualification/macroforcesense-known-replays.json) are kept.

<a id="interface-member-expression"></a>

## Interface members in expressions and statements (2026-11-07)

[`interaction_ifexpr.py`](../generators/interaction_ifexpr.py) defines `interface_member_expression@1`.
Chapters 11 x 25 and 12 x 25 map to all 49 cases; chapters 13 x 25 map only to rows that update through tasks the modport imports.
The model passes as a whole only when all 49 cases pass in the same saved run.

### Factors and scope

The access path (an interface port, a modport port, a generic interface port, an element of an array of interfaces, a hierarchical name),
the declaration of the member `v` (signed 8 bits, unsigned 8 bits, signed 4 bits, all with the bits `fa` or `a`),
the expression (division by 4, an arithmetic right shift by 2, adding `1'b0`, the part-select `[3:0]`, a comparison with 0, unary minus, multiplying by `2'sb11`),
the statement (if, case, repeat, while, for, do, foreach) and the update (direct assignment, compound assignment, an imported task taking the value, a task computing the expression inside the interface) are crossed.
49 cases come from 2,940 legal rows, covering 264 pair targets and keeping seven mandatory witnesses.

### What it distinguishes

The type of a member stays as declared whatever the path, and the rules of 11.6 and 11.8 decide the width and sign of an expression.
The signed `v` (-6) divided by 4 is -1 and shifted arithmetically is -2; unsigned (250), both are 62.
Adding `1'b0` makes the whole expression unsigned, so the four-bit member gives 10. A part-select is unsigned whatever the declaration.
`2'sb11` is -1 in a signed expression and 3 in an unsigned one, so the [unsigned multiplication](../tests/gen/ch25/test_gen_cross_ifexpr_modport_u8_mul_repeat_task.sv) gives 750 per update.

The control of each statement reads `n` of the interface through the path, and every update decrements it. repeat evaluates its count once and runs three times, while and for run twice and do once.
[Connecting an array element](../tests/gen/ch25/test_gen_cross_ifexpr_element_s8_shift_while_compound.sv) also checks that the other element keeps its values.

### Independent check and runs

[`qualify_ifexpr.py`](../tools/qualify_ifexpr.py) tokenizes the actual SV and builds storage and allowed directions from the declarations and the modport.
For each expression it finds the self-determined width and sign of every operand, pushes the context of the assignment or comparison down, and then computes the value; it does not use the value table of the model.
A write to a name outside the modport, or a call of a task it does not import, stops it with an error. All 2,940 programs match.
The [auxiliary evidence](../coverage/interaction-qualification/ifexpr.json) keeps seven normal controls and seven executable faults, all detected by an output difference after a normal exit.

In the [single complete 3,887-case run](../coverage/interaction-results/cross98-kirimasim-6e32b04e-ifexprloopfmt.json) on kirimasim `6e32b04ed6ec`, all 49 additions pass. The [all-row record](../coverage/interaction-qualification/ifexprloopfmt-all-rows.json) shows no kirimasim difference on all 2,940 rows.
Icarus 13.0 does not accept interface ports or modport imports, so all rows also ran once on Verilator 5.052, and all 2,940 match.

### Pinned-release differences

[Pinned Icarus 13.0](../coverage/interaction-results/cross98-ifexprloopfmt-icarus13.json) rejects all 49 at parsing (known). [Pinned Verilator 5.052](../coverage/interaction-results/cross98-ifexprloopfmt-verilator5052-seed1.json) passes 49 also at [seed 73](../coverage/interaction-results/cross98-ifexprloopfmt-verilator5052-seed73.json), and is the comparator.
See the [simulator differences](simulator-differences.md#interface-loop-literal-differences).

<a id="loop-control-scheduling"></a>

## Loop control and scheduling regions (2026-11-07)

[`interaction_loopsched.py`](../generators/interaction_loopsched.py) defines `loop_control_scheduling@1`.
Chapters 4 x 12 map to all 55 cases; chapters 12 x 21 map to the `$strobe` and `$monitor` rows, and chapters 9 x 12 to rows whose body waits `#0` or `#2`.

### Factors and scope

The loop (repeat, while, for, do, forever with `break`), the wait in the body (none, `#0`, `#2`),
the change of the control variable `n` (a nonblocking assignment by another process at time 1, a blocking assignment after `#0` at time 1, a blocking assignment at time 2, a decrement in the body)
and the observer (`$display`, `$strobe`, `$monitor` started before the loop) are crossed.
55 cases come from 165 legal rows, covering 137 targets including the loop, wait and change group and keeping six mandatory witnesses.

### What it distinguishes

repeat evaluates its count once at entry (12.7.2); while, for and forever test the condition before each pass, and do after the body.
`n` changes from 3 to 5. A body that does not wait or waits only `#0` finishes the loop in the same time slot, before the NBA region, so it reads the old 3.
A body that waits `#2` reads 5 at the next time: [repeat](../tests/gen/ch12/test_gen_cross_loopsched_repeat_delay_nba_display.sv) runs three times and [while](../tests/gen/ch12/test_gen_cross_loopsched_while_delay_nba_display.sv) five.

`$display` shows the value at the call, `$strobe` and `$monitor` the value at the end of the time slot, in the postponed region.
[`$strobe` in the loop](../tests/gen/ch12/test_gen_cross_loopsched_do_zero_nba_strobe.sv) shows the 5 after the NBA three times, though the loop read 3.
A `#0` in the body and a write after `#0` in another process wait in the same inactive region in either order, so that combination is left out.

### Independent check and runs

[`qualify_loopsched.py`](../tools/qualify_loopsched.py) parses each initial block into a statement tree and runs it on a small scheduler with active, inactive, NBA and postponed regions.
It checks that every order of the processes ready together gives the same output, so the excluded race is found. All 165 programs match.
The [auxiliary evidence](../coverage/interaction-qualification/loopsched.json) keeps six normal controls and six executable faults, all detected by an output difference after a normal exit.

In the [single complete 3,887-case run](../coverage/interaction-results/cross98-kirimasim-6e32b04e-ifexprloopfmt.json) on kirimasim `6e32b04ed6ec`, all 55 additions pass. kirimasim has no difference on all 165 rows, and Icarus matches them all.

### Pinned-release differences

[Pinned Icarus 13.0](../coverage/interaction-results/cross98-ifexprloopfmt-icarus13.json) passes 55. [Pinned Verilator 5.052](../coverage/interaction-results/cross98-ifexprloopfmt-verilator5052-seed1.json) has 48 pass / 7 known also at [seed 73](../coverage/interaction-results/cross98-ifexprloopfmt-verilator5052-seed73.json).
Over all rows Verilator matches 95 and differs on 70, all of them `$strobe` and `$monitor` rows.

<a id="literal-format-display"></a>

## Literal forms and display formats (2026-11-07)

[`interaction_litfmt.py`](../generators/interaction_litfmt.py) defines `literal_format_display@1`.
Chapters 5 x 21 map to all 91 cases; chapters 6 x 21 map to rows carrying the literal by `localparam`, 21 x 22 by a macro and 11 x 21 by a concatenation.

### Factors and scope

The literal (an unsized decimal, a sized decimal, hexadecimal padded on the left with x, hexadecimal padded with z, binary with `?` and underscores, octal with an x digit, hexadecimal with underscores, `'1`,
a negated sized decimal, a signed hexadecimal, a string with hexadecimal and octal escapes),
the format (`%d`, `%0d`, `%h`, `%0h`, `%o`, `%b`, `%8d`, `%8h`, `%s`),
the route (`$display`, `$write`, `$sformatf`, `$swrite`, `$fdisplay` to standard output, `$display`, `$displayh`, `$displayo` or `$displayb` without a format)
and the carrier (as written, an untyped `localparam`, a macro, a concatenation) are crossed.
91 cases come from 1,778 legal rows, covering 301 pair targets and keeping nine mandatory witnesses.

### What it distinguishes

The text fixes the width, the sign and every bit. `12'hx5` is padded on the left with x, and `?` is z (5.7.1).
A hexadecimal or octal digit is a lowercase x or z when its whole group is, and uppercase for a part; a decimal value shows one character, right-justified in the full width (21.2.1.3).
The full width comes from the largest value, a width of 0 drops the leading zeros, and a given width pads hexadecimal with zeros and decimal with spaces (21.2.1.2).
[`%8h` of a value with x](../tests/gen/ch21/test_gen_cross_litfmt_xpad_wh_display_direct.sv) is `00000xx5`.

A `localparam` and a macro keep the type of the literal, and a concatenation makes it unsigned. A string literal argument without a format is format text,
so [passing it as written](../tests/gen/ch21/test_gen_cross_litfmt_string_d_default_direct.sv) shows `AA`. An untyped parameter is a logic vector of the same width (6.20.2), so [passing it as a parameter](../tests/gen/ch21/test_gen_cross_litfmt_string_h_default_param.sv) shows `4141`.
The full width of an unsized number is only "at least 32 bits", and the full `%d` width of a signed value is read in two ways, so both are left out.

### Independent check and runs

[`qualify_litfmt.py`](../tools/qualify_litfmt.py) turns each literal of the actual SV into a list of bits from its text, expands macros as text, and applies each format one digit at a time.
It uses neither the literal table nor the formatting functions of the model, and all 1,778 programs match.
The [auxiliary evidence](../coverage/interaction-qualification/litfmt.json) keeps nine normal controls and nine executable faults, all detected by an output difference after a normal exit.

In the [single complete 3,887-case run](../coverage/interaction-results/cross98-kirimasim-6e32b04e-ifexprloopfmt.json) on kirimasim `6e32b04ed6ec`, all 91 additions pass. kirimasim has no difference on all 1,778 rows.

### Pinned-release differences

[Pinned Icarus 13.0](../coverage/interaction-results/cross98-ifexprloopfmt-icarus13.json) has 79 pass / 12 known. Over all rows it matches 1,555 and differs on 223.
[Pinned Verilator 5.052](../coverage/interaction-results/cross98-ifexprloopfmt-verilator5052-seed1.json) passes 91 also at [seed 73](../coverage/interaction-results/cross98-ifexprloopfmt-verilator5052-seed73.json), but is not a comparator for rows with X or Z.

<a id="parameter-override-type"></a>

## Parameter overrides and types (2026-11-07)

[`interaction_paramtype.py`](../generators/interaction_paramtype.py) defines `parameter_override_type@1`.
Chapters 6 x 23 map to all 44 cases; chapters 11 x 23 map to rows whose override is an expression (unary minus, concatenation, addition), and chapters 7 x 23 to rows with a packed-structure parameter.

### Factors and scope

The declaration (untyped, `[7:0]`, `signed [7:0]`, `signed` alone, `int`, `logic [3:0]`, a packed structure),
the value (`8'd200`, `-8'sd3`, `4'b1010`, `12'hf0f`, a concatenation, an addition)
and the override (the declared default, `#()` by order, by name, `defparam`, both `#()` and `defparam`, through a `localparam` of the parent) are crossed.
44 cases come from 252 legal rows, covering 120 pair targets and keeping eight mandatory witnesses.

### What it distinguishes

A parameter without a type or range takes the type and range of the final override value (6.20.2, 23.10). A range alone is unsigned with the declared width, `signed` alone is signed with the range of the value, and a type with a range converts to both.
A `defparam` wins over `#()` of the same instance, and then the type and range also come from the `defparam` value.
[An untyped `defparam`](../tests/gen/ch23/test_gen_cross_paramtype_untyped_wide_defparam.sv) of `12'hf0f` gives 3855 in 12 bits, and [`signed` alone with both](../tests/gen/ch23/test_gen_cross_paramtype_signed_concat_both.sv) gives -3 in 4 bits from a four-bit concatenation.
Only override expressions that give the same value at their own width and at the width of the parameter are used, because the standard does not say which width evaluates them.

### Independent check and runs

[`qualify_paramtype.py`](../tools/qualify_paramtype.py) reads the declaration, `#()`, `defparam` and `localparam` from the actual SV, computes each value from its tokens and converts it by the rules of the declaration. All 252 programs match.
The [auxiliary evidence](../coverage/interaction-qualification/paramtype.json) keeps eight normal controls and eight executable faults, all detected by an output difference after a normal exit.

In the [single complete 4,023-case run](../coverage/interaction-results/cross101-kirimasim-eee8cd16-paramassertlit.json) on kirimasim `eee8cd16ba1d`, 40 of the 44 additions pass and four fail.
Over all rows, 24 of 252 differ. When a `defparam` overrides a parameter without a type or range, or with `signed` alone, kirimasim keeps the type and range of the value before the `defparam` (the default or the `#()` value), and the value is cut to it.
Pinned Icarus 13.0 matches the expectations on 20 of these 24 rows; the four addition rows differ only by its separate nine-bit width of the addition. Pinned Verilator 5.052 matches the 12 `defparam` rows without `#()`.

### Pinned-release differences

[Pinned Icarus 13.0](../coverage/interaction-results/cross101-paramassertlit-icarus13.json) has 36 pass / 8 known. [Pinned Verilator 5.052](../coverage/interaction-results/cross101-paramassertlit-verilator5052-seed1.json) has 37 pass / 7 known also at [seed 73](../coverage/interaction-results/cross101-paramassertlit-verilator5052-seed73.json).
See the [simulator differences](simulator-differences.md#param-assert-literal-differences).

<a id="assertion-vector-query"></a>

## Bit vector functions in assertions (2026-11-07)

[`interaction_assertquery.py`](../generators/interaction_assertquery.py) defines `assertion_vector_query@1`.
Chapters 16 x 20 map to all 30 cases; chapters 4 x 16 map to deferred-assertion rows, and chapters 9 x 16 to `always_comb` rows.

### Factors and scope

The function (`$onehot`, `$onehot0`, `$countones(v) == 2`, `!$isunknown`, `$countbits(v, '0) == 2`),
the value (`0100`, `0000`, `0110`, `01x0`, `xxxx`, `1z00`), the assertion (immediate, `#0`, `final`),
the site (initial, `always_comb`, `always @(posedge clk)`) and the timing (settled, or a value in between or an NBA at the rising edge) are crossed.
30 cases come from 450 legal rows, covering 153 targets including the kind, site and timing group and keeping six mandatory witnesses.

### What it distinguishes

`$onehot`, `$onehot0` and `$countones` count only the 1 bits, `$countbits` only the bits equal to its controls, and x and z are not counted (20.9).
`$onehot` holds for `01x0`, and `$onehot0` for `xxxx`. `$isunknown` is 1 when a bit is x or z.
`always_comb` evaluates once at time 0. When it runs again for the value `0011` in between, [the `#0` report](../tests/gen/ch16/test_gen_cross_assertquery_onehot_xone_observed_comb_glitch.sv) is flushed and only the last value reports, while [an immediate assertion](../tests/gen/ch16/test_gen_cross_assertquery_known_xall_simple_comb_glitch.sv) reports both (16.4.2).
An NBA at a rising edge does not change the value evaluated at that edge.

### Independent check and runs

[`qualify_assertquery.py`](../tools/qualify_assertquery.py) computes the functions from four-state bits and runs a scheduler with active, inactive, NBA, observed and postponed regions.
A rerun of the same process empties its queue of deferred reports. It also checks that every order of the processes ready together gives the same output, and all 450 programs match.
The [auxiliary evidence](../coverage/interaction-qualification/assertquery.json) keeps six normal controls and six executable faults, all detected by an output difference after a normal exit.

In the [single complete 4,023-case run](../coverage/interaction-results/cross101-kirimasim-eee8cd16-paramassertlit.json) on kirimasim `eee8cd16ba1d`, all 30 additions pass. kirimasim has no difference on all 450 rows.
kirimasim has not implemented concurrent assertions, so they are left out of this model and added to the [candidates waiting for kirimasim](cross-verification-followup.en.md#models-waiting-for-kirimasim).

### Pinned-release differences

[Pinned Icarus 13.0](../coverage/interaction-results/cross101-paramassertlit-icarus13.json) has 18 pass / 12 known. Over all rows it matches the 150 immediate-assertion rows and rejects the 300 deferred ones.
[Pinned Verilator 5.052](../coverage/interaction-results/cross101-paramassertlit-verilator5052-seed1.json) has 17 pass / 13 known also at [seed 73](../coverage/interaction-results/cross101-paramassertlit-verilator5052-seed73.json).

<a id="literal-argument-conversion"></a>

## Literal arguments and conversion (2026-11-07)

[`interaction_litarg.py`](../generators/interaction_litarg.py) defines `literal_argument_conversion@1`.
Chapters 5 x 13 map to all 62 cases; chapters 6 x 13 map to rows with a two-state, `real` or `string` formal.

### Factors and scope

The literal (`-3`, `'1`, `'x`, `4'sb1010`, `4'b1010`, `'hff`, `2.5`, `1.5e1`, `-2.5`, `"AB"`),
the type of the formal (`bit [7:0]`, `byte`, `logic [11:0]`, `logic signed [11:0]`, `int`, `real`, `string`),
the passing (by position, by name, a default, `return`) and the name (an ordinary or an escaped identifier) are crossed.
62 cases come from 472 legal rows, covering 169 pair targets and keeping eight mandatory witnesses.

### What it distinguishes

An actual argument, a default and a return value are each converted to the type of the formal by the rules of an assignment (13.5, 10.7).
An unbased unsized literal fills the whole width of an integral formal, so [a default of `'1`](../tests/gen/ch13/test_gen_cross_litarg_fill1_byte_default_escaped.sv) is -1 in a `byte`. A two-state type turns x into 0.
A real rounds a half away from zero, so [a function returning `-2.5`](../tests/gen/ch13/test_gen_cross_litarg_negreal_bit8_return_plain.sv) gives 253 in a `bit [7:0]`. A string literal is an unsigned integer of eight-bit characters.
An escaped identifier ends at white space, so a name such as `\a+v ` is followed by a space (5.6.1).

### Independent check and runs

[`qualify_litarg.py`](../tools/qualify_litarg.py) reads the task, function, formal and default from the actual SV, turns each literal into a value from its text, and applies the conversion of an assignment and the display format. All 472 programs match.
The [auxiliary evidence](../coverage/interaction-qualification/litarg.json) keeps eight normal controls and eight executable faults, all detected by an output difference after a normal exit.

In the [single complete 4,023-case run](../coverage/interaction-results/cross101-kirimasim-eee8cd16-paramassertlit.json) on kirimasim `eee8cd16ba1d`, all 62 additions pass. kirimasim has no difference on all 472 rows.

### Pinned-release differences

[Pinned Icarus 13.0](../coverage/interaction-results/cross101-paramassertlit-icarus13.json) has 57 pass / 5 known. Over all rows it matches 422, differs on 20 and rejects 30, all of them default-argument rows.
[Pinned Verilator 5.052](../coverage/interaction-results/cross101-paramassertlit-verilator5052-seed1.json) has 57 pass / 5 known also at [seed 73](../coverage/interaction-results/cross101-paramassertlit-verilator5052-seed73.json).

<a id="hierarchical-process-control"></a>

## Process control through hierarchical names (2026-11-08)

[`interaction_hierproc.py`](../generators/interaction_hierproc.py) defines `hierarchical_process_control@1`.
Chapters 9 x 23 map to all 42 cases; chapters 15 x 23 map to event-trigger rows, 13 x 23 to task-call rows and 10 x 23 to value-write rows.

### Factors and scope

The action (`disable` of a named block, `->` of an event, a blocking write that wakes `@`, a blocking write that lets `wait` go on, a nonblocking write, a call of a task with a delay),
the hierarchical name (downward, downward to a grandchild, an element of an instance array, inside a loop generate block, from `$root`, upward by the module name, upward to a sibling instance),
the timing (the target waits from time 1, or from time 4 after the action) and the actor (initial, its own task, a child of `fork`-`join_none`) are crossed.
42 cases come from 252 legal rows, covering 149 targets including the action, timing and actor group and keeping seven mandatory witnesses.

### What it distinguishes

A downward name, a name from `$root`, and an upward name by a module name or a sibling instance name all reach the same target (23.6, 23.8).
Disabling a running block goes on after that block. [Disabling a block that is not running](../tests/gen/ch23/test_gen_cross_hierproc_disable_root_late_initial.sv) does nothing (9.6.2).
An event trigger or a value change with no process waiting is lost, but [a `wait`](../tests/gen/ch23/test_gen_cross_hierproc_level_generate_late_initial.sv) goes on at once when its condition already holds as it starts (9.4.3).
A read right after a nonblocking write gives the old value. A task called through a hierarchical name writes the variable of the instance where it is declared, and its delay passes in the calling process.
The actor prints before it acts, so no two processes race to print in the same time slot.

### Independent check and runs

[`qualify_hierproc.py`](../tools/qualify_hierproc.py) builds the tree of instances, generate blocks, tasks and named blocks from the actual SV and resolves names by the steps of 23.6 and 23.8.
It runs each process under a scheduler with an active and an NBA region, and checks that every start order of the processes gives the same output. All 252 programs match.
The [auxiliary evidence](../coverage/interaction-qualification/hierproc.json) keeps seven normal controls and seven executable faults, all detected by an output difference after a normal exit.

In the [single complete 4,170-case run](../coverage/interaction-results/cross104-kirimasim-28c6c1a1-hierloop.json) on kirimasim `28c6c1a1cb83`, all 42 additions pass. kirimasim has no difference on all 252 rows.

### Pinned-release differences

[Pinned Icarus 13.0](../coverage/interaction-results/cross104-hierloop-icarus13.json) has 36 pass / 6 known. Over all rows it reports a syntax error on the 36 rows with `$root` and matches the other 216.
[Pinned Verilator 5.052](../coverage/interaction-results/cross104-hierloop-verilator5052-seed1.json) has 40 pass / 2 known also at [seed 73](../coverage/interaction-results/cross104-hierloop-verilator5052-seed73.json). Over all rows it does not support `disable` through an instance array element or a generate block (12 rows) and matches the other 240.

<a id="hierarchical-name-display"></a>

## Hierarchical names printed by %m (2026-11-08)

[`interaction_hiername.py`](../generators/interaction_hiername.py) defines `hierarchical_name_display@1`.
Chapters 21 x 23 map to all 65 cases; chapters 21 x 27 map to rows inside generate blocks, 13 x 21 to subroutine rows, 9 x 21 to named-block and label rows, and 12 x 21 to loop-label rows.

### Factors and scope

The place (the top module, a child, a grandchild, an element of an instance array, a loop generate block, a named generate block, an unnamed generate block),
the scope (the module, a named begin, nested begins, a named fork, a statement label, the label of a `for` that declares its variable, a task, an automatic task, a function),
the call (from its own module, downward, from `$root`, upward by the module name) and the procedure (initial, final) are crossed.
65 cases come from 177 legal rows, covering 170 targets including the scope, call and procedure group and keeping seven mandatory witnesses.

### What it distinguishes

`%m` prints the hierarchical name of the module instance, named block, labeled statement or subroutine that holds the display (21.2.1.5).
A subroutine prints the name where it is declared, whether it is called from its own module, downward, from `$root` or [upward](../tests/gen/ch21/test_gen_cross_hiername_unnamedgen_task_up_initial.sv). The caller first prints its own name.
A statement label and the label of a `for` that declares its variable make a named block (9.3.5).
An unnamed generate block is named `genblk` with the number of its generate construct counted in its scope (27.6). Here a named loop generate comes first, so the name is `genblk2`.
Names inside an unnamed generate block cannot be reached from outside it, so downward and `$root` calls into it are left out. A final procedure holds only what a function may hold, so task calls and `fork`-`join` are left out there.

### Independent check and runs

[`qualify_hiername.py`](../tools/qualify_hiername.py) builds the tree from the actual SV, names unnamed generate blocks by the numbers of the generate constructs, and resolves labels and subroutine names. All 177 programs match.
The [auxiliary evidence](../coverage/interaction-qualification/hiername.json) keeps seven normal controls and seven executable faults, all detected by an output difference after a normal exit.

In the [single complete 4,170-case run](../coverage/interaction-results/cross104-kirimasim-28c6c1a1-hierloop.json) on kirimasim `28c6c1a1cb83`, all 65 additions pass. kirimasim has no difference on all 177 rows.

### Pinned-release differences

[Pinned Icarus 13.0](../coverage/interaction-results/cross104-hierloop-icarus13.json) has 45 pass / 20 known. Over all rows it reports a syntax error on 28 rows with statement or loop labels and 24 rows with `$root`, and matches the other 125.
[Pinned Verilator 5.052](../coverage/interaction-results/cross104-hierloop-verilator5052-seed1.json) has 58 pass / 7 known also at [seed 73](../coverage/interaction-results/cross104-hierloop-verilator5052-seed73.json). Over all rows `%m` adds an extra `.unnamedblk1` on the 14 loop-label rows.

<a id="array-query-loop"></a>

## Array query functions and loops (2026-11-08)

[`interaction_arrayloop.py`](../generators/interaction_arrayloop.py) defines `array_query_loop@1`.
Chapters 12 x 20 and 7 x 20 map to all 40 cases; chapters 7 x 12 map to `foreach` and `do`-`while` rows.

### Factors and scope

The dimension (`[0:3]`, `[3:0]`, `[5:2]`, `[-2:1]`, a packed `[1:4]`, a dynamic array, a queue, an empty dynamic array),
the query (the variable, a `typedef` type name, the second dimension, the element select `w[1]`),
the loop (`for`, `while`, `do`-`while`, `repeat`, `foreach`) and the range (left to right, low to high, high to low, counting `$size`) are crossed.
40 cases come from 440 legal rows, covering 151 pair targets and keeping seven mandatory witnesses.

### What it distinguishes

`$increment` is 1 for a fixed dimension whose left bound is not less than its right bound, -1 for another fixed dimension, and -1 for a dynamic array or a queue; `$low` and `$high` follow from it (20.7).
An empty dynamic array has `$right` and `$high` of -1 and `$size` of 0. `$dimensions` counts packed dimensions as well, and `$unpacked_dimensions` does not.
[A query of the second dimension](../tests/gen/ch20/test_gen_cross_arrayloop_neg_dim_for_leftright.sv) walks the negative range `[-2:1]` from left to right. A type name and a dimension after the first are queried on fixed-size dimensions only (20.7.1).
`foreach` goes from the left index to the right (12.7.3). [A `do`-`while` on an empty array](../tests/gen/ch20/test_gen_cross_arrayloop_empty_elem_do_highlow.sv) runs once and reads x from the element that does not exist (7.4.5).

### Independent check and runs

[`qualify_arrayloop.py`](../tools/qualify_arrayloop.py) lists the dimensions from the declarations of the actual SV, unpacked first and then packed, computes the queries by the rules of 20.7, and evaluates the statements and loops directly. All 440 programs match.
The [auxiliary evidence](../coverage/interaction-qualification/arrayloop.json) keeps seven normal controls and seven executable faults, all detected by an output difference after a normal exit.

In the [single complete 4,170-case run](../coverage/interaction-results/cross104-kirimasim-28c6c1a1-hierloop.json) on kirimasim `28c6c1a1cb83`, all 40 additions pass. kirimasim has no difference on all 440 rows.

### Pinned-release differences

[Pinned Icarus 13.0](../coverage/interaction-results/cross104-hierloop-icarus13.json) has 14 pass / 26 known. Over all rows it matches 169, differs on 49, rejects 221 and does not end on one.
[Pinned Verilator 5.052](../coverage/interaction-results/cross104-hierloop-verilator5052-seed1.json) has 38 pass / 2 known also at [seed 73](../coverage/interaction-results/cross104-hierloop-verilator5052-seed73.json). Over all rows it matches 432 and differs on eight.
See the [simulator differences](simulator-differences.md#hier-array-differences).

<a id="delay-value-form"></a>

## How a delay value is written (2026-11-08)

[`interaction_delayval.py`](../generators/interaction_delayval.py) defines `delay_value_form@1`.
Chapters 5 x 9 map to all 60 cases; chapters 9 x 10 map to rows with a delay inside an assignment, and chapters 3 x 9 to real and time-literal rows.

### Factors and scope

The value (`3`, `(3'b101)`, `2.4`, `2.6`, `3ns`, `2700ps`, `(1'bx)`, `(1'bz)`, `(4'b00x1)`, `(-1)`),
the site (before a statement, inside a blocking assignment, inside a nonblocking assignment, a `fork` branch, a task, `repeat`),
the start (time 0, time 10) and the precision (1ns, 100ps) are crossed. The time unit is always 1ns.
60 cases come from 222 legal rows, covering 126 pair targets and keeping seven mandatory witnesses.

### What it distinguishes

A delay takes its value in time units and is rounded to the precision before it waits (3.14.1). A time literal is converted from its own unit (5.8).
[A `repeat` that waits `2.4` twice](../tests/gen/ch9/test_gen_cross_delayval_real_down_repeat_later_unit.sv) steps by 2 at a precision of 1ns and by 2.4 at 100ps. No value lies on a rounding tie.
A delay with any x or z bit is zero (9.4.1). [`(1'bx)` inside a nonblocking assignment](../tests/gen/ch9/test_gen_cross_delayval_x_nba_later_tenth.sv) changes the value in the NBA region of the same time.
A negative delay is a 64-bit unsigned time, so [its statement](../tests/gen/ch9/test_gen_cross_delayval_neg_repeat_zero_unit.sv) never runs before the end.
Cases where adding it to the current time, or converting it to the precision, passes the largest time are left out, because the standard does not define them.

### Independent check and runs

[`qualify_delayval.py`](../tools/qualify_delayval.py) turns the text of each delay into ticks of the precision from `timeunit` and `timeprecision` in the actual SV.
It runs every start order of the processes under a scheduler with active, inactive and NBA regions. All 222 programs match.
The [auxiliary evidence](../coverage/interaction-qualification/delayval.json) keeps seven normal controls and seven executable faults, all detected by an output difference after a normal exit.

In the [single complete 4,296-case run](../coverage/interaction-results/cross107-kirimasim-28c6c1a1-delaypkgesc.json) on kirimasim `28c6c1a1cb83`, all 60 additions pass. kirimasim has no difference on all 222 rows.

### Pinned-release differences

[Pinned Icarus 13.0](../coverage/interaction-results/cross107-delaypkgesc-icarus13.json) passes all 60 cases and matches all 222 rows.
[Pinned Verilator 5.052](../coverage/interaction-results/cross107-delaypkgesc-verilator5052-seed1.json) has 46 pass / 14 known at seed 1 and 43 pass / 17 known at [seed 73](../coverage/interaction-results/cross107-delaypkgesc-verilator5052-seed73.json).
Over all rows, 37 rows with x or z delays differ and 12 rows with z delays are unsupported.

<a id="package-name-lookup"></a>

## Package name lookup (2026-11-08)

[`interaction_pkglookup.py`](../generators/interaction_pkglookup.py) defines `package_name_lookup@1`.
Chapters 12 x 26 map to all 37 cases; chapters 13 x 26 map to function-call rows.

### Factors and scope

How `lk_p` comes in (a wildcard import in the module, a wildcard import in the block, an explicit import, `lk_p::`),
the competing name (none, a declaration before the procedure, a block variable, a wildcard import of `lk_q` in the block, a declaration after the procedure, a wildcard import of `lk_q` after the procedure),
the reference (the variable `n`, the function `f()`) and the loop (`for`, `while`, `repeat`, `do`-`while`) are crossed.
37 cases come from 148 legal rows, after leaving out illegal combinations, covering 125 targets including the import, competitor and reference group and keeping seven mandatory witnesses.

### What it distinguishes

The scope of the reference is searched first, among declarations and explicit imports and then among wildcard imports before that point, and then the outer scope (26.3).
So [a wildcard import in the block](../tests/gen/ch26/test_gen_cross_pkglookup_block_wild_outer_decl_var_for.sv) is found before a module declaration that precedes the procedure.
A function call searches the declarations up to the end of the scope, so [a module function after the procedure](../tests/gen/ch26/test_gen_cross_pkglookup_module_wild_later_decl_call_repeat.sv) wins over an earlier wildcard import.
A wildcard import after the reference is not used. An explicit import with a declaration in the same scope, a declaration after a reference imported the name, and a reference that two wildcard imports both supply are illegal and left out.

### Independent check and runs

[`qualify_pkglookup.py`](../tools/qualify_pkglookup.py) reads the packages, imports and declarations of the actual SV in text order and searches each scope by the steps of 26.3. All 148 programs match, and all 28 illegal rows left out are errors for it.
The [auxiliary evidence](../coverage/interaction-qualification/pkglookup.json) keeps seven normal controls and seven executable faults, all detected by an output difference after a normal exit.

In the [single complete 4,296-case run](../coverage/interaction-results/cross107-kirimasim-28c6c1a1-delaypkgesc.json) on kirimasim `28c6c1a1cb83`, all 37 additions pass. kirimasim has no difference on all 148 rows.

### Pinned-release differences

[Pinned Icarus 13.0](../coverage/interaction-results/cross107-delaypkgesc-icarus13.json) and [pinned Verilator 5.052](../coverage/interaction-results/cross107-delaypkgesc-verilator5052-seed1.json) (also at [seed 73](../coverage/interaction-results/cross107-delaypkgesc-verilator5052-seed73.json)) match all 37 cases and all 148 rows.

<a id="escaped-name-binding"></a>

## Escaped identifier binding (2026-11-08)

[`interaction_escname.py`](../generators/interaction_escname.py) defines `escaped_name_binding@1`.
Chapters 5 x 23 map to all 29 cases; chapters 5 x 13 map to task rows, and chapters 5 x 27 to generate-block rows.

### Factors and scope

The named item (a module, an instance, a port, a parameter, a variable, a task, a generate block),
the declared spelling (plain, the same letters escaped, an escaped name with `+1`, an escaped keyword),
the reference (as declared, or with the plain and escaped forms swapped) and the white space that ends the reference (a space, a tab, a newline, several spaces) are crossed.
29 cases come from 126 legal rows, covering 100 pair targets and keeping seven mandatory witnesses.

### What it distinguishes

An escaped identifier runs from `\` to the next white space, and neither the `\` nor the ending white space is part of the name. `\abc` and `abc` are one name, and an escaped keyword is a user-defined name (5.6.1).
In a hierarchical name, [an escaped instance name](../tests/gen/ch5/test_gen_cross_escname_inst_special_same_newline.sv) is followed by white space, such as a newline, and then the period (23.6).
A name with `+1` comes with another declaration named like its part before the `+`, so [splitting the name in the wrong place changes a value](../tests/gen/ch5/test_gen_cross_escname_var_special_same_tab.sv).

### Independent check and runs

[`qualify_escname.py`](../tools/qualify_escname.py) splits the actual SV into tokens by the rules of 5.6, binds the module, parameter, ports, variables, task and generate block by name and evaluates them. All 126 programs match.
The [auxiliary evidence](../coverage/interaction-qualification/escname.json) keeps seven normal controls and seven executable faults, all detected by an output difference after a normal exit.

In the [single complete 4,296-case run](../coverage/interaction-results/cross107-kirimasim-28c6c1a1-delaypkgesc.json) on kirimasim `28c6c1a1cb83`, all 29 additions pass. kirimasim has no difference on all 126 rows.

### Pinned-release differences

[Pinned Icarus 13.0](../coverage/interaction-results/cross107-delaypkgesc-icarus13.json) and [pinned Verilator 5.052](../coverage/interaction-results/cross107-delaypkgesc-verilator5052-seed1.json) (also at [seed 73](../coverage/interaction-results/cross107-delaypkgesc-verilator5052-seed73.json)) match all 29 cases and all 126 rows.

<a id="scoped-class-declaration"></a>

## Classes declared in a module or a generate block (2026-11-08)

[`interaction_scopeclass.py`](../generators/interaction_scopeclass.py) defines `scoped_class_declaration@1`.
Chapters 8 x 23 map to all 48 cases; chapters 8 x 27 map to the 36 cases that declare the class in a generate block.

### Factors and scope

The place that declares the class (the child module, a loop generate block, an if-else generate block, a case generate block),
what the method reads (the parameter `P`, the local parameter `L`, the variable `v`, the function `f()`),
the caller (an `initial` in the declaring scope, a hierarchical name from the top module),
the method (an instance method, a static method called through the class scope, a method of a derived class that adds 1000 to `super.get()`)
and the same name (none, a static member of the class, the outer scopes) are crossed. The child module has two instances, with `P` 1 and 2.
A static method is called only from its declaring scope, so its rows with a hierarchical caller are left out.
48 cases come from 240 legal rows, covering 148 targets with the place, the item and the same-name group, and keeping seven mandatory witnesses.

### What it distinguishes

A name in a method is looked up first among the class members and the inherited members, then in the scope that declares the class and the scopes around it (23.9).
So [a class in a loop generate block](../tests/gen/ch8/test_gen_cross_scopeclass_gen_for_local_local_instance_outer.sv) reads the `L` of its block and none of the same names in the child module and the top module.
The variable is increased by 100 between two reads, which shows that the method reads the value at the call.
A conditional generate makes only the selected block, and the classes `C` of the two branches are different types (27.5).
[A static method that calls `f()` in an if branch](../tests/gen/ch8/test_gen_cross_scopeclass_gen_if_function_local_static_property.sv) finds the static method of the class, which hides the function outside.
A call from the top module through [`u1.g[0].h.get()`](../tests/gen/ch8/test_gen_cross_scopeclass_gen_for_variable_hier_derived_outer.sv) binds names where the class is declared and does not read the same names in the top module.

### Independent check and runs

[`qualify_scopeclass.py`](../tools/qualify_scopeclass.py) reads the modules, generate constructs, declarations, classes and `initial` procedures of the actual SV.
It elaborates each instance with its parameter: a block per genvar value for a loop, and only the block whose condition holds for if and case.
Method names are looked up in the order of 23.9, and the `initial` procedures run in the order of their delays. All 240 programs match.
The [auxiliary evidence](../coverage/interaction-qualification/scopeclass.json) keeps seven normal controls and seven executable faults, all detected by an output difference after a normal exit.

In the [single complete 4,416-case run](../coverage/interaction-results/cross110-kirimasim-f029ddd0-scopecaselit.json) on kirimasim `f029ddd0eee1`, 42 of the 48 additions pass and six fail.
The failures are the rows where a class in an if or case generate block has a static property. kirimasim stops with an internal error on a class with a static property, and a variable of its type, in the branch that is not instantiated.
Over all 240 rows, the 30 rows of this form all give the same internal error, and the other 210 match. The expectations stay as the standard gives them.
kirimasim `33cee3fa2f0d` gives the same internal error for the same six, and in the [Nightly](https://github.com/kurochan001/kirimasim-tests/actions/runs/42477954992) built with GCC 13.3 on Ubuntu 24.04 they also fail, with exit code 3.

### Pinned-release differences

[Pinned Icarus 13.0](../coverage/interaction-results/cross110-scopecaselit-icarus13.json) has 11 pass and 37 known. A class in a generate block stops on an internal check of the compiler.
A static method call `C::get()` of a class declared in a module is a syntax error. Over all 240 rows, 48 match and 192 are rejected.
[Pinned Verilator 5.052](../coverage/interaction-results/cross110-scopecaselit-verilator5052-seed1.json) passes all 48 cases at seed 1 and at [seed 73](../coverage/interaction-results/cross110-scopecaselit-verilator5052-seed73.json), and matches all 240 rows.
It also matches the expectations of the six cases that kirimasim fails.

<a id="case-literal-wildcard"></a>

## ?, z and x digits in case item literals (2026-11-08)

[`interaction_casedigit.py`](../generators/interaction_casedigit.py) defines `case_literal_wildcard@1`.
Chapters 5 x 12 map to all 24 cases.

### Factors and scope

The base of the item literal (binary, octal, hexadecimal, decimal), its digit (`?`, `z`, `x`), its leftmost digit (the wildcard or a known digit),
its width (6, 8 or 12 bits, unsized) and the statement (`case`, `casez`, `casex`, `case inside`) are crossed.
A decimal number may hold only one such digit, so it always leads with it, and two hexadecimal digits do not fit in six bits, so those rows are left out.
24 cases come from 312 legal rows, covering 136 targets with the digit, the leftmost digit and the statement group, and keeping seven mandatory witnesses.
Each program compares an 8-bit selector five times: with the wildcard positions filled with known bits, with one known bit flipped, with one known bit made z, or made x, and with the item's own four-state bits.

### What it distinguishes

`?` is another spelling of `z`; a hexadecimal digit sets 4 bits and an octal digit 3, and a decimal `x`, `z` or `?` sets every bit (5.7.1).
A literal shorter than its size is padded on the left with its leftmost bit if that is x or z, and with zeros otherwise.
The case then extends the selector and the item to the wider width with zeros (12.5).
So the two upper bits of [`6'b1z0z`](../tests/gen/ch5/test_gen_cross_casedigit_bin_z_known_narrow_casez.sv) are 0, and the upper bits of [`12'b?1?0`](../tests/gen/ch5/test_gen_cross_casedigit_bin_q_wild_wide_casez.sv) are z.
`casez` skips a bit that is z on either side, and `casex` one that is x or z (12.5.1).
`case inside` skips only an x or z bit of the item, and an x or z in the selector does not match (12.5.4, 11.4.6). [`8'hx5` in a `case inside`](../tests/gen/ch5/test_gen_cross_casedigit_hex_x_wild_same_inside.sv) shows this asymmetry.

### Independent check and runs

[`qualify_casedigit.py`](../tools/qualify_casedigit.py) reads the literals of the actual SV by 5.7.1 and compares the bits by the rule of each statement. All 312 programs match.
The [auxiliary evidence](../coverage/interaction-qualification/casedigit.json) keeps seven normal controls and seven executable faults, all detected by an output difference after a normal exit.

In the [single complete 4,416-case run](../coverage/interaction-results/cross110-kirimasim-f029ddd0-scopecaselit.json) on kirimasim `f029ddd0eee1`, all 24 additions pass. kirimasim has no difference on all 312 rows.

### Pinned-release differences

[Pinned Icarus 13.0](../coverage/interaction-results/cross110-scopecaselit-icarus13.json) passes 18 cases; the six `case inside` cases are syntax errors. Over all 312 rows, the 234 rows other than `case inside` match.
[Pinned Verilator 5.052](../coverage/interaction-results/cross110-scopecaselit-verilator5052-seed1.json) (also at [seed 73](../coverage/interaction-results/cross110-scopecaselit-verilator5052-seed73.json)) rejects every row, where a value with z is passed to a task argument, as an unsupported tristate construct.

<a id="aggregate-literal-key"></a>

## Keys of structure literals (2026-11-08)

[`interaction_agglit.py`](../generators/interaction_agglit.py) defines `aggregate_literal_key@1`.
Chapters 5 x 7 map to all 48 cases.

### Factors and scope

The structure has a member `a` of `nib_t` (`logic [3:0]`), a structure `n` with int, `nib_t`, byte and integer members, and an int array `q[2]`.
The keys (positions, member names, replication, default, type keys in the nested patterns, a type key with default, a member name with a type key and default, a type key given twice),
the value (`'1`, `'x`, `-2`, `2.5`, `12'h9f5`, `3'sb101`) and the context (a declaration initializer, a procedural assignment, a typed pattern expression, a localparam) are crossed.
All 192 rows are legal, and 48 cases are selected, covering 104 pair targets and keeping seven mandatory witnesses.

### What it distinguishes

A structure literal gives values by position, member name, type and default (5.10, 10.9.2).
A member name comes first, then a type key whose type matches, then default; a type key given twice uses its later value.
Default goes down into structure and array members that no name or type sets, and the type keys apply there as well.
int and integer differ in the number of states, so they are not matching types (6.22.1), and [an int key does not reach an integer member](../tests/gen/ch5/test_gen_cross_agglit_type_default_fillx_assign.sv).
A value is converted as an assignment to each member (10.7): `3'sb101` is sign-extended, `12'h9f5` truncated, `2.5` rounded to 3, and x becomes 0 in a two-state member.
Whether type keys go down into a nested structure when there is no default is read in two ways, so in that form the type keys are written in the nested patterns themselves.

### Independent check and runs

[`qualify_agglit.py`](../tools/qualify_agglit.py) reads the typedefs of the actual SV into types, applies the pattern by the rules of 10.9 and converts each value to its member type. All 192 programs match.
The [auxiliary evidence](../coverage/interaction-qualification/agglit.json) keeps seven normal controls and seven executable faults, all detected by an output difference after a normal exit.

In the [single complete 4,416-case run](../coverage/interaction-results/cross110-kirimasim-f029ddd0-scopecaselit.json) on kirimasim `f029ddd0eee1`, 40 of the 48 additions pass and the eight localparam cases are unsupported.
kirimasim has not implemented a localparam of an unpacked structure yet. Over all 192 rows, the 48 localparam rows are unsupported and the other 144 match.

### Pinned-release differences

[Pinned Icarus 13.0](../coverage/interaction-results/cross110-scopecaselit-icarus13.json) has not implemented unpacked structures and rejects all 48 cases and all 192 rows.
[Pinned Verilator 5.052](../coverage/interaction-results/cross110-scopecaselit-verilator5052-seed1.json) (also at [seed 73](../coverage/interaction-results/cross110-scopecaselit-verilator5052-seed73.json)) has 15 pass and 33 known.
It does not take default down into the nested structure and array, does not accept a typedef name as a type key, and reads `'x` as two-state. Over all 192 rows, 60 match.

<a id="simulation-end-sources"></a>

## Where the run is ended and how it ends (2026-11-14)

[`interaction_simend.py`](../generators/interaction_simend.py) defines `simulation_end_sources@1`.
Chapters 9×20 map all 42 cases. Chapters 13×20 map the calls from a task or a function, and chapters 20×24 the calls from a program.

### Factors and scope

The model crosses the task that ends the run (`$finish`, `$fatal`, `$exit`), the place of the call (initial, always, a child forked with join_none, an automatic task, an automatic function),
the wait until time 5 (a delay, a named event, a variable change), the scope of the caller (the top module, a child instance, a nested program)
and a second end scheduled at time 8 (none, `$finish`, `$fatal`).
A program holds no always procedure (24.3), so that combination is left out. `$exit` is called only from a program:
called from a module thread, it is an implicit `$finish` after every program completes by 20.2 and is ignored by 24.7, so the result would depend on the reading.
42 cases are selected from 288 legal rows. They keep 205 targets, including the three-factor groups task-place-scope, place-wait-scope and task-scope-second end, and 10 mandatory cases.

### What it distinguishes

Each program prints one line with the time, place, scope and task just before the call, and one final procedure prints the end time and these values:
the write at time 3, the number of rising clock edges at even times, a write one unit after the call in the calling thread, a write 20 units into the parent of a fork, writes by a delay and an event at time 7, and a write just before the second end at time 8.
`$finish` ends the simulation (20.2), and `$fatal` makes an implicit `$finish` (20.10).
`$exit` from a thread that begins in an initial procedure of a program ends every initial procedure of that program and their descendants (24.7). When the only program has ended, the implicit `$finish` of 24.3 ends the run.
Every row ends at time 5, and the final procedure shows only the write at 3 and the clock edge at 2.
The exit code is nonzero when `$fatal` is called and 0 otherwise, which also shows that [a `$fatal` at time 8 does not run](../tests/gen/ch20/test_gen_cross_simend_finish_function_delay_child_fatal.sv).
At time 5 only the calling process and the process that releases its wait run. Statements that run after the call in the same time step are not observed, since the standard does not settle them.
There is one final procedure only, since the order of final procedures is not fixed (9.2.3).

### Independent check and runs

[`qualify_simend.py`](../tools/qualify_simend.py) parses the actual SV and runs it on a small event scheduler.
It runs every program four times, with the processes in forward and reverse order and with `$finish` ending at once or at the end of the time step, and requires the same output and exit code each time. All 288 programs match their expectation.
The [auxiliary evidence](../coverage/interaction-qualification/simend.json) keeps six normal controls and ten executable faults on kirimasim `afc7733c8167`. Every fault was detected by a difference in the output of a normal run.

In the [single run of all 4,455 cases](../coverage/interaction-results/full-20261114-kirimasim-afc7733c.json) on kirimasim `afc7733c8167`, all 42 additions pass.
In the [one run of all 288 rows](../coverage/interaction-qualification/simend-all-rows-20261114.json), every row matches on kirimasim too.

### Pinned-release differences

[Pinned Icarus 13.0](../coverage/interaction-results/simend-20261114-icarus13.json) passes 38 cases. It cannot run the four `$exit` cases. Over all 288 rows, the 252 rows without `$exit` match.
[Pinned Verilator 5.052](../coverage/interaction-results/simend-20261114-verilator5052-seed1.json) (also at [seed 73](../coverage/interaction-results/simend-20261114-verilator5052-seed73.json)) passes 20 cases.
It rejects a nested program as unsupported, and does not run the final procedure after `$fatal`. Over all 288 rows, 90 match.
