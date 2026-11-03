<a id="引き継ぎクロス検証とモデルに基づくランダム比較2026-11-02"></a>

# Handoff: interaction verification and model-based random comparisons (2026-11-02)

[English](codex-handoff-20261102.en.md) / [日本語](codex-handoff-20261102.md)

This document hands off work on `kirimasim-tests`. Run commands from the repository root.
Counts below describe the baseline commit. Check GitHub state and current revisions when resuming.

For subsequent work, use the [2026-11-04 verified checkpoint](nightly-results.en.md#latest-verified-checkpoint),
[current interaction follow-up](cross-verification-followup.en.md) and [thirteen-profile stabilization](random-cross-verification.en.md#thirteen-profile-stabilization).
They supersede this handoff's counts and unstarted-work descriptions; this dated baseline remains unchanged below.

<a id="1-基点と今回の依頼"></a>

## 1. Baseline and current request

- The branch is `main`, based on `3894c997f9662b96869c4e8c78d5470edbf4dca7` (introduction of model-based random comparisons).
  Before creating this document, `git fetch origin main` succeeded, `HEAD...origin/main` was `0 / 0`, and the working tree was clean.
- The current request is to create handoff documentation. This document, README links and document-index changes are uncommitted when created.
  Commit and push only when separately requested.
- The preceding request to restore a README P1 progress table was cancelled by the user because it concerned another repository.
  It caused no file changes. Do not resume that restoration.
- The [2026-10-31 handoff](codex-handoff-20261031.en.md) preserves historical context.
  Its old counts, descriptions of unstarted work, branches and Issue states are not current status.

<a id="2-現在の検証規模と証跡"></a>

## 2. Current verification scope and evidence

- The fixed suite has **10,289 tests**, including **3,852 generated tests from 74 generators**.
- Finite interaction verification has **65 models, 2,539 selected cases and 96 chapter pairs**.
  Saved evidence confirms the full selection PASS for **47 models**.
- Triage of 820 unordered chapter pairs is **M96 / E10 / C5 / N117 / R592**.
  `M` means modelled, `E` has reviewed existing-test evidence, `C` is an additional design candidate, `N` is out of scope,
  and `R` is deferred or unreviewed. All registered P1 candidates have models; this does not mean all chapter pairs are verified or simulator implementation is complete.
- Requirement coverage is **10,983 / 12,298 (89.31%)** for design and **9,539 / 12,298 (77.57%)** for execution.
  Execution coverage is the union of saved Icarus Verilog, Verilator, SymbiYosys and Ghost evidence, not a kirimasim-only measure.
- The saved full interaction run on [kirimasim `80859f34`](../coverage/interaction-results/cross65-kirimasim-80859f34.json) has
  **2,207 pass, 326 unsupported and 6 existing fail results**. The failures are two `inside`/`case inside` width/signedness differences
  and four config parameter-reset differences. Do not describe this revision as the current upstream head.
- The random comparisons on `866abf4d` below are not a rerun of all 2,539 finite cases.
  Do not treat `known`, `unsupported`, successful auxiliary controls or planned t-way coverage as PASS for original selected cases.

Sources of counts are the [README](../README.md), [generator catalog](generators.md),
[interaction plan and saved runs](interaction-coverage.en.md), [chapter matrices and CSVs](chapter-cross-matrix.en.md),
and [zero-cell triage](chapter-cross-triage.en.md). `coverage/chapter-interactions.json` maps models to chapter pairs;
`coverage/chapter-cross-triage.json` holds candidates and reviewed evidence.

<a id="3-直近の有限クロス追加"></a>

## 3. Recent finite interaction additions

Read [principles and practice](interaction-verification-method.en.md) for design and extension procedures,
and [design and verification records](interaction-verification.en.md) for each model's standard basis, controls and execution conditions.
The method defines legal factor combinations and selects pairwise coverage, necessary three-factor coverage and boundary witnesses.
It checks both low-order combination coverage and whether expectations and controls can expose erroneous behavior.

- `92fcd234` added strength formatting (31 cases, Chapters 21 × 28), class-held virtual interfaces (13 cases, Chapters 8 × 25),
  and clocking-event `iff` (12 cases, Chapters 9 × 14).
  On `80859f34`, all 31 strength cases pass; the other two models remain unsupported.
  Fixed Verilator results differ between four scalar and eight vector clocking cases; success of auxiliary vector expressions is not success of the original eight cases.
- `a9c4d924` added associative arrays and array queries (18 cases, Chapters 7 × 20).
  Fixed Icarus rejects all builds, fixed Verilator differs on all outputs, and kirimasim `80859f34` reports all unsupported.
  Expectations follow the standard. Independent calculations cover 216 rows and six Python-reference mutations;
  these are not successful simulator normal controls or executed SV fault injections.
- `9543b49b` added array reductions and constraints (13 cases, Chapters 7 × 18).
  The original 13 cases do not match fixed tools, and all are unsupported on `80859f34`.
  Validation includes 192 independent calculation rows, four auxiliary fixed-array normal controls and seven SV fault injections.
  Element-type casts added to auxiliary observation expressions were not copied into original tests or expectations.
  This does not qualify dynamic-array size retention through execution.

Machine-readable records for the latter additions are `coverage/interaction-qualification/assocquery*.json` and
`coverage/interaction-qualification/randreduce*.json`; `tools/qualify_randreduce.py` runs the auxiliary controls.
Existing tests, expectations, oracles and historical execution evidence were preserved.

<a id="4-新しいランダム比較機能"></a>

## 4. New random comparison feature

Introduced in baseline `3894c997`. Read the [usage and verdict rules](random-cross-verification.en.md) first.
Main files are `tools/random_cross_models.py`, `tools/run_random_cross.py` and `tools/test_random_cross.py`.

- `expression_context`: expression width, signedness, destination width and addition/subtraction/multiplication;
  reuses the reference in `generators/interaction_expr.py`.
- `division_context`: natural-width and destination-width quotient/remainder, including signed truncation toward zero;
  uses `generators/interaction_divide.py`, known inputs and nonzero divisors.
- `packed_write_sequence`: ascending/descending packed declarations, `+:`/`-:`, bit/logic, legal positions, data and read/write sequences.
  A whole-vector reference also checks X/Z handling and preservation of unselected bits.

This does not randomize all 65 models. Classes, constraint solvers, `randomize()`, concurrent scheduling and out-of-range indices
are outside scope. Multiple-solution constraints require a validity check distinct from exact output equality.
Random sample successes do not increase fixed-suite counts, chapter matrices or requirement coverage.

Nightly defaults to 96 cases × 8 vectors/operations, 4 workers, 5 seconds per case and a 120-second comparison budget.
Caps are 256 cases × 32, 8 workers, 30 seconds per case and 600 seconds overall. The additional step, including build, has a 15-minute limit.
The comparison CLI exits zero only when every case is a valid `pass`.
`fail`, `unsupported`, `not_run` and `stale` are not successes. Zero exit from `--generate-only` means generation success only.

`manifest.json` saves actual inputs and operation sequences, in addition to the seed. Records include SV, expectations, stdout/stderr,
return codes and source/binary hashes. Use `--replay` to reproduce stimuli. Output directories must be new or empty.
Automatic counterexample minimization is not implemented.

<a id="ローカルで確認済みの範囲"></a>

### Locally verified scope

See the [qualification record](../coverage/interaction-qualification/random-cross.json) and
[saved 96-case manifest](../coverage/interaction-qualification/random-cross-manifest.json).

- kirimasim `866abf4d86d11130a9946b79ea5fd19e2913b19c`, fetched and built immediately before execution,
  passed 96 cases with seed 1, 96 with seed 73 and 256 with seed 20261102: **448 random cases PASS**.
- One saved-stimulus replay passed with byte-identical SV and expectations.
  One normal control passed, and replacing SV addition with subtraction was detected through an output difference despite normal exit.
  These checks are separate from the 448 cases.
- Fixed Icarus 13.0 matched four samples per profile, 12 total.
- Initial tooling validation passed **653 unit tests (622 existing + 31 new)** and 13 consistency checks.
  This does not mean those checks were all rerun while creating this handoff.
- Execution records identify test-repository `9543b49b` plus uncommitted changes. Recorded source hashes identify the introduced code.
  Do not rewrite historical execution commit fields to `3894c997` after the fact.

<a id="5-ciの状態と確認方法"></a>

## 5. CI status and how to check it

<!-- handoff-ci-snapshot:begin -->
External state checked: 2026-11-02 06:18 JST.

- [Check 41350297782](https://github.com/kurochan001/kirimasim-tests/actions/runs/41350297782) for baseline `3894c997` **succeeded**.
  All three jobs, `icarus`, `verilator` and `readme`, succeeded. This does not cover the uncommitted handoff changes.
- The latest [successful Nightly 41248878297](https://github.com/kurochan001/kirimasim-tests/actions/runs/41248878297) targets
  `7cf35321ce1bb18e059facfab4ddead871d94358` and completed at 2026-11-01 11:36 JST.
  It predates the baseline and is not GitHub execution evidence for the new random comparison step.
<!-- handoff-ci-snapshot:end -->

Check now covers generation, manifest replay and tooling unit tests. Nightly executes random cases on latest kirimasim.
After the fixed suite, Nightly fetches/builds upstream main again before random comparisons.
The seed is the GitHub run ID. A retry may use a newer upstream revision, so check both the simulator revision and stimuli.
Any non-pass fails the random step; the fixed-regression ratchet is separate.
Replay data is saved as `random-cross-kirimasim`, separately from published `results-*` artifacts.

```sh
git status --short --branch
git fetch origin main
git rev-list --left-right --count HEAD...origin/main
gh run list --workflow check.yml --limit 5
gh run list --workflow nightly.yml --limit 5
gh run view RUN_ID --json status,conclusion,jobs
```

<a id="6-再開時の優先順"></a>

## 6. Recommended order when resuming

1. Baseline Check success is confirmed. When resuming, check subsequent commits' Check results and, if a new Nightly exists, its test SHA, simulator SHA and random comparison artifact.
   Do not report latest Nightly PASS using only an older run or the 448 local cases.
2. [#45](https://github.com/kurochan001/kirimasim-tests/issues/45) (covergroup transition parentheses and commas),
   [#46](https://github.com/kurochan001/kirimasim-tests/issues/46) (block-variable initialization and lifetime), and
   [#47](https://github.com/kurochan001/kirimasim-tests/issues/47) (`$cast` from a variable holding null) are OPEN.
   This handoff checked their states and reported subjects only; no standard review or fix was performed. Compare the standard, current tests and expectations yourself.
3. [Review and corrections for #40–#44](issues-40-44-review-20261031.en.md) are complete, but all five Issues remain OPEN on GitHub.
   Check the corrected state and remaining implementation limits instead of restarting them as unstarted work.
   [#24](https://github.com/kurochan001/kirimasim-tests/issues/24),
   [#27](https://github.com/kurochan001/kirimasim-tests/issues/27), and
   [#28](https://github.com/kurochan001/kirimasim-tests/issues/28) are also OPEN.
   Their scopes mix historical fixes and remaining work; do not assume every listed case is still unfixed. No Issue was posted or closed in this task.
4. For more finite crosses, select observable shared state or boundaries from E/C candidates and unreviewed R entries in the
   [triage ledger](../coverage/chapter-cross-triage.json). Examples for further review are Chapter 11 × 18 (`dist` and expression precedence)
   and Chapter 16 × 27 (generate and `default disable iff`). Existing witness tests still need a separate factor model.
5. Extend random comparisons with profiles whose independent references accept actual inputs or operation sequences.
   Shuffling fixed expectations or changing only a Verilator initialization seed is not random-stimulus verification.
6. To assess the six existing finite-cross differences or implementation improvements, fetch/build latest simulator main and save a full run under a new filename.
   This task did not modify the simulator implementation. Do not hide differences by changing expectations.

<a id="7-守る方針と作業環境"></a>

## 7. Policies and working environment

- Report progress and results concisely in Japanese, including during long work. Update English and Japanese documentation together.
- Fetch latest upstream immediately before simulator execution and build that revision. Matching `--commit` to `--version` alone does not prove upstream freshness.
  Fixed Icarus 13.0 and Verilator 5.052 oracle checks are exceptions. Use seeds 1 and 73 for two-state fixed-Verilator validation.
- Preserve existing tests, expectations, oracles and historical evidence. Do not read GPL/LGPL simulator implementation source. Do not copy other projects' reproduction code.
- Do not run or compare commercial simulators, or use third-party outputs/diagnostics for behavior analysis, expectations or implementation decisions.
  Keep them out of Issue bodies, comments, attachments and external links. Follow the [FAQ policy](faq.en.md#8-商用シミュレータでの確認状況).
  Do not assert general contractual prohibitions. Do not publish Ghost's real identity, version or execution environment.
- Record Icarus/Verilator differences in the [fixed-version difference record](simulator-differences.md), without upstream reporting.
  Distinguish kirimasim from Lyra results. Do not publish standard text, private material, personal information or absolute home paths.
- Adjacent `../kirimasim` has unrelated documentation changes. Do not edit or reset that checkout.
  Read that repository's instructions and use an isolated worktree before implementation changes.
- This host's simulator worktree is `/tmp/kirimasim-cross56-source`; build directory is `/tmp/kirimasim-cross56-build`.
  Complete local random execution artifacts are under `my-results/random-cross-validation-20261102-1/`.
  These are host-local and untracked; recheck existence and revision. Icarus on PATH may be version 14 and must not be treated as fixed 13.
- The referenced `RTK.md` is at `.claude/RTK.md` under the home directory. Normal commands are used except for RTK-specific meta commands.

<a id="8-再現と文書更新の手順"></a>

## 8. Replay and documentation updates

Follow [local execution instructions](random-cross-verification.en.md#run-locally) to fetch/build latest simulator main and record its identity.
After that, replay the saved corpus into a separate output directory:

```sh
python3 tools/run_random_cross.py \
  --kirimasim /path/to/latest-build/kirimasim --commit VERIFIED_FULL_COMMIT \
  --replay coverage/interaction-qualification/random-cross-manifest.json \
  --output my-results/random-cross-handoff-replay
```

To inspect generation without simulator execution:

```sh
python3 tools/run_random_cross.py --generate-only --seed 731 --cases 12 \
  --output my-results/random-cross-handoff-generated
```

Update both handwritten language versions and register new pairs in `docs/languages.json`, then run these commands in order.
`--record` updates fingerprints after both languages have been reviewed; it does not translate documents.

```sh
python3 tools/documentation_languages.py --update
python3 tools/documentation_languages.py --record
python3 tools/documentation_languages.py --check
python3 tools/suite_stats.py --check
git diff --check
```

For model or tooling changes, also run applicable generated-test checks (`generators/generate.py --check`),
`tools/interaction_coverage.py --check`, chapter-matrix, triage and requirement-mapping consistency checks, and tooling unit tests.
Documentation-only changes are not new simulator execution evidence.

Handoff validation passed: consistency of 114 language pairs, 52,135 local links, no untranslated Japanese in English prose, README counts and whitespace checks.
