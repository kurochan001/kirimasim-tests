<a id="修正後の再レビュー2026-10-22"></a>

# Follow-up review after fixes (2026-10-22)

[English](test-content-review-followup-20261022.en.md) / [日本語](test-content-review-followup-20261022.md)

> The following review results apply to the listed target commits.
> For subsequent fixes and remaining issues, see [Nightly derived correction](nightly-suite-corrections-20261027.en.md) and [Test-side fixes](test-side-fixes-20261028.en.md).

<a id="結果"></a>

## Result

Scope: `5859a575f0801c0a658a8851b37c2619f648ce02` 。 Compared fix commit `5c1104e` with previously reviewed `c118d54`.

The correction of the errors pointed out in the previous report F01 to F11 is confirmed. F12 is partially resolved; the following 3 points remain. Test bodies are unchanged.

The primary data is PDF of the specified IEEE Std 1800-2023 and the extracted text, as in the previous study. This rereview covers the corrections and related sites; it does not repeat manual review of all 3,801 cases or full runs with both simulators.

<a id="残る指摘"></a>

## The remaining points

<a id="r01-clocking出力の駆動前観測を削除したためoutput-skewを検証できなくなった"></a>

### R01: removing observations before clocking-output driving prevents verification of output skew

Scope:

- [test_program_clocking_output.sv:26](../tests/ch24/test_program_clocking_output.sv#L26)
- [test_program_clocking_default_skew.sv:30](../tests/ch24/test_program_clocking_default_skew.sv#L30)

Removing initialization of the receiving variable resolved the prohibited mixture of driving methods reported in the earlier F03. Instead of giving the initial value at the drive source, the observation of `q` before the drive is deleted. Both first observe `q` at time 8 and therefore cannot confirm that the clocking event at time 5 drives the value at time 7 after output skew #2.

Reproduction: made temporary copies of each source and replaced `output #2 q` with `output #0 q`, or `default input #1 output #2` with `default input #1 output #0`. The expected output of the Verilator and 5.052 was not changed, and the two runs were successful. These tests pass even on implementations ignoring output delays.

Rationale: Output-skew behavior of 14.3 and 14.16. Both test descriptions also identify this delay as a verification target. The default skew test still has the verification of input sampling, but not the verification of output delay.

Proposed correction: initialize the program-side output variable to 0 using a standard-compliant method, restoring the observations 0 at time 6 and 1 at time 8. Initialization is not restored when the recipient variable is declared. If the initialization of the driver is avoided, another stimulus is prepared to produce a known output value before the observation starts.

<a id="r02-coverageが利用できない適合ケースを不合格にしてしまう"></a>

### R02: incorrectly fails a conforming case where coverage is unavailable

Scope: [test_coverage_definition_control.sv:91](../tests/ch40/test_coverage_definition_control.sv#L91), line 94 in the same source.

The corrected version requires `start_u1 == SV_COV_OK && max_u1 > 0` and similar conditions. However, 40.3.2.1, Table 40-1 (p. 1158) specifies the cases where START returns NOCOV or PARTIAL. The 40.3.2.2 and 40.3.2.3 also recognize the reference result 0 when coverage is not available. These are different from ERROR. The test specifies no prerequisite to enable toggle coverage before running, and source lines 23–25 explicitly permit implementations without coverage.

Reproduction: in a temporary copy, replaced STOP / RESET with OK, START with NOCOV, and all queries with 0. This is a combination of no-coverage return values permitted by Table 40-1 and query API. Executing the remaining stimuli and checks with Icarus 13.0 made the first 2 line become 1 and the last 2 line become 0, differing from the expected output.

Proposed correction: determine availability from the return value of CHECK or START, and distinguish NOCOV/PARTIAL from ERROR. Require actual changes in configurations supporting collection; mark behavioral verification as unperformed where collection is unavailable. If toggle coverage is always required, the runner must define how to enable it and the execution prerequisites, and the source description must agree.

<a id="r03-u2のcoverage照会が常にerrorでも依然として全判定が合格する"></a>

### R03: all checks still pass even if u2 coverage queries always return ERROR

Scope: [test_coverage_definition_control.sv:63](../tests/ch40/test_coverage_definition_control.sv#L63), lines 69, 81, and 94 of the same file.

Comparing operation return values with OK resolved the previous false pass where all API could be ERROR. However, the test does not check that the queried value differs from ERROR, leaving a possible false positive from `-1 == -1` in the before/after comparison of u2.

Reproduction: in a temporary copy, set every control to OK and get_max to 8, replace the 6 queries of u1 successively with `1, 0, 0, 0, 0, 1`, and replace every query of u2 with `SV_COV_ERROR` (-1). Running with Icarus 13.0 matched all 4 lines of the original expected output, still 1. Although the coverage value for u2 has never been obtained correctly, the checks “reset does not change u2,” “both remain unchanged while the definition is stopped,” and “u2 remains stopped after starting u1” pass.

Rationale: For 40.3.2.2 and 40.3.2.3, -1 indicates a query error, not a coverage value suitable for numeric comparison. Requires treatment distinct from R02’s NOCOV / PARTIAL.

Proposed fix: check error values from all queries before comparison. In particular, check invariance only after assuming that both values in c2 / c2_after, u2_before / u2_after, and x2_before / x2_after are valid. The return value of start_all / stop_all is not only obtained but also verified.

<a id="前回指摘の対応確認"></a>

## Follow-up on previous findings

- F01: moved procedural assign to a part-select into a ch10 negative test. The rejection required on line 25 matches pyslang's diagnostic location.
- F02: explicitly imported required names at the export source. Matched on both simulators.
- F03: removed output-destination initialization. The prohibited mixture is resolved. However, the detection power of R01 is decreased.
- F04: Adding an initial to the program that survives longer than the time of observation.
- F05: renamed the reserved word before to value_before.
- F06 : Add explicit clock to expect. The missing-clock diagnostic is resolved.
- F07: moved the return of fast_ok to 51, consistent with the failure of 42. A minor point: the comment on the final `#20 $finish` still says 60, but the actual end time is 71.
- F08: 9 C files, copying the string before the next vpi_get_str call. The shared-buffer reproduction for module binding also makes all 3 expected lines 1.
- F09: Change sv_wait_level to automatic.
- F10: Change the reporting time of the setup notifier to 10.
- F11: corrected recrem/removal event ordering, SDF annotation targets, and expected values.
- F12: false positives across all ERROR controls resolved. The R02 and R03 remain.

<a id="確認結果と限界"></a>

## Findings and limits

- Executed corrected oracle-backed tests: Icarus 13.0 matched 3/3, and Verilator 5.052 matched 6/6.
- The checks of suite_stats, generation test, suite_catalog, and coverage_depth were successful.
- Metadata validation: 3,801 total, 0 new, 378 known, 0 resolved.
- Analyzed 15 modified SV cases using pyslang 12.0.0. Verified expected negative-test diagnostics. As before, known checker-package-context clock-inference diagnostics are not reported as findings solely on this analyzer's diagnosis.
- Syntax check of all 208 files returned error 0 and warning 1 for existing unused variables.
- The replication of R01 to R03 is done by temporary copy, and the repository tests are not changed.
- For advanced checkers, coverage API, SDF timing checks, and similar cases whose sole oracle is the standard, the fixes do not establish independent execution verification on the existing 2 simulators.
