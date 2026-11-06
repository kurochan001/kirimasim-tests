<a id="handoff-20261106-cross-verification"></a>

# Handoff to Claude Code (2026-11-06)

[English](codex-handoff-20261106.en.md) / [日本語](codex-handoff-20261106.md)

Repository: `kurochan001/kirimasim-tests`. Run commands from its root.
The latest request is to prepare a handoff for Claude Code. Distinguish the ongoing event-loop addition from the subsequent handoff/documentation work.

## 1. Check the starting state

- Branch `main`, baseline `673210797a4e131a47f75524b4662f93de866206`. Fetch at handoff on 2026-11-06 confirmed `HEAD...origin/main` at `0 / 0`.
- **The 36 event-loop additions and these handoff/documentation changes are uncommitted.** This request does not ask for commit/push. Preserve existing changes and follow the next user instruction.
- Baseline 67321079 already commits/pushes the preceding 36 package-query cases. Earlier `98dc6d04` adds 36 program/automatic-task cases.
- Core repository `../kirimasim` is now **`1e840ea322cc58a9b6b6f1cac9fbf2ec0d005335`**, matching `origin/main`, with tracked files clean.
  The tested immutable binary was **`6f5c69841228257ebad959fef4aded828e781d93`**. **Core `1e840ea3` has not been rerun here.**
- The core already contains untracked `docs/CLAUDE_CODE_HANDOFF_2026-10-30.md` and `docs/CODEX_HANDOFF_2026-10-31.md`; they were left untouched.
- This work changes no core implementation, existing fixed expectations/tests or random profiles. Earlier evidence is preserved.

```sh
git status --short --branch
git fetch origin main
git rev-list --left-right --count HEAD...origin/main
git diff --stat
git -C ../kirimasim status --short --branch
git -C ../kirimasim fetch origin main
git -C ../kirimasim rev-list --left-right --count HEAD...origin/main
```

Do not reset/clean/force-checkout the uncommitted work. Older handoffs record historical counts/Issue states; prefer the [README](../README.md) and current reports.

## 2. Uncommitted cross addition

Read [design, examples and commands](interaction-verification.en.md#named-event-loop-transfer) first.

- `generators/interaction_eventflow.py`: `named_event_loop_transfer@1`, primary Chapter 15. Canonicalizing the unused all-flow pivot to middle reduces 2,592 Cartesian rows to 2,016 legal representatives.
  Select 36, retaining all 223 pair targets, 140 priority triple targets and six anchors.
- `generators/generate.py`, `generators/interaction_models.py`: register the generator and finite model.
- `tests/gen/ch15/test_gen_cross_eventflow_*.sv` and `.expected`: 36 new pairs.
- `coverage/chapter-interactions.json`: map only the 24 skip/stop cases to 12×15. Full-model success also requires twelve all-flow controls.
- `tools/qualify_eventflow.py`: independently interpret actual bounded SV with typed values, for/if, break/continue, Active/NBA queues, tick-indexed triggered state and fork-descendant cancellation.
  It does not call primary reference/payload/waiter helpers; it is separate from a general simulator or formal proof.
- `tools/test_interaction_eventflow.py`: eighteen new checks.
- `generators/oracles.txt`: append only eight pinned-Verilator known-input matches, preserving earlier entries.
- README, chapter CSVs, counts/catalogs/requirement matching, bilingual explanations and `tools/doc_locales/` are updated. Generated documents use their existing generators.

Boundaries include same-slot registration, edge versus triggered waits, blocking/NBA dispatch, and continue/break effects on receive/retention/completion.
Advance one tick per iteration and observe at trigger+2 to avoid rearm races. Pivot indexes receives, not driver pulses.
Late/edge/blocking misses the first pulse and receives three while awaiting a fourth: done=0 is expected.
Cancel at 26, spawn fresh waiters at 28 and check known recovery at 30/33 without erasing old history.

## 3. Observations and saved evidence

- Normal suite: **11,030 tests**, including **4,593 generated cases from 98 generators**.
- Finite selection: **89 models / 3,280 cases / 132 chapter pairs / 62 full-selection-pass models**. Triage: **M132/E3/C2/N117/R566**.
- [One complete selection run](../coverage/interaction-results/cross89-kirimasim-6f5c6984-eventflow.json) on `6f5c69841228`: **2,747 pass / 529 unsupported / four existing config failures**.
  All 36 additions parse/pass; preceding 3,244 input fingerprints/statuses are unchanged.
- [Build record](../coverage/interaction-qualification/eventflow-build.json): immediate fetch/configure/build, revision, slang pin, immutable binary hashes and 36 successful parses.
  The copied snapshot matched the built binary, isolating it from later changes in the shared core workspace.
- [Independent qualification](../coverage/interaction-qualification/eventflow.json): all 2,016 programs match; six normal controls and nine executable faulty programs exit normally, detecting all nine faults through output differences.
- [Pinned comparisons](../coverage/interaction-qualification/eventflow-fixed-replays.json): Icarus 13.0 has 36 known; Verilator 5.052 has 8 pass / 28 known at both seeds 1/73.
- [Replays](../coverage/interaction-qualification/eventflow-known-replays.json): all thirty-six Icarus diagnostics plus four known-input NBA and two X/Z Verilator cases at both seeds.
- [Four separate blocking-trigger controls](../coverage/interaction-qualification/eventflow-blocking-controls/) change only `->>` to `->` and independently interpret the changed expectation.
  Original SV/expectations stay unchanged. Controls match four kirimasim executions and eight Verilator executions across both seeds, without qualifying original NBA cases.

Requirements remain design 10,983/12,298 (89.31%), execution 9,539/12,298 (77.57%), with 5,310 explicitly reviewed linked tests.
Keep thirteen random profiles. Do not add random samples directly to fixed-suite, matrix or requirement counts.

## 4. Verified scope and logs

After implementing the event loop, **all 1,068 tool tests pass**, including the eighteen new checks. The final focused run also passes.
All fourteen consistency checks, 116 bilingual document pairs, relative links and changed anchors pass with this handoff included. The implementation regression is the run above; it was not repeated solely for handoff prose.
Core `1e840ea3`, formal CI for these 36 cases and a new random campaign have not been executed here.

Local ignored `my-results/eventflow-final-20261106/` contains `tools-unittest.log`, `verify-native.log`, `verify-fixed.log`, `update-reports.log`, `known-replays.log`, `checks.json`, `check-all.log`, `links.json` and `handoff-links.json`, plus the immutable binary snapshot.
These are local aids, not published artifacts. Use the tracked JSON above for lasting source/SV/execution evidence.
`my-results/eventflow-prototype-20261106/focused-unit.log` retains an initial target-count assertion typo failure.
The corrected 223/140 counts pass in `focused-unit-final.log` and the full regression; no SV expectation was weakened.
Helper scripts under `/tmp/` are local conveniences, not required resume dependencies.

Main check commands follow. Use each generator's `--update` for generated documents and `--record` only after editing both languages of authored documents.

```sh
python3 -m unittest discover -s tools -p 'test_*.py'
python3 generators/generate.py --check
python3 tools/suite_stats.py --check
python3 tools/suite_catalog.py --check
python3 tools/generator_catalog.py --check
python3 tools/interaction_coverage.py --check
python3 tools/chapter_cross_matrix.py --check
python3 tools/chapter_cross_triage.py --check
python3 tools/combination_gaps.py --check
python3 tools/documentation_languages.py --check
python3 tools/coverage_depth.py --check --minimum-tests 2
python3 tools/behavior_coverage.py --check --require-source-reviewed
python3 tools/requirement_matching.py --check
python3 tools/lint_metadata.py
python3 tools/interaction_coverage.py --model named_event_loop_transfer \
  --results coverage/interaction-results/cross89-kirimasim-6f5c6984-eventflow.json --require-pass
git diff --check
```

## 5. CI status and limitations

At handoff on 2026-11-06, baseline `67321079` passed [Check 42120289584](https://github.com/kurochan001/kirimasim-tests/actions/runs/42120289584)
and [Nightly 42136599265](https://github.com/kurochan001/kirimasim-tests/actions/runs/42136599265), including all jobs.
[The record](../coverage/interaction-qualification/handoff-ci-67321079-20261106.json) covers workflow/job conclusions.
**Individual Nightly artifacts, fixed/random inputs/results, core revisions and binary fingerprints remain uninspected.**
The uncommitted 36 event-loop cases are outside both runs.
Check on `98dc6d04` was cancelled by the later run; do not classify it as a failure.
Keep older artifact-reviewed `19cd790a` figures as a separate checkpoint in [result interpretation](nightly-results.en.md#latest-verified-checkpoint).

The four existing failures are config parameter-reset differences localized to pinned slang; expectations remain unchanged.
Read [follow-up](cross-verification-followup.en.md) before reimplementing already-fixed inside/label-cancellation work.
Verilator's four NBA cases show receive-count differences. Compare originals with blocking controls, without claiming an internal cause or general NBA non-support.
Icarus evidence records triggered-related build diagnostics; its implementation was not inspected. Known/unsupported/auxiliary results must remain separate from original passes.

## 6. Resume order and policies

1. Read the diff, tracked evidence above and [model-addition procedure](interaction-verification-method.en.md). No approval is pending for this addition.
2. If auditing new Nightly artifacts, distinguish the test commit and separate core revisions for fixed/random runs. Workflow success does not mean every test passed.
3. For current-core verification, fetch again and build that main into a new result name. Do not unconditionally call `1e840ea3` or the old snapshot latest.
4. Commit/push when subsequently requested, reviewing documents/generated files/evidence together and preserving existing uncommitted work.
5. Select observable E/C/R interactions from [triage](../coverage/chapter-cross-triage.json); first design legal scope, priority factors, boundaries/controls, independent expectations and fault-sensitive observations.
   Keep random profiles at thirteen for now, reusing existing deduplication, replay and failure-regression infrastructure.

```sh
# First verify that the core has no tracked local modifications.
git -C ../kirimasim fetch origin main
git -C ../kirimasim merge --ff-only origin/main
(cd ../kirimasim && cmake --preset dev && cmake --build --preset dev --parallel 6)
../kirimasim/build/dev/src/driver/kirimasim --version
python3 tools/run_kirimasim.py --kirimasim ../kirimasim/build/dev/src/driver/kirimasim -j 8 \
  --json my-results/eventflow-latest-new.json tests/gen/ch15/test_gen_cross_eventflow_*.sv
python3 tools/qualify_eventflow.py --kirimasim ../kirimasim/build/dev/src/driver/kirimasim \
  --output my-results/eventflow-qualification-new.json
```

Obtain the complete selection with `python3 tools/interaction_coverage.py --list-tests`. Do not combine partial batches into one complete success.
Preserve old evidence and use new output names. Read the core's current AGENTS.md/CLAUDE.md and specifications, following approval requirements for specification changes or new dependencies.
Do not read/copy GPL/LGPL simulator implementations or other projects' reproducer code; use standards and execution observations.
Do not run/compare commercial simulators or put their output/diagnostics into Issues, expectations or behavioral analysis. Keep Ghost's private information private.
Communicate concise status in Japanese and update both documentation languages together.
