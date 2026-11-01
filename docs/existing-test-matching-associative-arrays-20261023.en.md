<a id="既存テストの要求照合連想配列2026-10-23"></a>

# Requirement matching for existing tests: associative arrays (2026-10-23)

[English](existing-test-matching-associative-arrays-20261023.en.md) / [日本語](existing-test-matching-associative-arrays-20261023.md)

> Counts, percentages, and pending statuses in this document record their respective work dates.
> The current value is [Aggregated Summary](behavior-coverage-summary.en.md); the approval history for the denominator and interpretations is in
> See [Results of requirement extraction](requirement-extraction.en.md).

[Current coverage](behavior-coverage-summary.en.md) / [Comparison ledger for all tests](test-requirement-matching.en.md) / [Previous array-method mapping](existing-test-matching-array-methods-20261023.en.md)

The following records the state immediately after existing-test mapping. Subsequent [15 Adding a tests test to the missing observations](associative-gap-tests-20261023.en.md) records additions, execution results, and updated percentages.

<a id="今回の進捗"></a>

## Progress in this round

Reviewed 7.8, 7.8.1–7.8.7, 7.9, and 7.9.1–7.9.11 in the supplied IEEE 1800-2023, comparing stimuli and expected output for keys, allocation, defaults, counts, deletion, traversal, whole-object assignment, and passing by value.

- Registered bindings: 893 → 928 tests (added 35 of 3,923 total tests).
- Mapped requirements: 746 → 768 rows (22 added). Added 74 mapping-evidence entries from 38 tests.
- Execution-verified requirements: 672 → 688 rows (16 added).
- Provisional requirement coverage (test design): 6.23% (768/12,319).
- The provisional execution confirmation rate is 5.58% ( 688/12,319 ).
- Finalized values: both design and execution remain unfinalized. Denominator approval, deduplication, and resolution of pending interpretations remain outstanding.
- Tests without even one registered mapping: 2,995. Mappings based on verification content for every case remain incomplete.

Registered-test counts mean tests with at least one mapped observation, not files whose entire contents have been fully reviewed. AI performed the review; it is not independently verified by a person. Preserved all 12,319 requirement definitions, previous mappings/set evidence/assessments, and previously uncommitted changes.

<a id="採用した観測と集合証拠"></a>

## Accepted observations and set-level evidence

[test_assoc_array_iterate.sv](../tests/ch7/test_assoc_array_iterate.sv) traverses string keys forward/backward; forward traversal also prints all keys and values. Comparison with complete expected output verifies ordering/lookup that counts alone cannot reveal. Combined this with [test_associative_array_corner.sv](../tests/ch7/test_associative_array_corner.sv)'s full integral-key order/values as set evidence sharing general lookup, value retention, and key-order coverage.

[test_assoc_array_methods.sv](../tests/ch7/test_assoc_array_methods.sv) stores exists in a int variable and explicitly compares 1 for present and 0 for missing. This is a strong observation compared to many dedicated tests that judge by Boolean alone. In [test_assoc_class_null_and_alias_keys.sv](../tests/ch7/test_assoc_class_null_and_alias_keys.sv), overwriting of the same entry is distinguished by null key, base/derived object, and alias.

[test_assoc_array_iter_minimal.sv](../tests/ch7/test_assoc_array_iter_minimal.sv) calls next from final key c and checks both return value 0 and preservation of key c. Accepted this separately from tests checking only failure status.

Added collective evidence to 12 requirement rows, bringing the total to 44 rows.

- 2 rows for general lookup/order and entry retention/order: common members covering full string/integral order and values, plus each test's lookup/update retention.
- 2 row of num/size: absolute number of non-empty and 0 when empty.
- Read/modify/write initialization: type defaults and user-specified defaults.
- first/last 2 line: normal status1 and a narrow argument cut-off/status-1.
- 2 rows for next's strict successor and success-time updates: existing inputs, nonexistent inputs, and the narrow exception.
- narrow traversal: 4 method of first/last/next/prev.
- Rules that defaults do not affect methods: traversal/count after a missing read, plus copy/exists.
- Literal mapping: full replacement with index:value/default, and individual-entry writes.

Within groups use AND; between groups use OR. Count the whole row as execution-verified only when every member succeeds in the same run.

<a id="引用修正と再実行"></a>

## Citation corrections and reruns

The following 7 tests changed only `:lrm:`. Stimuli, expected values, oracles, and runners are unchanged.

- `ch7/test_assoc_array_methods.sv`: Added individual section 7.9.1–7.9.7 which is actually called.
- `ch7/test_assoc_array_edge.sv`: Added 7.9.1 of size/num.
- `ch7/test_assoc_next.sv`: corrected last citation 7.9.5 to 7.9.4/7.9.6 for the first/next operations actually used.
- `ch7/test_assoc_prev.sv`: corrected next citation 7.9.6 to 7.9.5/7.9.7 for the last/prev operations actually used.
- `ch7/test_assoc_narrow_prev_next_overflow.sv`: added next/prev 7.9.6/7.9.7 to 7.9.8.
- `ch7/test_assoc_allocate_on_write.sv`: added parent allocation-rule text 7.8.
- `ch6/test_edge_assoc_array_keys.sv`: Fixed from 7.8.1 of wildcard to 7.8.2 of string index.

Compiled and evaluated execution of 40 tests, including corrected inputs and set members, using both runners.

- [The result of Verilator 5.052](../coverage/results/associative-matching-20261023-verilator.json)：**37 pass、3 known**。
- [The result of Icarus 13.0](../coverage/results/associative-matching-20261023-icarus13.json) ： 0 pass、 40 known。 This includes compile non-compliance, etc.

The 3 known cases in Verilator concern unsupported ref actual syntax for associative elements with defaults and narrow traversal arguments. known is not converted to success. The following 6 of 22 new rows have only design mappings because recorded pass results for the required sets are incomplete.

- 7.8.7 INITIALIZE-BEFORE-READ-MODIFY。
- 7.9.4／7.9.5 INDEX-RESULT。
- 7.9.6 STRICT-SUCCESSOR／SUCCESS-UPDATE。
- 7.9.8 NARROW-INDEX-TRUNCATION。

The 40-test partial run does not overwrite saved snapshots for all 3,912 tests. This is not a batch rerun of all 3,923 tests; partial successes from separate runs are not combined into set evidence. Retained 2 existing narrow next/prev mappings and updated them to the input hashes after citation changes.

<a id="m44実際の操作と引用節のずれ"></a>

## M44: mismatch between actual operations and cited clauses

There was a quotation that made next correspond to the last paragraph, prev to the next paragraph, and string index to the wildcard paragraph, and it was corrected as above. Many files cite only parent 7.9; valid observations for individual 7.9.x rules do not automatically receive mapping approval. Made some strong observations more specific; left the remainder, including citation refinement, outstanding.

Correcting citations alone does not cover unobserved conditions. Simple dedicated next/prev tests lack return values or post-failure keys, so no mappings were registered for them yet.

<a id="m45boolean判定固定表示では戻り値1を確認できない"></a>

## M45: Boolean tests/fixed displays cannot verify return value 1

In `if (aa.exists(key))`, even incorrect 2 or -1 yields true. Even if you print a fixed string with "= 1", it is not proof that the method actually returned 1. Even if you check only the missing 0, you will not be able to fill in the correct 1 of the present.

first/last has the same issue; left tests checking status only as Boolean pending even when keys update correctly. Split these into sets observing ordinary 1 and narrow-case -1. Assignment to a int variable alone cannot measure the method expression's own type/width, so signature rows remain separately pending.

<a id="m46走査の終端statuskey保持未存在inputを区別する"></a>

## M46: Differentiation of the terminal status, key retention, and non‐existent input of the scan.

[test_assoc_next_2.sv](../tests/ch7/test_assoc_next_2.sv) checks result == 0 at the end but does not inspect the key after failure. The implementation of breaking the key on failure also works, so we adopted iter_minimal, which checks key c at the same time. Some dedicated prev tests inspect only terminal status without checking the key.

Only the test of keys where input must exist can not confirm the search from non-existent input. The narrow test, which selects non-existent 0 to 600, was adopted as a design reason, but since the execution is known, the normal status1 successes are not upgraded to the success of the entire row.

<a id="m47ref-actualによる呼出時点の確保が見えない"></a>

## M47: call-time allocation through ref actuals is unobserved

In `set_to(hits["new"],42)` of [test_assoc_allocate_on_write.sv](../tests/ch7/test_assoc_allocate_on_write.sv), the callee immediately writes to the ref formal. Without observing num/exists on callee entry, the test cannot distinguish allocation when passed as a ref actual from delayed allocation on the first write. Need passing by ref without writing, or an existence check at callee entry.

`set(a,12,9)` in [test_assoc_allocate_on_write_types.sv](../tests/ch7/test_assoc_allocate_on_write_types.sv) passes the whole associative array by ref, rather than a missing element. m[k]=v inside the callee allocates an ordinary assignment target. This is not proof of the ref pass of the missing element.

For read/modify/write defaults, combined results from user default10 to 15 and results from type/struct defaults as set-level evidence. Because the former is known, success of the latter alone does not establish execution verification of the whole set.

<a id="m48値とwarningの有無は別の観測"></a>

## M48: value and warning are separate observations.

Valid stdout observations verify ignored invalid-index writes and default values on missing reads. Required warnings and absence of warnings with user defaults are not checked. The same stdout can be created for an implementation that sends an extra warning to stderr or does not send the required warning.

Calling delete(missing-key) with only size0 or exists false does not verify the absence of warnings. Kept requirement rows involving warnings pending and accepted only independent observations such as deleting everything with delete().

<a id="m49キーの規格上正しい例だけでは変換正規化順序は確認できない"></a>

## M49: The conversion, normalization, and sequence cannot be verified by the standard correct example of the key.

Merely placing int and a string literal in a wildcard and obtaining size2 does not check normalization that removes leading zeros, aliasing with an equal-width bit vector, or unsigned treatment of signed values. Some files cite 7.8.1 without using wildcard itself.

Looking up a negative key does not establish signed ordering unless order including that key is examined. Retained the existing dedicated -3/0/2 observations, but kept broader rows pending where they also require a contrast with unsigned upper bit. Class-key order is arbitrary; compare repeated traversals of the same key set rather than expecting object-id/address order.

Checking only count/sum in foreach over struct keys does not verify order or stability within one run. Separate composite-key stimuli containing empty/null are also needed.

<a id="m50値コピーと全entryコピー再帰的なdeep-copyを区別する"></a>

## M50: Differentiate between value copy and full entry copy, recursive deep copy

“Deep copy” in [test_assoc_array_edge_cases_3.sv](../tests/ch7/test_assoc_array_edge_cases_3.sv) observes independence of int elements. This does not mean duplicating objects referenced by class-handle elements.

Even dedicated whole-array-assignment tests can check old-key removal, size, and one copied value without reading the other source entry's value at the destination. Matching only the count cannot detect losing one value, so the entire CLEAR-AND-COPY row remains pending. Existing individual replace-not-merge/value-copy observations are retained. Added value-passing observations where deleting/replacing input formals leaves callers unchanged to a separate corresponding requirement.

<a id="m51走査回数未使用宣言からの推定を避ける"></a>

## M51: avoid inference from traversal counts or unused declarations

The number of scans alone cannot detect the different order or the duplicate visits. The corner test's forward side displays key/value, so you can check the order in the expected text, but the reverse side only counts. Checked actual displays/branches and restricted mappings to the observed directions.

Do not infer arbitrary-width key behavior from files that only declare wildcard arrays. A function converting nested exists to bit also does not establish observation of the original method's exact int return value.

<a id="記録と検査"></a>

## Records and checks

Appended 40 tests and 65 entries to [Assessment ledger](../coverage/test-matching-reviews.json). Cumulative total: 312 tests, 419 entries. Assessment counts are neither counts of fully reviewed files nor additions to coverage. In comparison with the initial state, we confirmed that all the requirements definitions, existing coverage, set evidence, and judgment are maintained. Also verified that changes to 7 tests consist only of `:lrm:`, then regenerated catalogs, statistics, depth, and aggregates.

All 74 management-tool unit tests and consistency checks for text sources, coverage, matching, catalogs, statistics, depth, and generators succeeded. Metadata has 0 new issues and 378 known issues. `git diff --check` also succeeded.
