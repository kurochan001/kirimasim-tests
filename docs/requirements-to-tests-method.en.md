<a id="ieee-1800-2023のpdfから要求を抽出しテストで検証する手順"></a>

# Extracting requirements from the PDF of IEEE 1800-2023 and verifying them with tests

[English](requirements-to-tests-method.en.md) / [日本語](requirements-to-tests-method.md)

This paper summarizes the procedures for creating a requirements list, comparing with existing tests and creating new tests, and measuring coverage rates, starting from the standard PDF. The method used for the work from 2026-10-22 to 24 (extraction of all requirements, addition of comparisons and tests up to 20% → 52.2%, and review of the table) is written in a form that can be reproduced by another person. The work is still underway, and the unfinished parts are written in "known limits".

Related materials: [Results of requirement extraction](requirement-extraction.en.md) / [Interpretation and Re-examination Record](requirement-extraction-notes.en.md) / [Measurement rules and updating procedures](../coverage/README.en.md) / [Test format](../README.md#test-format) / [Generalization to semiconductor specifications](spec-to-verification-method.en.md) / [SVA Reference evaluator and formal verification](sva-reference-formal-verification.en.md)

<a id="1-前提と原則"></a>

## 1. Premises and principles

- Do not copy the text of the standard. PDF and extracted text are placed outside the repository. For the log, test, and comment, write the requirement in your own words, and quote the paragraph number and the reference block ID. Facts constituting the interface itself, such as header constant names/values and reserved words, can be covered.
- The expected value is determined first from the standard. Do not copy simulator output into expected values. The simulator is used only to verify the expected value and to record `:oracle:`.
- The authors and reviewers are separated. The comparison proposal and new test are reviewed by a reviewer who is not the author of the test, and only those that pass are taken into the test log. I will reject anything uncertain.
- A AI review is not human approval. This is always written in the `reviewer` column of the logbook and in the documents.
- The correct aggregation is preferred over the protection of the numerical value. Withdraw incorrect mappings and rewrite baselines with reasons.

<a id="2-全体の流れ"></a>

## 2. The whole flow.

```text
PDF ─┬─> A. Source index and section ledger (locations and hashes only)
     └─> B. Requirement extraction and source audit (behaviors.json / requirement-audit.json)
              │
              ├─> C. Ledger review (recast requirements in observable terms; resolve deferred interpretations)
              │
              ├─> D. Matching against existing tests ──────────┐
              ├─> E. Creating new tests ───────────────────────┤─> F. Independent review ─> G. Integration, measurement, and recording
              └─> E'. Generated tests for tabular requirements ┘
```

The results of each stage are the table of `coverage/` and the data of `docs/`, and they are examined together at the time of the integration of G.

<a id="3-準備"></a>

## 3. Preparation

<a id="31-資料"></a>

### 3.1 data

- Place the standard's PDF and the text extracted with `pdftotext -layout` (`out/lrm_pdftotext_layout.txt`) together in 1 material directory/directories. The tool's default location is `DEFAULT_SOURCE` in `tools/requirement_source.py`.
- PDF and SHA-256 of the extracted text are fixed to `coverage/standard-sections.json` and `coverage/requirement-source-index.json`. `python3 tools/behavior_coverage.py --check --verify-source <資料dir>`, to verify that the documents you have are the same version.

<a id="32-シミュレータ"></a>

### 3.2 Simulators

Use the same version as the saved execution trace. The result of a different version is treated as a separate run.

|Simulator|Version|Purpose|
| --- | --- | --- |
| Icarus Verilog | 13.0（`Icarus Verilog version 13.0 (stable) (v13_0-dirty)`） |First confirmation point. `iverilog@13.0`|
| Verilator | 5.052 |If Icarus does not comply with the specification or cannot be compiled. If the results match for both seed 1 and seed 73, `verilator@5.052`|

Icarus 13.0 is built from the `v13_0` tag. macOS require 2 points.

- I use bison (`PATH=/opt/homebrew/opt/bison/bin:$PATH`) of homebrew.
- After `#include "ivl_alloc.h"` of `driver/main.c`, add `#if defined(__APPLE__)` `#include <mach-o/dyld.h>` `#endif`.

The built executable locates libraries relative to itself, so it works after relocation. Specify `run_icarus.py --iverilog-bin <dir>/bin`. Verilator is faster to build if you add `OBJCACHE=ccache`.

<a id="33-リポジトリのツール"></a>

### 3.3 Repository Tools

|Tool|Role|
| --- | --- |
| `tools/requirement_source.py --show <節>` |Displays the text of the paragraph with the block ID (the text is not output to the repository)|
| `tools/import_standard_sections.py` |Importing and checking the clause ledger|
| `tools/behavior_coverage.py` |Ledger checks, measurements, baselines, history, and generated reports|
| `tools/requirement_audit.py` |Bidirectional comparison between the source audit and ledger (called from `behavior_coverage`)|
| `tools/requirement_matching.py` |Ledger of all tests' cited clauses, mappings, and decisions to hold mappings (`coverage/test-matching.json`)|
| `tools/run_icarus.py`、`tools/run_verilator.py` |Execution and evaluation. Write the result with the input hash and the runner hash in `--json`|
| `tools/run_sby.py` |The `:formal_case:` of `:type: formal` is checked by SymbiYosys. Exclude from simulation-runner targets|
| `tools/new_test.py` |New test prototype|
| `tools/lint_metadata.py` |Checking metadata and formatting|
| `tools/suite_stats.py`、`suite_catalog.py`、`coverage_depth.py` |Table, catalog, depth aggregation of README|
| `generators/` |Generating tests covering the requirements of table formats|

<a id="34-照合キットtoolsmatching_kit"></a>

### 3.4 Reference Kit (`tools/matching_kit/`)

Auxiliary scripts automate receiving comparison proposals, recording reviewers' judgments, and integration. How to use it is in [Kit's README.](../tools/matching_kit/README.md). The references, decisions, and notes are stored in a working directory outside the repository as an appended JSONL. Only `merge.py` can change the repository.

|Script|Role|
| --- | --- |
| `partition.py` |Distribute unmapped requirements into files for each assigned range without splitting clauses. Requirements with cited tests: `p..` (compare first); requirements without candidates: `g..` / `a..` / `h..` (investigate existing tests further and create new tests if necessary). The absence of a candidate does not mean that there is no existing test.|
| `propose.py` |`req` (requirements, sources, candidate tests, existing pending items); `test` (test headers, input files, links); `scope` (assigned-scope progress); `add` / `group` / `hold` (appending proposed mappings); `verdict` / `testverdict` (reviewer assessments). The same conditions as `behavior_coverage.validate()` are examined at the time of the addition. Conditions include clause citations, matching positive/standard-violation kinds, existing anchors, input files, existing holds, withdrawn pairs (`withdrawn-20261023.json`), and prohibited tests.|
| `merge.py` |Recheck only proposals whose latest judgment is `accept` against the ledger immediately before integration, then integrate them into `behaviors.json` and `test-matching-reviews.json`. The input digest is calculated at the time of integration. Skip proposals already integrated. The name of the person responsible and the date are passed as arguments.|
| `runsim.py` |Runs on Icarus 13.0 and Verilator 5.052 (seed 1/73) and shows which ones match.|
| `workflows/*.js` |In the Claude Code workflow, scripts that run author and reviewer for each section (10 chapter). The instruction text contains the criteria for judgment.|

`tools/test_matching_kit.py` checks the main conditions of the test with CI.

<a id="4-段階ab要求の抽出と出典監査"></a>

## 4. Stages A and B: Extraction of the requirement and source verification.

There are detailed rules for [Results of requirement extraction](requirement-extraction.en.md) and [Measurement rules](../coverage/README.en.md). The main points are as follows.

1. Reference index: For all 1,740 sections, the page and line positions of PDF, the boundary of the reference block, and the SHA-256 of each block are recorded (`requirement-source-index.json`, not including the text).
2. Clause ledger: record each clause's normative/informative status, progress state (`unreviewed` → `in_progress` → `complete` / `no_behavior`), and review notes (`standard-sections.json`).
3. Requirement rows (`behaviors.json`): 1 row represents 1 condition or observation unit.
   - Include `id`, `clause`, `kind` (`normal` / `error` / `boundary`), `modality`, `behavior`, `acceptance`, `source_note`, `source_spans` (clause and block ID), and `checks`.
   - `checks: []` means unmapped.
4. Source audit (`requirement-audit.json`): classify every block as one of `requirements` / `heading` / `informative` / `example` / `reference`. In the case of `requirements`, write which requirements it will respond to. It is compared with `source_spans` in both directions.
5. Pending interpretations: retain internally inconsistent standard statements as rows tagged `interpretation_issue`, and set the clause to `in_progress`. Cannot assign a test to this row.
6. Denominator: all registered rows form the provisional denominator. Keep `denominator_review.state` as `pending` until approval after semantic deduplication and resolution of pending issues.

To be careful when extracting (what I learned from the review):

- The observing form is written. The only way to observe that it is "reserved" is by refusing it when used as an identifier. Such a line is written as `kind: error` from the beginning.
- Do not mix positive tests and tests of standard violations in 1 row(s). "X is accepted, Y is rejected" is divided into 2 lines. The comparison tool rejects mappings from tests of standard violations to positive requirement rows.
- The premise of implementation dependency is fixed by acceptance conditions. Example: because the keyword set without `begin_keywords` is implementation-dependent, write the test within a region with an explicit version.
- Keep usage rules (application obligations) and value semantics separate from rows describing header declarations. Examples: “members corresponding to each value format” and “users must not include it directly.” The declaration is in the declaration line, the use is in the use line.
- Does not add rows that overlap with existing rows. The denominator swells, and the approval of the fixed value becomes difficult.

<a id="5-段階c台帳の見直し"></a>

## 5. Stage C: Re-examination of the register.

<a id="51-観測可能な形への組み替え"></a>

### 5.1 Transformation to Observable Form

Preserve requirements ID and `source_spans`, rewrite `kind`, `behavior`, and `acceptance`, and append the date and reason for the change to `source_note`. The content of the requirement changes, so the baseline is rewritten with reasons.

```sh
python3 tools/behavior_coverage.py --write-baseline --update --require-source-reviewed \
  --history coverage/behavior-history.json --reason '具体的な理由'
```

The SHA-256 of the denominator changes. When comparing the ratios before and after the change, the denominator is stated.

<a id="52-解釈保留の解消"></a>

### 5.2 Resolving pending interpretations

The following criteria are used to judge the standard, assuming that there is no official correction table.

- Resolve: If there is a decisive basis within the standard.
  - When the text's spelling conflicts with normative headers (Annexes I/K/M), API, or syntax/table definitions, while those definitions agree.
  - The error in the formula can be uniquely reconstructed from the text or other formulas defining the same concept.
- Keep pending: normative statements materially conflict, so adopting either requires discarding the other. If the basis remains in conjecture.

In the denominator review of 2026-10-28, in addition to the interpretation that is unambiguous from the text, we also recorded the explicit policy choices for the conflict of norms, and resolved the remaining 19 argument and 21 line. There are currently 0 pending interpretation issues. Do not treat a policy choice as an official IEEE correction. If you find a new conflict, please refer to [Interpretation and limitations of the method](denominator-review-20261028.en.md) and specify the reason and choice.

Procedure:

1. For each argument, the analyst makes a verification note of the judgment, the basis (paragraph and block ID), the rewritten requirement, and the paragraph.
2. The other reviewer checks that there are no contraexamples or omissions in the specification.
3. Remove `interpretation_issue` from rows for accepted issues and append the adopted interpretation to `source_note`.
4. If no other issues remain pending in the clause, set it to `complete` in both `standard-sections.json` and `requirement-audit.json`.
5. For issues still pending, record the missing decisive evidence in [Interpretation and Re-examination Record](requirement-extraction-notes.en.md).

Also check that rewritten requirements do not newly mix positive tests and tests of standard violations (Chapter 4).

<a id="6-段階d既存テストとの照合"></a>

## 6. Step D: Comparison with existing tests.

<a id="61-候補と制約"></a>

### 6.1 Candidates and constraints

- The candidates are limited to tests that quote the paragraph of the requirement in `:lrm:` (the constraint of `behavior_coverage.validate()`).
- The requirement for detection of a nonconformity (`kind: error`) can only be addressed by a nonconformity test with `:should_fail_because:`.
- Do not use rows with pending interpretations, pairs with existing holds, withdrawn pairs, or prohibited tests.

<a id="62-対応を登録する基準"></a>

### 6.2 Criteria for registering mappings

1. Read the requirement's `behavior`, `acceptance`, and `source_spans` plus the relevant clause's text, figures, and tables.
2. The test `.sv`, C helper ( `:vpi_c:` / `:dpi_c:` ), include, and expected output are read.
3. Register a mapping only if you can explain, with specific values, times, types, and objects, whether an incorrect implementation of the behavior would change the expected output.
4. The following does not prove the entire requirement.
   - Only quotes, test names, descriptions, and the fact that API was called.
   - Checks only for non-NULL, passes even when always 0, or comparisons with only true-producing inputs
   - Assigning to another type hides the original type during checking
   - The count/type check does not look for the identity of the object.
   - Observations depending on evaluation order unspecified by the standard, such as function-call order within one expression
5. Do not register a mapping that observes only some independent conditions. If all conditions can be shared between multiple tests, make `check_groups` (AND within the group, OR between groups).
6. In `checks`, record the test, a Japanese description of observations and how they distinguish incorrect implementations, date, owner, input digest, and `evidence` (string anchors for stimulus lines and expected-output lines).

<a id="63-保留判断"></a>

### 6.3 Decisions to hold mappings

Record reasons for deferring a mapping in `test-matching-reviews.json` when they will help later work.

- The categories are `partial_observation` / `oracle_issue` / `citation_refinement` / `compound_requirement`.
- Prefix each description with a sequential number (M01, M02, …).
- Tests with expected values contradicting the standard, or positive tests containing standard-violating syntax, are `oracle_issue`. The test itself is not fixed in this task.

<a id="64-実績"></a>

### 6.4 Results

In comparison alone, only 8 to 35 requirements (approximately 6 to 15% of non-compliant requirements) were adopted per interval. The main reason is that there is no existing test to stimulate the condition of the requirement in the first place. First, we verify the compatibility with existing tests, and fill the gap with new tests.

<a id="7-段階e新規テストの作成"></a>

## 7. Step E: Creating a new test.

<a id="71-共通の規則"></a>

### 7.1 Common rules

Follow the sections "Test format", "Metadata", "How a test is judged", "Tests with C code", "Where the expected outputs come from", and "Contributing" of README. The main points are as follows.

- Create a prototype with `tools/new_test.py chNN test_<内容> --lrm "節 ..."`. The location is the directory of the chapter in the first quoted paragraph. The section of the requirement to match must be included in `:lrm:`.
- If the display format of the expected output is different for each simulator, add `:expected_stdout_icarus:`, `:expected_stdout_verilator:`, `:expected_stdout_kirimasim:`, and `:expected_stdout_lyra:`, and leave the common `:expected_stdout:`. The fields by simulator will be prioritized. You can add it if the only difference is the format the standard has given to the tool, such as the blank `%p`, and both outputs are compatible with the standard. You will actually record both outputs and write the reasons for the differences in the test comments and work notes. If the standard does not specify the execution order, the order is not fixed as the expected value for each simulator, and the results are observed independent of the order. All referenced expected value files are included in the input hash, and any change to any of them will invalidate the execution trace.
- Use 1 test(s) to verify fully a closely related group of 1 to a few requirements. In the case of a incorrect implementation, the output will be different, so that the case is contrasted (true and false, both sides of the boundary, both x and z for x/z-handling requirements). The output is only the values specified by the standard and displays the actual values.
- Write the expected value first and check with `runsim`. If it does not match, you first check your expectations with the standard. For simulator-side errors, document them in `docs/simulator-differences.md` and test comments (do not record unsupported syntax).
- How to attach `:oracle:`:
  - If the results match with Icarus 13.0, add `iverilog@13.0`.
  - If the seeds 1 and 73 of Verilator are both matching, `verilator@5.052` is added. Tests added from 2026-11-14 until the pin moves to 5.054 are checked with 5.054 and get `verilator@5.054` ([the interim pin](simulator-differences.md#verilator-5054-interim)).
  - If neither match, only `spec` is used.
  - The results of kirimasim and Lyra are not recorded in `:oracle:`. These are for comparison purposes to increase the proof of expectations (run nightly).
  - The `:fourstate:` and `` `timescale `` are adjusted to the actual state.
- The non-conformity test is only used for requirements of `kind: error`. Include only 1 intended violations, and specify the valid diagnostic location and required diagnostic content in `:expected_stderr_regex:`. If multiple report locations are valid, allow them. Avoid mistaking an unsupported-syntax error for detection of a standard violation.
- Do not start a comment line with the word "Verilator" (it will be BADVLTPRAGMA). Avoid tests that take more than a few seconds to run or that use a large amount of memory.

<a id="72-vpidpiのテスト"></a>

### Tests of 7.2 VPI, DPI

- I write so that it can be compiled in both C and C++. Only when compiling as C++, enable `extern "C" {` enclosed by `#ifdef __cplusplus` and its matching `}` (Verilator compiles as C++).
- Verilator cannot call system tasks registered in `vpi_register_systf`. The output you want to drive with Verilator is either from a callback such as `cbStartOfSimulation` or from `vlog_startup_routines`.
- Include only standard headers (`vpi_user.h`, `sv_vpi_user.h`, `svdpi.h`, and the C library).
- For `:oracle: spec` tests that neither simulator can run, verify compilation in both C and C++ against the 1800-2023-version standard header (`vltstd` bundled with Verilator).

<a id="73-ヘッダの規定を検証する技法"></a>

### 7.3 Technique for verifying the specification of headers

This technique was used for header-constant/declaration requirements such as those in Annexes I/K/L/M.

- Constant: Enclosed by `#ifdef`, line missing if not defined. Use the value as a `enum` initializer so compilation fails unless it is an integer constant expression. Also reject values outside the int range with `1 / (INT_MIN <= c && c <= INT_MAX)` before printing numeric values.
- Types and declarations: use `SAME_TYPE(e, T)` to compare the exact types of unevaluated expressions. In C, we use `_Generic`, and in C++, we use `decltype` and our own `same<A,B>` templates (`<type_traits>` is not supported). Since the functions are not linked, even functions that are not implemented by the simulator can be checked for only declarations.
- Structures: check field order by comparing relative `offsetof` values. Verify that it is a union by checking equal `offsetof` for all members. The typedef name is checked by matching the pointer type.
- Guard: The application defines a guard macro and another type first, and ensures that the header skips the type definition (otherwise, the compilation stops due to double definition). 2 headers are loaded in sequence. In the double inclusion test, the macro is redefined to a different value and then loaded, and the value is retained.
- Macro value: `#if` treats undefined names as 0, so check `defined()` or compare it to a C constant. If the expression itself is specified, the results of the expansion are compared by converting them into strings.
- Self-verification: Compile and run tests natively on the reference headers recovered from the source of the specification text to verify that they match the expected output.

<a id="74-表形式の要求は生成器で作る"></a>

### 7.4 Table-format requirements are generated by the generator.

The generator is written to `generators/` for requirements (reserved words, constants, etc.) where the 1 row corresponds to the "1 cell of the table".

- The reference model is made from the table of the standard. Checks the table matches (e.g., the sum of the additions per edition matches the appendix B) in the generator.
- The case of the non-conformity test is `Case(should_fail_because=...)`, and the error line in the text ends with "`// illegal`". `common.render` creates `:expected_stderr_regex:` from its line number.
- Record `:oracle:` in `generators/oracles.txt` from the execution results, then rewrite using `generate.py`. Because `record_oracles.py` with `--verilator` also resets out-of-scope generated tests to `spec`, append only new cases under the same rules.
- When you edit the generator's comment, the error line numbers may change. The anchor of the reference proposal is also corrected.

<a id="8-段階f独立レビュー"></a>

## 8. Stage F: Independent review.

Reviewers must not accept authors' explanations at face value; they read the standard and tests themselves to look for counterexamples or omissions.

- The test is judged ( `testverdict` ) : the entire line of the expected output is derived from the standard and is compared by oneself. Also check standard conformance, determinism, metadata, lint, and agreement between `:oracle:` declarations and actual behavior. The test where the expected value cannot be derived from the standard is `defective`.
- The decision of the reference proposal (`verdict`): Make `accept` only if the stimulus triggers all the conditions of the requirement and the expected output can be distinguished from the incorrect implementation. If the test is `defective`, it is `reject`, if uncertain, it is `reject`.
- Detection verification by fault injection: the header and inputs in accordance with the specification are misplaced 1 at a time, and the output is changed or the build is stopped (mutation test).
- Large mechanical scheme: based on the results of comparisons with independently extracted values (e.g., a list extracted from the table of PDF by another method), we decide to use a script to decide all of them.
- Horizontal expansion: When a reviewer finds a certain type of defect, he checks all the adopted cases from the same point of view. For 2026-10-24, the 3 tests which was found to be defective in `input int` was checked, and the same form was found in the adopted 1 tests and the existing test 7 tests.
- In the 13 section of 2026-10-24, 30 tests (approximately 5%) of the new test 624 were defective, and 166 tests (approximately 7%) of the reference proposal 2,215 were rejected. Of 30 defective tests, 4 had incorrect expected values themselves. The remainder concerns output of values unspecified by the standard (7 tests), design conformance (7), error lines in standard-violation tests (6), metadata (5), and unfinished tests (1).

Holes found in the verification so far (checklist to avoid the same kind of errors from the start):

|Observations|Countermeasures|
| --- | --- |
|`(int)` Cast cannot distinguish between floating point definitions|Use as initialization of `enum`|
|int Out-of-range values are cut off and match|Trigger division by 0 in the range check|
|Does not verify that it is a union|Check that all members have equal `offsetof`|
|Guards check only whether a definition exists|Define the guard first and verify that the header omits the guarded declaration|
|`#if` treats undefined names as 0|Also use `defined()`, or evaluate it in a C constant expression|
|Tests dependent on undefined actions (e. g. shift of 32 bits)|Defer the mapping|
|The results show that the complex demand is only observed in part (only the z‐side, no contraction, only one direction).|Add control cases or use a AND set|
|Checks only counts, not identity|Compare with object name and value|
|Depends on the order of evaluation within the same `$display`|Avoid observations whose order is unspecified by the standard|
|The `:expected_stderr_regex:` in the violation test points to the standard-correct lines before and after the violation.|Compare against the “`// illegal`” line and verify that a correct implementation reports the diagnostic on that line|
|In the standard violation test, the intended violation is overlapped with another violation (e.g., a hierarchical reference to an item in an automatic task).|Make the violation 1 and make sure that there is no design error except for it.|
|Use a type that cannot be used for nets (a 2-value type such as `input int`, or a virtual interface) on an input port in ANSI form with the port kind omitted|Add `var` ( 23.2.2.3, 6.7.1 ) as `input var int`|
|The comment on the explanation on the line of violation is itself a violation (comment on the same line as `` `line `` is prohibited in 22.12).|Do not comment on command lines|
|Marked `:fourstate: no` despite outputting strengths or tri-state values|The test using the strength syntax is `:fourstate: yes`.|
|Outputs unspecified values, such as the unsized value `$bits`, the sequence of simultaneous events, the repetition order of VPI, and the element name.|No output, or change to the form specified by the standard.|

<a id="9-段階g統合計測記録"></a>

## 9. Stage G: Integration, measurement and recording.

1. Remove `defective` tests and tests with no judgment, or move them outside the repository. Because generated artifacts scan all of `tests/`, do not regenerate while leaving unverified tests in the working tree.
2. Run the remaining tests through the lint and pre-run them to make sure that the description of `:oracle:` is consistent with the actual results. Use `coverage_depth.py --check --minimum-tests 2` here to check that a new test is not the sole 1 test(s) citing a clause with no other citing tests. 2 or more tests are required for the cited section. If you want to use a paragraph as a background, remove it from `:lrm:`.
3. Run this for record, and save it as `coverage/results/<名前>-<日付>-icarus13.json`, `-verilator-seed1.json`, and `-verilator-seed73.json`. The results of all cases will not be overwritten. The results of partial execution are not synthesized either.
4. Integrate accepted proposals. Integration accepts only unmapped requirements. Input digest is calculated at the time of integration, so it is done after the test is confirmed.

   ```sh
   python3 tools/matching_kit/merge.py <work>/proposals/<wave> \
     --reviewer '<モデル名> (AI); not an independent human review' --date YYYY-MM-DD
   ```

5. Update generated artifacts.

   ```sh
   python3 tools/behavior_coverage.py --update --require-source-reviewed --history coverage/behavior-history.json
   python3 tools/requirement_matching.py --update
   python3 tools/suite_stats.py --update
   python3 tools/suite_catalog.py --update
   python3 tools/coverage_depth.py --update
   ```

If you have corrected the test after merging, do the following:
   - Rerun the corrected test and save it with an alternate name, such as `coverage/results/<名前>-refinement-<日付>-*.json`.
   - Recalculate the `inputs_sha256` in the table with new input.
   - This is a difference from the baseline, so leave the reason in `behavior_coverage.py --update --require-source-reviewed --write-baseline --reason '<理由>'`.
   - Attach `--history` only 1 time(s), at the end of the work. Every time you add, the history increases by 1.

6. Update the documentation: Results report (new), result file list for README, `coverage/README.md`, main aggregate for `docs/nightly-results.md`, cumulative pointer, `docs/simulator-differences.md`.
7. Commit after all checks are passed.

   ```sh
   python3 -m unittest discover -s tools -p 'test_*.py'
   python3 tools/behavior_coverage.py --check --require-source-reviewed --verify-source <資料dir>
   python3 tools/requirement_matching.py --check
   python3 tools/suite_stats.py --check
   python3 tools/suite_catalog.py --check
   python3 tools/coverage_depth.py --check --minimum-tests 2
   python3 generators/generate.py --check
   python3 tools/lint_metadata.py
   git diff --check
   ```

8. After push, the first nightly (or manual) run ensures that all simulator jobs have been run to the end. New tests can cause simulators to run out of control. At 2026-10-24, Verilator failed to stop recursion in a cycle of sequences containing a standard violation, exhausting runner memory and stopping the job. The Verilator job is now restricting the memory per process.

<a id="計測の読み方"></a>

### Reading measurements

- Temporary: Count all enrollment rows with the same weight. For annex constants and reserved words, 1 item(s) correspond to 1 row(s). Therefore, the values in those rows will move a lot. In addition to the total values, the values of the text (chapters 1 to 40) and the chapter-by-chapter summary are always included.
- Run check: Counts only `pass` that match the input and the runner hash. `known`, `unsupported`, `fail`, and old inputs are not counted. requirements for detection of non-conformity count only the results of simulators with fixed version tokens in `:oracle:`. The AND set is counted only if all tests in the group are successful in the same run of the same simulator.
- Finalized values are not published until denominator approval after semantic deduplication and resolution of pending interpretations.

<a id="10-並列化と費用"></a>

## 10. Parallelization and cost.

The large scale comparison and test creation was done in parallel, by dividing the requirement into sections of about 220 each.

|Composition|Content|Performance|
| --- | --- | --- |
|Checker + Reviewer|Compares a requirement with a citation test|1 pairs: approximately (50–65) × 10,000 tokens. Adopted: 8–35 requirements|
|Test creation + review|Write a new test for a requirement that cannot be filled by comparison|1 creation agents: 10–76 tests and dozens to more than 200 mapping proposals|
|Comparison and test creation with 1 agents|If the existing test is sufficient, use it, if not, write it.|Without tests citing the clause, the work effectively becomes test creation|
|Just a check.|We will verify the existing concepts and tests.|1 agents: approximately (15–40) × 10,000 tokens|

- Choose how many agents run concurrently based on machine load, including simulator builds. The load average of the 18 core was about 6 to 9.
- Interruption and resumption: keep all comparison proposals, judgments, and test lists in append-only files. When interrupted, unverified tests are relocated out of the repository. On resumption, verify existing work first; resume creation only if needed.
- Cost estimates: annex-header verification used approximately 130 × 10,000 tokens over 3 rounds; reviewing 46 pending interpretation issues used about 110 × 10,000; verifying generated reserved-word tests used about 15 × 10,000. Verifying the 13 ranges alone (2,215 comparison proposals, 624 new tests, 2026-10-24) used approximately 560 × 10,000 tokens, or about 43 × 10,000 per 1 range(s).

<a id="11-再現性のために固定するもの"></a>

## 11. Fixed for reproducibility.

- The references are PDF and SHA-256 for the extracted text and SHA-256 for the index of the sources.
- The table includes: SHA-256 ( `behavior-summary.json` ) of the denominator, reference value ( reason for `behavior-baseline.json` ), history ( `behavior-history.json` ), and version of the measurement rules ( `metric_policy_version` ).
- Test: Inputs digest (test body, expected value, C, include, `:files:`), SHA-256 of the runner, version and seed of the simulator.
- The decisions are made by the following elements: JSONL of the comparison proposal and the decision, the identifier of the reviewer, the date, the department, and the instructions used (workflow script).
- Generated tests: generator `VERSION` and `oracles.txt`.

<a id="12-既知の限界と未完了"></a>

## 12. Known limits and incompleteness.

- The requirement coverage (test design) at the time of 2026-10-29 is 89.33% (10,986/12,298), and the execution confirmation rate is 59.60% (including 7,330/12,298 and Ghost). The remaining reference intervals and additional tests were verified and integrated in 2026-10-25 to 26. For current remains and evidence, see [Summary of the aggregate](behavior-coverage-summary.en.md) and [Gap investigation](coverage-gap-recommendations-20261029.en.md).
- All 253 requirements in Annex F have mappings and recorded passes. This is a result within the scope of the registered model and conditions, and does not prove the entire implementation of any SVA or simulator.
- The 34 chapter, 40 chapter, VPI, DPI, and the timing checks have requirements that cannot be observed by the available tools. The range and reason are recorded in [Protective envelope boundary](protected-envelope-boundary.en.md) and [Gap investigation](coverage-gap-recommendations-20261029.en.md#8-追加しない方がよい領域). These are also left in the denominator.
- There are 0 pending interpretation issues; the denominator of 12,298 requirements was approved in the AI review. The independent review and approval by humans is not carried out. [Limits of denominator reviews](denominator-review-20261028.en.md#6-限界) also remain, including 3 rows with only clause-level sources.
- Some unmapped requirements can already be observed in existing tests, but their mappings have not been registered. Before writing a new test, compare the stimulus with the expected result.
- Tests marked only `:oracle: spec` have no registered reproduction of their expected results with a fixed-version simulator. It is not always "no simulator will work" because it may match with the development version or other tools. Expected values were checked against the standard by AI; human verification has not been performed.
- The comparison tool Lyra (added at 2026-10-24) provides limited independent corroboration. Lyra and kirimasim share the slang frontend, so agreement on parsing or elaboration is not independent corroboration. The nvc added at the same time was removed to 2026-10-25 because it had little support for SystemVerilog (pass was 1,611 of 6,009) and it could not run the tests of DPI and VPI.
- The expected value of `test_readmemh_address_range` found in the comparison was modified to fit the specification, and `:oracle:` was only `spec`. Tests are retained. See [The content of the correction and the results of each tool](simulator-differences.md#a-test-whose-expected-output-followed-both-releases-rather-than-the-standard).
- The Workflow script in the reference kit assumes the workflow tool in Claude Code. In other environments, you need to use the same criteria for the commands.
- Test of attachment header 24 The generation script that created the tests is not in the repository as a disposable. The standard is the test of the commit and the technique of the 7.3 section.
