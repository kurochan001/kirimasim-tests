<a id="品質監査-2026-10-27"></a>

# Quality audit 2026-10-27

[English](quality-audit-20261027.en.md) / [日本語](quality-audit-20261027.md)

> Counts, percentages, and pending statuses in this document record their respective work dates.
> The current value is [Aggregated Summary](behavior-coverage-summary.en.md); the approval history for the denominator and interpretations is in
> See [Results of requirement extraction](requirement-extraction.en.md).

87.31% (F completed) is the quality priority phase after reaching, auditing the semantic validity of the existing link and the strength of the execution evidence, and correcting the defects that can be corrected. No new requirements were added.

<a id="対象と方法"></a>

## Scope and method

- Table: 10,756 requirement / 13,214 link / 5,189 test file
- Mechanical checks: missing tests, evidence strings, excessive cross-chapter mappings and matching clause citations
- Semantic audit: stratified sample of 3 clusters (3 subagents)
- formal: automated audit of reference RTL, cover, and simple transcription across all 259 cases, plus manual review of 30 cases
- Execution: rerun previously unexecuted link targets with Verilator 5.052 (seed 1/73)

<a id="機械検査の結果"></a>

## Automated-check results

|Testing|Result|
|---|---:|
|Missing link end test| 0 |
|Mismatch in evidence `contains`| 0 |
|Tests mapped across more than 4 chapters| 0 |
|Mismatch between `:lrm:` and the requirement clause| 0 / 13,214 |

Mechanical ledger consistency was preserved.

<a id="意味監査の結果"></a>

## Results of semantic audit

<a id="附属書imported80リンクの層化サンプル"></a>

### Annex/imported tests (stratified sample of 80 links)

|Decision|Number of cases|
|---|---:|
| supported | 67 |
| weak | 13 |
| wrong | 0 |
| unverifiable | 0 |

The main weak cases are `const svOpenArrayHandle` in I.3 (affecting 61 links) and tests using only 1 grammar alternatives in Annex A. Since the type and argument order of ABI is strongly observable, the link itself is maintained and the limit is recorded here.

<a id="vpidpiヘッダ22テスト1132リンクの全件"></a>

### VPI / DPI headers (all items in 22 test and 1,132 link)

|Decision|Number of cases|
|---|---:|
| covered | 1,129 |
| partial | 3 |
| missing | 0 |

partial is the 2 test of `36.7 INCLUDE-HEADERS` and the 1 test of the `36.12.2.1 BOUND-RETARGET`. Also found 15 missing links for existing mapped requirements (COMPATIBILITY-DEFINE 5, K.2–COMPATIBILITY 5, BOUND-RETARGET 5). Because the matching kit accepts only unmapped requirements, these cannot be added without changing ledger policy.

<a id="ch16シミュレーション50リンクの層化サンプル"></a>

### ch16 simulation (stratified sample of 50 links)

|Decision|Number of cases|
|---|---:|
| supported | 38 |
| weak | 12 |
| wrong | 0 |
| unverifiable | 0 |

The 12 weak mappings exercise only some of a requirement’s conditions. Examples include flushing matured deferred assertions, future sampled values, left-associative `and` / `intersect` chains, and both empty and nonempty branches of ranged sequences.

<a id="formal259ケース全件"></a>

### formal (259 all cases)

|Decision|Number of cases|
|---|---:|
| strong | 107 |
| acceptable | 134 |
| weak | 19 |
| broken | 0 |

The weak cases include 9 unsatisfiable covers, 14 constant references, and 1 expected-value lookup tables (categories overlap). There were 0 examples where reference RTL called the Python evaluator.

<a id="実施した修正"></a>

## Corrections made

1. Recorded evidence of nonvacuity for every formal case
   - Changed cover expressions to use values actually reachable in each model (sequence/property/table/nonvacuity/clocking).
   - 9 cases 259 cases were added to cover job. The execution results are 518 PASS plus expected FAIL 5, with `ok: true`.
   - Updated formal-runner regression tests for the `task_plan` change.

2. Resolve partial mappings for VPI 36.7
   - Updated the C applications in `test_vpi_user_h_structure_constants` and `test_vpi_user_h_routine_declarations` to include both `vpi_user.h` and `sv_vpi_user.h`.
   - Confirmed unchanged output on Verilator 5.052 (seed 1/73), then rereviewed and updated the input digests for the 97 checks.

3. Retrieving the evidence of the execution
   - Saved Verilator reruns for previously unexecuted mapping targets.
   - Execution verification: 5,994 → 6,002 / 12,319 (48.72%) at that time.

<a id="残る弱点修正しないもの"></a>

## Remaining weakness (not corrected)

|Weakness|Scale|Reason|
|---|---:|---|
|The const type check of I.3|61 mappings|const disappears from the C function type, so execution cannot distinguish it|
|Add link to existing mapped requirement|15 cases|The matching kit accepts only unmapped requirements|
|Call check of BOUND-RETARGET|1 mappings|Requires VPI model with retarget at runtime|
|Formal case of constant reference|14 cases|Constant by definition, such as end-of-word or static graph analysis|
|Grammar alternatives in Annex A|6/23 mappings|1 test uses only a positive 1 substitute|
|Partial stimulation of ch16|12/50 mappings|Additional control cases are needed.|
|spec-only oracle test|1,372 Test / 4,559 Requirements|The simulator output is not recorded. No blanket blessing|

<a id="実行確認率の構造"></a>

## Structure of execution confirmation rate

Most of the unexecuted mapped requirements 4,559 are linked to spec-only tests, where the expected output is derived from the specification. To increase the execution confirmation rate, it is necessary to record the expected values for each simulator after reviewing that the output of each test conforms to the specification. A batch rerun like this does not increase it.

<a id="推奨"></a>

## Recommendations

1. To prioritize execution verification coverage, review spec-only tests chapter by chapter and record simulator expected values; do not bulk-process them.
2. To fill 15 missing links, add an “append evidence to existing mapped requirements” command with a review path separate from adding unmapped requirements.
3. For weak cases in Annex A and ch16, adding 1 control test(s) each offers the best cost-effectiveness.
4. If retaining constant-reference formal links, explicitly state “constant by definition” in case-definition comments and this report, without overstating independent RTL.

<a id="追補-分母レビュー2026-10-27"></a>

## Addendum: denominator review (2026-10-27)

Audited whether to approve the denominator from 3 perspectives: the `interpretation_issue` 21 lines, semantic duplication, and the initial observation cases. The conclusion cannot be approved right now.

- Interpretation conflicts: 19 issues across 21 rows. Of these, 6 rows require policy decisions and 15 await the standard's text; 0 rows can be resolved uniquely from the repository's text, tests, and docs alone.
- Even with denominator `approved`, no finalized values can be published. `summarize()` also requires section audits to be complete, but only 1,683/1,703 sections (98.83%) are complete; 20 remain `in_progress`.
- Of the initial 104 rows, 92 lack `source_spans`. Correspondence with source blocks has not been restored.
- The semantic duplication is that the perfectly consistent 3 groups cannot be integrated because the objects of observation are different. The 20 initial-to-extracted-row pairs and 5 `-TEXT` rows are merge candidates, leaving a possible denominator range of 12,279–12,319.

Therefore, the correct expression is as follows.

> Registered rows 12,319 (provisional denominator) / designs 87.3% / executions 48.7% / no finalized values /
> The denominator after deduplication is 12,279–12,319.

The work remaining before publishing final values is to complete the audit of 20 clauses, make 6 policy decisions, restore the sources for 92 rows, and consolidate 25 duplicates.

<a id="追補-ch16の残り69件"></a>

## Addendum: 69 remaining items in ch16

Classified 69 items into 31 reusing existing formal cases, 10 new formal items (8 cases), 15 requiring simulation, and 13 untestable items.

- 8 new cases: local flow, ranged always, right associativity of until/implies, adjoint ##1 / ##0, and semantic-leading-clock prefix/delay/inherited cases.
- For reuse, integrated only 27 cases actually covering the requirement conditions. The 4 items (implicit strength, holds, clock set of implication, and clock set of parens/not) with only a close name are excluded.
- Recorded stimulus, expected values, and reasons for 15 simulation cases and 13 untestable cases in audit notes without linking them here.

<a id="追補-シミュレータ別期待値"></a>

## Revision: Expected values by simulator

The `:expected_stdout_<simulator>:` is added to make the expected output for each simulator. Simulator-specific keys take precedence when used with common keys. The input fingerprint includes every referenced expected-output file. Existing tests containing only `:expected_stdout:` continue to work as before.

The pilot ran 10 requirements and 19 tests for which the passing sets differ between Icarus and Verilator. Differences on the 6 requirements run by both tools came from simulator nonconformance (converting x/z to 2-state values, missing path delays, missing x/z in VPI, or missing x propagation in relational operations) or unsupported syntax, rather than display formatting. The test was successful in 0 cases. Execution verification coverage is limited by simulator conformance and unsupported syntax, not metadata expressiveness.

<a id="最終値2026-10-27-深夜"></a>

## Final values (late on 2026-10-27)

The runner change made all the old execution evidence stale, so we retrieve all the instances with pinned release.

- Ran all 7,613 tests on Icarus Verilog 13.0 (Homebrew bottle, with the VPI include path corrected for the isolated prefix): 4,169 pass / 3,444 known.
- Ran 2,706 previously unexecuted link targets with Verilator 5.052 seed 1: 1,023 passed.
- Reran 268 formal tests with covers: 268 pass.

Final values: design 10,793 / 12,319 (87.61%), execution 6,117 / 12,319 (49.66%). The old value 6,002 was a union across different Icarus builds and past partial runs. The current value counts only the evidence of pinned release.

<a id="追補-ch16の完了状況2026-10-28"></a>

## Addendum: ch16 completion status (2026-10-28)

The additional 16 tests linked 53 of the 69 remaining ch16 items (27 reusing existing formal tests, 10 new formal tests, and 16 simulation tests). The remaining 16 cases are classified as unsupported for the following reasons.

- Untestable (12): undefined behavior, a recommendation in `should`, tool rejection of the syntax itself (`.triggered`, `$inferred_clock`, sequence-typed formals, multiclock, `strong`), or associativity / observation points left unspecified by the standard.
- Mappings withheld (4): implicit strength, holds, and clock sets for implication/parentheses. Avoided incorrect links where similarly named existing cases did not cover requirement conditions.

Of 16 simulation cases, 10 passed with Verilator 5.052; 6 are spec-only because the tools do not support them (no execution evidence). Because Icarus 13.0 cannot execute concurrent assertions, the concurrent assertions in ch16 have evidence from Verilator alone.

Final values: design 10,809 / 12,319 (87.74%), execution 6,127 / 12,319 (49.74%).

<a id="追補-6章9章21章2026-10-28"></a>

## Supplement: Chapters 6, 9, and 21 (2026-10-28)

Audited 133 unmapped items in Chapter 3 in parallel, and organized new 26 tests and candidates for reusing existing tests. Only 35 cases were integrated by the quality guard of the comparison kit (not adding a non-conformity test to the normal requirement, re-evaluating the scope of the existing mapped).

- Chapter 6: 15 new tests and 27 reuse candidates; integration focused on new tests.
- Chapter 9: New 7 test, reuse 15. Process API signatures and scheduling order are implementation-dependent or unspecified, so many entries were classified not_testable.
- Chapter 21: New 4 test, reuse 30. The implementation definition form of VCD / EVCD is not fixed.

The quality guard consistently rejected the proposal to observe the normal requirement by the standard violation test. This is a consequence of the policy of "observing the condition of the demand with a positive stimulus", and it is accepted to avoid the wrong link.

In parallel, evidence of the Ghost simulator was added. The official execution figure is 7,214/12,319 (58.56%), including Ghost; counting only Icarus/Verilator/SymbiYosys without Ghost gives 6,154/12,319 (49.96%). This audit targets the latter.

<a id="追補-37章38章-vpi2026-10-28"></a>

## Supplement: Chapters 37 and 38, VPI (2026-10-28)

Verified 196 VPI requirements by auditing reuse of 330 existing VPI tests and adding new VPI tests. The VPI object model exposed by Icarus 13.0 is limited, so 165 cases were marked not_testable for the following reasons.

- There are no object types as such: attribute, assertion/property/sequence, typespec/nettype, modport/interface port, delay terminal, frame/thread.
- Unimplemented properties/routines: `vpiExpanded`, `vpiIsProtected`, `vpiSimNet`, `vpiDelayType`, `vpiResolvedNetType`, `vpi_get_value_array`, `vpi_put_value_array`, `vpi_get_data`, `vpi_put_data`.
- Protected objects, save/restart, bulk arrays, reset, SV object callbacks, cbStmt, timing checks, and primitives/UDP.

Only 9 links passed the quality guards (Chapter 37: 4; Chapter 38: 5). Many VPI reuse candidates were rejected because of "observation of only part of the requirement", "value at error is not defined in the specification", and "depends on the iteration order and handle value of the implementation dependency".

This follows the judgment that exposing tool implementation boundaries is more accurate than increasing figures by hiding unsupported VPI cases.

<a id="追補-22章23章31章2026-10-28"></a>

## Supplement: Chapters 22, 23, and 31 (2026-10-28)

The 106 items of the compiler instructions, module rules, and timing checks are audited by 3 splitting. Organized 35 new tests and 26 reuse candidates, and integrated the 51 cases that passed the quality guards.

- Chapter 22: observe macro expansion, conditional compilation, `line`, keyword versions, `default_nettype`, and related behavior. Angle-bracket includes, macro recursion, and implementation-defined defaults are not_testable.
- Chapter 23: ANSI/non-ANSI ports, parameter overrides, bind, hierarchical names, uwire, and net collapse. The reuse candidate was rejected because collapsing nets of the same type cannot be distinguished by value.
- Chapter 31: timing events, negative setuphold/recrem limits and delayed data/reference, and fullskew active flags. Because Icarus explicitly states “Timing checks are not supported,” most violation-time, notifier-toggle, and negative-check internal-delay observations are not_testable.

The official figures are design 10,904/12,319 (88.51%) and execution 7,254 (58.88%, including Ghost); counting only Icarus/Verilator/SymbiYosys without Ghost gives 6,192 (50.26%).

<a id="追補-19章40章カバレッジ2026-10-28"></a>

## Supplement: Chapter 19, Chapter 40 Coverage (2026-10-28)

covergroup and API coverage are probed in the smallest sample.

- Icarus 13.0 rejects covergroup syntax (syntax errors at covergroup / coverpoint).
- Verilator 5.052 can execute covergroup, and `get_inst_coverage()` works.
- Neither tool implements Chapter 40’s coverage API. `$coverage_control` and similar routines return "reserved word not implemented"; the VPI coverage extension returns NULL.

For Chapter 19, integrated 9 links (8 new and 1 reused), and marked 43 items as not_testable. All 46 cases in Chapter 40 are not_testable. 0/100 is used as the expected value only if it is unique from the standard, because the rounding of the coverage rate, the automatic bin number, and the report format are implementation definitions.

The official figures are design 10,913/12,319 (88.59%) and execution 7,262 (58.95%, including Ghost); counting only Icarus/Verilator/SymbiYosys without Ghost gives 6,200 (50.33%).

<a id="追補-附属書ah35章36章2026-10-28"></a>

## Supplement: Annexes A and H, Clauses 35 and 36 (2026-10-28)

Audited grammar (A 48), DPI (H 48 and Chapter 35 43), and system tasks/VPI (Chapter 36 26).

- Annex A: placed new 16 tests in the chapters owning their syntax, observing 24 requirements. 11 cases are unverifiable because tools lack library-map, bind instance-target, DPI-string or related support.
- Annex H / Chapter 35: observe 6 requirements with new tests and 25 requirements by reusing existing tests, using DPI-C in Verilator. 60 cases are unverifiable because of ABI, undefined features, deprecated features (no svdpi_src.h), or internal errors in Verilator.
- Chapter 36: observe user system-task names, VPI callbacks, and startup API through 11 requirements. 15 cases are unverifiable because of vpi_get_data segfaults, missing compatibility headers or implementation discretion.

The link 70 passed the quality guard. Official figures: design 10,982 / 12,319 (89.15%); execution 7,325 (59.46%, including Ghost); and 6,264 (50.85%) for Icarus / Verilator / SymbiYosys alone, excluding Ghost.

<a id="追補-34章の境界と193536章の残り2026-10-28"></a>

## Addendum: Chapter 34 boundaries and remaining Chapter 19/35/36 items (2026-10-28)

Audited 215 cases in Chapter 34, converted only 5 into tests, classified 210 as not_testable, and documented the boundary in `docs/protected-envelope-boundary.md`.

- Icarus ignores every `` `pragma protect `` line and compiles plaintext inside the envelope unchanged.
- Verilator accepts only 12 of the 32 words and discards the base64 body. No decryption, key selection, digest matching, or visibility control is performed.
- Even the 5 test cases establish only that delimiters are accepted and data_block is excluded from analysis; they do not establish that protection works.

Audited the remaining 48 cases in Chapter 19 as 1 new and 17 reuse candidates, but the quality guards rejected them mainly as “only part of the requirement” or “implementation-defined rate.” Integrated the remaining 46 requirements of Chapter 35/36 using 3 new cases and 4 reused cases.

The official figures are design 11,000/12,319 (89.29%) and execution 7,329 (59.49%, including Ghost); counting only Icarus/Verilator/SymbiYosys without Ghost gives 6270 (50.87%).

<a id="分母レビュー完了2026-10-28"></a>

## 2026-10-28 Denominator review completed.

Audited 21 interpretation rows, 25 potential duplicates and 92 unsourced rows, then approved the denominator. For more details, see `docs/denominator-review-20261028.md`.

- Interpretation: main-text 11, policy choice 9; 31.4.4 is restricted by treating simultaneous edges as a precondition violation.
- Duplicates: merged 21 rows, retained 5 rows, and retained 6 exact-match rows.
- Sources: 89 rows have block-level citations; 3 rows have only section-level citations (6.24.3, 20.3.2, 20.14.2).
- Section: 1,703 / 1,703 Completed.
- Finalized denominator: 12,298; design 89.28% (10,980), execution 59.43% (including 7,309 and Ghost).
- The approval is AI review, and it is not an independent review and approval by humans.
