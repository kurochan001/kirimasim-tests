<a id="nightly-resultsの更新時刻と見方"></a>

# Nightly results: update times and interpretation

[日本語](nightly-results.md) / [README charts](../README.md#nightly-results) / [Published results](https://github.com/kurochan001/kirimasim-tests/tree/results#readme) / [Workflow runs](https://github.com/kurochan001/kirimasim-tests/actions/workflows/nightly.yml)

<a id="latest-verified-checkpoint"></a>

## Latest verified checkpoint (2026-11-04 JST)

For suite commit `9926160a1397f514cdd09f84384392c832de2cc5`, both
[Check 41718590448](https://github.com/kurochan001/kirimasim-tests/actions/runs/41718590448)
and [Nightly 41743702063](https://github.com/kurochan001/kirimasim-tests/actions/runs/41743702063)
completed successfully. Check's readme, pinned Icarus 13.0 and Verilator 5.052 jobs succeeded;
Nightly's five simulator jobs and `publish` succeeded.
The [published snapshot](https://github.com/kurochan001/kirimasim-tests/blob/d86edcb61af0d54b0a8cff910a8757cc67c257bf/README.md)
was generated on 2026-11-04 at 03:25 UTC (12:25 JST).
This is a dated verification checkpoint, not a guarantee for later commits or upstream builds.

- **Fixed suite:** 10,672 registered tests, including 268 formal tests; the simulator runs selected 10,404.
  kirimasim `9113955914d8` recorded **7,868 pass, 2,403 unsupported and 133 fail**.
  The existing pass→fail ratchet succeeded; CI success does not mean every fixed test passed.
  Compared with the preceding Nightly, five ordinary Chapter 30 specify-condition tests changed from unsupported to pass;
  all other fixed statuses and all 10,404 input fingerprints are unchanged. Those five tests are outside the finite interaction selection.
- **Finite interaction selection:** all 2,922 selected inputs in 79 models are present in that single kirimasim run.
  Input fingerprints and status categories match the [saved cross79 snapshot](../coverage/interaction-results/cross79-kirimasim-a682e19e-pkgwatch.json):
  **2,389 pass, 529 unsupported and four config failures**; 52 models pass their full selection.
  The mapping has 114 chapter pairs. The CSVs still identify their original saved snapshot;
  the formal run is a separate confirmation, not a merge of partial results.
- **Random comparisons:** all **96 cases across thirteen profiles pass**, with valid, complete evidence.
  Seed `41743702063` is the workflow run ID; the separately recorded random build is
  kirimasim `9113955914d878437074f0e3b86a8dca38438080` (GNU 13.3.0), fetched and built again before comparison.
  Its binary SHA-256 is `b348f74d38baa8da4e0d9fdb87c40966b3f6397328408bb340aec477a47f3852`.
  Fixed and random phases happened to use the same core revision in this run; they need not do so in future runs.

The [verification record](../coverage/interaction-qualification/formal-ci-9926160a-20261104.json)
identifies workflow conclusions, artifact fingerprints, the full-selection comparison and independent checks of saved random SV.
The random evidence remains in `random-cross-kirimasim`, outside fixed history and coverage.
Profile additions remain paused at thirteen; next work is targeted exploration, independent checks and confirmed failure-to-regression follow-up.

### Current local additions (2026-11-05)

The class/package addition subsequently entered [Check on fd140002](https://github.com/kurochan001/kirimasim-tests/actions/runs/41852637183), which passed.
The working tree now adds 36 [generated-subroutine cases](interaction-verification.en.md#generated-subroutine-binding),
bringing the suite to 10,742 tests and the finite selection to 81 models / 2,992 cases.
The [single complete local run](../coverage/interaction-results/cross81-kirimasim-16222215-gensub.json) on latest-built `162222153c57`
records 2,459 pass, 529 unsupported and four fail; all preceding 2,956 inputs/statuses are unchanged.
These new 36 cases have not run in formal Check/Nightly. The latest formal Nightly remains the `9926160a` checkpoint above,
which predates both the class/package and generated-subroutine additions.

<a id="previous-verified-checkpoint"></a>

### Previous checkpoint (suite e8d991a9)

The preceding [Check 41649940180](https://github.com/kurochan001/kirimasim-tests/actions/runs/41649940180) and
[Nightly 41650010801](https://github.com/kurochan001/kirimasim-tests/actions/runs/41650010801) also succeeded, including publication.
On kirimasim `d73d8922dfa2`, the fixed suite recorded 7,863 pass, 2,408 unsupported and 133 fail;
the finite selection recorded 2,389 pass, 529 unsupported and four fail, and random comparisons recorded 96 valid passes with seed `41650010801`.
The [original verification record](../coverage/interaction-qualification/formal-ci-e8d991a9-20261104.json) and
[published snapshot](https://github.com/kurochan001/kirimasim-tests/blob/6722914378e3758387157e8c5f5eb31cdcd3d7cf/README.md)
remain unchanged. These are observations of the earlier run, not results from the latest build.

<a id="日本時間ではいつ更新されるか"></a>

## When results update in Japan

The [Nightly schedule](../.github/workflows/nightly.yml) is 19:23 UTC daily, or **04:23 JST the following day**. Publication has no fixed time: GitHub scheduling delays, queued runs, simulator builds and tests can delay it.

`publish` runs after the five Icarus, Verilator, kirimasim, Lyra and Ghost jobs finish. Ghost is a pre-release simulator participating under an alias, using the same tests while its identity and source remain private. An executable hash identifies its build; download locations, internal diagnostics and build logs are not published. nvc joined on 2026-10-24 and was removed on 2026-10-25 for limited SystemVerilog support; its old results remain in `history.json` but are not plotted.

Lyra resolves upstream main when its job starts and uses that SHA consistently for source checkout, cache identity and result metadata. Only an identical commit can reuse a build; uncached revisions are rebuilt. Previous GitHub runner builds took 40–90 minutes. Only main runs publish; manually running another branch retains artifacts without publishing. When `publish` pushes history, charts and the report to results, README-linked charts update. Pushing main is a separate operation.

To include local execution in published charts, saving evidence on main is insufficient: update results history/charts/tables with `tools/results_history.py update --source local`, specifying actual execution time and suite commit and linking the JSON, then push results. The public report and chapter table use each simulator's latest result, identifying its time, suite and `nightly`/`local` source. Earlier execution is not presented as part of a newer run.

`Latest run` and `Recent runs` display **UTC**. They record when `tools/results_history.py update` generated the report, not workflow start. Add nine hours for JST, including date rollover. The `workflow run` link shows start, queue and completion status.

<a id="最新のmainで手動実行する"></a>

## Starting a new run on current main

Start a new execution targeting main to use current suite and workflow sources:

```sh
gh workflow run check.yml --repo kurochan001/kirimasim-tests --ref main
gh workflow run nightly.yml --repo kurochan001/kirimasim-tests --ref main
```

[GitHub Re-run uses the original commit and ref](https://docs.github.com/en/actions/how-tos/manage-workflow-runs/re-run-workflows-and-jobs). A new `workflow_dispatch` on main uses its tip when dispatched. Lyra independently resolves its upstream main when that job starts and records the SHA actually executed.

<a id="random-comparisons"></a>

<a id="追加のランダム比較"></a>

## Additional random comparisons

The kirimasim job executes a default 96 [model-based random comparison](random-cross-verification.en.md) cases separately from the fixed suite.
After the fixed suite, it fetches/builds upstream main again before comparison. The GitHub run ID is the seed, and actual values/operation sequences are also saved.
Every case must be a valid pass; differences, unsupported features, timeouts or changed evidence fail the step.

The dedicated `random-cross-kirimasim` artifact contains results, replay manifest, SV, expectations and output. Its English report also enters Step Summary.
This artifact is outside fixed-suite `results-*` publication and does not increase public graphs, chapter match counts or requirement coverage.
Local success and successful execution of this GitHub step must be checked separately.

<a id="2026-11-02の公開処理失敗と対策"></a>

## Publication failure on 2026-11-02

[Run 41359514776](https://github.com/kurochan001/kirimasim-tests/actions/runs/41359514776), targeting suite `4e9c89c4`,
completed all five simulator jobs successfully but failed while generating requirement-coverage documents in `publish`.
The kirimasim random comparisons also had 96 valid passes on revision `2c81a591105b` with seed `41359514776`.
Successful fixed-suite jobs do not imply that every test matched.

The cause was treating the latest Verilator version string as prose requiring a cached translation.
The unseen form `Verilator 5.055 devel rev v5.054-25-g1b275150` stopped localization.
Replaying subsequent processing with the same artifacts also exposed a missing translation for an Annex B negative requirement
whose test was mapped but execution remained unconfirmed.

The fix renders versions, execution timestamps, clause identifiers and requirement kinds as literal Markdown code,
translating only the requirement-state prose. This removes dictionary entries specific to individual versions, times or clauses
while retaining checks for untranslated prose.
A negative test matching a development build still receives `unreviewed_oracle` when it lacks an approved fixed-version oracle.
Expectations, oracles, verdicts and coverage measurement rules are unchanged.

The fix was verified locally by generating history, detailed and summary requirement coverage in both languages,
and interaction reports in both languages from the failed run's five result JSON files.
Report generation is distinct from simulator execution and GitHub publication.
The subsequent [verified Nightly checkpoint](#latest-verified-checkpoint) completed publication successfully.
For later changes, start a new Nightly using [current-main dispatch](#starting-a-new-run-on-current-main).
Re-running the original failed execution uses the suite and tools from before the fix.

<a id="確認例2026年10月31日の公開"></a>

## Recorded example: publication on 2026-10-31

On 2026-11-01, all five simulator jobs and publish were confirmed successful for [run 41141958886](https://github.com/kurochan001/kirimasim-tests/actions/runs/41141958886), along with its [published snapshot](https://github.com/kurochan001/kirimasim-tests/blob/a587ba92e91e4fe2217710c7408614c6649d84e7/README.md).

- Suite: [`73af6e95`](https://github.com/kurochan001/kirimasim-tests/commit/73af6e954828221c3c7447dd13cd3a271ae5bb55), 9,203 tests.
- Report generated: 2026-10-31 11:16 JST (02:16 UTC).
- Each simulator selected 8,935 tests, excluding 268 formal tests; Ghost also excluded formal tests in this run.
- Matches: Icarus 5,701; Verilator 5,265; kirimasim 6,468; Lyra 6,933; Ghost 8,036.
- kirimasim revision: `17b7192b4f05`; Lyra revision: `e13a017966a5`.

This is evidence for that commit, not current suite counts or another cross-run revision. Use the [live report](https://github.com/kurochan001/kirimasim-tests/tree/results#readme) for subsequent publication. Workflow success and every test matching are different claims.

<a id="確認例2026年10月24日の手動実行"></a>

## Recorded example: manual execution on 2026-10-24

This was the first publication after expanding to five participants, manually dispatched on main.

- [Run 40084390631](https://github.com/kurochan001/kirimasim-tests/actions/runs/40084390631), `workflow_dispatch`.
- Started: 2026-10-24 19:03:26 JST (10:03:26 UTC).
- Report generated: 21:44:13 JST (12:44:13 UTC). The first Lyra build made total time about 2 hours 40 minutes.
- Displayed timestamp: `Latest run: 2026-10-24 12:44 UTC`.
- [Suite `0073c69`](https://github.com/kurochan001/kirimasim-tests/commit/0073c6947bc210d7b928d0d651ef34d5095b5999): 6,009 tests.
- [Results update](https://github.com/kurochan001/kirimasim-tests/commit/71908d7e3482f16c25dfad95ff52478faa6f040d).
- Matches: Icarus 4,018; Verilator 4,023; kirimasim 4,235; nvc 1,611; Lyra 4,607.

<a id="確認例2026年10月22日の更新"></a>

## Recorded example: update on 2026-10-22

GitHub Actions and public history were checked at 2026-10-23 07:17 JST. The latest publication then was [run 39686633157](https://github.com/kurochan001/kirimasim-tests/actions/runs/39686633157).

- Started: 2026-10-22 07:27:34 JST (2026-10-21 22:27:34 UTC).
- Report generated: 07:46:03 JST (2026-10-21 22:46:03 UTC).
- Displayed timestamp: `Latest run: 2026-10-21 22:46 UTC`.
- [Suite `4752cea`](https://github.com/kurochan001/kirimasim-tests/commit/4752cea52e9dc0d24ef58240eddee11ef055c673): 3,719 tests.
- [Results update](https://github.com/kurochan001/kirimasim-tests/commit/2a5c1cf9af6e55b8b42c4887aa7fda80206e3dc5).

The report does not display the 07:27 start. The 07:46 update appears under the previous UTC date. This describes that observation, not today's latest report; check live results and runs for current status.

<a id="所要時間の目安"></a>

## Historical duration estimates

These times were measured on a manually dispatched branch run with 6,009 tests on 2026-10-24.

| Job | Duration |
| --- | --- |
| Icarus | 1–3 minutes |
| kirimasim | 7–8 minutes |
| Verilator | About 14 minutes with effective ccache |
| Lyra | 35–70 minutes of tests with a cached build; an uncached revision added 42–89 minutes to build |

Lyra determined the full-run time, about 40 minutes to 1 hour 15 minutes. These measurements do not guarantee durations for current counts, revisions or cache conditions. The first main Lyra build on October 24 took about 2 hours 40 minutes (89 minutes building and 70 testing). The four-job run on October 23 took about 42 minutes.

The Verilator job limits each process's address space to 6 GB with `ulimit -v`. An illegal cyclic named-sequence test, `tests/ch16/test_illegal_sequence_cycle_through_bodies.sv`, otherwise recursively exhausted the runner's 16 GB memory and GitHub terminated the job. With the limit, that test alone fails.

<a id="現在のテスト数とnightlyの本数が違う場合"></a>

## When current and Nightly test counts differ

Use the [README statistics](../README.md#contents) and [catalog](tests/README.md) for current counts; use the report's `tests` and `suite commit` for its execution. The 9,203, 6,009 and 3,719 examples above belong to different commits. Formal and other selection rules also make whole-suite and runner totals differ. New tests appear only after a run includes their commit and publication finishes.

The Match percentage counts matching tests for that simulator. It is not coverage of every IEEE 1800-2023 behavior; requirement coverage requires reviewed stimulus/expectation links to the registry.

<a id="要求カバレッジを確認する場所"></a>

## Where to find requirement coverage

- [Main summary](behavior-coverage-summary.en.md) aggregates saved `coverage/results/` evidence. Read its generated values, denominator and test scope; matching current inputs and recorded versions is separate from Nightly match rates. Historical progress: after the [second gap-test batch](gap-tests-2-20261024.en.md) on October 24, design coverage was 59.59% (7,341 requirements); merging p01/p05/p07/p12 on October 25 brought it to 63.21% (7,787, 6,294 tests). On October 26, the remaining p09/p10/p13/p15, annex/gap and Annex A grammar ranges and tests were merged; 277 standard-only tests gained Icarus 13.0 oracle tokens and existing-test review added 341 requirements. On October 28, interpretation holds were resolved and 21 duplicate rows merged into the approved 12,298-requirement denominator. Confirmed design and execution figures now use that denominator. Approval was AI review, not independent human approval.
- Nightly's publish job generates a summary using only that run's results, at `behavior-coverage-summary.md` in [results](https://github.com/kurochan001/kirimasim-tests/tree/results). Lyra joined this aggregation on October 24. Requirements involving illegal-design detection count only Icarus/Verilator results with fixed-release oracle tokens.
- [Registry procedure](../coverage/README.en.md) defines denominators, provisional/confirmed values, fingerprints and collective witnesses.
- The [mapping inventory](test-requirement-matching.en.md) and [gap review](coverage-gap-recommendations-20261029.en.md) identify mapping progress and candidate additions.

For feature interactions, publish separately writes `interaction-coverage.md` and `interaction-coverage.json` to results. It checks pairs, selected triples and anchors per simulator, excluding unsupported, known and unrun cases from success and never merging partial successes across runs. See [saved main results](interaction-coverage.en.md) and the [guide](interaction-verification.en.md).

Publication generates `README.md` in English and `README.ja.md` in Japanese, with matching English/Japanese charts. The three coverage Markdown reports use Japanese `.md` and English `.en.md` filenames with language-switch links. Both versions use the same recorded results; publication does not rerun a simulator or change the raw JSON. These additional files appear on the public branch after publication using the updated tools completes.

Main includes fixed-release runs, partial reruns and local full-suite Ghost results; Nightly executes development versions. Commits, scope and versions differ, so their percentages are not results under identical conditions. Collective evidence requires every member in the same run.

<a id="更新されていないときの確認順"></a>

## Troubleshooting missing updates

1. Check whether the workflow started or remains queued; passing 04:23 JST does not rule out scheduling delay.
2. Inspect all five simulator jobs and publish.
3. After successful publish, check timestamp, suite commit and counts in the report.
4. If charts alone look stale, inspect the public report and results branch history too.

A simulator failing before producing output can be absent from that run. Known, unsupported and build failures are not success, and old results are not filled in as new execution. Because `latest/<simulator>.json` is the last result per environment, these files can originate from different runs.

Charts and reports show only simulators with a current `tools/run_<simulator>.py`. Removed participants such as nvc retain history.json/latest data without being plotted.

<a id="differをバグとして調べるとき"></a>

## Investigating Differ as a defect

Differ counts failing tests, including output mismatch, compile failure, accepted illegal source and diagnostic/exit-code mismatch. Diagnosis needs individual logs, legal test source, standard-derived expectations and correct diagnostic locations/content. One implementation issue may affect many files, and tests can themselves be wrong. The [2026-10-27 review](nightly-suite-corrections-20261027.en.md) revisited 27 diagnostic-location cases and one legal packed-union case among kirimasim's 174 Differ results.

<a id="保存クロス実行との比較"></a>

## Comparing saved cross runs

[Saved cross runs](interaction-verification.en.md#保存実行の概要) execute selections from registered finite models, a different scope from each Nightly runner's full selection. Even on the same date, check suite revision, simulator commit/fixed release and selection. Fixed-release oracle confirmation does not certify a Nightly development build.

Job success, test match rates and cross fulfillment are separate judgments. Target/anchor success is evaluated per record with matching input, expectation and runner fingerprints. Minimal examples and mutation controls do not add ordinary passes; partial successes across runs are not merged. See [evidence policy](../coverage/README.en.md#機能間クロスの計画と証跡).
