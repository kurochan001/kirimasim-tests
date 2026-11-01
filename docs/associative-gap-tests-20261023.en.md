<a id="連想配列のレビューで不足していた観測へのテスト追加2026-10-23"></a>

# Added tests for observations missing from the associative-array review (2026-10-23)

[English](associative-gap-tests-20261023.en.md) / [日本語](associative-gap-tests-20261023.md)

> Counts, percentages, and pending statuses in this document record their respective work dates.
> The current value is [Aggregated Summary](behavior-coverage-summary.en.md); the approval history for the denominator and interpretations is in
> See [Results of requirement extraction](requirement-extraction.en.md).

[Original review and M45 – M50](existing-test-matching-associative-arrays-20261023.en.md) / [Current coverage](behavior-coverage-summary.en.md)

Added 15 tests and expected outputs where review found insufficient distinguishing power. Determined the expected values by checking IEEE 1800-2023, 7.8–7.9.11, Table 7-1, and 20.6.1–20.6.2 in the supplied material. This work does not change existing tests' stimulus, expected values, or metadata.

<a id="追加した観測"></a>

## Added observations

- M45: Type and exact status of return value. [test_assoc_method_expression_types.sv](../tests/ch7/test_assoc_method_expression_types.sv) passes num/size/exists/first/last/next/prev expressions themselves to `$typename` and `$bits`. Avoid hiding the original type by assignment to a int variable; in actual calls, also display 1/0 and key updates. [test_assoc_count_expression_types.sv](../tests/ch7/test_assoc_count_expression_types.sv) checks num/size types and counts when empty, nonempty, and after deleting all entries in a separate file. Unsupported behavior in other methods does not block recorded num/size passes.
- M46: nonexistent starting keys and preservation of the key on failure. [test_assoc_traversal_gaps_and_preserved_keys.sv](../tests/ch7/test_assoc_traversal_gaps_and_preserved_keys.sv) calls next/prev from both present and absent keys, comparing exact statuses and selected keys. The input key is maintained in case of empty array and terminal failure.
- M47: observe allocation of the ref actual before the callee operates on it. [test_assoc_ref_allocates_before_callee_write.sv](../tests/ch7/test_assoc_ref_allocates_before_callee_write.sv) displays the container's num/exists before the callee reads the element and never writes to the element. [test_assoc_read_modify_defaults_without_ref.sv](../tests/ch7/test_assoc_read_modify_defaults_without_ref.sv) separates this from ref, checking `+=` / `++` from type/user defaults and initial values of unchanged struct members.
- M48: presence or absence of warnings. [test_assoc_missing_read_reports_diagnostic.sv](../tests/ch7/test_assoc_missing_read_reports_diagnostic.sv) requires the 4-state default for missing reads, no allocation, preservation of existing entries, and a warning. [test_assoc_invalid_write_reports_diagnostic.sv](../tests/ch7/test_assoc_invalid_write_reports_diagnostic.sv) requires writes to X-containing keys to be ignored with a warning. [test_assoc_default_and_delete_silent.sv](../tests/ch7/test_assoc_default_and_delete_silent.sv) checks that there is no warning for the user default missing read and the empty/non-empty array missing delete.
- M49: signedness, cast context, wildcard width, and normalization. [test_assoc_signed_and_unsigned_key_order.sv](../tests/ch7/test_assoc_signed_and_unsigned_key_order.sv) checks all keys and values of the same 8bit pattern in the order of signed/unsigned. [test_assoc_integral_index_cast_context.sv](../tests/ch7/test_assoc_integral_index_cast_context.sv) distinguishes aliases caused by narrowed keys and addition of 4bit operands producing 16 in a 8bit index context. [test_assoc_wildcard_width_and_sign_aliases.sv](../tests/ch7/test_assoc_wildcard_width_and_sign_aliases.sv) checks leading-zero aliases in 8/64/128bit, keys exceeding 64bit and unsigned interpretation of 8bit signed values. [test_assoc_wildcard_string_literal_bits.sv](../tests/ch7/test_assoc_wildcard_string_literal_bits.sv) verifies that a string literal and an equal-width bit vector overwrite the same entry.
- M49: stability of arbitrary order and composite keys. [test_assoc_class_key_order_is_stable.sv](../tests/ch7/test_assoc_class_key_order_is_stable.sv) and [test_assoc_composite_empty_null_key_order.sv](../tests/ch7/test_assoc_composite_empty_null_key_order.sv) compare 2 complete traversal sequences without changing the key set, also checking every key's membership and value. The class handle is not fixed in a specific order. The latter also uses struct keys containing empty strings/null.
- M50: copying every entry. [test_assoc_assignment_copies_every_entry.sv](../tests/ch7/test_assoc_assignment_copies_every_entry.sv) checks all 3entry values, removal of old destination keys, independence after source updates/deletion, and clearing everything with an empty source. This copies scalar values; it does not require recursive deep copying of class objects.

<a id="実行結果"></a>

## Execution results

Execution used Icarus Verilog 13.0 stable (v13_0-dirty) and Verilator 5.052 (2026-09-05, vUNKNOWN-built20260905). Verilator was checked with initial seeds 1 and 73.

- Verilator: for current inputs, 8 tests match for both seeds; 7 have known mismatches or cannot compile.
- Icarus: all 15 tests are known because associative arrays or related features cannot compile. Compilation was actually attempted; this does not count as success.

The initial run of 15 tests is in the following 3 files.

- [associative-gaps-20261023-icarus13.json](../coverage/results/associative-gaps-20261023-icarus13.json)
- [associative-gaps-20261023-verilator-seed1.json](../coverage/results/associative-gaps-20261023-verilator-seed1.json)
- [associative-gaps-20261023-verilator-seed73.json](../coverage/results/associative-gaps-20261023-verilator-seed73.json)

We then added observations before overwriting wildcards and corrected the comment width of the count test. The result of rerunning each of the changed 2 files is the following 6 file. The success of the old input is not adopted, and 15 is not treated as a batch rerun or a synthesis of the tests into one run.

- [wildcard / Icarus](../coverage/results/associative-wildcard-refinement-20261023-icarus13.json)
- [wildcard / Verilator seed 1](../coverage/results/associative-wildcard-refinement-20261023-verilator-seed1.json)
- [wildcard / Verilator seed 73](../coverage/results/associative-wildcard-refinement-20261023-verilator-seed73.json)
- [count / Icarus](../coverage/results/associative-count-refinement-20261023-icarus13.json)
- [count / Verilator seed 1](../coverage/results/associative-count-refinement-20261023-verilator-seed1.json)
- [count / Verilator seed 73](../coverage/results/associative-count-refinement-20261023-verilator-seed73.json)

The 7 cases remaining in Verilator concern method-expression types, next from a nonexistent input, acceptance of ref actuals, signed-key order, cast context for index addition, 4-state values of missing reads, and ignoring invalid writes. The specific values have been recorded to [Simulator difference](simulator-differences.md#cases-added-after-the-2026-10-23-associative-array-review). Do not change standard-derived expected values to match implementations; the oracle for these 7 tests is only `spec`.

<a id="規格との対応と割合"></a>

## Standard mappings and percentages

The identifier of the 12,319 row and the denominator of the requirement definition have not been changed, and the corresponding basis of the 28 item has been added.

- All tests: 3,923 → 3,938.
- Registered bindings: From 928 to 943 tests. The unregistered tests is 2,995.
- Mapped requirements: 768 → 792 rows (24 added).
- Execution-verified requirements: 688 → 700 rows (12 added).
- The provisional requirements coverage (test design): 6.23% to 6.43% (792/12,319).
- The provisional execution confirmation rate is 5.58% to 5.68% ( 700/12,319 ).
- Finalized values: both design and execution remain unfinalized. Denominator approval, deduplication, and resolution of pending interpretations remain outstanding.

Of 24 newly mapped rows, 11 have recorded pass results. The 1 read/modify/write rows previously mapped only at design level are now execution-verified through separate new tests, so the increase is 12 rows. Requirements with set-level evidence increased from 44 to 45 rows. Retain existing groups and add independently complete alternative evidence for type/user-default read/modify/write and present/absent strict successors. No-warning behavior with user defaults and diagnostics without defaults form the AND group of 2 tests. Do not mark the whole row execution-verified until every member succeeds in the same run. Also recorded baseline-update reasons in `coverage/behavior-baseline.json`.

This adds missing observations for M45–M50. This does not establish complete coverage of all standard features, key types, widths, or diagnostic paths. The unobserved part of the broad complex requirement is left, for example, read of a key including X/Z, all conditions of a narrow scanning argument. Added scope-specific rejection reasons for 5 tests and 5 entries to [Assessment ledger](../coverage/test-matching-reviews.json). At least one registered mapping or scope-specific assessment does not mean complete review of a file. Mappings were made by AI and have not been verified by an independent person.

<a id="判別力と管理ファイルの検査"></a>

## Checks of discriminatory power and management files

Compiled and executed 11 temporary source variants on Verilator, detecting every one through disagreements with expected results. These are missing entries, incorrectly following source changes, missing defaults, truncating/sign-extending upper wildcard bit, making literal keys distinct entries, 2 traversal-order changes, extra warnings, and changed count-expression types. Variants that cannot compile do not count as successful detection. Wildcard sign extension was initially concealed by a later overwrite, so added pre-overwrite values, counts, and nonexistence checks and revalidated.

Apply warning condition `:expected_stderr_regex:` to raw stdout + stderr. The no-warning test fails even if ordinary stdout normalization removes extra `$warning`. For 2 tests requiring warnings, checked controls where synthetic correct-value output with only the warning removed fails, while input with WARNING added passes. This verifies the evaluator; it is not evidence of successful diagnostic behavior on an unsupported simulator. Diagnostic wording/source lines are not fixed, but the supported format contains identifying `warn` / `warning` terms.

Check the management tools' 74 tests, standard-material hashes, consistency of mapping evidence/execution records, and consistency of catalogs, statistics, depth, generated artifacts, and metadata. Retain existing requirement definitions, mapping evidence, set evidence, pending assessments, and previously uncommitted changes.
