<a id="claude-codeへの引き継ぎ機能間クロス検証2026-10-30"></a>

# Handoff to Claude Code: cross-feature verification (2026-10-30)

[English](claude-code-handoff-20261030-cross-verification.en.md) / [日本語](claude-code-handoff-20261030-cross-verification.md)

External-state check: 2026-10-30 14:15 UTC (23:15 JST). The first edition was written at 09:31:59 UTC that day; later updates reflect cross reruns, inside rechecks, and added range/case inside models. This material hands off the `kirimasim-tests` work. Run the following commands from the normal `kirimasim-tests` repository root.

<a id="1-最初に把握すること"></a>

## 1. What to understand first

- The main before adding the model in case inside was `a4e70f2b9e27a66a810c9fdeaaded342f8ce7bf0` (a range-specific model) and matched origin/main.
- This document's current update shares the case inside model commit. When resuming, check HEAD and push status using `git log` and `git status`.
- The continuing theme is to add feature interactions as finite models with specification-derived expectations and observations rather than a Cartesian product of all features.
- The suite has 9,176 cases and generation has 2,739 cases (since the first version, added 1 handwritten cases, 46 generated range cases, and 34 generated case inside cases). The short-term execution of crosses is 29 model and 1,426 case.
- A cross plan covering its targets does not establish that every simulator implementation case passes.
- The latest saved interaction run used kirimasim ** `f303becad9ca` ** (upstream main at verification time); of 1,426 cases, 1,368 passed, 56 were unsupported, and 2 failed. Do not reinterpret saved results as results for the new main implementation.
- Rechecked the 1 inside disagreements in `fc4cc356` and narrowed them down to sign extension of signed array-set elements instead of 0 extension. The implementation is unchanged. The cross-run in `f303beca` also disagreed on the same 1 cases; 1 disagreements of the same form were found for array items in case inside.

Read [Saved-run summary](interaction-verification.en.md#保存実行の概要), [Design principles and addition procedure](interaction-verification-method.en.md), and this document first.

<a id="2-ユーザーの方針と作業上の注意"></a>

## 2. User's policy and precautions during operation

- Report progress and results concisely in Japanese. The situation is shared even during long verification. English reports previously led to requests to restate them, so always report in Japanese.
- The user repeatedly requested commits/pushes to main, so work has proceeded by applying changes after verification.
- Immediately before running a simulator, fetch/check the latest commit and build that version. Do not use the old build as it is.
- kirimasim and Lyra are separate simulators. The `tools/run_kirimasim.py` and `tools/run_lyra.py` are used respectively. The results of kirimasim are not reported as the results of Lyra.
- Icarus 13.0 and Verilator 5.052 are the fixed oracle-reference releases. Do not interpret development-version agreement as a fixed-version oracle. To check Verilator, run the 2-state tests separately with seeds 1 and 73.
- Preserve existing tests, expected values, oracles, and historical execution evidence. Do not make unsupported diagnostics the expected result of success or remove legal factors to improve pass rates.
- Do not read GPL / LGPL implementation sources such as Icarus and Verilator, or copy reproduction code from other projects. Verify against the standard, independent calculations, and execution results.
- Differences between Icarus and Verilator are not reported upstream, but are recorded in [Fixed-version difference list](simulator-differences.md). Before writing another simulator's output in test comments, run it and verify the result.
- Do not start comment lines with `Verilator`. Because Verilator reads it as a directive, `tools/lint_metadata.py` detects it as `verilator-comment`.
- For tests without Icarus / Verilator oracles, the runner classifies disagreements as known rather than fail.
- Do not put reproduced standard text/figures/tables, absolute home paths, personal information, or private material in public files.
- The user previously requested subagent use, with approximately 6 agents. The following are the usage conditions of the current environment and instructions.
- In this conversation, the reference of `@RTK.md` is specified. AGENTS.md CLAUDE.md RTK.md was not a real file in the root of this repository at the time of verification. Check instructions in the environment when resuming.
- Before modifying the main file, read CLAUDE.md and AGENTS.md in the adjacent `kirimasim`. Apply rules for specification changes, expected-value changes, added dependencies, and local CI within the relevant work scope.
- Commits have used short English subjects, GitHub noreply author details, and a trailer naming the actual assisting model. The following persons follow the rules of the target repository.

<a id="3-直近に完了した変更"></a>

## 3. Recently completed changes

<a id="2026-10-31issue-の対応このコミット"></a>

### 2026-10-31: issue handling in this commit.

- Compared against the standard the 432 cases in #22–#28, plus #36–#39, that a batch run on another simulator (Ghost) classified as “test-side issues.” Fixed approximately 90 tests; retained the remainder as standard-compliant tests that Ghost does not match.
- #22: also excluded formal tests from `tools/run_ghost.py`. Saved Ghost results stopped counting after the runner fingerprint changed, reducing the verified-execution rate to 50.93%. Saving a new Ghost execution, such as `latest/ghost.json` from Nightly, in `coverage/results/` restores it.
- Closed #29–#35 (unimplemented Ghost operations) with explanations. The branch of the reactive sequence has only been re-appropriated for the test modification (adding `iverilog@13.0`).
- Ran 99 cases with modified inputs using Icarus 13.0 and Verilator 5.052, and saved them in `coverage/results/issues-20261031-*.json`. The requirement matching was reviewed again and the 3 case was removed (the reason was `behavior-baseline.json`).
- Removed `iverilog@13.0` from 7 negative tests that merely reject unsupported syntax (under the rule in README). The same problem remains in illegal-design tests such as ch8 and is recorded as oracle_issue in `test-matching-reviews.json`. The 2 FST cases remain extension tests; comments now correctly state that `$dumpfile` explicitly names VCD (21.7.1.1).
- Remaining work includes 2 undefined/deprecated DPI cases with no standard-defined expectation, illegal-test checks requiring `file:line:` at 1 lines, time-0 races in generator `scheduling` (14 cases), and interpretation-sensitive tests involving port forcing, compilation units, config use clauses, X/Z bins, empty checker outputs and parameter assignment.
- kirimasim: fixed sign extension of inside/case inside array elements on branch `fix/inside-array-element-extension` in a separate worktree (not pushed. local_ci passed; 2 cross-check disagreements resolved).

<a id="初版の後2026-10-30"></a>

### After the first edition (2026-10-30)

- Model of case inside (same commit as this update of the book)
  - Added `generators/interaction_case_inside.py`, `case_inside_selection@1`, and independent cross-check `tools/test_interaction_case_inside.py`.
  - Cross the first item (value/range/fixed array/list), widths/signs/bit / logic of the case expression and items, X/Z, no qualifier / `unique0`, and the 3-th item (variable / counting function). 34 cases from 8,704 possibilities; 315 pairs, 3 factor combinations for 154, and 7 mandatory conditions.
  - Priority and unique are excluded because the relationship between the violation report and `default` when there is no agreement is not explicitly mentioned in this paper. In `unique0`, do not use inputs matching 2 or more items.
  - kirimasim `f303beca` has 25 pass, 8 unsupported (function-call items), and 1 fail (sign-extending signed fixed-array items. The same form as the array set of inside). With Verilator 5.052, 4 of 9 2-state cases match for both seeds; only these 4 cases are registered as oracles. Icarus 13.0 is all known for 34.
  - Saved 29 models and 1,426 cases as `cross29-*.json`. Evidence: `coverage/interaction-qualification/20261030-case-inside.json` (minimal array-item examples and 7 fault types).
- ** `a4e70f2b`: range-specification model **
  - Added `generators/interaction_range.py`, `membership_range@1`, and independent cross-check `tools/test_interaction_range.py`.
  - Cross closed intervals, reversed bounds, `$` endpoints, absolute/relative tolerances, endpoint width and signedness, bit / logic, X/Z, and mixtures with values. 46 cases from 5,680 possibilities; 303 pairs, 3 factor combinations for 178, and 6 mandatory conditions.
  - The combination of different reading of the standard text (the range of endpoints X/Z, the empty range including X/Z, and the overflow of tolerance) is avoided by input and constraints that produce the same result in both reading.
  - kirimasim `f303beca` is 30 pass, 16 unsupported (range of tolerance). With Verilator 5.052, 7 of 16 2-state cases match for both seeds; only these 7 cases are registered as oracles. Record differing `$` endpoint results in the difference list. Icarus 13.0 is all known for 46.
  - Saved 1,392 cases for 28 models as `cross28-*.json` for kirimasim, Icarus, and Verilator, with both seeds. Evidence: `coverage/interaction-qualification/20261030-range.json` (small `$`-endpoint examples and 7 fault types).
- ** `e1be859f` **: moved README history to `docs/history.md` and `docs/history.ja.md`.
- ** `6dccebdd` **: first edition of this document.
- ** `b52cebd4`: interaction rerun with latest kirimasim, **
  - Built from upstream main `fb79248e46f6` checked immediately before execution, and saved all 1,346 cases in `cross27-kirimasim-fb79248e.json`.
  - 1,313 passed, 32 were unsupported, and 1 failed; no cases changed category from the saved `74fb2340` run. The input hash is the same.
- ** `4469ee37`: rechecking inside mismatches, **
  - Rebuilt at upstream main `fc4cc356` and reproduced the same output as before for 2 saved minimal examples (bit and logic).
  - A minimal example with a different left value showed kirimasim sign-extending signed array-set elements for comparison. 0 Extension is correct. Evaluating it as a localparam constant gives the correct result.
  - Added a handwritten test `tests/ch11/test_inside_array_set_mixed_sign_width.sv` using only 2 states (`:oracle: spec`). No requirement mappings are registered, so coverage is unchanged.
  - Recorded a new deviation in Verilator 5.052 in [Fixed-version difference list](simulator-differences.md).
  - Evidence: `coverage/interaction-qualification/20261030-inside-fc4cc356.json`.

<a id="初版の時点で完了していたもの"></a>

### Work complete at the first edition

- ** `93853a48`: incorporating regressions for Issue #21, **
  - The 20 candidate is matched with a new 74 item and an existing 14 item.
  - Added `generators/combination_events.py`, `combination_nba.py`, `combination_aggregates.py`, `combination_io.py`, and `combination_monitors.py`.
  - file monitor selects 18 cases from 36 possibilities, with 40 pairs and 3 mandatory conditions. `heap_file_monitor_context@1` is registered.
  - Use `tools/combination_gaps.py` to check candidate ID, the standard, observation points, and consistency of input hashes with execution evidence.
- ** `f1ed9eda`: compound shift assignments and left-hand-side selections, **
  - Added `generators/interaction_compound.py` and `compound_shift_target@1`.
  - 40 cases from 7,560 possibilities. 308 pairs, 3 factor combinations of 90, and 4 required conditions.
  - Observe scalars, array elements, part-selects, signedness, X/Z, shift amounts, 1 evaluations of index functions, and preservation of adjacent regions.
- ** `af21eff0`: set membership using inside, **
  - Added `generators/interaction_inside.py` and `membership_container@1`.
  - 46 cases from 5,984 possibilities. 305 pairs, 3 factor combinations of 174, and 5 required conditions.
  - Check explicit enumeration, fixed/dynamic arrays, queues, widths, signedness, state types, empty sets, X/Z, and reversed enumeration order.
- ** `f25ebecd`: updates to related 11 documents, **
  - Updated both language versions of README, the verification guide, methodology documents, FAQ, the glossary, the fixed-version differences list, and explanations of Nightly and evidence management.
  - Organized the new saved-run overview, the distinction between Check and execution satisfaction, and handling of auxiliary evidence.

[Issue #21](https://github.com/kurochan001/kirimasim-tests/issues/21) is closed. Completed work covers regression incorporation, legality classification, and evidence maintenance; unsupported functionality in the main implementation is not all implemented. See [Correspondence table](p1-combination-regressions-20261030.en.md) and [Mapping registry](../coverage/combination-gaps.json).

<a id="4-検証済みの状態と残件"></a>

## 4. Verified status and remaining items

<a id="最新の保存クロス実行"></a>

### Latest saved interaction run

`coverage/interaction-results/cross29-kirimasim-f303beca.json`：

- Main suite `f303becad9ca`: of 1,426 cases, 1,368 passed, 56 were unsupported, and 2 failed. The previous 1,392 case statuses match `cross28-kirimasim-f303beca.json` in the 28-model run.
- case inside： 25 pass・ 8 unsupported・ 1 fail。 274 of 315 pairs, 115 of 154 combinations of 3 factors, and 3 of 7 mandatory cases.
- Range specification: 30 pass, 16 unsupported (tolerance ranges). 252 of 303 pairs, 117 of 178 combinations of 3 factors, and 4 of 6 mandatory cases.
- Both `cross27-kirimasim-fb79248e.json` (`fb79248e46f6`) and `cross27-kirimasim-latest.json` (`74fb2340925a`) for the 27 models produced 1,313 passes, 32 unsupported results, and 1 failures. Keep it all.
- Compound shift assignment: all 40 cases pass.
- Set membership: 19 pass, 26 unsupported, 1 fail.
- Set-membership runs verified 208 of 305 pairs, and 84 of 174 combinations of 3 factors. The 5 mandatory cases have 1 pass, 3 unsupported and 1 fail; `complete` is false.
- The 56 unsupported cases comprise 6 existing array-slice assignments, 26 reading dynamic arrays/queues as sets, 16 tolerance ranges, and 8 case-inside items with side-effecting function calls. The 2 failures involve array sets in inside and array items in case inside.

In versions newer than `f303beca`, the entire cross is not executed. Handwritten test `test_inside_array_set_mixed_sign_width` is outside the cross scope and was last run in `fc4cc356`. Use a new result name for the next run; do not overwrite old JSON.

<a id="不一致1件の再現箇所"></a>

### Reproduction points for 1 disagreements

[Fixed-array width, signedness, and RHS X cases](../tests/gen/ch11/test_gen_cross_inside_w33_w_us_l_fixed_n3_rhs_x.sv) 。 Comparing an unsigned 34-bit all-1 value against signed 33-bit elements gives 1 in array form and 0 when the same elements are listed individually. With 0 extension to the common unsigned type under 11.4.13, 11.4.6, and 11.8.2, the expected value is 0.

[Isolation JSON](../coverage/interaction-qualification/20261030-inside.json) stores a minimal example using only known 2/3-bit values, same-sign control cases for bit / logic, measured values, and build fingerprints. The minimal example also confirmed array = 1, individual list = 0, and direct `==?` = 0. Injecting a fault comparing only the first element into correctly functioning individual lists produces detected disagreements.

Re-verification in `fc4cc356` ([Evidence](../coverage/interaction-qualification/20261030-inside-fc4cc356.json)):

- The 2 saved minimal examples reproduced the same output as previously recorded.
- Compared an unsigned 3-bit left-hand side against an array set of signed 2-bit elements `11`. For left-hand side `111`, array = 1 (expected 0); for `011`, array = 0 (expected 1), so the deviations are in opposite directions. This appears to compare elements as `111` rather than `011`.
- Even with `{01, 11}` containing 2 elements, left operand `111` gives array = 1. Using a localparam constant for the same comparison correctly gives array = 0.
- All individually listed forms give expected values.
- In the handwritten test, kirimasim differs from expectations only for the array form at lines 1–3 (1/0/1, expected 0/1/0). The 4 and 5 lines using the left-hand side of signed are correct.

<a id="固定参照版"></a>

### Fixed reference versions

- `cross29-icarus-13.json`: 1,007 pass and 419 known across all 1,426 cases. The case inside 34 is all known. The 1 bit-function cases with recorded variability became known again.
- `cross29-verilator-5.052-seed1.json` and `seed73.json`: 438 pass and 79 known of 517 each. The 9 2-state case inside cases each have 4 pass and 5 known (2 C++ build failures for array items, 2 `==?` for variable 4-state RHS, and 1 evaluations of items after a match).
- `cross28-icarus-13.json`: 1,008 pass and 384 known across all 1,392 cases. The range specified 46 items are all known. 2 bit-function cases with previously recorded variability changed from known to pass, but oracles were unchanged.
- `cross28-verilator-5.052-seed1.json` and `seed73.json`: 434 pass and 74 known of 508 each. For the 16 2-state range-specification cases, each has 7 passes and 9 known results (4 tolerance-syntax cases, 3 `==?` cases for variable 4-state RHS, and 2 result cases with `$` endpoints).
- `cross27-icarus-13.json`: 1,006 pass and 340 known across all 1,346 cases. The new inside 46 items are all known, and no Icarus oracle is added.
- `cross27-verilator-5.052-seed1.json` and `seed73.json`: 427 pass and 65 known of 492 each. For the new inside cases, the 11 2-state cases have 6 pass and 5 known on each tool; the 35 4-state cases are out of scope.
- Register the Verilator oracle only for the 6 new inside cases; retain standard-derived expectations for the other 40 cases.
- The 40 new compound-shift cases had 33 pass and 7 known on Icarus. For Verilator, among 9 2-state cases, 7 passed and 2 were known results (both seeds). Register a Icarus oracle only for the 33 cases that agreed on Icarus.
- Handwritten test `test_inside_array_set_mixed_sign_width`: Icarus 13.0 does not support `inside`. Verilator 5.052 has the same output for both seeds. At lines 1 and 3, the array form produces 1 while individual enumeration correctly produces 0. On line 4, both array and individually listed forms give 1, sign-extending the signed left operand against wider unsigned elements. Neither oracle is registered.
- Bit functions include cases with previously recorded variability and no registered oracle. Do not change expected values or oracle tags solely because the overall measured pass count changes.

For specific examples and rationale, see [Fixed-version difference list](simulator-differences.md) and [Explanation of auxiliary evidence](../coverage/interaction-qualification/README.en.md).

<a id="checknightlyローカル検査"></a>

### Check, Nightly, and local checks

- `4469ee37`'s [Check](https://github.com/kurochan001/kirimasim-tests/actions/runs/41041450032) is completed/successful.
- [Check](https://github.com/kurochan001/kirimasim-tests/actions/runs/41038897723) in `b52cebd4` and [Check](https://github.com/kurochan001/kirimasim-tests/actions/runs/41035144950) in `6dccebdd` also succeeded.
- In the state of `4469ee37`, the local tool recurrence 324 item is PASS. The product, aggregation, metadata and requirements matching were successfully checked.
- The latest verified [Nightly](https://github.com/kurochan001/kirimasim-tests/actions/runs/40972765631) succeeded, but its target suite was ** `360ef70c` **. This does not mean Nightly success across all current main cases.
- Check the Check result of the document-update commit separately at that commit.

The success of Check, the number of matches in the test, the coverage of the crosses, and the coverage of the requirements are other indicators. `interaction_coverage.py --check` is a consistency check. `--require-pass` checks successful satisfaction of all target combinations and mandatory cases in the specified saved run; it currently returns nonzero for set membership.

<a id="5-隣接リポジトリとローカル作業場所"></a>

## 5. Adjacent repositories and local workspaces

<a id="kirimasim本体"></a>

### kirimasim body

At verification time, `../kirimasim` was main ** `f303becad9cafcb96221bcfd4321a92341bab4ff` **, matching origin/main with no unpushed commits. Implementation work continues; the following 5 commits arrived after this document's first edition.

- `b64f3781`: NBA targeting string characters.
- `fc4cc356`: update of the measurement values. This is the version used to re-verify inside.
- `a7ee20a4` and `a8566e8b`: timing of NBA arena release.
- `f303beca`: update of the measurement values.

The body has an untraced `docs/CLAUDE_CODE_HANDOFF_2026-10-30.md`. Its opening baseline was `74fb2340`; compare the actual Git state and contents. Do not mix work in adjacent repositories or existing worktree with changes in this test repository.

<a id="作業用ディレクトリ"></a>

### Working directory

- Recent test-side worktrees: `../kirimasim-tests-work/issue21-20261030`, `cross26-20261030`, `cross27-20261030`, `docs-cross-20261030-af21`.
- Isolated implementation build: `../kirimasim-tests-work/cross-20261030-latest`. HEAD is at `fc4cc356` in detached state; the built `kirimasim --version` also reports `fc4cc3569fd6`. Since it is older than the current upstream, it is necessary to confirm the consistency of the acquisition, reconfiguration, build, and version if it is to be reused.
- Existing cache example for Icarus 13.0: `../kirimasim-tests-work/50percent-20261023/iverilog13/bin`. Check existence and version.
- There are also old worktree. Check with `git worktree list` and investigate its provenance before use.
- Do not make continuation depend on temporary logs or investigation scripts. Use material in Git and JSON for authoritative inputs, results, and minimal examples.
- The proposal to generalize this to LSI is `../lsi-verification-method/docs/feature-interaction-coverage-proposal.md`. There are also `docs/method/feature-interaction-verification.md` and `docs/templates/interaction-coverage-plan.md` in the same repository.

<a id="6-再開時の確認と実行"></a>

## 6. Checks and execution when resuming

```sh
git status --short --branch
git fetch origin
git log -5 --oneline
git rev-list --left-right --count HEAD...origin/main
git worktree list

git -C ../kirimasim status --short --branch
git -C ../kirimasim fetch origin
git -C ../kirimasim log -5 --oneline
git -C ../kirimasim rev-parse HEAD origin/main
```

Check unsaved/unpushed/concurrent work before choosing verification targets; create an isolated worktree if needed. Follow that repository's implementation-build instructions and build after reconfiguring CMake. Match the commit of `kirimasim --version` with the commit of the selected latest source.

The existing standard-material location is `../IEEE_1800-2023_SystemVerilog`.

```sh
python3 tools/requirement_source.py --source ../IEEE_1800-2023_SystemVerilog \
  --show 11.4.13 11.4.6 11.8.1 11.8.2
python3 tools/interaction_coverage.py --list-tests --model membership_container
```

Example after setting the new kirimasim build in `KIRIMASIM_BIN` and an unused result destination in `CROSS_RESULT_JSON`:

```python
import os
from pathlib import Path
import subprocess
import sys

paths = subprocess.check_output([
    sys.executable, "tools/interaction_coverage.py", "--list-tests"
], text=True).splitlines()
binary = Path(os.environ["KIRIMASIM_BIN"]).resolve()
result = Path(os.environ["CROSS_RESULT_JSON"])
if result.exists():
    raise SystemExit("保存先を変え、過去の実行JSONを保持してください")
run = subprocess.run([
    sys.executable, "tools/run_kirimasim.py", "--kirimasim", str(binary),
    "-j", "8", "--json", str(result), *paths
], check=False)
print("runner exit:", run.returncode)
```

Save to a new location within `coverage/interaction-results/`, with a name that identifies the version and re-verification. The runner may return nonzero while disagreements or unsupported cases remain. Check result classifications and JSON. Run Icarus with `--iverilog-bin` and Verilator with `--verilator --all --seed`. Restrict paths passed to Verilator to tests whose header `fourstate` is `no`. Lyra gets the latest main and builds it, and passes the actual commit to `run_lyra.py --commit`.

<a id="7-変更後の更新確認コマンド"></a>

## 7. Update and confirm command after change

```sh
python3 generators/generate.py
python3 tools/interaction_coverage.py --update
python3 tools/suite_stats.py --update
python3 tools/suite_catalog.py --update
python3 tools/coverage_depth.py --update --minimum-tests 2
python3 tools/behavior_coverage.py --update --require-source-reviewed
python3 tools/requirement_matching.py --update

python3 -m unittest discover -s tools -p 'test_*.py'
python3 generators/generate.py --check
python3 tools/interaction_coverage.py --check
python3 tools/combination_gaps.py --check
python3 tools/suite_stats.py --check
python3 tools/suite_catalog.py --check
python3 tools/coverage_depth.py --check --minimum-tests 2
python3 tools/behavior_coverage.py --check --require-source-reviewed
python3 tools/requirement_matching.py --check
python3 tools/lint_metadata.py
git diff --check
```

Refresh the corresponding aggregation after saving the rerun of the changed test. Documentation-only changes do not unnecessarily update inputs, expected values, or evidence. Aggregation/common regression may take time; avoid duplicate processes and share progress.

<a id="8-新しいクロスを追加する際の要点"></a>

## 8. Points to consider when adding a new cross

- Use the Model in `generators/interaction_cover.py`. Split the Cartesian product into chunks of at most 10,000 rows, specifying constraints, higher-order factor groups, and required cases.
- Not only do we align the same syntax, but we also decide what interacts and in which values, times, regions, and adjacent regions to distinguish errors.
- Changing existing model factors, constraints, higher-order groups, or mandatory cases also changes the selected set. Check `git diff --name-status` for accidental removal of old tests during regeneration; retain existing tests and history.
- Register it in `generators/generate.py` and `generators/interaction_models.py`, and add `interaction_model` and `interaction_values` to the generated metadata.
- Cross-check semantic boundaries with a calculation method independent of the implementation. Also check deterministic selection, target projections, and mandatory cases in common regression tests.
- `inside` applies OR to each comparison's 4-state result. `X inside {0,1}` is X; do not collapse it to 1 merely because all 2-valued concretizations of the left-hand side belong to the set.
- Do not pass partial results to `generators/record_oracles.py` and overwrite the full existing oracle. Check only additions and retain existing registrations.
- Changes in the header such as the oracle tag will change the input hash. Regenerate and rerun; do not carry forward success by rewriting old JSON hashes.
- Do not automatically add new interactions to requirement coverage. Requirement-mapping registration requires a separate content review.
- Update both language versions of README, the verification guide, fixed-version difference list, and auxiliary-evidence explanation. Keep only current information in README, and move superseded records and measurements to [History](history.md) (English version: `docs/history.md`).
- `combination_gap` links to the 20 candidate ledger for Issue #21. Do not attach it mechanically to another new model.

Do not relabel the unresolved real-member representation in `fread`, recursive VCD program/interface scope, automatic-strobe interpretation, native callback reentry or actual GC reclamation separated in Issue #21 as passing or illegal without reading the rationale in [Mapping registry](../coverage/combination-gaps.json).

<a id="9-次の担当者への推奨順序"></a>

## 9. Recommended order for the next person in charge

1. Recheck the current state of main, adjacent implementations, and CI. The scope of implementation is determined according to the following user instructions.
2. Before fixing inside in the main implementation, run handwritten tests `test_inside_array_set_mixed_sign_width` and `test_gen_cross_inside_w33_w_us_l_fixed_n3_rhs_x` with the latest build to confirm reproduction. The correction concerns extension of signed elements in the array-set comparison path. Follow implementation conventions and keep this separate from ongoing implementation-side work.
3. Then distinguish the 26 dynamic-array/queue set cases from the previous 6 array-slice cases when proceeding.
4. Because saved and current implementation versions differ, rerun the necessary scope on the latest build and save under a new result name.
5. When adding more crosses, choose outside the existing guide's scope. Candidates include task-argument index changes and return-time visibility, queue-element reference lifetime, and factor models for events OR and `iff`. Check legality and unspecified ordering first.
6. To verify all latest-main cases, run Nightly at that commit and check every job and publishing. Do not interpret an old Nightly success as success on a new suite.

Waiting for user decision:

- Unmerged branch `fix/p1-conditional-reactive-tests` (2 commit). Change the expected value of `test_reactive_region_set_order` in ch4.
- Open issue # 22 to # 36 in this repository. #36 (where `"\60x"` in ch21 becomes an illegal escape in 5.9.1) was created in 2026-10-30.
- Draft report of a streaming defect to slang. It is in `../kirimasim-tests-work/slang-issue-streaming-20261028/` and should be submitted after the user's earlier report slang #2072 (OPEN when checked) has been processed. Do not link to kirimasim-tests.

<a id="10-読む資料とコード"></a>

## 10. Material and code to read

- [Verification guide and saved-run overview](interaction-verification.en.md)
- [Approach, addition procedure, and application to other projects](interaction-verification-method.en.md)
- [Generated cross plans and execution reports](interaction-coverage.en.md)
- [FAQ](faq.en.md#7-機能間クロス検証)・[Glossary](glossary.en.md#8-機能間クロス検証)
- [Fixed-version difference list](simulator-differences.md)
- [Evidence management](../coverage/README.en.md#機能間クロスの計画と証跡)
- [Auxiliary evidence](../coverage/interaction-qualification/README.en.md)・[Re-check inside](../coverage/interaction-qualification/20261030-inside-fc4cc356.json)
- [inside generator](../generators/interaction_inside.py)・[Independent recalculation](../tools/test_interaction_inside.py)
- [Compound-shift generator](../generators/interaction_compound.py)・[Independent recalculation](../tools/test_interaction_compound.py)
- [Selector](../generators/interaction_cover.py)・[Model registration](../generators/interaction_models.py)・[Aggregation tools](../tools/interaction_coverage.py)
- [Requirement-coverage aggregation](behavior-coverage-summary.en.md): 12,298 requirements, design mappings 10,986 (89.33%), verified execution 7,330 (59.60%, the union across environments). Adding tests and increasing this percentage are separate matters.
- [Previous handoffs](handover-20261028.en.md): requirement ledger and outstanding work as of 2026-10-29. Do not treat old test counts as current values.

<a id="claude-codeへ渡す開始指示の例"></a>

## Example of a start instruction to pass to Claude Code

```text
Read docs/claude-code-handoff-20261030-cross-verification.md in this repository,
and check for differences between the recorded state and the current state of Git, CI, and the neighboring kirimasim checkout.
Preserve existing expected values, oracles, and history. Build the simulator from the latest commit verified immediately before execution.
Keep plan coverage, execution completeness, Check/Nightly, and requirement coverage distinct.
Follow the user's subsequent instructions, and report verification results and outstanding work in Japanese.
```
