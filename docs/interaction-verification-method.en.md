<a id="機能間クロス検証の考え方と実践手順"></a>

# Feature interaction verification: rationale and practice

[English](interaction-verification-method.en.md) / [日本語](interaction-verification-method.md)

This guide records the decisions, design method, implementation steps and measurement procedures used to introduce feature interaction verification in this repository. It is intended for maintainers adding new items and for engineers applying the method to other software or LSI logic verification.

See [Verification guide](interaction-verification.en.md) for implemented models and execution results, [Interaction verification report](interaction-coverage.en.md) for current factors, denominators and per-run fulfillment, and [From requirements to tests](requirements-to-tests-method.en.md) for mappings between standard requirements and tests. This guide explains the method; consult the reports for current counts. For a concise account of build revisions and remaining work, see [Saved-run summary](interaction-verification.en.md#保存実行の概要); for differences in fixed reference releases, see [Simulator differences](simulator-differences.md). For boundary-condition regressions added outside the finite models, [Issue #21 regression integration report](p1-combination-regressions-20261030.en.md) and [Mapping registry](../coverage/combination-gaps.json) track reuse of existing tests, standard rationale and unresolved items.

<a id="1-設計思想"></a>

## 1. Design rationale

<a id="単独機能の合格だけでは分からない境界を検証する"></a>

### Verify boundaries that passing individual features cannot establish

Features that work correctly in isolation can still fail at boundaries where values, state, types or timing pass between them. For example, passing signed-arithmetic and width-conversion tests separately does not establish that an operation correctly widens to the destination width before division. For NBA, the final value alone does not establish when the value and assignment target were captured.

We therefore identify the interacting mechanisms and the observations that distinguish correct from incorrect behavior before listing feature names. Each model row is tied to stimulus, observation points and expected values derived from the standard. The presence of two constructs in one test does not establish verification of their interaction.

<a id="小さな意味単位へ分けてから組合せを選ぶ"></a>

### Divide behavior into small semantic units before selecting combinations

Do not build the Cartesian product of every feature. Instead, divide behavior into units whose results can be explained, such as expression context, NBA value/target capture and array resizing. Within each unit, use constrained 2-factor coverage as the baseline and cover groups directly related to failure mechanisms at strength 3 or higher. Retain boundary values and known-bug reproductions as mandatory cases even when other cases could cover the same combinations.

This design checks selected low-order interactions with a small set of cases. 2-factor coverage does not guarantee detection of arbitrary higher-order faults. It also provides no guarantee for values, states or orderings absent from the model.

<a id="期待値と分母を実装の都合に合わせない"></a>

### Keep expected values and denominators independent of implementation convenience

Derive expected values from IEEE 1800-2023 using a Python model independent of the implementation under verification. Do not copy simulator output into expected values. Use comparison with other simulators to help check the expected values. When results disagree, recheck the specification interpretation and the test, and retain unsupported cases and mismatches. Do not exclude targets to raise the pass rate.

Preserve existing tests. Adding a selection for short runs is separate from reducing the ordinary regression suite. Do not add achieved interaction counts directly to whole-standard requirement coverage.

<a id="2-何をモデル化するか"></a>

## 2. What to model

<a id="追加候補の優先順位"></a>

### Prioritize additional candidates

Inspect existing tests and the specification, then choose additions using the following criteria.

- Multiple features read or write the same value or state.
- Behavior crosses boundaries involving type conversion, width conversion, buffers, hierarchy or arguments.
- Priority, delay, concurrency or the distinction between before and after an update affects the result.
- Widths such as 1, 32, 33, 64, 65 and 129 bits cross implementation boundaries.
- Handling differs from ordinary values for X/Z, empty/full states, zero or negative values.
- A known bug exists, or an existing model explicitly excludes the behavior from its scope.

Consider reusing an existing test first when it already provides the required stimulus and observations. The initial `scheduling_visibility` model preserved all 325 existing tests and selected 51 of them. For items needing new stimulus, add a generator and independent expected values.

Not every candidate needs a factor model. Issue #21 added 56 boundary-condition cases for events, NBA, aggregates and I/O, plus 18 cases selected from a finite file-monitoring model. The former are mapped in the registry as regressions for specific boundary conditions. The latter defines 36 combinations of registration location × queue/dynamic array × MCD/FD and selects 18 cases preserving all 40 factor-pair targets and 3 mandatory cases. Do not count regressions without defined factors and target combinations as t-way achievements.

<a id="因子と水準は結果に影響する違いから決める"></a>

### Choose factors and levels from differences that affect results

Factors include width, signedness, destination state type, operation, input value and time. Levels are representative values of a factor. For a relative level such as widening, define which width is the reference. For example, the expected value changes depending on whether `state=bit` specifies the input type or only the final destination type.

Before adding levels, provide stimulus that makes their differences observable. For arrays of 1-bit elements, a single 0/1 pattern cannot distinguish every position, so two observations with rotated inputs were used. Division cases containing X/Z also receive known inputs, avoiding credit for width/sign interactions based only on uniformly X results. A model row need not be limited to one input vector.

For expressions with side effects, observe evaluation counts as well as values. In the 40 compound-shift cases, index functions for array elements and part-selects change their next return value, allowing call count, write destination and unselected regions to be checked together. Fault injection also confirmed detection when an expression required to be evaluated 1 time was evaluated 2 times. The 2 evaluations observed in Verilator were saved as a difference rather than adopted as the expected behavior.

Do not replace 4-state expectations with a 2-state mathematical set-membership calculation. For `inside`, determine X at each comparison before combining results with OR. For example, even if concretizing X to either 0/1 value would produce a set member, the result remains X when both comparisons are X. The independent calculation follows the standard's operation granularity and order, using mandatory mixed match/unknown cases, individual enumeration of identical elements and a fault that reads only the first element.

When the standard permits different readings, choose stimulus producing the same result under both and exclude other combinations with an explicit constraint rationale. For an `inside` range with an X/Z endpoint, possible readings combine two relations with `&&` or make the range result X whenever a comparison is X. For closed intervals, use inputs satisfying the other endpoint so both readings produce X. Because the text does not define empty ranges containing X/Z, reversed ranges use only known values. Check the interaction with interpretation-independent observations rather than choosing expected values to favor one reading.

Avoid making the observation mechanism itself a prerequisite for every case. In case inside, placing a side-effecting function item in every case made all cases unsupported in an implementation lacking such items, preventing any check of width/sign/X/Z interactions. The third item was therefore factored into variable versus function-call forms: evaluation counts are checked in function-call rows, while both forms check selection rules.

For event OR and `iff`, condition changes and trigger-source changes occur at separate times, with independent left/right raw event counts alongside conditional OR wakeups. This distinguishes incorrect wakeups caused only by condition changes from loss of a term or condition binding in OR. Phase-by-phase counting formulas independently checked all 252 rows, and execution covered positive controls for 4 selected rows plus 7 fault types deliberately corrupting SV conditions, triggers or updates. Observe wakeup counts and periods without wakeups as well as matching values. See [Event OR verification record](interaction-verification.en.md#イベントorと項ごとのiff条件) and [Auxiliary evidence](../coverage/interaction-qualification/README.en.md#イベントorとiffの確認) for extension procedures and rerun commands.

When verifying references, model element identity in addition to value and position. Queue methods and whole-queue assignment can produce identical values while leaving retained references with different validity. The reference model moves/replaces element objects, while the independent calculation uses a positional correspondence table. Rotating initial values 3 times distinguishes 3 elements even at 1 bit. Reading both retained references after deletion and every current queue element, with separate observations after writes and after return, also applies to reuse of containers, buffers and identifiers. See [Queue-reference verification record](interaction-verification.en.md#キュー要素への参照と要素の寿命) for concrete stimulus and constraints.

Treat changes to the index selecting an actual argument separately from changes or deletion of the selected element itself. The argument-binding model passes a valid element before changing only the index to the next element or -1. Subsequent observations read the already-bound object instead of indexing the array again, detecting incorrect reselection without turning valid stimulus into an invalid access. Observe 3 stages—caller to task, task to caller and later caller update to task—to distinguish copies from live references and immediate writes from erroneous return-time writeback. See [Argument-binding verification record](interaction-verification.en.md#引数の結合と呼出し後の添字変更) for details.

For inverse operations such as writing/reading or encoding/decoding, prepare specification-derived known inputs and expected outputs independently for both directions. A round trip returning the original value is insufficient because corresponding faults in both directions can cancel. The memory-file model reads both files written by DUT and literal input files not formatted from values produced by the verification target. When both writing and reading were reversed, independent input detected the fault despite matching round-trip values. The same approach applies to LSI encoders/decoders, serializers/deserializers and transmit/receive comparisons. See [Memory-file verification record](interaction-verification.en.md#型と範囲を組み合わせたメモリファイル入出力) for an example.

For cancellation or shutdown, observing no writes after shutdown is insufficient. The same result occurs if the affected process never started or the release stimulus never arrived. The program-termination model separately observes initial progress, the time-5 checkpoint before termination and suppression of later writes. A separate program waiting on the same delay, event or condition must wake after release, providing an independent control. With natural termination of multiple initial processes, children survive until the last initial process finishes; $exit instead cancels other initial processes and children. For LSI reset or queue flushing, likewise distinguish progress before shutdown, suppression afterward and continuation of an independent path. See [Program-termination verification record](interaction-verification.en.md#program終了と子孫プロセスの取消し) for an example.

When using repeating patterns, check value-combination coverage separately from positional identification. The net-type model retained 16-bit periodic equivalence even after every bit passed through the resolution table. Additional stimulus encoded positions 1 through 129 in 8 observations within the same 40 cases, and that stimulus alone detected reuse of the low word in higher words. The combination of operation coverage and identifying data also applies to channels, lanes and buffer elements.

For connection verification, observe values and identifying information on both selected and unselected sides. The generated-interface model adds 2 role-identifying observations to 11 observations encoding element and bit position. Selected/control histories then remain distinct after inversion, identifying 780 bit positions across 3 elements of widths 129/130/131. Tags for each element and branch identify reader bindings even when unknown data values are difficult to distinguish. This also applies to LSI lane/bank selection and connections among multiple interfaces. See [Generate/interface verification record](interaction-verification.en.md#generateで生成したinterfaceとmodport接続) for an example.

Observe scheduling and completion separately. In the program event-region model, fixed-release output showed that the final stage still held its old value even as the module's NBA scheduling count increased. Check every stage's value, scheduling counts, capture context and later output notifications together, with an early module-side control. Separating values immediately after a nonblocking assignment from values after its update also helps verify LSI pipeline/queue acceptance, completion and update notifications. See [Program event-region verification record](interaction-verification.en.md#programのイベント領域と非ブロッキング代入) for an example.

Features involving conversions need stimulus that distinguishes processing orders yielding identical results for known values. The interface model distinguishes 1, obtained by converting an unknown value to the package function’s bit formal type before inversion, from 0, obtained by inverting the unknown first and then converting back to bit. The latter fault survived 55 output lines from 11 known-input stimulus steps and was detected only at the first unknown input. Separate observations before conversion, after storage, after arithmetic and at final output also prevent later processing from cancelling an earlier fault. For name binding, compare declaration-side defaults and caller-side actuals using deliberately different same-named declarations. For re-exported names, check actual import of the declaration rather than mere candidacy. For LSI data formatting, sign/width conversion and configuration binding, combine intermediate observations with values that expose processing order. See [Interface imports and type conversion](interaction-verification.en.md#interfaceヘッダのimportとpackage関数の型変換) for an example.

To verify state retention, observe retention despite input changes, not merely an interval without output changes. The sequential UDP model clocks only a subset, checks unselected state and keeps an other-clock guard at its initial state while data changes. Finally drive the guard to sample position-identifying values while checking retention on the target side. Sample all 1 immediately before unknown inputs so converted 0 and X from UDP necessarily differ from the prior state. For LSI banks/channels or clock/enable-controlled state, the same timeline can check unselected retention, later operation and independence from the selected side. See [Generated sequential UDP verification record](interaction-verification.en.md#generateで生成した逐次udpの状態と入力変換) for an example.

For strength and priority, observe isolated outputs as well as outputs under contention. The UDP model instantiates 2 arrays with identical inputs and adds a competing driver to only one. Transitions among 0, 1 and Z distinguish configured strengths and release behavior through logic values, without depending on strength-display formatting. Known connection-checking stimulus identifies each bit, while truth-table checks supply every 4-state input pair. Combining these in each row's timeline also makes the excluded unknown-output/competing-driver interaction explicit as a candidate for a separate model. Record unobserved equivalences too, such as simultaneous permutation of named-array elements that leaves external behavior unchanged. For LSI bus driving and priority selection, compare isolated, contending and released operation and state the granularity actually observed. See [UDP and strength verification record](interaction-verification.en.md#udpの配列接続と駆動強度の解決) for an example.

When crossing configuration priority with reset, observe unspecified parameters, unaffected siblings and derived generated shapes as well as explicitly specified parameters. The config model separates reset of W alone from reset of all parameters and crosses these with 4 forms of prior specification. Each leaf displays its actual generated array, so an incorrect element count is detected through output differences rather than missing hierarchical names. This focused cross exposed 4 differences involving whole-parameter reset together with defparam. Keep the expected values and compare an empty whole reset with explicit reset of each parameter in a minimal example. The same reasoning applies to LSI parameter configurations, lane/bank counts, configuration priority and reset scope. See [Config/generate verification record](interaction-verification.en.md#configのパラメータ設定とgenerateの形状) for an example.

To verify configuration scope, compare affected objects, explicit exceptions and objects defined after restoring the setting under identical stimulus. The default_nettype model places modules defined under the directive alongside ports with explicit wire only on vectors and modules defined after restoring the default. Instantiate after restoring the setting and check that later settings do not override types of ports defined earlier. This comparison also helps check LSI parameters and compile-time settings against each instance's configuration. See [Net-type and port-declaration verification record](interaction-verification.en.md#default_nettypeとポートnetの解決) for an example.

<a id="組合せの制約とツールの未対応を区別する"></a>

### Distinguish combination constraints from unsupported tool features

Use constraints to exclude combinations invalid under the specification and duplicate representative values with the same meaning. Examples include narrowing width 1 by 1 bit to width 0, or initial size 3 with capacity 2. For an empty array with no input element value, fix the value factor to one level. Record each exclusion rationale in the generator and report.

Do not exclude combinations because the current implementation lacks support, expected values disagree or generation is difficult. Design rejection tests for specification violations separately from legal-combination models.

Construct target denominators from partial combinations that can be extended with the remaining factors to a complete legal row. Mechanically multiplying per-factor levels for the pair denominator would incorrectly count unreachable combinations as deficits.

<a id="3-少ないケースを選ぶ仕組み"></a>

## 3. How to select a small case set

`Model` in [interaction_cover.py](../generators/interaction_cover.py) selects cases in the following order.

1. Enumerate the Cartesian product of all factor levels and retain rows satisfying the `legal` constraint.
2. Project all factor pairs and specified higher-strength groups from legal rows to construct the target combination universe.
3. Select the mandatory cases specified by `anchors` first.
4. Repeatedly add the row covering the largest number of unmet combinations.
5. Remove redundant rows when the other selected rows still cover every target. Keep mandatory cases even when they are redundant for combination coverage.

Fixing the order of factors and levels makes the selection reproducible. The algorithm uses greedy selection and redundancy removal; it does not guarantee the minimum possible case count. The current implementation defaults to an enumeration limit of 10,000 rows in the full Cartesian product before applying constraints. Split semantic units or configurations when this limit is exceeded. This limit belongs to the selector implementation, not to the specification of the verification target.

Use `groups` for factors that act together through shared state, conversion order or priority. Examples include width × state type × X/Z and capacity × initial size × operation. Choose these groups from risk and specification rationale instead of applying higher-strength coverage indiscriminately to every factor. For interactions not adequately represented at strength 3, add higher-strength groups or explicit mandatory scenarios.

The following minimal example exercises only the selector. It does not generate an executable testbench.

```python
import sys
sys.path.insert(0, "generators")
from interaction_cover import Model

model = Model(
    "example_word_update",
    (("width", ("1", "32", "33", "64", "65", "129")),
     ("state", ("bit", "logic")),
     ("update", ("blocking", "nba")),
     ("value", ("known", "x", "z"))),
    legal=lambda row: True,
    groups=(("width", "state", "value"),),
    anchors=(("129", "logic", "nba", "z"),),
)
selected = model.select()
assert set(model.anchors) <= set(selected)
assert {t for row in selected for t in model.targets(row)} == set(model.universe())
print(len(model.rows()), len(selected))
```

<a id="4-一行を正誤が分かるテストへ変換する"></a>

## 4. Turn a row into a test that distinguishes correct behavior

Separate inputs, intermediate values and final values so a failure can be localized to a processing stage. As needed, also observe adjacent elements, unselected bits and independence after source updates. When event regions or delays matter, explain observation timing and absence or presence of races from the specification. Do not assign a unique expected result to a race whose execution order the standard leaves unspecified.

Calculate expected values using a representation different from the verification target. Examples include bit-weight-based part selection, arbitrary-precision integer arithmetic and array-list copies. For quotient and remainder, explicitly account for differences in negative-number rounding between Python and SystemVerilog. Specification-derived reference models can also be wrong, so use an independent reviewer and a different calculation method. The independent review in this work used AI and does not constitute human approval.

Reference-model unit tests should use concrete cases distinguishing rounding, sign extension, type-specific defaults and conversion order instead of merely retracing the implementation. When comparison with an implementation disagrees, investigate the stimulus, observations and expected values to locate the cause.

<a id="5-本リポジトリにモデルを追加する手順"></a>

## 5. Add a model to this repository

<a id="51-設計と実装"></a>

### 5.1 Design and implementation

1. Review specification sources, existing tests and exclusions of existing models.
2. Document the target interaction, factors/levels, combination constraints, higher-strength groups and mandatory cases.
3. Design stimulus, observations and expected values, reviewing indistinguishable combinations and undefined races.
4. Implement `NAME`, `VERSION`, `CHAPTER`, `MODEL`, `case_name(row)` and `cases()` in `generators/<generator>.py`. Use an existing generator as a template.
5. Return a list of `common.Case` objects from `cases()`, giving each case its sources, independent expected values, `interaction_model` and `interaction_values`. Use `fourstate=True` when observations can contain X from defaults or other behavior even if the stimulus is known. Do not edit generated files directly.
6. Register the generator in [generate.py](../generators/generate.py) and in `GENERATORS` and `registered()` of [interaction_models.py](../generators/interaction_models.py). Provide paths, available rows and observation descriptions to `SuiteModel`.
7. Add semantic-boundary checks to [Regression tests](../tools/test_interaction_coverage.py). Common checks also verify projection of all targets, preservation of mandatory cases and deterministic selection.
8. Run `python3 generators/generate.py` to generate the new SV and expected output before checking execution.
9. Register the primary chapter, chapter pairs and factor conditions in [Chapter-pair mapping registry](../coverage/chapter-interactions.json). If [0-cell triage](chapter-cross-triage.en.md) has a corresponding E/C entry, review and remove it, then update both the model and triage tables. Do not add interactions solely from joint chapter citations.

Available model rows must correspond to actual tests. Reused tests may preserve all rows, while a new generator may generate only selected rows. When meaning or expected values change, review generator `VERSION` and model `version`, recording the reason and rerun scope.

<a id="52-期待値の確認と実行証跡"></a>

### 5.2 Check expected values and record execution evidence

Fixed releases Icarus 13.0 and Verilator 5.052 check reproducibility of expected values for oracle registration. Check Verilator with two seeds for cases independent of X/Z. For kirimasim development verification, fetch/check the latest upstream commit immediately before execution, use a binary built from that commit and record its revision. Fixed oracle releases and builds used to verify the latest implementation serve different purposes.

`generators/record_oracles.py` updates oracle registrations for every generator. In particular, passing partial-run JSON to `--verilator` may reset existing oracles absent from that result to `spec`. Use results covering every target, or review/merge only new entries and verify preservation of existing registrations. After registration changes, regenerate oracle metadata with `python3 generators/generate.py` and collect result JSON again because input hashes changed. Do not reuse old results by rewriting their hashes to current values.

The following example runs specified models and checks pass evidence for the same inputs. Run from the repository root after replacing the simulator path.

```python
import subprocess
import sys

models = ["division_context", "dynamic_array_resize"]
select = [sys.executable, "tools/interaction_coverage.py"]
for model in models:
    select += ["--model", model]
tests = subprocess.check_output([*select, "--list-tests"], text=True).splitlines()
receipt = "my-results/cross.json"
run = subprocess.run([
    sys.executable, "tools/run_kirimasim.py",
    "--kirimasim", "/path/to/latest-build/kirimasim", "-j", "8",
    "--json", receipt, *tests,
])
gate = subprocess.run([*select, "--results", receipt, "--require-pass"])
if run.returncode or gate.returncode:
    raise SystemExit(1)
```

To inspect multiple results, list their JSON paths after one `--results`. Evaluate each result independently; do not combine partial passes across versions or runs.

<a id="53-文書集計回帰を更新する"></a>

### 5.3 Update documentation, reports and regression checks

Document observations, constraints, exclusions, selection counts, specification interpretations and mismatch handling in the verification guide, then update current status in both READMEs, the generator catalog and the document index. Run the following commands.

```sh
python3 generators/generate.py
python3 tools/suite_stats.py --update
python3 tools/suite_catalog.py --update
python3 tools/coverage_depth.py --update --minimum-tests 2
python3 tools/requirement_matching.py --update
python3 tools/behavior_coverage.py --update --require-source-reviewed
python3 tools/interaction_coverage.py --update
python3 tools/chapter_cross_matrix.py --update
python3 tools/chapter_cross_triage.py --update
python3 tools/combination_gaps.py --update
python3 tools/generator_catalog.py --update
python3 tools/documentation_languages.py --update
python3 -m unittest discover -s tools -p 'test_*.py'
python3 tools/lint_metadata.py
```

After updating both versions of handwritten pages, run `python3 tools/documentation_languages.py --record` and `--check`. When adding generator prose, update the language dictionaries using the [translation maintenance guide](../tools/doc_locales/README.md).

Place saved execution JSON in `coverage/interaction-results/` before updating interaction reports. After updating, also run the corresponding `--check` and inspect Check in CI. Update both README versions, the verification guide, fixed-release differences and auxiliary-evidence descriptions. Append a record with the target commit and revision instead of overwriting historical measurements with new values. In the FAQ and glossary, link to reports or saved-run summaries rather than duplicating changing counts. `interaction_coverage.py --check` checks freshness of plans, generated artifacts and reports. The gate requiring passing execution coverage across models is `--require-pass`. Record concrete mismatches and unsupported behavior without weakening expected values, and check that existing tests, oracles and historical evidence were not unintentionally changed.

<a id="54-有限モデルにしない境界条件を追加する"></a>

### 5.4 Add boundary cases outside finite models

Compare with existing tests to identify missing stimulus and observations, then add expected values derived from the standard. Retain the generator, sources, independent expected values, versions and execution evidence, but do not attach `MODEL` and `interaction_model` labels merely to count these tests toward interaction coverage. For Issue #21, use `combination_gap` to assign candidate ID values and record primary/control roles, existing/new status, observations, clauses and input fingerprints in [Mapping registry](../coverage/combination-gaps.json).

```sh
python3 tools/combination_gaps.py --list-tests
# Run listed tests with the latest-commit build; save JSON in coverage/combination-results/.
python3 tools/combination_gaps.py --update
python3 tools/combination_gaps.py --check
```

`--list-tests` lists every test path bound in the registry. `--check` checks test existence, fingerprints and report freshness; it does not require every implementation result to pass. When changing registry input fingerprints, review the stimulus, observations, expected values and standard rationale again. Keep unresolved standard interpretations on hold, and record items observable only through a native API as a separate test scope. Do not turn unsupported behavior into an expected pass or relabel unverified behavior as illegal or defective.

<a id="6-何を達成したと数えるか"></a>

## 6. What counts as achieved

Distinguish planned coverage, runtime reachability and passes with correct results. This repository reports planned selections and combinations backed by matching expected results; it does not measure raw coverage reached partway through a failed execution.

Use only `pass` records whose input and runner hashes match the current versions as pass evidence. Do not count `known`, `unsupported`, `stale` or unexecuted cases as passes. A runner may accept a known difference and return exit code 0 without establishing interaction coverage. `--require-pass` requires every target combination and mandatory case of each specified model to have pass evidence within one snapshot. Alternative rows can satisfy a target, so this is distinct from requiring every available case to pass. Also inspect the regression result for each case.

Hashes detect mismatches between inputs and execution tools. They do not prove that a binary was built from the latest upstream commit or that the entire runtime environment matches. Check the upstream commit, build the simulator and record its version, configuration and seed separately.

A reduction in selected case count is not a measured reduction in runtime. Measure generation, compilation and simulation time to assess the benefit for short regressions. 100% coverage of registered models does not establish verification of every language feature, specification rule, state or temporal sequence.

<a id="7-他プロジェクトへ適用する方法"></a>

## 7. Apply the method to other projects

Transfer the following workflow rather than the SystemVerilog-specific list of widths. Manage the interaction hypothesis, finite factor model, legality review, focused crosses, stimulus, actual observations, independent checks and evidence as one connected process. For each model, retain the following information.

- The target specification and interaction faults the model should detect.
- The rationale for factors, levels and representative values, together with combination constraints and their basis.
- All factor pairs, focused higher-strength groups and mandatory scenarios to preserve.
- Case ID, stimulus generation, observation points and expected values or a checker.
- Versions of the specification, implementation, tests and checker, plus execution configuration, results and reasons for unmet targets.
- The next extension candidates and the evidence invalidated by a change.

Start from features sharing state: for a API, examples include authentication state × operation × retry × disconnection; for storage, writes × capacity boundaries × failure recovery. These are candidate-factor examples, not models executed or verified in this repository.

<a id="lsiのロジック検証へ適用する場合"></a>

### Apply the method to LSI logic verification

For a FIFO, candidate factors include occupancy (empty, 1, nearly full, full), reads, writes and backpressure. Distinguish issued requests from actual acceptance and focus on pre-operation occupancy × accepted read × accepted write. Derive full/empty behavior and acceptance of simultaneous read/write requests at full occupancy from the design specification. Deduplicate representative values at depth 1 and do not exclude behavior merely because the RTL implementation lacks support.

Choose groups acting on shared state and priority, such as outstanding requests × backpressure × reset for DMA, or event × W1C × mask for interrupts. When before/with/after A is insufficient, retain mandatory sequences immediately before acceptance, after acceptance but before completion, immediately after completion and at the first operation after interruption. Check reachability together with the initial state and operation sequence.

In UVM or a similar environment, launch sequences from selected rows and have monitors record actual acceptance, prior state, transaction ID, clock domain and acceptance cycle. With multiple clocks, define acceptance/completion domains, synchronization delay and causality; equal simulation timestamps alone do not establish simultaneity. Correlate information belonging to the same interaction and use a scoreboard or SVA to check values, ordering, loss, duplication and recovery after reset. Partition functional coverage into small crosses, bins for focused crosses and temporal targets; merely setting configuration values or observing factors in unrelated transactions does not fulfill a target. Separate reachability from passing and check that the checker is enabled and that required responses, comparisons and SVA evaluations have completed. Do not use vacuous SVA success or a scoreboard still awaiting comparison as pass evidence. Retain unmet targets separately for each configuration, channel and instance.

The method is developed further in another repository through [Practical procedure for LSI](https://github.com/kurochan001/lsi-verification-method/blob/main/docs/method/feature-interaction-verification.md), [Verification-plan template](https://github.com/kurochan001/lsi-verification-method/blob/main/docs/templates/interaction-coverage-plan.md) and [Executable APB and interrupt teaching example](https://github.com/kurochan001/lsi-verification-method/blob/main/examples/local-apb-irq-coverage/README.md). Teaching-example results do not establish adoption in a production design or a generally applicable reduction rate. Interaction verification does not replace complete sign-off; combine it with the appropriate methods for CDC/RDC, timing, power and other concerns.

<a id="8-追加を完了とする基準と次の拡張"></a>

## 8. Completion criteria and further extensions

Model introduction is complete when independent stimulus/observation review, selection preserving all targets and mandatory cases, independent expected values, execution evidence, unmet-target reasons, rerun procedures and documentation links are available. Report completed introduction separately from passing every target on the implementation under verification.

When a deficit is found, first classify its cause. Run unexecuted cases, record implementation work for unsupported behavior, review operations/environment for unreached stimulus, review stimulus/observations/expectations for poor discrimination, and revisit the specification/model for an inappropriate denominator. Do not begin simply by increasing random seeds or interaction strength.

[Verification guide](interaction-verification.en.md) records additions using this procedure for split assignments to concatenated destinations and X/Z in logical/reduction operations. The latter observes 7 operations in each row, checking every expected value while keeping case count small. The same procedure added binary logical short-circuit side effects and edge detection in event expressions. Short-circuit rows observe 4 operations; event-control rows observe 3 event kinds under 0/1 backgrounds. Bundling background values into phases of each row checks both backgrounds against the row while limiting the Cartesian product and selector cost. Issue #21 also adds specific boundary cases such as `iff` with side effects. Factor models for event OR and iff are already implemented as documented in [Verification record](interaction-verification.en.md#イベントorと項ごとのiff条件). Further candidates include multiple updates within one time step, glitch-containing timelines, unknown clocks in sequential UDP and simultaneous input changes. These are outside the current finite models and should be added after reviewing existing tests and intended levels. Use new bugs and specification changes to assess need, then add observations and evidence through the same process.

<a id="classハンドルとmailbox値が同じでも同一オブジェクトとは限らない"></a>

### Class handles and mailboxes: equal values do not establish object identity

[Mailbox/class-handle model](interaction-verification.en.md#mailboxのclassハンドルと別名経由の更新) separately observes received values, identity with the original handle, sender-side updates and receiver-side updates. An incorrect implementation copying values into a different object can match immediately after retrieval but is distinguished when later updates are not shared. Cross FIFO ordering, counts after peek/get, capacity limits and null messages to distinguish successful receipt of null from failure on an empty mailbox. Compare return values as positive versus 0 according to the standard; do not additionally require a positive result to equal 1. Do not invent an expected output-argument value for an empty retrieval when the text does not specify one.

With up to 129 bits in each of 4 input streams, 516 positions require identification. Base-2 position codes need 10 observations because 9 are insufficient; adding all-0 and all-1 distinguishes 1,032 histories including inversion. When increasing signal count or width, check again that repeating an existing pattern does not give different positions identical histories. This model selects 36 cases from 3,456 combinations, and its 36 width × state-type × input targets also explain a selection-count lower bound.

The independent model holds objects, references and a bounded queue; it does not call the generator's closed-form ordering calculation. Keep unsupported runtime features in the legal denominator. Do not generalize successful fault injection for some types or known values to other types or X/Z; auxiliary evidence records the reference revision, factor levels and normally completed scope. This demonstrates the distinction between reporting model introduction and reporting execution fulfillment on a target simulator.

<a id="イベントの再結合コピー登録通知の時点を分ける"></a>

### Event rebinding: separate copy, registration and notification timing

[Event-rebinding model](interaction-verification.en.md#イベント変数の再結合と登録済み待機の保持) separates passing a handle to a task, registration of a wait by `@` and notification of the synchronization object. Rebinding between the call and registration distinguishes input copying from ref/direct references. The same outputs check the separate rule that rebinding after registration does not change an already registered wait. Place processes on separate ticks so execution-order races are not mistaken for specification differences.

Cross late waiters, retained old handles, independent noise, relay-handle changes, multiple waiters and unused slots to distinguish identity errors, registration-time errors and shared/confused wait queues. The design procedure also applies to callback registration, subscription changes and connection switching. Expected values use closed-form timing selection, while the independent model operates objects and registration queues in order.

The model selects 27 cases from 648 legal combinations and reaches the lower bound imposed by 27 targets in the required strength-3 group. Observational differences for 13 fault types in the reference model do not count as runtime fault detection or combination fulfillment when the target tool cannot execute the operations. Record syntax acceptance, independent expectation checks, behavioral execution and executable fault injection with their respective evidence and limits.
