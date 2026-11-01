<a id="章間クロス検証マトリクス"></a>

# Chapter interaction matrix

[日本語](chapter-cross-matrix.md)

The CSV matrices show which IEEE 1800-2023 chapters are crossed. Both axes cover chapters 1–41; UTF-8 BOM encoding allows opening them in Excel. The first two columns identify the row chapter and title; column headings identify the other chapter.

- [Registered model counts](../coverage/chapter-cross-models.en.csv): distinct models mapped to each chapter pair.
- [All-selected-cases-pass model counts](../coverage/chapter-cross-passed-models.en.csv): the same layout, counting only models whose entire selection passed in the saved run below.
- [Mapping and execution details](../coverage/chapter-cross-details.en.csv): pair, model ID, rationale, conditions, case counts, pass/fail/known/unsupported, representative test, expectation and result JSON.

See [zero-cell triage](chapter-cross-triage.en.md) for reasons and next candidates. A separate 41×41 CSV shows classification codes, with rationales, priorities, factor proposals and observations. Unreviewed cells remain awaiting review rather than being declared out of scope or low risk.

For example, chapter 7 (aggregate data types) × 13 (tasks and functions) has three models covering array-element argument passing, binding after index changes and queue-element references. Chapters 11 (operators/expressions) × 12 (procedural statements) have two models for ordinary case matching and case-inside selection; one of these two models passed its full selection.

<a id="数字の読み方"></a>

## Reading the counts

Off-diagonal cells count **models mapped to chapter interactions**. A model can map to several pairs. Diagonal cells count **models whose primary chapter is that chapter**, following the test's first `:lrm:` clause. Only the diagonal sums to the model total; it does not establish exhaustive crossing within a chapter.

The matrix is symmetric. Summing triangles or arbitrary cells gives neither test nor model totals. Zero means no mapped model in this aggregation, not absent tests, unsupported implementation or zero requirement coverage. Annexes are not axes.

The scope is [registered finite interaction models](interaction-verification.en.md), not all 10,123 tests. It excludes ordinary tests and the 56 [issue #21 boundary regressions](p1-combination-regressions-20261030.en.md) not registered as finite models. It measures neither chapter requirement coverage nor the full product of chapter features.

<a id="対応付けの根拠"></a>

## Mapping rationale

The [mapping registry](../coverage/chapter-interactions.json) records AI review of factors, stimulus and observations. Pairs are not inferred from every chapter cited in a test: display-only `$display` use or a process needed merely to execute a test must not inflate interaction counts. These are reviewed interactions, not an exhaustive list of possible mappings.

Where only some factor levels exercise a pair, `when` restricts the mapping. For example, chapter 7×13 in the task-argument model includes only array-element actuals. Matching-selection and status counts apply that filter; whole-model selection counts may differ. A representative test is one example. Every selected path is in each model's `selection` in the [plan JSON](../coverage/interaction-summary.json).

<a id="実行結果の扱い"></a>

## Execution policy

The current mapping contains 56 models and 2,373 selected cases across 87 unordered off-diagonal pairs. The [full kirimasim 1144b2ac run](../coverage/interaction-results/cross56-kirimasim-1144b2ac.json) records 2,170 pass, 197 unsupported and 6 fail; 46 models passed their entire selection.

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
