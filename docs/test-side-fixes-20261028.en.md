<a id="テスト側の失敗と-issue-619-の修正2026-10-28"></a>

# Test side failure and fix for Issue #6 - #19 (2026-10-28)

[English](test-side-fixes-20261028.en.md) / [日本語](test-side-fixes-20261028.md)

> Counts, percentages, and pending statuses in this document record their respective work dates.
> The current value is [Aggregated Summary](behavior-coverage-summary.en.md); the approval history for the denominator and interpretations is in
> See [Results of requirement extraction](requirement-extraction.en.md).

This records corrections to test-side failures whose assessment was recorded by `docs/test-failure-triage-20261028.md`, based on the clauses of IEEE 1800-2023. The runner-side #13 / #14 is in `docs/runner-selection-20261028.md`.

<a id="1-修正した-issue"></a>

## 1. Fixed issues

| Issue |Target|Primary fixes|
|---:|---|---|
| #6 |Checker 5|Initialize the checker variable at declaration, and move the `initial` assignment to `assign`/`always_comb`/`always_ff`. Move `int acc;` to checker body|
| #7 |Deferred assertions: 3 tests|Change the action assignment to the `void` function call of the checker body (16.4.1)|
| #8 |Severity / clocking: 5 tests|Change the regex to accept severity words either before or after the filename and line number|
| #9 |`$readmemh` 1 tests|Changed expected values to the standard's behavior: warn for out-of-range start/finish and leave memory unchanged. `:oracle: spec`|
| #10 |specparam / program / checker delays: 3 tests|Move specparam to generate conditions, access program signals through output ports, and change checker delay displays to `final`|
| #11 |VPI C: 1 file|Correct `%s` in `vpi_printf` to `%d`|
| #12 |VCD 3 tests|The index range of `$var` is arbitrary, the type and size are strict, and the range is allowed to be either "none" or as declared|
| #15 |Grammar: 6 tests|Rewrite `matches` using the standard's correct `cond_predicate` form; correct the word order in `wildcard bins`; avoid the reserved word `cell`|
| #16 |9 tests|Change multiclock to `\|->`/`##0`; rand constraints, quoted includes, modports, modules inside interfaces, converting `$bits` to a packed union, and `extern virtual`.|
| #17 |6 tests|Move `$future_gclk` into a property expression; `local` formal, virtual interface port, `out`→`output`, and soft packed union.|
| #18 |4 tests|Remove real / shortreal / event from array queries (outside 20.7's scope)|
| #19 |1 tests|Remove empty-matching `1'b1[*]` from the property|

Changed 46 test files in total (#11 changes C only). No tests were added or removed. The expected-output changes are ch6 in #9, #12, and #16, and `test_sequence_local_formal_assignment` in #17. Otherwise, we have corrected the design to the correct description according to the standards, and we have maintained the same expected value.

<a id="2-検証"></a>

## 2. Verification

- `python3 tools/lint_metadata.py`: 7,740 tests, 0 new issues (396 known).
- Executed 46 modified tests with locally built Icarus Verilog 13.0: 8 pass and 38 known (because `:oracle:` is not 13.0, or Icarus does not implement checkers or related features). Failed 0.
- Ran all 7,472 tests with Verilator 5.052: all 2,171 tests with a Verilator oracle passed. The remaining 5,301 tests is known, and failed 0.
- For grammar cases #15 / #16 / #17, a subagent also confirmed the absence of syntax and semantic errors with pyslang 12.1.0 `--std 1800-2023`.
- The actual #11 test still terminates with a separate 139 during the unreleased simulator's VPI typedef traversal. The `%s` test-side fixes are resolved; the remaining issue is an existing simulator defect.

<a id="3-実行証跡とカバレッジ"></a>

## 3. Execution evidence and coverage.

Existing execution evidence becomes stale because the changed tests have new input hashes. Reran the 46 modified tests on Icarus 13.0 and Verilator 5.052, and added the following evidence.

- `coverage/results/issues-20261028-icarus13.json` (46 tests)
- `coverage/results/issues-20261028-verilator.json` (all 7,472 tests)

Aggregate result (`coverage/behavior-summary.json`):

|Metric|Before the amendment|After modification|
|---|---:|---:|
|Register line (denominator)| 12,298 | 12,298 |
|Requirement mappings| 10,980 | **10,979** |
|Unsupported| 1,318 | **1,319** |
|Execution verification| 7,309 | **7,324** |
|Test mapping rate across the standard| 89.28% | **89.27%** |
|Execution verification coverage across the standard| 59.43% | **59.55%** |
|Snapshot of adoption| 39 | **41** |

The requirement mapping count decreased by 1 rows because the mapping for `SV2023-A.10-EXTRACT-FOOTNOTE-30` (matches binds more tightly than `&&` / `||`) was removed. `matches` is `cond_pattern` and cannot be an expression operand, so this claim cannot be expressed in a standard-compliant test. Added evidence from the full Verilator run increases execution-verified requirements by 15 rows net. The pre-change evidence of Ghost is that it has become stale for the modified test, and Ghost has not been rerun.

<a id="4-台帳の来歴更新"></a>

## 4. Updating ledger provenance

The following table has been updated due to changes in the test input.

- `coverage/behaviors.json`: update `inputs_sha256` of the 118 check, the evidence anchor in 40, and the observation in 2. Removed the 1 mapping from A.10.
- `coverage/test-matching-reviews.json`: Updated the evidence anchors of `inputs_sha256` and 2 from the 16 review. The explanation of `$readmemh` and the sequence local formal is revised to reflect the new observations.
- `coverage/behavior-baseline.json`: Record the reason for the above change in `reason`.

Replaced evidence anchors in `behaviors.json` with strings actually present in the modified tests. The only changes to the meaning of a mapping (its observation target) were the A.10 above, removal of real in 20.7, conversion of packed to a union in 6.24.1, and the expected-value change in `$readmemh`.

<a id="5-残る限界"></a>

## 5. Remaining limitations

- The simulator-side VPI defect in #11 (139 termination during typedef traversal) is a separate issue.
- No available simulator supports checker / SVA in ch16, interface in ch25, or tagged/soft unions in ch6 / ch7; their expected values are spec-only, derived from the standard.
- For #16, changed ch22 to a quoted include plus `:incdirs:` because the search locations for angle-bracket includes are implementation-dependent. The acceptance of the angle form itself is not observed in this test.
- For #6, `output int y2` now consistently uses declaration initializer 6; the old test's 5-to-+1 transition is no longer observed. The form with initial values declared on output ports is retained.
- Human independent review is still not carried out.

<a id="6-関連"></a>

## 6. Related

- [Coverage Gap Survey and Additional Test Candidates](coverage-gap-recommendations-20261029.en.md)
