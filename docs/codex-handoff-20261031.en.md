<a id="codexへの引き継ぎテスト側指摘の対応とクロス検証2026-10-31"></a>

# Codex handoff: test corrections and interaction verification (2026-10-31)

[English](codex-handoff-20261031.en.md) / [日本語](codex-handoff-20261031.md)

External-state check: 2026-10-30 21:05 UTC (10-31 06:05 JST). Local state, interaction verification and documentation updated on 2026-11-01 JST. The external-state check date, including Issue status, remains the date above. GitHub Actions and the published Nightly were rechecked on 2026-11-01 JST. This material hands off the `kirimasim-tests` work. Unless otherwise stated, run commands from the root of the `kirimasim-tests` repository.

The previous maintainer's documents are also retained. Their scopes overlap, so read both.

- [Interaction-verification handoff (2026-10-30)](claude-code-handoff-20261030-cross-verification.en.md): adding interaction models, saved runs and investigating inside mismatches.
- [Requirement-coverage handoff (2026-10-28)](handover-20261028.en.md): the requirement registry and the coverage denominator.
- [History](history.md): past measurements and work records. Keep only current information in README.

<a id="1-最初に把握すること"></a>

## 1. What to understand first

- The latest test additions are based on main `7cf35321`. Following 36 mailbox/class-handle cases, 27 event-variable rebinding and wait cases were added, for 63 additional cases in total. The additions were committed together with their generators, tests, saved runs and related documents. Check commit/push status using `git status`, `git log -1` and `git rev-parse origin/main`. The simulator implementation was not changed. The execution worktree for kirimasim was synchronized with upstream main `ddf48e2b0436` and built. Distinguish the target commit and execution scope when checking GitHub Check, Nightly and local validation. Local validation passed 552 tool unit tests and 11 consistency checks; metadata validation found 0 new problems (395 known problems). Each model's [Design and verification records](interaction-verification.en.md) describes its verification scope and limits.
- The verified [Nightly](https://github.com/kurochan001/kirimasim-tests/actions/runs/41141958886) covers 9,203 tests in suite `73af6e95`; the 5 environment and publishing succeeded. This record predates the current main. Each runner targets 8,935 tests, excluding 268 formal tests. See [Publication record and revisions](nightly-results.en.md#確認例2026年10月31日の公開).
- The suite is 10,105 and the generated 3,668. The short‐time execution of cross‐functionality is performed in the 55 model and 2,355 case.
- With kirimasim `ddf48e2b0436` matched to upstream immediately before execution, the full interaction selection has 2,170 pass, 179 unsupported and 6 existing fail results. The 27 event-rebinding cases encounter unsupported event-value operations; all 36 mailbox cases encounter unsupported types. Input hashes and result categories for the preceding 2,328 cases are unchanged. Class-method results are 18 pass and 18 unsupported. For fixed Verilator, 11 typed known-value cases matched with both seeds, 1 typeless case was known, and 24 4-state cases were excluded. For event rebinding, all 27 cases also have known build failures with fixed Icarus / Verilator; no fixed oracle was added. All 27 syntax and semantic analysis cases for kirimasim succeeded, and the independent reference model agreed on 648 legal lines. Registered Clause 6 × Clause 15 and Clause 8 × Clause 15, bringing the total to 86 chapter pairs and 46 models with their full selection PASS. See [Event-rebinding design and saved execution](interaction-verification.en.md#イベント変数の再結合と登録済み待機の保持).
- Requirement coverage is 89.31% (10,983/12,298) for test design and 77.57% (9,539/12,298) for verified execution. Execution verification is the union of saved evidence from Icarus Verilog 13.0, Verilator 5.052, SymbiYosys and Ghost. These interaction tests add no requirement mappings; the requirement denominator and verification rates are unchanged.
- Planned coverage, Check success, matching test results and requirement coverage are different measures. Keep these measures distinct.

<a id="2-ユーザーの方針と作業上の注意"></a>

## 2. User's policy and precautions during operation

- Report progress and results concisely in Japanese. The situation is shared even during long verification.
- Commit and push to main only when requested. The established workflow validates changes before integrating them.
- Immediately before running a simulator, fetch/check the latest commit and build that version. Do not use the old build as it is. Record that the build revision matches the upstream commit.
- kirimasim and Lyra are separate simulators. The results of kirimasim are not reported as the results of Lyra.
- Icarus 13.0 and Verilator 5.052 are the fixed oracle-reference releases. Do not reinterpret a development-version match as an oracle confirmation for these fixed releases. To check Verilator, run the 2-state tests separately with seeds 1 and 73.
- Preserve existing tests, expected values, oracles, and historical execution evidence. Do not make unsupported behavior the expected successful result. Do not remove legal factors to improve the pass rate.
- Do not read the implementation source of GPL / LGPL software such as Icarus and Verilator. Do not copy reproducer code from other projects. Verify against the standard, independent calculations, and execution results.
- Commercial SystemVerilog simulators have not been used for verification. We will continue to avoid running or comparing them and analyzing their behavior from output or diagnostics. Do not reuse third-party commercial simulator results to construct expectations or make implementation decisions. Do not assume keeping results private avoids contractual issues. Base verification on public standards and independent reference models. Distinguish this policy from asserting the prohibited scope of any particular agreement. See [FAQ policy and examples of publicly available agreements](faq.en.md#8-商用シミュレータでの確認状況).
- Do not include commercial simulator output or diagnostics in Issue bodies, comments, attachments, images, waveforms or external links. This also covers anonymized excerpts, summaries and third-party results. Base reports on standard clause numbers and independently authored reproducers. Refer contributors to [Issue posting policy](faq.en.md#q45-issueに商用シミュレータの出力診断を載せてもよいですか) and the English/Japanese Issue forms.
- Differences between Icarus and Verilator are not reported upstream, but are recorded in [Fixed-version difference list](simulator-differences.md).
- Do not put reproduced standard text/figures/tables, absolute home paths, personal information, or private material in public files. Ghost is an alias for an unreleased simulator. Do not publish its real name, version, execution profile or paths.
- Do not begin a comment line with `Verilator`, because Verilator interprets it as a directive. `tools/lint_metadata.py` detects this as `verilator-comment`.
- For tests without Icarus / Verilator oracles, the runner classifies disagreements as known rather than fail.
- Before modifying the simulator (`../kirimasim`), read that repository's CLAUDE.md. Rules include defining semantics in one place, avoiding branches based on symptom shape, generating matrix tests of mechanisms, and running `tools/local_ci.py` before pushing. Another session is working in that checkout. Use an isolated worktree rather than modifying it directly.

<a id="3-2026-10-31に完了した作業f0908394"></a>

## 3 . Work completed on 2026-10-31 (`f0908394`)

Reexamined the 432 cases classified as “test-side issues” by the full Ghost run (an audit in another repository), plus individual reports #36–#39, against IEEE 1800-2023. Corrected approximately 90 tests while retaining tests that already follow the standard.

- Main categories corrected
  - Illegal constructs within nominally legal tests include defaults on non-ANSI formals, literal actuals inherited through ref, `binsof` as a bin index, hierarchical references using a structure variable as an enclosing scope, interconnect on variable ports, 3-value delays on `buf`, properties following `##1`, degenerate sequences and empty actions in `; else`.
  - Races whose results the standard does not define (observation at the same time as a UDP-delayed change, a program's implicit `$finish` occurring before reporting, and a race between a continuous assignment at time 0 and `@(v)`).
  - Incorrect expectations include int occupying 8 digits under `%h`, classes as bit-stream types, the warning and 0 required by Annex N for nonpositive means, and `always a` starting an attempt on every tick.
  - 11 C tests did not account for the shared `vpi_get_str()` buffer in VPI (38.11).
  - Added standard-derived common expected output to 21 tests that previously had only Verilator-specific output.
  - Relaxed diagnostic regular expressions within the formatting freedom granted by 20.10: severity and `file:line` may appear on the same or following line, in either order.
- Oracle withdrawal: removed `iverilog@13.0` from 7 negative tests that merely reject unsupported syntax (under the “Determining expected output” rule in README). Similar issues remain in ch8 and elsewhere; they are recorded in `oracle_issue` of `coverage/test-matching-reviews.json`.
- #22: make `tools/run_ghost.py` exclude `:type: formal` as well, and align `tools/test_runner_selection.py` with README.
- #29–#35 list unimplemented Ghost operations. They were closed with explanations because they were not test defects.
- Reactive ordering: reapplied the test correction from the unmerged branch (4.5. Icarus 13.0 reproduced the result in all 5 runs, so `iverilog@13.0` was registered).
- Evidence: ran 108 cases with changed inputs on Icarus 13.0, and 101 2-state cases on Verilator 5.052 with seeds 1 and 73, saving results in `coverage/results/issues-20261031-*.json`. All cases carrying an applicable oracle matched.
- Requirement mappings: rereviewed every record affected by the changed tests. Removed the 3 cases that no longer held (packed array typespec in 37.25, the load on net bit in 37.46, and ack in I.3) from the supporting evidence, and recorded the reasons in `coverage/behavior-baseline.json`.
- Updated 1 fingerprint in `tools/sva_reference/fixtures/m4_deferred.json` following the ch16 test correction.

<a id="本体kirimasim側"></a>

### Simulator implementation (kirimasim)

- Fixed sign extension of set elements in inside and case inside. Following 11.8.1 and 11.8.2, consolidated the logic in one place in `src/front/lower_expr.cpp` (`Lowerer::memberMatch`) so that array elements are extended according to the common type's signedness.
- Pushed branch `fix/inside-array-element-extension` (`e2912de7`). No PR was created, and the change has not been merged into main. The branch is based on `745388cd`, while upstream main was `83e89bf5` at verification time. Synchronize it with upstream before integration.
- Added generated matrix tests for the mechanism using `tools/gen_inside_member_matrix.py`. `tools/local_ci.py` passed every check.
- This fix resolves 2 disagreements among 1,426 cross-check cases (before: 1,368 pass, 2 fail; after: 1,370 pass, 0 fail; 56 unsupported cases unchanged). These results have not yet been saved as execution evidence. After the change is merged upstream, build the latest main and save `coverage/interaction-results/cross29-kirimasim-<commit>.json` under a new filename.

<a id="4-未着手の課題"></a>

## 4. Outstanding work

<a id="41-新しい個別指摘-4044"></a>

### 4.1 New individual reports #40–#44

Follow-up: [Review record for issues #40–#44](issues-40-44-review-20261031.en.md) records the post-handoff review, corrections and saved execution results. The following describes the unverified reports and proposed procedure at the time of the handoff.

Each report alleges that the expected result or stimulus of 1 test violates the standard, and identifies the clause and relevant lines. These reports have not been verified. Treat each report as an allegation to verify. Compare the clause text with the test yourself.

| Issue |Target|Summary of the unverified report|
| --- | --- | --- |
| [#40](https://github.com/kurochan001/kirimasim-tests/issues/40) | `ch14/test_syntax_clocking_drive_forms` |Expects 2–5 for the 1-bit `d` (truncation of 10.7 to the left-hand-side width)|
| [#41](https://github.com/kurochan001/kirimasim-tests/issues/41) | `ch11/test_A_extra_specparam_range` |A constant expression containing specparam is assigned to localparam (6.20.5).|
| [#42](https://github.com/kurochan001/kirimasim-tests/issues/42) | `ch14/test_clocking_default_skew` |An expectation reads the new value before the update in Re-NBA (14.16). It contradicts `test_clocking_future_drive_in_re_nba`, which addresses the same rule.|
| [#43](https://github.com/kurochan001/kirimasim-tests/issues/43) | `ch37/test_vpi_immediate_assertion_parts` |It identifies unlabeled call statements using `vpiName`, although 37.60 detail 1 specifies NULL.|
| [#44](https://github.com/kurochan001/kirimasim-tests/issues/44) | `ch4/test_pli_phase_chain_after_nba_and_end_write` |It requires `cbReadWriteSynch` to occur after the NBA update, although 38.36.2 permits either order.|

Use the same procedure as for #36–#39.

1. Read the clause text with `tools/requirement_source.py --show`, then read the test and its `.expected`.
2. Look for other suite tests that interpret the same rule differently (#42 itself identifies one). If tests contradict each other, use stimulus that gives the same result under both interpretations, or correct one with an explanation.
3. After the correction changes inputs, rerun the fixed releases and decide whether to retain or revoke each oracle.
4. Update the fingerprints, evidence and observations in the requirement mappings (`coverage/behaviors.json` and `coverage/test-matching-reviews.json`). See §6.3 for the procedure.

<a id="42-開いたままのissue判断が必要"></a>

### 4.2 Open Issues requiring a decision

- [#24](https://github.com/kurochan001/kirimasim-tests/issues/24) ： `ch35/test_35_rest_noncontext_export_error` 。 The standard defines calls to exports from noncontext imports as unpredictable or undefined, so no common expected output, exit code or message can be derived. The expected result still uses wording from 1 tool. A decision is needed on whether to redesign or retire it.
- [#27](https://github.com/kurochan001/kirimasim-tests/issues/27)：
  - `ch35/test_35_rest_deprecated_dpi_diagnostic` 。 35.5.4 allows either a warning or an error, but the test format cannot express acceptance of either outcome. The test format or runner rules need an extension.
  - Illegal-design judgment requires `file:line:` on 1 line. The standard does not prescribe diagnostic formatting. One proposal is to relax `judge_illegal` in `tools/suite_results.py` to accept a non-word character immediately after `file:line`. Because the impact is broad, decide the policy before changing the affected cases together.
- [#28](https://github.com/kurochan001/kirimasim-tests/issues/28)：
  - 14 cases in the `assign_wait` family of `generators/scheduling.py`. Evaluation of the continuous assignment at time 0 races with the start of `@(v)`; the standard permits either order. Correct the generator; do not edit generated files directly.
  - Interpretation-sensitive tests include port coercion (23.3.3.1, 23.3.3.7), compilation-unit grouping (3.12.1), the config `use` clause form (grammar A.1.5 versus example 33.4.3), x/z in bins (19.5.4 and 19.5.7 b) 3), empty checker outputs (17.3), parameter assignment without an override, program/interface relationships (37.9 and 37.10 d3), and whether `$coverage_*` scope permits interface instances or packages (40.3.2.1).

<a id="43-その他の残件"></a>

### 4.3 Other remaining work

- Restoring Ghost results is complete: import [Complete Ghost results for 2026-10-31](../coverage/results/ghost-local-20261031.json) saved with upstream-main `80f19e33` and recalculate requirement coverage. Subsequently imported [Complete strict LRM results](../coverage/results/ghost-local-20261031-strict.json) from upstream-main `bfa43fea`; execution coverage at that integration point was 77.47% (9,527/12,298). See §1 for current values. This is the union of successful saved executions across simulators, not the result of kirimasim alone. See [Description of Nightly](nightly-results.en.md) and `coverage/README.md` for integration rules. Also incorporated upstream main's `a3edb14a` corrections to variable/task lifetimes in existing tests, together with [Ghost execution of the corrected tests](../coverage/results/test-fixes-20261031-ghost.json), fixed-release executions and requirement mappings. Input hashes and results for the 1,988 selected interaction cases are unchanged.
- Problems remain in Ghost (not in the tests. Recorded only): checks that produce warnings in the default mode; diagnostic locations on separate lines or using `(file:line)`; `$finish(2)` statistics/coverage notes mixed into stdout; and unsupported diagnostics without severity words. Some issues may be resolved by improving the execution profile.
- slang (shared by kirimasim, Lyra, and Ghost): rejects a coverpoint name in a set expression, contrary to the text of 19.5.1.2. Not reported.
- Draft streaming-defect report to slang: `../kirimasim-tests-work/slang-issue-streaming-20261028/`. Submit only after the previously submitted [slang #2072](https://github.com/MikePopoloski/slang/issues/2072) has been processed. It was still OPEN when checked. Do not link to kirimasim-tests.
- Next interaction candidates include changed task-argument indices and visibility on return, queue-element reference lifetimes, and factor modeling of event OR and `iff`. See [Principles and practical procedure](interaction-verification-method.en.md) §5 for the procedure. Addendum: added 27 cases for events OR and `iff` as model 30. See [Model design and execution records](interaction-verification.en.md#イベントorと項ごとのiff条件). Added 60 cases for queue-reference lifetimes as model 31. See [Design and execution records](interaction-verification.en.md#キュー要素への参照と要素の寿命). Argument-index binding and visibility for input/ref/const ref were added as model 32 with 36 cases. See [Design and execution records](interaction-verification.en.md#引数の結合と呼出し後の添字変更). Remaining candidates include when output/inout evaluates its return destination, reference lifetimes for dynamic and associative arrays, and event OR with different edge types. Resolve disputed interpretations of the standard before choosing an expected result that favors one interpretation. Added 36 cases for clocking-input sampling as model 33. See [Design, current-build results, fixed-release oracles and fault injection](interaction-verification.en.md#クロッキング入力のサンプリングと参照経路). The suite reached 33 models and 1,585 selected cases; on checked revision `55ce80b9d5bc`, new cases had 24 pass and 12 unsupported, with totals 1,521 pass, 62 unsupported and 2 existing fail results. `#0` and virtual modports remain unsupported. See [0-cell triage](chapter-cross-triage.en.md) for the next chapter-pair candidates. Added assertion sample/action observation and container wait as models 34 and 35, with 36 cases each. On checked revision `3a31b060c158`, [Assertions](interaction-verification.en.md#アサーションのサンプル値とactionのライブ値) has 36 unsupported results, while [Container waits](interaction-verification.en.md#コンテナ変更とwaitの起床) has 36 passes. At that point there were 35 models and 1,657 selected cases; overall, 1,557 passed, 98 were unsupported, and the existing 2 failures remained, with 9,407 cases in the normal suite. Rerun when concurrent assertion support has progressed. Also recorded fixed Verilator differences in live values during simultaneous NBA updates. Added 36 cases for class-method callees, recursion, and input/ref/const ref as model 36. See [Design and execution records](interaction-verification.en.md#クラスメソッドの呼出し先と再帰引数). At that point, there were 36 models, 1,693 selected cases and 9,443 tests in the ordinary suite. In the latest compared version `3a31b060c158`, 36 new cases are unsupported because of class types; overall, 1,557 passed, 134 were unsupported, and the existing 2 failures remain. Registered Clause 6 × Clause 8 and Clause 8 × Clause 13 in finite models, bringing the total to 49 chapter pairs. Update the saved execution once class-type and inheritance support has progressed. Do not count a fixed-release success as a kirimasim success. Added 36 cases for function return from loops and instance/package state as model 37. See [Design and execution records](interaction-verification.en.md#ループからの関数returnと状態の共有範囲). At that point, there were 37 models, 1,729 selected cases and 9,479 tests in the ordinary suite. On checked revision `3a31b060c158`, every 36 new case was PASS; totals were 1,593 pass, 134 unsupported and 2 existing fail results. Inputs and results for the preceding 1,693 cases are unchanged. Registered Clause 12 × Clause 13 and Clause 13 × Clause 26, bringing the total to 51 chapter pairs and 31 models with their full selection PASS. Added 36 cases for loop-assignment update order and module/interface independence as model 38. See [Design and execution records](interaction-verification.en.md#ループ代入の更新順序とインスタンスの独立性). At that point, there were 38 models, 1,765 selected cases and 9,515 tests in the ordinary suite. On checked revision `95eefebeb952`, every 36 new case was PASS; totals were 1,629 pass, 134 unsupported and 2 existing fail results. Inputs and results for the preceding 1,729 cases are unchanged. Registered Clause 10 × Clause 12 and Clause 10 × Clause 25, bringing the total to 53 chapter pairs and 32 models with their full selection PASS. Added 36 cases for implicit comb/latch sensitivity and value retention as model 39. See [Design and execution records](interaction-verification.en.md#暗黙の感度リストとラッチ保持). At that point, there were 39 models, 1,801 selected cases and 9,551 tests in the ordinary suite. On checked revision `95eefebeb952`, every 36 new case was PASS; totals were 1,665 pass, 134 unsupported and 2 existing fail results. Inputs and results for the preceding 1,765 cases are unchanged. Registered Clause 9 × Clause 25 and Clause 13 × Clause 25, bringing the total to 55 chapter pairs and 33 models with their full selection PASS. For fixed Verilator, both seeds reproduced evaluation counters reaching 512 instead of expected 1 at time 0 in 7 known-value cases, so no Verilator oracle was registered for this model. All 36 cases matched with Icarus 13.0. Added 36 cases for type/constant name lookup across generate hierarchies, packages and local declarations as model 40. See [Design and execution records](interaction-verification.en.md#generate階層でのpackageと局所宣言の名前探索). At that point, there were 40 models, 1,837 selected cases and 9,587 tests in the ordinary suite. On checked revision `4b58e29f8c94`, every 36 new case was PASS; totals were 1,701 pass, 134 unsupported and 2 existing fail results. Inputs and results for the preceding 1,801 cases are unchanged. Registered Clause 10/23/26 × Clause 27, bringing the total to 58 chapter pairs and 34 models with their full selection PASS. Added 36 cases for default-argument evaluation and hierarchical calls as model 41. See [Design and execution records](interaction-verification.en.md#デフォルト引数と階層呼出しのスコープ). At that point, there were 41 models, 1,873 selected cases and 9,623 tests in the ordinary suite. On checked revision `4b58e29f8c94`, every 36 new case was PASS; totals were 1,737 pass, 134 unsupported and 2 existing fail results. Inputs and results for the preceding 1,837 cases are unchanged. Registered Clause 13 × Clause 23 and Clause 23 × Clause 25, bringing the total to 60 chapter pairs and 35 models with their full selection PASS. With fixed Icarus, 36 cases match for both seeds; with fixed Verilator, 12 known-value cases match for both seeds. Added 13 cases for module/interface/package synchronization through event arguments as model 42. See [Design and execution records](interaction-verification.en.md#イベント引数によるスコープ間の同期). At that point, there were 42 models, 1,886 selected cases and 9,636 tests in the ordinary suite. On checked revision `4b58e29f8c94`, every 13 new case was PASS; totals were 1,750 pass, 134 unsupported and 2 existing fail results. Inputs and results for the preceding 1,873 cases are unchanged. Newly registered Clause 4/13/25/26 × Clause 15, bringing the total to 64 chapter pairs and 36 models with their full selection PASS. With fixed Verilator, 3 ref plus normal-trigger cases match for both seeds; 10 cases are saved as differences because they do not wake at the expected time. Fixed Icarus cannot build any of the 13 cases. Event-variable rebinding remains unsupported in the latest kirimasim and remains a candidate. Added 63 cases for continuous-assignment delays and short-pulse rejection as model 43. See [Design and execution records](interaction-verification.en.md#連続代入の遅延と短パルスの除去). At that point, there were 43 models, 1,949 selected cases and 9,699 tests in the ordinary suite. On checked revision `4b58e29f8c94`, every 63 new case was PASS; totals were 1,813 pass, 134 unsupported and 2 existing fail results. Inputs and results for the preceding 1,886 cases are unchanged. Registered Clause 10 × Clause 28 and Clause 6 × Clause 28, bringing the total to 66 chapter pairs and 37 models with their full selection PASS. For the fixed Icarus, 57 cases match; 6 differences are saved with the expected values preserved. For fixed Verilator, 17 of 21 known-value cases matched with both seeds; 4 cases at width 65/129 did not build. Added 39 cases for package imports and wildcard port connections as model 44. See [Design and execution records](interaction-verification.en.md#packageのimportとワイルドカードポート接続). At that point, there were 44 models, 1,988 selected cases and 9,738 tests in the ordinary suite. On checked revision `4b58e29f8c94`, every 39 new case was PASS; totals were 1,852 pass, 134 unsupported and 2 existing fail results. Inputs and results for the preceding 1,949 cases are unchanged. Registered Clause 23 × Clause 26, bringing the total to 67 chapter pairs and 38 models with their full selection PASS. Fixed Icarus matched 38 cases; saved build failures cover 1 cases unable to bind `.p` through wildcard imports. Fixed Verilator differed for all 13 known-value cases with both seeds; the recorded difference makes all 1 defaults, including controls, become 0. Added 36 cases combining types and ranges in memory-file I/O as model 45. See [Design and execution records](interaction-verification.en.md#型と範囲を組み合わせたメモリファイル入出力). At that point, there were 45 models, 2,024 selected cases and 9,774 tests in the ordinary suite. On checked revision `4b58e29f8c94`, every 36 new case was PASS; totals were 1,888 pass, 134 unsupported and 2 existing fail results. Inputs and results for the preceding 1,988 cases are unchanged. Registered Clause 6 × Clause 21, bringing the total to 68 chapter pairs and 39 models with their full selection PASS. Fixed Icarus matched 35 cases and hit an internal compiler assertion in 1 65-bit bit enumeration cases; fixed Verilator matched 11 of 12 known-value cases with both seeds and differed in 1 reverse-read cases. Added a practical method using independent inputs to detect write/read errors that would otherwise cancel each other out.

Added 18 cases for program termination and descendant-process cancellation as model 46. See [Design and execution records](interaction-verification.en.md#program終了と子孫プロセスの取消し). At that point, there were 46 models, 2,042 selected cases and 9,792 tests in the ordinary suite. On checked revision `4b58e29f8c94`, every 18 new case was PASS; totals were 1,906 pass, 134 unsupported and 2 existing fail results. Inputs and results for the preceding 2,024 cases are unchanged. Registered Clause 9 × Clause 24 and Clause 15 × Clause 24, bringing the total to 70 chapter pairs and 40 models with their full selection PASS. With fixed Icarus, 6 natural-termination cases mismatch and 12 cases report $exit as undefined. Fixed Verilator cannot build any of the 18 cases with either seed because program declarations within modules are unsupported. Expected results are retained and diagnostics are saved. Added a procedure that combines progress observations before/after startup with an independent control using the same wait condition to check cancellation. Test-suite main was updated through `efd160c4`, which saves the latest complete Ghost results, while preserving the previous uncommitted changes.

40 cases for default_nettype and port-net resolution were added as model 47. See [Design and execution records](interaction-verification.en.md#default_nettypeとポートnetの解決). At that point, there were 47 models, 2,082 selected cases and 9,832 tests in the ordinary suite. On checked revision `4b58e29f8c94`, every 40 new case was PASS; totals were 1,946 pass, 134 unsupported and 2 existing fail results. Inputs and results for the preceding 2,042 cases are unchanged. Registered Clause 6 × Clause 22 and Clause 22 × Clause 23, bringing the total to 72 chapter pairs and 41 models with their full selection PASS. Fixed Icarus matched 14 wire/tri cases; saved differences cover 26 wired-AND/OR cases. All cases are 4-state tests, leaving 0 cases eligible for fixed Verilator. Neither seed started a simulation. Added a procedure comparing a directive's affected objects, explicitly declared exceptions and objects after resetting the setting, using the same stimulus.

Added 36 cases for interfaces created by generate and modport connections to 2026-11-01 as model 48. See [Design and execution records](interaction-verification.en.md#generateで生成したinterfaceとmodport接続). At that point, there were 48 models, 2,118 selected cases and 9,868 tests in the ordinary suite. On checked revision `4b58e29f8c94`, every 36 new case was PASS; totals were 1,982 pass, 134 unsupported and 2 existing fail results. Inputs and results for the preceding 2,082 cases are unchanged. Registered Clause 25 × Clause 27 and Clause 6 × Clause 25, bringing the total to 74 chapter pairs and 42 models with their full selection PASS. Fixed Icarus cannot build any of the 36 cases because it reports syntax errors in interface-port declarations. For fixed Verilator, all 12 known-value cases agreed across both seeds; the 24 X/Z cases are outside the scope of this check. Added a practical procedure that uses 13 known stimuli to distinguish 780 bit positions on the selected and control sides and checks the connection tags.

On the same day, added 36 cases for program event regions and nonblocking assignments as model 49. See [Design and execution records](interaction-verification.en.md#programのイベント領域と非ブロッキング代入). At that point, there are 49 models, 2,154 selected cases and 9,904 tests in the ordinary suite. On checked revision `4b58e29f8c94`, every 36 new case was PASS; totals were 2,018 pass, 134 unsupported and 2 existing fail results. Inputs and results for the preceding 2,118 cases are unchanged. Registered Clause 4/6/10 × Clause 24, bringing the total to 77 chapter pairs and 43 models with their full selection PASS. With fixed Icarus, 36 cases fail to match for both seeds; with fixed Verilator, 12 known-value cases fail to match for both seeds. The 24 X/Z cases are outside the scope of Verilator. Saved separately the 1-bit control output, where the stage value at notification remains old despite reservation-count progress, and a later snapshot. Added a practical procedure that observes reservation-count progress separately from completion of the actual data update.

On the same day, added 41 cases for config parameter settings and generate shape as model 50. See [Design and execution records](interaction-verification.en.md#configのパラメータ設定とgenerateの形状). At that point, there are 50 models, 2,195 selected cases and 9,945 tests in the ordinary suite. On checked revision `4b58e29f8c94`, 41 new cases produced 37 pass and 4 fail; totals were 2,055 pass, 134 unsupported and 6 fail (2 existing plus 4 new). Inputs and results for the preceding 2,154 cases are unchanged. Registered Clause 23 × Clause 33 and Clause 27 × Clause 33, bringing the total to 79 chapter pairs. The new model is incomplete, so the number of models with PASS for every selected case remains 43. Fixed Icarus and both seeds of Verilator rejected all 41 cases during the build. The next implementation-investigation candidate is a difference where combining defparam with config `use #()` fails to reset values to their defaults. Saved a minimal comparison that matches when the same value is reset with 4 explicit empty braces, including source, output and exit code, under fault-injection record JSON. Expected results were not changed and cases were not excluded to hide failures. Implementation-internal investigation and Issue submission have not been performed.

On the same day, added 25 cases for UDP array connections and drive strengths as model 51. See [Design and execution records](interaction-verification.en.md#udpの配列接続と駆動強度の解決). At that point, there are 51 models, 2,220 selected cases and 9,970 tests in the ordinary suite. On checked revision `4b58e29f8c94`, every 25 new case was PASS; totals were 2,080 pass, 134 unsupported and 6 existing fail results. Inputs and results for the preceding 2,195 cases are unchanged. Registered Clause 28 × Clause 29, bringing the total to 80 chapter pairs and 44 models with their full selection PASS. 1 cases agreed for fixed Icarus; registered the oracle for only those 1 cases and reran them with the final generated artifacts. 24 cases were rejected during the build. All cases are 4-state tests, leaving 0 cases eligible for Verilator. Documented comparisons of isolated drive, competing drives and release, along with individual instance indices outside the observation scope.

On the same day, added 36 cases for states and input transformations of sequential UDP generated by generate, as model 52. See [Design and execution records](interaction-verification.en.md#generateで生成した逐次udpの状態と入力変換). At that point, there are 52 models, 2,256 selected cases and 10,006 tests in the ordinary suite. Rebuilt `3550d77474f1` against upstream immediately before the full regression; all 36 new cases PASS. Overall results are 2,134 pass, 116 unsupported and 6 existing fail. Inputs for the preceding 2,220 cases are unchanged; 18 existing class-method cases improved from unsupported to pass. The remaining 18 cases in the same model are still unsupported. Prior saved execution files and their summaries are unchanged. Registered Clause 27 × Clause 29 and Clause 6 × Clause 29, bringing the total to 82 chapter pairs and 45 models with their full selection PASS. All 36 cases for fixed Icarus and the 2 target cases for fixed Verilator agreed across both seeds. The 34 4-state cases are outside the scope of Verilator. Documented retaining state while inputs change, running the control later, preparing all-1 state before unknown inputs, and distinguishing 258 position histories.

On the same day, added 36 cases for interface-header imports and package-function type conversion as model 53. See [Design and execution records](interaction-verification.en.md#interfaceヘッダのimportとpackage関数の型変換). At this addition, there were 53 models, 2,292 selected cases and 10,042 tests in the ordinary suite. Detected an upstream main update before the full regression, rebuilt `4fb5f6b1aec8`, and obtained PASS for all 36 new cases. Overall results are 2,170 pass, 116 unsupported and 6 existing fail. Inputs and result classifications for the preceding 2,256 cases are unchanged. Registered Clause 25 × Clause 26 and Clause 6 × Clause 26, bringing the total to 84 chapter pairs. 46 models have PASS for every selected case. All 36 cases for fixed Icarus and the 12 target cases for fixed Verilator agreed across both seeds. The 24 4-state cases are outside the scope of Verilator. A fault that bypasses type conversion passed 55 known-input rows and was detected by the first unknown input. Added comparisons that distinguish declaration scope from call-site scope, and observations using intermediate and unknown values to identify processing order.

<a id="5-実行環境"></a>

## 5. Execution environment

<a id="51-シミュレータ"></a>

### 5.1 Simulators

|Simulator|Purpose|Location and conditions|
| --- | --- | --- |
| Icarus Verilog 13.0 |Fixed-release oracle checks|`../kirimasim-tests-work/50percent-20261023/iverilog13/bin` (verify the version)|
| Verilator 5.052 |Fixed-release oracle checks|On `PATH`. 2-state tests only; seeds 1 and 73|
| kirimasim | Current implementation checks | `../kirimasim-tests-work/cross30-event-iff-core` (last recorded build: `ddf48e2b0436`; fetch upstream and rebuild immediately before execution) |
| Lyra |Comparison|x86-64 Linux only. Pass the actual commit to `run_lyra.py --commit`|
| Ghost |Comparison (unreleased)|A private build and execution profile are required. Keep these outside the repository (README, “Ghost”)|
| SymbiYosys |268 formal tests|`tools/run_sby.py` 。 Specify the verification case with `:formal_case:`|

The standard material is at `../IEEE_1800-2023_SystemVerilog`.

```sh
python3 tools/requirement_source.py --source ../IEEE_1800-2023_SystemVerilog \
  --show 11.4.13 16.12.22 A.8.6
```

<a id="52-ランナー"></a>

### 5.2 Runners

```sh
python3 tools/run_icarus.py --iverilog-bin DIR [-j N] [--json FILE] [TEST ...]
python3 tools/run_verilator.py --all --seed 1 [-j N] [--json FILE] [TEST ...]
python3 tools/run_kirimasim.py --kirimasim BIN [-j N] [--json FILE] [TEST ...]
python3 tools/run_ghost.py --simulator BIN --profile PRIVATE.json --include DIR [TEST ...]
python3 tools/run_sby.py --sby "$SBY_BIN" --json FILE
```

Simulation runners exclude `:type: formal`; the formal runner `run_sby.py` selects formal tests. Only results saved with `--json` constitute execution evidence. Pass the test list as an array or similar structure because `zsh` does not split variable values on spaces. Stop execution if the list is empty. Without positional test arguments, the runner ordinarily selects the whole suite.

<a id="6-変更後の更新確認手順"></a>

## 6. Updating and checking changes

<a id="61-検査ciと同じ範囲"></a>

<a id="61-checks-the-ci-scope"></a>

### 6.1 Checks (the CI scope)

```sh
python3 -m unittest discover -s tools -p 'test_*.py'
python3 generators/generate.py --check
python3 tools/interaction_coverage.py --check
python3 tools/chapter_cross_matrix.py --check
python3 tools/chapter_cross_triage.py --check
python3 tools/combination_gaps.py --check
python3 tools/suite_stats.py --check
python3 tools/suite_catalog.py --check
python3 tools/coverage_depth.py --check --minimum-tests 2
python3 tools/behavior_coverage.py --check --require-source-reviewed
python3 tools/requirement_matching.py --check
python3 tools/lint_metadata.py
python3 tools/generator_catalog.py --check
python3 tools/documentation_languages.py --check
git diff --check
```

The original 29-model handoff recorded 539 passing tool tests, and the later 55-model addition recorded 552. The bilingual-documentation changes bring the tool test inventory to 582. Counts change as tools are added; inspect the result for the revision being checked. Regenerate reports with `--update`, retaining `--minimum-tests 2` for `coverage_depth.py` and `--require-source-reviewed` for `behavior_coverage.py`. Update generated tests with `python3 generators/generate.py`. Refresh the document index with `documentation_languages.py --update`; after reviewing both language versions of handwritten documents, record their fingerprints with that tool's `--record` option.

<a id="62-テストを直したときの順序"></a>

<a id="62-after-correcting-a-test"></a>

### 6.2 After correcting a test

1. Make the smallest correction justified by the cited clause. Explain the clause and rationale in your own words; do not copy standard text. Keep comments within 80 columns and code within 100 columns.
2. Run `python3 tools/lint_metadata.py` and confirm zero new findings.
3. Changed inputs invalidate prior execution evidence. Rerun tests carrying `iverilog@13.0` or `verilator@5.052` in `:oracle:` with that release; use both seeds for Verilator. Remove any oracle token no longer supported by the results and record why. Adding an oracle token requires review.
4. Save evidence under a new filename in `coverage/results/`. Preserve past JSON files.
5. Update the mappings in §6.3, regenerate affected reports and run the checks in §6.1.

<a id="63-要求の対応付けの更新"></a>

<a id="63-updating-requirement-mappings"></a>

### 6.3 Updating requirement mappings

Changing a test's inputs makes records in `coverage/behaviors.json` (`requirements[*].checks[*]`) and `coverage/test-matching-reviews.json` (`reviews[*]`) stale because their `inputs_sha256` values no longer match.

- Find stale records by comparing `inputs_sha256` with `suite_results.input_digest(Path(test))`.
- Reread the stimulus, observations, expected results and cited clauses. If the mapping remains valid, update `inputs_sha256`, `reviewed_on` and `reviewer`. Confirm that each `evidence[*].contains` is a substring of the current file; refresh references to moved lines or changed regular expressions.
- Rewrite `observation` when its meaning has changed, keeping the existing language and tone.
- Remove or hold mappings that no longer hold. Removing support can make `behavior_coverage.py --check` report a coverage regression. Use `--write-baseline --reason "..."` to record the reason in one English paragraph, following the existing records.
- Reassess the baseline when the composition of a collective witness changes.
- `coverage/combination-gaps.json` entries in `bindings[*].inputs_sha256` become stale in the same way. `combination_gaps.py --update` detects them.

Do not merely replace the fingerprint with the current value. Update a mapping only after reviewing its stimulus, observation, expected result and clause.

<a id="7-読む資料"></a>

<a id="7-reading-list"></a>

## 7. Reading list

- [Interaction guide and saved runs](interaction-verification.en.md): registered model definitions, constraints, exclusions and per-model verification records.
- [Principles and practical procedure](interaction-verification-method.en.md): factor modeling, disputed interpretations and adding a model.
- [Interaction coverage report](interaction-coverage.en.md): generated planning and execution summaries.
- [Fixed-version differences](simulator-differences.md): differences between the standard and Icarus 13.0 or Verilator 5.052.
- [Supporting evidence](../coverage/interaction-qualification/README.en.md): minimal examples, fault injection and build fingerprints.
- [Requirement coverage summary](behavior-coverage-summary.en.md) and [registry procedures](../coverage/README.en.md).
- [Test catalog](tests/README.md), [clause index](tests/clauses.md) and [tests per clause](coverage-depth.md), all generated.
- [FAQ](faq.en.md) and [glossary](glossary.en.md).
- README ([English](../README.md) / [日本語](../README.ja.md)): test format, metadata, result judgment, expected-output rules and contribution procedure.
- [History](history.md): past measurements. Do not substitute historical counts for the current README values.

<a id="8-再開時の確認"></a>

## 8. Checks when resuming

```sh
git status --short --branch
git fetch origin
git log -5 --oneline
git rev-list --left-right --count HEAD...origin/main

git -C ../kirimasim status --short --branch
git -C ../kirimasim fetch origin
git -C ../kirimasim log -5 --oneline
git worktree list
```

The simulator repository may contain another session's work and unpushed commits. Check the state before choosing your work scope, and create an isolated worktree if needed.

<a id="codexへ渡す開始指示の例"></a>

## Example starting instruction for Codex

```text
Read docs/codex-handoff-20261031.en.md and compare its records with the current
Git, CI and adjacent kirimasim repository state. Preserve existing expected
results, oracle registrations and history. Build simulators from the latest
commit verified immediately before execution. Distinguish planned coverage,
execution fulfillment, Check/Nightly and requirement coverage. Follow the user's
next instructions and report validation results and remaining work in Japanese.
```

<a id="9-日英ドキュメントの保守"></a>

## 9. Maintaining bilingual documentation

The [document index](README.md) links to both language versions. Keep current structure, counts and commands in the README; put past measurements and work records in history or dated documents. Update both handwritten pages together, review their meaning, numbers and commands, then record their fingerprints. Generate both versions of reports, catalogs and chapter CSV exports from the same canonical data.

See the [translation maintenance guide](../tools/doc_locales/README.md) for procedures and translation provenance. The bilingual-documentation changes do not run simulators or change test inputs, expected results or past execution evidence.
