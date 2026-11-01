<a id="claude-codeへのハンドオフ50到達作業2026-10-23開始2026-10-24に50到達"></a>

# Handoff to Claude Code: work toward 50% (started at 2026-10-23; reached 50% at 2026-10-24)

[English](claude-code-handoff-20261023-50percent.en.md) / [日本語](claude-code-handoff-20261023-50percent.md)

> Historical materials
> The text records the state of each work period. The current denominator, mappings, and execution evidence are in
> [Aggregated Summary](behavior-coverage-summary.en.md), the latest takeover and remaining cases.
> See [Handoff for updating 2026-10-29](handover-20261028.en.md).

<a id="nightly-とシミュレータの変更2026-10-24"></a>

## Nightly and simulator changes (2026-10-24)

- Set the comparison targets to 4 tools: Icarus, Verilator, kirimasim, and Lyra (fixed by `LYRA_COMMIT`); nvc was added on 10/24 and removed on 10/25 because of limited support. Removed all names of the previous 1 additional simulator(s); do not mention them in new files or commit messages.
- Trend charts and reports show only simulators with `tools/run_<id>.py`.
- After integrating new tests, check that all jobs finish in the first nightly run. Verilator once ran out of control on `ch16/test_illegal_sequence_cycle_through_bodies` introduced in round 1 and stalled the runner (now bounded by `ulimit -v`).
- The standard PDF is located at `../IEEE_1800-2023_SystemVerilog` (locally a symlink to its original location), or `$IEEE1800_SOURCE`. The `pdf` argument of the workflow can also be passed in this path.
- Tests whose expected values may conflict with the standard, and thus are exclusion candidates, are in the final section of `docs/simulator-differences.md`.

<a id="75を目指す再開2026-10-241回目まで統合"></a>

## Resuming toward 75% (2026-10-24, integrated through round 1)

- Target: exceed 75% = 9,240 requirements. After integrating round 1: 7,341 requirements (59.590876%), with 1,899 requirements remaining. The record is [gap-tests-2-20261024.md](gap-tests-2-20261024.en.md).
- Comparison work continued, reaching 10,980 requirements (89.28%) and 75% when the denominator was approved at 2026-10-28.
- Integrated work is committed as `1a2c833` and pushed to `main` (2026-10-24).
- Round 1 (Run ID `wf_71865177-920`, approximately 861×10,000 tokens; weekly usage 59% → about 70%): g01, g02, g03, g04, g06, g07, p08 and p25. Comparison proposals: 928 accepted and 102 rejected; tests: 936 passed and 26 defective.
- Integrated 933 of 936 passing tests (list `usable3b-tests.txt`). Excluded the 3 tests citing 12.2, 12.3, 12.4.2.1, and 12.5.3.1 using only 1 tests because a 2-th test is required (moved to `parked3/`).
- Tests in unverified segments are in `parked3/` (list `parked3-files.txt`, 679 tests). Restore with `rsync -a <作業dir>/parked3/tests/ tests/` when continuing. Identify tests already assessed defective by the last assessment in `notes/*-testverdicts.jsonl`.
- At the user's direction, resume from round 2 onward only after capacity becomes available under the weekly limit.
  - Planned round 2: p01, p05, p07, p09, p10, p12, p13 and p15.
  - Planned round 3: a01–a05, g05, g08, g09, h01 and h02 (1,388 proposed mappings together with round 2, covering 1,356 unmapped requirements).
- Added the reasons for defect classifications to the `tools/matching_kit/workflows/gap.js` instructions, including comments on the same line as `` `line `` and virtual-interface input ports.
- Adding new tests to `tests/ch22` changes the input hashes of 4 existing tests that use `tests/ch22` as an include search directory. Rerun together during integration and refresh input hashes in the ledger and hold records.

<a id="1回目までの準備の記録"></a>

### Preparation records through round 1

- Goal: exceed 75%, corresponding to 9,240 requirements (2,810 more than 6,430 as of `b13204c`).
- Restored the `parked2/` tests to `tests/` except for 32 confirmed defects (1,832 files. Excluded items are in working-directory `restored3-skipped.txt`). `tests/` currently contains unvalidated tests. Do not regenerate artifacts or commit until the integration procedure.
- Added the reasons for defects found in the previous verification to the `tools/matching_kit/workflows/gap.js` instructions (uncommitted).
- Procedure: run resumed creation (`resume: true`) and independent validation in batches of 8 segments.
  - Round 1 (Run ID `wf_71865177-920`): g01, g02, g03, g04, g06, g07, p08, p25
  - Planned round 2: p01, p05, p07, p09, p10, p12, p13 and p15 (after round 1, the user decides whether to continue based on growth in weekly usage, starting at 59%).
  - Planned round 3: a01–a05, g05, g08, g09, h01 and h02.
  - If this is not enough, the creation continues with the remaining unmatched requirements of the verified segment (p02 to p24).
- If the workflow stops, resume with the same `scriptPath` and arguments, adding `resumeFromRunId`.

<a id="2026-10-24の再開後の状態"></a>

## State after resuming 2026-10-24

- Reached 50%: independent checks of 13 sections (p02, p03, p04, p06, p11, p16–p19 and p21–p24) completed, and 594 new tests and their mappings were integrated. 6,430 / 12,319 requirements (52.195795%), provisional execution verification coverage 30.310902% (3,734); main text alone (Chapters 1–40): 53.47% (5,072/9,486).
- Record: [gap-tests-20261024.md](gap-tests-20261024.en.md) (totals, chapter breakdown, verification results, details of 30 defects, `input int` findings and remaining work).
- Commit: incorporated work was pushed to `main` as commit `0ab9e18` (2026-10-24).
- List of tests included: `usable2-tests.txt` in the working directory (594 tests). Execution evidence is `coverage/results/gap-tests-20261024-*.json` and `gap-refinement-20261024-*.json` for 3 tests fixed after integration.
- Unvalidated tests are in working-directory `parked2/` (1,893 files, including 1,117 tests. The 30 tests which was found to be defective is also included. List `parked2-files.txt` ). Restore with `rsync -a <作業dir>/parked2/tests/ tests/` when resuming. The 30 defective tests are those whose last assessment in `notes/*-testverdicts.jsonl` is `defective`.
- Unvalidated proposed mappings (1,752):

| wave |Segment (undecided-proposal count)|
| --- | --- |
| wave1 | p12-gap（110） |
| wave2 | p01-gap（107）、p05-gap（110）、p07-gap（75） |
| wave3 | p08（95）、p09（100）、p10（124）、p13（111）、p15（138）、p25（95） |
| wave4 |a01–a05 (288, Annex A syntax), g01–g09 (305) and h01–h02 (94)|

- If we continue, we verify the above segment with `verifyOnly: true` of `tools/matching_kit/workflows/gap.js` and integrate it in the same way as before. `merge.py` has been corrected to prevent duplicate decisions to hold mappings.
- Check before merging (what I learned this time):
  - A 2-state input with its kind omitted in ANSI form (`input int`) becomes a net and violates the standard (23.2.2.3, 6.7.1). Set it to `input var int`.
  - If only 1 new test(s) cite a previously uncited clause, `coverage_depth.py --check --minimum-tests 2` fails. Remove background-only clauses from `:lrm:`.
  - If a test changes after incorporation, save its rerun under a separate result filename, update `inputs_sha256` in the ledger, and record it with `--write-baseline --reason`. Run `--history` only 1 times at the end.

The following records the state before resuming 2026-10-24.

<a id="中断時の記録2026-10-23"></a>

## Records at interruption (2026-10-23)

<a id="最初に把握すること"></a>

### What to understand first

The task "Proceed the provisional requirements coverage (test design) to 50%" was interrupted in the middle because of the large token consumption. After the interruption, incorporated only independently verified work into the ledger (24 annex-header tests, 24 VPI tests for Chapter 37, and comparisons with existing tests). After incorporation: 3,889 / 12,319 requirements, provisional requirement coverage (test design) 31.569121%, and provisional verified-execution rate 19.449631% (2,396). Integrated work is committed as `ba54eb3` and pushed to `main` (2026-10-24). Approximately 1,711 unvalidated new tests are stored outside the repository. When resuming, restore from the working directory before starting.

- Repository: kirimasim-tests (`main`, HEAD `af50ecf` = progress through 10% and 20%. Pushed)
- Authoritative value: 3,889 requirements at `ba54eb3` (31.57%). Subsequent registry revision (`721db37`) and generated keyword tests (`1f9efc5`, 2026-10-24) brought coverage to 4,386/12,319 requirements, 35.60%
- Target: exceed 50% = 6,160 requirements (1,774 remaining as of `1f9efc5`)
- Incorporation record: [header-vpi-tests-and-matching-20261023.md](header-vpi-tests-and-matching-20261023.en.md)
- Working directory, outside the repository and required for resumption: `kirimasim-tests-work/50percent-20261023/` beside the repository
- The previous report ( judgment criteria of comparison, etc.) is referred to [claude-code-handoff-20261023.md](claude-code-handoff-20261023.en.md). The criteria is still valid.

<a id="中断時点の数値"></a>

## Interrupted value

|Stage|Requirement count|Provisional requirements coverage (test design)|
| --- | ---: | ---: |
|Committed| 2,465 | 20.01% |
|+ Accepted through independent validation (not integrated)| 3,889 | 31.57% |
|If all mappings awaiting verification are also accepted| 7,847 | 63.70% |

- Breakdown of the 1,424 accepted requirements: 1,081 header tests for Annexes K/M/L/I, 153 mappings to existing tests, and approximately 190 new tests (p20).
- Awaiting validation: proposed mappings for 3,958 requirements (3,967 entries). Previous validation rejected 2–4 tenths of proposals. 50% requires the adoption of 2,271 requirements (57%).
- Accepted entries are concentrated in annex headers: 1 constants = 1 requirement rows. For the main text only (clauses 1–40, denominator 9,486), coverage rises from committed 25.6% to 29.3% including accepted mappings. In the final report, the total value and the value of the present paper only and the chapter-by-chapter indication are planned to be jointly listed.

<a id="取り込み前中断直後の作業ツリーの状態"></a>

## Working-tree state before integration, immediately after interruption

The following is the record immediately after the interruption. In the subsequent incorporation, retained only 48 verified tests (`usable-tests.txt`) in `tests/` and moved the other 3,069 untracked test files to `parked/` in the working directory, preserving their paths (list: `parked-files.txt`). When resuming, run `rsync -a <作業dir>/parked/tests/ tests/` at the repository root to restore the files. `parked/` also includes the 2 tests found defective in p20 and the 13 tests with lint violations.


- Untracked new tests: 1,759 (under `tests/`, including `.sv` / `.expected` / `.c` and others, totaling 3,214 files). Lists: `new-tests.txt` in the working directory, the complete list of untracked files `untracked-files.txt`, and backup `untracked-worktree.tgz` (restore by running `tar xzf <tgz>` at the repository root).
- The 24 tests is a header test for the appendix that I wrote (verified, see below). The remainder was written by the assigned agents and is unverified, apart from the 26 tests in p20 (24 passing, 2 defective).
- 13 tests with lint violations (unfinished): `new-tests-lint.txt` in the working directory. TODO remains, expected output is empty/none, and the line is long.
- Modified tracked files: `coverage/test-matching.json`, `docs/test-requirement-matching.md` (only regenerated with new tests included. Regenerate once more during final integration).
- The hand-off material itself is not traced.

<a id="作業ディレクトリの中身"></a>

## Contents of the working directory

|Path|Content|
| --- | --- |
| `kit/propose.py` |The reference, registration and decision of the comparison proposals are CLI. `req` / `test` / `scope` / `add` / `group` / `hold` / `show` / `verdict` / `testverdict` 。 At registration, perform checks equivalent to `validate()` (clause citation, positive/negative classification, anchor existence, input files, withdrawal of existing pending / 20% audits, and BLOCKED). New tests are discovered automatically from the filesystem.|
| `kit/merge.py` |The only proposals where the latest decision is accepted are integrated into `behaviors.json` and `test-matching-reviews.json` ( `--dry-run` is present ). The input is rechecked at the time of integration and the input digest is calculated. The reviewer is `Claude Opus 5.5 (AI); not an independent human review`.|
| `kit/runsim.py` |Run on Icarus 13.0 and Verilator 5.052 (seed 1/73), and display agreement (using ccache).|
| `iverilog13/` |Icarus Verilog 13.0 (`v13_0-dirty`, the same version as the preserved evidence). This also works after relocation. To rebuild, apply `iverilog13-macos.patch` to tag `v13_0` of `iverilog13-source.txt`, then run `sh autoconf.sh && ./configure --prefix=... && make && make install` in `PATH=/opt/homebrew/opt/bison/bin:$PATH`.|
| `assign/*.json` |Assigned scope (list of ID requirements). `p01`–`p25`: requirements with cited tests; `g01`–`g09`: main-text requirements without cited tests; `a01`–`a05`: Annex A; `h01`–`h02`: Annexes C/G/H/J/N.|
| `proposals/<wave>/<label>.jsonl` |Proposed mappings. `.verdicts.jsonl` assesses entries; the last assessment for the same key takes precedence. `-gap` contains new-test proposals written after mapping. `annex/` contains annex-header tests.|
| `notes/<label>-tests.txt` |The list of new tests made by each person (isolation test 111 when interrupted) has been divided into sections. `-testverdicts.jsonl` records test pass/fail; `-simdiff.md` records simulator/standard differences. `annex-simdiff.md` is a draft of differences in annex tests.|
| `wf-gap.js` |Workflow script (pipeline of creation→verification). `args = {sp, parts:[{label,wave,mode}], verifyOnly?, resume?}` 。 Modes are `gap` (new tests after comparison), `combined` (comparison and new tests), and `annexA` (syntax tests).|
| `wf-match.js` |Workflow for existing-test comparison only (used in wave1 / 2).|
| `parts.json` |All segments for resumption (label/wave/mode/undecided-proposal count at interruption).|
| `status-table.md` |Per-segment accepted/rejected/undecided counts and test listed/passing/defective counts.|
| `annex/` |Annex-header test generation scripts (`gen_constants.py`, `gen_decls.py`, `gen_decls2.py`, `gen_compat.py`), reference header `refhdr/` reconstructed from the standard text, and self-check `selfcheck.py`.|
| `start/` |Copy of `behaviors.json`, etc. at the start of the operation.|
| `verifier-artifacts/` |The header and mutation test work that the verification person reconstructed from the standard text.|

From 2026-10-24 onward, use the `tools/matching_kit/` incorporated into the repository (`kit/` and `wf-*.js` in the working directory are old versions from when work was interrupted). The differences are as follows. Proposal and assessment file formats are unchanged and remain usable.
- `merge.py` requires `--reviewer` and `--date`.
- Specify `--iverilog-bin <作業dir>/iverilog13/bin` for `runsim.py`.
- The workflow uses `tools/matching_kit/workflows/gap.js` and passes `args = {repo, work: "<作業dir>", pdf, iverilogBin, parts, verifyOnly?, resume?}`.

<a id="この作業で決めたこと判明したこと"></a>

## What we have decided and discovered in this work.

- `validate()` requires mapped tests to cite the requirement's clause in `:lrm:` (`tools/behavior_coverage.py:113`). The existing test which is not cited cannot be matched (the reference person has reported many cases where "the test can be matched by adding a citation", but the test input has changed and the evidence is old, so this time it is ignored).
- Existing-test mapping has a low acceptance rate (153 requirements across 9 segments). The main reason is that there is no existing test with the necessary stimulus. Switched to creating new tests.
- During the 2026-10-24 ledger review, reorganized Annex B (248 reserved words) and the version-specific keyword rows in 22.14.x as tests of standard violations (versions explicitly specified with `kind=error` and `begin_keywords`). Mappings can be added by writing a standard-violation test for each reserved word; a generator is inexpensive. F (formal semantics) and 34 (protective envelope) are dismissed. p14 (22.14.2–22.14.6) is not started. Resolved 27 interpretation issues; 19 issues covering 21 rows remain pending ([requirement-extraction.md](requirement-extraction.en.md)).
- The annex-header tests (24 tests for `tests/ch36/test_vpi_user_h_*`, `test_sv_vpi_user_h_*`, `test_vpi_compatibility_h_*`, and `tests/ch35/test_svdpi_h_*`) underwent 3 rounds of independent verification, resulting in adoption of 1,081 requirements. Rejected or deferred: rows containing usage rules or value semantics (DELAY-FIELD, members of VALUE / ARRAY, STEP-STRUCT, L.1 INCLUSION, SIZE-TYPES, TIME, VECTOR, STRENGTH, SYSTF, etc.); I.3 SCALARS (a gap in `#if`; test corrected but not reverified); I.3 UNSIGNED (compiler-dependent undefined behavior, rejected by coordinator decision); and I.3 MASK (contains unobservable conditions).
- The Icarus 13.0 header defines only 218 of the 855 constants in K.2/M.2; every defined value is correct. Neither simulator has `vpi_compatibility.h`. In Verilator 5.052, `svdpi.h` makes `SV_MASK` `~(0xffffffffU << (N))` (unsigned). A draft for `docs/simulator-differences.md` is in `notes/annex-simdiff.md`.
- Standard-header findings (validation agent's report): the non-Linux branch of K.2 / I.3 provides only `<sys/types.h>`, so macOS lacks `uint64_t` and related definitions. `1800v2017` / `1800v2023` in L.2 defines `VPI_COMPATIBILITY_VERSION_1800v2012` as empty, causing the later `#elif` to produce an error.

<a id="再開手順"></a>

## Resumption procedure

1. The `git log` checks whether the uploaded portion has been committed. Restore the `parked/` tests to `tests/` (`rsync -a <作業dir>/parked/tests/ tests/`). Also verify that the working directory still exists. The annexes (`proposals/annex`), mappings for wave1 / wave2, and new tests for p20 have been integrated, so do not repeat validation or integration (`merge.py` skips already integrated proposals).
2. Proceed in order of increasing cost. Validate first. Validate pending proposals (3,967) and new tests using `verifyOnly` of `wf-gap.js`. `Workflow({scriptPath: "tools/matching_kit/workflows/gap.js", args: {repo, work: "<作業dir>", pdf, iverilogBin: "<作業dir>/iverilog13/bin", verifyOnly: true, parts: [...]}})` 。 For `parts`, choose roughly 8 sections per round 1 from the `pending_proposals > 0` range in `parts.json`. p20 is completed to verification and import, while p04 is created but not verified. At a requirement-level acceptance rate of at least 57%, validation alone exceeds 50%.
3. If 50% is not reached, resume the creation task with `resume: true` (without verifyOnly). At interruption, the authors had stopped with every segment unfinished.
4. Consolidation (after full verification):
   1. Delete tests assessed defective by `testverdict` and tests without assessments, limited to untracked files. `.expected` / `.c` / also supporting files). Treat the 13 tests with lint violations the same way.
   2. Run the remaining new tests with `run_icarus.py --iverilog-bin <作業dir>/iverilog13/bin` and `run_verilator.py --all --seed 1/73` (`OBJCACHE=ccache`), and compare the results with the descriptions in `:oracle:`. Correct disagreements in `:oracle:` and rerun afterward because inputs change.
   3. Save the record run as `coverage/results/<名前>-20261023-icarus13.json`, `-verilator-seed1.json`, and `-verilator-seed73.json` (do not overwrite the existing full-run results).
   4. Run `python3 tools/matching_kit/merge.py <作業dir>/proposals/<wave> --reviewer '<モデル名> (AI); not an independent human review' --date YYYY-MM-DD` for each directory, including `annex`. Integration accepts only unmapped requirements, so entry 2 onward for the same requirement displays SKIP; this is expected.
   5. Run `requirement_matching.py --update`, `behavior_coverage.py --update --require-source-reviewed --history coverage/behavior-history.json`, `suite_stats.py --update`, `suite_catalog.py --update`, and `coverage_depth.py --update`.
   6. Update `docs/simulator-differences.md` after checking `notes/*-simdiff.md`, README, the result-file list in `coverage/README.md`, a new result report and the main summary in `docs/nightly-results.md`.
   7. Pass all checks from the previous handoff before committing.

<a id="費用の目安"></a>

## Cost estimate

A group of 1 comparison agents and 1 verification agents uses approximately (30–60) × 10,000 tokens (`subagent_tokens` based on output). 1 verification workers handling about 200 proposals require approximately 15×10,000 to 40×10,000 tokens. Annex reverification used approximately (30–50) × 10,000 tokens per 1 round(s). Parallel work consumes resources quickly, so launch only a limited number of segments.
