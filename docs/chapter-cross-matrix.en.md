<a id="章間クロス検証マトリクス"></a>

# Chapter interaction matrix

[日本語](chapter-cross-matrix.md)

The CSV matrices show which IEEE 1800-2023 chapters are crossed. Both axes cover chapters 1–41; UTF-8 BOM encoding allows opening them in Excel. The first two columns identify the row chapter and title; column headings identify the other chapter.

- [Registered model counts](../coverage/chapter-cross-models.en.csv): distinct models mapped to each chapter pair.
- [All-selected-cases-pass model counts](../coverage/chapter-cross-passed-models.en.csv): the same layout, counting only models whose entire selection passed in the saved run below.
- [Mapping and execution details](../coverage/chapter-cross-details.en.csv): pair, model ID, rationale, conditions, case counts, pass/fail/known/unsupported, representative test, expectation and result JSON.

See [zero-cell triage](chapter-cross-triage.en.md) for reasons and next candidates. A separate 41×41 CSV shows classification codes, with rationales, priorities, factor proposals and observations. Unreviewed cells remain awaiting review rather than being declared out of scope or low risk.

For example, chapter 7 (aggregate data types) × 13 (tasks and functions) has four models covering array-element argument passing, binding after index changes, queue-element references and generated-scope array defaults. Chapters 11 (operators/expressions) × 12 (procedural statements) have two models for ordinary case matching and case-inside selection; one of these two models passed its full selection.

<a id="数字の読み方"></a>

## Reading the counts

Cells count models, not tests. Read [why cells cannot be summed](faq.en.md#q32-can-i-sum-matrix-cells-to-get-the-cross-test-total), [zero and M/E/C/N/R](faq.en.md#q33-do-zero-cells-and-mecnr-indicate-missing-tests-or-passes), and [complete versus every selected case passing](faq.en.md#q34-are-complete-and-all-selected-tests-pass-the-same-judgment).

Off-diagonal cells count **models mapped to chapter interactions**. A model can map to several pairs. Diagonal cells count **models whose primary chapter is that chapter**, following the test's first `:lrm:` clause. Only the diagonal sums to the model total; it does not establish exhaustive crossing within a chapter.

The matrix is symmetric. Summing triangles or arbitrary cells gives neither test nor model totals. Zero means no mapped model in this aggregation, not absent tests, unsupported implementation or zero requirement coverage. Annexes are not axes.

The scope is [registered finite interaction models](interaction-verification.en.md), not an aggregation of all tests. It excludes ordinary tests and the 56 [issue #21 boundary regressions](p1-combination-regressions-20261030.en.md) not registered as finite models. It measures neither chapter requirement coverage nor the full product of chapter features.

<a id="対応付けの根拠"></a>

## Mapping rationale

The [mapping registry](../coverage/chapter-interactions.json) records AI review of factors, stimulus and observations. Pairs are not inferred from every chapter cited in a test: display-only `$display` use or a process needed merely to execute a test must not inflate interaction counts. These are reviewed interactions, not an exhaustive list of possible mappings.

Where only some factor levels exercise a pair, `when` restricts the mapping. For example, chapter 7×13 in the task-argument model includes only array-element actuals. Matching-selection and status counts apply that filter; whole-model selection counts may differ. A representative test is one example. Every selected path is in each model's `selection` in the [plan JSON](../coverage/interaction-summary.json).

<a id="実行結果の扱い"></a>

## Execution policy

The 2026-11-06 mapping contains 88 models and 3,244 selected cases across 131 unordered off-diagonal pairs. The [complete kirimasim 6f5c69841228 local run](../coverage/interaction-results/cross88-kirimasim-6f5c6984-pkgquery.json) records 2,711 pass, 529 unsupported and four failures; 61 models passed their entire selection.

[Check on baseline 9c39d865](https://github.com/kurochan001/kirimasim-tests/actions/runs/42051092628) passed pinned-release comparisons and static checks for the preceding 86-model suite.
The [verified formal Nightly](nightly-results.en.md#latest-verified-checkpoint) covers 82 models on 19cd790a; the new 36 cases have not run in either Check or Nightly.
The CSVs use the complete 3,244-case local cross88 run; partial successes from different runs are not combined.
The thirteen random profiles and their 96 Nightly passes do not enter these matrices.

- **20×26, package queries:** map all 36 cases, adding one registered model and one full-selection-pass model. Full-model success requires all 36 in the same saved run. See [design and independent evidence](interaction-verification.en.md#package-array-query-scope).

- **13×24 and 12×24, program/task lifetime:** map all 36 cases to 13×24 and the eight early-return cases to 12×24; each has one model and one full-selection-pass model. Full-model success requires all 36 together. See [design and independent evidence](interaction-verification.en.md#program-task-frame-lifetime).

- **11×21 and 20×21, formatted scanning:** map the 24 part-select cases to 11×21 and the twelve runtime-format cases to 20×21; each has one model and one full-selection-pass model. Full-model success still requires all 36 together. See [design and independent evidence](interaction-verification.en.md#formatted-scan-partial-write).

- **11×27 and 20×27, constant-expression/generate shape:** one model and one full-selection-pass model each, mapping all 36 cases. See [design and independent evidence](interaction-verification.en.md#generated-constant-expression-shape).

- **7×25, 20×25 and 13×20, interface array queries:** one model and one full-selection-pass model each, mapping all 36 cases. See [design and independent evidence](interaction-verification.en.md#interface-array-query-walk).

- **12×27 and 9×27, generated process loops:** one model and one full-selection-pass model each, mapping all 36 cases and strengthening 7×27. See [design and independent evidence](interaction-verification.en.md#generated-process-loop-transfer).

- **8×11 and 8×12, class selection/early return:** one model and one full-selection-pass model each. The former maps all 36 cases; the latter maps the 24 if/case cases. A full model pass still requires all 36 together. Observe dynamic/static dispatch, X/Z selection, typed returns, receiver updates, aliases and dead effects. See [design and independent evidence](interaction-verification.en.md#class-conditional-return).

- **13×27 and 7×27, generated subroutine/array binding:** all 36 subroutine cases map to both pairs. 13×27 has one full-selection-pass model; 7×27 now has two including generated loops. The existing **7×13** mapping gains this fourth model. Observe per-scope widths/ranges, default reevaluation, function/task results, neighbor retention and repeated calls. See [design and independent evidence](interaction-verification.en.md#generated-subroutine-binding).

- **8×26, class method/package lookup:** one model and one full-selection-pass model. All 34 cases check lexical import scope, typed function/task results, object identity and state retention through aliasing/rebinding. See [design, independent checks and limits](interaction-verification.en.md#class-method-package-lookup).

- **14×15, clocking inputs and named-event waiters:** one model, zero all-selection-pass models. Of 24 cases, the 12 `#1step` cases pass and the 12 `#0` cases are unsupported. Both fixed Verilator seeds record 12 pass and 12 known nonblocking-notification differences; fixed Icarus rejects all 24 builds. See [design, controls and limits](interaction-verification.en.md#clocking-named-event).
- **9×16, deferred reports:** all 31 cases pass, giving one all-selection-pass model. The other four failures are configuration parameter-reset cases; the two inside cases pass after the repair. See [triage and historical repair-build identities](cross-verification-followup.en.md).

- **7×18, reduction constraints:** one model, zero all-selection-pass models because randomize/class-array operations are unsupported. Both fixed Verilator seeds have output differences on all 13 original cases; auxiliary controls remain separate. See [design/evidence](interaction-verification.en.md#array-reduction-constraints-and-retention).
- **7×20, associative-array queries:** one model, zero all-selection-pass models because typed associative-array variables are unsupported. Both fixed Verilator seeds have 18 output differences; fixed Icarus rejects all builds. See [design/evidence](interaction-verification.en.md#associative-array-domains-and-allocation).
- **9×14, clocking iff:** one model, zero all-selection-pass models because guarded clocking events are unsupported. Each fixed Verilator seed has 4 passes and 8 known internal build errors. See [design/evidence](interaction-verification.en.md#clocking-event-guards-and-held-samples).
- **8×25, class virtual interfaces:** one model, zero all-selection-pass models because the class-held virtual-interface types are unsupported. Both fixed Verilator seeds pass all 13 cases. See [design/evidence](interaction-verification.en.md#class-virtual-interface-rebinding).
- **21×28, strength formatting:** one model and one all-selection-pass model. Current kirimasim and fixed Icarus Verilog 13.0 pass all 31 cases. See [design/evidence](interaction-verification.en.md#resolved-strength-formatting).
- **7×8, class arrays:** one model, zero all-selection-pass models; 6 fixed-array cases pass and 12 dynamic-array/queue cases encounter unsupported operations. Both fixed Verilator seeds pass all 18 cases. See [design/evidence](interaction-verification.en.md#class-array-storage-and-shared-elements).
- **7×35, DPI open arrays:** one model, zero all-selection-pass models. The runner marks all 30 unsupported for C loading; separate parsing accepts 24 and rejects 6 queue cases during type matching. Both fixed Verilator seeds pass 18 static-array cases; 12 dynamic-array/queue cases have known build failures. See [design/evidence](interaction-verification.en.md#dpi-open-array-shape-and-copyback).
- **14×16, clocking/assertion:** one model, zero all-selection-pass models in kirimasim because concurrent assertions are unsupported. Both fixed Verilator seeds pass all 18 cases. See [design/evidence](interaction-verification.en.md#clocking-inputs-and-assertion-clocks).
- **8×18, inherited constraints:** one model, zero all-selection-pass models in kirimasim because randomize is unsupported. Both fixed Verilator seeds pass all 13 cases. See [design/evidence](interaction-verification.en.md#constraint-inheritance-and-failure-retention).
- **10×35, DPI/NBA:** one registered model, zero all-selection-pass models. All 18 are unsupported C loading; fixed Verilator's 14 partial passes are not added. See [design/evidence](interaction-verification.en.md#dpi-copyback-and-nba-capture).
- **6×15, event rebinding:** one registered model, zero all-selection-pass models. Its 27 cases combine rebinding before calls, before registration and after registration with input/ref/direct controls. All parse and type-check, but event-value operations are unsupported. See [design/evidence](interaction-verification.en.md#イベント変数の再結合と登録済み待機の保持).
- **8×15, mailbox/class handles:** one model, zero all-selection-pass models. All 36 cases combine FIFO, peek/get, capacity, null and bidirectional alias writes. All are unsupported mailbox types in this build. Fixed Verilator partial success is not added to kirimasim success. See [design/evidence](interaction-verification.en.md#mailboxのclassハンドルと別名経由の更新).
- **25×26 and 6×26, interface header import:** one model and one all-selection-pass model for each. The former maps all 36 cases; the latter maps 24 X/Z cases. Observations cover header type/function/default binding, formal conversion before operations and target-only overrides. See [design/evidence](interaction-verification.en.md#interfaceヘッダのimportとpackage関数の型変換).
- **27×29 and 6×29, sequential UDP generation:** one model and one all-selection-pass model per pair. The former maps all 36 cases, the latter 24 X/Z storage cases. Initialization, shared/partial clocks, guard retention/later capture and conversion order are observed. See [design/evidence](interaction-verification.en.md#generateで生成した逐次udpの状態と入力変換).
- The class-method model retains its 18 improved passes; its other 18 ref-argument cases remain unsupported, so it does not count as all-selection-pass.
- **28×29, UDP arrays/strength:** one model and one all-selection-pass model. All 25 cases cover strength, other drivers, instance/packed ranges and shared versus distributed inputs. Independent and contended outputs and all four-state input pairs are observed; hierarchical indexing of individual primitive instances is excluded. See [design/evidence](interaction-verification.en.md#udpの配列接続と駆動強度の解決).
- **23×33 and 27×33, config/generate:** one model and zero all-selection-pass models per pair. All 41 cases map to both pairs: 37 pass, while four retain defparam values after a global reset. Scope covers generated width/count/if/case structure under ordinary module-hierarchy configuration, not direct configuration inside generate. See [design/differences](interaction-verification.en.md#configのパラメータ設定とgenerateの形状).
- **4/6/10×24, program regions:** one model and one all-selection-pass model per pair. Chapter 4×24 maps all 36 cases, 6×24 maps 24 X/Z cases, and 10×24 maps six program-NBA output cases. Observations distinguish early module values, completed NBA chains, reservations, capture context and old values immediately after reservation.
- **25×27 and 6×25, generated interfaces:** one model and one all-selection-pass model each; all 36 cases and 24 X/Z storage cases respectively. Checks cover per-element widths, if/case structure, whole/modport connections, target/guard data/tags and storage conversion.
- **6×22 and 22×23, default_nettype:** one model and one all-selection-pass model each. All 40 cases cover default net types, explicit wires, port forms, widths, multi-driver resolution and another module after restoring settings.
- **9×24 and 15×24, program termination:** one model and one all-selection-pass model each. The former maps all 18 cases; the latter six named-event-wait cases. Checks cover natural termination, direct/task `$exit`, initial-process count, child/grandchild cancellation, another program's wakeup and implicit overall termination.
- **6×21, memory files:** one model and one all-selection-pass model, with eight enum cases. **7×21** has two models and two all-selection-pass models including file monitoring. The memory model's 36 cases cover conversion, element values, explicit bounds/direction and untouched out-of-range elements.
- **23×26, package import:** one model and one all-selection-pass model; all 39 cases. Inputs, outputs and samples distinguish visibility, local declarations, defaults and import leakage into another parent scope.
- **10×28 and 6×28, continuous-assignment delay:** one model and one all-selection-pass model each. The former maps all 63 cases; the latter 28 bit-storage X/Z cases. Values, transition times and counts check scalar/vector delay selection, conversion and pending-update cancellation.
- **4×15, 13×15, 15×25 and 15×26, event arguments:** one model and one all-selection-pass model each. The 4/13×15 mappings use all 13 cases, interface uses five and package uses four; all 13 in the model pass. Chapter 10×15 also maps one model. Wakeup region/value, argument-mediated synchronization identity and independent events/instances are observed.
- **13×23 and 23×25, default arguments:** one model and one all-selection-pass model each, mapping all 36 cases and 15 interface cases respectively. Checks identify default-expression declaration context and called instance. **13×25** has two models and two all-selection-pass models including implicit processes.
- **10×27, 23×27 and 26×27, generate:** one model and one all-selection-pass model each. All 36 cases observe type/constant selection, hierarchy, genvar constants and per-element continuous assignments.
- **9×25 and 13×25, implicit processes:** one mapped model with full-selection success, using seven interface cases and four interface-function cases respectively; the complete model's 36 cases pass. **9×13** also maps nine function cases checking sensitivity through function bodies.
- **10×12 and 10×25, loop assignments:** one model and one all-selection-pass model each. Chapter 10×25 maps seven interface assignments; all 36 model cases pass.
- **12×13 and 13×26, function return:** one model and one all-selection-pass model each. Chapter 13×26 maps 12 package-function cases; all 36 model cases pass.
- **6×8 and 8×13, class methods:** one model each; 18 pass and 18 ref-argument cases are unsupported, so all-selection-pass is zero.
- Assertions map **4/6/10/11/25×16**, with zero all-selection-pass models for these five pairs because unsupported cases remain.
- **7×9, container waits:** one model and one all-selection-pass model.
- The four clocking-input pairs **4/6/10/25×14** also retain unsupported cases. Reporting them does not claim a simulator rerun after the saved record.

Deferred report arguments map **13×16** with one model and one all-selection-pass model.
All 29 cases compare registration-time input capture, action-time static-reference reads, formal width/signedness conversion and input-evaluation side effects.
See [design and evidence](interaction-verification.en.md#deferred-argument-capture) for selection targets and exclusions.

Enum/generate maps **6×27** with one model and one all-selection-pass model. All 36 cases compare per-generated-element widths, tables, signedness, declaration-order navigation, wraparound and held state. See [design and evidence](interaction-verification.en.md#generated-enum-navigation) for targets and exclusions.

The package-NBA model itself maps **10×26, 4×26 and 7×26** and passes its entire selection. The first two map all 36 cases; 7×26 maps 24 array cases. Observations cover shared-object references, Active/NBA ordering, captured indices and retained neighbors/other packages. See [design, evidence and limits](interaction-verification.en.md#package-nba-capture).

Package observers add **9×26 and 11×26**, each with one model and one all-selection-pass model. The former maps all 36 cases, the latter the 12 logic X/Z cases. Existing 4×26 and 7×26 now each have two models and two all-selection-pass models including package NBA; the new array mapping uses 24 cases. Observations distinguish sensitivity, notifications, wake history, live data and retained values. See [design, evidence and limits](interaction-verification.en.md#package-change-observers).

The tool chooses one latest admissible kirimasim run containing all current selections. It checks input/expectation and runner fingerprints and runner stability during execution. Unsupported/failing cases remain, and partial successes from separate runs are never merged. If a newer run covers only some models, an older complete admissible snapshot is used. Every detail row identifies JSON path, version and execution timestamp.

The pass matrix requires **every selected case in the entire model to pass in the same run**, not just cases matching one pair's filter. The detail field for this condition is `1` when true and `0` otherwise. This differs from target-combination fulfillment in the [interaction report](interaction-coverage.en.md), Check success, Nightly results and requirement coverage.

<a id="更新と検査"></a>

## Updating and checking

Generate tests, execute affected cases and save evidence first. Add a registry entry for a new model, reviewing primary chapter, pair rationale and factor filters. A model-set mismatch or absent current-input full-selection run makes CSV generation fail.

```sh
python3 tools/interaction_coverage.py --update
python3 tools/chapter_cross_matrix.py --update
python3 tools/chapter_cross_matrix.py --check
python3 -m unittest discover -s tools -p test_chapter_cross_matrix.py
```

`--check` validates registry, inputs, saved execution and all three CSVs, and runs in Check. It neither builds nor starts a simulator. When selecting a new saved run, update this guide's counts/version too. See the [practical method](interaction-verification-method.en.md) for extension decisions and application elsewhere.
