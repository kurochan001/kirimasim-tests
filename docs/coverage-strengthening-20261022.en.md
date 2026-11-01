<a id="規格テストの補強2026-10-22"></a>

# Strengthening standard tests (2026-10-22)

[English](coverage-strengthening-20261022.en.md) / [日本語](coverage-strengthening-20261022.md)

<a id="範囲と到達点"></a>

## Range and reach

The start time is `51173db` and the total number of tests is 3,801. All 932 leaf clauses in main-text Chapters 3–40 of IEEE 1800-2023 already had directly citing tests in the existing count, but 187 clauses had only 1 test each.

Added 111 tests (99 positive cases and 12 negative cases), plus 6 C helper sources. Added another case to every one of the 187 clauses that previously had only 1 case(s), producing the following state.

- Total number of tests: 3,801 → 3,912.
- Target clauses directly cited by tests: 932/932 (100%).
- Percentage of target clauses directly cited by at least 2 tests: 745/932 → 932/932 (100%).
- Clauses with only 1 tests: 187 → 0.
- Clauses with only 1 tests and standard-only oracles: 65 → 0.
- Clauses whose tests rely solely on the standard: 259 → 239.

This is an index of the direct citation of the verse unit and the number of tests. The operation coverage rate listing all requirements, exceptions, boundaries, execution sequences, and combinations of functions in the specification is not measured. This 100% does not include behavioral coverage of the existing out-of-scope 227 clauses, protected envelopes in Chapter 34, or the annexes as a whole. The denominator and exclusion rules are not changed.

<a id="追加した検証"></a>

## Added verification

Did not increase counts merely by changing existing names/input values; each test comment states the standard clause and observed behavior. For example, added the following.

- Copying versus sharing: array arguments, associative-array assignment, classes/structs, retained queue-element references, and event rebinding.
- Type/value boundaries: descending enum names and prev wraparound, failing enum casts, signed associative keys, writes with unknown keys, and narrow traversal arguments.
- Execution timing: destination selection for delayed blocking assignments, argument copy-out, Preponed/Observed/Reactive/Re-NBA, and reevaluation of HDL after the PLI callback.
- Independent negative cases: edition-specific reserved words, incompatible casts, real-containing associative keys, interface-class construction, and constant actuals for checker covergroup.
- Hierarchy and connections: non-ANSI external port names and internal concatenations, wildcard-connection overrides, stable defparam, binds to specific instances, modport slices, and virtual references.
- Actual I/O data: short binary reads and EOF, seek after pushback, flush and error strings, memory output of packed struct / enum, and presence or absence of address tokens.
- VCD: read files back and check types, widths, values, times, and off/on/checkpoint behavior. The identifier code and time unit are obtained from the header, and the specific value of the processing system dependency is not fixed.
- VPI: check statement kinds plus condition/body/else, loop initialization/increment, disable targets, repeat controls, nettype-alias links, and numeric attributes.
- Other items include charge retention/decay/recharge, nonresistive-switch strengths, UDP presets, SDF label expressions and pulse boundaries, and differences between synchronous PLA and asynchronous PLA.

See [Catalog](tests/README.md) for added-test descriptions, clause numbers, and oracles, and [coverage-depth.md](coverage-depth.md) for current overall aggregates.

<a id="期待値と検証"></a>

## Expected values and verification

Expected values were determined against the supplied IEEE Std 1800-2023 text and extracted text. Expected values were not changed to match differing execution results. For example, short fread checks the byte count and upper byte determined by the standard, while leaving unread bit values unconstrained by expected output.

Oracles for the 111 new cases: 37 from both releases, 16 from Icarus alone, 31 from 5.052 alone, and 27 from the standard alone. Compared the new cases with Icarus 13.0 and 5.052; 2-state implementations were not used as oracles for 4-state cases. Standard-only cases lack completed independent execution verification, particularly advanced checkers, VPI, nettypes, SDF, and related features. Verified differences are documented in [simulator-differences.md](simulator-differences.md).

Checks performed:

- Passed 111 new cases to the Icarus runner; 53/53 oracle-target cases agree. The 58 cases outside the subject are distinguished as known differences.
- New 5.052 Oracle object matches 68/68.
- Analyzed syntax, semantics, and procedures for 111 new cases with pyslang 12.0.0 in 2023 mode. The negative case 12 was rejected. Positive-test diagnostics arose in 3 cases involving interconnect primitive connections, resolved-nettype aliases, and narrow associative-array traversal arguments; checked explicit permission rules in the text without changing expected values.
- Syntax checks for all 214 C files had 0 errors. Warning 1 for existing unused variable.
- Consistency checks for suite_stats, generators, suite_catalog, and coverage_depth succeeded.
- Metadata checks: 3,912 items; new issues 0, known issues 378, resolved issues 0.
- The depth check passes with a lower bound of 2; with a lower bound of 3, it fails and reports 437 missing clauses. Small inputs with parent-clause citations, uncited clauses, and excluded clauses also confirmed that only direct citations count.

This run targets added cases; it does not rerun simulations for all existing tests. Existing test sources and expected values are unchanged.

<a id="再発を防ぐチェック"></a>

## Checks to prevent recurrence.

`tools/coverage_depth.py --check --minimum-tests 2` is added to CI. Citing a parent instead of the child clause does not pass; uncited clauses remain in the denominator too. If fewer tests leave a target clause with only 1 tests, regenerating documentation alone cannot pass CI. This enforces a minimum count; test-content validity still requires review.

To verify VCD with the existing runner, the Icarus runner additionally strips only the `VCD info: dumpfile ... opened for output.` diagnostic line indicating that the file was opened. Keep verification-result lines emitted by HDL in the comparison.
