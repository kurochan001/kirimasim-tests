<a id="claude-codeへのハンドオフ2026-10-23"></a>

# Handoff to Claude Code (2026-10-23)

[English](claude-code-handoff-20261023.en.md) / [日本語](claude-code-handoff-20261023.md)

> Historical materials
> The text records the state of each work period. The current denominator, mappings, and execution evidence are in
> [Aggregated Summary](behavior-coverage-summary.en.md), the latest takeover and remaining cases.
> See [Handoff for updating 2026-10-29](handover-20261028.en.md).

<a id="最初に把握すること"></a>

## What to understand first

This document is a requirement matching of existing tests for IEEE 1800-2023 and a takeover of the requirement coverage management. This records the state when 20% was reached; subsequent work to reach 50% and additional comparisons are in [Handoff for work toward 50%](claude-code-handoff-20261023-50percent.en.md). The opening box and [ `coverage/behavior-summary.json` ](../coverage/behavior-summary.json) are authoritative for current values; read figures in the text as historical records of their respective dates.

The work reaching 10% and 20% has since been committed and pushed (this document was also added in `a30cddb`). You do not need to maintain the work tree.

- Workspace: The root of this repository
- Branch: `main`
- HEAD when the material was written: `f9436fadc025540e5aedf113d5bee96a2b9b23e5` (`Match compiler directive tests to IEEE requirements`)
- origin：`https://github.com/kurochan001/kirimasim-tests.git`
- The date and time is based on Asia/Tokyo. The following values are the values of the local work tree when the document was created.
- The user-specified instruction is `@RTK.md`, equivalent to `AGENTS.md`. The actual files are absent from the current workspace; checked `@RTK.md` in `~/.claude/CLAUDE.md` and `RTK.md` in the same directory. Normal command rewriting for RTK is configured to be handled by Claude Code's hook.

<a id="ユーザーの目的と完了範囲"></a>

## User's goal and scope of completion

The user initially requested review of every test, beyond uncommitted work, with findings recorded in Markdown. Subsequently requested extraction of all standard requirements, mapping to existing tests, addition of missing tests, and measurement/management of standard requirement coverage. The provisional value and the definitive value are jointly noted.

Material investigation and requirement extraction for all 1,740 clauses and 15,846 source blocks are complete in the ledger. However, semantic duplicates and pending interpretations remain, so the denominator is unapproved. 100% material review does not mean 100% behavioral-test coverage or completed content review of all tests. Codex ( AI ) is responsible for this, and it is not treated as approval by an independent person.

Work toward 20% compared existing test stimulus/expected values and registered mapping evidence and pending assessments. No new SystemVerilog/C tests, input changes, or reruns were made; saved execution evidence is checked instead.

<a id="20到達時点の計測値2026-10-23履歴"></a>

## Measurements when 20% was reached (2026-10-23, historical)

The authoritative source is [ `coverage/behavior-summary.json` ](../coverage/behavior-summary.json). The figures below are from when 20% was reached; see the opening box for current values.

- Fixed denominator: 12,319 requirement rows.
- Mapped: 2,465 requirements. The provisional requirement coverage (test design) is 20.009741050409936% (normally indicated as 20.01% ).
- Requirements with valid recorded passes: 1,292. Provisional execution verification coverage: 10.487864274697621% (normally displayed as 10.49%).
- Definitive values: both design and execution `null` / undetermined. `denominator_reviewed` is `false`.
- All tests: 3,938 tests. 1,386 tests have at least one mapping; 2,552 are unregistered.
- AND set-level evidence: 126 requirements.
- Pending-assessment ledger: 406 tests, 546 assessments.
- Pending interpretations: 49 requirement rows, 46 issues, 42 clauses. This is not excluded from the denominator.
- The measurement rule is `metric_policy_version = 3`.

Work toward 20% started at 1,242/12,319 (10.081987%), with 754 requirements having recorded pass results. Added 1,296 pieces of evidence from 418 tests, increasing mapped requirements by 1,223 and requirements with recorded pass results by 538. Added 42 pending assessments. The mapped-test count is not the number of files whose complete review is finished.

Denominator SHA-256: `d9e94724b317c8668673f4f4883c4923bf94caad46d79ba7c79e1fd16302e6ac`

The index of the document SHA-256 (`source_audit.source_index_sha256` in the summary): `15a9aed7738bec626841dbdf20c4c8da3488bbd80b07f0d0328b9492026f5eaa`

If 12,319 is the denominator, the 2,464 requirement is required to exceed 20%. The current figure is 1 requirements higher than that. If a mapping must be withdrawn, prioritize correct aggregation over preserving figures.

<a id="読む順序と正本"></a>

## Reading order and authoritative sources

1. [20% : Achievement results, M65 - M97, Final inspection](existing-test-matching-20percent-20261023.en.md)
2. [Overall aggregate summary](behavior-coverage-summary.en.md)
3. [Existing-test mapping status](test-requirement-matching.en.md)
4. [Cumulative issues and pending reasons (since M01)](existing-test-matching-review-20261022.en.md)
5. [VPI mapping results when 10% was reached](existing-test-matching-vpi-20261023.en.md)
6. [Measurement rules and updating procedures](../coverage/README.en.md)
7. [Results of requirement extraction](requirement-extraction.en.md) and [Caution on interpretation and extraction](requirement-extraction-notes.en.md)

Ledger roles are as follows.

- `coverage/behaviors.json`: requirement definitions and approved `checks` / `check_groups`. `checks: []` is unsupported.
- `coverage/test-matching-reviews.json`: deferred mapping targets ID, reasons, evidence, and input hashes.
- `coverage/test-matching.json`: generated artifact integrating all tests' citations, registered ID mappings, unapproved candidates, and hold decisions.
- `coverage/standard-sections.json`, `requirement-source-index.json`, `requirement-audit.json`: source and extraction audit.
- `coverage/behavior-baseline.json`: The criterion for detecting the regression of the requirement, response, and AND set.
- `coverage/behavior-history.json`: history at each measurement date. The values in the process are also kept as a history.
- `coverage/results/*.json`: Evidence of complete execution and partial re-execution. Retain each run separately.
- `docs/behavior-coverage.md`: large per-requirement generated report. First, read the subject section closely.

<a id="規格資料"></a>

## Standard material

User-provided materials are outside the repository.

- Directory: `IEEE_1800-2023_SystemVerilog` beside the repository (`tools/requirement_source.py` can also be set through environment variable `IEEE1800_SOURCE`)
- PDF：`IEEE_Std_1800-2023_SystemVerilog.pdf`
- Extracted text: `out/lrm_pdftotext_layout.txt`

To read the source's own text, run it in the repository path.

```sh
python3 tools/requirement_source.py --show 6.20.4 6.21 11.5.1
python3 tools/behavior_coverage.py --candidates 11.5.1
```

If needed, regenerate the text cache outside the repository. Visually inspect figures/tables in PDF as necessary. Do not add the standard text, PDF or extracted-body caches to Git.

```sh
python3 tools/requirement_source.py --cache /tmp/claude-requirement-source.json
```

<a id="当時の未コミットの変更履歴"></a>

## Changes not committed at the time (history)

The following 12 tracked file was changed just before the handoff was created. These were subsequently committed and pushed.

```text
README.md
coverage/behavior-baseline.json
coverage/behavior-history.json
coverage/behavior-summary.json
coverage/behaviors.json
coverage/test-matching-reviews.json
coverage/test-matching.json
docs/behavior-coverage-summary.md
docs/behavior-coverage.md
docs/existing-test-matching-review-20261022.md
docs/nightly-results.md
docs/test-requirement-matching.md
```

The untracked material is the following 2 tests, and the 3 tests in addition to this handoff.

```text
docs/existing-test-matching-vpi-20261023.md
docs/existing-test-matching-20percent-20261023.md
docs/claude-code-handoff-20261023.md
```

The difference from HEAD also includes progress to 10% before 20% work began. Do not restore files from HEAD to discard changes present at the start. The 20% work verified preservation of initial requirement definitions, existing checks/AND sets, pending assessments, and history. Changes to `tests/`, `tools/`, `generators/`, `.github/`, the standard index, and requirement definitions were outside the scope of this work.

<a id="対応を登録するときの判断基準"></a>

## Criteria for registering mappings

1. Read the requirement's `behavior`, `acceptance`, and `source_spans` plus the relevant clause's text, figures, and tables.
2. Read the SV main file, VPI / DPI C helpers, includes and input data, and expected stdout/stderr.
3. Use concrete values, times, types, and targets to check whether incorrect implementation of this behavior would change expected output.
4. Check for existing hold decisions on the same test/requirement, and examine the whole file's conformance and oracle issues.
5. Leave mappings pending when they cover only part of multiple independent conditions. If separate tests can cover all conditions collectively, use a AND set.
6. Record the input digest, stimulus/expected-result string anchors, observations, date, and reviewer in `checks`.

Cited clauses, test names, or the mere fact that API is called are insufficient for registration. Relations checked only for non-NULL, coverage checks passing even when always 0, relational operators with only true-producing inputs, and checks that hide the original return type by assigning to another type are also insufficient evidence for the whole requirement.

`check_groups` uses AND within groups and OR between groups. For requirements configured this way, every check must belong to a group. Execution success requires every group member to succeed on the same simulator and snapshot; do not combine partial successes from separate runs. Do not confuse the collection of partial observations with OR, where multiple checks are placed to satisfy the entire requirement alone.

Count success only for `pass` with matching input and runner hashes. `known`, `unsupported`, `fail`, old inputs, and old runners do not count as successes. Do not confuse a non-matched syntax error in a non-conformity test with the detection of an intentional non-conformity.

<a id="最終監査で取り下げた対応と再登録時の注意"></a>

## Mappings withdrawn in the final audit and cautions for reregistration

In the audit just before reaching 20%, withdrew 20 provisional mappings covering 16 requirements because the existing reasons for holding them remained unresolved. After adding 20 mappings for 17 requirements from other existing tests, the final value is 2,465. Do not treat interim aggregate 2,464 as the final result.

- 6.16.2 `NO-RESIZE` in `ch6/test_string_putc`: valid indices alone do not verify that out-of-range/zero writes have no effect.
- 6.16.3 `SIGNATURE` in `ch6/test_string_getc_is_byte`: return width and signedness are observed, but the index formal's int type remains unchecked.
- 7.12.2 `SORT` / `RSORT`: comparing every element for plain sort but only endpoints and the first element for with sort does not prove that all elements are ordered by the projected key (M38).
- 8.7 `PROPERTY-INITIALIZATION`: defaults observed only after new do not prove initialization before the constructor body.
- 8.14 `VIRTUAL-OVERRIDE-DISPATCH`: virtual behavior alone does not provide a control against nonvirtual static binding (M33).
- `ch26/test_std_package_access`: try_get Oracle problem fixing success to 1 (M04). The new 5 items derived from this file are excluded.
- 37.29 `VIRTUAL-INITIALIZER`, 37.30 `INTERFACE-TYPE-PARENT`: the helper's `none` does not distinguish a NULL handle from the NULL name of a non-NULL handle.
- 37.58 `VECTOR-USES`: per-kind counts alone do not rule out incorrect same-kind targets or duplicates (M60).
- 37.72 `DIAGRAM-002/003` in `ch37/test_vpi_case_loop_force_stmts`: an existing issue where the helper also makes inappropriate Lhs queries on other statements (M64).
- `ch7/test_tagged_union_packed`: the standard's basis for tag encoding 00/01/10 for a 3-member type remains unresolved (M84). Deferred new mappings from this file, including width and placement.

For 13.3.1 `TASK-LOCAL-LIFETIME-OVERRIDE`, whose overlap with the hold registry remains, AND checked the static local in the automatic task of `ch13/test_task_static` and the automatic local in the static task of `ch6/test_automatic_variable_in_static_subroutine`. The M16, which pointed out the shortcomings of the previous test alone, is retained.

The final format mapping (21.2.1.1) observes concrete conversions. This does not claim separate stimulation of uppercase aliases. When requirement-row granularity is refined, alias and compound-condition handling should also be reaudited. Successful automated checks do not automatically approve semantic validity.

<a id="続行する場合の候補と既知の不足"></a>

## Continuation candidates and known gaps

The following are starting points for investigation, not approved mappings. Do not register entries while again ignoring previously recorded pending reasons.

- 6.20.2: type inference including type of aggregate parameter, member read, integral select, and signed/range. The `ch6/test_param_value_2`, `test_parameters_edge_cases`, and `test_parameter_override_types` are verified from the present paper and the oracle.
- 6.20.4: continuation of port localparam and the localparam keyword; local context in generate/package/class/unit. Indirect dependencies are already registered through `test_localparam_from_parameters`.
- 6.21: automatic blocks/subroutines, static defaults, hierarchical references, and fork/enclosing-scope lifetime. The candidates are `test_program_automatic_lifetime`, `test_vpi_lifetime_properties`, and `test_static_initializer_runs_once`. The automatic local is registered.
- 11.5.1: ascending declaration ranges, non-0-based index labels, invalid part-select reads/writes, and self-determined base-expression evaluation. Do not fill a whole compound row with ordinary descending ranges or comparisons that merely produce partial x values.
- Chapter 21: unsupported I/O/format/scan rows remain. Prioritize tests comparing concrete inputs and strings / byte / return values.
- 9.7: await rows including the self-await error are unsupported. Timing/state-specific resume/suspend rules and kill of all descendants are also insufficiently covered.
- 20.15.5: existing q_exam primarily covers code 1/3 and does not establish code 2/4/5/6.
- 10.9's assignment pattern: only the existing named field/default does not check for the priority of the type key.
- 6.19.5.2: although 3/1/6 in enum is nonmonotonic, last equals the maximum, so the test does not distinguish an incorrect implementation that returns the maximum for last (M95).
- The VPI: NULL test, the identity and value of the correct object, and the relation between callback and side effect are confirmed. This is distinguished from count/type only checks.

If the user again requests missing tests, these pending reasons can serve as stimulus/oracle design constraints. Derive expected values from the standard and independent observations rather than simulator acceptance alone.

<a id="更新検証の再開手順"></a>

## Resuming updates and validation

First check `git status --short` and authoritative values, save the current uncommitted state, then edit. The following commands will be executed from the repository path.

Artifact updates after adding mappings:

```sh
python3 tools/behavior_coverage.py --update --require-source-reviewed
python3 tools/requirement_matching.py --update
```

`--update` incorporates straightforward additions of requirements, mappings, and completed investigations into the baseline. If a justified mapping withdrawal or requirement correction requires a baseline update, record the diff and standard rationale and use `--write-baseline --reason '具体的な理由'`. Do not revert to an old baseline just to pass checks. Keep the existing history.

In the last 20% state of reaching, all of the following tests were successful.

```sh
python3 -m unittest discover -s tools -p 'test_*.py'
python3 tools/behavior_coverage.py --check --require-source-reviewed \
  --verify-source ../IEEE_1800-2023_SystemVerilog
python3 tools/requirement_matching.py --check
python3 tools/suite_stats.py --check
python3 tools/suite_catalog.py --check
python3 tools/coverage_depth.py --check --minimum-tests 2
python3 generators/generate.py --check
python3 tools/lint_metadata.py
git diff --check
```

The unit test was successful in 74 cases. The metadata lint is 3,938 tests, new problem 0, and known 378. Pass the document directory to `--verify-source` instead of the PDF file. `--require-complete` fails while unmapped requirements or requirements without recorded passes remain; do not use it as an ordinary check requiring success. The denominator was approved on 2026-10-28. There is no need to rerun all original SV/C tests for this handoff.

Along with generated artifacts, update README, the latest-results material, cumulative progress, and the main aggregate field in nightly-results. Do not rewrite historical descriptions in Nightly with current values. Saved main results differ from the current run's results produced by Nightly on the results branch. This handoff does not consult the latest execution status on GitHub.

<a id="一時ファイルについて"></a>

## About Temporary Files

The following remain in the original environment but are not required for handoff. Authoritative material other than the standard text is all in the repository.

- `/tmp/kirimasim-twentypercent-start-20261023.json`: comparison snapshot of uncommitted state when 20% work began.
- `/tmp/kirimasim-twenty-final-audit.py` / `.json`: Saved comparison with the start and final count.
- `/tmp/kirimasim-twenty-withdrawn-conflicts.json`: 20 provisional mappings withdrawn in the final audit.
- `/tmp/kirimasim-twenty-helper.py` etc.: Edit assistance for this session only. Do not rerun registered batch.

These are untracked by Git and may disappear. final-audit is session-specific and assumes the 20% target and the file set at that time; do not apply it unchanged to future work. Record a new starting state for subsequent work.

<a id="claude-codeへ渡す開始メッセージ"></a>

## Initialization message to pass to Claude Code

```text
From the root of this repository, read
docs/claude-code-handoff-20261023.md and
docs/claude-code-handoff-20261023-50percent.md to understand the situation.
For the latest denominator, requirement mappings, and verified execution results, see
coverage/behavior-summary.json and docs/behavior-coverage-summary.md.
The 75% target has been achieved. For current outstanding work and the approach to follow, see docs/handover-20261028.md.
Treat coverage/behavior-summary.json as authoritative, and carry forward the deferred decisions, evidence for AND sets, and procedures for checking the source materials.
The next specific work instructions will be provided separately.
```
